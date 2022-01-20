# This file is part of MXE. See LICENSE.md for licensing information.
PKG             := qtservice
$(PKG)_WEBSITE  := https://qt.gitorious.org/qt-solutions/
$(PKG)_DESCR    := Qt Solutions
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 11730d4
$(PKG)_CHECKSUM := 4c5a0d9454b2981b547264d92f31df578c93e71c03c73ff163c1d55a04f74847
$(PKG)_SUBDIR   := qtproject-qt-solutions-$($(PKG)_VERSION)
$(PKG)_FILE     := qt-solutions-$($(PKG)_VERSION).tar.gz
$(PKG)_URL      := https://github.com/qtproject/qt-solutions/tarball/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := cc qtbase

define $(PKG)_UPDATE
    echo 'Warning: Updates are temporarily disabled for package qtservice.' >&2;
    echo $(qtservice_VERSION)
endef

define $(PKG)_BUILD
    cd '$(1)/qtservice/buildlib' && '$(PREFIX)/$(TARGET)/qt5/bin/qmake' \
        '-after' \
        'CONFIG -= dll debug_and_release build_all' \
        'CONFIG += create_prl create_pc' \
        'QMAKE_PKGCONFIG_DESTDIR = pkgconfig' \
        'DESTDIR =' \
        'DLLDESTDIR =' \
        'headers.path = $$$$[QT_INSTALL_HEADERS]' \
        'headers.files += ../src/qtservice.h' \
        'win32:dlltarget.path = $$$$[QT_INSTALL_BINS]' \
        'target.path = $$$$[QT_INSTALL_LIBS]' \
        '!static:win32:target.CONFIG = no_dll' \
        'win32:INSTALLS += dlltarget' \
        'INSTALLS += target headers'
    $(MAKE) -C '$(1)/qtservice/buildlib' -j '$(JOBS)'
    $(MAKE) -C '$(1)/qtservice/buildlib' -j 1 install
endef
