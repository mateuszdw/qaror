class Subscription < ActiveRecord::Base

  STATUS_INACTIVE = 0
  STATUS_ACTIVE = 1

  before_create { self.last_view = Time.now }

  belongs_to :subscribable, :polymorphic => true
  belongs_to :subscribable_thr, :foreign_key => :subscribable_id, :class_name => "Thr"
  belongs_to :user

  attr_protected # accessible all atrrs

  # notify users when they enable notifications
  def self.notify_answers

#    Mailer.registration_confirmation(@user).deliver
  end

  def self.notify_answer_resolved

  end

  def self.notify_comments

  end

end
