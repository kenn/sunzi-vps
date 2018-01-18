module Sunzi
  module Vps
    Mapping = {
      linode: {
        gem: 'linode',
        klass: 'Linode',
      },
      digital_ocean: {
        gem: 'droplet_kit',
        klass: 'DigitalOcean',
      },
    }.freeze
  end
end
