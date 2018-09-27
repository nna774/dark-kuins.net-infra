node.reverse_merge!({
  nana: {
    sudo_nopasswd: true,
  },
  disable_user: {
    names: [
      'ubuntu',
    ],
  },
  sshd: {
    allow_users: [
      'nana',
    ],
  },
  hostname: 'tsugu.compute.nishiogikubo.dark-kuins.net',
  os: :ubuntu,
})
include_cookbook 'nana'
include_cookbook 'disable-users'
include_cookbook 'sshd'
include_cookbook 'hostname'
include_cookbook 'cloud-init'
include_cookbook 'strongswan'

%w(
/etc/sysctl.d/20-ipv4.ip_forward.conf
/etc/systemd/network/15-ens6.network
).each do |f|
  remote_file f do
    owner 'root'
    group 'root'
    mode '0644'
  end
end
