module Sunzi
  module Vps
    class DNS
      class Base
        include Sunzi::Actions::Delegate

        delegate_to_thor :say

        attr_reader :api

        def initialize(api)
          @api = api
          @zone = api.config.fqdn.zone
        end

        def client
          api.client
        end
      end
    end
  end
end
