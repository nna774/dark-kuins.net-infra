# node[:journald][:system_max_use] が nil なら何もしない。
# 例) node.reverse_merge!(journald: { system_max_use: '200M' })
node.reverse_merge!(
  journald: {
    system_max_use: nil,
  },
)

max_use = node[:journald][:system_max_use]

directory '/etc/systemd/journald.conf.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

file '/etc/systemd/journald.conf.d/00-size.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  if max_use
    content [
      '[Journal]',
      "SystemMaxUse=#{max_use}",
      '',
    ].join("\n")
  else
    action :delete
  end
  notifies :restart, 'service[systemd-journald]'
end

service 'systemd-journald' do
  action :nothing
end
