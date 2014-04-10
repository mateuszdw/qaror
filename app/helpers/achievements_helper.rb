module AchievementsHelper

  def achievement_schema(*args)
    if args[0].class.name.constantize < ActiveRecord::Base
      object = args[0]
      tname = object.name_humanized
      name = object.name
      count = object.achieved_count unless args[1] && args[1][:count] == false
      html_options = {:class=> object.type_humanized}
    else
      tname = args[0]
      name =  args[0]
      count =  args[1]
      html_options = args[2]
    end

    html = "<div class=\"achievement\">
          <span class=\"bg\">
            #{link_to tname, achievement_url(name), html_options }
          </span>"
    html << "<span> x #{count}</span>" if count
    html << "</div>"
    raw html
  end

end
