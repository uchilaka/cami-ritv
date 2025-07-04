# frozen_string_literal: true

require 'rails_helper'
require 'fugit'

# Jobs testing guide: https://guides.rubyonrails.org/testing.html#testing-jobs
module Zoho
  RSpec.describe UpsertAccountJob, type: :job do
    before do
      Fixtures::Zoho::Serverinfo.new.invoke(:load, [], region_alpha2: 'US')
    end

    shared_examples 'a valid job schedule' do |schedule, expected_tz|
      let(:parsed_schedule) { ::Fugit.parse(schedule) }

      it { expect(parsed_schedule.class).to be(::Fugit::Cron) }
      it { expect(parsed_schedule.zone).to eq(expected_tz) }
    end

    it_behaves_like 'a valid job schedule', 'every 15 minutes America/New_York', 'America/New_York'
    it_behaves_like 'a valid job schedule', '*/15 5-9,12-13,18-22 * * 1-6 America/New_York', 'America/New_York'

    context 'for business accounts' do
      let(:record) { Fabricate :business }

      context 'when a record is created' do
        it do
          expect do
            described_class.perform_later(record.id)
            perform_enqueued_jobs
          end.to(change { record.reload.remote_crm_id })
        end

        it do
          expect do
            described_class.perform_now(record.id)
          end.to(change { record.reload.last_sent_to_crm_at })
        end
      end
    end
  end
end
