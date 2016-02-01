source 'https://rubygems.org'

ruby '2.1.1'
gem 'rails', '3.2.22'

gem 'thin'
gem 'pg'
gem 'squeel'
gem 'memcachier'
gem 'dalli'

group :development do
  gem 'execjs'
  gem 'therubyracer'
end

group :production do
  gem 'rails_12factor' # Added to avoid warnings on heroku
  gem 'newrelic_rpm'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

#libs
gem "rmagick", :require => "rmagick"
gem 'jquery-rails'

gem 'simple-navigation'
gem 'galetahub-simple_captcha','0.1.3', :require => 'simple_captcha'
gem "cancan",'1.6.8'
gem 'json_builder'
gem 'httpclient'
gem "friendly_id", "~> 4.0.1"
gem 'will_paginate', '~> 3.0'

gem "omniauth-openid"
gem "omniauth-facebook"

## delayed jobs
#gem "delayed_job_active_record"
#gem "workless", "~> 1.1.3"

#versioning
gem 'paper_trail', '~> 3.0.1'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
