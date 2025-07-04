# frozen_string_literal: true

class UpdateUserProfileWorkflow
  include Interactor
  include LarCity::ProfileParameterUtils

  # (profile_params:, current_user:, account: nil)
  def call
    current_user = context.current_user
    profile = current_user.profile || {}
    profile.reverse_merge!(UserProfile.new)
    profile_params =
      (context.profile_params.slice(*individual_profile_param_keys) if context.profile_params.present?)
    context.fail!(messages: ['No profile parameters provided']) unless profile_params.present?
    return unless context.success?

    # TODO: Improve this logic to allow for updating the email address on
    #   a profile if a User does not exist for it - otherwise, profile emails
    #   should ONLY be changed as a side-effect of a confirmed email update
    #   to the associated account's email.
    _updated_email = profile_params.delete(:email) unless current_user.admin?
    input_number = profile_params.delete(:phone)
    profile_params[:phone] = PhoneNumber.new(value: input_number) if input_number.present?
    current_user.update(profile: profile.merge(profile_params))
    context.fail!(message: current_user.errors.full_messages) if current_user.errors.any?
  ensure
    context.current_user = current_user.reload
  end

  class << self
    def allowed_parameter_keys
      # For standardized timezones: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
      # For IANA timezones: https://nodatime.org/TimeZones
      %i[image_url family_name given_name email phone country_alpha2 timezone]
    end
  end
end
