class CandidatePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  def show?
    true
  end

  def new?
    true
  end

  def new_candidates?
    true
  end
end
