allow_users = node.dig(:sshd, :allow_users)
allow_users_c = ''
unless allow_users.nil?
  allow_users_c = 'AllowUsers'
  allow_users.each { |u| allow_users_c += " #{u}" }
end

sftp_path = '/usr/lib/ssh/sftp-server'
if node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  sftp_path = '/usr/lib/openssh/sftp-server'
end

template '/etc/ssh/sshd_config' do
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    allow_users: allow_users_c,
    sftp_path: sftp_path,
  )
  notifies :restart, 'service[sshd]'
end

service 'sshd'
