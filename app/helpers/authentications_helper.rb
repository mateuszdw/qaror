module AuthenticationsHelper

  def provider_url(hash)
    return case hash
      when :google then root_url + 'auth/open_id?openid_url=https://www.google.com/accounts/o8/id'
      when :yahoo then root_url + 'auth/open_id?openid_url=yahoo.com'
      when :myopenid then root_url + 'auth/open_id?openid_url=http://myopenid.com/'
      when :facebook then root_url + 'auth/facebook'
      when :wp then root_url + 'auth/open_id?openid_url=http://openid.wp.pl'
    end
  end

end
