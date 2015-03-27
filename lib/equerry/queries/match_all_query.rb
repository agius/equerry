module Equerry
  module Queries
    class MatchAllQuery
      def to_search
        { match_all: {} }
      end
    end
  end
end
