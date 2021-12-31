class SessionsController < ApplicationController
  def new
    @email = params[:email].gsub(/%40/, "@") unless params[:email].nil?
  end

  def create
    password = SecureRandom.urlsafe_base64
    user = User.from_omniauth(request.env["omniauth.auth"])
    user.id = User.last.id + 1
    user.password = password
    if user.save
      redirect_user(user, "おかえりなさいませ♪")
    else
      flash.now[:_] = "もう一度お願いします。"
      render "users/show"
    end
  end

  def create_email
    email = params[:session][:email]
    user = User.find_by(email: email)
    if user && user.authenticate(params[:session][:password])
      # params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      redirect_user(user, "おかえりなさいませ♪")
    else
      flash[:_] = "もう一度お願いします。"
      redirect_to root_url(email: email)
    end
  end

  def destroy
    user = User.find(params[:id])
    logout if logged_in?
    # flash[:_] = user.provider.nil? ? "退出しました。" : "ログアウトしました。"
    flash[:_] = "ログアウトしました。"
    redirect_to root_url
  end

end
