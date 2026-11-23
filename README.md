# 兆能 ZN-M2 ImmortalWrt 自编译固件

自动化编译 **兆能 ZN-M2（IPQ6000 / IPQ6018，512MB RAM，无 WiFi）** 的 ImmortalWrt 固件。

- 源码：`immortalwrt/immortalwrt` 分支 `openwrt-24.10`（kernel 6.6，**opkg / .ipk** 包管理）
- 设备支持：上游没有 zn_m2，本仓库通过 `scripts/znm2-patch.sh` 补 DTS + image profile
- 无 WiFi：移除 `kmod-ath11k*` / `ath11k-firmware-ipq6018` / `wpad`

## 内置插件

| 功能 | 包 |
|---|---|
| OpenClash（含 mihomo 内核） | `luci-app-openclash` + `mihomo-core` |
| mosdns（带 stats 补丁的核心 + LuCI） | `mosdns` + `luci-app-mosdns` |
| 微信推送 | `luci-app-wechatpush` |
| Lucky | `lucky` + `luci-app-lucky` |
| frp（客户端） | `frpc` + `luci-app-frpc` |
| KMS 服务器 | `vlmcsd` + `luci-app-vlmcsd` |
| EasyTier | `easytier` + `luci-app-easytier` |
| Bandix 流量监控 | `bandix` + `luci-app-bandix` |

## 刷机

- 不死 U-Boot 网页端：刷 `*zn_m2*squashfs-factory.ubi`
- 已有 OpenWrt 系统内升级：刷 `*zn_m2*squashfs-sysupgrade.bin`（不保留配置更稳）
- 默认管理地址：<http://192.168.1.1>，首次登录自行设置密码

## 自定义

改 `configs/znm2.config` 增删软件包，推送后在 Actions 页面手动 Run workflow。
