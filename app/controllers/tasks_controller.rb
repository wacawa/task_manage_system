class TasksController < ApplicationController
  before_action :set_user
  # after_action :save_query, only: :new

  def new
    @day = params[:day]
    @hour = params[:hour]
    @form = Form::TaskCollection.new
  end

  def create
    @form = Form::TaskCollection.new(task_collection_params)
    if @form.save
      redirect_to request.referer
    else
      # render "users/show", day: params[:day], hour: params[:hour]
      redirect_back(fallback_location: request.referer)
    end


    # ActiveRecord::Base.transaction do 
    #   tasks_params.each do |task|
    #   end
    # rescue ActiveRecord::RecordInvalid
    #   redirect_to request.referer
    # end
    # debugger
    # # @tasks = 
  end

  private

    def task_collection_params
      params.require(:form_task_collection).permit(tasks_attributes: Form::Task::REGISTRABLE_ATTRIBUTES)
    end

  # after_action

    def save_query
      session[:day] = params[:day]
      session[:hour] = params[:hour]
    end

end
