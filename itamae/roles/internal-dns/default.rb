package 'unbound'
service 'unbound'

service 'systemd-resolved' do
  action [:stop, :disable]
end

if !node[:internal_dns][:keep_resolveconf]
  file '/etc/resolve.conf' do
    action :delete
    only_if 'test -h /etc/resolve.conf'
  end

  file '/etc/resolve.conf' do
    content "nameserver 127.0.0.1\nsearch #{node[:internal_dns][:self_search]}\n"
    owner 'root'
    group 'root'
    mode '0644'
  end
end

iii = data_bag('iii', type: :json)
template '/etc/unbound/unbound.conf.d/main.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[unbound]'
  variables ({
    iii: iii,
  })
end
