require "rails_helper"

describe Mailer do
  describe "password_reset" do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { Mailer.remind_password(user) }

    it "sends user password reset url" do
      expect(mail.subject).to include("change password")
      expect(mail.to).to eq([user.email])
    end

    it "renders the body" do
      expect(mail.body).to have_content(change_password_users_url(:hash=>user.remind_token))
    end
  end

  describe "registration_confirmation" do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { Mailer.registration_confirmation(user) }

    it "sends email with valid description" do
      expect(mail.subject).to include("confirm your e-mail")
      expect(mail.to).to eq([user.email])
    end

    it "renders the body with activation url" do
      expect(mail.body.encoded).to have_content(activate_users_url(:hash=>user.activation_hash))
    end
  end
end