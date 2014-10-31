# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="Graphic driver switcher"
HOMEPAGE=""
SRC_URI="" 

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${FILESDIR}"

DEPEND="${RDEPEND}" 

src_install() {

 dodir "/usr/bin"
 insinto "/usr/bin"
 doins "${S}/drvconf" || die
 doins "${S}/drvconf.py" || die
 
 dodir "/usr/share/drvconf/images"
 insinto "/usr/share/drvconf/images"
 doins "${S}/graphic_card_logo.png" || die
 
 dodir "/usr/share/applications"
 insinto "/usr/share/applications"
 doins "${S}/drvconf.desktop" || die

}
 
#pkg_postinst() {
 
#}
