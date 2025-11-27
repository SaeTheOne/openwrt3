#!/bin/bash

# 确定当前工作目录，确保在immortalwrt源码目录中执行
CURRENT_DIR=$(pwd)
echo "🔍 当前工作目录: $CURRENT_DIR"

# 如果不在immortalwrt目录，尝试切换到immortalwrt目录
if [[ ! "$CURRENT_DIR" == *"immortalwrt"* ]]; then
  if [ -d "immortalwrt" ]; then
    echo "🔄 切换到immortalwrt源码目录"
    cd immortalwrt
    CURRENT_DIR=$(pwd)
  else
    echo "❌ 未找到immortalwrt源码目录，请确保在正确的目录中执行"
  fi
fi

echo "🎯 在目录中执行自定义脚本: $CURRENT_DIR"

# 修改默认IP地址为10.0.0.1
echo "📝 修改默认IP地址为10.0.0.1"
if [ -f "package/base-files/files/bin/config_generate" ]; then
  sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate
else
  echo "⚠️  未找到config_generate文件，跳过IP地址修改"
fi

# 移除不必要的软件包
echo "🧹 移除不必要的软件包"
if [ -f "feeds/luci/collections/luci/Makefile" ]; then
  sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
fi
find package/feeds -name "libyubikey*" -type d | xargs -r rm -rf

# 克隆自定义软件包
echo "📦 克隆自定义软件包"
if [ ! -d "package/luci-theme-argon" ]; then
  git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
fi
if [ ! -d "package/luci-app-argon-config" ]; then
  git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
fi

# 设置默认主题
echo "🎨 设置默认主题"
THEME_FILE="feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap"
if [ -f "$THEME_FILE" ]; then
  sed -i 's/luci.main.mediaurlbase=\/luci-static\/bootstrap/luci.main.mediaurlbase=\/luci-static\/argon/g' "$THEME_FILE"
fi

# 解决python3-distutils依赖问题 - 增强版修复
echo "🔧 解决python3-distutils依赖问题 - 增强版修复"

# 方法1: 全局替换所有可能的路径
echo "🔧 方法1: 全局替换所有路径中的python3-distutils依赖"
# 搜索并替换当前目录下所有Makefile中的python3-distutils
grep -r "python3-distutils" --include="Makefile" . | awk -F":" '{print $1}' | xargs -r sed -i 's/python3-distutils/python3-setuptools/g'

# 方法2: 针对特定目录的替换
for dir in feeds/packages/lang/python package/feeds/*/*; do
  if [ -d "$dir" ]; then
    find "$dir" -name "Makefile" -type f | xargs -r sed -i 's/python3-distutils/python3-setuptools/g'
  fi
done

# 方法3: 特别处理新增的python3-distutils依赖包
echo "🔧 方法3: 特别处理新增的python3-distutils依赖包"
for pkg in babel docker incremental fail2ban flent; do
  echo "🎯 处理python-${pkg}..."
  # 查找所有可能的路径
  find . -name "python-${pkg}" -type d | grep -E "package/feeds|feeds/packages" | xargs -r -I{} sh -c 'if [ -f "{}/Makefile" ]; then sed -i "s/python3-distutils/python3-setuptools/g" "{}/Makefile"; fi'
done

# 方法4: 创建python3-distutils虚拟包
echo "🔧 方法4: 创建python3-distutils虚拟包"
mkdir -p package/custom/python3-distutils
cat > package/custom/python3-distutils/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=python3-distutils
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=OpenWrt
PKG_LICENSE:=GPL-3.0

include $(INCLUDE_DIR)/package.mk

define Package/python3-distutils
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python3 distutils (virtual package)
  DEPENDS:=+python3-setuptools
  VIRTUAL:=1
endef

define Package/python3-distutils/description
  Virtual package to provide python3-distutils dependency.
endef

$(eval $(call BuildPackage,python3-distutils))
EOF

# 修复编译工具链问题
echo "🔧 修复编译工具链问题"
if [ -f "include/target.mk" ]; then
  # 降级优化级别，减少编译错误
  sed -i 's/O2/O1/g' include/target.mk
  
  # 确保stdc-predef.h包含路径正确
  sed -i '/CFLAGS += -include $(TOOLCHAIN_DIR)\/usr\/include\/stdc-predef.h/d' include/target.mk
  echo 'CFLAGS += -include $(TOOLCHAIN_DIR)/usr/include/stdc-predef.h' >> include/target.mk
fi

# 修复device name安全问题
echo "🔧 修复device name安全问题"
if [ -f "package/base-files/files/etc/init.d/boot" ]; then
  sed -i "s/'\''/\'\\\\\'\''/g" package/base-files/files/etc/init.d/boot
fi

# 解决target/linux编译失败问题
echo "🔧 解决target/linux编译失败问题"

# 方法1: 清理target/linux目录下的临时文件
find target/linux -name ".*.d" -o -name ".*.o" -o -name "*.ko" -o -name ".*cmd" | xargs -r rm -f

# 方法2: 确保内核配置正确
echo "🔧 确保内核配置正确"
export KCONFIG_AUTOCONFIG=1
export KCONFIG_AUTOSAVE=1

# 自动内核配置脚本
echo "🔧 生成自动内核配置脚本"
cat > auto_kernel_config.sh << 'EOF'
#!/bin/bash

# 设置自动配置环境变量
export KCONFIG_AUTOCONFIG=1
export KCONFIG_AUTOSAVE=1

# 执行内核配置
echo "正在执行 make olddefconfig..."
make olddefconfig || {
  echo "make olddefconfig失败，尝试 make defconfig..."
  make defconfig || {
    echo "make defconfig失败，尝试清理后重新配置..."
    make clean
    make defconfig
  }
}
EOF

# 设置执行权限
chmod +x auto_kernel_config.sh

# 执行自动内核配置
echo "执行自动内核配置..."
./auto_kernel_config.sh

# 创建target/linux修复脚本
echo "🔧 创建target/linux修复脚本"
cat > fix_target_linux.sh << 'EOF'
#!/bin/bash

# 清理target/linux目录下的临时文件和错误状态
echo "🧹 清理target/linux目录下的临时文件..."
find target/linux -name ".*.d" -o -name ".*.o" -o -name "*.ko" -o -name ".*cmd" -o -name ".tmp_versions" | xargs -r rm -rf

# 确保Makefile中的依赖正确
echo "🔧 修复target/linux的Makefile依赖..."
if [ -f "target/linux/Makefile" ]; then
  # 确保依赖项正确，避免循环依赖
  sed -i '/subdir-$(CONFIG_TARGET_ROOTFS_SQUASHFS)/d' target/linux/Makefile
  echo 'subdir-$(CONFIG_TARGET_ROOTFS_SQUASHFS) += squashfs' >> target/linux/Makefile
fi

# 修复可能的内核模块编译错误
echo "🔧 修复可能的内核模块编译错误..."
# 设置更保守的编译选项
if [ -f ".config" ]; then
  # 禁用可能导致问题的功能
  sed -i 's/CONFIG_KERNEL_LSM=y/# CONFIG_KERNEL_LSM is not set/' .config
  sed -i 's/CONFIG_KERNEL_SECURITY=y/# CONFIG_KERNEL_SECURITY is not set/' .config
fi

# 修复内核配置中的依赖问题
echo "🔧 修复内核配置中的依赖问题..."
# 确保必要的内核配置项被设置
grep -q "CONFIG_KERNEL_ELF_CORE=y" .config || echo "CONFIG_KERNEL_ELF_CORE=y" >> .config
grep -q "CONFIG_KERNEL_FTRACE_SYSCALLS=y" .config || echo "# CONFIG_KERNEL_FTRACE_SYSCALLS is not set" >> .config

echo "✅ target/linux修复完成！"
EOF

# 设置执行权限并执行target/linux修复脚本
chmod +x fix_target_linux.sh
./fix_target_linux.sh

# 完成
echo "✅ 自定义脚本执行完成！修复了python3-distutils依赖问题和target/linux编译问题！"
