module Admin
  
  class MainController < ApplicationController

    layout "admin"
    before_filter :verify_admin

    def index
#      @activities = Activity.limit(100).order("created_at desc")

      respond_to do |format|
        format.html
      end
    end

    # questions and answers, hidden and marked as delete
    def thrs
      @posts = Thr.hidden_or_deleted.order("created_at desc").paginate(:per_page=>default_per_page,:page=>params[:page])
      respond_to do |format|
        format.html { render 'posts' }
      end
    end

    def ans
      @posts = An.hidden_or_deleted.order("created_at desc").paginate(:per_page=>default_per_page,:page=>params[:page])
      respond_to do |format|
        format.html { render 'posts' }
      end
    end

    def comments
      @posts = Comment.deleted.order("created_at desc").paginate(:per_page=>default_per_page,:page=>params[:page])
      respond_to do |format|
        format.html { render 'posts' }
      end
    end

    def recover_post

    end

  end

end