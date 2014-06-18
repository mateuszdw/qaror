module PagesHelper

  def wiki_vars
    reputation = APP_PRIVILEGES
    mod_abilities = reputation.inject({}) {|h,(k,v)| h["#{k}_desc"] = v["desc"]; h["#{k}_value"] = v["value"] ;h }
    mod_abilities.merge(reputation)
  end

end
