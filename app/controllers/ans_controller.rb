class AnsController < ApplicationController

  authorize_resource

  # GET /ans/1/edit
  def edit
    @an = An.active.find(params[:id])
    @an.revert_to params[:version].to_i if !params[:version].blank?
  end

  # POST /ans
  # POST /ans.xml
  def create
    # placed in thrs/answer
  end

  # PUT /ans/1
  # PUT /ans/1.xml
  def update
    @an = An.active.find(params[:id])

    @an.content = params[:an][:content]
    @an.updated_by = current_user
    @an.vsummary = params[:an][:vsummary]
    Extender::Activities.revise(@an,current_user) if @an.changed?
    respond_to do |format|
      if @an.save
        format.html { redirect_to(@an.thr, :notice => t('ans.update.saved')) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @an.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ans/1
  # DELETE /ans/1.xml
  def destroy
    @an = An.active.find(params[:id])
    Extender::Activities.delete(@an,current_user)
    respond_to do |format|
      if @an.mark_as_destroy
        format.html { redirect_to(request.referer) }
        format.js { render :text=>'location.reload();' }
      else
        format.html { redirect_to(request.referer) }
        format.js { render_flash_window :content => unified_errors(@an) }
      end
    end
  end

  def vote
    @an = An.active.find(params[:id])
    
    params[:vote] == 'up' ? authorize!(:vote_up,An) : authorize!(:vote_down,An)

    respond_to do |format|
      if vote = @an.vote(current_user,params[:vote])
        format.html { redirect_to(request.referer) }
        format.js
      else
        format.html { redirect_to(request.referer) }
        format.js { render_flash_window :content => unified_errors(@an) }
      end
    end
  end

  def resolved
    @an = An.active.find(params[:id])
    Extender::Activities.an_resolved(@an,current_user) # oznaczam jako rozwiazane
    respond_to do |format|
      if @an.thr.user == current_user && @an.resolve # rozwiazuje
        format.html { redirect_to(request.referer) }
        format.js
      else
        format.html { redirect_to(request.referer) }
        format.js { render_flash_window :content => unified_errors(@an) }
      end
    end
  end

  def unresolved
    @an = An.active.find(params[:id])
    Extender::Activities.an_unresolved(@an,current_user)
    respond_to do |format|
      if @an.thr.user == current_user && @an.unresolve # rozwiazuje
        format.html { redirect_to(request.referer) }
        format.js
      else
        format.html { redirect_to(request.referer) }
        format.js { render_flash_window :content => unified_errors(@an) }
      end
    end
  end

  def history
    @an = An.find(params[:id])
    @versions = @an.versions.order("number DESC").paginate(:per_page=>default_per_page,:page=>params[:page])
  end

  def history
    @an = An.find(params[:id])
    @versions = @an.versions.order("number DESC").paginate(:per_page=>default_per_page,:page=>params[:page])
  end

  def report_flag
    @an = An.active.find(params[:id])
  end

  def flag
    @an = An.active.find(params[:id])
    Extender::Activities.flag(@an, current_user,params[:acomment])
    respond_to do |format|
      if @an.mark_as_hidden_if_needed
        format.html { redirect_to(request.referer) }
        format.js
      else
        format.html { redirect_to(request.referer) }
        format.js { render_flash_window :content => unified_errors(@an) }
      end
    end
  end

end
