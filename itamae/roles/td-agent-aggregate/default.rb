include_cookbook 'td-agent'

package 'build-essential'

execute 'install bq gem' do
  command 'td-agent-gem install fluent-plugin-bigquery'
  not_if 'td-agent-gem list --local fluent-plugin-bigquery | grep fluent-plugin-bigquery'
end

file '/etc/td-agent/tsugu_gcp_service_account' do
  owner 'td-agent'
  group 'td-agent'
  mode '600'
  content node[:secrets][:tsugu_gcp_service_account]
end

remote_file '/etc/td-agent/nginx.json' do
  owner 'td-agent'
  group 'td-agent'
  mode '644'
end

template '/etc/td-agent/td-agent.conf' do
  owner 'td-agent'
  group 'td-agent'
  mode '644'
  notifies :restart, 'service[td-agent]'
end
