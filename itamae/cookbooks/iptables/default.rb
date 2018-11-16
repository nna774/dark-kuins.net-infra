package 'iptables-persistent'

remote_file '/etc/iptables/rules.v4' do
  owner 'root'
  group 'root'
  mode '755'
end
