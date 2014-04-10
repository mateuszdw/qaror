class AchievementsController < ApplicationController

  authorize_resource

  # GET /achievements
  # GET /achievements.xml
  def index
    @badges = Badge.all
    @badges.sort! { |a,b| a.name_humanized <=> b.name_humanized }
    @have_badges = current_user.achievements.map(&:badge_id) if current_user
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /achievements/1
  # GET /achievements/1.xml
  def show

    @badge = Badge.find_by_name!(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end

end
