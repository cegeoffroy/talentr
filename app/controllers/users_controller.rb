class UsersController < ApplicationController
  before_action :authenticate_user!
  def dashboard
    authorize User
    @jobs = current_user.jobs
    @candidates = current_user.candidates.sort_by(&:days_since_applied)
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
