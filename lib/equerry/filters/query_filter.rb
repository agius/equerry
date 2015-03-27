module Equerry
  module Filters
    class QueryFilter

      def initialize(query)
        @query = query
      end

      def to_search
        {
          query: @query.to_search
        }
      end
    end
  end
end
