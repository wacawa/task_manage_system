class UsersController < ApplicationController
  before_action :logged_in_user, only: :show
  before_action :correct_user, only: :show

  def show
    @user = User.find(params[:id])
  end

  #before_action

    def logged_in_user
      unless logged_in?
        redirect_to root_url
      end 
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_back fallback_location: login_user unless @user == login_user
    end
end
