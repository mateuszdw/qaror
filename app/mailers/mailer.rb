# encoding: utf-8

class Mailer < ActionMailer::Base
  default :from => APP_CONFIG['display_app_name']+' <notify@'+APP_CONFIG['app_domain']+'>'
  layout 'email'
  
  def registration_confirmation(user)
    @user = user
    mail(:to => user.email,:subject=>"#{APP_CONFIG['display_app_name']}: confirm your e-mail")
  end
  
  def remind_password(user)
    @user = user
    mail(:to => user.email,:subject=>"#{APP_CONFIG['display_app_name']}: change password")
  end

  def notify_thr_activity(user,thr)
    @user = user
    @thr = thr
    @last_activity = @thr.last_activity
    mail(:to => user.email,:subject=>"Question activity: #{@thr.title} - #{APP_CONFIG['display_app_name']}")
  end

end
