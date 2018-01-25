module Sunzi
  module Vps
    class DNS
      class Vultr < Base

        def verify
          result = client::DNS.list
          domain = result[:result].find{|h| h['domain'] == @zone }
          abort_with "zone for #{@zone} was not found on Vultr DNS!" unless domain
        end

        def add(fqdn, ip)
          say 'adding the public IP to Vultr DNS...'
          client::DNS.create_record(domain: @zone, name: fqdn.sub('.' + @zone, ''), type: 'A', data: ip)
        end

        def delete(ip)
          say 'deleting the public IP from Vultr DNS...'

          result = client::DNS.records(domain: @zone)
          hash = result[:result].find{|i| i['type'] == 'A' && i['data'] == ip }

          abort_with "ip address #{ip} was not found on Vultr DNS!" unless hash['RECORDID']

          client::DNS.delete_record(domain: @zone, RECORDID: hash['RECORDID'])
        end

      end
    end
  end
end
