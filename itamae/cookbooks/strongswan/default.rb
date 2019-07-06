package 'strongswan-swanctl'
package 'charon-systemd'

if node[:os] == :debian && node[:release] == :stretch
  # for libstrongswan-updown.so
  package 'strongswan-starter'

  link '/etc/systemd/system/strongswan.service' do
    to '/dev/null'
    notifies :run, 'execute[systemctl daemon-reload]'
  end
end

directory '/etc/swanctl/conf.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/swanctl/conf.d/yukari.conf' do
  owner 'root'
  group 'root'
  mode '0400'
  variables(psk: node[:secrets][:tsugu_yukari_psk])
  notifies :restart, 'service[strongswan-swanctl]'
end

service 'strongswan-swanctl'

file '/etc/swanctl/swanctl.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  content "include conf.d/*.conf\n"
  notifies :restart, 'service[strongswan-swanctl]'
end
