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

  def privileges
    @privilege = APP_PRIVILEGES.inject([]) do |a,(k,v)|
      a << {:symbol=>k,:title=>v['title'],:desc=>v['desc'],:value=>v['value']}
      a
    end
    @privilege = @privilege.sort_by {|v| -v[:value]}
    @reputation = APP_REPUTATION.inject({}){|h,(k,v)| h[k.to_sym] = v; h}
  end

end
