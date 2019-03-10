include_cookbook 'slack'

template '/etc/systemd/system/owari.service' do
  owner 'root'
  group 'root'
  mode '0644'
  variables(word: node.dig(:aisatsu, :owari) || '終わりー')
  notifies :run, 'execute[systemctl daemon-reload]'
end

service 'owari' do
  action :enable
end

template '/etc/systemd/system/hajimari.service' do
  owner 'root'
  group 'root'
  mode '0644'
  variables(word: node.dig(:aisatsu, :hajimari) || '次は殺さないでね。')
  notifies :run, 'execute[systemctl daemon-reload]'
end

service 'hajimari' do
  action :enable
end
