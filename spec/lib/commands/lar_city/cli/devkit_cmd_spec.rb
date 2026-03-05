require 'rails_helper'
require 'commands/lar_city/cli/devkit_cmd'

RSpec.describe LarCity::CLI::DevkitCmd, type: :command do
  let(:command) { described_class.new([], **command_opts) }
  let(:command_opts) { {} }
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  describe '#force?' do
    subject(:force?) { command.send(:force?) }

    context 'when --force option is true' do
      let(:command_opts) { { force: true } }

      it { expect(force?).to be true }
    end

    context 'when --force option is false' do
      let(:command_opts) { { force: false } }

      it { expect(force?).to be false }
    end

    context 'when --force option is not provided' do
      let(:command_opts) { {} }

      it { expect(force?).to be false }
    end
  end

  describe '#setup_webhooks' do
    subject(:run_command) { command.invoke(:setup_webhooks, [], **command_opts) }

    let(:command_opts) { { verbose: true, vendor: vendor_slug.to_s } }
    let(:stub_vendor_creds) { nil }
    let(:vendor_slug) { nil }

    context 'in test environment' do
      let(:command_opts) { { vendor: 'notion' } }

      around do |example|
        with_modified_env(RAILS_ENV: 'test') { example.run }
      end

      it { expect { run_command }.to output(%r{🚫 Skipping webhook setup in test environment}).to_stdout }
    end

    context 'in non-test environment' do
      before do
        allow(Rails.application.credentials).to receive(vendor_slug) { stub_vendor_creds }
      end

      around do |example|
        with_modified_env(RAILS_ENV: 'development') { example.run }
      end

      context 'when vendor is supported' do
        let(:stub_vendor_creds) { ActiveSupport::OrderedOptions.new }
        let(:webhook) { Webhook.find_by(slug: vendor_slug) }

        context 'and vendor is "notion"' do
          let(:vendor_slug) { :notion }
          let(:deal_database_id) { 'test-notion-deal-db-id' }
          let(:integration_id) { 'notion-int-id' }
          let(:mock_notion_creds) do
            { deal_database_id:, integration_id:, verification_token:, vendor_database_id: }
          end
          let(:vendor_database_id) { 'test-notion-db-id' }
          let(:verification_token) { 'test-notion-verification-token' }

          before do
            mock_notion_creds.each_pair do |key, value|
              stub_vendor_creds[key] = value
            end
          end

          context 'and the webhook does not exist' do
            it 'creates a new webhook' do
              expect { run_command }.to change(Webhook, :count).by(1).and \
                output(%r{⚡ Webhook for notion has been set up successfully}).to_stdout
            end

            context 'after creating the webhook' do
              before { run_command }

              it 'updates the expected webhook data' do
                mock_notion_creds.each_pair do |key, value|
                  next if %w[verification_token].include?(key.to_s)

                  expect(webhook.data[key.to_s]).to eq(value)
                end
              end

              it { expect(webhook.verification_token).to eq(verification_token) }

              it 'sets :records_index_workflow_name to the expected value' do
                expect(webhook.data['records_index_workflow_name']).to eq(Notion::Deals::DownloadLatestWorkflow.name.to_s)
              end

              it 'sets :record_download_workflow_name to the expected value' do
                expect(webhook.data['record_download_workflow_name']).to eq(Notion::Deals::DownloadWorkflow.name.to_s)
              end
            end
          end

          context 'when webhook exists' do
            let!(:webhook) { Fabricate(:webhook, integration: :notion, verification_token:, status: :active) }

            it { expect { run_command }.not_to(change(Webhook, :count)) }
            it { expect { run_command }.to change { webhook.reload.data['deal_database_id'] }.to(deal_database_id) }
            it { expect { run_command }.to change { webhook.reload.data['vendor_database_id'] }.to(vendor_database_id) }

            it do
              expect { run_command }.to \
                change { webhook.reload.data['records_index_workflow_name'] }
                  .to(Notion::Deals::DownloadLatestWorkflow.name.to_s)
            end

            it do
              expect { run_command }.to \
                change { webhook.reload.data['record_download_workflow_name'] }
                  .to(Notion::Deals::DownloadWorkflow.name.to_s)
            end

            # TODO: still sloppy codegen - verify all fields are updated as expected
            xit 'reports no changes if the webhook is up to date' do
              webhook.set_on_data(integration_id: 'notion-int-id', deal_database_id: 'deal-db-id')
              webhook.save!
              command.invoke(:setup_webhooks, [], { vendor: 'notion' })
              expect(stdout.string).to include('💅🏾 Webhook for notion is already up to date.')
            end

            # TODO: still sloppy codegen - verify all fields are updated as expected
            xit 'forces an upsert with the --force option' do
              command.invoke(:setup_webhooks, [], { vendor: 'notion', force: true })
              expect(stdout.string).to include('⚡ Webhook for notion has been set up successfully.')
              expect(webhook.reload.data['integration_id']).to eq('notion-int-id')
            end
          end
        end

        context 'with vendor "zoho"', skip: 'TODO: validate possibly sloppy codegen' do
          it 'raises NotImplementedError' do
            expect { command.invoke(:setup_webhooks, [], { vendor: 'zoho' }) }.to raise_error(NotImplementedError)
          end
        end
      end

      context 'with an unsupported vendor', skip: 'TODO: validate possibly sloppy codegen' do
        let(:vendor_slug) { 'unsupported-vendor' }
        let(:stub_vendor_creds) { nil }

        it 'raises ArgumentError' do
          expect { command.invoke(:setup_webhooks, [], { vendor: 'invalid' }) }.to raise_error(ArgumentError, /Unsupported vendor: invalid/)
        end
      end
    end
  end

  describe '#yeet_deploy' do
    subject(:run_command) { command.invoke(:yeet_deploy, [], **command_opts) }

    before do
      allow(command).to receive(:run)
      allow(command).to receive(:current_branch).and_return('feature-branch')
      allow(command).to receive(:detected_environment).and_return('production')
      allow(command).to receive(:block_deployment_on_uncommitted_changes!)
      allow(command).to receive(:block_deployment_on_same_branch!)
      allow(command).to receive(:block_deployment_on_release_branches!)
    end

    it 'runs the deployment commands' do
      run_command
      expect(command).to have_received(:run).with('git pull --ff', inline: true)
      expect(command).to have_received(:run).with('git push', inline: true)
      expect(command).to have_received(:run).with('git checkout releases/production', inline: true, mock_return: true)
      expect(command).to have_received(:run).with('git pull --ff', inline: true)
      expect(command).to have_received(:run).with(/git merge --no-ff feature-branch -m/, inline: true)
      expect(command).to have_received(:run).with('git push origin', 'HEAD:releases/production', inline: true, mock_return: true)
      expect(command).to have_received(:run).with('git switch feature-branch', inline: true)
    end

    context 'when deploy hook is configured' do
      before do
        allow(ENV).to receive(:fetch).with('APP_DEPLOY_PRODUCTION_HOOK_URL', nil).and_return('https://example.com/deploy')
      end

      it 'triggers the deploy hook' do
        run_command
        expect(command).to have_received(:run) do |*args|
          expect(args).to eq(['curl -X POST https://example.com/deploy', { inline: true }])
        end
      end
    end
  end

  describe '#peek' do
    subject(:run_command) { command.invoke(:peek, [], **command_opts) }

    before do
      allow(command).to receive(:run)
      allow(command).to receive(:check_or_prompt_for_branch_to_review).and_return('123')
    end

    context 'with web output' do
      let(:command_opts) { { output: 'web' } }

      it 'opens the PR in the browser' do
        run_command
        expect(command).to have_received(:run) do |*args|
          expect(args).to eq(['gh pr view 123 --web', { inline: true }])
        end
      end
    end

    context 'with inline output' do
      let(:command_opts) { { output: 'inline' } }

      it 'displays the PR in the console' do
        run_command
        expect(command).to have_received(:run) do |*args|
          expect(args).to eq(['gh pr view 123', { inline: true }])
        end
      end
    end
  end

  describe '#swaggerize' do
    subject(:run_command) { command.invoke(:swaggerize, [], **command_opts) }

    before do
      allow(command).to receive(:run)
    end

    it 'runs the rswag command' do
      run_command
      expect(command).to have_received(:run) do |*args|
        expect(args).to eq(['bundle exec rails rswag', { inline: true }])
      end
    end
  end

  describe '#logs' do
    subject(:run_command) { command.invoke(:logs, [], **command_opts) }

    before do
      allow(command).to receive(:run)
      allow(command).to receive(:mac?).and_return(true)
      allow(command).to receive(:log_stream_url).and_return('https://example.com/logs')
    end

    it 'opens the log stream URL' do
      run_command
      expect(command).to have_received(:run) do |*args|
        expect(args).to eq(['open --url https://example.com/logs'])
      end
    end
  end

  describe '#check_blueprint' do
    subject(:run_command) { command.invoke(:check_blueprint, [], **command_opts) }

    before do
      allow(command).to receive(:run)
      allow(command).to receive(:require_render_cli!)
      allow(ENV).to receive(:fetch).with('RENDER_WORKSPACE_ID').and_return('ws-123')
    end

    it 'validates the render blueprint' do
      run_command
      expect(command).to have_received(:run) do |*args|
        expect(args).to eq(['render blueprints validate', '--workspace ws-123', Rails.root.join('render.yaml')])
      end
    end
  end

  describe '#get_blueprint' do
    subject(:run_command) { command.invoke(:get_blueprint, [], **command_opts) }

    let(:command_opts) { { platform: 'digitalocean' } }

    before do
      allow(command).to receive(:run).and_return('yaml_content')
      allow(command).to receive(:require_doctl_cli!)
      allow(DigitalOcean::Utils).to receive(:app_id!).and_return('app-123')
      allow(DigitalOcean::Utils).to receive(:access_token!).and_return('do-token')
      allow(File).to receive(:read).and_return('<%= yaml_content %>')
      allow(File).to receive(:write).and_return(1)
    end

    it 'generates the blueprint' do
      run_command
      expect(command).to have_received(:run) do |*args|
        expect(args).to eq(['doctl apps spec get', 'app-123', '--access-token do-token', '--format yaml', { eval: true }])
      end
      expect(File).to have_received(:write) do |*args|
        expect(args).to eq([Rails.root.join('app.yaml'), 'yaml_content'])
      end
    end
  end

  describe '#build' do
    subject(:run_command) { command.invoke(:build, [], **command_opts) }

    let(:command_opts) { { platform: 'digitalocean' } }

    before do
      allow(command).to receive(:run)
      allow(command).to receive(:require_doctl_cli!)
      allow(DigitalOcean::Utils).to receive(:app_id!).and_return('app-123')
      allow(DigitalOcean::Utils).to receive(:access_token!).and_return('do-token')
    end

    it 'builds the project blueprint' do
      run_command
      expect(command).to have_received(:run) do |*args|
        expect(args).to eq(['doctl apps dev build', '--access-token do-token', '--app app-123'])
      end
    end
  end
end
