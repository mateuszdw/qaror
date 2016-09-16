# encoding: utf-8
class User < ActiveRecord::Base

  delegate :can?, :cannot?, :to => :ability

  STATUS_ANONYMOUS = 0
  STATUS_NOTCONFIRMED = 1
  STATUS_ACTIVE = 2
  STATUS_BLOCKED = 9 # suspended

  ROLE_NONE = 0
  ROLE_USER = 1
  ROLE_MODERATOR = 2
  ROLE_ADMIN= 3

  before_create {
    self.last_login = Time.now
    self.apikey = SecureRandom.hex(12)
  }

  serialize :ranks, Hash

  has_many :authentications,:dependent => :destroy
  has_many :ans
  has_many :attaches
  has_many :thrs
  has_many :activities # never destroy user activities
  has_many :activity_points # never destroy user activities
  has_many :achievements
  has_many :badges, :through=> :achievements
  has_many :comments
  has_many :tags
  has_many :subscriptions, :dependent => :destroy
  has_one :user_setting, :dependent => :destroy
  has_many :contact_us

  apply_simple_captcha

  attr_accessor :updating_password, :accessible

  attr_accessible :name, :email,:password,:first_name,:last_name,:www,:about,:gender,:birth,:timezone,:language

  validates :name,
            :presence => true,
            :length => {:within => 5..100},
            :uniqueness => { :case_sensitive => false },
            :format => {:with => /^[0-9a-zA-Z ]+$/i, :message => "#{I18n.t("errors.messages.invalid")}. #{I18n.t(:alphanumeric_and_spaces_required)}"}

  validates :email,
            :presence => true,
            :uniqueness => { :case_sensitive => false },
            :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }

  validates :password,
            :length => {:within => 5..30},
            :presence => true,
            :confirmation => true,
            :if => :should_validate_password?

  validates :www,
            :allow_blank => true,
            :format => {:with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix, :message => "#{I18n.t("errors.messages.invalid")}. #{I18n.t(:full_url_required)}" }

  before_save :do_password,:if => :should_validate_password?
  before_save :email_downcase
#  before_save :assign_first_last_name
  before_update :check_email_changed
  after_create :set_user_settings

  scope :active, where(:status => [STATUS_NOTCONFIRMED,STATUS_ACTIVE])
  scope :sortable, lambda { |sort=nil|
    case sort
    when "reputation" then order("reputation DESC")
    when "newest" then order("created_at DESC")
    else
      order("reputation DESC")
    end
  }

  def self.valid_attribute?(attr, value)
    m = self.new(attr => value)
    unless m.valid?
      return m.errors.has_key?(attr) ? false : true
    end
    false
  end

  def self.generate_name_if_short_or_used(name)
    # if !name.nil? && name > 5 && name not empty && not used
    self.valid_attribute?(:name,name) ? name : 'kowalski-' + SecureRandom.hex(4).to_s
  end

  def sname
    return name + '&diams;&diams;' if is_admin?
    return name + '&diams;' if is_moderator?
    return name
  end

  def reputation_points
    self.activity_points.not_zero.includes(:activity).not_undo.
    # COMMENTED 12.05.2014 where{(activities.name.like "%vote%") | (activities.name == "resolved")}.
    order("activity_points.created_at desc")
  end

  def votes_points
    self.activity_points.not_zero.includes(:activity).not_undo.
      where{(activities.name.like "%vote%")}.
      order("activity_points.created_at desc")
  end

  # favorites
  def favs
    activities.favs
  end

  def votes
    activities.votes
  end

  def votes_up
    activities.votes_up
  end

  def votes_down
    activities.votes_down
  end

  def is?(role)
    current_role = case role
                    when ROLE_USER then :user
                    when ROLE_MODERATOR then :moderator
                    when ROLE_ADMIN then :admin
                  end
    return (role == current_role) ? true : false
  end

  def is_registered?
    role > ROLE_NONE ? true : false
  end

  def is_moderator?
    role == ROLE_MODERATOR ? true : false
  end

  def is_admin?
    role == ROLE_ADMIN ? true : false
  end

  def not_confirmed?
    status == STATUS_NOTCONFIRMED ? true : false
  end

  def active?
    (status == STATUS_NOTCONFIRMED || status == STATUS_ACTIVE) ? true : false
  end

  def do_password
    salt = Digest::SHA1.hexdigest("--#{Time.now.to_f}-$-$-#{self.email}--%*$!#;\.k~'(_@")
    self.password_salt = salt
    self.password = User.hash_password(self.password,salt) if self.password
  end

  def self.authenticate(email,password)
    user = self.where(:email => email).active.first
    return false unless user
    return user if user.password == self.hash_password(password,user.password_salt)
    return false
  end

  def self.hash_password(pass,salt)
    Digest::SHA384.hexdigest("#{pass}:$:#{salt}")
  end

  def achievements_grouped
    self.badges.group("badges.badge_type").count(:id)
  end

  def update_reputation
    self.reputation = self.activity_points.not_undo.sum(:value)
    self.save
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def gravatar_url
    APP_CONFIG['gravatar_url'] + Digest::MD5.hexdigest(email) + "?d=identicon&s=128"
  end

  def avatar
    avatar_url.blank? ? gravatar_url : avatar_url
  end

  # overwrite method save_with_captcha of galetahub/simple-captcha gem
  # for test purpose
  def save_with_captcha
    if Rails.env.test?
      save
    else
      valid_with_captcha? && save(:validate => false)
    end
  end

  def generate_remind_token
    begin

    end
  end

private

  def check_email_changed
    if email_changed?
      self.status = STATUS_NOTCONFIRMED
    end
  end

  def assign_first_last_name
    n = self.name.split(' ')
    self.first_name = n.first
    self.last_name = n.last
  end

  def email_downcase
    self.email = self.email.downcase
  end

  def set_user_settings
    create_user_setting
  end

  def should_validate_password?
    updating_password || new_record?
  end

  def mass_assignment_authorizer(role = :default)
    if accessible == :all
      self.class.protected_attributes
    else
      super + (accessible || [])
    end
  end

end
