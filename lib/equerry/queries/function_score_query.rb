module Equerry
  module Queries
    class FunctionScoreQuery

      def self.attributes
        [:filter, :boost, :max_boost, :score_mode, :boost_mode, :min_score]
      end

      attr_reader *attributes

      SCORE_MODES = %w(multiply sum avg first max min)
      BOOST_MODES = %w(multiply replace sum avg max min)

      def initialize(options = {})
        @functions  = Array(options[:functions])
        @query      = options[:query] || MatchAllQuery.new
        
        self.class.attributes.map do |field|
          instance_variable_set("@#{field}", options[field])
        end
        validate
      end

      def validate
        if @query.present? && @filter.present?
          raise ArgumentError.new("Cannot have both query and filter -- combine using a FilteredQuery")
        end

        if @boost.present? && !@boost.is_a?(Numeric)
          raise ArgumentError.new("Boost must be a number - it is the global boost for the whole query")
        end

        if @max_boost.present? && !@max_boost.is_a?(Numeric)
          raise ArgumentError.new("Max boost must be a number")
        end

        if @min_score.present? && !@min_score.is_a?(Numeric)
          raise ArgumentError.new("min_score must be a number - it is the global boost for the whole query")
        end

        if @score_mode.present? && !SCORE_MODES.include?(@score_mode)
          raise ArgumentError.new("Score mode must be one of #{SCORE_MODES.join(', ')}")
        end

        if @boost_mode.present? && !BOOST_MODES.include?(@boost_mode)
          raise ArgumentError.new("Score mode must be one of #{BOOST_MODES.join(', ')}")
        end
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
