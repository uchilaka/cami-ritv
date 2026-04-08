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
                expect(webhook.records_index_workflow_name).to eq(Notion::Deals::DownloadLatestWorkflow.name.to_s)
              end

              it 'sets :record_download_workflow_name to the expected value' do
                expect(webhook.record_download_workflow_name).to eq(Notion::Deals::DownloadWorkflow.name.to_s)
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
end
