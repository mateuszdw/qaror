require 'rails_helper'

describe "ForgotPassword", :type => :feature do
  it "email user when click remind password" do
    user = FactoryGirl.create(:user)
    visit login_path
    click_link "password"
    fill_in "user_email", :with => user.email
    click_button "Send email"
    expect(page).to have_content 'sent to '
    expect(last_email).to have_content(user.email)
  end
end
