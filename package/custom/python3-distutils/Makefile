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
