execute 'timedatectl set-timezone Asia/Tokyo' do
  action :run
  not_if 'timedatectl status | grep -qE "Time zone:.*Asia/Tokyo"'
end
