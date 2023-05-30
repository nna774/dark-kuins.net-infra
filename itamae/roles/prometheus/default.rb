packages = %w(prometheus prometheus-alertmanager)

packages.each do |p|
  package p

  service p do
    action [:start, :enable]
  end
end

template '/etc/default/prometheus' do
  owner 'prometheus'
  group 'prometheus'
  mode '0644'
  notifies :restart, 'service[prometheus]'
end

template '/etc/prometheus/prometheus.yml' do
  owner 'prometheus'
  group 'prometheus'
  mode '0644'
  notifies :restart, 'service[prometheus]'
end

template '/etc/prometheus/alertmanager.yml' do
  owner 'prometheus'
  group 'prometheus'
  mode '0644'
  notifies :restart, 'service[prometheus-alertmanager]'
end

=begin
execute 'install grafana' do
  command 'wget https://dl.grafana.com/oss/release/grafana_6.0.1_amd64.deb -O /tmp/grafana.deb && dpkg -i /tmp/grafana.deb'
  not_if 'apt show grafana | grep installed'
end

service 'grafana-server' do
  action [:start, :enable]
end
=end
