class UsersController < ApplicationController

  authorize_resource :class => false

  # GET /users
  # GET /users.xml
  def index
    @users = User.active.sortable(params[:sort]).
      paginate(:per_page=>24,:page=>params[:page])


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.active.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = current_user
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new
    @user.name = params[:user][:name]
    @user.email = params[:user][:email]
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation] # in mass assigment this not pass
    @user.activation_hash = Digest::SHA512.hexdigest(Time.zone.now.to_s)
    @user.role = User::ROLE_USER
    @user.status = User::STATUS_NOTCONFIRMED

    @user.captcha = params[:user][:captcha]
    @user.captcha_key = params[:user][:captcha_key]

    respond_to do |format|
      if @user.save_with_captcha
        m = Mailer.registration_confirmation(@user).deliver
        flash[:notice] = t('users.successfully_created') + @user.email
        format.html { login_user_and_redirect(@user,@user) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = current_user

    @user.name = params[:user][:name]
    @user.email = params[:user][:email]
    @user.birth = Date.civil(params[:user][:"birth(1i)"].to_i,params[:user][:"birth(2i)"].to_i,params[:user][:"birth(3i)"].to_i)
#    @user.birth = params[:user][:birth]
    @user.www = params[:user][:www]
    @user.about = params[:user][:about]

    @user.user_setting.update_attributes(params[:user_setting])
    Extender::Activities.update_user(@user)
    respond_to do |format|
      if @user.save
        flash[:notice] = t :saved
        format.html { redirect_to(edit_user_url) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = current_user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  # GET /users/remind_password_create
  def remind_password_edit
    @user = User.new
  end

# POST /users/remind_password
  def remind_password
    @user = User.active.where(:email=>params[:user][:email]).first
    
    if @user.nil?
      flash[:user_error] = t 'users.email_not_exists_or_blocked'
      render :action => "remind_password_edit"
      return
    else
      @user.remind_token = SecureRandom.hex(18)
      @user.captcha = params[:user][:captcha]
      @user.captcha_key = params[:user][:captcha_key]
    end

    respond_to do |format|
      if @user.save_with_captcha
        Mailer.remind_password(@user).deliver
        flash[:notice] = t 'users.remind_password_send'
        format.html { redirect_to root_url }
      else
        format.html { render :action => "remind_password_edit" }
      end
    end
  end

  # POST /users/change_password
  def change_password
    # check hash
    @user = User.active.where(:remind_token=>params[:hash]).first
    if @user.nil?
      redirect_to root_url
      return
    end
    respond_to do |format|
      if request.post?
          @user.password = params[:user][:password]
          @user.password_confirmation = params[:user][:password_confirmation]
          @user.updating_password = true
          if @user.save
            @user.updating_password = false
            @user.remind_token = nil
            if @user.not_confirmed? # if user not active? or block?
              @user.activation_hash = nil
              @user.status = User::STATUS_ACTIVE
            end
            @user.save
            flash[:notice] = t "users.remind_password_confirm"
            format.html { redirect_to root_url }
          else
            format.html
          end
      else
        format.html
      end
    end
  end

  # GET /users/activate
  def activate
    @user = User.where(:activation_hash=>params[:hash],:status=> User::STATUS_NOTCONFIRMED).first
    respond_to do |format|
      unless @user.nil?
        @user.activation_hash = nil
        @user.status = User::STATUS_ACTIVE
        @user.save
        Extender::Activities.confirm_email(@user)
        flash[:notice] = t :user_successfully_activated
        format.html { redirect_to root_url}
      else
        format.html { redirect_to root_url}
      end
    end
  end

  def send_activation_link
    @user = User.where(:status=>User::STATUS_NOTCONFIRMED).find(params[:id])
    @user.activation_hash = Digest::SHA512.hexdigest(Time.zone.now.to_s)

    respond_to do |format|
      if @user.save
        m = Mailer.registration_confirmation(@user).deliver
        flash[:notice] = 'Wyslano link aktywacyjny'
        format.html { redirect_to :action => "edit" }
#        format.js { render_flash_window :content => 'Wyslano link aktywacyjny'}
      end
    end
  end

  def ako
    # params[:k] - api key
    # params[:opt] - option / unckeck all subscribed field / uncheck question only
    # params[:opt_id] - option id
    @user = User.active.find_by_apikey!(params[:k])
    if params[:opt] == 'sub_q' && params[:opt_id] # users/ako?k=da42j..34jnk&opt=sub_q&opt_id=11
      @thr = Thr.find(params[:opt_id])
      @thr.subscribe(@user.id) if @thr.subscribed?(@user.id)
      flash[:notice] = t "users.subscription.uncheck_thr"
      redirect_to @thr
    elsif params[:opt] == 'sub_a'
      @user.user_setting.uncheck_all_notifies
      flash[:notice] = t "users.subscription.uncheck_all"
      redirect_to @user
    else
      response_404
    end
  end

  def activity
    @user = User.active.find(params[:id])
  end

  def votes
    @user = User.active.find(params[:id])
  end

  def favorites
    @user = User.active.find(params[:id])
  end

end
