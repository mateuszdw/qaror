module UsersHelper

  def role(integer)
    case integer
      when User::ROLE_NONE then 'nieaktywny'
      when User::ROLE_USER then 'uzytkownik'
      when User::ROLE_MODERATOR then 'moderator'
      when User::ROLE_ADMIN then 'admin'
    end
  end

  def status(integer)
    case integer
      when User::STATUS_ANONYMOUS then 'anonim'
      when User::STATUS_NOTCONFIRMED then 'niepotwierdzony'
      when User::STATUS_ACTIVE then 'aktywny'
      when User::STATUS_BLOCKED then 'zablokowany'
    end
  end

  def user_label(user)
    @user = user
    render :partial=>'users/user_label'
  end

  def user_label_small(user)
    @user = user
    render :partial=>'users/user_label',:locals=>{:small=>true}
  end

  def reputation_sign_humanized(value)
    return "plus" if value > 0
    return "minus" if value < 0
    return "zero" if value == 0
  end

  def reputation_sign(value)
    return "+" if value > 0
    return "" if value <= 0
  end

end
