template '/etc/pacman.conf' do
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'update repository' do
  command 'pacman -Sy'
  action :nothing
end
