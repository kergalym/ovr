# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils gnome2-utils games versionator

MY_PN="AssaultCube"
DESCRIPTION="Fast and fun first-person-shooter based on the Cube fps"
HOMEPAGE="http://assault.cubers.net"
SRC_URI="mirror://sourceforge/actiongame/AssaultCube%20Version%20${PV}/${MY_PN}_v${PV}.tar.bz2"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dedicated doc server"

RDEPEND="
	>=net-libs/enet-1.3.0:1.3
	sys-libs/zlib
	!dedicated? (
		media-libs/libsdl[X,opengl,video]
		media-libs/libogg
		media-libs/libvorbis
		media-libs/openal
		media-libs/sdl-image[jpeg,png]
		virtual/opengl
		x11-libs/libX11
	)"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S=${WORKDIR}/AssaultCube_v${PV}

src_prepare() {
	# epatch "${FILESDIR}"/${PN}-1.2.0.2-QA.patch
	# remove unsued stuff
	rm -r bin_unix/* || die
	#find packages -name readme.txt -delete || die

	# respect FHS and fix binary name
	sed -i s'/CXX=clang++/#CXX=clang++/'g source/src/Makefile
	sed -i s'/CXXFLAGS= -O3 -fomit-frame-pointer/CXXFLAGS= $(EXTRA_CXXFLAGS) -fomit-frame-pointer/'g source/src/Makefile
	sed -i "/^CUBE_DIR/s|=.*|=\"${GAMES_DATADIR}/${PN}\"|" ${PN}.sh server.sh || die
}

src_compile() {
	BUNDLED_ENET=YES \
		emake -C source/src \
		$(usex dedicated "" "client") \
		$(usex dedicated "server" "$(usex server "server" "")")
}

src_install() {
	insinto "${GAMES_DATADIR}/${PN}"
	doins -r bin_unix config demos mods packages screenshots

	if ! use dedicated ; then
		exeinto "${GAMES_DATADIR}"/${PN}/bin_unix
		newexe source/src/ac_client native_client
		newgamesbin ${PN}.sh ${PN}
		make_desktop_entry ${PN} ${MY_PN} ${PN}
	fi

	if use dedicated || use server ; then
		exeinto "${GAMES_DATADIR}"/${PN}/bin_unix
		newexe source/src/ac_server native_server 
		newgamesbin server.sh ${PN}-server
		make_desktop_entry ${PN}-server "${MY_PN} Server" ${PN}
	fi

	doicon -s 48 "${FILESDIR}"/${PN}.png
	doicon -s 48 "${FILESDIR}"/${PN}.desktop

	if use doc ; then
		rm -r docs/autogen || die
		dohtml -r docs/*
	fi

	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	games_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
