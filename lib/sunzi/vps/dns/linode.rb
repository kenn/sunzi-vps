module Sunzi
  module Vps
    class DNS
      class Linode < Base

        def verify
          @domain = client.domain.list.find{|i| i.domain == @zone }
          abort_with "zone for #{@zone} was not found on Linode DNS!" unless @domain
        end

        def add(fqdn, ip)
          say 'adding the public IP to Linode DNS Manager...'
          client.domain.resource.create(:DomainID => @domain.domainid, :Type => 'A', :Name => fqdn, :Target => ip)
        end

        def delete(ip)
          say 'deleting the public IP from Linode DNS Manager...'
          resource = client.domain.resource.list(:DomainID => @domain.domainid).find{|i| i.target == ip }
          abort_with "ip address #{ip} was not found on Linode DNS!" unless resource
          client.domain.resource.delete(:DomainID => @domain.domainid, :ResourceID => resource.resourceid)
        end

      end
    end
  end
end
