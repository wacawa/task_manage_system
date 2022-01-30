class TaskMailer < ApplicationMailer

  def send_tasks(user, tasks)
    @user = user
    @tasks = tasks
    mail from: "sample@gmail.com", to: @user.email, subject: "【TimeBoxing】本日の予定。"
  end

end
