class ApplicationController < ActionController::Base

  rescue_from ActiveRecord::RecordNotFound, :with => :response_404
  rescue_from CanCan::AccessDenied do |e|
    #    p e.action
    auth_failed(e.message.to_s + t(:unauthorize_desc,:link_to=> faq_url))
  end

  rescue_from ActiveRecord::RecordInvalid do |e| auth_failed(e.message) end

  protect_from_forgery

  layout "application"

  helper_method :current_user

  before_filter :check_auth
  before_filter :set_user_language, :set_time_zone

protected

  def default_per_page(per_page=nil)
    per_page.nil? || per_page.empty? ? APP_CONFIG['pagination_per_page'] : per_page
  end

  def unified_errors(model,attribute=nil)
    if model && attribute
      err = model.errors[attribute]
      err = err.first if err.is_a?(Array)
    else
      err = model.errors.full_messages.first
    end
    if err.include? 'base'
      err.split(' base ').last
    else
      err
    end
  end

private

  def verify_admin
      unless current_user.nil?
        response_404 unless current_user.is_admin?
      else
        response_404
      end
  end

  def response_404
    respond_to do |format|
        format.html { render_404 }
    end
    return false
  end

  def render_404
    render :layout=>nil,:file => "#{Rails.root.to_s}/public/404.html", :status =>404
  end

  def auth_failed(notice=nil)
    notice = notice.split(' base ').last if notice.include? 'base'
    notice = notice.nil? ? t(:unauthorized_http) : notice
    respond_to do |format|
        format.html {
           flash[:notice] = notice
           redirect_to request.referer ? request.referer : root_url
        }
        format.js {
           render_flash_window :content=> notice
        }
    end
  end

  def render_flash_window(hash)
    render :partial => 'shared/flash_window.js', :locals => hash
  end

  # narazie na sztywniaka ustawiam strefe czasowa i jezyk
  def set_time_zone
      Time.zone = 'Warsaw'
  end

  def set_user_language
#      I18n.locale = 'pl'
  end

  def check_auth
    respond_to do |format|
        format.html { check_session.nil? }
        format.json { check_session.nil? }
    end
  end

  def check_session
    if session[:cuid]
      @user_session = User.active.where(:id=>session[:cuid]).first
      if @user_session.nil?
        reset_session
        redirect_to root_url
        return
      else
#        @user_session.touch(:last_activity)
      end
    end
  end

  # aktualny, zalogowany user
  def current_user
    @user_session
  end

  #narazie uzywane tylko do logowania openid
  def login_user_and_redirect(user,redirect=nil)
    if user.active?
      user.last_login = Time.now
      Extender::Activities.day_activity(user)
      user.save
      session[:cuid] = user.id
    else
      flash[:notice] = t("users.email_not_exists_or_blocked")
    end

    if redirect.blank? || redirect == login_index_url
      redirect_to root_url
    else
      redirect_to redirect
    end
  end

  def detected_os
    case
      when request.user_agent =~ /Windows/ && !(request.user_agent =~ /x64/) then 1
      when request.user_agent =~ /(Windows)(.*)(x64)/i then 2
      when request.user_agent =~ /Linux i686/i then 3
      when request.user_agent =~ /Linux x86_64/i then 4
      when request.user_agent =~ /Linux i686 QT/i then 5
      when request.user_agent =~ /Linux x86_64 QT/i then 6
      when request.user_agent =~ /Mobile|webOS/ then 7
      else  1
    end
  end

end
