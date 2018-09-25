# sudo rsync wget をmitamaeの前に手で入れる必要がある。

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

node.merge!({
  pacman_myrepo: {
    arch: 'aarch64'
  },
})
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

node.merge!({
  nana: {
    sudo_nopasswd: true,
  },
})
include_cookbook 'nana'

node.merge!({
  disable_user: {
    names: [
      'alarm',
    ],
  },
})
include_cookbook 'disable-users'

node.merge!({
  sshd: {
    allow_users: [
      'nana',
    ],
  },
})
include_cookbook 'sshd'
