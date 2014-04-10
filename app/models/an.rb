# encoding: utf-8

class An < ActiveRecord::Base
  has_paper_trail :only => [:content], :on=> [:update],
  :meta => {
    :user_id  => Proc.new { |m| m.updated_by.id },
    :summary  => Proc.new { |m| m.vsummary if m.changed? && !m.vsummary.blank? }
  }

  include Extender::Voteable

  before_create { self.activity_at = Time.now }

  STATUS_INACTIVE = 0
  STATUS_ACTIVE = 1
  STATUS_HIDDEN = 8
  STATUS_DELETED = 9

  UNRESOLVED = 0
  RESOLVED = 1

  has_many :comments, :as => :commentable ,:dependent => :destroy
  has_many :activities,:as => :activityable # never destroy user activities
  accepts_nested_attributes_for :activities

  belongs_to :thr
  belongs_to :user

  apply_simple_captcha

  attr_accessor :vsummary, :updated_by
  attr_accessible :content

  validates :content,
            :length => {:within => 20..3000},
            :presence => true

  after_save :set_version_summary
  after_create :set_subscription

  scope :active, where(:status => STATUS_ACTIVE)
  scope :hidden_or_deleted, where(:status => [STATUS_HIDDEN,STATUS_DELETED])
  scope :sortable, lambda { |sort=nil|
    case sort
    when "oldest" then order("created_at ASC")
    when "votes" then order("(vote_up + vote_down) DESC")
    else
      order("activity_at DESC")
    end
  }

  def resolve
    if self.thr.resolved?
      errors.add(:base,:resolved)
      return false
    end
    self.resolved = RESOLVED
    saved = self.save
    thr.reload
    return saved
  end

  def unresolve
    unless self.can_unresolve?
      errors.add(:base,:unresolved)
      return false
    end
    self.resolved = UNRESOLVED
    saved = self.save
    thr.reload
    return saved
  end

  def can_unresolve?
    self.resolved == RESOLVED && thr.resolved?
  end

  def resolved?
    self.resolved == RESOLVED
  end

  def stitle
    status_string + content
  end

  def status_string
    case self[:status]
#    when STATUS_ACTIVE then '[active] '
    when STATUS_HIDDEN then '[hidden] '
    when STATUS_DELETED then '[deleted] '
    else ''
    end
  end

  def mark_as_destroy
    self.status = STATUS_DELETED
    self.save(:validate => false)
  end

  def mark_as_hidden_if_needed
    if self.activities.flagged.count >= APP_VOTING_CONFIG['flags_to_hide_post']
      self.status = STATUS_HIDDEN
      self.save
    else
      self.save
    end
  end

protected

private

  def set_subscription
    self.thr.subscriptions.find_or_create_by_user_id(user_id)
  end

  def set_version_summary
    versions.last.update_attributes(:summary => vsummary) if self.changed? && !vsummary.blank?
  end

end
