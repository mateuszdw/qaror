require 'rails_helper'

describe User do


  it 'has a valid factory' do
    expect(FactoryGirl.create(:user)).to be_valid
  end

  it 'is invalid without email' do
    expect( FactoryGirl.build(:user, email: nil) ).to_not be_valid
  end

  it 'is invalid without name' do
    expect( FactoryGirl.build(:user, name: nil) ).to_not be_valid
  end

  it 'has an active account' do
    expect(FactoryGirl.create(:user).status).to eq User::STATUS_ACTIVE
  end

  context 'scopes' do
    it 'is active' do
      active_user = FactoryGirl.create(:user)
      active_not_confirmed_user = FactoryGirl.create(:user, :not_confirmed)
      expect(User.active).to eq [active_user, active_not_confirmed_user]
    end

    it 'sortable by default' do
      user_reputation_0 = FactoryGirl.create(:user, reputation: 0)
      user_reputation_1 = FactoryGirl.create(:user, reputation: 1)
      expect(User.sortable).to eq([user_reputation_1, user_reputation_0])
    end

    it 'sortable by reputation' do
      user_reputation_0 = FactoryGirl.create(:user, reputation: 0)
      user_reputation_1 = FactoryGirl.create(:user, reputation: 1)
      expect(User.sortable("reputation")).to eq([user_reputation_1, user_reputation_0])
    end

    it 'sortable by newest' do
      user_created_first = FactoryGirl.create(:user, created_at: Time.now)
      user_created_last = FactoryGirl.create(:user, created_at: Time.now)

      expect(User.sortable("newest")).to eq([user_created_last, user_created_first])
    end
  end

end
