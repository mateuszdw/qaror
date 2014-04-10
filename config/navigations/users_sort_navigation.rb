# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_id = 'users_sort'
    primary.dom_class = 'sort'
    primary.item :users_reputation, t("sort.users.reputation"),users_url, :title=>t("sort.users.reputation_title"), :highlights_on=>/^\/users$/
    primary.item :users_newest, t('sort.users.newest'),users_url(:sort=>"newest"), :title=>t("sort.users.newest_title")
  end
end