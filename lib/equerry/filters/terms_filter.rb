module Equerry
  module Filters
    class TermsFilter
      attr_reader :field, :values

      def initialize(field:, values:)
        @field = field
        @values = Array(values)
      end

      def to_search
        {
          terms: {
            @field => @values
          }
        }
      end
    end
  end
end
