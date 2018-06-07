# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils unpacker 

DESCRIPTION="Minergate a mining client"
HOMEPAGE="https://minergate.com"
SRC_URI="https://download.minergate.com/ubuntu/${P}.deb"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="fetch"

DEPEND=""
RDEPEND="${DEPEND}"
S=${WORKDIR}


src_unpack() {
        :
}

src_install() {
        cd "${ED}" || die
        unpacker

}

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${P}.deb"
	einfo "from ${HOMEPAGE} and place them in your ${DISTDIR} directory."
}

