class StaticPagesController < ApplicationController
  before_action :not_access, only: :top
  
  def top
  end

  def gest_login
    user = get_user
    user.email = "gest#{format("%02d", user.id)}@email.com"
    user.password = SecureRandom.urlsafe_base64
    user.expiration_date = DateTime.now.beginning_of_hour.since(1.day + 2.hours)
    if user.save
      redirect_user(user, "タスクを作成しましょう♪")
    end
  end

  def intro
  end


  #before_action
    
    def not_access
      if login_user.present?
        flash[:_] = "×"
        # redirect_back fallback_location: @login_user
        redirect_to create_user_url(login_user)
        # redirect_to request.referer
      end
    end


  #methods

    def get_user
      user = User.where(provider: nil).where.not(expiration_date: nil).order(:expiration_date).first
      user_ex_date(user)
      if @boolean && @ex_date < DateTime.now
        id = user.id
        user.destroy
      end
      id = 1 if User.find(1).nil?
      id ||= User.last.id + 1
      return User.new(id: id)
    end


end
