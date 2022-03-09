class TaskMailer < ApplicationMailer
  default from: "TimeBoxing@email.com"

  def send_tasks(user, tasks)
    @user = user
    @tasks = tasks
    @wday = %w[日 月 火 水 木 金 土]
    mail to: @user.email, subject: "【TimeBoxing】本日#{Time.now.month}月#{Time.now.day}日の予定。", from: "TimeBoxing@email.com"
  end

end
