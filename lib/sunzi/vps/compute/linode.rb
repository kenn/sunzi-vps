module Sunzi
  module Vps
    class Compute
      class Linode < Base

        def do_up
          @sshkey = File.read(File.expand_path(config.root_sshkey_path)).chomp
          if @sshkey.match(/\n/)
            abort_with "RootSSHKey #{@sshkey.inspect} must not be multi-line! Check inside \"#{config.root_sshkey_path}\""
          end

          choose(:plan, client.avail.linodeplans)
          choose(:datacenter, client.avail.datacenters, :label_method => :location)
          choose(:distribution, client.avail.distributions, :filter => 'distributions_filter')
          choose(:kernel, client.avail.kernels, :filter => 'kernels_filter')

          # Choose swap size
          @swap_size = ask('swap size in MB?', default: 256).to_i

          # Go ahead?
          proceed?

          # Create
          say "creating a new linode..."
          result = client.linode.create(
            :DatacenterID => @attributes[:datacenterid],
            :PlanID => @attributes[:planid],
            :PaymentTerm => config.payment_term)
          @linodeid = result.linodeid
          say "created a new instance: linodeid = #{@linodeid}"

          result = client.linode.list.select{|i| i.linodeid == @linodeid }.first
          @totalhd = result.totalhd

          # Update settings
          say "Updating settings..."
          @group = config.group[@env]
          settings = { :LinodeID => @linodeid, :Label => @name, :lpm_displayGroup => @group }
          settings.update(config.settings) if config.settings
          client.linode.update(settings)

          # Create a root disk
          say "Creating a root disk..."
          result = client.linode.disk.createfromdistribution(
            :LinodeID => @linodeid,
            :DistributionID => @attributes[:distributionid],
            :Label => "#{@attributes[:distribution_label]} Image",
            :Size => @totalhd - @swap_size,
            :rootPass => config.root_pass,
            :rootSSHKey => @sshkey
          )
          @root_diskid = result.diskid

          # Create a swap disk
          say "Creating a swap disk..."
          result = client.linode.disk.create(
            :LinodeID => @linodeid,
            :Label => "#{@swap_size}MB Swap Image",
            :Type => 'swap',
            :Size => @swap_size
          )
          @swap_diskid = result.diskid

          # Create a config profiile
          say "Creating a config profile..."
          result = client.linode.config.create(
            :LinodeID => @linodeid,
            :KernelID => @attributes[:kernelid],
            :Label => "#{@attributes[:distribution_label]} Profile",
            :DiskList => [ @root_diskid, @swap_diskid ].join(',')
          )
          @config_id = result.configid

          # Add a private IP
          say "Adding a private IP..."
          result = client.linode.ip.list(:LinodeID => @linodeid)
          public_ip = result.first.ipaddress
          result = client.linode.ip.addprivate(:LinodeID => @linodeid)
          result = client.linode.ip.list(:LinodeID => @linodeid).find{|i| i.ispublic == 0 }
          @private_ip = result.ipaddress

          @instance = {
            :linode_id => @linodeid,
            :env => @env,
            :host => @host,
            :fqdn => @fqdn,
            :label => @name,
            :group => @group,
            :plan_id =>             @attributes[:planid],
            :datacenter_id =>       @attributes[:datacenterid],
            :datacenter_location => @attributes[:datacenter_location],
            :distribution_id =>     @attributes[:distributionid],
            :distribution_label =>  @attributes[:distribution_label],
            :kernel_id =>           @attributes[:kernelid],
            :kernel_label =>        @attributes[:kernel_label],
            :swap_size => @swap_size,
            :totalhd => @totalhd,
            :root_diskid => @root_diskid,
            :swap_diskid => @swap_diskid,
            :config_id => @config_id,
            :public_ip => public_ip,
            :private_ip => @private_ip,
          }

          # Boot
          say 'Done. Booting...'
          client.linode.boot(:LinodeID => @linodeid)
        end

        def choose(key, result, options = {})
          label_method = options[:label_method] || :label
          id    = :"#{key}id"
          label = :"#{key}_#{label_method}"

          # Filters
          if options[:filter] and config[options[:filter]]
            result = result.select{|i| i.label.match Regexp.new(config[options[:filter]], Regexp::IGNORECASE) }
          end

          result.each{|i| say "#{i.send(id)}: #{i.send(label_method)}" }
          @attributes[id] = ask("which #{key}?", limited_to: result.map(&id).map(&:to_s), default: result.first.send(id).to_s).to_i
          @attributes[label] = result.find{|i| i.send(id) == @attributes[id] }.send(label_method)
        end

        def do_down
          @linode_id_hash = { :LinodeID => @instance[:linode_id] }

          # Shutdown first or disk deletion will fail
          say 'shutting down...'
          client.linode.shutdown(@linode_id_hash)
          # Wait until linode.shutdown has completed
          wait_for('linode.shutdown')

          # Delete the instance
          say 'deleting linode...'
          client.linode.delete(@linode_id_hash.merge(:skipChecks => 1))
        end

        def wait_for(action)
          begin
            sleep 3
          end until client.linode.job.list(@linode_id_hash).find{|i| i.action == action }.host_success == 1
        end
      end
    end
  end
end
