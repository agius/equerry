module Equerry
  module Filters
    class AndFilter

      def initialize(filters)
        @filters = filters
      end

      def to_search
        {
          and: @filters.map(&:to_search)
        }
      end

    end
  end
end
