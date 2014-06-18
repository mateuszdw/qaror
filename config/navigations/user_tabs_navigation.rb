# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  navigation.items do |primary|
    primary.dom_id = 'user_tabs'
    primary.dom_class = 'sort'
    primary.item :user_tabs_info, t("sort.user_tabs.info"),user_url(@user), :title=> t("sort.user_tabs.info_title")
    primary.item :user_tabs_favorites, t("sort.user_tabs.favorites"),favorites_user_url(@user),:title=> t("sort.user_tabs.favorites_title")
    primary.item :user_tabs_reputation, t("sort.user_tabs.reputation"),reputation_user_url(@user), :title=> t("sort.user_tabs.reputation_title")
    primary.item :user_tabs_activity, t("sort.user_tabs.activity"),activity_user_url(@user), :title=> t("sort.user_tabs.activity_title")
    primary.item :user_tabs_votes, t("sort.user_tabs.votes"),votes_user_url(@user), :title=> t("sort.user_tabs.votes_title") if can?(:votes, :user)
  end
end
