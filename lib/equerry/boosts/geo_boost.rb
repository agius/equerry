module Equerry
  module Boosts
    class GeoBoost

      def initialize(field: 'coords', offset: '10km', scale: '50km', lat:, lng:)
        @field = field
        @offset = offset
        @scale = scale
        @lat = lat
        @lng = lng
      end

      def to_search
        {
          gauss: {
            @field => {
              origin: { lat: @lat, lon: @lng },
              offset: @offset,
              scale: @scale
            }
          }
        }
      end
    end
  end
end
