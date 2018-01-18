require 'terminal-table'

require 'sunzi'
require 'sunzi/vps/dependency'
require 'sunzi/vps/cli'

module Sunzi
  class Cli
    desc 'vps [...]', 'VPS setup/teardown commands'
    subcommand 'vps', Sunzi::Vps::Cli
  end
end
