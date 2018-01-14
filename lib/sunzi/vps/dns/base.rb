module Sunzi
  module Vps
    class DNS
      class Base
        include Sunzi::Actions::Delegate

        delegate_to_thor :say
      end
    end
  end
end
