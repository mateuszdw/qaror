class CommentsController < ApplicationController

  authorize_resource

  # GET /comments
  # GET /comments.xml
  def index
    @commentable = find_commentable
    @comments = @commentable.comments.active

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])
    @commentable = find_commentable

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new

    @commentable = find_commentable
    @comment = Comment.new
    respond_to do |format|
      format.html # new.html.erb
      format.js # new.html.erb
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.active.find(params[:id])
    @commentable = find_commentable
  end

  # POST /comments
  # POST /comments.xml
  def create

    @commentable = find_commentable
    @comment = @commentable.comments.build #(params[:comment])

    @comment.content = params[:comment][:content]
    @comment.user_id = current_user.id
    Extender::Activities.create(@comment,current_user)

    respond_to do |format|
      if @comment.save
        format.html { redirect_to(@comment) }
        format.js {
          @comments = @commentable.comments.active
        }
      else
        format.html { render :action => "new" }
        format.js { render :action => "new" }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.active.find(params[:id])
    @commentable = @comment.commentable
    @comment.content = params[:comment][:content]    
    respond_to do |format|
      if @comment.save
        format.html { redirect_to(@comment) }
        format.js { 
          @comments = @commentable.comments.active
        }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.js { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.active.find(params[:id])
    @commentable = @comment.commentable
    Extender::Activities.delete(@comment,current_user)
    @comment.mark_as_destroy

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.js {
        @comments = @commentable.comments.active
      }
    end
  end

  def vote
    @comment = Comment.active.find(params[:id])

    params[:vote] == 'up' ? authorize!(:vote_up,Comment) : authorize!(:vote_down,Comment)

    respond_to do |format|
      if vote = @comment.vote(current_user,params[:vote])
        format.html { redirect_to(request.referer) }
        format.js
      else
        format.html { redirect_to(request.referer) }
        format.js { render_flash_window :content => @comment.errors[:base].first }
      end
    end
  end

private

  def find_commentable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end

end
