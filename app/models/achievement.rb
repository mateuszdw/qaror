class Achievement < ActiveRecord::Base

  belongs_to :trigger, :foreign_key => :trigger_id, :class_name => "Activity"
  belongs_to :activity
  belongs_to :tag
  belongs_to :user
  belongs_to :badge, :counter_cache => "achieved_count"

  attr_reader :name
  attr_protected # accessible all atrrs
#  validates :name,
#            :inclusion => { :in => self.ALL, :message => " nie jest odpowiedni" },
#            :unless => :using_tag?

  after_save :update_user_ranks

  # args[0] - badge name
  # args[1] - user object
  # args[2] - activity trigger object ( usually activity object )
  # hash - options ( uniq_activityable=>true - include trigger in find_or_create condition )
  def self.find_or_create(*args)
    return false unless APP_CONFIG['gain_achievements']

    name = args[0]
    user = args[1][:user]
    activity = args[1][:activity]
    uniq_activityable = args[1][:uniq_activityable]
    activityable = args[1][:activityable]

    badge = Badge.find_by_name!(name)

    if activity && user && uniq_activityable == true
      unless badge.activities.activityable_object(activity.activityable).where(:user_id=>user.id).first
        # create activity 'achieve'
        achieve_activity = activity.activityable.activities.create(:user_id=>user.id,:name=>'achieve')
        badge.achievements.create(:user_id=>user.id,:trigger_id=>activity.id,:activity_id=>achieve_activity.id)
      end
    elsif activityable
      unless badge.activities.activityable_object(activityable).where(:user_id=>activityable.user.id).first
        achieve_activity = activityable.activities.create(:user_id=>activityable.user.id,:name=>'achieve')
        badge.achievements.create(:user_id=>activityable.user.id,:activity_id=>achieve_activity.id)
      end
    elsif activity && user
      activity_hash = activity ? {:trigger_id=>activity.id} : {}
      unless badge.achievements.where(:user_id=>user.id).first
        achieve_activity = Activity.create(:user_id=>user.id,:name=>'achieve')
        badge.achievements.create({:user_id=>user.id,:activity_id=>achieve_activity.id}.merge(activity_hash))
      end
    end
  end

  def name
    self.badge.name
  end

  def type_humanized
    self.badge.type_humanized
  end

  def achieved_count
    self.badge.achieved_count
  end

private

  def update_user_ranks
    self.user.ranks = self.user.achievements_grouped
    .inject({}) { |h,(k,v)| h[Badge.type_humanized(k)] = v;h}
    self.user.save
  end

end
