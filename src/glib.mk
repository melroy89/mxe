# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := glib
$(PKG)_WEBSITE  := https://gtk.org/
$(PKG)_DESCR    := GLib
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.68.4
$(PKG)_CHECKSUM := 62fd061d08a75492617e625a73e2c05e259f831acbb8e1f8b9c81f23f7993a3b
$(PKG)_SUBDIR   := glib-$($(PKG)_VERSION)
$(PKG)_FILE     := glib-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://download.gnome.org/sources/glib/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_DEPS     := cc dbus gettext libffi libiconv pcre zlib $(BUILD)~$(PKG)
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS_$(BUILD) := meson-wrapper gettext libffi libiconv zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://gitlab.gnome.org/GNOME/glib/tags' | \
    $(SED) -n "s,.*<a [^>]\+>v\?\([0-9]\+\.[0-9.]\+\)<.*,\1,p" | \
    $(SORT) -Vr | \
    head -1
endef

define $(PKG)_BUILD_DARWIN
    # native build
    $(MXE_MESON_NATIVE_WRAPPER) --buildtype=release -Dtests=false '$(BUILD_DIR)' '$(SOURCE_DIR)' && \
    ninja -C '$(BUILD_DIR)' -j '$(JOBS)' && \
    ninja -C '$(BUILD_DIR)' -j '$(JOBS)' install

    #cd '$(SOURCE_DIR)' && NOCONFIGURE=true ./autogen.sh
    #cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
    #    $(MXE_CONFIGURE_OPTS) \
    #    --enable-regex \
    #    --disable-threads \
    #    --disable-selinux \
    #    --disable-inotify \
    #    --disable-fam \
    #    --disable-xattr \
    #    --disable-dtrace \
    #    --disable-libmount \
    #    --with-pcre=internal \
    #    PKG_CONFIG='$(PREFIX)/$(TARGET)/bin/pkgconf' \
    #    CPPFLAGS='-I$(PREFIX)/$(TARGET).gnu/include' \
    #    LDFLAGS='-L$(PREFIX)/$(TARGET).gnu/lib'
    #$(MAKE) -C '$(BUILD_DIR)/glib'    -j '$(JOBS)'
    #$(MAKE) -C '$(BUILD_DIR)/gthread' -j '$(JOBS)'
    #$(MAKE) -C '$(BUILD_DIR)/gmodule' -j '$(JOBS)'
    #$(MAKE) -C '$(BUILD_DIR)/gobject' -j '$(JOBS)' lib_LTLIBRARIES= install-exec
    #$(MAKE) -C '$(BUILD_DIR)/gio/xdgmime'     -j '$(JOBS)'
    #$(MAKE) -C '$(BUILD_DIR)/gio/kqueue'      -j '$(JOBS)'
    #$(MAKE) -C '$(BUILD_DIR)/gio'     -j '$(JOBS)' glib-compile-schemas
    #$(MAKE) -C '$(BUILD_DIR)/gio'     -j '$(JOBS)' glib-compile-resources
    #$(INSTALL) -m755 '$(BUILD_DIR)/gio/glib-compile-schemas' '$(PREFIX)/$(TARGET)/bin/'
    #$(INSTALL) -m755 '$(BUILD_DIR)/gio/glib-compile-resources' '$(PREFIX)/$(TARGET)/bin/'
endef

define $(PKG)_BUILD_NATIVE
    # native build
    $(MXE_MESON_NATIVE_WRAPPER) --buildtype=release -Dtests=false '$(BUILD_DIR)' '$(SOURCE_DIR)' && \
    ninja -C '$(BUILD_DIR)' -j '$(JOBS)' && \
    ninja -C '$(BUILD_DIR)' -j '$(JOBS)' install

    # OLD:
    #cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
    #    $(MXE_CONFIGURE_OPTS) \
    #    --enable-regex \
    #    --disable-threads \
    #    --disable-selinux \
    #    --disable-inotify \
    #    --disable-fam \
    #    --disable-xattr \
    #    --disable-dtrace \
    #    --disable-libmount \
    #    --with-libiconv=gnu \
    #    --with-pcre=internal \
    #    PKG_CONFIG='$(PREFIX)/$(TARGET)/bin/pkgconf' \
    #    CPPFLAGS='-I$(PREFIX)/$(TARGET)/include' \
    #    LDFLAGS='-L$(PREFIX)/$(TARGET)/lib'
    #$(SED) -i 's,#define G_ATOMIC.*,,' '$(BUILD_DIR)/config.h'
    #$(MAKE) -C '$(BUILD_DIR)/glib'    -j '$(JOBS)'
    #$(MAKE) -C '$(BUILD_DIR)/gthread' -j '$(JOBS)'
    #$(MAKE) -C '$(BUILD_DIR)/gmodule' -j '$(JOBS)'
    #$(MAKE) -C '$(BUILD_DIR)/gobject' -j '$(JOBS)' lib_LTLIBRARIES= install-exec
    #$(MAKE) -C '$(BUILD_DIR)/gio/xdgmime'     -j '$(JOBS)'
    #$(MAKE) -C '$(BUILD_DIR)/gio'     -j '$(JOBS)' glib-compile-schemas
    #$(MAKE) -C '$(BUILD_DIR)/gio'     -j '$(JOBS)' glib-compile-resources
    #$(INSTALL) -m755 '$(BUILD_DIR)/gio/glib-compile-schemas' '$(PREFIX)/$(TARGET)/bin/'
    #$(INSTALL) -m755 '$(BUILD_DIR)/gio/glib-compile-resources' '$(PREFIX)/$(TARGET)/bin/'
endef

define $(PKG)_BUILD_$(BUILD)
    $(if $(findstring darwin, $(BUILD)), \
        $($(PKG)_BUILD_DARWIN), \
        $($(PKG)_BUILD_NATIVE))
endef

define $(PKG)_BUILD
    # other packages expect glib-tools in $(TARGET)/bin
    # Q: Still needed?
    rm -f  '$(PREFIX)/$(TARGET)/bin/glib-*'
    ln -sf '$(PREFIX)/$(BUILD)/bin/glib-genmarshal'        '$(PREFIX)/$(TARGET)/bin/'
    ln -sf '$(PREFIX)/$(BUILD)/bin/glib-compile-schemas'   '$(PREFIX)/$(TARGET)/bin/'
    ln -sf '$(PREFIX)/$(BUILD)/bin/glib-compile-resources' '$(PREFIX)/$(TARGET)/bin/'

    # cross build with posix threads
    $(MXE_MESON_WRAPPER) --buildtype=release -Dtests=false -Dthreads=true '$(BUILD_DIR)' '$(SOURCE_DIR)' && \
    ninja -C '$(BUILD_DIR)' -j '$(JOBS)' && \
    ninja -C '$(BUILD_DIR)' -j '$(JOBS)' install

    #cd '$(SOURCE_DIR)' && NOCONFIGURE=true ./autogen.sh
    #cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
    #    $(MXE_CONFIGURE_OPTS) \
    #    --with-threads=win32 \
    #    --with-pcre=system \
    #    --with-libiconv=gnu \
    #    --disable-inotify \
    #    CXX='$(TARGET)-g++' \
    #    PKG_CONFIG='$(PREFIX)/bin/$(TARGET)-pkg-config' \
    #    CFLAGS='-Wno-incompatible-pointer-types -Wno-deprecated-declarations -Wno-format' \
    #    GLIB_GENMARSHAL='$(PREFIX)/$(TARGET)/bin/glib-genmarshal' \
    #    GLIB_COMPILE_SCHEMAS='$(PREFIX)/$(TARGET)/bin/glib-compile-schemas' \
    #    GLIB_COMPILE_RESOURCES='$(PREFIX)/$(TARGET)/bin/glib-compile-resources'
    #$(MAKE) -C '$(BUILD_DIR)/glib'    -j '$(JOBS)' install sbin_PROGRAMS= noinst_PROGRAMS=
    #$(MAKE) -C '$(BUILD_DIR)/gmodule' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
    #$(MAKE) -C '$(BUILD_DIR)/gthread' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
    #$(MAKE) -C '$(BUILD_DIR)/gobject' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
    #$(MAKE) -C '$(BUILD_DIR)/gio'     -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS= MISC_STUFF=
    #$(MAKE) -C '$(BUILD_DIR)'         -j '$(JOBS)' install-pkgconfigDATA
    #$(MAKE) -C '$(BUILD_DIR)/m4macros' install
endef
