class TasksController < ApplicationController
  before_action :set_user

  def new
    @time = (params[:ymd] + " " + params[:hour]).to_time
    @form = Form::TaskCollection.new
    @tasks = @user.tasks.where("start_datetime > ?", Time.now.yesterday).where("start_datetime < ?", Time.now).order(:start_time)
    next_tasks = @user.tasks.where("start_datetime >= ?", Time.now).order(:start_time)
    if @tasks.exists?
      if task = @tasks.where("start_time < ?", Time.now).where("finish_time > ?", Time.now).presence
        tasks = @tasks.where("start_time >= ?", task.first.start_time)
        array = tasks.pluck(:finish_time) - tasks.pluck(:start_time)
        @first_time = array.first
      end
    end
    if next_tasks.exists?
      if !next_tasks.where(start_time: @time).exists?
        @first_time = @time
      elsif next_task = next_tasks.where("start_time > ?", @time).presence
        next_tasks = next_tasks.where("start_time >= ?", next_task.first.start_time)
        next_array = next_tasks.pluck(:finish_time) - next_tasks.pluck(:start_time)
        @first_time = next_array.first
      end
    end
    @first_time ||= Time.now
  end

  def create
    @form = Form::TaskCollection.new(task_collection_params)
    if @form.save
      flash[:_] = "⚪︎"
      # redirect_to request.referer
      t = params[:time].to_time
      redirect_to user_url(@user, year: t.year, month: t.month, day: t.day, hour: t.hour, update: true)
      # redirect_to user_url(@user)
    else
      flash[:_] = @form.valid?.include?(true) ? "一部のタスクの作成に失敗しました" : "×"
      # render "users/show", day: params[:day], hour: params[:hour]
      # redirect_back(fallback_location: session[:default_url])
      # redirect_to user_url(@user)
      t = params[:time].to_time
      redirect_to user_url(@user, year: t.year, month: t.month, day: t.day, hour: t.hour, update: true)
      # render "users/show"
    end
  end

  def update
    @task = @user.tasks.find(params[:id])
    datetime = @task.start_datetime
    par = params[:task]
    if par[:start_time].present? && par[:finish_time].present?
      s = par[:start_time].split(":")
      f = par[:finish_time].split(":")
      time = @task.start_time.change(hour: s[0], min: s[1])
      diff = time - @task.start_time
      par[:start_time] = -12 * 60 * 60 < diff ? time : time.tomorrow
      par[:start_time] = diff < 12 * 60 * 60 ? time : time.yesterday if par[:start_time] == time
      time = @task.finish_time.change(hour: f[0], min: f[1])
      diff = time - @task.finish_time
      par[:finish_time] = -12 * 60 * 60 < diff ? time : time.tomorrow
      par[:finish_time] = diff < 12 * 60 * 60 ? time : time.yesterday if par[:finish_time] == time
      par[:finish_time] = @task.start_datetime.tomorrow if datetime.tomorrow < par[:finish_time]
    end
    t = params[:ymd].to_time
    if @task.update_attributes(task_params)
      @task.memo = @task.memo.gsub(/(\r\n)*$/, "") if @task.memo.present?
      flash[:_] = "⚪︎"
      # redirect_to session[:default_url]
      redirect_to user_url(@user, year: t.year, month: t.month, day: t.day, hour: params[:hour], update: true)
    else
      flash.now[:_] = "×"
      # redirect_back(fallback_location: request.referer)
      # redirect_to session[:default_url]
      redirect_to user_url(@user, year: t.year, month: t.month, day: t.day, hour: t.hour, update: true)
      # render "users/show"
    end
  end

  def destroy
    @task = @user.tasks.find(params[:id])
    @task.destroy
    flash[:_] = "⚪︎"
    t = params[:ymd].to_time
    redirect_to user_url(@user, year: t.year, month: t.month, day: t.day, hour: t.hour, update: true)
  end

  private

    def task_collection_params
      params.require(:form_task_collection).permit(tasks_attributes: Form::Task::REGISTRABLE_ATTRIBUTES)
    end

    def task_params
      params.require(:task).permit(:title, :memo, :start_time, :finish_time, :start_datetime)
    end

end
