node.reverse_merge!({
  ebgp_router: {
    id: '192.50.220.191',
    as: 64777,
    local: {
      v4: '192.50.220.191',
      v6: '2001:df0:8500:a717::1',
    },
  },
})

# シリアルで入れないのはデバッグに不便なので入れるようにする。
remote_file '/etc/default/grub' do
  owner 'root'
  group 'root'
  mode '644'
  notifies :run, 'execute[update-grub]'
end

## hoshinoからのコピペだけど、名前を渡してうまく2ファイル作ってくれるやつを用意したほうがいいかも
_ = <<EOComment
127.0.0.1	localhost
127.0.1.1	debian

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOComment

file '/etc/hostname' do
  owner 'root'
  group 'root'
  mode '644'
  content "ao\n"
end

file '/etc/hosts' do
  owner 'root'
  group 'root'
  mode '0644'
  content "127.0.0.1 localhost ao\n"
end

# これsystemd-networkd cookbookに切り出したほうがいい。
service 'systemd-networkd' do
  action :enable
end

package 'ifupdown' do
  action :remove
end

%w(
  01-lo.network
  11-enp11s0f0.network
  12-enp11s0f1.network
  31-t_yume.netdev
  32-t_yume.network
).each do |f|
  remote_file "/etc/systemd/network/#{f}" do
    owner 'root'
    group 'root'
    mode '644'
    notifies :restart, 'service[systemd-networkd]'
  end
end

include_role 'ebgp-router'

%w(
  t_yume.conf
  static.conf
).each do |t|
  template "/etc/bird/bird.conf.d/#{t}" do
    owner 'root'
    group 'root'
    mode '644'
    notifies :restart, 'service[bird]'
  end
end

service 'bird' do
  action [:enable, :start]
end

include_cookbook 'sshd'

%w(
  bind9-dnsutils
  tcpdump
  htop
  mtr
).each do |p|
  package p
end
