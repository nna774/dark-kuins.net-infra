node.reverse_merge!({
  nana: {
    sudo_nopasswd: true,
  },
  disable_user: {
    names: [
      'ubuntu',
    ],
  },
  sshd: {
    allow_users: [
      'nana',
    ],
  },
  hostname: 'tsugu.compute.nishiogikubo.dark-kuins.net',
  os: :ubuntu,
  nginx: {
    dhparam_user: 'root',
  },
  rproxy: {
    canonical: 'tsugu.compute.nishiogikubo.dark-kuins.net',
    alts: [
      'grafana.dark-kuins.net',
    ],
  },
  strongswan: {
    profiles: [
      { name: 'yukari.conf', psk: node[:secrets][:tsugu_yukari_psk] },
      { name: 'noja.conf', psk: node[:secrets][:tsugu_noja_psk] },
    ],
  },
  internal_dns: {
    self_search: 'compute.nishiogikubo.dark-kuins.net nishiogikubo.dark-kuins.net',
    forward_addr: '169.254.169.253',
  },
})
include_cookbook 'nana'
include_cookbook 'disable-users'
include_cookbook 'sshd'
include_cookbook 'hostname'
include_cookbook 'cloud-init'
include_cookbook 'strongswan'

%w(
/etc/sysctl.d/20-ipv4.ip_forward.conf
/etc/systemd/network/15-ens6.network
).each do |f|
  remote_file f do
    owner 'root'
    group 'root'
    mode '0644'
  end
end

include_role 'internal-dns'

include_role 'td-agent-aggregate'

include_cookbook 'postfix'
directory '/etc/postfix/' do
  owner 'root'
  group 'root'
  mode '755'
  notifies 'service[postfix]', :restart
end
remote_file '/etc/postfix/main.cf' do
  owner 'root'
  group 'root'
  mode '644'
  notifies 'service[postfix]', :restart
end

include_cookbook 'iptables'

include_cookbook 'slack'
include_cookbook 'aisatsu'

include_role 'prometheus'

include_role 'rproxy'

include_cookbook 'mackerel-agent'
