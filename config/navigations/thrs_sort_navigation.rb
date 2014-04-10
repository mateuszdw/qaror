# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_id = 'thrs_sort'
    primary.dom_class = 'sort'

    primary.item :thrs_active, t('sort.thrs.active'),root_url, :highlights_on=> /(^\/questions$)|(\/$)/,
      :title=>t('sort.thrs.active_title')
    primary.item :thrs_newest, t('sort.thrs.newest'),thrs_sort_url(:sort=>"created_at"), :title=>t('sort.thrs.newest_title')
    primary.item :thrs_hot, t('sort.thrs.hot'),thrs_sort_url(:sort=>"hot"), :title=> t('sort.thrs.hot_title')
  end
end