require 'omniauth-openid'
require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :facebook, '', ''
  # provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp')
end