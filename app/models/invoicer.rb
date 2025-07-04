# frozen_string_literal: true

class Invoicer < NestedModel
  attr_accessor :email

  define_attribute_methods :email

  def initialize(args = {})
    super
    clear_attribute_changes(%w[email])
  end

  validates :email, email: true, allow_nil: true

  def attributes
    { 'email' => nil }
  end
end
