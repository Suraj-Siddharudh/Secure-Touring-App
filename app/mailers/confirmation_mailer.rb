class ConfirmationMailer < ApplicationMailer
     default from: ENV.fetch('MAILER_FROM', 'no-reply@touringapp.com')
    #   @bookmark = bookmark	 
    #  @user = User.where(id: Query.find(bookmark.user_id).pluck(:user_id))	

    def new_confirmation_mail
        email_id = User.where(id: params[:bookmark]).pluck(:email)
        mail(to: email_id, subject: 'Congratulations!!!! You got your tickets booked.. Yay!!!!')
     end
end
