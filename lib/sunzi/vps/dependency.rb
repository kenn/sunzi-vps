module Sunzi
  module Vps
    class Dependency
      [
        ['linode', '~> 0.7'],
        ['route53', '~> 1.6'],
        ['digital_ocean', '~> 1.0'],
      ].each do |name, version|
        Sunzi::Dependency.new(name, version)
      end
    end
  end
end
