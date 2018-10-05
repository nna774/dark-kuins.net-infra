package 'strongswan-swanctl'
package 'charon-systemd'

template '/etc/swanctl/conf.d/tsugu.conf' do
  owner 'root'
  group 'root'
  mode '0400'
  variables(psk: node[:secrets][:tsugu_kizuna_psk])
  notifies :restart, 'service[strongswan-swanctl]'
end

service 'strongswan-swanctl'
