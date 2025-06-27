class UserController < ApplicationController
  def index
    @users = User.all
  end

  def show
    params.permit(:id).require(:id)
    @user = User.find(params[:id])
  end
end
