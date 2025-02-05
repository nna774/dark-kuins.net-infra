package 'unbound'
service 'unbound'

service 'systemd-resolved' do
  action [:stop, :disable]
end

if !node[:internal_dns][:keep_resolveconf]
  file '/etc/resolv.conf' do
    action :delete
    only_if 'test -h /etc/resolv.conf'
  end

  file '/etc/resolv.conf' do
    content "nameserver 127.0.0.1\nsearch #{node[:internal_dns][:self_search]}\n"
    owner 'root'
    group 'root'
    mode '0644'
  end
end

template '/etc/unbound/unbound.conf.d/main.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[unbound]'
  variables ({
    forward: node[:internal_dns][:forward_addr]
  })
end
