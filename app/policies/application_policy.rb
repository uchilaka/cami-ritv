# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  alias resource record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    return true if user.admin?

    false
  end

  def show?
    return true if user.admin?

    false
  end

  def create?
    return true if user.admin?

    false
  end

  def new?
    create?
  end

  def update?
    return true if user.admin?

    false
  end

  def edit?
    update?
  end

  def destroy?
    return true if user.admin?

    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
