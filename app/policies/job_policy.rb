class JobPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end
  def create?
    true
  end

  def show?
    true
  end

  def filter?
    true
  end

  def remove_filter?
    filter?
  end
end
