require 'rails_helper'

feature "User" do

  background do
    @user = FactoryGirl.create(:user)
  end

  scenario "receive email when register" do
    user = FactoryGirl.build(:user)
    visit register_path
    fill_in "user_name", :with => user.name
    fill_in "user_email", :with => user.email
    fill_in "user_password", :with => user.password
    fill_in "user_password_confirmation", :with => user.password
    click_button I18n.t("users.new")
    expect(page).to have_content 'new account'
    expect(last_email).to have_content(user.email)
  end

  scenario "do standard login" do
    login(@user)
    expect(page).to have_content 'Profile'
  end

  scenario 'blank login and password' do
    visit login_path
    fill_in "login_email", :with => ''
    fill_in "login_password", :with => ''
    click_button I18n.t(:login)
    expect(page).to have_content I18n.t(:all_fields_required)
  end

  scenario 'wrong password' do
    visit login_path
    fill_in "login_email", :with => @user.email
    fill_in "login_password", :with => 'wrong'
    click_button I18n.t(:login)
    expect(page).to have_content I18n.t(:login_error)
  end

  scenario 'remind password' do
    visit remind_password_path
    fill_in "user_email", :with => @user.email
    click_button I18n.t("users.send_to_email")
    expect(last_email).to have_content(@user.email)
  end

end
