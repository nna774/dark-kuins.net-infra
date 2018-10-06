apt_key '9B40E429A71065E9'

file '/etc/apt/sources.list.d/treasure-data.list' do
  content "deb http://packages.treasuredata.com/3/debian/stretch/ stretch contrib\n"
  owner 'root'
  group 'root'
  mode '644'
  notifies :run, 'execute[apt-get update]', :immediately
end

package 'td-agent'

service 'td-agent' do
  action [:start, :enable]
end
