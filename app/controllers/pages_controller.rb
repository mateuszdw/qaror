class PagesController < ApplicationController
  
  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.active.find(params[:id])
    render :action => "show"
  end

  def faq
    @page = Page.active.find('faq')
    render :action => "show"
  end

  def privacy
    @page = Page.active.find('privacy')
    render :action => "show"
  end

end
