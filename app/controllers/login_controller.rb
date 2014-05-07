# encoding: utf-8
class LoginController < ApplicationController

  authorize_resource :class => false
  protect_from_forgery :except => :failure
  # if request comes from omniauth disable protect_from_forgery
  protect_from_forgery :unless => :return_url
  
  def index
    respond_to do |format|
      format.html
    end
  end

  #  POST
  # metoda logowania i tworzenia sesji
  def create
    respond_to do |format|
      format.html {
        if request.env["omniauth.auth"]
          login_with_omniauth
        else
          login_with_email_and_pass
        end
      }
    end
  end

  def logout
    respond_to do |format|
      format.html {
        session[:current_user_id] = nil
        reset_session
        redirect_to root_url
      }
    end
  end

  def failure
    flash[:notice] = t('users.omniauth_login_failed')
    redirect_to login_index_url
  end

private

  def login_with_email_and_pass
    if request.post? && params[:login] && params[:login][:email] && params[:login][:password]
        if params[:login][:email].blank? || params[:login][:password].blank?
          flash[:login_error] = t :all_fields_required
          redirect_to login_index_url
          return
        end
        if user = User.authenticate(params[:login][:email],params[:login][:password])
          login_user_and_redirect(user,params[:referer])
        else
          flash[:login_error] = t :login_error
          redirect_to login_index_url
        end
    else
        redirect_to root_url
    end
  end

  def return_url
    request.env['omniauth.origin']
  end

  def login_with_omniauth
    omniauth = request.env["omniauth.auth"]
    
    authentication = Authentication.find_by_provider_and_uid(omniauth.provider.to_s,omniauth.uid.to_s)
    if authentication
      # if uid exists log in instantly
      # login_user_and_redirect check if user is login, is active and not blocked
      login_user_and_redirect(authentication.user)

#    TODO do zrobienia podlaczanie kolejnych kont
#    elsif current_user
#      current_user.authentications.create!(:provider=> omniauth['provider'], :uid => omniauth['uid'])
#      flash[:notice] = "podpiecie dodatkowego konta"
#      redirect_to return_url
    else
      
      # if uid not exists check if email already used
      # login_user_and_redirect check if user is login, is active and not blocked
      if user = User.find_by_email(omniauth.info.email)
        user.authentications.build(:provider=> omniauth.provider, :uid => omniauth.uid)
        login_user_and_redirect(user)
      else
        user = User.new
        user.authentications.build(:provider=> omniauth.provider, :uid => omniauth.uid)
        user.name = User.generate_name_if_short_or_used(omniauth.info.name)
        user.email = omniauth.info.email
        pass = SecureRandom.hex(12)
        user.password = pass
        user.password_confirmation = pass
        user.status = User::STATUS_ACTIVE
        user.role = User::ROLE_USER
        user.remind_token = 1
        if user.save
#          p "create new account, no email and uid in database"
          flash[:notice] = t('users.successfully_created') + omniauth.info.email
          login_user_and_redirect(user,return_url)
        else
          flash[:notice] = t('users.omniauth_login_failed')
          redirect_to return_url
        end
      end
    end
  end

end
