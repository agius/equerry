module Search
  module Boosts
    class RandomBoost
      attr_reader :seed

      # randomizes order (somewhat) consistently per-user
      # http://www.elastic.co/guide/en/elasticsearch/guide/current/random-scoring.html

      def initialize(seed)
        @seed = seed
      end

      def to_search
        {
          random_score: {
            seed: @seed
          }
        }
      end

    end
  end
end
