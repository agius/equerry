module Equerry
  module Queries
    class MatchQuery
      attr_reader :field, :operator, :string

      def initialize(string, field: '_all', operator: 'and')
        @field    = field
        @operator = operator
        @string   = string
      end

      def to_search
        {
          match: {
            @field => {
              query: @string,
              operator: @operator
            }
          }
        }
      end

    end
  end
end
