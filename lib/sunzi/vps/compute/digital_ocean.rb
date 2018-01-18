module Sunzi
  module Vps
    class Compute
      class DigitalOcean < Base

        def do_up
          choose(:size, client.sizes.all.to_a)
          choose(:region, client.regions.all.to_a)

          # Choose an image
          result = client.images.all
          if config.distributions_filter
            result = result.select{|i| i.distribution.match Regexp.new(config.distributions_filter, Regexp::IGNORECASE) }
          end
          choose(:image, result)

          # Go ahead?
          proceed?

          ssh_keys = client.ssh_keys.all.map(&:fingerprint)

          # Create
          say "creating a new droplets..."
          droplet = client.droplets.create(
            DropletKit::Droplet.new(
              name: @name,
              size: @attributes[:size],
              image: @attributes[:image],
              region: @attributes[:region],
              ssh_keys: ssh_keys
            )
          )

          @droplet_id = droplet.id
          say "Created a new droplet (id: #{@droplet_id}). Booting..."

          # Boot - we need this before getting public IP
          while droplet.status.downcase != 'active'
            sleep 3
            droplet = client.droplets.find(id: @droplet_id)
          end

          @public_ip = droplet.networks.v4.first.ip_address
          say "Done. ip address = #{@public_ip}"

          @instance = {
            droplet_id: @droplet_id,
            env:  @env,
            host: @host,
            fqdn: @fqdn,
            name: @name,
            ip_address: @public_ip,
            size:       @attributes[:size],
            region:     @attributes[:region],
            image:      @attributes[:image],
          }
        end

        def choose(key, result)
          abort "no #{key} found!" if result.first.nil?

          rows = result.map(&:attributes).map do |h|
            h.values.map do |v|
              next v unless v.is_a?(Array)
              if v.size > 5
                v.first(5).join(', ') + ', ...'
              else
                v.join(', ')
              end
            end
          end

          table = Terminal::Table.new headings: result.first.attributes.keys, rows: rows
          say table

          @attributes[key] = ask("which #{key}?: ", default: result.first.slug, limited_to: result.map(&:slug))
        end

        def do_down
          say 'deleting droplet...'
          client.droplets.delete(id: @instance[:droplet_id])
        end

        def ip_key
          :ip_address
        end
      end
    end
  end
end
