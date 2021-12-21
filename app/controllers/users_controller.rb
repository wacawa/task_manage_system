class UsersController < ApplicationController
  before_action :set_user, except: [:logged_in_user]
  before_action :logged_in_user, only: :show
  before_action :correct_user, only: :show
  before_action :session_delete, only: :show
  before_action :edit_param, only: :show

  def show
    if params[:year] && params[:month] && params[:day] && params[:hour]
      t = "#{params[:year]}-#{params[:month]}-#{params[:day]} #{params[:hour]}:00:00".to_time
    else
      t = Time.now
      t = @user.expiration_date.yesterday
    end
    # task = @user.tasks.where("start_datetime >= ?", t.ago(0.5.days)).first
    task = @user.tasks.where("start_datetime >= ?", t).first
    @tasks = task.present? ? @user.tasks.where(start_datetime: task.start_datetime).order(:start_time) : []
    # @stimes = @tasks.pluck(:id, :start_time)
    start_time = @tasks.present? ? @tasks.first.start_time.to_time : t #Time.now.beginning_of_hour
    # @ym = ["#{t.year}-#{t.month}-", "#{t.tomorrow.year}-#{t.tomorrow.month}-"]
    @day = [start_time.day, start_time.tomorrow.day]
    @hour = start_time.hour
    # @end_hour = @hour + 25
    @end_hour = @hour + 24
    # debugger
  end

  def destroy
    @user.destroy
    redirect_to root_url
  end

  #before_action

    def logged_in_user
      unless logged_in?
        redirect_to root_url
      end 
    end

    def correct_user
      redirect_back fallback_location: login_user unless @user == login_user
    end

    def session_delete
      if @user.provider.blank?
        user_ex_date(@user)
        if @boolean && @ex_date < DateTime.now
          logout
        elsif !@boolean
          password = SecureRandom.urlsafe_base64
          @user.update(expiration_date: DateTime.now.since(1.5.days), password: password, password_confirmation: password)
        end
      end
    end

    def edit_param
      if @user.provider.present?
        debugger
        if params[:day].to_i + 1 < DateTime.now.day
          params[:day] = "#{params[:day].to_i + 1}"
        elsif params[:day].to_i + 1 == DateTime.now.day && params[:hour].to_i <= DateTime.now.hour
          params[:hour] = "#{DateTime.now.hour}"
        end
      end
    end
    
end
