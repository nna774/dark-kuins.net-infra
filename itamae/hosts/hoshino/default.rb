node.reverse_merge!(
  disable_user: {
    names: ['pi'],
  },
  nana: {
    sudo_nopasswd: true,
  },
  unattended_upgrades: {
    # 既存の apt-listchanges メールと同じ root@dark-kuins.net 宛で届く
    # (postfix virtual_maps が root -> nana -> nna@nna774.net に転送)
    mail: 'root',
  },
)

file '/etc/hostname' do
  owner 'root'
  group 'root'
  mode '644'
  content "hoshino\n"
end

file '/etc/hosts' do
  owner 'root'
  group 'root'
  mode '0644'
  content "127.0.0.1 localhost hoshino\n"
end


service 'dhcpcd' do
  action [:stop, :disable]
end

service 'systemd-networkd' do
  action :enable
end

%w(
  /etc/systemd/network/01-lo.network
  /etc/systemd/network/10-eth0.network
  /etc/systemd/network/23-eth0.50.netdev
  /etc/systemd/network/25-eth0.50.network
).each do |f|
  remote_file f do
    owner 'root'
    group 'root'
    mode '644'
    notifies :restart, 'service[systemd-networkd]'
  end
end

include_cookbook 'nana'
include_cookbook 'disable-users'

include_cookbook 'sshd' # for ban password auth

include_cookbook 'unattended-upgrades'

package 'ufw'
%w(
  /etc/ufw/user.rules
  /etc/ufw/user6.rules
).each do |f|
  remote_file f do
    owner 'root'
    group 'root'
    mode '644'
    notifies :restart, 'service[ufw]'
  end
end

service 'ufw' do
  action [:start, :enable]
end

include_role 'mail'

node.reverse_merge!(
  upstream_watch: {
    router_ssh: 'uwatch@10.8.0.2',
    mail_to: [
      # Slack のチャンネル宛メールアドレスは投稿権限そのものなので secret
      %("#nona-kanshi (Slack)" <#{node[:secrets][:upstream_watch_slack_mail]}>),
      'root@dark-kuins.net',
    ],
    timer: true,
    # BGP 側の瞬断はだいたい 1 分以内に戻るので、それを拾える間隔にする。
    # mtr は 1 回 30 秒かかり、見ているのも上流の構造変化なので 5 分のまま
    interval: '1min',
    min_interval: { 'mtr-upstream' => 300 },
  },
)
include_cookbook 'upstream-watch'

%w(
  tmux
  dnsutils
  mtr
).each do |p|
  package p
end
