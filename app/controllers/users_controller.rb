class UsersController < ApplicationController
  before_action :authenticate_user!
  def dashboard
    authorize User
    @jobs = current_user.jobs
    @applications = current_user.job_applications.order(suitability: :desc).first(5)
    @count = @applications.count
  end

  def show
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    if @user.update(user_params)
      redirect_to
      user_path(@user)
    else
      render :show
    end
  end

  private

  def user_params
    params.require(:user).permit(:photo)
  end
end
