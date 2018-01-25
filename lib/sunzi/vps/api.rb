require 'sunzi/vps/mapping'

require 'sunzi/vps/compute/base'
require 'sunzi/vps/compute/linode'
require 'sunzi/vps/compute/digital_ocean'
require 'sunzi/vps/compute/vultr'

require 'sunzi/vps/dns/base'
require 'sunzi/vps/dns/linode'
require 'sunzi/vps/dns/digital_ocean'
require 'sunzi/vps/dns/vultr'

module Sunzi
  module Vps
    class Api
      attr_reader :provider

      def initialize(provider)
        @provider = provider
        Sunzi::Dependency.load(mapping[:gem])
      end

      def client
        @client ||= begin
          case provider
          when 'linode'
            ::Linode.new(api_key: config.api_key)
          when 'digital_ocean'
            DropletKit::Client.new(access_token: config.api_key)
          when 'vultr'
            Vultr.api_key = config.api_key
            Vultr
          end
        end
      end

      def config
        @config ||= YAML.load(File.read("#{provider}/#{provider}.yml")).to_hashugar
      end

      def compute
        @compute ||= Object.const_get("Sunzi::Vps::Compute::#{mapping[:klass]}").new(self)
      end

      def dns
        @dns ||= Object.const_get("Sunzi::Vps::DNS::#{mapping[:klass]}").new(self)
      end

    private

      def mapping
        @mapping ||= Mapping.fetch(provider.to_sym)
      end
    end
  end
end
