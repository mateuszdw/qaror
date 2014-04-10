# encoding: utf-8

class Thr < ActiveRecord::Base
  extend FriendlyId

  has_paper_trail :only => [:title,:content,:tagnames], :on=> [:update],
  :meta => {
    :user_id  => Proc.new { |m| m.updated_by.id },
    :summary  => Proc.new { |m| m.vsummary if m.changed? && !m.vsummary.blank? }
  }
  
  include Extender::Voteable
  include Extender::Impressionable
  include Extender::Taggable

  before_create { self.activity_at = Time.now }

  MAX_ATTACHES = 4

  STATUS_NEW = 0
  STATUS_ACTIVE = 1
  STATUS_CLOSED = 3
  STATUS_HIDDEN = 8
  STATUS_DELETED = 9

  friendly_id :title, use: :slugged

  has_many :ans,:dependent => :destroy
  has_many :attaches,:as => :attachable, :dependent => :destroy
  has_many :comments,:as => :commentable, :dependent => :destroy
  has_many :activities, :as => :activityable# never destroy user activities
  accepts_nested_attributes_for :activities

  has_many :subscriptions,:as => :subscribable, :dependent => :destroy

  belongs_to :user

  apply_simple_captcha

  attr_accessor :accessible,:add_attaches,:vsummary,:updated_by
  attr_accessible :title, :content, :tagnames

  validates :title,
            :presence => true,
            :length => {:within => 10..100},
            :uniqueness => { :case_sensitive => false }

  validates :content,
            :presence => true,
            :length => {:within => 20..3000}

  after_create :set_subscription


  scope :active, where(:status => STATUS_ACTIVE)
  scope :closed, where(:status => STATUS_CLOSED)
  scope :active_or_closed, where(:status => [STATUS_ACTIVE,STATUS_CLOSED])
  scope :deleted, where(:status => STATUS_DELETED)
  scope :hidden_or_deleted, where(:status => [STATUS_HIDDEN,STATUS_DELETED])
#  scope :users_favorit, where(:status => STATUS_DELETED)
  scope :releated, lambda { |thr|
      select("thrs.id,thrs.title,thrs.slug").joins(:tags).
      where({:tags=>{:name.matches_any=> thr.tags.map(&:name)}}).
      where({:thrs=>{:id.not_eq=>thr.id}}).
      group("thrs.id,thrs.title").limit(20)
  }

  scope :sortable, lambda { |sort=nil|
    case sort
    when "newest" then order("created_at DESC")
    when "hot" then order("hotness DESC")
    else
      order("activity_at DESC")
    end
  }

  def users_fav
    activities.favs
  end

  def stitle
    status_string + title
  end

  def status_string
    case self[:status]
#    when STATUS_ACTIVE then '[active] '
    when STATUS_CLOSED then '[closed] '
    when STATUS_HIDDEN then '[hidden] '
    when STATUS_DELETED then '[deleted] '
    else ''
    end
  end

  def closed?
    status == STATUS_CLOSED
  end

  def mark_as_destroyed?
    status == STATUS_DELETED
  end

  def resolved?
    ans.map(&:resolved).include? An::RESOLVED
  end

  def last_activity_user
    User.find_by_id(last_activity_user_id)
  end

  def last_activity
    Activity.find_by_id(last_activity_id)
  end

  def subscribed?(user_id)
    subscriptions.where(:user_id=>user_id).first
  end

  def subscribe(user_id)
    if sub = subscribed?(user_id)
      sub.destroy
      sub = nil
    else
      sub = subscriptions.create(:user_id=>user_id)
    end
  end

  def mark_as_closed
    self.status = STATUS_CLOSED
    self.save
  end

  def mark_as_hidden_if_needed
    if self.activities.flagged.count >= APP_VOTING_CONFIG['flags_to_hide_post']
      self.status = STATUS_HIDDEN
      self.save
    else
      self.save
    end
  end

  def mark_as_destroy
    self.status = STATUS_DELETED
    self.save(:validate => false)
  end

  def vsummary
    version.summary if !live?
  end

private

  def set_subscription
    self.subscriptions.find_or_create_by_user_id(user_id)
  end

#
# => W RAZIE GDY BY POTRZEBA ZALACZNIKOW BEZPOSREDNIO W THR
#
#  def check_add_attaches
#    if @add_attaches.respond_to?('each')
#      errors.add(:attach,"za duzo obrazkow maksymalnie " + MAX_ATTACHES.to_s) if @add_attaches.count > MAX_ATTACHES
#    end
#  end
#  def set_attaches
#    if @add_attaches
#        Array(@add_attaches).map do |a|
#          if attach = Attach.where(:user_id=>user_id).find(a)
#            attach.thr_id = self.id
#            attach.status = Attach::STATUS_ASSIGN
#            attach.save
#          end
#        end
#    end
#  end

  def mass_assignment_authorizer
    if accessible == :all
      self.class.protected_attributes
    else
      super + (accessible || [])
    end
  end

end
