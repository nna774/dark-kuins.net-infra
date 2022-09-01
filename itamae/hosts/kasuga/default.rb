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
include_cookbook 'strongswan'

include_cookbook 'slack'
include_cookbook 'aisatsu'

include_cookbook 'mackerel-agent'

%w(less git).each do |p|
  package p
end

file '/etc/sysctl.d/50-ip-forward.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  content "net.ipv4.ip_forward = 1\n"
end

include_role 'internal-dns'

include_role 'dhcp'

include_cookbook 'timezone'
