packages = %w(prometheus prometheus-alertmanager)

packages.each do |p|
  package p

  service p do
    action [:start, :enable]
  end
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
