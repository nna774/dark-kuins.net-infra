# sudo rsync wget をmitamaeの前に手で入れる必要がある。

node.reverse_merge!({
  pacman_myrepo: {
    arch: 'aarch64'
  },
  nana: {
    sudo_nopasswd: true,
  },
  disable_user: {
    names: [
      'alarm',
    ],
  },
  sshd: {
    allow_users: [
      'nana',
    ],
  },
  hostname: 'sumi.border.kitashirakawa.dark-kuins.net',
})

%w(
dnsutils
).each do |p|
  package p
end

file '/etc/systemd/network/eth.network' do
  action :delete
end

%w(
/etc/systemd/network/10-eth0.network
/etc/systemd/network/20-eth0.5.netdev
/etc/systemd/network/25-eth0.5.network
).each do |f|
  remote_file f do
    owner 'root'
    group 'root'
    mode '644'
  end
end

include_cookbook 'pacman-myrepo'

package 'conserver'
%w(
/etc/conserver
/var/log/conserver
).each do |d|
  directory d do
    owner 'root'
    group 'root'
    mode '755'
  end
end

%w(
/etc/conserver/conserver.cf
/etc/systemd/system/conserver.service
).each do |f|
  remote_file f do
    owner 'root'
    group 'root'
    mode '644'
  end
end

service 'conserver' do
  action [:start, :enable]
end

remote_file '/etc/hosts' do
  owner 'root'
  group 'root'
  mode '644'
end

include_cookbook 'nana'
include_cookbook 'disable-users'
include_cookbook 'sshd'
include_cookbook 'hostname'
