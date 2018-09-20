package 'jq'
package 'awscli'

%w(
/etc/cloud/cloud.cfg
/etc/cloud/cloud.cfg.d/set_hostname.cfg
).each do |t|
  template t do
    owner 'root'
    group 'root'
    mode  '0644'
  end
end

template '/etc/cloud/cloud.cfg.d/set_hostname.sh' do
  owner 'root'
  group 'root'
  mode  '0755'
end
