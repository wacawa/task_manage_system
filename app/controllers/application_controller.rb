class ApplicationController < ActionController::Base
  include SessionsHelper

  def set_user
    if params[:user_id].present?
      @user = User.find(params[:user_id])
    elsif params[:id].present?
      @user = User.find(params[:id])
    else
      redirect_to root_url
    end
  rescue
    redirect_to root_url
  end

  def create_user_url(user)
    return user_url(user, session[:default_time])
  end

  def user_ex_date(user)
    if user
      @ex_date = user.expiration_date
      @boolean = @ex_date.is_a?(Time)
    else
      @ex_date = nil
      @boolean = false
    end
  end

  def redirect_user(user, text)
    login(user)
    remember(user)
    now = DateTime.now
    session[:default_time] = {year: now.year, month: now.month, day: now.day, hour: now.hour}
    flash[:_] = text
    redirect_to user_url(user, session[:default_time])
  end


end
