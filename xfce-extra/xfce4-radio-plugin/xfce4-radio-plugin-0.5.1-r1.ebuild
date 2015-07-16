# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils multilib 

DESCRIPTION="V4L radio device control plug-in for the Xfce desktop environment"
HOMEPAGE="http://goodies.xfce.org/projects/panel-plugins/xfce4-radio-plugin"
SRC_URI="mirror://xfce/src/panel-plugins/${PN}/${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
#IUSE="debug"

RDEPEND=">=xfce-base/libxfcegui4-4.8
        >=xfce-base/xfce4-panel-4.8"
DEPEND="${RDEPEND}
        dev-util/intltool
        virtual/pkgconfig"

WORKDIR="${S}"

src_prepare() {
        epatch "${FILESDIR}/${PN}-fix-libm-underlinking.patch"

}

src_configure() {
        xdt-autogen 
        econf --libexecdir="${EPREFIX}"/usr/$(get_libdir)
        emake DESTDIR="${D}" install
        dodoc  AUTHORS NEWS README 
}

