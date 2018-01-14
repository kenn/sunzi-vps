require 'sunzi'
require 'sunzi/vps/dependency'
require 'sunzi/vps/cli'

module Sunzi
  class Cli
    desc 'vps [COMMANDS]', 'VPS related commands'
    subcommand 'vps', Sunzi::Vps::Cli
  end
end
