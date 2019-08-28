class UsersController < ApplicationController
  before_action :authenticate_user!
  def dashboard
    authorize User
    @jobs = current_user.jobs
    # @candidates = current_user.jobs.candidates
  end
end
