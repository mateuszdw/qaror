module Extender
  module Impressionable
    
    def self.included(base)
      base.extend(ClassMethods).relate
      base.send :include, InstanceMethods
    end

    module ClassMethods
      def relate
        has_many :impressions, :as=>:impressionable, :dependent => :destroy
      end
    end

    module InstanceMethods

      def set_achievement
        self.increment!(:hotness)
        self.increment!(:hits)
    #    impressionable.reload # reload hits, hotness
        if self.class.name == 'Thr'
          if self.hits >= APP_BADGES_CONFIG['popular_question'] &&
              self.hits < APP_BADGES_CONFIG['notable_question']
            Achievement.find_or_create('popular_question',:activityable=>self)
          end
          if self.hits >= APP_BADGES_CONFIG['notable_question'] &&
              self.hits < APP_BADGES_CONFIG['famous_question']
            Achievement.find_or_create('notable_question',:activityable=>self)
          end
          if self.hits >= APP_BADGES_CONFIG['famous_question']
            Achievement.find_or_create('famous_question',:activityable=>self)
          end
        end
      end

      def log_impression(ip,user=nil)
        unless APP_CONFIG['unique_impressions']
          set_achievement
          return
        end
        
        hash = {:ip=>ip}
        hash[:user_id] = user ? user.id : nil
        unless impressions.where(hash).first
          impressions.create(hash)
          reload
        end
      end

      def impression_count
        impressions.size
      end
      
      def unique_impression_count
        impressions.group(:ip).size
      end
    end

  end
end