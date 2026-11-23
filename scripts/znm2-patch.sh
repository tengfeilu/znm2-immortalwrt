#!/bin/bash
# 为 ImmortalWrt (openwrt-24.10) 添加兆能 ZN-M2 (IPQ6000/IPQ6018) 设备支持
# 说明：上游 OpenWrt/ImmortalWrt 均未内置 zn_m2，此处通过补充 DTS + image profile 实现。
set -euo pipefail

SRC="${1:?usage: znm2-patch.sh <openwrt-source-dir>}"
DTS_DIR="$SRC/target/linux/qualcommax/files/arch/arm64/boot/dts/qcom"

echo ">>> 写入 DTS: ipq6018-m2.dts"
cat > "$DTS_DIR/ipq6018-m2.dts" <<'DTS'
// SPDX-License-Identifier: (GPL-2.0+)

/dts-v1/;

#include "ipq6018-512m.dtsi"
#include "ipq6018-cp-cpu.dtsi"
#include "ipq6018-ess.dtsi"
#include <dt-bindings/gpio/gpio.h>
#include <dt-bindings/input/input.h>
#include <dt-bindings/leds/common.h>

/ {
	model = "ZN M2";
	compatible = "zn,m2", "qcom,ipq6018";

	aliases {
		ethernet0 = &dp1;
		ethernet1 = &dp2;
		ethernet2 = &dp4;
		ethernet3 = &dp5;
		serial0 = &blsp1_uart3;
		led-boot = &led_power;
		led-failsafe = &led_power;
		led-running = &led_power;
		led-upgrade = &led_power;
	};

	chosen {
		bootargs-append = " root=/dev/ubiblock0_1 swiotlb=1";
	};

	keys {
		compatible = "gpio-keys";

		reset {
			label = "reset";
			gpios = <&tlmm 60 GPIO_ACTIVE_LOW>;
			linux,code = <KEY_RESTART>;
		};

		wps {
			label = "wps";
			gpios = <&tlmm 9 GPIO_ACTIVE_LOW>;
			linux,code = <KEY_WPS_BUTTON>;
		};
	};

	leds {
		compatible = "gpio-leds";
		pinctrl-0 = <&leds_pins>;
		pinctrl-names = "default";

		led_power: power {
			label = "m2:blue:power";
			gpios = <&tlmm 58 GPIO_ACTIVE_HIGH>;
		};

		mesh {
			label = "m2:blue:mesh";
			gpios = <&tlmm 73 GPIO_ACTIVE_HIGH>;
		};

		lan {
			label = "m2:blue:lan";
			gpios = <&tlmm 74 GPIO_ACTIVE_HIGH>;
		};

		wan {
			label = "m2:blue:wan";
			gpios = <&tlmm 37 GPIO_ACTIVE_HIGH>;
		};

		wlan5g {
			label = "m2:blue:wlan5g";
			gpios = <&tlmm 35 GPIO_ACTIVE_HIGH>;
		};

		wlan2g {
			label = "m2:blue:wlan2g";
			gpios = <&tlmm 70 GPIO_ACTIVE_HIGH>;
		};
	};
};

&blsp1_uart3 {
	pinctrl-0 = <&serial_3_pins>;
	pinctrl-names = "default";
	status = "okay";
};

&tlmm {
	mdio_pins: mdio-pins {
		mdc {
			pins = "gpio64";
			function = "mdc";
			drive-strength = <8>;
			bias-pull-up;
		};

		mdio {
			pins = "gpio65";
			function = "mdio";
			drive-strength = <8>;
			bias-pull-up;
		};
	};

	leds_pins: leds_pins {
		mux {
			pins = "gpio35", "gpio37",
				"gpio58", "gpio70",
				"gpio73", "gpio74";
			function = "gpio";
			drive-strength = <8>;
			bias-pull-down;
		};
	};
};

&mdio {
	status = "okay";
	pinctrl-0 = <&mdio_pins>;
	pinctrl-names = "default";
	reset-gpios = <&tlmm 75 GPIO_ACTIVE_LOW>;
	reset-delay-us = <10000>;
	reset-post-delay-us = <50000>;

	ethernet-phy-package@0 {
		#address-cells = <1>;
		#size-cells = <0>;
		compatible = "qcom,qca8075-package";
		reg = <0>;

		qcom,package-mode = "psgmii";

		qca8075_0: ethernet-phy@0 {
			compatible = "ethernet-phy-ieee802.3-c22";
			reg = <0>;
		};

		qca8075_1: ethernet-phy@1 {
			compatible = "ethernet-phy-ieee802.3-c22";
			reg = <1>;
		};

		qca8075_2: ethernet-phy@2 {
			compatible = "ethernet-phy-ieee802.3-c22";
			reg = <2>;
		};

		qca8075_3: ethernet-phy@3 {
			compatible = "ethernet-phy-ieee802.3-c22";
			reg = <3>;
		};

		qca8075_4: ethernet-phy@4 {
			compatible = "ethernet-phy-ieee802.3-c22";
			reg = <4>;
		};
	};
};

&switch {
	status = "okay";

	switch_lan_bmp = <(ESS_PORT1 | ESS_PORT2 | ESS_PORT4)>; /* lan port bitmap */
	switch_wan_bmp = <ESS_PORT5>; /* wan port bitmap */
	switch_mac_mode = <MAC_MODE_PSGMII>; /* mac mode for uniphy instance0 */

	qcom,port_phyinfo {
		port@1 {
			port_id = <1>;
			phy_address = <0>;
		};

		port@2 {
			port_id = <2>;
			phy_address = <1>;
		};

		port@4 {
			port_id = <4>;
			phy_address = <3>;
		};

		port@5 {
			port_id = <5>;
			phy_address = <4>;
		};
	};
};

&dp1 {
	status = "okay";
	phy-handle = <&qca8075_0>;
	label = "lan1";
};

&dp2 {
	status = "okay";
	phy-handle = <&qca8075_1>;
	label = "lan2";
};

&dp4 {
	status = "okay";
	phy-handle = <&qca8075_3>;
	label = "lan3";
};

&dp5 {
	status = "okay";
	phy-handle = <&qca8075_4>;
	phy-mode = "psgmii";
	label = "wan";
};

&qpic_bam {
	status = "okay";
};

&qpic_nand {
	status = "okay";

	nand@0 {
		reg = <0>;

		nand-ecc-strength = <4>;
		nand-ecc-step-size = <512>;
		nand-bus-width = <8>;
	};
};

&prng {
	status = "okay";
};

&cryptobam {
	status = "okay";
};

&crypto {
	status = "okay";
};

&qusb_phy_0 {
	status = "okay";
};

&qusb_phy_1 {
	status = "okay";
};

&ssphy_0 {
	status = "okay";
};

&usb3 {
	status = "okay";
};

&usb2 {
	status = "okay";
};

&edma {
	status = "okay";
};

&CPU0 {
	/delete-property/ cpu-supply;
};

&CPU1 {
	/delete-property/ cpu-supply;
};

&CPU2 {
	/delete-property/ cpu-supply;
};

&CPU3 {
	/delete-property/ cpu-supply;
};
DTS

echo ">>> 追加 image profile: zn_m2"
cat >> "$SRC/target/linux/qualcommax/image/ipq60xx.mk" <<'MK'

define Device/zn_m2
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := ZN
	DEVICE_MODEL := M2
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	DEVICE_DTS_CONFIG := config@cp03-c1
	SOC := ipq6018
endef
TARGET_DEVICES += zn_m2
MK

echo ">>> 移除默认 WiFi 固件包（无 WiFi 版本）"
sed -i 's/^\tath11k-firmware-ipq6018$//' "$SRC/target/linux/qualcommax/ipq60xx/target.mk"
sed -i 's/^DEFAULT_PACKAGES += ath11k-firmware-ipq6018$//' "$SRC/target/linux/qualcommax/ipq60xx/target.mk"
sed -i 's/kmod-ath11k-ahb wpad-openssl/\\/' "$SRC/target/linux/qualcommax/Makefile"
sed -n '11,20p' "$SRC/target/linux/qualcommax/Makefile"
grep -n "DEFAULT_PACKAGES" -A6 "$SRC/target/linux/qualcommax/ipq60xx/target.mk" || true
echo ">>> 完成"
