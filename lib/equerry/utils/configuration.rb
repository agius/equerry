module Equerry
  module Utils
    module Configuration

      def configure(options = {})
        @default_index  = options[:default_index]
        @default_type   = options[:default_type]
        @logger         = options[:logger]
        yield self if block_given?
      end

      def default_index
        @default_index
      end

      def default_index=(_default_index)
        @default_index = _default_index
      end

      def default_type
        @default_type
      end

      def default_type=(_default_type)
        @default_type = _default_type
      end

      def logger
        @logger
      end

      def logger=(_logger)
        @logger = _logger
      end

      def deconfigure
        @default_index = nil
        @default_type  = nil
        @logger        = nil
      end 

    end
  end
end