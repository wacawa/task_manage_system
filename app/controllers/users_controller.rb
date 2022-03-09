class UsersController < ApplicationController
  before_action :set_user, except: [:logged_in_user]
  before_action :logged_in_user, only: :show
  before_action :correct_user, only: :show
  before_action :session_update, only: :show
  before_action :create_time_gest, only: :show
  before_action :create_time_provider, only: :show

  def show
    @tasks = @user.tasks.where(start_datetime: @time).order(:start_time)
    @tasks ||= []
    @within = @time <= Time.now && Time.now < @time.tomorrow
    @year = @time.year
    @month = @time.month
    @day = [@time.day, @time.tomorrow.day]
    @hour = @time.hour
    @end_hour = @hour + 24
    @edit_task = @user.tasks.find(params[:task_id]) if params[:task_id]
    @prev = @user.tasks.where("start_datetime < ?", @time).order(:start_datetime).last
    @next = @user.tasks.where("start_datetime > ?", @time).order(:start_datetime).first
    @next_time = @next.start_datetime if @next.present?
    time = (session[:default_time].map{|_,v|v}.join("-") + ":00:00").to_time
    @next_time ||= time if time.is_a?(Time) && @time < time
  end

  def destroy
    @user.destroy
    flash[:destroy] = "退出しました。"
    redirect_to root_url
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:user_update] = "⚪︎"
      redirect_to create_user_url(@user)
    else
      # flash.now[:user_unupdate] = "×"
      flash[:user_unupdate] = "×"
      # redirect_back fallback_location: session[:default_url]
      # render :show
      redirect_to create_user_url(@user)
    end
  end

  def send_mail
    time_hash = session[:default_time].present? ? session[:default_time] : time_hash(params[:year], params[:month], params[:day], params[:hour])
    t = session[:default_time].map{|k,v| v}
    # time = "#{params[:year]}-#{params[:month]}-#{params[:day]} #{params[:hour]}:00:00".to_time
    time = "#{t[0]}-#{t[1]}-#{t[2]} #{t[3]}:00:00".to_time
    tasks = @user.tasks.where(start_datetime: time)
    @tasks = tasks.where("finish_time > ?", Time.now).order(:start_time)
    TaskMailer.send_tasks(@user, @tasks).deliver_now
    flash[:mail] = "送信しました。"
    redirect_to create_user_url(@user)
  end

  private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :provider, :expiration_date)
    end

  #before_action

    def logged_in_user
      unless logged_in?
        flash[:nologin] = "×"
        redirect_to root_url
      end 
    end

    def correct_user
      unless @user == login_user
        # t = Time.now
        # url = user_url(login_user, year: t.year, month: t.month, day: t.day, hour: t.hour)
        flash[:uncorrect] = "×"
        redirect_to create_user_url(login_user) 
      end
    end

    def session_update
      if @user.provider.present?
        hash = session[:default_time].empty? ? {} : session[:default_time]
        time = hash.empty? ? false : "#{hash["year"]}-#{hash["month"]}-#{hash["day"]} #{hash["hour"]}:00:00".to_time
        if time && time.tomorrow <= Time.now.beginning_of_hour
          datetime = time.tomorrow
          session[:default_time] = {year: datetime.year, month: datetime.month, day: datetime.day, hour: datetime.hour}
        end
      end
    end

    def create_time_gest
      if @user.provider.blank?
        user_ex_date(@user)
        if @boolean && @ex_date < DateTime.now
          logout
          flash[:_] = "お疲れ様でした♪"
          redirect_to root_url
        elsif !@boolean
          password = SecureRandom.urlsafe_base64
          @time = Time.now.beginning_of_hour.tomorrow
          @user.update(expiration_date: @time, password: password, password_confirmation: password)
          @time = @time.yesterday
        else
          hash = session[:default_time].empty? ? {} : session[:default_time]
          time = hash.empty? ? false : "#{hash["year"]}-#{hash["month"]}-#{hash["day"]} #{hash["hour"]}:00:00".to_time
          @time = "#{params[:year]}-#{params[:month]}-#{params[:day]} #{params[:hour]}:00:00".to_time if !time && params[:year]
          time ||= @user.tasks.exists? ? @user.tasks.first.start_datetime : false
          @time ||= time ? time : @user.expiration_date.yesterday.beginning_of_hour
        end
      end
    end

    def create_time_provider
      if @user.provider.present?
        @time = "#{params[:year]}-#{params[:month]}-#{params[:day]} #{params[:hour]}:00:00".to_time if params[:prev] || params[:next]
        unless @time
          hour = @user.tasks.exists? ? @user.tasks.order(:start_datetime).last.start_datetime.hour : false
          now = Time.now.beginning_of_hour
          time = hour ? now.change(hour: hour) : now
          @time = time > now ? time.yesterday : time
          session[:default_time] = {year: @time.year, month: @time.month, day: @time.day, hour: @time.hour}
        end
      end
    end

  # methods

    def time_hash(year, month, day, hour)
      return {year: year, month: month, day: day, hour: hour}
    end
    
end
