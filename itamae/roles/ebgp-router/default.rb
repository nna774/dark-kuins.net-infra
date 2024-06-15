package 'bird2'

directory '/etc/bird' do
  owner 'root'
  group 'root'
  mode  '0755'
end

directory '/etc/bird/bird.conf.d' do
  owner 'root'
  group 'root'
  mode  '0755'
end

template '/etc/bird/bird.conf' do
  owner 'root'
  group 'root'
  mode '644'
  notifies :restart, 'service[bird]'
end
