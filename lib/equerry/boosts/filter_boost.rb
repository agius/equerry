module Equerry
  module Boosts
    class FilterBoost

      def initialize(filter:, weight: 1.2)
        @filter = filter
        @weight = weight
      end

      def to_search
        {
          filter: @filter.to_search,
          weight: @weight
        }
      end
    end
  end
end
