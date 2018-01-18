# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'sunzi-vps'
  spec.version       = '0.1.0' # retrieve this value by: Gem.loaded_specs['sunzi'].version.to_s
  spec.authors       = ['Kenn Ejima']
  spec.email         = ['kenn.ejima@gmail.com']
  spec.summary       = %q{Sunzi VPS}
  spec.description   = %q{Simple CLI to create and/or destroy VPS instances}
  spec.homepage      = 'https://github.com/kenn/sunzi-vps'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'sunzi', '~> 2.0'
  spec.add_dependency 'hashugar', '~> 1.0'
  spec.add_dependency 'terminal-table', '~> 1.8'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'vcr', '~> 4.0'
  spec.add_development_dependency 'webmock', '~> 3.2'
  spec.add_development_dependency 'linode', '~> 0.7'
  spec.add_development_dependency 'droplet_kit', '~> 2.2'
end
