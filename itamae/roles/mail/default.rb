daemons = <<EOS
EOS

package 'postfix-pcre'

%w(
  virtual_domains
  virtual_maps
).each do |e|
  execute "postmap-#{e}" do
    command "postmap /etc/postfix/#{e}"
    action :nothing
  end
end

remote_file '/etc/postfix/virtual_domains' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[postmap-virtual_domains]'
  notifies :reload, 'service[postfix]'
end

remote_file '/etc/postfix/virtual_maps' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[postmap-virtual_maps]'
  notifies :reload, 'service[postfix]'
end

node.reverse_merge!(
  postfix: {
    aliases: {
      'nana' => 'nna@nna774.net',
    },
    mailname: 'dark-kuins.net',
    daemons: daemons,
    conf: {
      mydomain: 'compute.kitashirakawa.iii.dark-kuins.net',
      myorigin: 'dark-kuins.net',
      mydestination: 'dark-kuins.net, localhost',
      mynetworks_local: '10.8.0.0/16',
      local_header_rewrite_clients: 'permit_mynetworks, permit_sasl_authenticated',

      # restrictions
      smtpd_client_restrictions: '',
      smtpd_relay_restrictions: 'permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination',
      smtpd_recipient_restrictions: '',

      # queue
      maximal_queue_lifetime: '3d',
      bounce_queue_lifetime: '1d',

      # alias
      local_recipient_maps: 'hash:/etc/aliases',
      alias_maps: 'hash:/etc/aliases',
      virtual_alias_domains: 'pcre:/etc/postfix/virtual_domains',
      virtual_alias_maps: 'pcre:/etc/postfix/virtual_maps',
    },
  },
)

include_cookbook 'postfix'
