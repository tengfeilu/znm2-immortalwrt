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

# mosdns 固定到 5.3.3-r4 期提交：其依赖补丁把 go.mod 定为 go 1.23.0，
# 与 immortalwrt 24.10 自带的 golang 1.23.12 一致（v5 最新分支已要求 go 1.26，无法编译）。
MOSD_SHA=849af3f740108341745679c9bdc5dd97e5dba5ac
echo ">>> mosdns (sbwml 5.3.3-r4 @ ${MOSD_SHA:0:10} + LuCI 1.6.10 + v2dat)"
curl -fsSL --retry 3 -o "$TMP/mos.tar.gz" \
	"https://codeload.github.com/sbwml/luci-app-mosdns/tar.gz/${MOSD_SHA}"
mkdir -p "$TMP/mos"
tar -xzf "$TMP/mos.tar.gz" -C "$TMP/mos" --strip-components=1
rm -rf "$SRC/package/feeds/packages/mosdns"       # 避免与 feed 里的 mosdns 重名
cp -r "$TMP/mos/luci-app-mosdns" "$SRC/package/"
cp -r "$TMP/mos/mosdns" "$SRC/package/"
cp -r "$TMP/mos/v2dat" "$SRC/package/"

echo ">>> lucky"
fetch https://github.com/gdy666/luci-app-lucky.git main lucky
cp -r "$TMP/lucky/luci-app-lucky" "$SRC/package/"
cp -r "$TMP/lucky/lucky" "$SRC/package/"

echo ">>> EasyTier"
fetch https://github.com/EasyTier/luci-app-easytier.git main easytier
cp -r "$TMP/easytier/luci-app-easytier" "$SRC/package/"
cp -r "$TMP/easytier/easytier" "$SRC/package/"

echo ">>> Bandix (LuCI + eBPF 后端, 后端用官方预编译二进制)"
fetch https://github.com/timsaya/luci-app-bandix.git main bandix-luci
cp -r "$TMP/bandix-luci/luci-app-bandix" "$SRC/package/"
fetch https://github.com/timsaya/openwrt-bandix.git main bandix-core
cp -r "$TMP/bandix-core/openwrt-bandix" "$SRC/package/"

echo ">>> 微信推送 (luci-app-wechatpush)"
fetch https://github.com/tty228/luci-app-wechatpush.git master wechatpush
mkdir -p "$SRC/package/luci-app-wechatpush"
cp -a "$TMP/wechatpush/." "$SRC/package/luci-app-wechatpush/"
rm -rf "$SRC/package/luci-app-wechatpush/.git" "$SRC/package/luci-app-wechatpush/.github"

echo ">>> 超级网络唤醒 (luci-app-wolultra)"
fetch https://github.com/VIKINGYFY/packages.git main viking
cp -r "$TMP/viking/luci-app-wolultra" "$SRC/package/"

echo ">>> 本地包: mihomo 内核"
cp -r "$(dirname "$0")/../package/mihomo-core" "$SRC/package/"

ls -1 "$SRC/package/" | sed 's/^/    /'
echo ">>> 第三方插件就绪"
