# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_id = 'admin_posts_sort'
    primary.dom_class = 'sort'
    primary.item :thrs, 'questions', thrs_admin_main_index_url
    primary.item :ans, 'answers', ans_admin_main_index_url
    primary.item :comments, 'comments', comments_admin_main_index_url
  end
end