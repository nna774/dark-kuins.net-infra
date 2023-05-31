packages = %w(prometheus prometheus-alertmanager)

packages.each do |p|
  package p

  service p do
    action [:start, :enable]
  end
end

%w(
  /etc/default/prometheus
  /etc/prometheus/prometheus.yml
  /etc/prometheus/rules.yml
).each do |n|
  template n do
    owner 'prometheus'
    group 'prometheus'
    mode '0644'
    notifies :restart, 'service[prometheus]'
  end
end

%w(
  /etc/default/prometheus-alertmanager
  /etc/prometheus/alertmanager.yml
).each do |n|
  template n do
    owner 'prometheus'
    group 'prometheus'
    mode '0644'
    notifies :restart, 'service[prometheus-alertmanager]'
  end
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
