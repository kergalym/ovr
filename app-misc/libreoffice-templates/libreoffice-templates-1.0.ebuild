# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="LibreOffice Templates"
HOMEPAGE=""
SRC_URI="" 

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${FILESDIR}"

DEPEND="${RDEPEND}" 

src_install() {

 dodir "/usr/share/templates/"
 insinto "/usr/share/templates/"
 doins "${S}/LibreOffice-Calc.desktop" || die
 doins "${S}/LibreOffice-Draw.desktop" || die
 doins "${S}/LibreOffice-Impress.desktop" || die
 doins "${S}/LibreOffice-Writer.desktop" || die
 
 dodir "/usr/share/templates/.source"
 insinto "/usr/share/templates/.source"
 doins "${S}/.source/IllustrationDocument.odg" || die
 doins "${S}/.source/Praesentation.odp" || die
 doins "${S}/.source/TableDocument.ods" || die
 doins "${S}/.source/TextDocument.odt" || die


}
 
#pkg_postinst() {
 
#}
