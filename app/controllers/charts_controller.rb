class ChartsController < ApplicationController

  def new_candidates
    render json: Candidate.group_by_day(:created_at).count
    authorize Candidate
  end
end
