module Extender
  module Voteable

    def self.included(base)
      
#      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end

    module InstanceMethods

      def model_name
        self.class.name
      end

      def model_name_downcased
        self.class.name.downcase
      end

      def vote_count
        vote_down + vote_up
      end

      def voted?(voter,vote=nil)
        params = {:user_id => voter.id}
        if vote
          params.merge!(:name => "vote_#{vote}",:activityable_type => model_name )
        else
          params.merge!(:name.matches => "vote_%")
        end
        self.activities.not_undo.where(params).first
      end

      def vote(voter,vote) # self.user # thr owner

        unless ["up","down"].include?(vote)
          errors[:base] << I18n.t("voteable.bad_param")
          return false
        end

        if voter.id == self.user.id
          errors[:base] << I18n.t("voteable.onself")
          return false
        end

        if self.activities.votes.created_today.where(:user_id=>voter.id).count(:id) > APP_VOTING_CONFIG['max_votes_per_day']
          errors[:base] << I18n.t("voteable.max_per_day",:max=>APP_VOTING_CONFIG['max_votes_per_day'])
          return false
        end

        if activity = voted?(voter)
          if activity.vote_expired?
            errors[:base] << I18n.t("voteable.cant_undo")
            return false
          end
          # jesli glos byl oddany na ten, ktory jest juz w bazie to musze cofnac te czynnosc
          # jesli termin waznosci wycofania mija to nie powinien wykonac akcji wycofania
          if activity.name == "vote_#{vote}" && activity.activityable_type == model_name
            vote == 'up' ? self.decrement(:vote_up) : self.increment(:vote_down)
            Extender::Activities.send(:"undo_vote_#{vote}_#{model_name_downcased}", self, voter)
            self.save
          else
          # kolejne glosy w nie ten sam przycisk glosowania
            errors[:base] << I18n.t("voteable.vote_already")
            return false
          end
        else
          vote == 'up' ? self.increment(:vote_up) : self.decrement(:vote_down)
          Extender::Activities.send(:"vote_#{vote}_#{model_name_downcased}", self, voter)
          self.save
        end
        
      end

    end
  end
end