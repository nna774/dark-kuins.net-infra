file '/etc/hostname' do
  content node[:hostname]
  owner 'root'
  group 'root'
  mode '644'
end
