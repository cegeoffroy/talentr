class JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: [:show]

  def new
    @job = Job.new
    authorize @job
  end

  def create
    @job = Job.new(job_params)
    authorize @job
    @job.user = current_user
    if @job.valid?
      @job.save
      redirect_to job_path(@job)
    else
      render :new
    end
  end

  def show
    authorize @job
  end

  private

  def set_job
    @job = Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:title,
                                :due_date)
  end
end
