module Sunzi
  module Vps
    class DNS
      class Base
        include Sunzi::Utility
        include Sunzi::Actions::Delegate

        delegate_to_thor :say
      end
    end
  end
end
