require 'rails_helper'
require 'commands/lar_city/cli/devkit_cmd'

RSpec.describe LarCity::CLI::DevkitCmd, type: :command do
  let(:command) { described_class.new }
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  before do
    # command.shell = Thor::Shell::IO.new(stdout, stderr)
    # TODO: Consider refactoring to use ClimateControl (via setting RAILS_ENV value) instead of stubbing Rails.env
    # allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
    # # Stub constants that might not be loaded
    # stub_const('Notion::Deals::DownloadLatestWorkflow', Class.new { def self.name; 'Notion::Deals::DownloadLatestWorkflow'; end })
    # stub_const('Notion::Deals::DownloadWorkflow', Class.new { def self.name; 'Notion::Deals::DownloadWorkflow'; end })
    # # Stub custom error class
    # stub_const('LarCity::CLI::Errors::UnsupportedOSError', Class.new(StandardError))
  end

  describe '#setup_webhooks' do
    subject(:run_command) { command.invoke(:setup_webhooks, [], **command_opts) }

    let(:command_opts) { { verbose: true, vendor: vendor_slug.to_s } }
    let(:stub_vendor_creds) { nil }
    let(:vendor_slug) { nil }

    context 'in test environment' do
      # before do
      #   allow(Rails.env).to receive(:test?).and_return(true)
      # end

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

      context "when vendor is supported" do
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
            # before do
            #   # TODO: Have the RSpec configuration handle cleaning the DB before each test
            #   matching_webhook = Webhook.find_by(slug: vendor_slug)
            #   matching_webhook.destroy if matching_webhook.present?
            # end

            it 'creates a new webhook' do
              expect { run_command }.to change(Webhook, :count).by(1).and \
                output(%r{⚡ Webhook for notion has been set up successfully}).to_stdout
            end

            it 'updates the expected webhook data' do
              run_command
              mock_notion_creds.each_pair do |key, value|
                next if %w[verification_token].include?(key.to_s)

                expect(webhook.data[key.to_s]).to eq(value)
              end
            end

            it 'sets :records_index_workflow_name to the expected value' do
              run_command
              expect(webhook.records_index_workflow_name).to eq(Notion::Deals::DownloadLatestWorkflow.name.to_s)
            end

            it 'sets :record_download_workflow_name to the expected value' do
              run_command
              expect(webhook.record_download_workflow_name).to eq(Notion::Deals::DownloadWorkflow.name.to_s)
            end
          end

          context 'when webhook exists', skip: "TODO: validate possibly sloppy codegen" do
            let!(:webhook) { Fabricate(:webhook, integration: :notion, verification_token:, status: :active) }

            it 'updates the existing webhook' do
              expect { command.invoke(:setup_webhooks, [], { vendor: 'notion' }) }.not_to change(Webhook, :count)
              expect(stdout.string).to include('⚡ Webhook for notion has been updated successfully.')
              expect(webhook.reload.data['integration_id']).to eq('notion-int-id')
            end

            it 'reports no changes if the webhook is up to date' do
              webhook.set_on_data(integration_id: 'notion-int-id', deal_database_id: 'deal-db-id')
              webhook.save!
              command.invoke(:setup_webhooks, [], { vendor: 'notion' })
              expect(stdout.string).to include('💅🏾 Webhook for notion is already up to date.')
            end

            it 'forces an upsert with the --force option' do
              command.invoke(:setup_webhooks, [], { vendor: 'notion', force: true })
              expect(stdout.string).to include('⚡ Webhook for notion has been set up successfully.')
              expect(webhook.reload.data['integration_id']).to eq('notion-int-id')
            end
          end
        end

        context 'with vendor "zoho"', skip: "TODO: validate possibly sloppy codegen" do
          it 'raises NotImplementedError' do
            expect { command.invoke(:setup_webhooks, [], { vendor: 'zoho' }) }.to raise_error(NotImplementedError)
          end
        end
      end

      context 'with an unsupported vendor', skip: "TODO: validate possibly sloppy codegen" do
        let(:vendor_slug) { 'unsupported-vendor' }
        let(:stub_vendor_creds) { nil }

        it 'raises ArgumentError' do
          expect { command.invoke(:setup_webhooks, [], { vendor: 'invalid' }) }.to raise_error(ArgumentError, /Unsupported vendor: invalid/)
        end
      end
    end
  end

  describe '#peek', skip: "TODO: validate possibly sloppy codegen" do
    before do
      allow(command).to receive(:`).with('git branch --list').and_return("* main\n  feature-branch")
      allow(command).to receive(:`).with('git rev-parse --abbrev-ref HEAD').and_return('main')
    end

    context 'when a PR exists' do
      before do
        allow(command).to receive(:`).with("gh pr list --head main --json number -q '.[].number'").and_return("123\n")
      end

      it 'views the PR on the web by default' do
        expect(command).to receive(:run).with('gh pr view 123 --web', inline: true)
        command.invoke(:peek, [], { interactive: false, branch_name: 'main' })
        expect(stdout.string).to include('PR number: 123')
      end

      it 'views the PR inline with --output=inline' do
        expect(command).to receive(:run).with('gh pr view 123', inline: true)
        command.invoke(:peek, [], { interactive: false, branch_name: 'main', output: 'inline' })
      end
    end

    context 'when no PR exists' do
      before do
        allow(command).to receive(:`).with("gh pr list --head feature-branch --json number -q '.[].number'").and_return("\n")
      end

      context 'in non-interactive mode' do
        it 'reports no PR was found' do
          command.invoke(:peek, [], { interactive: false, branch_name: 'feature-branch' })
          expect(stdout.string).to include('🙅🏾‍♂️ No PR found for branch feature-branch.')
        end
      end

      context 'in interactive mode' do
        it 'prompts to delete the branch and deletes it on "y"' do
          allow(command.shell).to receive(:ask).with(/Delete the feature-branch branch/).and_return('y')
          expect(command).to receive(:run).with('git branch --delete feature-branch', inline: true).and_return(true)
          # Interrupt the command loop after the first action
          allow(command).to receive(:prompt_for_branch_selection).and_raise(SystemExit)

          expect { command.invoke(:peek, [], { interactive: true, branch_name: 'feature-branch' }) }.to raise_error(SystemExit)
          expect(stdout.string).to include('Branch feature-branch deleted.')
        end

        it 'does not delete the branch on "n"' do
          allow(command.shell).to receive(:ask).with(/Delete the feature-branch branch/).and_return('n')
          expect(command).not_to receive(:run).with(/git branch --delete/)
          allow(command).to receive(:prompt_for_branch_selection).and_raise(SystemExit)

          expect { command.invoke(:peek, [], { interactive: true, branch_name: 'feature-branch' }) }.to raise_error(SystemExit)
        end
      end
    end
  end

  describe '#swaggerize', skip: "TODO: validate possibly sloppy codegen" do
    it 'executes the rswag command' do
      expect(ClimateControl).to receive(:modify).with(RAILS_ENV: 'test').and_yield
      expect(command).to receive(:system).with('bundle exec rails rswag')
      command.invoke(:swaggerize)
    end

    it 'does not execute on a dry run' do
      expect(command).not_to receive(:system)
      command.invoke(:swaggerize, [], { dry_run: true })
      expect(stdout.string).to include('Executing (dry-run): bundle exec rails rswag')
    end
  end

  describe '#logs', skip: "TODO: validate possibly sloppy codegen" do
    before do
      credentials = { betterstack: { team_id: 'team-id', source_id: 'source-id' } }
      allow(Rails.application).to receive(:credentials).and_return(credentials.with_indifferent_access)
    end

    context 'on macOS' do
      before { allow(command).to receive(:mac?).and_return(true) }

      it 'opens the log stream URL' do
        expected_url = 'https://logs.betterstack.com/team/team-id/tail?s=source-id'
        expect(command).to receive(:system).with("open --url #{expected_url}")
        command.invoke(:logs)
      end

      it 'does not open the URL on a dry run' do
        expect(command).not_to receive(:system)
        command.invoke(:logs, [], { dry_run: true })
        expect(stdout.string).to include('Executing (dry-run): open --url')
      end
    end

    context 'on a non-macOS system' do
      before { allow(command).to receive(:mac?).and_return(false) }

      it 'raises an UnsupportedOSError' do
        expect { command.invoke(:logs) }.to raise_error(LarCity::Errors::UnsupportedOSError, 'Unsupported OS')
      end
    end
  end
end
