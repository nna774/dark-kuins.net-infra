package 'unbound'
service 'unbound'

service 'systemd-resolved' do
  action [:stop, :disable]
end

file '/etc/resolve.conf' do
  action :delete
  only_if 'test -h /etc/resolve.conf'
end

file '/etc/resolve.conf' do
  content "nameserver 127.0.0.1\nsearch compute.nishiogikubo.dark-kuins.net nishiogikubo.dark-kuins.net\n"
  owner 'root'
  group 'root'
  mode '0644'
end

remote_file '/etc/unbound/unbound.conf.d/main.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[unbound]'
end
