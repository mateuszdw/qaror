class MainController < ApplicationController

#  authorize_resource :class => false,:except=>[:index,:manual_set_lang,:wiki_parser]

  # this action is disabled, go to thrs#index
  def index

#    @tag_thr = Thr.joins(:tags).group("tags.name").limit(10).count(:id)
#    @users = User.order("created_at DESC").limit(8)
#
#    @thrs = Thr.active_or_closed.sortable(params[:sort]).paginate(:per_page=>default_per_page,:page=>params[:page])
#
#    @achievements = Achievement.order("created_at DESC").limit(15)

  end

#  def wiki_parser
#    respond_to do |format|
#      format.html { render :text=> wiki_decode(params[:data])}
#    end
#  end

#  def confirm_destroy
#    respond_to do |format|
#      format.html { render :layout=>nil}
#      format.xml
#    end
#  end

end
