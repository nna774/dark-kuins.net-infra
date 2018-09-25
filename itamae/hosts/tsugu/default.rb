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
})
include_cookbook 'nana'
include_cookbook 'disable-users'
include_cookbook 'sshd'
include_cookbook 'cloud-init'
