# frozen_string_literal: true

class WebhooksController < ApplicationController
  before_action :set_webhook, only: %i[show edit update destroy]

  load_console

  # GET /webhooks or /webhooks.json
  def index
    @webhooks = policy_scope(Webhook)
  end

  # GET /webhooks/1 or /webhooks/1.json
  def show; end

  # GET /webhooks/new
  def new
    @webhook = authorize Webhook.new
  end

  # GET /webhooks/1/edit
  def edit; end

  # POST /webhooks or /webhooks.json
  def create
    @webhook = authorize Webhook.new(webhook_params)

    respond_to do |format|
      if @webhook.save
        format.html { redirect_to @webhook, notice: 'Webhook was successfully created.' }
        format.json { render :show, status: :created, location: @webhook }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @webhook.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /webhooks/1 or /webhooks/1.json
  def update
    respond_to do |format|
      if @webhook.update(webhook_params)
        format.html { redirect_to @webhook, notice: 'Webhook was successfully updated.' }
        format.json { render :show, status: :ok, location: @webhook }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @webhook.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /webhooks/1 or /webhooks/1.json
  def destroy
    @webhook.destroy!

    respond_to do |format|
      format.html { redirect_to webhooks_path, status: :see_other, notice: 'Webhook was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_webhook
    @webhook = authorize Webhook.friendly.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def webhook_params
    params
      .expect(
        webhook: %i[
          slug
          name
          readme
          integration_id
          integration_name
          dashboard_url
          content_management_url
          verification_token
        ]
      )
  end
end
