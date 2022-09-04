node.reverse_merge!(
  postfix: {
    aliases: {},
    conf: {
      compatibility_level: 2,
      biff: 'no',
      smtpd_tls_received_header: 'yes',
      smtpd_tls_loglevel: 1,
      smtpd_tls_security_level: '${smtpd_tls_cert_file?may}',
      smtpd_tls_dh1024_param_file: '/etc/ssl/ffdhe2048.pem',
      smtpd_tls_mandatory_protocols: '!SSLv2, !SSLv3, !TLSv1, !TLSv1.1',
      smtpd_tls_protocols: '!SSLv2, !SSLv3',
      smtp_tls_CApath: '/etc/ssl/certs',
      smtp_tls_loglevel: 1,
      smtp_tls_security_level: 'may',
      smtp_tls_session_cache_database: 'btree:${data_directory}/smtp_scache',
      smtp_tls_mandatory_protocols: '!SSLv2, !SSLv3, !TLSv1, !TLSv1.1',
      smtp_tls_protocols: '!SSLv2, !SSLv3',
      alias_maps: 'hash:/etc/aliases',
      alias_database: 'hash:/etc/aliases',
      myorigin: '/etc/mailname',
      mydestination: 'localhost',
      mynetworks: '127.0.0.0/8, [::ffff:127.0.0.0]/104, [::1]/128, ${mynetworks_local}',
      mynetworks_local: '',
      mailbox_size_limit: 0,
      recipient_delimiter: '+',
    },
  },
)

package 'postfix'

include_cookbook 'ffdhe'

file '/etc/mailname' do
  content node[:postfix][:mailname]
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :reload, 'service[postfix]'
end

template '/etc/postfix/master.cf' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :restart, 'service[postfix]'
end

file '/etc/postfix/main.cf' do
  content (node[:postfix][:conf].map {|k, v| "#{k}=#{v.to_s.gsub(/(?<=\n)/, '  ')}\n" }.sort.join)
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :reload, 'service[postfix]'
end

file '/etc/aliases' do
  aliases = node[:postfix][:aliases].map do |k, v|
    l = [*v].map {|u| u =~ /\s/ ? %["#{u}"] : u }.join(', ')
    "#{k}: #{l}\n"
  end.join

  content aliases
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[newaliases]'
end

execute 'newaliases' do
  action :nothing
end

service 'postfix' do
  action [:enable, :start]
end
