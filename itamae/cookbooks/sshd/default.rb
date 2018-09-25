allow_users = node.dig(:sshd, :allow_users)
allow_users_c = ''
unless allow_users.nil?
  allow_users_c = 'AllowUsers'
  allow_users.each { |u| allow_users_c += " #{u}" }
end

template '/etc/ssh/sshd_config' do
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    allow_users: allow_users_c
  )
  notifies :restart, 'service[sshd]'
end

service 'sshd'
