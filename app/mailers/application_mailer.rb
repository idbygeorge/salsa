class ApplicationMailer < ActionMailer::Base
<<<<<<< HEAD
  default from: ENV['EMAIL_FROM']
=======
  default from: ENV['SES_SMTP_USERNAME']
>>>>>>> workflow-notifications
  layout 'mailer'
end
