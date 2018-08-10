class ApplicationMailer < ActionMailer::Base
  default from: ENV['SES_SMTP_USERNAME']
  layout 'mailer'
end
