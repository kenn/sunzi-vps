module Sunzi
  module Vps
    class DNS
      class DigitalOcean < Base

        def verify
          @domain = client.domains.find(name: @zone)
        rescue DropletKit::Error => e
          abort_with "zone for #{@zone} was not found on DigitalOcean DNS!" if e.message =~ /not_found/
          raise
        end

        def add(fqdn, ip)
          say 'adding the public IP to DigitalOcean DNS...'
          client.domain_records.create(
            DropletKit::DomainRecord.new(
              type: 'A',
              name: fqdn.sub('.' + @domain.name, ''),
              data: ip,
            ),
            for_domain: @domain.name
          )
        end

        def delete(ip)
          say 'deleting the public IP from DigitalOcean DNS...'
          domain_record = client.domain_records.all(for_domain: @domain.name).find{|i| i.type == 'A' && i.data == ip }
          abort_with "ip address #{ip} was not found on DigitalOcean DNS!" unless domain_record
          client.domain_records.delete(id: domain_record.id, for_domain: @domain.name)
        end

      end
    end
  end
end
