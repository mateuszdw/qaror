module ApplicationHelper

  def title(t)
    content_for(:title) { sanitize( strip_tags(t) ) }
    t
  end

  def snippet(thought, wordcount=10)
    thought.split[0..(wordcount-1)].join(" ") +(thought.split.size > wordcount ? "..." : "")
  end

  # komunikat wyswietlony zostanie tylko raz na stronie
  def field_messages_for(model, attribute=nil)
    if model && attribute
      err = model.errors[attribute]
      err = err.first if err.is_a?(Array)
    else
      err = model.errors.full_messages.first
    end
    if !err.nil? && !@field_messages_for_appears
      @field_messages_for_appears = true
      raw "<div class=\"form_error\">#{err}</div>"
    end
  end

  def flash_form_messages(attr)
    attr = (attr.to_s + "_error").to_sym
    if flash[attr]
      raw "<div class=\"form_error\">#{flash[attr]} </div>"
    end
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    sort_param = params[:sort].nil? ? []:params[:sort]
    css_class = sort_param.include?(column) ? "current #{sort_param[column]}" : nil
    direction = sort_param.include?(column) && sort_param[column] == "asc" ? "desc" : "asc"
#    current_params.include?(:page) && current_params[:page].to_i > 1 ? current_params[:page] = 1 : ''
    link = link_to title, params.merge(:sort => { column => direction},:page=>nil), {:class => (css_class ? css_class:'')}
    raw "<span class=\"sortable\" > #{link} </span>"
  end

  def attaches_form
    @attach =  Attach.new
    render 'attaches/form'
  end

  def attaches_lib(thr=nil)
    if thr && current_user
      @attaches = Attach.where(:user_id=>current_user.id).
        where({:status=> Attach::STATUS_NOTASSIGN}).
        order("created_at desc")
    elsif current_user
      @attaches = Attach.where(:user_id=>current_user.id,:status=> Attach::STATUS_NOTASSIGN).order("created_at desc")
    else
      @attaches = []
    end
    render 'attaches/lib'
  end

end