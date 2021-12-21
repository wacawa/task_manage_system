module SessionsHelper
  
  def login(user)
    session[:user_id] = user.id
  end

  def remember(user)
    user.remember
    user_ex_date(user)
    # cookies.signed[:user_id] = {value: user.id, expires: 1.day.from_now}
    # cookies[:remember_token] = {value: user.remember_token, expires: 1.day.from_now}
    if @boolean
      cookies.signed[:user_id] = {value: user.id, expires: @ex_date}
      cookies[:remember_token] = {value: user.remember_token, expires: @ex_date}
    else
      cookies.permanent.signed[:user_id] = user.id
      cookies.permanent[:remember_token] = user.remember_token
    end
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def login_user
    if (user_id = session[:user_id])
      @login_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        login(user)
        @login_user = user
      end
    end
  end

  def logged_in?
    !login_user.nil?
  end

  def logout
    forget(login_user)
    session.delete(:user_id)
    @login_user = nil
  end

end
