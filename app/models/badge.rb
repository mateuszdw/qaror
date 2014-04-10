class Badge < ActiveRecord::Base

  GOLD =   1
  SILVER = 2
  BRONZE = 3

  has_many :achievements
  has_many :activities, :through=> :achievements
  
  belongs_to :user

  attr_accessible :name, :badge_type

  validates :name,
            :presence => true,
            :uniqueness => { :case_sensitive => false }

  def name_humanized
    I18n.t("badges.#{name}.name")
  end

  def self.type_humanized(type)
    case type
    when GOLD then "gold"
    when SILVER then "silver"
    when BRONZE then "bronze"
    end
  end

  def type_humanized
    Badge.type_humanized(self.badge_type)
  end

end