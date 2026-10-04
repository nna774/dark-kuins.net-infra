# ここのコミットを上げるのがupstream-watchのデプロイになる
node.reverse_merge!(
  upstream_watch: {
    revision: '746dc9a10243f10d797bb4e5e5795fd89dc4cb38',
  },
)
node[:upstream_watch][:source] = "https://raw.githubusercontent.com/nna774/upstream-watch/#{node[:upstream_watch][:revision]}"
