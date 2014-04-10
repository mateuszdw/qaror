class TagsController < ApplicationController

  def index
    @tags = Tag.sortable(params[:sort]).paginate(:per_page =>35,:page=>params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @tag = Tag.find_by_name(params[:id])
    @thrs = Thr.active_or_closed.joins(:tags).where(:tags=>{:name=> params[:id]}).
      sortable(params[:sort]).paginate(:per_page =>10,:page=>params[:page])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

end
