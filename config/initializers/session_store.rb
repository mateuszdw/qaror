# Be sure to restart your server when you modify this file.

config_hash = { key: '_sugestie_session', expire_after: 60*60*24*7}
#config_hash.merge!({domain: :all}) if Rails.env.include? "production"

Qaror::Application.config.session_store :cookie_store, config_hash

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Qaror::Application.config.session_store :active_record_store
