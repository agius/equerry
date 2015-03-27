module Equerry
  class QueryBuilder

    include Equerry::Utils::Helpers

    def initialize(offset: 0, limit: 40, match: nil, filters: [], not_filters: [], boosts: [],
                   index:, type:)

      @offest = offset
      @limit = limit
      @match = match
      @filters = filters
      @not_filters = not_filters
      @boosts = boosts
      @type = type
      @index = index
    end

    def clone_with(options)
      options = optionize(options)
      filters = @filters || []
      filters += (options[:filters] || [])
      filters += [options[:filter]] if options[:filter]

      not_filters = @not_filters || []
      not_filters += (options[:not_filters] || [])
      not_filters += [options[:not_filter]] if options[:not_filter]

      boosts = @boosts || []
      boosts += (options[:boosts] || [])
      boosts += [options[:boost]] if options[:boost]

      self.class.new(
        type: @type,
        index: @index,
        offset: options[:offset] || @offset,
        limit: options[:limit] || @limit,
        match: options[:match] || @match,
        filters: filters,
        not_filters: not_filters,
        boosts: boosts
      )
    end

    def offset(num)
      clone_with(offset: num)
    end

    def limit(num)
      clone_with(limit: num)
    end

    def where(options = {})
      return self unless options.present?
      filters = []
      not_filters = []
      options.each do |field, values|
        if values.nil?
          not_filters << Filters::ExistsFilter.new(field)
        elsif values.is_a?(Array)
          filters << Filters::TermsFilter.new(field: field, values: values)
        else
          filters << Filters::TermsFilter.new(field: field, values: [values])
        end
      end
      clone_with(filters: filters, not_filters: not_filters)
    end

    def not_where(options = {})
      return self unless options.present?
      filters = []
      not_filters = []
      options.each do |field, values|
        if values.nil?
          filters << Filters::ExistsFilter.new(field)
        elsif values.is_a?(Array)
          not_filters << Filters::TermsFilter.new(field: field, values: values)
        else
          not_filters << Filters::TermsFilter.new(field: field, values: [values])
        end
      end
      clone_with(not_filters: not_filters, filters: filters)
    end

    def boost_where(options = {})
      return self unless options.present?
      options = optionize(options)
      weight = options.delete(:weight) || 1.2

      boosts = options.map do |field, values|
        filter = nil
        if values.nil?
          filter = Filters::ExistsFilter.new(field)
        elsif values.is_a?(Array)
          filter = Filters::TermsFilter.new(field: field, values: values)
        else
          filter = Filters::TermsFilter.new(field: field, values: [values])
        end
        Boosts::FilterBoost.new(filter: filter, weight: weight)
      end
      clone_with(boosts: boosts)
    end

    def boost_not_where(options = {})
      return self unless options.present?
      options = optionize(options)
      weight = options.delete(:weight) || 1.2

      boosts = []
      options.each do |field, values|
        filter = nil
        if values.nil?
          filter << Filters::ExistsFilter.new(field)
        elsif values.is_a?(Array)
          filter << Filters::TermsFilter.new(field: field, values: values)
        else
          filter << Filters::TermsFilter.new(field: field, values: [values])
        end
        Boosts::FilterBoost.new(filter: NotFilter.new(filter: filter))
      end
      clone_with(boosts: boosts)
    end

    def range(field:, min: nil, max: nil)
      return self unless min.present? || max.present?
      clone_with(filter: Filters::RangeFilter.new(
        field: field,
        min: min,
        max: max
      ))
    end

    def not_range(field:, min: nil, max: nil)
      return self unless min.present? || max.present?
      clone_with(not_filter: Filters::RangeFilter.new(
        field: field,
        min: min,
        max: max
      ))
    end

    def boost_range(field:, min: nil, max: nil, weight: 1.2)
      return self unless min.present? || max.present?
      clone_with(boost: Boosts::Boost.new(
        filter: Filters::RangeFilter.new(
          field: field,
          min: min,
          max: max
        ),
        weight: weight
      ))
    end

    def geo(field: 'coords', distance: '50km', lat:, lng:)
      clone_with(filter: Filters::GeoFilter.new(
        field: field,
        distance: distance,
        lat: lat,
        lng: lng
      ))
    end

    def not_geo(field: 'coords', distance: '50km', lat:, lng:)
      clone_with(not_filter: Filters::GeoFilter.new(
        field: field,
        distance: distance,
        lat: lat,
        lng: lng
      ))
    end

    def boost_geo(field: 'coords', offset: '10km', scale: '50km', lat:, lng:)
      clone_with(boost: Boosts::GeoBoost.new(
        field: field,
        offset: offset,
        scale: scale,
        lat: lat,
        lng: lng
      ))
    end

    def match(string, options = {})
      field = options[:field] || '_all'
      operator = options[:operator] || 'and'
      clone_with(match: Queries::MatchQuery.new(string, field: field, operator: operator))
    end

    def not_match(string, options = {})
      field = options[:field] || '_all'
      operator = options[:operator] || 'and'
      clone_with(not_filter: Filters::QueryFilter.new(
        Queries::MatchQuery.new(string, field: field, operator: operator)
      ))
    end

    def request
      @request ||= RequestBody.new(
        match: @match,
        filters: @filters,
        not_filters: @not_filters,
        boosts: @boosts
      )
    end

    def response
      @response = Equerry.search(type: @type, body: request.to_search)
    end

    def id_response
      @id_response ||= Equerry.search(type: @type, body: request.to_search, fields: [])
      @id_response
    end

    def results
      @results ||= response['hits']['hits'].map do |hit|
        hit['_source'].merge(
          '_id' => hit['_id'],
          '_type' => hit['_type'],
          '_index' => hit['_index']
        )
      end
    end

    def ids
      @ids ||= result_metadata('hits', 'hits').map{ |hit| hit['_id'].to_i == 0 ? hit['_id'] : hit['_id'].to_i }
    end

    def shards
      @shards ||= result_metadata('shards')
    end

    def total
      @total ||= result_metadata('hits', 'total')
    end

    private
      def result_metadata(*args)
        if @response
          args.reduce(@respons){|json, field| json.nil? ? nil : json[field] }
        else
          args.reduce(id_response){|json, field| json.nil? ? nil : json[field] }
        end
      end

  end
end
