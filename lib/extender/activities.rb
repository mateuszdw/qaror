module Extender
  module Activities

      #
      # Activities for which users get achievements and reputation points
      # 
      # NOTICE:
      # Each activity gets action owner object
      #

      # reputation increase (only once) for email confirmation
      def self.confirm_email(user)
        params = {:name=>'confirm_email'}
        unless user.activities.not_undo.where(params).first
          a = user.activities.build(params)
          a.build_points(:value=> APP_REPUTATION['confirm_email'])
          a.save!
        end
      end

      # achievement for edit user data
      def self.update_user(user)
        user.activities.build(:name=>'update_user')
      end

      # user activity and inactivity days
      def self.day_activity(user)
        activities = user.activities.where(:name=>"day_activity").select("created_at").order("created_at asc").limit(100)
        unless activities.map(&:created_at).find {|day| day.today? } # jesli jeszcze dzis sie nie logowal
          user.activities.build(:name=>'day_activity')
        end
      end

      #
      # viewed posts
      #
      def self.revise(current_object,user)
        current_object.activities.build(:user_id=>user.id,:name=>'revise')
      end

      #
      # TODO:
      # revert to previous document version
      #
      def self.revert(current_object,user)
#        current_object.activities.build(:user_id=>user.id,:name=>'revert')
#        a.build_points(:value=>APP_REPUTATION['revert'])
      end
      
      #
      # create question
      #
      def self.create(current_object,user)
        model_name = current_object.class.name.downcase
        a = current_object.activities.build(:user_id=> user.id, :name=>'create')
        if APP_REPUTATION['create_'+model_name] != 0
          a.build_points(:value => APP_REPUTATION['create_'+model_name])
        end

        if model_name == 'an' # answer
          current_object.thr.increment!(:hotness)
        end
      end

      #
      # delete question
      #
      def self.delete(current_object,user)
        model_name = current_object.class.name.downcase
        a = current_object.activities.build(:user_id=>user.id,:name=>'delete')
        if APP_REPUTATION['delete_'+model_name] != 0
          if current_object.user_id == user.id
            a.build_points(:value => APP_REPUTATION['delete_'+model_name],:reduce_points_if_needed=>true)
          end
        end
      end

      def self.fav(current_object,user)
        if a = current_object.activities.not_undo.where(:user_id=>user.id,:name=>'fav').first
          a.undo_activity
        else
          current_object.activities.create(:user_id=>user.id,:name=>'fav')
        end
      end

      #
      # best answer achievement
      #
      def self.an_resolved(current_object,user)
        a = current_object.activities.build(:user_id=>user.id,:name=>'resolved')
        # gain reputation only when is not author
        unless current_object.thr.user_id == user.id
          a.build_points(:value=>APP_REPUTATION['an_resolved'])
          a.build_points(:reduce_points_if_needed=>true,:user_id=>current_object.user.id,:value=>APP_REPUTATION['receives_an_resolved'])
        end
      end

      def self.an_unresolved(current_object,user)
        current_object.activities.not_undo.where(:user_id=>user.id,:name=>'resolved').each do |a|
          a.undo_activity
        end
      end

      #
      # achievement for report posts
      #
      def self.flag(current_object,user,acomment=nil)
        create = {:user_id=>user.id,:name=>'flag'}
        create.merge!(:extra=>acomment) unless acomment.blank?
        a = current_object.activities.build(create)
        a.build_points(:reduce_points_if_needed=>true, :user_id=>current_object.user_id, :value=>APP_REPUTATION['flag'])
      end

      #
      # achievement for close report posts
      #
      def self.close(current_object,user,acomment=nil)
        create = {:user_id=>user.id,:name=>'close'}
        create.merge!(:extra=>acomment) unless acomment.blank?
        current_object.activities.create!(create)
      end

      #
      # SCORING ACTIONS - voter points
      #
      # vote questions
      def self.vote_up_thr(current_object,user)
        a = current_object.activities.build(:user_id=>user.id,:name=>'vote_up')
        a.build_points(:value => APP_REPUTATION['vote_up_thr'])
        a.build_points(:reduce_points_if_needed=>true,:user_id=>current_object.user.id,:value => APP_REPUTATION['thr_receives_up_vote'])
        self.on_vote_thr(current_object,user)
      end

      def self.vote_down_thr(current_object,user)
        a = current_object.activities.build(:user_id=>user.id,:name=>'vote_down')
        a.build_points(:value=> APP_REPUTATION['vote_down_thr'])
        a.build_points(:reduce_points_if_needed=>true,:user_id=>current_object.user.id,:value => APP_REPUTATION['thr_receives_down_vote'])
        self.on_vote_thr(current_object,user)
      end

      # vote answers
      def self.vote_up_an(current_object,user)
        a = current_object.activities.build(:user_id=>user.id,:name=>'vote_up')
        a.build_points(:value=>APP_REPUTATION['vote_up_an'])
        a.build_points(:reduce_points_if_needed=>true,:user_id=>current_object.user.id,:value=>APP_REPUTATION['an_receives_up_vote'])
        self.on_vote_an(current_object,user)
      end

      def self.vote_down_an(current_object,user)
        a = current_object.activities.build(:user_id=>user.id,:name=>'vote_down')
        a.build_points(:value=>APP_REPUTATION['vote_down_an'])
        a.build_points(:reduce_points_if_needed=>true,:user_id=>current_object.user.id,:value=>APP_REPUTATION['an_receives_down_vote'])
        self.on_vote_an(current_object,user)
      end

      # vote comments
      def self.vote_up_comment(current_object,user)
        a = current_object.activities.build(:user_id=>user.id,:name=>'vote_up')
        a.build_points(:value=>APP_REPUTATION['vote_up_comment'])
        a.build_points(:reduce_points_if_needed=>true,:user_id=>current_object.user.id,:value=>APP_REPUTATION['comment_receives_up_vote'])
      end

      def self.vote_down_comment(current_object,user)
        a = current_object.activities.build(:user_id=>user.id,:name=>'vote_down')
        a.build_points(:value=>APP_REPUTATION['vote_down_comment'])
        a.build_points(:reduce_points_if_needed=>true,:user_id=>current_object.user.id,:value=>APP_REPUTATION['comment_receives_down_vote'])
      end

      
      #
      # UNDO ACTIONS
      #
      
      # undo vote questions
      def self.undo_vote_up_thr(current_object,user)
        current_object.activities.not_undo.where(:user_id=>user.id,:name=>'vote_up').each do |a|
          a.undo_activity
        end
      end

      def self.undo_vote_down_thr(current_object,user)
        current_object.activities.not_undo.where(:user_id=>user.id,:name=>'vote_down').each do |a|
          a.undo_activity
        end
      end

      # undo vote answers
      def self.undo_vote_up_an(current_object,user)
        current_object.activities.not_undo.where(:user_id=>user.id,:name=>'vote_up').each do |a|
          a.undo_activity
        end
      end

      def self.undo_vote_down_an(current_object,user)
        current_object.activities.not_undo.where(:user_id=>user.id,:name=>'vote_down').each do |a|
          a.undo_activity
        end
      end

      # undo vote comments
      def self.undo_vote_up_comment(current_object,user)
        current_object.activities.not_undo.where(:user_id=>user.id,:name=>'vote_up').each do |a|
          a.undo_activity
        end
      end

      def self.undo_vote_down_comment(current_object,user)
        current_object.activities.not_undo.where(:user_id=>user.id,:name=>'vote_down').each do |a|
          a.undo_activity
        end
      end

private

      def self.on_vote_thr(current_object,user)
        current_object.increment!(:hotness)
      end

      def self.on_vote_an(current_object,user)
        current_object.thr.increment!(:hotness)        
      end
  end
end