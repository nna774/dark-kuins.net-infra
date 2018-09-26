package 'strongswan'

template '/etc/ipsec.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[strongswan]'
end

template '/etc/ipsec.secrets' do
  owner 'root'
  group 'root'
  mode '0400'
  variables(psk: node[:secrets][:tsugu_kizuna_psk])
  notifies :restart, 'service[strongswan]'
end

service 'strongswan'
