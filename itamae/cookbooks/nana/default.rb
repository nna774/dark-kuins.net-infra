DEFAULT_AUTHORIZED_KEYS = [
  'ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAyEqw6xdtVsZVQd8CxR4LVD0zrfYW3xdfjtbnAxabztvlnfvdrVjP7zL3L39vHlmVYH4LHuoE9otnWiE6MjMvhaAG3f5kaAp3ZvC/Xs8LX+v/PU/YdAsolnS3RNcPmdv8XqsOBMeEjVdWBJYrXl/O6SX2bGvwgrQvWXuQQNrIhLfrIbA== hibiki-ecdsa-key-20180822',
  'rsa-sha2-512 AAAAB3NzaC1yc2EAAAABJQAAAQEAuSWaN5ZkzTLJDgliJbctzQJZhvwUPoeAjALmS2bkhymhcCFNXVU6HvsBG9LSqFgl1ghZV7Jx/oEjicaepnSC71zyr/TcIckSrp4HjNVoFqjuwUdZmC9raAvBYnoa23uvmzIQfnfWgF9fh2mGQ6pkQICvljF/nyNif2p+HN5rWSYn1s52+Bn7Sqmba1Ncxm9F/Q58l0BICRjt4QdbXSRrqGWLtPbNv+wIDdLoqrojHUcrV4Yg1J3QxdH5dpChFhE5PLRrK0Ldz9SEYg6oE7cMuew9YPv3teRLiMNwwGAUUEA8q99ur82kUs4GiGJFMOzlIwp/g+sR79TbKajhPG3Lvw== tsukumothan-2016-11-14',
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPx1uvh5Yc/RMeskZfkvYKw/Y5cPIiOZk7o1yzK336Ka nana-iPad-shelly',
  'ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABj/OA/DFLLScesRmVwzmNYPch0cRV3bqbvoVbjOg6g5JhzozAwS4dTW8cbhc1p4jdkFCJY1MBMtlDSr7Ky3uXfYwGIM18h/mggX8UyG4LCFLJmjXZGSsmgCqrIQGUysCFBOXIomtdeS/QCHProxm5iGANSOsFOuVQjwWNoK7rjik7QsQ== hibiki-wsl-2018-08-31',
  'ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBADpEd+w4HnX8tpyj2VHC98rvwbmwT5LRXbXKWlMocUxtMNHCQWeA+0uYd1U8kh/UjLoxSNVKoHcRvcvDhEDLAmz1AAUad4NVo8ofNmCkIQmvSh8vL9Vo9XC7KQU1mC47PZmqkgHBKtw/pqB4TXWha10KkVDDsTFFX5UzqNYBRP0ksXx7Q== nana@er-2021-0413',
  'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWnKQt2rWVXfhvUkCMBEIfVF6tArJTCvTkFmRkHfKQ9 1password-20240628h'
]

node.reverse_merge!(
  nana: {
    name: 'nana',
    password: node[:nana_password],
    authorized_keys: [],
    include_default_authorized_keys: true,
    homedir_mode: '0755',
    sudo_nopasswd: false,
    gid: 1005,
    uid: 1005,
  },
)

username = node[:nana].fetch(:name)
password = node[:nana].fetch(:password)
nana_gid = node[:nana].fetch(:gid)
nana_uid = node[:nana].fetch(:uid)

group username do
  gid nana_gid
end

user username do
  uid nana_uid
  gid nana_gid
  password password if password
  home "/home/#{username}"
  shell '/bin/bash'
  create_home true
end

#directory "/home/#{username}" do
#  owner username
#  group username
#  mode node[:nana].fetch(:homedir_mode)
#end
## なぜか↑があると /home/alarm/mitamae/mrblib/mitamae/recipe_executor.rb:24:undefined method 'name' for #<NilClass:0x0> (NoMethodError) と死ぬ

directory "/home/#{username}/.ssh" do
  owner username
  group username
  mode '0700'
end

file "/home/#{username}/.ssh/authorized_keys" do
  authorized_keys = node[:nana][:authorized_keys]
  if node[:nana][:include_default_authorized_keys]
    authorized_keys.concat DEFAULT_AUTHORIZED_KEYS
  end

  content authorized_keys.join(?\n) + ?\n
  owner username
  group username
  mode '600'
end

file '/etc/sudoers.d/opuser' do
  content node[:nana].fetch(:sudo_nopasswd) ? "#{username} ALL=(ALL) NOPASSWD:ALL\n" : "#{username} ALL=(ALL) ALL\n"
  owner 'root'
  group 'root'
  mode '440'
end
