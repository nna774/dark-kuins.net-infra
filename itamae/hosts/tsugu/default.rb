node.merge!({
  nana: {
    sudo_nopasswd: true,
  },
})
include_cookbook 'nana'

node.merge!({
  disable_user: {
    names: [
      'ubuntu',
    ],
  },
})
include_cookbook 'disable-users'

node.merge!({
  sshd: {
    allow_users: [
      'nana',
    ],
  },
})
include_cookbook 'sshd'

include_cookbook 'cloud-init'
