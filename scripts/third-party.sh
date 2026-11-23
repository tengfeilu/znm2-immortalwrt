#!/bin/bash
# 拉取第三方插件源码到 openwrt/package/
# 必须在 ./scripts/feeds install -a 之后运行（需要先清理 feed 里的同名包）
set -euo pipefail

SRC="${1:?usage: third-party.sh <openwrt-source-dir>}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fetch() { # fetch <url> <ref> <dir>
	git clone --depth 1 -b "$2" "$1" "$TMP/$3"
}

echo ">>> mosdns (sbwml v5: 核心带 stats_api 补丁 + LuCI)"
fetch https://github.com/sbwml/luci-app-mosdns.git v5 mosdns
rm -f "$SRC/package/feeds/packages/mosdns"          # 避免与 feed 里的 mosdns 重名
rm -rf "$SRC/package/feeds/packages/mosdns"
cp -r "$TMP/mosdns/luci-app-mosdns" "$SRC/package/"
cp -r "$TMP/mosdns/mosdns" "$SRC/package/"
cp -r "$TMP/mosdns/geo2txt" "$SRC/package/"

echo ">>> lucky"
fetch https://github.com/gdy666/luci-app-lucky.git main lucky
cp -r "$TMP/lucky/luci-app-lucky" "$SRC/package/"
cp -r "$TMP/lucky/lucky" "$SRC/package/"

echo ">>> EasyTier"
fetch https://github.com/EasyTier/luci-app-easytier.git main easytier
cp -r "$TMP/easytier/luci-app-easytier" "$SRC/package/"
cp -r "$TMP/easytier/easytier" "$SRC/package/"

echo ">>> Bandix (LuCI + eBPF 后端, 后端走官方预编译)")
fetch https://github.com/timsaya/luci-app-bandix.git main bandix-luci
cp -r "$TMP/bandix-luci/luci-app-bandix" "$SRC/package/"
fetch https://github.com/timsaya/openwrt-bandix.git main bandix-core
cp -r "$TMP/bandix-core/openwrt-bandix" "$SRC/package/"

echo ">>> 微信推送 (luci-app-wechatpush)"
fetch https://github.com/tty228/luci-app-wechatpush.git master wechatpush
mkdir -p "$SRC/package/luci-app-wechatpush"
cp -a "$TMP/wechatpush/." "$SRC/package/luci-app-wechatpush/"
rm -rf "$SRC/package/luci-app-wechatpush/.git" "$SRC/package/luci-app-wechatpush/.github"

echo ">>> 本地包: mihomo 内核"
cp -r "$(dirname "$0")/../package/mihomo-core" "$SRC/package/"

ls -1 "$SRC/package/" | sed 's/^/    /'
echo ">>> 第三方插件就绪"
