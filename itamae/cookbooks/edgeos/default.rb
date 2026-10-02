# EdgeOS (EdgeRouter) の、設定の外にある成果物を管理する。
#
# config.boot は vyatta CLI の所有物なのでここでは一切触らない。ファイルを上書きして
# load + commit するのはルータを壊す定番の手なので、設定は CLI のまま運用する。
#
# ここで扱うのはファームウェアアップデートで消えるローカルパッチと、/config 配下の
# スクリプト。消えたら itamae を回し直せば戻る、という状態にするのが目的。
#
# mitamae は mips バイナリが無いので動かない。driver は itamae_ssh を使う。
# busybox userland なので package / user リソースは使えない (useradd が無い)。

src = File.join(node[:basedir], 'vendor', 'upstream-watch')

templates = '/opt/vyatta/share/vyatta-cfg/templates/interfaces'

# ---- ローカルパッチ: ip6ip6 トンネルで encaplimit と `encapsulation any` を使えるようにする ----

%W(
  #{templates}/ipv6-tunnel/node.tag/encaplimit
  #{templates}/tunnel/node.tag/encaplimit
).each do |dir|
  directory dir do
    owner 'root'
    group 'root'
    mode '0755'
  end
end

%W(
  #{templates}/ipv6-tunnel/node.tag/encapsulation/node.def
  #{templates}/ipv6-tunnel/node.tag/encaplimit/node.def
  #{templates}/tunnel/node.tag/encaplimit/node.def
).each do |f|
  remote_file f do
    owner 'root'
    group 'root'
    mode '0644'
  end
end

# ---- ローカルパッチ: 169.254/16 を scope link で入れさせる ----
#
# vyatta-address は `ip addr add` を scope 指定なしで呼ぶので、RFC 3927 の
# リンクローカルが scope global で入る。すると gateway 付き scope global 経路の
# 送信元選択でこの転送ネットアドレスが採用され、ルータ自身が v4 で外に出られず、
# 転送パケットへの ICMP エラーの送信元も到達不能になる。
#
# EdgeOS に scope を書ける設定ノードは存在しない。アドレス生成時点で正しく入れたいので
# テンプレートが呼ぶスクリプト側にパッチを当てる。スクリプト自体が冪等。
#
# /config/scripts は setgid vyattacfg なので、ここに置くファイルの group は root にしない。

remote_file '/config/scripts/link-local-scope.sh' do
  owner 'root'
  group 'vyattacfg'
  mode '0755'
end

execute 'patch vyatta-address for link-local scope' do
  command 'bash /config/scripts/link-local-scope.sh'
  not_if "grep -qF 'scope link' /opt/vyatta/sbin/vyatta-address"
end

# ---- 転送パケットへの ICMP エラーの送信元を経路ベースにする ----
#
# 上の scope link と両方揃って初めて直る。post-config.d なので起動時に効く。

remote_file '/config/scripts/post-config.d/20-icmp-errors-src.sh' do
  owner 'root'
  group 'vyattacfg'
  mode '0755'
end

execute 'apply icmp_errors_use_inbound_ifaddr=0 now' do
  command 'sh /config/scripts/post-config.d/20-icmp-errors-src.sh'
  not_if 'test "$(cat /proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr)" = 0'
end

# ---- upstream-watch からの読み取り ----

remote_file '/config/scripts/upstream-watch-fetch' do
  source File.join(src, 'edgeos', 'upstream-watch-fetch')
  owner 'root'
  group 'vyattacfg'
  mode '0755'
end

# sudoers は壊すと sudo が全部死ぬので、検証してから設置する
execute 'install /etc/sudoers.d/upstream-watch' do
  command <<~'SH'
    set -e
    tmp=$(mktemp)
    {
      echo '# upstream-watch が BGP 状態を読むためだけの許可 (itamae が管理)'
      echo 'uwatch ALL=(root) NOPASSWD: /config/scripts/upstream-watch-fetch'
    } > "$tmp"
    visudo -cf "$tmp"
    install -o root -g root -m 0440 "$tmp" /etc/sudoers.d/upstream-watch
    rm -f "$tmp"
  SH
  not_if 'grep -qx "uwatch ALL=(root) NOPASSWD: /config/scripts/upstream-watch-fetch" /etc/sudoers.d/upstream-watch 2>/dev/null'
end

# ---- sshd ----
#
# /etc/ssh/sshd_config は commit では再生成されない (node.def は /etc/default/ssh を
# 書くだけで、listen-address と disable-password-authentication が sed で直接
# 書き換えている) ので、直接編集してよい。消えるのはファームウェアアップデート時。
#
# どちらの execute も sshd -t が通らなければ書き戻して失敗する。これが無いと
# itamae がルータから締め出す道具になる。

sshd_guard = <<~'SH'
  if /usr/sbin/sshd -t; then
    systemctl reload ssh
  else
    cp /etc/ssh/sshd_config.itamae-bak /etc/ssh/sshd_config
    echo 'sshd -t が通らないので書き戻した' >&2
    exit 1
  fi
SH

# 鍵でできることを読み取りスクリプト 1 本に固定する。
# EdgeOS は設定値に " を書けないので authorized_keys の command= では表現できず、
# operator level には shell が無い (Vyatta::Login::User が nologin にする) ため、
# admin でない専用ユーザ + ForceCommand という組み合わせになる。
execute 'sshd_config: confine the upstream-watch key' do
  command <<~SH
    set -e
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.itamae-bak
    cat >> /etc/ssh/sshd_config <<'BLOCK'

# upstream-watch の鍵を BGP 読み取り 1 本に限定する (itamae が管理)
Match User uwatch
    PasswordAuthentication no
    ForceCommand sudo -n /config/scripts/upstream-watch-fetch
BLOCK
    #{sshd_guard}
  SH
  not_if 'grep -q "^Match User uwatch" /etc/ssh/sshd_config'
end

# disable-password-authentication の sed は /^PasswordAuthentication/ で行頭に
# 固定されているため、Match Group operator ブロック内のインデントされた行に当たらない。
# 設定ノードでは消せないので直接書き換える。
execute 'sshd_config: disable password auth for the operator group' do
  command <<~SH
    set -e
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.itamae-bak
    sed -i -e '/^Match Group operator/,/^$/ s/^\\( *\\)PasswordAuthentication yes/\\1PasswordAuthentication no/' /etc/ssh/sshd_config
    #{sshd_guard}
  SH
  only_if %(sed -n '/^Match Group operator/,/^$/p' /etc/ssh/sshd_config | grep -q 'PasswordAuthentication yes')
end
