# encoding: utf-8
module Extender
  module Taggable
    
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
      base.relate
    end

    module ClassMethods
      def relate
        has_many :tag_rels, :as => :taggable, :dependent => :destroy
        has_many :tags, :through=> :tag_rels
        accepts_nested_attributes_for :tags
        before_destroy :decrement_tags_counter
        
        validates :tagnames, :presence => true
        validate :check_tags

        before_save :set_tags

        def grouped_tags(thr)
          joins(:tags).
          where(:tags=>{:name.matches_any=> thr.tags.map(&:name) }).
          group("tags.name").count(:id)
        end

      end
    end

    module InstanceMethods

        def check_tags
          unless self.tagnames.nil?
            # first tag must be in special tags array
            # unless Tag::SPECIAL_TAGS.include? tags_array_from_string.first
            #   errors.add(:tagnames,:no_special_tags,:arr=>Tag::SPECIAL_TAGS.join(', '))
            # end

            # check tags count
            if tags_array_from_string.count < Tag::MIN_TAGS || tags_array_from_string.count > Tag::MAX_TAGS
              errors.add(:tagnames,:min_max_tags,:min=>Tag::MIN_TAGS.to_s,:max=>Tag::MAX_TAGS.to_s)
            end
          end
        end

        def set_tags
          return unless self.tagnames
          tags_arr = tags_array_from_string
          self.tagnames = tags_arr.join(' ')
          return unless self.tagnames_changed?
          decrement_tags_counter
          self.tag_rels.destroy_all

          tags_arr.each do |tagname|
              tag = Tag.active.find_or_initialize_by_name(tagname)
              if tag.new_record? #
                tag.user_id = user_id
                tag.increment(:quantity)
                unless tag.save
                  errors.add(:tagnames,"zawiera słowo \"#{tagname}\", które #{tag.errors.first.last}")
                  return false
                end
              else
                tag.increment!(:quantity)
              end
              self.tag_rels.build(:tag_id=>tag.id)
          end
        end

        def decrement_tags_counter
          self.tags.each { |tag| tag.decrement!(:quantity) }
        end

        def tags_array_from_string
          self.tagnames.downcase.gsub(tag_sanitize_pattern,"").split(' ').uniq
        end

        def tag_sanitize_pattern
          /[^0-9a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻ\- ]+/i
        end

    end

  end
end