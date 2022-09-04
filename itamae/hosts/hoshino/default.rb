node.reverse_merge!(
  disable_user: {
    names: ['pi'],
  },
  nana: {
    sudo_nopasswd: true,
  },
)

file '/etc/hostname' do
  owner 'root'
  group 'root'
  mode '644'
  content "hoshino\n"
end

file '/etc/hosts' do
  owner 'root'
  group 'root'
  mode '0644'
  content "127.0.0.1 localhost hoshino\n"
end


service 'dhcpcd' do
  action [:stop, :disable]
end

service 'systemd-networkd' do
  action :enable
end

%w(
  /etc/systemd/network/10-eth0.network
  /etc/systemd/network/20-eth0.50.netdev
  /etc/systemd/network/25-eth0.50.network
).each do |f|
  remote_file f do
    owner 'root'
    group 'root'
    mode '644'
    notifies :restart, 'service[systemd-networkd]'
  end
end

include_cookbook 'nana'
include_cookbook 'disable-users'

=begin

execute 'prepre install docker' do
  command 'curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && apt-update'
  not_if 'test -e /etc/apt/sources.list.d/docker.list'
end

%w(
  docker-ce
  docker-ce-cli
  containerd.io
  docker-compose-plugin
).each do |p|
  package p
end

execute 'install minikube' do
  command 'curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_arm64.deb && dpkg -i minikube_latest_arm64.deb'
  not_if 'which minikube'
end

execute 'docker group' do
  command 'usermod -aG docker nana'
  not_if 'groups nana | grep docker'
end

# swap 2GB

# minikube autostart

=end


