module Equerry
  module Utils
    module Contract

      def contract(*args)
        @contracts ||= []
        
        if Array(args).length > 1
          ivar, spec = *args
          @contracts << [ivar, spec]
        end

        options = args.last
        if options.is_a?(Hash)
          options.each do |ivar, spec|
            @contracts << [ivar, spec]
          end
        end
      end

      def validate(obj)
        Array(@contracts).each do |ivar, spec|
          var = obj.instance_variable_get("@#{ivar}")
          
          case spec
          when Proc
            success = obj.instance_exec(&spec)
            raise "Contract for #{ivar} failed: #{success}" unless success === true
          when Class, Module
            raise "Argument #{ivar} is not of type #{spec}" unless var.is_a?(spec)
          when Enumerable
            if spec.count == 1 && (spec.first.is_a?(Class) || spec.first.is_a?(Module))
              spec = spec.first
              raise "Argument #{ivar} must be an array of #{spec}" unless var.all?{|v| v.is_a?(spec) }
            elsif spec.all?{|s| s.is_a?(Class) || s.is_a?(Module) }
              raise "Argument #{ivar} must be one of #{spec}" unless var.all?{|v| spec.any?{|s| v.is_a?(s)} }
            else
              raise "Argument #{ivar} must be one of #{spec}" unless spec.include?(var)
            end
          else
            if spec.respond_to?(:eql?)
              raise "Argument #{ivar} does not match #{spec}" unless var.eql?(spec)
            else
              raise "Argument #{ivar} does not match #{spec}" unless var == spec
            end
          end
        end
      end

    end
  end
end