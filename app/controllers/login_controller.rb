# encoding: utf-8
class LoginController < ApplicationController

  authorize_resource :class => false
  protect_from_forgery :except => :failure
  # nie uzywaj protect_from_forgery gdy request nadchodzi z omniauth
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
    flash[:notice] = 'podany adres OpenID nie pozwala na logowanie'
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

  
  # TODO do zrobienia podlaczanie kolejnych kont
  def login_with_omniauth
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'],omniauth['uid'])
    if authentication
      # jesli uid juz istnieje loguje odrazu
      # login_user_and_redirect sprawdza czy uzytkownik nie jest przypadkiem zablokowany albo cos
      login_user_and_redirect(authentication.user)
      p "uid jest ok - loguje"

#    elsif current_user
#      current_user.authentications.create!(:provider=> omniauth['provider'], :uid => omniauth['uid'])
#      flash[:notice] = "podpiecie dodatkowego konta"
#      redirect_to return_url
    else
      # jesli uid nie istnieje sprawdzam czy dany email byl już uzyty
      # zapisuje dane z uid
      # login_user_and_redirect sprawdza czy uzytkownik nie jest przypadkiem zablokowany albo cos
      if user = User.find_by_email(omniauth['user_info']['email'])
        p "email jest ok - loguje"
        user.authentications.build(:provider=> omniauth['provider'], :uid => omniauth['uid'])
        login_user_and_redirect(user)
      else
        user = User.new
        user.authentications.build(:provider=> omniauth['provider'], :uid => omniauth['uid'])
        user.name = User.generate_name_if_short_or_used(omniauth['user_info']['name'])
        user.email = omniauth['user_info']['email']
        pass = SecureRandom.hex(12)
        user.password = pass
        user.password_confirmation = pass
        user.status = User::STATUS_ACTIVE
        user.role = User::ROLE_USER
        user.remind_token = 1
        if user.save
          p "tworze nowe konto, nie bylo emaila ani uid"
          flash[:notice] = t('users.successfully_created') + omniauth['user_info']['email']
          login_user_and_redirect(user,return_url)
        else
          flash[:notice] = "Tworzenie konta przy użyciu #{omniauth['user_info']['email']} nie powiodło się.
Utwórz konto w tradycyjny sposób klikajac w przycisk Zarejestruj się na stronie logowania."
          redirect_to return_url
        end
      end
    end
  end

end
