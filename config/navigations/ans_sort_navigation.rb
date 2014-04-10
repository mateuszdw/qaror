# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_id = 'ans_sort'
    primary.dom_class = 'sort'
    primary.item :ans_active, t('sort.ans.active'),thr_url(@thr),
      :highlights_on=> /^\/questions\/([^\/.]+)$/, :title=> t('sort.ans.active_title')
    primary.item :ans_oldest, t('sort.ans.oldest'),ans_sort_url(:id=>@thr.id,:sort=>"oldest"), :title=> t('sort.ans.oldest_title')
    primary.item :ans_votes, t('sort.ans.votes'),ans_sort_url(:id=>@thr.id,:sort=>"votes"), :title=> t('sort.ans.votes_title')
  end
end