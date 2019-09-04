class JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: [:show]

  def index
    @jobs = policy_scope(Job).order(due_date: :desc)
  end

  def new
    @job = Job.new
    authorize @job
  end

  def create
    keywords = params[:job][:keywords][:keywords]

    @job = Job.new(title: job_params[:title],
                   due_date: DateTime.parse(job_params[:due_date]))
    authorize @job
    @job.user = current_user
    if @job.valid?
      create_keywords(@job, keywords)
      redirect_to job_path(@job)
    else
      render :new
    end
  end

  def show
    @fields = []
    authorize @job
  end

  def filter
    @job = Job.find(params[:job_id])
    @fields = []
    if params[:filter]
      s = "#{params[:filter][:variable]}---#{params[:filter][:comparator]}---#{params[:filter][:value]}"
      @fields << s
      if params[:filter][:hidden]
        params[:filter][:hidden].each do |k, v|
          @fields << v
        end
      end
    end
    Job.search(@job, @fields)
    authorize @job
    respond_to do |format|
      format.js
    end
  end

  private

  def set_job
    @job = Job.find(params[:id])
  end

  def job_params
    params.require(:job).permit(:title, :due_date)
  end

  def create_keywords(job, keywords)
    keywords.split(",").each do |word|
      keyword = Keyword.find_or_create_by(word: word)
      JobKeyword.create(job: job, keyword: keyword)
    end
  end
end
