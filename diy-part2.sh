#!/bin/bash

# 执行自定义脚本 - diy-part2.sh
echo "🔧 执行自定义脚本 - diy-part2.sh"

# 修改默认IP地址
echo "📝 修改默认IP地址为10.0.0.1"
sed -i 's/192.168.1.1/10.0.0.1/' package/base-files/files/bin/config_generate

# 移除一些不必要的软件包
echo "🧹 移除不必要的软件包"
# 不再删除luci-theme-argon，因为有其他包依赖它

# 克隆自定义软件包
echo "📦 克隆自定义软件包"
# git clone https://github.com/lisaac/luci-app-dockerman.git package/luci-app-dockerman
# git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome

# 修改默认主机名
# echo "🏠 修改默认主机名为OpenWrt"
# sed -i 's/OpenWrt/OpenWrt/' package/base-files/files/bin/config_generate

# 修改默认主题
echo "🎨 设置默认主题"
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 解决python3-distutils依赖问题
echo "🔧 解决python3-distutils依赖问题"
# 由于immortalwrt的feeds中可能没有python3-distutils，我们需要创建一个符号链接或修改依赖关系
sed -i 's/python3-distutils/python3-setuptools/g' feeds/packages/lang/python/*/Makefile 2>/dev/null || true

# 解决libyubikey依赖问题
echo "🔧 解决libyubikey依赖问题"
# 如果freeradius3依赖libyubikey但我们不需要yubikey功能，可以禁用该选项
sed -i '/libyubikey/d' feeds/packages/net/freeradius3/Makefile 2>/dev/null || true

# 调整系统设置
echo "⚙️ 调整系统设置"
sed -i 's/\t$//g' package/base-files/files/etc/banner

# 解决stdc-predef.h找不到的工具链问题
echo "🔧 解决stdc-predef.h找不到的工具链问题"
# 创建一个包含必要头文件的目录结构
mkdir -p staging_dir/toolchain-aarch64_generic_gcc-12.3.0_musl/include
# 创建一个空的stdc-predef.h文件
 touch staging_dir/toolchain-aarch64_generic_gcc-12.3.0_musl/include/stdc-predef.h
# 或者通过修改编译选项来避免这个错误
sed -i 's/CFLAGS_OPTIMIZE := -O3/CFLAGS_OPTIMIZE := -O2 -isystem\$(STAGING_DIR)\/toolchain-*/include/g' include/toplevel.mk 2>/dev/null || true
# 确保工具链包含路径正确设置
echo 'export CFLAGS += -I$(STAGING_DIR)/toolchain-*/include' >> include/toplevel.mk 2>/dev/null || true

# 更新软件包缓存
echo "🔄 更新软件包缓存"
# ./scripts/feeds update -a
# ./scripts/feeds install -a

echo "✅ diy-part2.sh 执行完成，自定义配置已应用"
