# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                        :uuid             not null, primary key
#  amount_cents              :integer          default(0), not null
#  amount_currency           :string           default("USD"), not null
#  due_amount_cents          :integer          default(0), not null
#  due_amount_currency       :string           default("USD"), not null
#  due_at                    :datetime
#  invoice_number            :string
#  invoiceable_type          :string
#  invoicer                  :jsonb
#  issued_at                 :datetime
#  links                     :jsonb
#  metadata                  :jsonb
#  notes                     :text
#  paid_at                   :datetime
#  payment_vendor            :string
#  payments                  :jsonb
#  status                    :enum             default("draft")
#  type                      :string           default("Invoice")
#  updated_accounts_at       :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  invoiceable_id            :uuid
#  vendor_record_id          :string
#  vendor_recurring_group_id :string
#
# Indexes
#
#  index_invoices_on_invoiceable                          (invoiceable_type,invoiceable_id)
#  index_invoices_on_invoiceable_type_and_invoiceable_id  (invoiceable_type,invoiceable_id)
#
require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:account) { Fabricate :account }

  subject { Fabricate(:invoice, invoiceable: account) }

  # The basics
  it { is_expected.to have_many(:roles).dependent(:destroy) }

  describe 'when accessed' do
    let(:user) { Fabricate :user }
    let(:account) { Fabricate :account }

    context 'by a user' do
      context 'with a "customer" role on the invoice' do
        before { user.add_role(:customer, subject) }

        it { expect(user.has_role?(:customer, subject)).to be true }
      end
      pending 'with a "contact" role on the invoice'
    end
  end

  describe '#amount' do
    context 'initialize' do
      subject { Invoice.new }

      it { expect(subject.amount).to eq 0 }
      xit do
        expect { subject.assign_attributes(amount: '4.99') }.to \
          raise_error(ArgumentError, 'Money#== supports only zero numerics')
      end
      it do
        expect { subject.assign_attributes(amount: 4.99) }.to \
          change { subject.amount_cents }.to 499
      end
      it do
        expect { subject.update(amount: 0.99) }.to \
          change { subject.amount_cents }.to 99
      end
    end

    context 'after save' do
      subject do
        described_class
          .new(
            invoice_number: random_invoice_number,
            amount: '14.50',
            payment_vendor: 'paypal'
          )
      end

      it { expect(subject).to be_valid }
      it { expect(subject.amount_cents).to eq 1450 }
      it { expect(subject.amount.format).to eq '$14.50' }
      it { expect(subject.amount.format(no_cents: true)).to eq '$14' }
      it { expect(subject.amount.format(symbol: false)).to eq '14.50' }
      it { expect { subject.save! }.not_to raise_error }
    end

    context 'after update' do
      subject { Fabricate :invoice, amount: 0 }

      it 'is valid with "4.99"' do
        expect { subject.update(amount: '4.99') }.to \
          change { subject.amount_cents }.to 499
        expect(subject).to be_valid
      end
    end
  end

  describe '#status' do
    # draft or scheduled to sent on send_bill
    it { is_expected.to transition_from(:draft).to(:sent).on_event(:send_bill) }
    it { is_expected.to transition_from(:scheduled).to(:sent).on_event(:send_bill) }

    # sent, scheduled, unpaid, payment_pending OR partially_paid to paid on paid_in_full
    it { is_expected.to transition_from(:scheduled).to(:paid).on_event(:paid_in_full) }
    it { is_expected.to transition_from(:sent).to(:paid).on_event(:paid_in_full) }
    it { is_expected.to transition_from(:unpaid).to(:paid).on_event(:paid_in_full) }
    it { is_expected.to transition_from(:payment_pending).to(:paid).on_event(:paid_in_full) }
    it { is_expected.to transition_from(:partially_paid).to(:paid).on_event(:paid_in_full) }

    # sent, scheduled, unpaid, payment_pending OR partially_paid to marked_as_paid on paid_via_transfer
    it { is_expected.to transition_from(:scheduled).to(:marked_as_paid).on_event(:paid_via_transfer) }
    it { is_expected.to transition_from(:sent).to(:marked_as_paid).on_event(:paid_via_transfer) }
    it { is_expected.to transition_from(:unpaid).to(:marked_as_paid).on_event(:paid_via_transfer) }
    it { is_expected.to transition_from(:payment_pending).to(:marked_as_paid).on_event(:paid_via_transfer) }
    it { is_expected.to transition_from(:partially_paid).to(:marked_as_paid).on_event(:paid_via_transfer) }

    # sent, scheduled, unpaid OR payment_pending to partially_paid on partial_payment
    it { is_expected.to transition_from(:sent).to(:partially_paid).on_event(:partial_payment) }
    it { is_expected.to transition_from(:scheduled).to(:partially_paid).on_event(:partial_payment) }
    it { is_expected.to transition_from(:unpaid).to(:partially_paid).on_event(:partial_payment) }
    it { is_expected.to transition_from(:payment_pending).to(:partially_paid).on_event(:partial_payment) }

    # sent, scheduled, unpaid OR payment_pending to unpaid on late_payment_30_days
    it { is_expected.to transition_from(:sent).to(:unpaid).on_event(:late_payment_30_days) }
    it { is_expected.to transition_from(:scheduled).to(:unpaid).on_event(:late_payment_30_days) }
    it { is_expected.to transition_from(:unpaid).to(:unpaid).on_event(:late_payment_30_days) }
    it { is_expected.to transition_from(:payment_pending).to(:unpaid).on_event(:late_payment_30_days) }

    # sent, scheduled, unpaid OR payment_pending to canceled on late_payment_90_days
    it { is_expected.to transition_from(:sent).to(:unpaid).on_event(:late_payment_90_days) }
    it { is_expected.to transition_from(:scheduled).to(:unpaid).on_event(:late_payment_90_days) }
    it { is_expected.to transition_from(:unpaid).to(:unpaid).on_event(:late_payment_90_days) }
    it { is_expected.to transition_from(:payment_pending).to(:unpaid).on_event(:late_payment_90_days) }

    it 'is draft by default' do
      expect(subject.status).to eq 'draft'
    end
  end

  describe '#paid?' do
    context 'when status = "paid"' do
      subject { Fabricate :invoice, status: :paid, paid_at: Time.current }

      it { expect(subject.paid?).to be true }
    end

    context 'when status != "paid"' do
      subject { Fabricate :invoice, status: :sent, paid_at: nil }

      it { expect(subject.paid?).to be false }
    end
  end

  describe '#past_due?' do
    context 'when due date is in the past' do
      subject { Fabricate :invoice, due_at: 1.day.ago }

      it { expect(subject.past_due?).to be true }
    end

    context 'when due date is in the future' do
      subject { Fabricate :invoice, due_at: 1.day.from_now }

      it { expect(subject.past_due?).to be false }
    end
  end

  describe '#overdue?' do
    context 'when due date is over 30 days in the past' do
      subject { Fabricate :invoice, due_at: 31.days.ago }

      it { expect(subject.overdue?).to be true }
    end

    context 'when past due but not yet overdue' do
      subject { Fabricate :invoice, due_at: 1.day.ago }

      it { expect(subject.overdue?).to be false }
    end

    context 'when account is current' do
      subject { Fabricate :invoice, status: :paid, due_at: 120.days.ago, paid_at: 1.day.ago }

      it { expect(subject.overdue?).to be false }
    end
  end

  describe '#actions' do
    context 'when invoice is unpaid' do
      subject { Fabricate :invoice, status: :draft }

      it 'includes the expected action hashes' do
        expect(subject.actions).to \
          match(
            back: hash_including(
              dom_id: anything,
              http_method: 'GET',
              label: 'Back to Invoices',
              url: anything
            ),
            edit: hash_including(
              dom_id: anything,
              http_method: 'GET',
              label: 'Edit',
              url: anything
            ),
            show: hash_including(
              dom_id: anything,
              http_method: 'GET',
              label: 'Invoice details',
              url: anything
            )
          )
      end

      it { expect(subject.actions.dig(:back, :url)).to match(%r{/invoices\?locale=en$}) }
      it { expect(subject.actions.dig(:edit, :url)).to match(%r{/invoices/#{subject.id}\?locale=en$}) }
      it { expect(subject.actions.dig(:show, :url)).to match(%r{/invoices/#{subject.id}\?locale=en$}) }
    end

    pending 'when invoice is sent'
    pending 'when invoice is paid'
    pending 'when invoice is overdue'
  end

  describe '#modal_dom_id' do
    it { expect(subject.modal_dom_id).to eq "#{subject.model_name.singular}--modal|#{subject.id}|" }

    context 'with content_type' do
      let(:content_type) { 'content' }

      it do
        expect(subject.modal_dom_id(content_type:)).to \
          eq "#{subject.model_name.singular}--#{content_type}--modal|#{subject.id}|"
      end
    end
  end

  describe '.fuzzy_search_predicate_key' do
    let(:fields) { %w[invoice_number status] }

    it do
      expect(described_class.fuzzy_search_predicate_key(*fields)).to \
        eq 'invoice_number_or_status_cont'
    end

    context 'with 1 field' do
      let(:fields) { %w[invoice_number] }

      context 'when an association is provided' do
        let(:association) { 'Account' }

        context 'and polymorphic is true' do
          let(:model_name) { :invoiceable }

          subject do
            described_class.fuzzy_search_predicate_key(*fields, model_name:, association:, polymorphic: true)
          end

          it do
            expect(subject).to \
              eq 'invoiceable_of_Account_type_invoice_number_cont'
          end
        end
      end

      context 'when association is provided' do
        let(:association) { 'Account' }
        let(:fields) { %w[display_name] }

        subject do
          described_class.fuzzy_search_predicate_key(*fields, association:)
        end

        it { expect(subject).to eq 'accounts_display_name_cont' }
      end
    end

    context 'with several fields' do
      let(:fields) { %w[display_name email] }

      context 'when association is provided' do
        let(:association) { 'Account' }

        context 'and polymorphic is true' do
          let(:model_name) { :invoiceable }

          subject do
            described_class.fuzzy_search_predicate_key(*fields, association:, model_name:, polymorphic: true)
          end

          it do
            expect(subject).to \
              eq 'invoiceable_of_Account_type_display_name_or_invoiceable_of_Account_type_email_cont'
          end
        end
      end

      context 'when association is provided' do
        let(:association) { 'Account' }

        subject do
          described_class.fuzzy_search_predicate_key(*fields, association:)
        end

        it do
          expect(subject).to \
            eq 'accounts_display_name_or_accounts_email_cont'
        end
      end
    end
  end
end
