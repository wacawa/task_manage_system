# Preview all emails at http://localhost:3000/rails/mailers/task_mailer
class TaskMailerPreview < ActionMailer::Preview
  def test_mail
    @user = User.find(8)
    @tasks = @user.tasks.all
   
    TaskMailer.send_tasks(@user, @tasks)
  end
end
