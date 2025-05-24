class AccountsController < ApplicationController
  include MaybeAccountSpecific
  include LarCity::ProfileParameterUtils

  class << self
    @authorized_actions = {}.with_indifferent_access
  end

  # load_account :all, optional: true, id_keys: %i[account_id id]
  load_account %i[show show_modal show_li_actions edit update update_crm destroy],
               optional: false, id_keys: %i[account_id id]

  load_console

  # before_action :set_account, only: %i[show edit update destroy]

  # GET /accounts or /accounts.json
  def index
    @accounts = policy_scope(Account)
  end

  # GET /accounts/1 or /accounts/1.json
  def show; end

  def show_modal
    # rubocop:disable Style/GuardClause
    if account.last_sent_to_crm_at
      human_readable_time = account.last_sent_to_crm_at.strftime('%B %d, %Y %I:%M %p')
      flash_notice = I18n.t('models.account.sync_to_crm_success', human_readable_time:)
      # Set a rails flash message to be displayed in the modal
      flash.now[:notice] = flash_notice
    end
    # rubocop:enable Style/GuardClause
  end

  def show_li_actions; end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit; end

  # POST /accounts or /accounts.json
  def create
    result = CreateAccountWorkflow.call(
      account_params: create_account_params,
      profile_params: create_profile_params,
      current_user:
    )
    @account = result.account

    respond_to do |format|
      if result.success?
        format.html { redirect_to account_url(@account), notice: 'Account was successfully created.' }
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new, status: :bad_request }
        format.json do
          render status: :bad_request, json: { account: result.account&.errors }
        end
      end
    end
  end

  # PATCH/PUT /accounts/1 or /accounts/1.json
  def update
    result = UpdateAccountWorkflow.call(
      account:, current_user:,
      account_params: update_params[:account],
      profile_params: update_params[:profile]
    )
    @account = result.account
    respond_to do |format|
      if result.success?
        format.html { redirect_to account_url(@account), notice: 'Account was successfully created.' }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :new, status: :bad_request }
        format.json do
          render status: :bad_request, json: { account: result.account&.errors }
        end
      end
    end
  end

  def push
    result = Zoho::API::Account.upsert(account)
    response_data = Zoho::API::Account.sync_callback!(result, account:)
    respond_to do |format|
      if response_data[:code] == 'SUCCESS'
        format.html { redirect_to account_url(@account), notice: 'Account was successfully updated.' }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :show, status: :bad_request, location: @account }
        format.json do
          render json: { errors: account.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /accounts/1 or /accounts/1.json
  def destroy
    @account.destroy!

    respond_to do |format|
      format.html { redirect_to accounts_path, status: :see_other, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.

  # TODO: Refactor the :create action to expect :account_params
  #   and :profile_params discretely from the frontend
  def create_account_params
    params
      .require(:account)
      .permit(*CreateAccountWorkflow.allowed_parameter_keys, metadata: {})
  end

  def create_profile_params
    params.permit(profile: create_profile_param_keys)[:profile]
  end

  def create_profile_param_keys
    (individual_profile_param_keys + business_profile_param_keys).uniq
  end

  def update_params
    params
      .permit(
        %i[integration],
        account: [*update_account_param_keys, { metadata: {} }],
        profile: create_profile_param_keys
      )
  end

  def update_account_param_keys
    base_keys = %i[display_name readme status tax_id phone]
    if authorize(@account, :edit?)
      base_keys + %i[email type]
    else
      base_keys
    end
  end
end
