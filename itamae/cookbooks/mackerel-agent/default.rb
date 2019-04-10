execute 'install mackerel' do
  command "wget -q -O - https://mackerel.io/file/script/setup-all-apt-v2.sh | MACKEREL_APIKEY='#{node[:secrets][:mackerel_apikey]}' sh"
  not_if 'test -e /lib/systemd/system/mackerel-agent.service'
end
