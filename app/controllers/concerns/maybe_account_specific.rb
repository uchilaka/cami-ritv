# frozen_string_literal: true

module MaybeAccountSpecific
  extend ActiveSupport::Concern

  def self.included(base)
    # TODO: Read more about what base.extend(ClassMethods) does https://stackoverflow.com/a/45110474
    base.extend ClassMethods

    raise LarCity::MissingRequiredModule, "#{name} requires LarCity::CurrentAttributes" \
          unless base.include?(LarCity::CurrentAttributes)

    # unless base.respond_to?(:authorized_actions)
    #   raise StandardError, <<~ERROR
    #     #{name} must implement a class instance variable and accessor :authorized_actions
    #   ERROR
    # end
    #
    # unless base.send(:authorized_actions).is_a?(HashWithIndifferentAccess)
    #   raise StandardError, <<~ERROR
    #     #{name} must initialize @authorized_actions class instance variable as a HashWithIndifferentAccess
    #   ERROR
    # end
  end

  module ClassMethods
    def load_account(actions, options = {})
      supported_actions =
        if actions == :all
          %i[index show new edit create update destroy]
        elsif actions.is_a?(Array)
          [*actions].flatten
        else
          []
        end

      authorized_actions = supported_actions.each_with_object({}) do |action, actions_hash|
        actions_hash[action] = options
      end

      # Configure the before_action to set the account for the authorized actions
      before_action only: authorized_actions.keys.map(&:to_sym) do
        set_account(authorized_actions:)
      end
    end
  end

  attr_reader :account

  def set_account(authorized_actions: {})
    opts = action_options(authorized_actions.with_indifferent_access[action_name], action_name:)
    param_key = (opts[:id_keys] || []).find { |key| params[key].present? }
    return if param_key.blank?

    account_id = params[param_key]
    @account =
      if opts[:optional]
        policy_scope(Account).find_by(id: account_id)
      else
        policy_scope(Account).find(account_id)
      end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to opts[:bounce_to], notice: 'Account not found' }
      format.json { render json: { error: 'Account not found' }, status: :not_found }
    end
  ensure
    Current.account ||= @account
  end

  private

  def action_options(opts = {}, action_name: nil)
    opts.reverse_merge!(
      optional: !%w[show edit update].include?(action_name.to_s),
      bounce_to: :root_path,
      # NOTE: The order here is important! Ensure that you configure
      #   the more specific key that first when this option is customized.
      id_keys: %i[account_id id]
    )
    opts[:bounce_to] = send(opts[:bounce_to]) if respond_to?(opts[:bounce_to])
    opts
  end
end
