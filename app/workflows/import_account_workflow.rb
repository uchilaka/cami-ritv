# frozen_string_literal: true

class ImportAccountWorkflow
  include Interactor
  include InteractorInvoiceProcessing

  def call
    account, invoice = nil
    invoice_account = context.invoice_account
    invoice = context.invoice
    require_invoice_record_presence!

    context.accounts = lookup(invoice_account)
    if context.accounts.any?
      if link_accounts?
        if context.accounts.one?
          account = context.accounts.first
          if account.is_a?(Account)
            account.add_role(:customer, invoice)
            # Link the matching account to the invoice (if not already linked)
            if invoice.invoiceable.blank? && invoice.update(invoiceable: account)
              Rails.logger.info("Linked account #{account.id} to invoice #{invoice.id}", account:)
            end
          else
            context.fail!(message: I18n.t('workflows.import_account.errors.unsupported_record_type'))
          end
        else
          context.fail!(message: I18n.t('workflows.import_account.errors.multiple_matching_accounts'))
        end
      else
        context.fail!(message: I18n.t('workflows.import_account.errors.already_exists'))
      end
      return
    end

    email, display_name, _given_name, _family_name, _type =
      invoice_account.values_at 'email', 'display_name', 'given_name', 'family_name', 'type'
    display_name = email if display_name.blank?

    # Create an account for the business
    account = Account.new(display_name:, email:)

    if email.present?
      contact = AccountContact.new(display_name:, email:)
      account.metadata['contacts'] << contact.compose
    end

    account.save

    if account.persisted?
      Rails.logger.info(
        "Created account #{account.id} from invoice #{invoice.id}",
        account:
      )
      account.add_role(:customer, invoice)
      invoice.update(invoiceable: account) if invoice.invoiceable.blank?
    else
      context.errors = account.errors.full_messages
      context.fail!(message: I18n.t('workflows.import_account.errors.generic'))
    end
  rescue LarCity::Errors::InvalidInvoiceRecord => e
    context.fail!(message: e.message)
  ensure
    context.invoice = invoice
    context.account = account
  end

  private

  # Returns a list of any matching account(s) found
  def lookup(params)
    working_params = params.symbolize_keys
    email, _display_name, _type = working_params.values_at(:email, :display_name, :type)
    return Account.none unless email.present?

    # Check for a business account
    records = Account.where(email:)
    return records if records.any?

    # Check for accounts linked to a user via the invoice email address
    User.find_by(email:)&.accounts || records
  end
end
