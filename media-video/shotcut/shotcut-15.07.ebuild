# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /usr/local/ovr/media-video/shotcut/shotcut-15.07.ebuild,v 15.07 2015/07/10 00:58:56 redeyedman Exp $

EAPI="5"

inherit eutils

DESCRIPTION="Shotcut is a free, open source, cross-platform video editor"
HOMEPAGE="http://www.shotcut.org"
SRC_URI="https://github.com/mltframework/${PN}/releases/download/v$PV/${PN}-src-150702.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE="+vorbis +theora +pulseaudio +ogg +flac +ffmpeg +x264 +lame +opus +vpx +landspa"
REQUIRED_USE="|| ( vorbis theora pulseaudio ogg flac ffmpeg x264 lame opus vpx landspa )"

DEPEND="
	dev-libs/libpthread-stubs
	sys-libs/libstdc++-v3
	x11-libs/libX11
	media-libs/alsa-lib
	dev-libs/libxml2 
	=media-sound/pulseaudio-2*
	dev-libs/glib:2
	dev-libs/gobject-introspection
	=media-libs/mlt-0.8.2
     	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtx11extras:5
	dev-qt/qtsql:5
	dev-qt/qtwebkit:5
	dev-qt/qtquickcontrols:5
	dev-qt/qtnetwork:5
	dev-qt/qtxml:5
	dev-qt/qtopengl:5
	dev-qt/qtwidgets:5
	dev-qt/qtconcurrent:5
	dev-qt/qtmultimedia:5
	dev-qt/qtprintsupport:5
	vorbis? (
		media-libs/libvorbis
		media-sound/vorbis-tools
	)
	theora? (
		media-libs/libtheora 
	)
	ogg? (
		media-libs/libogg
	)
	flac? (
		media-libs/flac
	)
	ffmpeg? (
		>=media-video/ffmpeg-1.2.6-r1
		media-plugins/frei0r-plugins
	) 
	x264? (
		media-libs/x264
	)
	vpx? (
		media-libs/libvpx
	)
	lame? (
		media-sound/lame 
	)
	opus? (
		media-libs/opus
	)
	landspa? (
		media-libs/ladspa-sdk
	)
"

RDEPEND="${DEPEND}"

src_prepare() {
	/usr/lib64/qt5/bin/qmake PREFIX=${D}/usr/
}

src_install() {
	dobin src/shotcut
	insinto /usr/share/shotcut
	doins -r src/qml
	newicon "${S}"/icons/shotcut-logo-64.png "${PN}".png
	make_desktop_entry shotcut "Shotcut"
#	emake PREFIX=/usr DESTDIR="${D}" install
}

