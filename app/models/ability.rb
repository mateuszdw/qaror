class Ability
  include CanCan::Ability
  # read create update,destroy
  def initialize(user)
    user = User.new if user.nil?

    #
    #guest
    #
    can [:index,:show,:new,:create,:remind_password,:remind_password_edit,:change_password_edit,:change_password,:activate,:activity,:reputation,:favorites,:ako], :user #registration
    can [:index,:create,:failure], :login

    can [:index,:show,:new,:create,:vote,:answer], Thr
    can [:create,:vote], An
    can [:index,:show], Achievement

    #
    # registered user
    #
    if user.is_registered?
      cannot [:index,:create], :login
      can [:logout], :login

      cannot [:new,:create,:remind_password,:remind_password_edit], :user

      can [:index,:show,:update,:edit,:activate,:send_activation_link,:activity,:votes,:favorites,:votes,:ako], :user

      can [:index,:show,:new,:create,:fav,:vote,:subscribe,:answer], Thr
      can [:edit,:update,:destroy],Thr do |thr| thr.user == user end

      can [:create,:vote,:resolved,:unresolved], An
      can [:edit,:update,:destroy],An do |an| an.user == user end

      # can always comment on your questions and answers, and any answers to questions you’ve asked
      can [:show,:new,:create,:vote], Comment do |c|
        (c.commentable.respond_to?('user') && (c.commentable.user_id == user.id)) ||
        ((c.commentable.class == An) && (c.commentable.thr.user_id == user.id))
#        p c.commentable.respond_to?('user')
#        p c.commentable.user_id == user.id
      end
      
      # edit own
      can [:edit,:update,:destroy],Comment do |comment| comment.user == user end
      can [:index,:show], Achievement

      
      # minimum reputation
      if user.not_confirmed?
        cannot [:new,:create], Comment
      end

      if user.reputation > 0 || user.active? || user.is_moderator? || user.is_admin? # show captcha
        can [:skip_captcha],Thr
        can [:skip_captcha],An
      else
        cannot [:skip_captcha],Thr
        cannot [:skip_captcha],An
      end

      # Vote up # Flag for moderator attention
      if user.reputation >= APP_PRIVILEGES['flag_voteup']['value'] || user.is_moderator? || user.is_admin?
        can [:report_flag,:flag], Thr do |thr| thr.user != user end
        can [:report_flag,:flag], An do |an| an.user != user end
        can [:vote_up], Thr
        can [:vote_up], An
        can [:vote_up], Comment
      end
      
      # Leave comments # you can always comment on your questions and answers, and any answers to questions you’ve asked, even with 1 rep.
      if user.reputation > APP_PRIVILEGES['leave_comments']['value'] || user.is_moderator? || user.is_admin?
        can [:new,:create,:edit,:update],Comment
      end

      if user.reputation > APP_PRIVILEGES['votedown']['value'] || user.is_moderator? || user.is_admin? # Vote down, Edit community wiki posts
        can [:vote_down], Thr
        can [:vote_down], An
      end

      if user.reputation > APP_PRIVILEGES['reduceads']['value'] # Reduced advertising
      end

      # Vote to close, vote toreopen, or migrate your questions
      if user.reputation > APP_PRIVILEGES['voteclose']['value'] || user.is_moderator? || user.is_admin?
        can [:report_close,:close], Thr
      end

      # Retag questions # can reopen questions
      if user.reputation > APP_PRIVILEGES['retag_reopen']['value'] || user.is_moderator? || user.is_admin?
        can [:retag,:reopen], Thr
      end
      
      # 	Show total up and down vote counts
      if user.reputation > APP_PRIVILEGES['votetotal']['value'] || user.is_admin?
        can [:vote_total], Thr
        can [:vote_total], An
      end

      # 	Create new tags
      if user.reputation > APP_PRIVILEGES['createtags']['value'] || user.is_moderator? || user.is_admin?
        can :create, Tag
      end

      # 	Edit other people’s posts, vote to approve or reject suggested edits
      if user.reputation > APP_PRIVILEGES['editposts']['value'] || user.is_moderator? || user.is_admin?
        can [:edit,:update], Thr
        can [:edit,:update], An
      end

      if user.is_moderator? || user.is_admin?
        can [:destroy],Thr
        can [:destroy],An
        can [:destroy],Comment
      end

    end

    unless APP_CONFIG['manage_users']
      cannot(:manage, :user)
      can(:ako, :user)
    end
    cannot(:manage, :login) unless APP_CONFIG['manage_login']
    cannot(:manage, Achievement) unless APP_CONFIG['manage_achievements']
       
  end

end
