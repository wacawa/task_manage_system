class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.from_omniauth(request.env["omniauth.auth"])
    if user.save
      login(user)
      params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      redirect_to user_url(user)
    else
      render :new
    end
  end

  def create_email
    user = User.find_by(email: params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      login(user)
      params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      redirect_to user_url(user)
    else
      render :new
    end
  end

  def destroy
    logout if logged_in?
    redirect_to root_url
  end

end
