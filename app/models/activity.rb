class Activity < ActiveRecord::Base
  include Extender::Achievements

  NOT_UNDO = 0
  UNDO = 1

  has_many :activity_points
  accepts_nested_attributes_for :activity_points
  belongs_to :activityable, :polymorphic => true
  belongs_to :activityable_thr, :foreign_key => :activityable_id, :class_name => "Thr"
  belongs_to :user
  belongs_to :badge
  belongs_to :tag

  attr_protected # accessible all atrrs

  scope :activityable_object, lambda {|o| where(:activityable_id=>o.id,:activityable_type=>o.class.to_s) }
  scope :not_undo, where(:undo=> NOT_UNDO)
  scope :flagged, where(:name=> 'flag')
  scope :close_reported, where(:name=> 'close')
  scope :flagged_or_close, where(:name => ['close','flag'])

  scope :favs, where(:name => "fav",:undo=> NOT_UNDO)
  scope :votes, where("name LIKE ? AND undo=?","%vote%",NOT_UNDO)
  scope :votes_for_thrs_and_ans, where(:name => ["vote_up","vote_down"],:activityable_type => ['An','Thr'],:undo=> NOT_UNDO)
  scope :votes_up, where("name LIKE ? AND undo=?","%vote_up%",NOT_UNDO)
  scope :votes_down, where("name LIKE ? AND undo=?","%vote_down%",NOT_UNDO)
  scope :answers, where(:name=>'create',:undo=> NOT_UNDO,:activityable_type=>'An')
  scope :public_activities, where("name NOT IN (?) AND undo=?",['day_activity','update_user'],NOT_UNDO)
  scope :created_today, where("CAST(created_at + interval '? seconds' AS date) = CAST(? AS date)", Time.zone.utc_offset, Time.now)
  scope :flagged_today, flagged.where("CAST(created_at + interval '? seconds' AS date) = CAST(? AS date)", Time.zone.utc_offset, Time.now)

  validate :check_flagging_and_closing, :if => :flagging_or_closing?

  after_save :set_activity_at_for_activityable

  def build_points(hash)
    if hash[:user_id]
      if points_receiver(hash[:user_id])
        if ActivityPoint.not_undo.where(:user_id=>hash[:user_id]).
           created_today.sum(:value) >= APP_REPUTATION['max_rep_by_up_votes']
          hash[:value] = 0
        end
      end
    else
      hash[:user_id] = self.user_id
    end
    self.activity_points.build(hash)
  end

  def points_receiver(user_id)
    # ten user_id ktory nie jest tworca activity, jest otrzymujacym punkty
    self.user_id != user_id
  end

  def answer_created?
    name == 'create' && activityable_type == 'An'
  end

  def answer_resolved?
    name == 'an_resolved'
  end

  def comment_created?
    name == 'create' && activityable_type == 'Comment'
  end

  def vote_expired?
    self.created_at <= Time.now - APP_VOTING_CONFIG['days_to_cancel_vote'].days
  end

  def undo_activity
    self.undo = UNDO
    self.undo_at = Time.now
    self.activity_points.each do |points|
      points.update_attributes(:undo => ActivityPoint::UNDO)
    end
    self.save(:validate=>false)
  end

  def name_humanized
    unless self.name.empty?
      if self.activityable
        I18n.t("activities.names.#{self.name}_#{self.activityable.class.name.downcase}")
      else
        I18n.t("activities.names.#{self.name}")
      end
    end
  end

private

  def flagging?
    self.name == 'flag'
  end

  def closing?
    self.name == 'close'
  end

  def flagging_or_closing?
    self.name == 'flag' || self.name == 'close'
  end

  def check_flagging_and_closing
    if flagging?
      if self.user.activities.flagged_today.count > APP_VOTING_CONFIG['max_flag_par_day']
        errors.add(:base,:too_many_reports)
      end
    end

    if flagging? && activity = self.activityable.activities.flagged.where(:user_id=>self.user_id).first
      errors.add(:base,:already_reported,:content=>activity.extra)
    end

    if closing? && self.activityable.activities.close_reported.where(:user_id=>self.user_id).first
      errors.add(:base,:closed_question)
    end

    if self.extra.blank?
      errors.add(:base,:report_reason)
    end
  end


  def set_activity_for(o)
    o.activity_at = Time.now
    o.save(:validate => false)
  end

  def set_activity_for_thr(thr)
    thr.last_activity_user_id = user_id
    thr.last_activity_id = id
    set_activity_for(thr)

    # jesli byly jakies zmiany aktywnosci w pytaniu od czasu ostatniej wizyty
    # to wysylam wszystkim zapisanym na liscie subskrypcji

    # mozna opoznic troche mailera (2 - 5min), by oszczedzic na niepotrzebych aktywnosciach
    # ktore odbiorca moze tak czy siak zobaczyc odswiezajac strone
    # wykonac w delay jobie zapytanie o nowe subskrybcje. Delayed job bedzie tworzony w tej metodzie

    if subscriptions = Subscription.joins(:subscribable_thr).
      where("subscriptions.user_id <> ? AND thrs.id=?",user_id,thr.id).
      where("subscriptions.last_view < thrs.activity_at")

      subscriptions.each do |sub|
        # jesli zaznaczyl ze chce otrzymywac i rzeczywiscie zostala taka akcja wykonana to
        if (sub.user.user_setting.notify_answers==1 && answer_created?) ||
           (sub.user.user_setting.notify_comments==1 && comment_created?) ||
           (sub.user.user_setting.notify_answer_resolved==1 && answer_resolved?)

          p "send mail to #{sub.user.name}"

          Mailer.notify_thr_activity(sub.user,thr).deliver
        else
          p 'not sending because user uncheck subscription or there was undefined action'
        end
      end

    end

  end

  def set_activity_at_for_activityable
    if ['create','delete','revise','an_resolved','an_unresolved','close'].include? name
      if activityable.class == Thr
        set_activity_for_thr(activityable)
      elsif activityable.class == An
        set_activity_for(activityable)
        set_activity_for_thr(activityable.thr)
      elsif activityable.class == Comment
        # p 'add activity for comment'
        set_activity_for(activityable) # for comment
        if activityable.commentable.class == Thr
          # p 'add comment for question'
          set_activity_for_thr(activityable.commentable) # for question
        elsif activityable.commentable.class == An
          # p 'add comment for question and answers'
          set_activity_for(activityable.commentable) # for answer
          set_activity_for_thr(activityable.commentable.thr) # for question
        end
      end

    end
  end

end
