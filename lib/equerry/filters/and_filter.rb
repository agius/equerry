module Equerry
  module Filters
    class AndFilter
      attr_reader :filters

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
