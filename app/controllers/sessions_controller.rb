class SessionsController < ApplicationController
  def new
    @email = params[:email].gsub(/%40/, "@") unless params[:email].nil?
    @line_state = SecureRandom.urlsafe_base64
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

  def line_login
    state = SecureRandom.urlsafe_base64
    # redirect_to "https://line-login-starter-20220124.herokuapp.com"
    # redirect_to "https://line-login-starter-20220124.herokuapp.com?response_type=code&client_id=1656830695
    # &redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fcallback&state=#{SecureRandom.urlsafe_base64}&scope=openid%20email"
    # redirect_to "https://access.line.me/oauth2/v2.1/authorize?response_type=code&client_id=1656830695
    # &redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fauth%2Fline%2F&state=#{state}&scope=openid%20email"
  end

  def create_line
    debugger
  end

  def destroy
    user = login_user
    if user.provider.nil?
      user.tasks.destroy_all
      msg = "退出しました。"
    else
      msg = "ログアウトしました。"
    end
    logout if logged_in?
    flash[:_] = msg
    redirect_to root_url
  end

end
