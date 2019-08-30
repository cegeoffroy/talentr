class CandidatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_candidates, only: [:show]

  def index
    @candidates = policy_scope(Candidate).order(created_at: :desc)
  end

  def show
    authorize @candidate
  end

  def new
    @candidate = Candidate.new
    @job = Job.find(params[:job_id])
    authorize @candidate
  end

  private

  def set_candidates
    @candidate = Candidate.find(params[:id])
  end
end
