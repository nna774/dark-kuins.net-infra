# upstream-watch (https://github.com/nna774/upstream-watch) を配る。
# 本体は submodule itamae/vendor/upstream-watch が正で、ここには複製を持たない。
# submodule の pin がどの版を配ったかの記録になる。

src = File.join(node[:basedir], 'vendor', 'upstream-watch')

node.reverse_merge!(
  upstream_watch: {
    # 30-ripe-upstream は上流側で統計を取っているので入れない
    probes: %w(10-edgeos-bgp 20-mtr-upstream),
    router_ssh: nil,
    mail_to: [],
    # 定期実行。false の間は systemctl start / sudo -u upstream-watch で手動
    timer: false,
  },
)

# mtr-tiny でもよいが、既に mtr が入っている環境に二重に入れないよう合わせる
package 'mtr'

# root は不要。mtr は非特権 ICMP datagram socket で足りる
user 'upstream-watch' do
  system_user true
  create_home false
  shell '/usr/sbin/nologin'
end

directory '/usr/local/libexec/upstream-watch' do
  owner 'root'
  group 'root'
  mode '0755'
end

directory '/etc/upstream-watch' do
  owner 'root'
  group 'root'
  mode '0755'
end

directory '/var/lib/upstream-watch' do
  owner 'upstream-watch'
  group 'upstream-watch'
  mode '0755'
end

remote_file '/usr/local/bin/upstream-watch' do
  source File.join(src, 'upstream-watch')
  owner 'root'
  group 'root'
  mode '0755'
end

node[:upstream_watch][:probes].each do |probe|
  remote_file File.join('/usr/local/libexec/upstream-watch', probe) do
    source File.join(src, 'probes', probe)
    owner 'root'
    group 'root'
    mode '0755'
  end
end

%w(
  /etc/upstream-watch/targets.conf
  /etc/upstream-watch/known_hosts
).each do |f|
  remote_file f do
    owner 'root'
    group 'root'
    mode '0644'
  end
end

file '/etc/upstream-watch/id_ed25519' do
  owner 'upstream-watch'
  group 'root'
  mode '0600'
  # 末尾の改行が落ちると OpenSSH が error in libcrypto で読めなくなる
  content "#{node[:secrets][:upstream_watch_ssh_key].chomp}\n"
  sensitive true
end

file '/etc/upstream-watch/env' do
  owner 'upstream-watch'
  group 'root'
  mode '0600'
  sensitive true
  content <<~ENV
    # itamae が生成している。直接編集しても次回の実行で戻る。
    MAIL_TO='#{node[:upstream_watch][:mail_to].join(', ')}'
    ROUTER_SSH=#{node[:upstream_watch][:router_ssh]}
    ROUTER_SSH_OPTS='-o BatchMode=yes -o ConnectTimeout=10 -i /etc/upstream-watch/id_ed25519 -o UserKnownHostsFile=/etc/upstream-watch/known_hosts -o StrictHostKeyChecking=yes'
    CONFIRM_PROBES='mtr-upstream'
  ENV
end

remote_file '/etc/systemd/system/upstream-watch.service' do
  source File.join(src, 'systemd', 'upstream-watch.service')
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

remote_file '/etc/systemd/system/upstream-watch.timer' do
  source File.join(src, 'systemd', 'upstream-watch.timer')
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
  action node[:upstream_watch][:timer] ? :create : :delete
end

service 'upstream-watch.timer' do
  action node[:upstream_watch][:timer] ? [:enable, :start] : [:stop, :disable]
end
