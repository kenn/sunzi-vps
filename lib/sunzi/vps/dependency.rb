module Sunzi
  module Vps
    class Dependency
      [
        ['linode', '~> 0.7'],
        ['droplet_kit', '~> 2.2'],
      ].each do |name, version|
        Sunzi::Dependency.new(name, version)
      end
    end
  end
end
