class UsersController < ApplicationController
  before_action :set_user, except: [:logged_in_user]
  before_action :logged_in_user, only: :show
  before_action :correct_user, only: :show
  before_action :session_delete, only: :show
  before_action :create_time, only: :show
  before_action :edit_session_and_param, only: :show

  def show
    @within = @time <= Time.now && Time.now < @time.tomorrow
    @tasks = @task.present? ? @user.tasks.where(start_datetime: @task.start_datetime).order(:start_time) : []
    @day = [@time.day, @time.tomorrow.day]
    @hour = @time.hour
    @end_hour = @hour + 24
    @edit_task = @user.tasks.find(params[:task_id]) if params[:task_id]
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
      flash.now[:user_unupdate] = "×"
      # redirect_back fallback_location: session[:default_url]
      render :show
    end
  end

  def send_mail
    time_hash = session[:default_time].present? ? session[:default_time] : time_hash(params[:year], params[:month], params[:day], params[:hour])
    t = session[:default_time].map{|k,v| v}
    # time = "#{params[:year]}-#{params[:month]}-#{params[:day]} #{params[:hour]}:00:00".to_time
    time = "#{t[0]}-#{t[1]}-#{t[2]} #{t[3]}:00:00".to_time
    tasks = @user.tasks.where("start_datetime LIKE ?", time)
    @tasks = tasks.where("finish_time > ?", Time.now)
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

    def session_delete
      if @user.provider.blank?
        user_ex_date(@user)
        if @boolean && @ex_date < DateTime.now
          logout
          flash[:outsession] = "明日の計画を立てましょう♪"
          redirect_to root_url
        elsif !@boolean
          password = SecureRandom.urlsafe_base64
          @user.update(expiration_date: DateTime.now.since(1.day, 2.hours), password: password, password_confirmation: password)
        end
      end
    end

    def create_time
      if params[:year] && params[:month] && params[:day] && params[:hour]
        @time = "#{params[:year]}-#{params[:month]}-#{params[:day]} #{params[:hour]}:00:00".to_time
        @task = @user.tasks.where("start_datetime >= ?", @time).where("start_datetime < ?", @time.tomorrow).order(:start_datetime).first
      else
        @time = Time.now
        t = @time
        @task = @user.tasks.where("start_datetime > ?", @time.yesterday).where("start_datetime <= ?", @time).order(:start_datetime).last
        params[:year] = t.year
        params[:month] = t.month
        params[:day] = t.day
        params[:hour] = t.hour
        # redirect_to user_url(@user)
        # flash[:_] = "エラーが発生しました。"
        # redirect_to create_user_url(@user)
        # @time = Time.now.beginning_of_hour
        # @task = @user.tasks.where("start_datetime >= ?", @time.yesterday).where("start_datetime < ?", @time).order(:start_datetime).last
        # @time = @task.start_datetime if @task.present?
      end
      @time = @task.start_datetime if @task.present?
      session[:default_time] = {year: @time.year, month: @time.month, day: @time.day, hour: @time.hour} if session[:default_time].empty?
      @without_task = true if @task.blank?
    end

    def edit_session_and_param
      if @user.provider.present?
        if @time.tomorrow <= Time.now && Time.now < @time.since(2.days)
          datetime = @time.tomorrow
          session[:default_time] = {year: datetime.year, month: datetime.month, day: datetime.day, hour: datetime.hour}
          redirect_to create_user_url(@user)
        # elsif params[:day].to_i + 1 == DateTime.now.day && params[:hour].to_i <= DateTime.now.hour
          # params[:hour] = "#{DateTime.now.hour}"
        end
      end
    end

  # methods

    def time_hash(year, month, day, hour)
      return {year: year, month: month, day: day, hour: hour}
    end
    
end
