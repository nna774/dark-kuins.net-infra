node.reverse_merge!(
  nginx: {
    user: 'www-data',
    worker_processes: 'auto',
    worker_connections: 8192,
    worker_rlimit_nofile: 17824,
    keepalive_timeout: 65,
    client_max_body_size: '4G',
    client_body_buffer_size: '128k',
    proxy_buffers: '100 64k',
    proxy_buffer_size: '8k',
    large_client_header_buffers: '4 8k',
    proxy_read_timeout: '60s',
    proxy_connect_timeout: '5s',
    server_names_hash_bucket_size: 128,
    proxy_headers_hash_bucket_size: 64,
    log_format: %w[
      status:$status
      time:$time_iso8601
      reqtime:$request_time
      method:$request_method
      uri:$request_uri
      protocol:$server_protocol
      ua:$http_user_agent
      forwardedfor:$http_x_forwarded_for
      host:$remote_addr
      referer:$http_referer
      server_name:$server_name
      vhost:$host
      size:$body_bytes_sent
      reqsize:$request_length
      runtime:$upstream_http_x_runtime
      apptime:$upstream_response_time
     ].join('\t'),
    default_conf: true,
  }
)

package (node[:nginx][:package] || 'nginx')

execute "/etc/nginx/dhparam.pem" do
  command "touch /etc/nginx/dhparam.pem && chown #{node.dig(:nginx, :dhparam_user) || 'nginx' }:root /etc/nginx/dhparam.pem && chmod 660 /etc/nginx/dhparam.pem && openssl dhparam -out /etc/nginx/dhparam.pem 2048 && chmod 440 /etc/nginx/dhparam.pem"
  not_if "test -e /etc/nginx/dhparam.pem"
end

%w(
/etc/nginx/utils
/etc/nginx/conf.d
).each do |d|
  directory d do
    owner 'root'
    group 'root'
    mode  '0755'
  end
end

%w(
/etc/nginx/nginx.conf
/etc/nginx/utils/tls_modern.conf
).each do |f|
  template f do
    owner 'root'
    group 'root'
    mode '0644'
    notifies :reload, 'service[nginx]'
  end
end

service 'nginx' do
  action [:start, :enable]
end

execute 'nginx try-reload' do
  command 'nginx -t && systemctl try-reload-or-restart nginx.service'
  action :nothing
end

if node[:nginx][:use_certbot]
  package (node[:nginx][:cerbot_package] || 'certbot')
end
