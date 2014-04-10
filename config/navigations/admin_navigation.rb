# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_id = 'menu'
    primary.item :activities, 'Activities', admin_activities_url
    primary.item :posts, 'Posts', thrs_admin_main_index_url
    primary.item :pages, 'Pages', admin_pages_url
    primary.item :badges, 'Badges', admin_badges_url
    primary.item :users, 'Users', admin_users_url
    primary.item :contact_us, 'Contact', admin_contact_us_url
    primary.item :logout,'Logout', logout_url
  end
end
