class SessionsController < ApplicationController
  def new
  end

  def create
    password = SecureRandom.urlsafe_base64
    user = User.from_omniauth(request.env["omniauth.auth"])
    user.id = User.count + 1
    user.password = password
    if user.save
      login(user)
      remember(user)
      redirect_to user_url(user)
    else
      render :new
    end
  end

  def create_email
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      login(user)
      remember(user)
      # params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      redirect_to user_url(user)
    else
      redirect_to root_url(modal: true)
    end
  end

  def destroy
    logout if logged_in?
    redirect_to root_url
  end

end
