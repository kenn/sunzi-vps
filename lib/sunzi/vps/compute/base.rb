module Sunzi
  module Vps
    class Compute
      class Base
        include Sunzi::Actions::Delegate

        delegate_to_thor :empty_directory, :template, :create_file, :remove_file, :say

        attr_reader :api

        def initialize(api)
          @api = api
          api.dns.verify # fail early if domain is not registered
        end

        def up
          if config.api_key == 'your_api_key'
            abort_with "You must have your own settings in #{api.provider}.yml"
          end

          # Ask environment and hostname
          @env = ask("environment?", limited_to: config.environments, default: 'production')
          @host = ask('hostname? (only the first part of subdomain): ')

          abort_with '"label" field in linode.yml is no longer supported. rename it to "name".' if config.label
          @fqdn = config.fqdn.send(@env).gsub(/%{host}/, @host)
          @name = config.name.send(@env).gsub(/%{host}/, @host)
          abort_with "#{@name} already exists!" if instance_config_path.exist?

          @attributes = {}

          # Run Linode / DigitalOcean specific tasks
          do_up

          # Save instance info
          create_file instance_config_path, YAML.dump(@instance)

          # Register IP to DNS
          api.dns.add(@fqdn, @instance[:public_ip])
        end

        def down
          names = Dir.glob("#{api.provider}/instances/*.yml").map{|i| i.split('/').last.sub('.yml','') }
          abort_with "No match found with #{api.provider}/instances/*.yml" if names.empty?

          names.each{|i| say i }
          @name = ask('which instance?', limited_to: names)

          @instance = YAML.load(instance_config_path.read).to_hashugar

          # Are you sure?
          moveon = ask("Are you sure about deleting #{@instance.fqdn} permanently? (y/n)", limited_to: ['y','n'])
          exit unless moveon == 'y'

          # Run Linode / DigitalOcean specific tasks
          do_down

          # Delete DNS record
          api.dns.delete @instance.public_ip

          # Remove the instance config file
          remove_file instance_config_path

          say 'Done.'
        end

        def ask(statement, *args)
          Sunzi.thor.ask statement.color(:green).bright, *args
        end

        def proceed?
          moveon = ask("Are you ready to go ahead and create #{@fqdn}? (y/n)", limited_to: ['y','n'])
          exit unless moveon == 'y'
        end

      private

        def instance_config_path
          Pathname.new "#{api.provider}/instances/#{@name}.yml"
        end

        def config
          api.config
        end

        def client
          @api.client
        end

      end
    end
  end
end
