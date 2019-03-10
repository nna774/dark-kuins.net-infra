package 'postfix'

service 'postfix' do
  action [:start, :enable]
end

file '/etc/mailname' do
  action :delete
end
