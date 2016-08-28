module AuthSupport

  def login(user)
    visit login_path
    fill_in "login_email", :with => user.email
    fill_in "login_password", :with => FactoryGirl.build(:user).password
    click_button I18n.t(:login)
  end

end
