package 'unbound'
service 'unbound'

service 'systemd-resolved' do
  action [:stop, :disable]
end

if !node[:internal_dns][:keep_resolveconf]
  # /etc/resolv.conf が symlink(systemd-resolved の stub 等)なら除去してから
  # 実ファイルを書く。mitamae の file :delete は dangling symlink を消せない
  # (test -e が偽で「存在しない」と判断しスキップ)ため execute rm -f を使う。
  # do-release-upgrade はこの symlink を貼り直すので、upgrade 後に必要になる。
  execute 'remove resolv.conf symlink' do
    command 'rm -f /etc/resolv.conf'
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
