class UserSetting < ActiveRecord::Base
  attr_accessible :notify_answers, :notify_comments, :notify_answer_resolved

  before_create {
    self.notify_answers = 1
    self.notify_answer_resolved = 1
    self.notify_comments = 1
  }

  belongs_to :user

protected

  def uncheck_all_notifies
    all_notifies_hash = attributes.inject({}) {|h,(k,v)| h[k]=0 if k.include?('notify_');h }
    update_attributes(all_notifies_hash)
  end


end
