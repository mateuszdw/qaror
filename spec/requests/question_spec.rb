require 'rails_helper'

# feature "Anonymous question" do
#
#   background do
#     @question = FactoryGirl.build(:question)
#   end
#
# end

feature 'Question' do


  background do
    @user = FactoryGirl.create(:user)
    @question = FactoryGirl.build(:question)
  end

  scenario "can be ask by anonymous" do
    new_question(@question)
    expect(page).to have_content I18n.t(:question_stored)
  end

  scenario 'can be created by user' do
    login(@user)
    new_question(@question)
    expect(page).to have_content I18n.t('thrs.create.saved')
  end

  # scenario 'can be edit by owner' do
  #   user = FactoryGirl.create(:user, :registered, :with_reputation)
  #   login(user)
  #   new_question = FactoryGirl.create(:question_with_activity)
  #   visit edit_thr_path(new_question)
  #   #
  #   # fill_in 'thr[title]', with: new_question.title
  #   # fill_in :thr_content, with: new_question.content
  #   # fill_in 'thr[tagnames]', with: new_question.tagnames + " tag4"
  #   # click_button I18n.t(:send)
  #
  #   expect(page).to have_content I18n.t('thrs.update.saved')
  # end

end
