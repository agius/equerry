module Equerry
  module Filters
    class TermsFilter

      def initialize(field:, values:)
        @field = field
        if(values.is_a?(Array))
          @values = values
        else
          @values = [values]
        end
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
