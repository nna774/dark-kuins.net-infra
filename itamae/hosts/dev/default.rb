packages = %w(git htop tmux emacs-nox make build-essential mongodb-clients golang-go traceroute)
packages.each do |p|
  package p do
    action :install
  end
end

# install docker
packages = %w(docker docker-engine docker.io)
packages.each do |p|
  package p do
    action :remove
  end
end
packages = %w(apt-transport-https ca-certificates curl software-properties-common)
packages.each do |p|
  package p do
    action :install
  end
end
apt_key '0EBFCD88'
file '/etc/apt/sources.list.d/docer.list' do
  content "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable\n"
  owner 'root'
  group 'root'
  mode '644'
  notifies :run, 'execute[apt-get update]', :immediately
end
package 'docker-ce'
execute 'install docker-compose' do
  command 'curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-Linux-x86_64" -o /usr/local/bin/docker-compose; chmod +x /usr/local/bin/docker-compose'
  not_if 'test -e /usr/local/bin/docker-compose'
end

# go
gopath = '$HOME/.go'
execute 'set gopath' do
  command "mkdir -p #{gopath}; touch ~/.bashrc; echo GOPATH=#{gopath} >> ~/.bashrc"
  not_if 'grep \'GOPATH=\' ~/.bashrc'
end
