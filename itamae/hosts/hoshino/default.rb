node.reverse_merge!(
  disable_user: {
    names: ['pi'],
  },
  nana: {
    sudo_nopasswd: true,
  },
)

file '/etc/hostname' do
  owner 'root'
  group 'root'
  mode '644'
  content "hoshino\n"
end

file '/etc/hosts' do
  owner 'root'
  group 'root'
  mode '0644'
  content "127.0.0.1 localhost hoshino\n"
end


service 'dhcpcd' do
  action [:stop, :disable]
end

service 'systemd-networkd' do
  action :enable
end

%w(
  /etc/systemd/network/10-eth0.network
  /etc/systemd/network/23-eth0.50.netdev
  /etc/systemd/network/25-eth0.50.network
).each do |f|
  remote_file f do
    owner 'root'
    group 'root'
    mode '644'
    notifies :restart, 'service[systemd-networkd]'
  end
end

include_cookbook 'nana'
include_cookbook 'disable-users'

package 'ufw'
# ufw conf file

include_role 'mail'
