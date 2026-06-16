# スワップファイルを fstab に登録する。手動 swapon だけだと systemd が
# シャットダウン時の順序依存を把握できないため、fstab 経由で swap unit を生成させる。
node.reverse_merge!(
  swap: {
    file: '/swapfile',
    size: '1G',
  },
)

swapfile = node[:swap][:file]
size = node[:swap][:size]

execute "create #{swapfile}" do
  command "fallocate -l #{size} #{swapfile} && chmod 600 #{swapfile} && mkswap #{swapfile}"
  not_if "test -e #{swapfile}"
end

execute "register #{swapfile} to fstab" do
  command %{echo "#{swapfile} none swap sw 0 0" >> /etc/fstab}
  not_if %{grep -qE "^#{swapfile}[[:space:]]" /etc/fstab}
end

execute "swapon #{swapfile}" do
  command "swapon #{swapfile}"
  not_if "grep -qE \"^#{swapfile}[[:space:]]\" /proc/swaps"
end
