# encoding: utf-8
class Tag < ActiveRecord::Base
  extend FriendlyId

  STATUS_INACTIVE = 0
  STATUS_ACTIVE = 1
  MIN_TAGS = 3
  MAX_TAGS = 5
  SPECIAL_TAGS = %w{sugestia błąd pytanie}


  has_many :tag_rels, :dependent => :destroy
  has_many :thrs, :through=> :tag_rels, :source => :taggable, :source_type => 'Thr'
  
  has_many :achievements
  has_many :activities, :through=> :achievements
  belongs_to :user

  friendly_id :name, use: :slugged

  validates :name,
            :presence => true,
            :length => {:within => 3..40},
            :uniqueness => { :case_sensitive => false }


  validate :check_reputation

  scope :active, where(:status => STATUS_ACTIVE)
  scope :sortable, lambda { |sort|
    case sort
    when "name" then order("name ASC")
    when "newest" then order("created_at DESC")
    else
      order("quantity DESC")
    end
  }

  def self.special?(name)
    SPECIAL_TAGS.include?(name) ? "spc_" + name.gsub(/[^A-Za-z]/, '') : nil
  end

  def self.special_tags
    SPECIAL_TAGS.map {|t| "spc_" + t.gsub(/[^A-Za-z]/, '') }
  end

  def check_reputation
#    narazie wszyscy moga dodawac tagi
#    unless self.user.is_moderator? || self.user.is_admin? || self.user.reputation > 1500
#      errors.add(:name,"jeszcze nie istnieje. Masz za mało reputacji by dodawać nowe tagi. ")
#    end
  end

  def refresh_counter
    self.update_attributes(:quantity=>self.tag_rels.count)
  end

end
