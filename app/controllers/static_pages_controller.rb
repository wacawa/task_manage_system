class StaticPagesController < ApplicationController
  before_action :not_access, only: :top
  before_action :sort_user, only: :gest_login

  def top
  end

  def gest_login
    user ||= User.new
    if user.id.nil?
      password = SecureRandom.urlsafe_base64
      user.id = User.count + 1
      user.email = "gest#{format("%02d", user.id)}@email.com"
      user.password = password
    else
      #user.tasks.delete
    end
    if params[:date] == "today"
      user.expiration_date = DateTime.now.since(2.days)
    else
      user.expiration_date = DateTime.now.since(3.days)
    end
    user.save
    login(user)
    remember(user)
    redirect_to user_url(user)
  end

  #before_action
    
  def not_access
    if login_user.present?
      redirect_back fallback_location: login_user
    end
  end

  def sort_user
    User.where(provider: nil).each do |u|
      if u.expiration_date.nil? || u.expiration_date < DateTime.now
        user = u
        break
      end
    end
  end
end
