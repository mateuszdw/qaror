class Impression < ActiveRecord::Base
  belongs_to :impressionable, :polymorphic=>true #, :counter_cache => 'hits'

  attr_protected # accessible all atrrs

  after_create :set_achievement

private

  def set_achievement
    impressionable.set_achievement
  end

#  def set_achievement
#    impressionable.increment!(:hotness)
#    impressionable.increment!(:hits)
##    impressionable.reload # reload hits, hotness
#    if impressionable.class.name == 'Thr'
#      if impressionable.hits >= APP_BADGES_CONFIG['popular_question'] &&
#          impressionable.hits < APP_BADGES_CONFIG['notable_question']
#        Achievement.find_or_create('popular_question',:activityable=>impressionable)
#      end
#      if impressionable.hits >= APP_BADGES_CONFIG['notable_question'] &&
#          impressionable.hits < APP_BADGES_CONFIG['famous_question']
#        Achievement.find_or_create('notable_question',:activityable=>impressionable)
#      end
#      if impressionable.hits >= APP_BADGES_CONFIG['famous_question']
#        Achievement.find_or_create('famous_question',:activityable=>impressionable)
#      end
#    end
#  end

end
