# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Kazakh dictionaries for myspell/hunspell"
HOMEPAGE="http://hunspell.sourceforge.net/"
SRC_URI="https://github.com/kergalym/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
KEYWORDS="~x86 ~amd64"

src_install() {
	insinto "/usr/share/myspell"
	doins kk_KZ.dic kk_KZ.aff
	doins kk_noun_adj.aff kk_noun_adj.dic
	doins kk_test.aff kk_test.dic
	dodoc README_kk_KZ.txt
}
