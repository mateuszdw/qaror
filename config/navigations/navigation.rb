# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_id = 'menu'
    primary.item :thrs, t("activerecord.models.thrs"), thrs_url
    primary.item :tags, t("activerecord.models.tags"), tags_url
    primary.item :users, t("activerecord.models.users"), users_url
    primary.item :achievements, t("activerecord.models.achievements"), achievements_url
  end
end