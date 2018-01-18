require 'sunzi/vps/init'
require 'sunzi/vps/api'

module Sunzi
  module Vps
    class Cli < Thor

      desc 'init [provider]', 'Generate VPS config file (provider: linode, digital_ocean)'
      def init(provider)
        Sunzi::Vps::Init.new.run(provider)
      end

      desc 'up [provider]', 'Set up a new instance (provider: linode, digital_ocean)'
      def up(provider)
        api = Sunzi::Vps::Api.new(provider)
        api.compute.up
      end

      desc 'down [provider]', 'Tear down an existing instance (provider: linode, digital_ocean)'
      def down(provider)
        api = Sunzi::Vps::Api.new(provider)
        api.compute.down
      end

    end
  end
end
