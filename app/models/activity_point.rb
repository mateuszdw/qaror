class ActivityPoint < ActiveRecord::Base

  NOT_UNDO = 0
  UNDO = 1

  belongs_to :user
  belongs_to :activity

  attr_accessor :reduce_points_if_needed
  
  attr_protected # accessible all atrrs

  validate :check_reputation, :if => :reduce_points_activity?

  after_save :update_reputation_for_activity
  
  scope :not_zero, where("value > 0")
  scope :not_undo, where(:undo=> NOT_UNDO)
  scope :created_today, where("CAST(created_at + interval '? seconds' AS date) = CAST(? AS date)", Time.zone.utc_offset, Time.now)
  
private

  def reduce_points_activity?
    return false if reduce_points_if_needed
    (!self.value.nil? && self.value < 0)
  end

  # sprawdzenie usera generujacego i otrzymujacego punkty
  def check_reputation
    if (self.user.reputation + self.value) < 0
      errors.add(:base,'masz za malo punktow by wykonac te akcje')
    end
  end

  def update_reputation_for_activity
    self.user.update_reputation
  end


end
