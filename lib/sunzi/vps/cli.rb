require 'sunzi/vps/init'
require 'sunzi/vps/compute'
require 'sunzi/vps/dns'

module Sunzi
  module Vps
    class Cli < Thor

      desc 'init [provider]', 'Generate VPS config file (provider: linode, digital_ocean)'
      def init(provider)
        Sunzi::Vps::Init.new.run(provider)
      end

      desc 'up [provider]', 'Set up a new instance (provider: linode, digital_ocean)'
      def up(provider)
        Sunzi::Vps::Compute.new(provider).up
      end

      desc 'down [provider]', 'Tear down an existing instance (provider: linode, digital_ocean)'
      def down(provider)
        Sunzi::Vps::Compute.new(provider).down
      end

    end
  end
end
