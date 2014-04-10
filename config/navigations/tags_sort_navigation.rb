# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_id = 'tags_sort'
    primary.dom_class = 'sort'
    primary.item :tags_popular, t('sort.tags.popular'),tags_url, :highlights_on=>/^\/tags$/, :title=>t('sort.tags.popular_title')
    primary.item :tags_byname, t('sort.tags.byname'),tags_sort_url(:sort=>"name"), :title=>t('sort.tags.byname_title')
    primary.item :tags_newest, t('sort.tags.newest'),tags_sort_url(:sort=>"newest"), :title=>t('sort.tags.newest_title')
  end
end