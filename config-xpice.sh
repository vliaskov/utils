#!/bin/bash
# needed xutils-dev or xorg-macros needed
# needed xproto fontsproto  randrproto renderproto videoproto xf86dgaproto
TEST=$1
for src in git://anongit.freedesktop.org/xorg/proto/xextproto \
git://anongit.freedesktop.org/xorg/proto/inputproto \
git://anongit.freedesktop.org/xorg/proto/xcmiscproto \
git://anongit.freedesktop.org/xorg/proto/bigreqsproto \
git://anongit.freedesktop.org/xorg/proto/compositeproto \
git://anongit.freedesktop.org/xorg/proto/recordproto \
git://anongit.freedesktop.org/xorg/lib/libXfont \
git://anongit.freedesktop.org/xorg/app/xkbcomp \
git://anongit.freedesktop.org/xorg/xserver \
git://anongit.freedesktop.org/xorg/lib/libxkbfile \
git://git.freedesktop.org/git/spice/spice-protocol \
git://anongit.freedesktop.org/git/xorg/util/macros xorg-macros \
git://anongit.freedesktop.org/xorg/driver/xf86-input-mouse \
git://anongit.freedesktop.org/xorg/driver/xf86-input-keyboard \
git://anongit.freedesktop.org/xorg/driver/xf86-input-evdev \
git://anongit.freedesktop.org/xorg/driver/xf86-video-qxl; do 
	git clone $src; 
done

#build and install into some non common prefix (not to overwrite
#your existing server) - note that this is just for testing. This
#should all work with the default server as well, but that server
#requires root generally and this is undesireable for testing (and
#running actually).

export PKG_CONFIG_PATH=${TEST}/lib/pkgconfig
(cd xextproto; ./autogen.sh --prefix=$TEST --without-xmlto && make install)
(cd pixman; ./autogen.sh --prefix=$TEST && make install)
(cd inputproto; ./autogen.sh --prefix=$TEST && make install)
(cd xcmiscproto; ./autogen.sh --prefix=$TEST && make install)
(cd bigreqsproto; ./autogen.sh --prefix=$TEST && make install)
(cd compositeproto; ./autogen.sh --prefix=$TEST && make install)
(cd recordproto; ./autogen.sh --prefix=$TEST && make install)
(cd libXfont; ./autogen.sh --prefix=$TEST && make install)
(cd inputproto; ./autogen.sh --prefix=$TEST && make install)
(cd xserver; ./autogen.sh --prefix=$TEST && make install)
(cd xkbcomp; ./autogen.sh --prefix=$TEST && make install)
(cd libxkbfile; ./autogen.sh --prefix=$TEST && make install)
(cd spice-protocol; ./autogen.sh --prefix=$TEST  --datadir=$TEST/lib && make install)
(cd xorg-macros; ./autogen.sh --prefix=$TEST  --datadir=$TEST/lib && make install)
(cd xf86-input-evdev; ./autogen.sh --prefix=$TEST && make install)
(cd xf86-input-mouse; ./autogen.sh --prefix=$TEST && make install)
(cd xf86-input-keyboard; ./autogen.sh --prefix=$TEST && make install)
(cd xf86-video-qxl; ./autogen.sh --prefix=$TEST && make install)

mkdir -p $TEST/etc/X11

mkdir -p $TEST/share/X11
cp -R /usr/share/X11/xkb $TEST/share/X11
cp $TEST/xf86-video-qxl/examples/spiceqxl.xorg.conf.example $TEST/etc/X11/spiceqxl.xorg.conf
