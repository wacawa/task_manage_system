class StaticPagesController < ApplicationController
  before_action :not_access, only: :top
  
  def top
  end

  def gest_login
    user = get_user
    user.email = "gest#{format("%02d", user.id)}@email.com"
    user.password = SecureRandom.urlsafe_base64
    user.expiration_date = DateTime.now.since(1.5.days)
    # year = user.expiration_date.year
    # month = user.expiration_date.month
    # day = user.expiration_date.day
    # hour = user.expiration_date.hour
    if user.save
      redirect_user(user)
    end
  end


  #before_action
    
    def not_access
      if login_user.present?
        redirect_back fallback_location: @login_user
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
      id ||= User.last.id + 1
      return User.new(id: id)
    end


end
