module Admin

  class UsersController < ApplicationController

    layout "admin"
    before_filter :verify_admin

    # GET /users
    # GET /users.xml
    def index
      @users = User.order("created_at ASC")

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @users }
      end
    end

    # GET /users/1
    # GET /users/1.xml
    def show
      @user = User.find(params[:id])

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
      @user = User.find(params[:id])
    end

    # POST /users
    # POST /users.xml
    def create
      @user = User.new
      @user.accessible = :all if current_user.is_admin?
      @user.name = params[:user][:name]
      @user.email = params[:user][:email]
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation] # in mass assigment this not pass
#      @user.activation_hash = Digest::SHA512.hexdigest(Time.zone.now.to_s)
      @user.role = User::ROLE_USER
      @user.status = (params[:user][:status] && params[:user][:status].to_i == 2) ? User::STATUS_ACTIVE : User::STATUS_NOTCONFIRMED

      respond_to do |format|
        if @user.save
          flash[:notice] = t('users.successfully_created') + @user.email
          format.html { redirect_to(user_url(@user), :notice => t(:saved)) }
        else
          format.html { render :action => "new" }
        end
      end
    end

    # PUT /users/1
    # PUT /users/1.xml
    def update
      @user = User.find(params[:id])
      @user.accessible = :all if current_user.is_admin?
      respond_to do |format|
        if @user.update_attributes(params[:user])
          format.html { redirect_to(edit_admin_user_path(@user), :notice => t(:saved))  }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /users/1
    # DELETE /users/1.xml
    def destroy
      @user = User.find(params[:id])
      @user.destroy

      respond_to do |format|
        format.html { redirect_to(admin_users_url) }
        format.xml  { head :ok }
      end
    end

    def block
      @user = User.find(params[:id])
      @user.block
    end

    def refresh_messages_size
      user = User.find(params[:id])
      user.import_messages.each do |im|
          if im.importing?
            redirect_to(edit_admin_user_path(user), :notice => 'Obecnie trwa import. Sprobuj za chwile')
            return
          end
      end
      user.refresh_messages_size
      redirect_to(edit_admin_user_path(user))
      return
    end

    def refresh_attaches_size
      user = User.find(params[:id])
      user.refresh_attaches_size
      redirect_to(edit_admin_user_path(user))
      return
    end

  end
  
end