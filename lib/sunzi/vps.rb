require 'highline'

require 'sunzi'
require 'sunzi/vps/dependency'
require 'sunzi/vps/cli'
require 'sunzi/vps/compute'
require 'sunzi/vps/dns'

module Sunzi
  class Cli
    desc 'vps [COMMANDS]', 'VPS related commands'
    subcommand 'vps', Sunzi::Vps::Cli
  end
end
