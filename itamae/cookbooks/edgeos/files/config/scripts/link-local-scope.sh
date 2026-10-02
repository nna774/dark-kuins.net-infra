#!/bin/bash
# /opt/vyatta/sbin/vyatta-address に 169.254/16 を scope link で入れさせるくん。
#
# EdgeOS の vyatta-address は `ip addr add` を scope 指定なしで呼ぶため、
# RFC 3927 のリンクローカル (169.254/16) が scope global で入ってしまう。
# すると default route のような gateway 付き scope global 経路の送信元選択で
# inet_select_addr() に res->scope = RT_SCOPE_UNIVERSE (0) が渡り、
# 出力デバイス上のその転送ネットアドレスが採用される。結果、
#
#   - ルータ自身が v4 で外に出られない (curl に --interface が必要になる)
#   - 転送中パケットに対して生成する ICMP fragmentation-needed の送信元も
#     到達不能アドレスになり、リモートに PMTU を通知できない
#
# scope link にすれば 253 > 0 で除外され、lo のアドレスに落ちる。
# BGP ピア宛 (on-link) は connected route (scope link) 経由で scope 引数が
# RT_SCOPE_LINK になるため `253 > 253` が偽で、引き続き適格。セッションに影響しない。
#
# EdgeOS に scope を書ける設定ノードは存在しない (templates 全走査で確認済み)。
# post-config.d スクリプトでも実現できるが、
#   - 起動時にしか走らないのでインタフェースに触る commit 後に乖離する
#   - 既存アドレスの del + add が必要で、default route を担うデバイスでやると
#     zebra が経路を再投入せず v4 が全断する (実際に事故った)
# のでこちらのほうが素直。アドレス生成時点で正しい scope で入る。
#
# 冪等。ファームウェアアップデートで消えるので encap.sh / node.def と一緒に再適用する。
#
# 使い方:
#   sudo bash link-local-scope.sh
#   bash link-local-scope.sh /path/to/copy    # 検証用に別ファイルへ当てる

set -eu

TARGET="${1:-/opt/vyatta/sbin/vyatta-address}"
ANCHOR='exec ip -6 addr add'
# 冪等判定・挿入確認のマーカー。素の vyatta-address には scope 指定が一度も出てこない。
MARK='scope link'

[ -f "$TARGET" ] || { echo "ない: $TARGET" >&2; exit 1; }

if grep -qF "$MARK" "$TARGET"; then
    echo "すでに当たっている: $TARGET"
    exit 0
fi

if [ ! -w "$TARGET" ]; then
    echo "書けない: $TARGET  (sudo で実行しろ)" >&2
    exit 1
fi

if [ "$(grep -cF "$ANCHOR" "$TARGET")" != 1 ]; then
    echo "アンカー '$ANCHOR' が 1 個見つからない。$TARGET の形が変わっている" >&2
    exit 1
fi

insert=$(mktemp)
patched=$(mktemp)
trap 'rm -f "$insert" "$patched"' EXIT

# ANCHOR 行 (IPv6 分岐) の直後に elif を挿し込む。
# 直後が元の `else` なので、分岐の並びとして成立する。
cat <<'EOF' > "$insert"
        elif [[ "$3" =~ ^169\.254\. ]]
        then # LOCAL PATCH: link-local scope
             # RFC 3927 のリンクローカルは scope link で入れる。
             # scope global だと gateway 付き scope global 経路の送信元選択
             # (inet_select_addr に res->scope = RT_SCOPE_UNIVERSE が渡る) で
             # この転送ネットアドレスが採用され、ルータ自身の送信パケットと
             # 転送中パケットへの ICMP fragmentation-needed の送信元が
             # 到達不能になる。BGP ピア宛 (on-link) には影響しない。
            exec ip addr add "$3" broadcast + dev "$2" scope link
EOF

sed "/$ANCHOR/r $insert" "$TARGET" > "$patched"

bash -n "$patched" || { echo "パッチ後の構文が壊れた。中止する" >&2; exit 1; }
grep -qF "$MARK" "$patched" || { echo "挿入に失敗した。中止する" >&2; exit 1; }

bak="$TARGET.bak.$(date +%Y%m%d%H%M%S)"
[ -e "$bak" ] && { echo "退避先が既にある: $bak  中止する" >&2; exit 1; }
cp -a "$TARGET" "$bak"
cat "$patched" > "$TARGET"
chmod 755 "$TARGET"

echo "当てた: $TARGET"
echo "退避  : $bak"
echo
echo "注意: このパッチはアドレスが追加される瞬間に効く。今あるアドレスの scope は変わらない。"
echo "      次の再起動で全ての 169.254 アドレスが scope link で立ち上がる。"
echo "      今すぐ反映させたい場合、del + add は default route を担っていないデバイスだけに限れ。"
echo "      default route を担うデバイスでやると zebra が経路を再投入せず v4 が全断する。"
echo
echo "確認: ip -4 -o addr show | grep 169.254"
echo "      ip route get 8.8.8.8          # src が lo のアドレスになる"
echo "      curl -s4 https://ifconfig.io  # --interface なしで通る"
