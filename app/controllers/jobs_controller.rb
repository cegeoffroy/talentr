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
    @fields = session[:fields] || []
    @filtered_results = @job.candidates
    filter
    authorize @job
  end

  def filter
    if params[:job_id]
      @job = Job.find(params[:job_id])
    else
      @job = Job.find(params[:id])
    end
    @fields = []
    results = nil
    # execute if statemment if params variables are not-empty
    if params[:filter] && (!params[:filter][:variable].blank? || !params[:filter][:hidden].nil?)
      array = []
      if !params[:filter][:hidden].nil?
        array = params[:filter][:hidden].values.to_a
        array.select! { |item| item.match?(/.+---.+---.+/) }
      end
      hidden = array.any? || !params[:filter][:variable].blank?
    else
      hidden = false
    end

    if hidden
      s = "#{params[:filter][:variable]}---#{params[:filter][:comparator]}---#{params[:filter][:value]}"
      @fields << s
      if params[:filter][:hidden]
        params[:filter][:hidden].each do |k, v|
          @fields << v
        end
      end
      results = Job.search(@job, @fields)
    elsif session[:fields].any?
      binding.pry
      results = Job.search(@job, session[:fields])
    end
    p session[:fields]
    p results
    if !results.nil? && results.any?
      session[:fields] = @fields
      first = results[0]
      others = results[1..-1]
      @filtered_results = first.select do |n|
        others.all? do |o|
          o.include?(n)
        end
      end
      @filtered_results.map! { |id| Candidate.find(id) }
    elsif results.nil?
      @filtered_results = @job.candidates
    else
      @filtered_results = []
    end
    authorize @job
    respond_to do |format|
      format.html { render :show }
      format.js
    end
  end

  def remove_filter
    @job = Job.find(params[:job_id])
    @value = "#{params[:variable]}---#{params[:comparator]}---#{params[:value]}"
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
