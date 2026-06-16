node.reverse_merge!({
  hostname: 'kasuga.compute.nakanoshima.dark-kuins.net',
  os: :debian,
  strongswan: {
    profiles: [
      { name: 'kasuga-yukari.conf', psk: node[:secrets][:kasuga_yukari_psk] },
    ],
  },
  internal_dns: {
    self_search: 'compute.nakanoshima.dark-kuins.net nakanoshima.dark-kuins.net',
    forward_addr: '169.254.169.254',
  },
  dhcp: {
    role: :slave,
    interfacesv4: 'ens4',
  },
  journald: {
    system_max_use: '200M',
  },
})

file '/etc/hosts' do
  owner 'root'
  group 'root'
  mode '0644'
  content <<~EOS
    127.0.0.1 localhost
    127.0.0.1 kasuga.compute.nakanoshima.dark-kuins.net kasuga

    # The following lines are desirable for IPv6 capable hosts
    ::1 ip6-localhost ip6-loopback
    fe00::0 ip6-localnet
    ff00::0 ip6-mcastprefix
    ff02::1 ip6-allnodes
    ff02::2 ip6-allrouters
    ff02::3 ip6-allhosts
    169.254.169.254 metadata.google.internal metadata
  EOS
end

include_cookbook 'strongswan'

include_cookbook 'slack'
include_cookbook 'aisatsu'

include_cookbook 'mackerel-agent'

%w(less git).each do |p|
  package p
end

# /etc/sysctl.d/60-gce-network-security.conf があるので、60より後でする必要がある。
file '/etc/sysctl.d/70-ip-forward.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  content "net.ipv4.ip_forward = 1\n"
end

include_role 'internal-dns'

include_role 'dhcp'

include_cookbook 'timezone'

include_cookbook 'journald'
include_cookbook 'swap'

# Google Cloud Ops Agent は使っていない(監視は mackerel と prometheus/node_exporter)。
# サービスアカウントに monitoring 権限が無く動作していない上、シャットダウン時に
# 子プロセス google_cloud_ops_agent_diagnostics が終了せず数分ハングする原因に
# なっていたため無効化する。
%w(
  google-cloud-ops-agent
  google-cloud-ops-agent-fluent-bit
  google-cloud-ops-agent-opentelemetry-collector
).each do |svc|
  service svc do
    action [:stop, :disable]
  end
end

# google-shutdown-scripts.service は TimeoutStopSec=infinity で、刺さると
# シャットダウンが無限に止まる(24.04 への do-release-upgrade 時に発生)。
# 上限を被せて一定時間で SIGKILL させ shutdown が必ず進むようにする。
directory '/etc/systemd/system/google-shutdown-scripts.service.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

file '/etc/systemd/system/google-shutdown-scripts.service.d/timeout.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  content "[Service]\nTimeoutStopSec=30s\n"
  notifies :run, 'execute[systemctl daemon-reload]'
end

# IPv6 DHCP は使わない(v4/ens4 のみ運用)。resolvconf 連携は internal-dns が
# /etc/resolv.conf を直接管理するため不要。どちらも upgrade 後に failed になるので mask する。
%w(
  isc-dhcp-server6
  unbound-resolvconf
).each do |svc|
  execute "mask #{svc}" do
    command "systemctl mask --now #{svc}.service"
    not_if %{test "$(systemctl is-enabled #{svc}.service 2>/dev/null)" = masked}
  end
end
