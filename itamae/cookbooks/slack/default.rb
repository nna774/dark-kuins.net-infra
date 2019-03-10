template '/usr/local/bin/slack' do
  owner 'root'
  group 'root'
  mode  '0755'
  variables(
    wh_uri: node[:secrets][:kmc_slack_wh_uri]
  )
end
