module Equerry
  class RequestBuilder

    def initialize(
        match: nil,
        filters: nil,
        not_filters: nil,
        boosts: nil,
        offset: 0,
        limit: 40
      )

      @json = {}
      @match = match
      @filters = filters
      @not_filters = not_filters
      @boosts = boosts
      @offset = offset
      @limit = limit
    end

    def to_search
      return @json if @json.present?
      query = Queries::MatchAllQuery.new
      query = @match if @match.present?

      if @filters.present? && @not_filters.present?
        query = Queries::FilteredQuery.new(
          query: query,
          filter: Filters::BoolFilter.new(
            must: @filters,
            must_not: @not_filters
          )
        )
      elsif @filters.present?
        if @filters.count == 1
          query = Queries::FilteredQuery.new(
            query: query,
            filter: @filters.first
          )
        else
          query = Queries::FilteredQuery.new(
            query: query,
            filter: Filters::AndFilter.new(@filters)
          )
        end
      elsif @not_filters.present?
        query = Queries::FilteredQuery.new(
          query: query,
          filter: Filters::NotFilter.new(@not_filters)
        )
      end

      if @boosts.present?
        query = Queries::FunctionScoreQuery.new(
          query: query,
          functions: @boosts,
          score_mode: 'sum',
          boost_mode: 'sum'
        )
      end

      @json = { query: query.to_search, from: @offset, size: @limit }
      Equerry.logger.debug("Generated elastic query: #{JSON.pretty_generate(@json)}")
      @json
    end
  end
end
