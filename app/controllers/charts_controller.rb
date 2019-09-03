class ChartsController < ApplicationController
  def new_candidates
    render json: JobApplication.where(status: 'pending').group_by_day(:date).count
    authorize Candidate
  end
end
