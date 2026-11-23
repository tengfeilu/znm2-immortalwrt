# mihomo (Clash.Meta) 内核，给 OpenClash 用
# 官方预编译 aarch64 二进制，装到 /etc/openclash/core/clash_meta
include $(TOPDIR)/rules.mk

PKG_NAME:=mihomo-core
PKG_VERSION:=1.19.34
PKG_RELEASE:=1

PKG_SOURCE:=mihomo-linux-arm64-v$(PKG_VERSION).gz
PKG_SOURCE_URL:=https://github.com/MetaCubeX/mihomo/releases/download/v$(PKG_VERSION)
PKG_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/mihomo-core
	SECTION:=net
	CATEGORY:=Network
	TITLE:=mihomo (Clash.Meta) core for OpenClash (arm64)
	URL:=https://github.com/MetaCubeX/mihomo
endef

define Package/mihomo-core/description
	mihomo (Clash.Meta) 内核，供 luci-app-openclash 使用。
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	gunzip -c $(DL_DIR)/$(PKG_SOURCE) > $(PKG_BUILD_DIR)/mihomo
	chmod 0755 $(PKG_BUILD_DIR)/mihomo
endef

define Build/Compile
endef

define Package/mihomo-core/install
	$(INSTALL_DIR) $(1)/etc/openclash/core
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mihomo $(1)/etc/openclash/core/clash_meta
endef

$(eval $(call BuildPackage,mihomo-core))
