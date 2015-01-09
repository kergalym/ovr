# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: 

EAPI=5
inherit eutils git-r3 qmake-utils 

DESCRIPTION="Kvantum is an SVG-based theme engine for Qt4/Qt5 and KDE"
HOMEPAGE="http://kde-look.org/content/show.php/Kvantum?content=166241"
EGIT_REPO_URI="https://github.com/tsujan/Kvantum.git"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="qt4 qt5"

RDEPEND="qt4? ( dev-qt/qtcore:4 
		dev-qt/qtsvg:4 )
	qt5? ( dev-qt/qtcore:5
		dev-qt/qtsvg:5 )
	>=x11-libs/libX11-1.6.2" 
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S=${WORKDIR}/${P}/${V}/Kvantum

src_configure() {
    eqmake4 "${S}"/kvantum.pro
    emake 

}

src_install() {
    emake INSTALL_ROOT="${D}" DESTDIR="${D}" install 

}