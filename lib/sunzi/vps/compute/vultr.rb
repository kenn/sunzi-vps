module Sunzi
  module Vps
    class Compute
      class Vultr < Base

        def do_up
          result = choose(:plan, client::Plans.list)
          choose(:region, client::Regions.list, ids: result['available_locations'])

          # Choose an image
          result = client::OS.list
          if config.distributions_filter
            result[:result].reject!{|id, hash| hash['name'] !~ Regexp.new(config.distributions_filter, Regexp::IGNORECASE) }
          end
          choose(:os, result)

          # Go ahead?
          proceed?

          # Create
          say 'creating a new instance...'
          result = client::Server.create(
            label: @name,
            DCID: @attributes[:region],
            VPSPLANID: @attributes[:plan],
            OSID: @attributes[:os]
          )

          subid = result[:result]['SUBID']

          say "Created a new instance (id: #{subid}). Booting..."

          begin
            sleep 3
            result = client::Server.list_ipv4(SUBID: subid)
            public_ip = result[:result][subid].first['ip']
          end while public_ip == '0.0.0.0'

          say "Done. ip address = #{public_ip}"

          @instance = {
            subid: subid,
            env:  @env,
            host: @host,
            fqdn: @fqdn,
            name: @name,
            public_ip:  public_ip,
            plan:       @attributes[:plan],
            region:     @attributes[:region],
            os:         @attributes[:os],
          }

        end

        def choose(key, result, ids: nil)
          abort "API returned for #{key}!" if result[:status] != 200
          result = result[:result].map{|id,hash| hash.merge(id: id) }

          # Filter out items not included in ids
          if ids
            ids = ids.map(&:to_s)
            result.reject!{|h| !ids.include?(h[:id].to_s) }
          end

          rows = result.map do |h|
            h.values.map do |v|
              next v unless v.is_a?(Array)
              if v.size > 5
                v.first(5).join(', ') + ', ...'
              else
                v.join(', ')
              end
            end
          end

          table = Terminal::Table.new headings: result.first.keys, rows: rows
          say table

          @attributes[key] = ask("which #{key}?: ", default: result.first[:id], limited_to: result.map{|i| i[:id] })
          result.find{|i| i[:id].to_s == @attributes[key] }
        end

        def do_down
          say 'deleting instance...'
          result = client::Server.destroy(SUBID: @instance[:subid])
          abort result[:result] if result[:status] != 200
        end
      end
    end
  end
end
