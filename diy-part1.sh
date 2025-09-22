#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"

sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default
./scripts/feeds update -a && rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang feeds/packages/lang/golang
rm -rf package/luci-app-amlogic
git clone https://github.com/ophub/luci-app-amlogic.git package/luci-app-amlogic
# 修复 Rust 编译时 LLVM 下载 404 错误：禁用 download-ci-llvm，使用本地 LLVM
echo "=== Fix Rust LLVM download error ==="
# 找到 Rust 编译的 config.toml 生成路径（对应 Rust 1.85.0，若版本不同需调整路径中的版本号）
RUST_CONFIG_PATH="feeds/packages/lang/rust/files/config.toml"
# 若 config.toml 存在，添加/修改 llvm 配置
if [ -f "$RUST_CONFIG_PATH" ]; then
    # 删除原有 download-ci-llvm 配置（若存在）
    sed -i '/\[llvm\]/,/^$/d' "$RUST_CONFIG_PATH"
    # 新增 llvm 配置：禁用下载，使用本地 LLVM
    cat >> "$RUST_CONFIG_PATH" << EOF
[llvm]
download-ci-llvm = false
# 使用 OpenWrt 本地构建的 LLVM（需确保 OpenWrt 已启用 LLVM 编译）
llvm-config = "\$(STAGING_DIR_HOST)/bin/llvm-config"
EOF
    echo "Successfully modified Rust config.toml: disable download-ci-llvm"
else
    echo "Warning: Rust config.toml not found, create new one"
    # 若 config.toml 不存在，直接创建
    mkdir -p "$(dirname $RUST_CONFIG_PATH)"
    cat > "$RUST_CONFIG_PATH" << EOF
[llvm]
download-ci-llvm = false
llvm-config = "\$(STAGING_DIR_HOST)/bin/llvm-config"
EOF
fi

# 额外确保 OpenWrt 启用 LLVM 依赖（若未启用）
echo "CONFIG_PACKAGE_llvm=y" >> .config
echo "CONFIG_PACKAGE_llvm-utils=y" >> .config
