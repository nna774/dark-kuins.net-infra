package 'isc-dhcp-server'

service 'isc-dhcp-server'

if node[:dhcp][:role] == :master
  master = true
elsif node[:dhcp][:role] == :slave
  master = false
else
  raise 'need node[:dhcp][:role] :master/:slave'
end

node[:dhcp][:nets] = data_bag('dhcp')['nets']

%w(
/etc/default/isc-dhcp-server
/etc/dhcp/dhcpd.conf
).each do |file|
  template file do
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[isc-dhcp-server]'
    variables({
      nets: node[:dhcp][:nets],
      master: master,
    })
  end
end
