# ここのコミットを上げるのがupstream-watchのデプロイになる
node.reverse_merge!(
  upstream_watch: {
    revision: '3128e561b641a1bd7eb42ef552fd4607af19144e',
  },
)
node[:upstream_watch][:source] = "https://raw.githubusercontent.com/nna774/upstream-watch/#{node[:upstream_watch][:revision]}"
