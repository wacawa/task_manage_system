class ApplicationController < ActionController::Base
  include SessionsHelper

  def set_user
    if params[:id].present?
      @user = User.find(params[:id])
    elsif params[:user_id].present?
      @user = User.find(params[:user_id])
    else
      redirect_to root_url
    end
  end

  def user_ex_date(user)
    if user
      @ex_date = user.expiration_date
      @boolean = @ex_date.is_a?(Time)
    else
      debugger
      @ex_date = nil
      @boolean = false
    end
  end

  def redirect_user(user)
    login(user)
    remember(user)
    now = DateTime.now
    redirect_to user_url(user, year: now.year, month: now.month, day: now.day, hour: now.hour)
  end


end
