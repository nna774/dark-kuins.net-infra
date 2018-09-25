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
