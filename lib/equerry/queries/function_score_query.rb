module Equerry
  module Queries
    class FunctionScoreQuery

      SCORE_MODES = %w(multiply sum avg first max min)
      BOOST_MODES = %w(multiply replace sum avg max min)

      def initialize(functions: [], query: nil, filter: nil, boost: nil,
                     max_boost: nil, score_mode: nil, boost_mode: nil,
                     min_score: nil)
        @functions = functions
        @query = query
        @filter = filter
        @boost = boost
        @max_boost = max_boost
        @score_mode = score_mode
        @boost_mode = boost_mode
        @min_score = min_score
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
        json[:functions] = @functions.map(&:to_search)
        json[:query] = @query.to_search if @query.present?
        json[:filter] = @filter.to_search if @filter.present?
        json[:boost] = @boost if @boost.present?
        json[:max_boost] = @max_boost if @max_boost.present?
        json[:score_mode] = @score_mode if @score_mode.present?
        json[:boost_mode] = @boost_mode if @boost_mode.present?
        json[:min_score] = @min_score if @min_score.present?
        { function_score: json }
      end
    end
  end
end
