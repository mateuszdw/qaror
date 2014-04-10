# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_id = 'admin_activities_sort'
    primary.dom_class = 'sort'
    primary.item :activities, 'all', admin_activities_url
    primary.item :reported, 'reported and closed', reported_admin_activities_url
  end
end