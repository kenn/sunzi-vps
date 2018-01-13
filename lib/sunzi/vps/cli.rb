module Sunzi
  module Vps
    class Cli < Thor

      desc 'init', 'init'
      def init(provider)
        Sunzi::Vps::Init.new.run(provider)
      end

      desc 'create', 'create'
      def create(provider)
        Sunzi::Vps::Compute.new(provider).setup
      end

      desc 'destroy', 'destroy'
      def destroy(provider)
        Sunzi::Vps::Compute.new(provider).teardown
      end

    end
  end
end
