module Equerry
  module Filters
    class GeoFilter
      def initialize(field: 'coords', distance: '50km', lat:, lng:)
        @field = field
        @distance = distance
        @lat = lat
        @lng = lng
      end

      def to_search
        {
          geo_distance: {
            distance: @distance,
            @field => {
              lat: @lat,
              lon: @lng
            }
          }
        }
      end
    end
  end
end
