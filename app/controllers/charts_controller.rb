class ChartsController < ApplicationController
  def new_candidates
    my_jobs = current_user.jobs
    render json: JobApplication.where(status: 'pending', job_id: my_jobs).group_by_day(:date).count
    authorize Candidate
  end
end
