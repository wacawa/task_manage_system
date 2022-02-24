class UsersController < ApplicationController
  before_action :set_user, except: [:logged_in_user]
  before_action :logged_in_user, only: :show
  before_action :correct_user, only: :show
  before_action :create_tasks, only: :show

  def show
    @tasks ||= []
    @within = @time <= Time.now && Time.now < @time.tomorrow
    @year = @time.year
    @month = @time.month
    @day = [@time.day, @time.tomorrow.day]
    @hour = @time.hour
    @end_hour = @hour + 24
    @edit_task = @user.tasks.find(params[:task_id]) if params[:task_id]
    @prev = @user.tasks.order(:start_datetime).where("start_datetime < ?", @time).last
    @next = @user.tasks.order(:start_datetime).where("start_datetime > ?", @time).first
    @next_time = @next.start_datetime if @next.present?
    time = (session[:default_time].map{|_,v|v}.join("-") + ":00:00").to_time
    @next_time ||= time if time.is_a?(Time) && @time < time
    debugger
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

    def create_tasks
      if @user.provider.blank?
        user_ex_date(@user)
        if @boolean && @ex_date < DateTime.now
          logout
          flash[:outsession] = "お疲れ様でした♪"
          redirect_to root_url
        elsif !@boolean
          password = SecureRandom.urlsafe_base64
          @time = Time.now.beginning_of_hour.tomorrow
          @user.update(expiration_date: @time, password: password, password_confirmation: password)
          @time = @time.yesterday
        else
          hash = session[:default_time].empty? ? {} : session[:default_time]
          time = hash.empty? ? false : "#{hash["year"]}-#{hash["month"]}-#{hash["day"]} #{hash["hour"]}:00:00".to_time
          @time = "#{params[:year]}-#{params[:month]}-#{params[:day]} #{params[:hour]}:00:00".to_time
          @time ||= time
          @tasks = @user.tasks.where(start_datetime: @time).order(:start_time)
        end
      else
        if params[:year] && params[:month] && params[:day] && params[:hour]
          @time = "#{params[:year]}-#{params[:month]}-#{params[:day]} #{params[:hour]}:00:00".to_time
          s_datetime = @user.tasks.where("start_datetime > ?", @time).any?
          hash = session[:default_time].empty? ? {} : session[:default_time]
          time = hash.empty? ? false : "#{hash["year"]}-#{hash["month"]}-#{hash["day"]} #{hash["hour"]}:00:00".to_time
          if !s_datetime && time && time.tomorrow <= Time.now
            datetime = @time.tomorrow
            session[:default_time] = {year: datetime.year, month: datetime.month, day: datetime.day, hour: datetime.hour}
            redirect_to create_user_url(@user)
          end
        else
          @time = Time.now.beginning_of_hour
          @task = @user.tasks.where("start_datetime > ?", @time.yesterday).where("start_datetime <= ?", @time).order(:start_datetime).last
          # t = @time
          # params[:year] = t.year
          # params[:month] = t.month
          # params[:day] = t.day
          # params[:hour] = t.hour
          @time = @task.start_datetime if @task.present?
          session[:default_time] = {year: @time.year, month: @time.month, day: @time.day, hour: @time.hour} if session[:default_time].empty?
        end
        @tasks = @user.tasks.where(start_datetime: @time).order(:start_time)
        # @without_task = true if @task.blank?
      end
    end

  # methods

    def time_hash(year, month, day, hour)
      return {year: year, month: month, day: day, hour: hour}
    end
    
end
