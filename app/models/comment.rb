# encoding: utf-8

class Comment < ActiveRecord::Base
  include Extender::Voteable
  before_create { self.activity_at = Time.now }

  STATUS_NEW = 0
  STATUS_ACTIVE = 1
  STATUS_DELETED = 9

  has_many :activities, :as => :activityable
  accepts_nested_attributes_for :activities
  
  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  attr_accessible :content

  validates :content,
            :presence => true,
            :length => {:within => 10..500}

  scope :active, where(:status => STATUS_ACTIVE)
  scope :deleted, where(:status => STATUS_DELETED)
  scope :sortable, lambda { |sort=nil|
    case sort
    when "oldest" then order("created_at ASC")
    when "votes" then order("(vote_up + vote_down) DESC")
    else
      order("activity_at ASC")
    end
  }
  
  def stitle
    status_string + content
  end

  def status_string
    case self[:status]
#    when STATUS_ACTIVE then '[active] '
    when STATUS_DELETED then '[usunięta] '
    else ''
    end
  end

  def mark_as_destroy
    self.status = STATUS_DELETED
    self.save(:validate => false)
  end
  
protected


end
