class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_FROM', 'no-reply@touringapp.com')
  layout 'mailer'
end
