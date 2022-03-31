class UsersController < ApplicationController
  before_action :set_user, except: [:logged_in_user]
  before_action :logged_in_user, only: :show
  before_action :correct_user, only: :show
  before_action :session_update, only: :show
  before_action :create_time, only: [:show, :prev_time, :next_time]
  before_action :prev_time, only: :show
  before_action :next_time, only: :show

  def show
    # start_times = @tasks.pluck(:start_time) if @tasks.present?
    # @overlap_start = start_times.select{|s| start_times.index(s) != start_times.rindex(s)}.uniq if start_times.present?

    @within = @time <= Time.now && Time.now < @time.tomorrow
    @year = @time.year
    @month = @time.month
    @day = [@time.day, @time.tomorrow.day]
    @hour = @time.hour
    @end_hour = @hour + 24
    @edit_task = @user.tasks.find(params[:task_id]) if params[:task_id]
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
    time = (params[:ymd] + " " + params[:hour]).to_time.tomorrow
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

    def create_time
      if @user.provider.blank?
        limit = @user.expiration_date
        if limit < Time.now
          logout
          flash[:_] = "お疲れ様でした♪"
          redirect_to root_url
        end
      end
      @time = "#{params[:year]}-#{params[:month]}-#{params[:day]} #{params[:hour]}:00:00".to_time if params[:prev] || params[:next]
      @time ||= session_to_time
      @tasks = @user.tasks.where("finish_time > ?", @time).where("finish_time <= ?", @time.tomorrow).order(:start_time)
      time = @tasks.exists? ? @tasks.first.start_time : @time
      if time < @time
        @time = @tasks.first.start_time.beginning_of_hour
        session[:default_time] = {year: @time.year, month: @time.month, day: @time.day, hour: @time.hour}
      end
    end

    def prev_time
      prev_time = @user.tasks.where("start_datetime < ?", @time).order(:start_datetime).pluck(:start_datetime).uniq.last
      if prev_time && prev_time >= @time.yesterday
        time = @time.yesterday
      else
        time = prev_time ? @user.tasks.where(start_datetime: prev_time).order(:finish_time).last.finish_time.yesterday : nil
      end
      @prev_time = time
    end

    def next_time
      next_time = @user.tasks.where("start_time >= ?", @time.tomorrow).order(:start_time).pluck(:start_time).uniq.first
      if next_time && next_time < @time.since(2.days)
        time = @time.tomorrow
      else
        time = next_time
        session_time = (session[:default_time].map{|_,v|v}.join("-") + ":00:00").to_time
        time = session_time if time && time > session_time
      end
      @next_time = time
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
