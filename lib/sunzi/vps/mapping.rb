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
      vultr: {
        gem: 'vultr',
        klass: 'Vultr',
      },
    }.freeze
  end
end
