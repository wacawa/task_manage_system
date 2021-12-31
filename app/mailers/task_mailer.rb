class TaskMailer < ApplicationMailer

  def send_tasks(user, tasks)
    @user = user
    @tasks = tasks
    mail to: @user.email, subject: "【TimeBoxing】本日の予定。", from: "TimeBoxing"
  end

end
