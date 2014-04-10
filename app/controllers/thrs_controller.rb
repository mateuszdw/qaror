class ThrsController < ApplicationController

  authorize_resource :except => :index

  
  def index
    
    respond_to do |format|
      format.html {
        @tag_thr = Thr.joins(:tags).group("tags.name").limit(10).count(:id)
        @users = User.order("created_at DESC").limit(8)
        @thrs = Thr.active_or_closed.sortable(params[:sort]).paginate(:per_page=>default_per_page,:page=>params[:page])
        @achievements = Achievement.order("created_at DESC").limit(15)
      }
      format.json {
        @thrs = Thr.active_or_closed.sortable(params[:sort]).limit(5)
        render json: @thrs
      }
    end
  end

  def show

    show_action

    respond_to do |format|
      format.html # show.html.erb
      format.js { render 'schema' }
    end
  end

  def new
    
    @thr = Thr.new
    if session[:thr]
      @thr.title = session[:thr][:title]
      @thr.content = session[:thr][:content]
      @thr.tagnames = session[:thr][:tagnames]
    end
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @thr = Thr.find(params[:id])
    
#    p @thr
    if !params[:version].blank?
      restore_version = @thr.versions[params[:version].to_i]
      if restore_version
        @thr = @thr.version_at(restore_version.created_at - 3.seconds)
        @current_version = restore_version.index
      end
    else
      @current_version = @thr.versions.count
    end
  end

  def create

    @thr = Thr.new
    @thr.title = params[:thr][:title]
    @thr.content = params[:thr][:content]
    @thr.tagnames = params[:thr][:tagnames]
    @thr.add_attaches = params[:attaches]
    @thr.user_id = current_user.id if current_user

    @thr.captcha = params[:thr][:captcha]
    @thr.captcha_key = params[:thr][:captcha_key]

    respond_to do |format|
      # kolejnosc ma znaczenie
      if !@thr.valid_with_captcha? && cannot?(:skip_captcha,Thr)
        format.html { render :action => "new" }
      else
        Extender::Activities.create(@thr,current_user) if current_user
        if current_user && @thr.save
          session[:thr] = nil
          @thr.to_param
          format.html { redirect_to(@thr, :notice => t('thrs.create.saved')) }
        elsif !current_user && @thr.valid?
          session[:thr] = params[:thr]
          format.html { redirect_to(login_index_url, :notice => t(:question_stored)) }
        else
          format.html { render :action => "new" }
        end
      end
    end
  end

  def update
    @thr = Thr.find(params[:id])

    @thr.title = params[:thr][:title] if can?(:edit, @thr)
    @thr.content = params[:thr][:content] if can?(:edit, @thr)
    @thr.tagnames = params[:thr][:tagnames]
    @thr.vsummary = params[:thr][:vsummary]
    @thr.add_attaches = params[:attaches] if can?(:edit, @thr)
    @thr.updated_by = current_user
    Extender::Activities.revise(@thr,current_user) if @thr.changed?
    respond_to do |format|
      if @thr.save
        format.html { redirect_to(@thr, :notice => t('thrs.update.saved')) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @thr = Thr.find(params[:id])
    Extender::Activities.delete(@thr,current_user)
    respond_to do |format|
      if @thr.mark_as_destroy
        format.html { redirect_to(request.referer) }
        format.js { render :text=>'location.reload();' }
      else
        format.html { redirect_to(request.referer) }
        format.js { render_flash_window :content => unified_errors(@thr) }
      end
    end
  end

  def answer
    
    show_action

    if request.post?
      @thr = Thr.active.find(params[:an][:thr_id])

      @an = An.new
      @an.thr_id = params[:an][:thr_id]
      @an.content = params[:an][:content]
      @an.user_id = current_user.id if current_user
      Extender::Activities.create(@an,current_user) if current_user

      @an.captcha = params[:an][:captcha]
      @an.captcha_key = params[:an][:captcha_key]

    end
    
#    respond_to do |format|
      if request.post? && @an.valid_with_captcha? && cannot?(:skip_captcha,An)
        render 'show'
      else
        if request.post? && current_user && @an.save
          session[:an] = nil
          redirect_to( thr_url(@thr,:anchor=> 'an-' + @an.id.to_s), :notice => t("ans.create.saved"))
        elsif request.post? && !current_user && @an.valid?
          session[:an] = params[:an]
          redirect_to(login_index_url, :notice => t(:answer_stored))
        else
          render 'show'
        end
#      end
    end

  end

  def tagged
    
  end

  def vote
    @thr = Thr.find(params[:id])

    params[:vote] == 'up' ? authorize!(:vote_up,Thr) : authorize!(:vote_down,Thr)

    respond_to do |format|
      if vote = @thr.vote(current_user,params[:vote])
        format.html { redirect_to(request.referer) }
        format.js
      else
        format.html { redirect_to(request.referer) }
        format.js { render_flash_window :content => unified_errors(@thr) }
      end
    end
  end

  def fav
    @thr = Thr.find(params[:id])
    Extender::Activities.fav(@thr, current_user)

    respond_to do |format| 
      format.html { redirect_to(request.referer) }
      format.js
    end
  end

  def history
    @thr = Thr.find(params[:id])
    @versions = @thr.versions.order("number DESC").paginate(:per_page=>default_per_page,:page=>params[:page])
  end

  def report_close
    @thr = Thr.active.find(params[:id])
  end

  def report_flag
    @thr = Thr.active_or_closed.find(params[:id])
  end

  def close
    @thr = Thr.active.find(params[:id])
    Extender::Activities.close(@thr, current_user,params[:acomment])
    respond_to do |format|
      if @thr.mark_as_closed
        format.html { redirect_to(request.referer) }
        format.js
      else
        format.html { redirect_to(request.referer) }
        format.js { render_flash_window :content => unified_errors(@thr) }
      end
    end
  end

  def flag
    @thr = Thr.active_or_closed.find(params[:id])
    Extender::Activities.flag(@thr, current_user,params[:acomment])
    respond_to do |format|
      if @thr.mark_as_hidden_if_needed
        format.html { redirect_to(request.referer) }
        format.js
      else
        format.html { redirect_to(request.referer) }
        format.js { render_flash_window :content => unified_errors(@thr) }
      end
    end
  end

  def reopen
    @thr = Thr.closed.find(params[:id])
    @thr.status = Thr::STATUS_ACTIVE
    respond_to do |format|
      if @thr.save
        format.html { redirect_to(request.referer) }
        format.js
      else
        format.html { redirect_to(request.referer) }
        format.js
      end
    end
  end

  def subscribe
    @thr = Thr.find(params[:id])
    @subscribe = @thr.subscribe(current_user.id)
    respond_to do |format|
        format.html { redirect_to(request.referer) }
        format.js
    end
  end

private

  def show_action
    @thr = Thr.find(params[:id])

#    @thr.increment!(:hits)
    @thr.log_impression(request.remote_ip,current_user)

    if current_user
      @subscribe = @thr.subscriptions.where(:user_id=>current_user.id).first
      if @subscribe
        @subscribe.last_view = Time.now
        @subscribe.save
      end
    end

    @related_thrs = Thr.releated(@thr)
    @tag_thr = Thr.grouped_tags(@thr)

    @comment = Comment.new

    @an = An.new
    if session[:an]  
      @an.thr_id = session[:an][:thr_id]
      @an.content = session[:an][:content]
    end
    
    @ans = @thr.ans.active.sortable(params[:sort])
    
  end


end
