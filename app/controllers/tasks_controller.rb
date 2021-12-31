class TasksController < ApplicationController
  before_action :set_user

  def new
    @day = params[:day]
    @hour = params[:hour]
    @form = Form::TaskCollection.new
  end

  def create
    @form = Form::TaskCollection.new(task_collection_params)
    if @form.save
      flash[:_] = "⚪︎"
      # redirect_to request.referer
      redirect_to create_user_url(@user)
    else
      @form.tasks.count > 1 ? flash.now[:_] = "一部のタスクの作成に失敗しました" : flash.now[:_] = "×"
      # render "users/show", day: params[:day], hour: params[:hour]
      # redirect_back(fallback_location: session[:default_url])
      flash.now[:_] = "×"
      render "users/show"
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
    if @task.update_attributes(task_params)
      @task.memo = @task.memo.gsub(/(\r\n)*$/, "") if @task.memo.present?
      flash[:_] = "⚪︎"
      # redirect_to session[:default_url]
      redirect_to create_user_url(@user)
    else
      flash.now[:_] = "×"
      # redirect_back(fallback_location: request.referer)
      # redirect_to session[:default_url]
      render "users/show"
    end
  end

  private

    def task_collection_params
      params.require(:form_task_collection).permit(tasks_attributes: Form::Task::REGISTRABLE_ATTRIBUTES)
    end

    def task_params
      params.require(:task).permit(:title, :memo, :start_time, :finish_time, :start_datetime)
    end

end
