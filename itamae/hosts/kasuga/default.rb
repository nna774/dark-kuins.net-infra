node.reverse_merge!({
  hostname: 'kasuga.compute.nakanoshima.dark-kuins.net',
  os: :debian,
  strongswan: {
    profiles: [
      { name: 'kasuga-yukari.conf', psk: node[:secrets][:kasuga_yukari_psk] },
    ],
  },
  internal_dns: {
    self_search: 'compute.nakanoshima.dark-kuins.net nakanoshima.dark-kuins.net',
    forward_addr: '169.254.169.254',
  },
  dhcp: {
    role: :slave,
    interfacesv4: 'ens4',
  },
})

file '/etc/hosts' do
  owner 'root'
  group 'root'
  mode '0644'
  content <<~EOS
    127.0.0.1 localhost
    127.0.0.1 kasuga.compute.nakanoshima.dark-kuins.net kasuga

    # The following lines are desirable for IPv6 capable hosts
    ::1 ip6-localhost ip6-loopback
    fe00::0 ip6-localnet
    ff00::0 ip6-mcastprefix
    ff02::1 ip6-allnodes
    ff02::2 ip6-allrouters
    ff02::3 ip6-allhosts
    169.254.169.254 metadata.google.internal metadata
  EOS
end

include_cookbook 'strongswan'

include_cookbook 'slack'
include_cookbook 'aisatsu'

include_cookbook 'mackerel-agent'

%w(less git).each do |p|
  package p
end

# /etc/sysctl.d/60-gce-network-security.conf があるので、60より後でする必要がある。
file '/etc/sysctl.d/70-ip-forward.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  content "net.ipv4.ip_forward = 1\n"
end

include_role 'internal-dns'

include_role 'dhcp'

include_cookbook 'timezone'
