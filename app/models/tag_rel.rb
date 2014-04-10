class TagRel < ActiveRecord::Base

  belongs_to :tag
  belongs_to :taggable, :polymorphic => true

  attr_protected # accessible all atrrs

end
