class SearchController < ApplicationController

  skip_authorization_check

  def index
    begin
      raise Exceptions::Search, t(:search_presence) if params[:term].blank?
      search = params[:term]
      @tag = Tag.find_by_name(search)
      if @tag
        @thrs = @tag.thrs.active.paginate(:per_page =>10,:page=>params[:page])
      else
        @thrs = Thr.active.includes(:ans).
        where(:title.matches % "%#{search}%" | :content.matches % "%#{search}%" ).
        paginate(:per_page =>10,:page=>params[:page])
      end
      
      raise Exceptions::Search, t(:search_not_found) + ' "'+search+'"' if @thrs.blank?
      respond_to do |format|
        format.html
        format.js
      end
    rescue Exceptions::Search => text
      respond_to do |format|
        format.html { @error = text }
        format.js
      end
    end
  end

  def tags
    begin
      raise Exceptions::Search, t(:search_presence) if params[:term].nil?
      search = params[:term]
      @tags = Tag.where(:name.matches % "%#{search}%").limit(10)
      raise Exceptions::Search, t(:search_not_found) + ' "'+search+'"' if @tags.nil?
      respond_to do |format|
        format.html {
          ActiveRecord::Base.include_root_in_json = false
          render :json => @tags.inject([]) {|a,t| 
            a << {:value => t.name,:label=> "(#{t.quantity}) #{t.name}" };a
          }.to_json
        }
      end
    rescue Exceptions::Search => text
      respond_to do |format|
        format.html { render :layout=>nil,:text => text }
      end
    end
  end

end
