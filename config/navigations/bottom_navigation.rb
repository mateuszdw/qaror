# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_id = 'bottom_menu'
    primary.dom_class = 'sort'
    primary.item :tags, t("activerecord.models.tags"), tags_url
    primary.item :users, t("activerecord.models.users"), users_url
    primary.item :achievements, t("activerecord.models.achievements"), achievements_url
    primary.item :privileges, "Privileges", privileges_url
    
#    primary.item :terms, (t :terms), terms_url
#    primary.item :faq, (t :faq), faq_url
#    primary.item :contact_us, (t "activerecord.models.contact_us"), contact_us_url
  end
end