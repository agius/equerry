module Equerry
  module Queries
    class FunctionScoreQuery
      extend Equerry::Utils::Contract

      SCORE_MODES = %w(multiply sum avg first max min)
      BOOST_MODES = %w(multiply replace sum avg max min)

      def self.attributes
        [:filter, :boost, :max_boost, :score_mode, :boost_mode, :min_score]
      end

      attr_reader *attributes

      contract Hash[
        boost: Numeric,
        max_boost: Numeric,
        min_score: Numeric,
        score_mode: SCORE_MODES,
        boost_mode: BOOST_MODES,
        query: Proc.new {
          (@query.nil? || @filter.nil?) ? true : "Cannot have both query and filter - combine using a FilteredQuery"
        }
      ]

      def initialize(options = {})
        @functions  = Array(options[:functions])
        @query      = options[:query] || MatchAllQuery.new
        
        self.class.attributes.map do |field|
          instance_variable_set("@#{field}", options[field])
        end
        validate
      end

      def to_search
        json = {}
        json[:functions]  = @functions.map(&:to_search)
        json[:query]      = @query.to_search

        self.class.attributes.reduce(json) do |body, field|
          ivar = instance_variable_get("@#{field}")
          body[field] = ivar if ivar.present?
          body
        end

        { function_score: json }
      end
    end
  end
end
