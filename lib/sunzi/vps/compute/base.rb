module Sunzi
  module Vps
    class Compute
      class Base
        include Sunzi::Utility
        include Sunzi::Actions::Delegate

        delegate_to_thor :empty_directory, :template, :create_file, :remove_file, :say

        def up
          if config.fqdn.zone == 'example.com'
            abort_with "You must have your own settings in #{@provider}.yml"
          end

          # Ask environment and hostname
          @env = ask("environment?", limited_to: config.environments, default: 'production')
          @host = ask('hostname? (only the first part of subdomain): ')

          abort_with '"label" field in linode.yml is no longer supported. rename it to "name".' if config.label
          @fqdn = config.fqdn.send(@env).gsub(/%{host}/, @host)
          @name = config.name.send(@env).gsub(/%{host}/, @host)
          abort_with "#{@name} already exists!" if instance_config_path.exist?

          assign_api
          @attributes = {}
          do_up

          # Save instance info
          create_file instance_config_path, YAML.dump(@instance)

          # Register IP to DNS
          dns.add(@fqdn, @public_ip) if config.dns
        end

        def down
          names = Dir.glob("#{@provider}/instances/*.yml").map{|i| i.split('/').last.sub('.yml','') }
          abort_with "No match found with #{@provider}/instances/*.yml" if names.empty?

          names.each{|i| say i }
          @name = ask('which instance?', limited_to: names)

          @instance = YAML.load(instance_config_path.read).to_hashugar

          # Are you sure?
          moveon = ask("Are you sure about deleting #{@instance.fqdn} permanently? (y/n)", limited_to: ['y','n'])
          exit unless moveon == 'y'

          # Run Linode / DigitalOcean specific tasks
          assign_api
          do_down

          # Delete DNS record
          dns.delete @instance.send(ip_key) if config.dns

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

        def provider_config_path
          Pathname.new "#{@provider}/#{@provider}.yml"
        end

        def instance_config_path
          Pathname.new "#{@provider}/instances/#{@name}.yml"
        end

        def config
          @config ||= YAML.load(provider_config_path.read).to_hashugar
        end

        def dns
          @dns ||= Sunzi::DNS.new(config, @provider) if config.dns
        end

      end
    end
  end
end
