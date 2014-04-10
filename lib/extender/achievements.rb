module Extender
  module Achievements

    # tutaj przechowywane sa wszystkie metody wywolywane w callbacku activity after_create
    # ten modul zaklada, ze tylko za aktywnosc mozna otrzymac osiagniecie
    def self.included(base)
      base.extend(ClassMethods).relate
      base.send :include, InstanceMethods
    end

    module ClassMethods
      def relate
        has_one :achievement
        after_create :set_achievement
      end
    end

    module InstanceMethods

      private

      # not working
      # cleanup
      # taxonomist

      # activityable - current_object
      # id - id aktywnosci, musi istniec po poprawnym utworzeniu rekordu aktywnosci
      # user - wykonujacy aktywnosc
      # activityable.user - wlasciciel obiektu uczestniczacego w aktywnosci
      # name - nazwa aktywnosci

      def set_achievement
        if [:day_activity,:fav,:update_user,:create,:revise,:delete,:resolved,:flag,:vote_up,:vote_down].include? name.to_sym
          send :"achievement_for_#{name}"
        end
      end

      def consecutive_days(asc_array,consecutive_days=30)
        asc_array.map! {|x| x.to_date}
        consecutive = consecutive_days.times.map {|i| asc_array.include?((Time.now + i.days).to_date) }
        consecutive.all? # wszystkie sa na true
      end

      def achievement_for_day_activity
        if (user.created_at < Time.zone.now - APP_BADGES_CONFIG['yearling_years'].years) && (user.reputation > APP_BADGES_CONFIG['yearling_reputation'])
          Achievement.find_or_create('yearling',:user=>user,:activity=>self)
        end

        activities = user.activities.where(:name=>"day_activity").select("created_at").order("created_at asc").limit(100)
        if consecutive_days(activities.map(&:created_at),APP_BADGES_CONFIG['enthusiast'])
          Achievement.find_or_create('enthusiast',:user=>user,:activity=>self)
        end
        if consecutive_days(activities.map(&:created_at),APP_BADGES_CONFIG['fanatic'])
          Achievement.find_or_create('fanatic',:user=>user,:activity=>self)
        end
      end

      #ok
      def achievement_for_update_user
        if !user.name.blank? && !user.birth.blank? && !user.about.blank?
          Achievement.find_or_create('autobiographer',:user=>user,:activity=>self)
        end
      end

      def achievement_for_create
        if activityable.class.name == 'Thr' # ask
        # TODO konieczne jest dodanie informacji za jaki tag. Wykomentowane do czasu wgrania poprawki
#        activityable.tags.active.where("quantity >= ?",APP_BADGES_CONFIG['taxonomist']).each do |tag|
#          Achievement.find_or_create('taxonomist',:user=>tag.user,:activity=>self)
#        end
        elsif activityable.class.name == 'An' # ask
          # tutaj uzytkownik moze otrzymac osiagniecie za tag
          # jesli tag wystepuje w odpowiedziach usera
#          Achievement.find_or_create('great_question',:user=>activityable.user ,:activity=>self ,:uniq_activityable=>true)
#          activityable.thr.tags.active
        #ok
        elsif activityable.class.name == 'Comment'
          if activityable.activities.where(:name=>'create',:user_id=>user.id).count(:id) >= APP_BADGES_CONFIG['commentator']
            Achievement.find_or_create('commentator',:user=>user,:activity=>self)
          end
        end
      end

      def achievement_for_revise
        # tutaj tez musze sprawdzac tagi dla thr
        Achievement.find_or_create('editor',:user=>user,:activity=>self)
      end

      #ok
      def achievement_for_delete
        if activityable.class.name == 'Thr'
          if activityable.user_id == user.id && activityable.vote_count >= APP_BADGES_CONFIG['disciplined']
            Achievement.find_or_create('disciplined',:user=>user,:activity=>self)
          end

          if activityable.user_id == user.id && activityable.vote_count <= APP_BADGES_CONFIG['peer_pressure']
            Achievement.find_or_create('peer_pressure',:user=>user,:activity=>self)
          end
        end
      end

      #TODO
      def achievement_for_fav
        activityable.activities.reload
        if activityable.users_fav.count >= APP_BADGES_CONFIG['favorite_question']
          Achievement.find_or_create('favorite_question',:user=>activityable.user,:activity=>self)
        end

        if activityable.users_fav.count >= APP_BADGES_CONFIG['stellar_question']
          Achievement.find_or_create('stellar_question',:user=>activityable.user,:activity=>self)
        end
      end

      #ok
      def achievement_for_resolved
        # zadales pytanie i zaakceptowales odpowiedz ( niekoniecznie swoją )
        if activityable.thr.user_id == user.id
            Achievement.find_or_create('scholar',:user=>user,:activity=>self)
        end
      end

      #ok
      def achievement_for_flag
        # zglosil naduzycie poraz pierwszy
        Achievement.find_or_create('citizen_patrol',:user=>user,:activity=>self)
      end

      def achievement_for_vote_up
        if activityable.class.name == 'Thr' # ask

          if activityable.vote_count >= APP_BADGES_CONFIG['nice_question']
            # uniq_activityable for each thr, an or comment
            Achievement.find_or_create('nice_question',:user=>activityable.user, :activity=>self , :uniq_activityable=>true)
          end

          if activityable.vote_count >= APP_BADGES_CONFIG['good_question']
            Achievement.find_or_create('good_question',:user=>activityable.user ,:activity=>self ,:uniq_activityable=>true)
          end

          if activityable.vote_count >= APP_BADGES_CONFIG['great_question']
            Achievement.find_or_create('great_question',:user=>activityable.user ,:activity=>self ,:uniq_activityable=>true)
          end

          # jesli pytanie otrzymalo wiecej niz 3 voty na plus to odznake dostaje wlasciciel activityable
          if activityable.vote_up >= APP_BADGES_CONFIG['self_learner']
            Achievement.find_or_create('self_learner',:user=>activityable.user ,:activity=>self)
          end
          
        elsif activityable.class.name == 'An' # ask

          if activityable.vote_count >= APP_BADGES_CONFIG['nice_answer']
            Achievement.find_or_create('nice_answer',:user=>activityable.user ,:activity=>self ,:uniq_activityable=>true)
          end

          if activityable.vote_count >= APP_BADGES_CONFIG['good_answer']
            Achievement.find_or_create('good_answer',:user=>activityable.user ,:activity=>self ,:uniq_activityable=>true)
          end

          if activityable.vote_count >= APP_BADGES_CONFIG['great_answer']
            Achievement.find_or_create('great_answer',:user=>activityable.user ,:activity=>self ,:uniq_activityable=>true)
          end

          # jesli odpowiedzi otrzymala 1 i wiecej glosow to odznake dostaje tworca current_object
          if activityable.vote_up >= APP_BADGES_CONFIG['teacher']
            Achievement.find_or_create('teacher',:user=>activityable.user ,:activity=>self)
          end
        
        end
        
        achievement_on_vote(name,user)
      end

      def achievement_for_vote_down
        achievement_on_vote(name,user)
      end

      #ok
      def achievement_on_vote(vote,user)
        # first vote_down
        if vote.include? 'vote_down'
          Achievement.find_or_create('critic',:user=>user,:activity=>self)
        end

        if vote.include? 'vote_up'
          Achievement.find_or_create('supporter',:user=>user,:activity=>self)
        end

        if user.activities.votes_for_thrs_and_ans.count(:user_id) >= APP_BADGES_CONFIG['civic_duty']
          Achievement.find_or_create('civic_duty',:user=>user,:activity=>self)
        end
      end

    end

  end
end