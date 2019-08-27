class UsersController < ApplicationController
  before_action :authenticate_user!
  def dashboard
    authorize User
  end
end
