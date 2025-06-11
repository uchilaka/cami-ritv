# frozen_string_literal: true

class InvoicePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # TODO: Figure out active query to filter against accounts_users
      #   and rolify tables for the invoices having :customer role
      #   against accounts accessible to this user (see :accessible_to_user?)
      if user.admin?
        scope.all
      else
        scope
          .kept
          .where(
            invoiceable: Account
                           .includes(:members)
                           .where(members: { id: user.id })
          )
          .or(
            scope
              .kept
              .where(invoiceable: user)
          )
      end
    end
  end

  def index?
    return true if user.admin?

    if Current.account.present?
      is_account_member?
    else
      user.has_role?(:customer) || user.has_role?(:contact)
    end
  end

  def show?
    return true if user.admin?
    return true if user.has_role?(:contact, record)

    update?
  end

  def create?
    return true if user.admin?
    return current_account_is?(:vendor) if Current.account.present?

    false
  end

  # Who can make changes to this invoice (e.g. update, void, mark as paid etc.)
  def update?
    create?
  end

  # Who can perform actions on this invoice (e.g. pay in full, dispute, etc.)
  def action?
    return true if create?
    return true if record.invoiceable == user
    return true if is_account_member? && current_account_is?(:customer)

    false
  end

  def destroy?
    user.admin? || update?
  end

  def accessible_to_user?
    # These seem terrible... Figure out a way to measure the
    # performance of this access control check. It might need
    # a refactor to come up  with an ad-hoc query to rule all
    # the access control via rolify problems 🤔
    return true if record.invoiceable == user
    return true if user.has_role?(:customer, record)
    return true if user.has_role?(:contact, record)
    return true if current_account_is?(:customer)

    false
  end

  def is_account_member?
    return false unless Current.account.present?

    Current.account.members.include?(user)
  end

  def current_account_is?(role)
    return false unless Current.account.present?

    Current.account.has_role?(role, record)
  end
end
