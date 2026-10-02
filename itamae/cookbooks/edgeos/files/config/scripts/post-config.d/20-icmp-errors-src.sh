#!/bin/sh
# /config/scripts/post-config.d/20-icmp-errors-src.sh
#
# 転送パケットに対して生成する ICMP エラー (time-exceeded / fragmentation-needed) の
# 送信元に、着信インタフェースのアドレスを使わせない。
#
# EdgeOS は /etc/sysctl.d/30-vyatta-router.conf で
#   net.ipv4.icmp_errors_use_inbound_ifaddr=1
# を入れている (コメントは "exiting interface" と書いてあるが実際は inbound)。
# 全インタフェースに到達可能なアドレスが載っている普通の構成では親切な設定だが、
# この機体の着信インタフェースは ip6ip6 トンネルで、載っているのは
# 169.254/16 の転送ネットだけ。結果、
#
#   icmp_send() → inet_select_addr(v6tun1, iph->saddr, RT_SCOPE_LINK)
#     → 169.254.222.10 (scope link=253 は 253 > 253 が偽で除外されない)
#
# となり、到達不能アドレス発の ICMP エラーを吐く。外からの traceroute に
# このルータが出てこないのも、リモートに PMTU を通知できないのもこれが原因。
#
# 0 にすると saddr=0 となり経路ベースの送信元選択に委ねられる。
# 転送ネットのアドレスが scope link になっていれば (link-local-scope.sh のパッチ)
# lo の PI アドレスに落ちる。両方揃って初めて直る。
#
# /config 配下なのでファームウェアアップデートでも消えない。
set -u

KEY=/proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr
[ -w "$KEY" ] || exit 0
[ "$(cat "$KEY")" = 0 ] && exit 0
echo 0 > "$KEY" && logger -t icmp-errors-src "set icmp_errors_use_inbound_ifaddr=0"
