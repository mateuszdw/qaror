# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_id = 'tag_sort'
    primary.dom_class = 'sort'

    primary.item :tag_activty, t('sort.tag.activity'),tag_url(params[:id]),
      :highlights_on=> /^(\/tags\/([^\/.]+))$/, :title=> t('sort.tag.activity_title')
    primary.item :tag_newest, t('sort.tag.newest'),tag_sort_url(:sort=>"newest"), :title=> t('sort.tag.newest_title')
    primary.item :tag_hot, t('sort.tag.hot'),tag_sort_url(:sort=>"hot"),:class=> :last, :title=> t('sort.tag.hot_title')
  end
end