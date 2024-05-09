remote_file '/etc/default/grub' do
  owner 'root'
  group 'root'
  mode '644'
  notifies :run, 'execute[update-grub]'
end
