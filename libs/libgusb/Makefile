#
# Copyright (C) 2024 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libgusb
PKG_VERSION:=0.4.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/hughsie/libgusb/releases/download/$(PKG_VERSION)
PKG_HASH:=9df5ef301d6a4b361002aa52cce1165a87a89744055879bdbab31e7e86f1e846

PKG_MAINTAINER:=Lukas Voegl <lvoegl@tdt.de>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=glib2/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libgusb
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libgusb
  URL:=https://github.com/hughsie/libgusb
  DEPENDS:= \
	$(INTL_DEPENDS) \
	+glib2 \
	+json-glib \
	+libusb-1.0 \
	+usbids
endef

define Package/libgusb/description
  GUsb is a GObject wrapper for libusb1 that makes it easy to do asynchronous
  control, bulk and interrupt transfers with proper cancellation and
  integration into a mainloop.
endef

MESON_ARGS += \
	-Db_lto=true \
	-Dtests=false \
	-Dvapi=false \
	-Dusb_ids=/usr/share/hwdata/usb.ids \
	-Ddocs=false \
	-Dintrospection=false \
	-Dumockdev=disabled

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/gusb-1
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gusb-1/gusb.h $(1)/usr/include/gusb-1

	$(INSTALL_DIR) $(1)/usr/include/gusb-1/gusb
	$(CP) $(PKG_INSTALL_DIR)/usr/include/gusb-1/gusb/*.h $(1)/usr/include/gusb-1/gusb

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgusb.so* $(1)/usr/lib

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/gusb.pc $(1)/usr/lib/pkgconfig
endef

define Package/libgusb/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gusbcmd $(1)/usr/bin

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgusb.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libgusb))
