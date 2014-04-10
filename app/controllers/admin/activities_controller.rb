module Admin
  
  class ActivitiesController < ApplicationController

    layout "admin"
    before_filter :verify_admin

    def index
      @activities = Activity.public_activities.order("created_at desc").
        not_undo.paginate(:per_page=>default_per_page,:page=>params[:page])

      respond_to do |format|
        format.html
      end
    end

    # flag and close activity
    def reported
      @activities = Activity.flagged_or_close.order("created_at desc").
        not_undo.paginate(:per_page=>default_per_page,:page=>params[:page])
    end

  end

end