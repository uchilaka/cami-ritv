# frozen_string_literal: true

class AccountContact < NestedModel
  include ActiveModel::Attributes

  attribute :display_name, :string
  attribute :email, :string
  attribute :given_name, :string
  attribute :family_name, :string
  attribute :remote_crm_id, :string

  # attr_accessor :display_name, :email, :given_name, :family_name, :remote_crm_id

  # define_attribute_methods :display_name, :email, :given_name, :family_name, :remote_crm_id

  validates :display_name, presence: true
  validates :email, email: true, presence: true

  def initialize(args = {})
    super
    clear_attribute_changes(%w[display_name email given_name family_name remote_crm_id])
  end

  def attributes
    {
      display_name:,
      email:,
      given_name:,
      family_name:,
      remote_crm_id:,
    }
  end
end
