node.reverse_merge!({
  hostname: 'kasuga.compute.nakanoshima.dark-kuins.net',
  os: :debian,
  strongswan: {
    profiles: [
      { name: 'kasuga-yukari.conf', psk: node[:secrets][:kasuga_yukari_psk] },
    ],
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
