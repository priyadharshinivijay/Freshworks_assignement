def get_command_line_argument
    if ARGV.empty?
        puts "Usage: ruby lookup.rb <domain>"
        exit
    end
    ARGV.first    
end

def parse_dns(dns_raw)
    h1={}
    h1["A"]={}
    h1["CNAME"]={}
    dns_raw.each do |dns|
        if dns[0]=="A"
            h1["A"][dns[1]]=dns[2]
        elsif dns[0]=="CNAME"
            h1["CNAME"][dns[1]]=dns[2]
        end
    end
    return h1
end

def resolve(dns_records,lookup_chain,domain)
    if dns_records["A"][domain]!=nil
        return lookup_chain<<dns_records["A"][domain]
    end
    if(dns_records["CNAME"][domain]!=nil)
    
        lookup_chain<<dns_records["CNAME"][domain]
        resolve(dns_records,lookup_chain,dns_records["CNAME"][domain])
    else
        lookup_chain<<"Domain not found"
    end
end

domain=get_command_line_argument()
dns_raw=File.readlines("zone.txt")[1..]
dns_raw=dns_raw.map {|d| d.split(",")}
dns_raw.each do |dns|
    dns.each do |d|
        d.strip!
    end
end

dns_records=parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")