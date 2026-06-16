node.reverse_merge!(
  disable_user: {
    names: ['pi'],
  },
  nana: {
    sudo_nopasswd: true,
  },
  unattended_upgrades: {
    # 既存の apt-listchanges メールと同じ root@dark-kuins.net 宛で届く
    # (postfix virtual_maps が root -> nana -> nna@nna774.net に転送)
    mail: 'root',
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
  /etc/systemd/network/01-lo.network
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

include_cookbook 'sshd' # for ban password auth

include_cookbook 'unattended-upgrades'

package 'ufw'
%w(
  /etc/ufw/user.rules
  /etc/ufw/user6.rules
).each do |f|
  remote_file f do
    owner 'root'
    group 'root'
    mode '644'
    notifies :restart, 'service[ufw]'
  end
end

service 'ufw' do
  action [:start, :enable]
end

include_role 'mail'

%w(
  tmux
  dnsutils
  mtr
).each do |p|
  package p
end
