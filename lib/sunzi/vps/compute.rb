require 'sunzi/vps/compute/base'
require 'sunzi/vps/compute/linode'
require 'sunzi/vps/compute/digital_ocean'

module Sunzi
  module Vps
    class Compute

      def initialize(provider)
        @subject = case provider
        when 'linode'
          Sunzi::Vps::Compute::Linode.new
        when 'digital_ocean'
          Sunzi::Vps::Compute::DigitalOcean.new
        else
          abort_with "Provider #{provider} is not valid!"
        end
      end

      def method_missing(sym, *args, &block)
        @subject.send sym, *args, &block
      end

      def respond_to?(method)
        @subject.respond_to?(sym) || super
      end
    end
  end
end
