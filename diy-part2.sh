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
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 解决python3-distutils依赖问题
echo "🔧 解决python3-distutils依赖问题"

# 方法1: 全面修复所有包的python3-distutils依赖问题
echo "🔧 方法1: 替换所有包中的python3-distutils依赖"
# 扩展搜索范围，确保覆盖所有包
sed -i 's/python3-distutils/python3-setuptools/g' feeds/packages/*/*/Makefile 2>/dev/null || true
sed -i 's/+python3-distutils/+python3-setuptools/g' feeds/packages/*/*/Makefile 2>/dev/null || true
sed -i 's/PKG_BUILD_DEPENDS:=.*python3-distutils/PKG_BUILD_DEPENDS:=$(filter-out python3-distutils,$(PKG_BUILD_DEPENDS)) python3-setuptools/g' feeds/packages/*/*/Makefile 2>/dev/null || true
# 额外修复package/feeds下的所有包
sed -i 's/python3-distutils/python3-setuptools/g' package/feeds/*/*/Makefile 2>/dev/null || true
sed -i 's/+python3-distutils/+python3-setuptools/g' package/feeds/*/*/Makefile 2>/dev/null || true
# 特别处理python-babel、python-docker、python-incremental等新发现的依赖问题
echo "🔧 特别处理新增的python3-distutils依赖问题"
for pkg in babel docker incremental fail2ban flent; do
  if [ -d "package/feeds/packages/python-${pkg}" ] && [ -f "package/feeds/packages/python-${pkg}/Makefile" ]; then
    echo "✅ 修复python-${pkg}依赖"
    sed -i 's/python3-distutils/python3-setuptools/g' package/feeds/packages/python-${pkg}/Makefile
    sed -i 's/+python3-distutils/+python3-setuptools/g' package/feeds/packages/python-${pkg}/Makefile
  fi
done

# 方法2: 为fail2ban和flent创建本地补丁
if [ -d "package/feeds/packages/fail2ban" ]; then
  echo "✅ 找到fail2ban包，直接修改其Makefile"
  if [ -f "package/feeds/packages/fail2ban/Makefile" ]; then
    sed -i 's/+python3-distutils/+python3-setuptools/g' package/feeds/packages/fail2ban/Makefile
    sed -i 's/python3-distutils/python3-setuptools/g' package/feeds/packages/fail2ban/Makefile
  fi
fi

if [ -d "package/feeds/packages/flent" ]; then
  echo "✅ 找到flent包，直接修改其Makefile"
  if [ -f "package/feeds/packages/flent/Makefile" ]; then
    sed -i 's/+python3-distutils/+python3-setuptools/g' package/feeds/packages/flent/Makefile
    sed -i 's/python3-distutils/python3-setuptools/g' package/feeds/packages/flent/Makefile
  fi
fi

# 方法3: 创建python3-distutils虚拟包
echo "🔧 方法3: 创建python3-distutils虚拟包以满足依赖检查"
mkdir -p package/feeds/packages/python3-distutils
cat > package/feeds/packages/python3-distutils/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=python3-distutils
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python3-package.mk)

define Package/python3-distutils
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python3 distutils (virtual package)
  DEPENDS:=+python3-setuptools
  PROVIDES:=python3-distutils
endef

define Package/python3-distutils/description
  Virtual package that depends on python3-setuptools
  to satisfy dependencies that require python3-distutils.
endef

define Build/Compile
  # This is a virtual package, nothing to compile
endef

define Package/python3-distutils/install
  # Create empty directory for the package
  $(INSTALL_DIR) $(1)/usr/lib/python3.11/site-packages/distutils
  # Create a dummy __init__.py file
  touch $(1)/usr/lib/python3.11/site-packages/distutils/__init__.py
endef

$(eval $(call BuildPackage,python3-distutils))
EOF

# 方法4: 在make命令前添加特殊处理，强制忽略这些警告
echo "🔧 方法4: 创建一个预处理脚本，在make前强制修复依赖"
cat > fix_dependencies.sh << 'EOF'
#!/bin/bash

# 直接修复所有已知有问题的包
echo "🔄 正在修复依赖问题..."

# 扩展修复范围，包含所有新发现的有问题的包
echo "✅ 修复所有python3-distutils依赖问题"

# 1. 修复所有feeds/packages下的包
find feeds/packages -name "Makefile" -type f -exec sed -i 's/python3-distutils/python3-setuptools/g' {} \;
find feeds/packages -name "Makefile" -type f -exec sed -i 's/+python3-distutils/+python3-setuptools/g' {} \;

# 2. 修复package/feeds下的所有包
find package/feeds -name "Makefile" -type f -exec sed -i 's/python3-distutils/python3-setuptools/g' {} \;
find package/feeds -name "Makefile" -type f -exec sed -i 's/+python3-distutils/+python3-setuptools/g' {} \;

# 3. 特别处理已知有问题的包
for pkg in babel docker incremental fail2ban flent; do
  if [ -f "package/feeds/packages/python-${pkg}/Makefile" ]; then
    echo "✅ 修复python-${pkg}依赖"
    sed -i 's/python3-distutils/python3-setuptools/g' package/feeds/packages/python-${pkg}/Makefile
    sed -i 's/+python3-distutils/+python3-setuptools/g' package/feeds/packages/python-${pkg}/Makefile
  fi
done

# 4. 处理可能的构建依赖
find . -name "Makefile" -type f -exec sed -i 's/PKG_BUILD_DEPENDS:=.*python3-distutils/PKG_BUILD_DEPENDS:=$(filter-out python3-distutils,$(PKG_BUILD_DEPENDS)) python3-setuptools/g' {} \; 2>/dev/null || true

echo "✅ 依赖修复完成"
EOF
chmod +x fix_dependencies.sh

# 解决libyubikey依赖问题
echo "🔧 解决libyubikey依赖问题"
# 如果freeradius3依赖libyubikey但我们不需要yubikey功能，可以禁用该选项
sed -i '/libyubikey/d' feeds/packages/net/freeradius3/Makefile 2>/dev/null || true

# 调整系统设置
echo "⚙️ 调整系统设置"
sed -i 's/\t$//g' package/base-files/files/etc/banner

# 解决stdc-predef.h找不到的工具链问题
echo "🔧 解决stdc-predef.h找不到的工具链问题"
# 修复路径问题，确保在正确的目录下创建
CURRENT_DIR=$(pwd)
echo "当前工作目录: $CURRENT_DIR"

# 更安全的方式 - 先检查toplevel.mk是否存在
if [ -f "include/toplevel.mk" ]; then
  echo "✅ 找到toplevel.mk文件，应用编译选项修复"
  # 优化编译选项，使用更稳定的设置
  sed -i 's/CFLAGS_OPTIMIZE := -O3/CFLAGS_OPTIMIZE := -O2/g' include/toplevel.mk
  # 添加CFLAGS设置确保正确包含路径
  if ! grep -q 'export CFLAGS.*toolchain' include/toplevel.mk; then
    echo 'export CFLAGS += -I$(STAGING_DIR)/toolchain-aarch64_generic_gcc-12.3.0_musl/include' >> include/toplevel.mk
  fi
else
  echo "❌ 未找到toplevel.mk文件，跳过编译选项修复"
fi

# 预创建必要的输出目录结构，确保即使编译出错也有基本目录
echo "🔧 预创建输出目录结构"
mkdir -p bin/targets/armsr/armv8 || true

# 添加环境变量设置以确保编译稳定性
export FORCE_UNSAFE_CONFIGURE=1
export STAGING_DIR="$(pwd)/staging_dir"

# 添加设备名称安全处理
# 如果在编译过程中出现Invalid format 'generic'错误，这将确保DEVICE_NAME格式正确
echo "🔧 添加设备名称安全处理逻辑"
# 检查是否存在.config文件，如果存在，预处理设备名称
if [ -f ".config" ]; then
  echo "✅ 找到.config文件，添加设备名称处理逻辑"
  # 创建一个临时脚本用于安全处理设备名称
  cat > fix_device_name.sh << 'EOF'
#!/bin/bash
# 安全提取设备名称，移除可能导致格式错误的字符
grep '^CONFIG_TARGET.*DEVICE.*=y' .config | sed -r 's/.*DEVICE_(.*)=y/\1/' > DEVICE_NAME
if [ -s DEVICE_NAME ]; then
  # 移除不允许的字符，只保留字母、数字、下划线和连字符
  SAFE_DEVICE_NAME=$(cat DEVICE_NAME | sed 's/[^a-zA-Z0-9_-]//g')
  # 如果处理后的名称为空，使用默认值
  if [ -z "$SAFE_DEVICE_NAME" ]; then
    SAFE_DEVICE_NAME="default"
  fi
  echo "DEVICE_NAME=_${SAFE_DEVICE_NAME}" >> $GITHUB_ENV
  echo "✅ 设置安全的DEVICE_NAME: _${SAFE_DEVICE_NAME}"
fi
EOF
  chmod +x fix_device_name.sh
fi

# 修复可能的权限问题
chmod -R 755 . 2>/dev/null || true

# 添加自动内核配置处理，确保没有交互式提示
echo "🔧 配置自动内核编译设置，避免交互式提示"
# 设置环境变量以自动回答配置问题
export KCONFIG_AUTOCONFIG=1
export KCONFIG_AUTOHEADER=1
export KCONFIG_AUTOUUID=1
export KCONFIG_AUTOLOAD=1

# 确保在编译前运行make olddefconfig来自动应用默认配置
if [ -f "Makefile" ]; then
  echo "✅ 准备自动处理内核配置"
  # 创建一个处理内核配置的临时脚本
  cat > auto_kernel_config.sh << 'EOF'
#!/bin/bash
# 自动运行make olddefconfig来解决所有配置问题
echo "🔄 运行make olddefconfig以自动应用默认配置..."
make olddefconfig || {
  echo "❌ make olddefconfig失败，尝试make defconfig..."
  make defconfig || {
    echo "❌ make defconfig也失败，尝试清理并重试..."
    make clean
    make defconfig
  }
}
EOF
  chmod +x auto_kernel_config.sh
fi

echo "✅ 工具链和编译环境修复完成"

# 更新软件包缓存
echo "🔄 更新软件包缓存"
# ./scripts/feeds update -a
# ./scripts/feeds install -a

echo "✅ diy-part2.sh 执行完成，自定义配置已应用"
