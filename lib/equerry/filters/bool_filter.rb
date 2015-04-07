module Equerry
  module Filters
    class BoolFilter
      attr_reader :must, :must_not, :should

      def initialize(must:, must_not:, should: nil)
        @must = must
        @must_not = must_not
        @should = should
      end

      def to_search
        json = {}
        json[:must] = @must.map(&:to_search) if @must.present?
        json[:must_not] = @must_not.map(&:to_search) if @must_not.present?
        json[:should] = @should.map(&:to_search) if @should.present?
        { bool: json }
      end
    end
  end
end
