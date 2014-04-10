#
# CLASS MOVED TO login_controller
#
#
class AuthenticationsController < ApplicationController
#
#  authorize_resource :class => false
#  # GET /authentications
#  # GET /authentications.xml
#  def index
#    @authentications = current_user.authentications if current_user
#  end
#
#  # POST /authentications
#  # POST /authentications.xml
#  def create
#    omniauth = request.env["omniauth.auth"]
#    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'],omniauth['uid'])
#    if authentication
#      flash[:notice] = "dane logowania juz sa"
#      login_user_and_redirect(authentication.user)
#    elsif current_user
#      current_user.authentications.create!(:provider=> omniauth['provider'], :uid => omniauth['uid'])
#      flash[:notice] = "podpiecie dodatkowego konta"
#      redirect_to return_url
#    else
#      if user = User.find_by_email(omniauth['user_info']['email'])
#        if user.active?
#          user.authentications.build(:provider=> omniauth['provider'], :uid => omniauth['uid'])
#          user.save
#          flash[:notice] = "konto juz jest aktywne - loguje"
#          login_user_and_redirect(user)
#        else
#          flash[:notice] = "Konto "+ omniauth['user_info']['email'] +" jest zablokowane"
#          redirect_to return_url
#        end
#      else
#        user = User.new
#        user.authentications.build(:provider=> omniauth['provider'], :uid => omniauth['uid'])
#        user.email = omniauth['user_info']['email']
#        pass = ActiveSupport::SecureRandom.hex(12)
#        user.password = pass
#        user.password_confirmation = pass
#        user.status = User::STATUS_ACTIVE
#        user.role = User::ROLE_USER
#        user.remind_token = 1
#        if user.save
#          flash[:notice] = "niema konta wogole. Tworze konto"
#          login_user_and_redirect(user,return_url)
#        else
#          redirect_to return_url
#        end
#      end
#    end
#
#  end
#
#  # DELETE /authentications/1
#  # DELETE /authentications/1.xml
#  def destroy
#    @authentication = Authentication.find(params[:id])
#    @authentication.destroy
#  end
#
#  def failure
#    flash[:notice] = 'podany adres OpenID nie pozwala na logowanie'
#    redirect_to login_index_url
#  end
#
##protected
##
##  def handle_unverified_request
##    true
##  end
#
#private
#
#  def return_url
#    request.env['omniauth.origin']
#  end
#
end
