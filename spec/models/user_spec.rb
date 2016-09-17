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

  it 'has not confirmed account' do
    expect(FactoryGirl.create(:user_not_confirmed).status).to eq User::STATUS_NOTCONFIRMED
  end

  it 'has an active account' do
    expect(FactoryGirl.create(:user).status).to eq User::STATUS_ACTIVE
  end

  describe 'scopes' do

    let(:user_reputation_0) { FactoryGirl.create(:user, reputation: 0) }
    let(:user_reputation_1) { FactoryGirl.create(:user, reputation: 1) }

    it 'is active' do
      active_user = FactoryGirl.create(:user)
      active_not_confirmed_user = FactoryGirl.create(:user_not_confirmed)
      expect(User.active).to eq [active_user, active_not_confirmed_user]
    end

    it 'sortable by default' do
      expect(User.sortable).to eq([user_reputation_1, user_reputation_0])
    end

    it 'sortable by reputation' do
      expect(User.sortable("reputation")).to eq([user_reputation_1, user_reputation_0])
    end

    it 'sortable by newest' do
      user_created_first = FactoryGirl.create(:user)
      user_created_last = FactoryGirl.create(:user)
      expect(User.sortable("newest")).to eq([user_created_last, user_created_first])
    end
  end

  describe 'instance' do

    context '#reputation_points' do

      let(:user_with_two_activity_points) { FactoryGirl.create(:user_with_two_activity_points) }
      let(:user_with_10_reputation) { FactoryGirl.create(:user_with_points) }
      let(:user_with_no_reputation) { FactoryGirl.create(:user_with_zero_points) }
      let(:user_with_undo_points) { FactoryGirl.create(:user_with_undo_points) }

      it 'return object with 10 points' do
        expect( user_with_10_reputation.activity_points ).to eq( user_with_10_reputation.reputation_points )
      end

      it 'not return object with 0 points' do
        expect( user_with_no_reputation.activity_points ).to_not eq( user_with_no_reputation.reputation_points )
      end

      it 'not return object with undo points' do
        expect( user_with_undo_points.activity_points ).to_not eq( user_with_undo_points.reputation_points )
      end

      it 'return ordered by latest' do
        expect(user_with_two_activity_points.activity_points.reverse ).to eq( user_with_two_activity_points.reputation_points )
      end

    end
  end

end
