# frozen_string_literal: true

class InvoicesController < ApplicationController
  # skip_before_action :verify_authenticity_token, only: %i[search]

  include MaybeAccountSpecific

  load_account :all,
               optional: true,
               id_keys: %i[account_id],
               bounce_to: :invoices_path

  load_console

  before_action :set_invoice, only: %i[show show_modal edit update destroy]

  # GET /invoices or /invoices.json
  def index
    # TODO: Review when the policy scope should be applied in /invoices results.
    @query = policy_scope(Invoice).ransack(search_query.predicates)
    @query.sorts = search_query.sorters if search_query.sorters.any?
    @invoices = @query.result(distinct: true)
  end

  def search
    @query = Invoice.ransack(search_query.predicates)
    @query.sorts = search_query.sorters if search_query.sorters.any?
    # TODO: Break search query into:
    #   - search against invoice records (OR)
    #   - search against account association (OR)
    #   - search within user policy scope (AND)
    @invoices = policy_scope(@query.result(distinct: true)).reverse_order
  end

  # GET /invoices/1 or /invoices/1.json
  def show; end

  def show_modal; end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
  end

  # GET /invoices/1/edit
  def edit; end

  # POST /invoices or /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)

    respond_to do |format|
      if @invoice.save
        format.html { redirect_to @invoice, notice: 'Invoice was successfully created.' }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoices/1 or /invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to @invoice, notice: 'Invoice was successfully updated.' }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1 or /invoices/1.json
  def destroy
    @invoice.discard!

    respond_to do |format|
      format.html { redirect_to invoices_path, status: :see_other, notice: 'Invoice was successfully discarded.' }
      format.json { head :no_content }
    end
  end

  private

  def search_query
    @search_query ||= InvoiceSearchQuery.new(invoice_search_params[:q], params: invoice_search_params)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_invoice
    @invoice = policy_scope(Invoice).find(params[:id])
  end

  def invoice_search_params
    return invoice_search_array_params if params[:mode] == 'array'

    invoice_search_hash_params
  end

  def invoice_search_hash_params
    params.permit(:q, :mode, f: {}, s: {})
  end

  def invoice_search_array_params
    params.permit(:q, :mode, f: %i[field value], s: %i[field direction])
  end

  # Only allow a list of trusted parameters through.
  def invoice_params
    params
      .require(:invoice)
      .permit(
        :account_id,
        :invoicer,
        :invoice_number,
        :vendor_record_id,
        :payment_vendor,
        :status,
        :issued_at,
        :due_at,
        :updated_accounts_at,
        :amount,
        :amount_cents,
        :amount_currency,
        :due_amount,
        :due_amount_cents,
        :due_amount_currency,
        :currency_code,
        :metadata,
        :notes
      )
  end
end
