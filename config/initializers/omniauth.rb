require 'omniauth-openid'
require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
  #provider :facebook, '247367931976798', 'eec701eff9a8b8db2a6ec6a5911843de'
  ##,{:client_options => {:ssl => {:ca_path => "/usr/lib/ssl"}}}
  # {:client_options => {:ssl => {:ca_file => "/usr/lib/ssl/certs/ca-certificates.crt"}}}
  #  provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp')
end