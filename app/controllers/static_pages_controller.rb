class StaticPagesController < ApplicationController
  before_action :not_access, except: :intro
  
  def top
  end

  def gest_login
    user = User.new
    user.id = User.exists? ? ([*1..User.count] - User.pluck(:id)).first : 1
    user.id ||= User.last.id + 1
    user.email = "gest#{format("%02d", user.id)}@email.com"
    user.password = SecureRandom.urlsafe_base64
    user.expiration_date = Time.now.tomorrow.beginning_of_hour
    if user.save
      redirect_user(user, "タスクを作成しましょう♪")
    end
  end

  def intro
  end


  #before_action
    
    def not_access
      if logged_in?
        flash[:_] = "×"
        redirect_to user_url(login_user)
      end
    end

end
