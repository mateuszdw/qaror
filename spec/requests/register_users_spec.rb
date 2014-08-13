require 'rails_helper'

describe "RegisterUser", :type => :feature do
  it "email user when register" do
    user = FactoryGirl.build(:user)
    visit register_path
    fill_in "user_name", :with => user.name
    fill_in "user_email", :with => user.email
    fill_in "user_password", :with => user.password
    fill_in "user_password_confirmation", :with => user.password
    click_button "Sign in"
    expect(page).to have_content 'new account'
    expect(last_email).to have_content(user.email)
  end
end
