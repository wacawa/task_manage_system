class UsersController < ApplicationController
  before_action :set_user, except: [:logged_in_user]
  before_action :logged_in_user, only: :show
  before_action :correct_user, only: :show
  before_action :session_update, only: :show
  before_action :create_time_gest, only: :show

  def show
    @tasks = @user.tasks.where(start_datetime: @time).order(:start_time)
    @tasks ||= []
    @ids = @tasks.pluck(:id).join("-")


    # start_times = @tasks.pluck(:start_time) if @tasks.present?
    # @overlap_start = start_times.select{|s| start_times.index(s) != start_times.rindex(s)}.uniq if start_times.present?



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
    if logged_in?
      @login_user.destroy 
      logout
    end
    flash[:destroy] = "退出しました。"
    redirect_to root_url
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:_] = "⚪︎"
      redirect_to @user
    else
      # flash.now[:user_unupdate] = "×"
      flash[:_] = "×"
      # redirect_back fallback_location: session[:default_url]
      # render :show
      redirect_to @user
    end
  end

  def send_mail
    time = time_hash(params[:year], params[:month], params[:day], params[:hour]).tomorrow
    @tasks = @user.tasks.where("finish_time > ?", Time.now).where("finish_time < ?", time)
    TaskMailer.send_tasks(@user, @tasks).deliver_now
    flash[:mail] = "送信しました。"
    redirect_to @user
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
        redirect_to user_url(login_user) 
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
        limit = @user.expiration_date
        if limit < Time.now
          logout
          flash[:_] = "お疲れ様でした♪"
          redirect_to root_url
        end
      else
        @time = "#{params[:year]}-#{params[:month]}-#{params[:day]} #{params[:hour]}:00:00".to_time if params[:prev] || params[:next]
        @time ||= session_to_time
      end
    end

    # methods

      def time_hash(year, month, day, hour)
        return "#{year}-#{month}-#{day} #{hour}:00:00".to_time
      end
    
      def session_to_time
        hash = session[:default_time]
        return "#{hash["year"]}-#{hash["month"]}-#{hash["day"]} #{hash["hour"]}:00:00".to_time
      end

end
