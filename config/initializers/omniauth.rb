require 'omniauth-openid'
require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
  #,{:client_options => {:ssl => {:ca_path => "/usr/lib/ssl"}}}
  # {:client_options => {:ssl => {:ca_file => "/usr/lib/ssl/certs/ca-certificates.crt"}}}
  #  provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp')
  provider :facebook, 'API KEY', 'API SECRET'
end