# this constant is assign in application.rb
# APP_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]

# load reputation
APP_REPUTATION = YAML.load_file("#{Rails.root.to_s}/config/reputation.yml")

# load privileges
APP_PRIVILEGES = YAML.load_file("#{Rails.root.to_s}/config/privileges.yml")

# load badges config
APP_BADGES_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/badges_config.yml")

# load voting config
APP_VOTING_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/voting_config.yml")
