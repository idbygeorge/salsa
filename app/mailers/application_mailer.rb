class ApplicationMailer < ActionMailer::Base
  default from: ENV['SES_SMTP_FROM']
  layout 'mailer'
end
