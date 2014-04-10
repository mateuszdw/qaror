module PaperTrail
  class Version < ActiveRecord::Base
    attr_accessible :summary ,:user_id
    belongs_to :user
  end
end 