module Extender
  module Voteable
    
    def self.included(base)
#      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end

    module InstanceMethods

      def self.sortable(sort_by={})
        default = [:created_at,:desc].join(" ")
        valid = ['created_at','uploaded_at','sizebyte','name']
        return order(default) if sort_by.nil?
        sortable = []
        sort_by.each do |column,order|
          return order(default) if column.nil? || order.nil?
          if valid.include?(column)
              order = order == "asc" ? "asc" : "desc"
              if alias? column
                sortable << [aliases[column.to_sym], order]
              else
                sortable << [column.to_sym, order]
              end
          end
        end
        order(sortable.join(" "))
      end

    end

  end
end