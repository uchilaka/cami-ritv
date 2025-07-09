# frozen_string_literal: true

class GenericEventPolicy < ApplicationPolicy
  def index?
    user.present? && user.admin?
  end

  def show?
    user.present? && (user.admin? || user.accounts.include?(record.eventable))
  end

  def create?
    user.present? && user.admin?
  end

  def update?
    user.present? && user.admin?
  end

  def destroy?
    user.present? && user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        # TODO: For now, only return events for the user's account.
        scope.kept.where(eventable: user.account)
      end
    end
  end
end
