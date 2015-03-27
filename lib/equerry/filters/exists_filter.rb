module Equerry
  module Filters
    class ExistsFilter

      # CAUTION: this will match empty strings
      # see http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-exists-filter.html
      def initialize(field)
        @field = field
      end

      def to_search
        {
          exists: {
            field: @field
          }
        }
      end
    end
  end
end
