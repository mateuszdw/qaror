module PagesHelper

  def wiki_vars
    reputation = APP_REPUTATION
    mod_abilities = reputation['ability'].inject({}) {|h,(k,v)| h["#{k}_desc"] = v["desc"]; h["#{k}_value"] = v["value"] ;h }
#    reputation['ability'] = nil
    mod_abilities.merge(reputation)
  end

end
