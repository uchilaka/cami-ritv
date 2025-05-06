# frozen_string_literal: true

class AccountPolicy < ApplicationPolicy
  def index?
    user.admin? || accessible_to_user?
  end

  def show?
    user.admin? || accessible_to_user?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || accessible_to_user?
  end

  def destroy?
    user.admin? || accessible_to_user?
  end

  def accessible_to_user?
    return true if user.has_role?(:customer, record)

    record.users.include?(user)
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope
          .includes(:members, :roles)
          .where(users: { id: user.id })
          .or(
            Account
              .where(
                roles: {
                  name: %w[customer contact],
                  users: { id: user.id },
                  resource_type: 'Account'
                }
              )
          )
      end
    end
  end
end
