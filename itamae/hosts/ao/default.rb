node.reverse_merge!({

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
  action :nothing # :remove # これ突然removeすると多分ひきこもる。
end
