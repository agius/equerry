module Equerry
  module Combinators
    class WhereCombinator

      def initialize(options = {})
        @queries = []
        @queries << options[:query] if options[:query]
        @queries += options[:queries] if options[:queries]
        
        @filters = []
        @filters << options[:filter] if options[:fitler]
        @filters += options[:filters] if options[:filters]

        @boosts = []
        @boosts << options[:boost] if options[:boost]
        @boosts += options[:boosts] if options[:boosts]
      end

      def and
        AndCombinator.new(
          queries: @queries,
          filters: @filters,
          boosts: @boosts
        )
      end

      def or(query)
        OrCombinator.new(
          queries: @queries,
          filters: @filters,
          boosts: @boosts
        )
      end

      def not(query)
        NotCombinator.new(
          queries: @queries,
          filters: @filters,
          boosts: @boosts
        )
      end

      def to_search

      end

    end
  end
end