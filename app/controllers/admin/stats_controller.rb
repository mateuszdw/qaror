module Admin

  class StatsController < ApplicationController

    layout "admin"
    before_filter :verify_admin

    def index

    end
  end
  
end