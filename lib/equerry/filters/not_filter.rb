module Equerry
  module Filters
    class NotFilter

      def initialize(filters)
        if(filters.is_a?(Array))
          if filters.count == 1
            @filter = filters.first
          else
            @filter = AndFilter.new(filters)
          end
        else
          @filter = filters
        end
      end

      def to_search
        { not: @filter.to_search }
      end
    end
  end
end
