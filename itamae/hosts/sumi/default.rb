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


