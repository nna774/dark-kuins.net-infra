node.reverse_merge!({
  nginx: {
    use_certbot: true,
  },
})

include_cookbook 'nginx'

%w(
/etc/nginx/conf.d/default.conf
/etc/nginx/utils/dark-kuins_auth_location.conf
/etc/nginx/utils/dark-kuins_auth_server.conf
).each do |f|
  remote_file f do
    owner 'root'
    group 'root'
    mode '0644'
    notifies :reload, 'service[nginx]'
  end
end

webroot = node[:rproxy][:webroot] || '/var/www/certbot'
directory webroot do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/nginx/utils/certbot.conf' do
  variables ({ webroot: "#{webroot}/" })
  owner 'root'
  group 'root'
  mode '0644'
  notifies :reload, 'service[nginx]'
end

template '/etc/nginx/tls_modern.conf' do
  variables ({
		dns: node[:rproxy][:dns],
		cert: '/etc/letsencrypt/live/tsugu.compute.nishiogikubo.dark-kuins.net/fullchain.pem',
		key: '/etc/letsencrypt/live/tsugu.compute.nishiogikubo.dark-kuins.net/privkey.pem',
  })
  owner 'root'
  group 'root'
  mode '0644'
  notifies :reload, 'service[nginx]'
end

%w(
/etc/nginx/conf.d/grafana.conf
).each do |t|
  template t do
    owner 'root'
    group 'root'
    mode '0644'
    notifies :reload, 'service[nginx]'
  end
end

#node[:rproxy][:dry_run_certbot] = true
domains = "-d #{node[:rproxy][:canonical]}"
dry_run = node[:rproxy][:dry_run_certbot] ? '--dry-run' : ''
node[:rproxy][:alts].each {|d| domains += " -d #{d}" }
execute "certbot certonly --webroot --webroot-path #{webroot} --expand --non-interactive --preferred-challenges http-01 --agree-tos #{domains} --email rproxy-certs@nna774.net #{dry_run}" do
  not_if "test -e /etc/letsencrypt/live/#{node[:rproxy][:canonical]}"
end
