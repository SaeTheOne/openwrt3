#!/bin/bash

# 执行自定义脚本 - diy-part2.sh
echo "🔧 执行自定义脚本 - diy-part2.sh"

# 修改默认IP地址
echo "📝 修改默认IP地址为10.0.0.1"
sed -i 's/192.168.1.1/10.0.0.1/' package/base-files/files/bin/config_generate

# 移除一些不必要的软件包
echo "🧹 移除不必要的软件包"
rm -rf feeds/luci/themes/luci-theme-argon

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

# 调整系统设置
echo "⚙️ 调整系统设置"
sed -i 's/\t$//g' package/base-files/files/etc/banner

# 更新软件包缓存
echo "🔄 更新软件包缓存"
# ./scripts/feeds update -a
# ./scripts/feeds install -a

echo "✅ diy-part2.sh 执行完成，自定义配置已应用"
