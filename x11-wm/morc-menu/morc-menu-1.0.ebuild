# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 eutils

DESCRIPTION="categorized desktop application menu, independent of any window manager, highly and easily customizable"
HOMEPAGE="https://github.com/Boruch-Baum/morc_menu"
EGIT_REPO_URI="https://github.com/Boruch-Baum/morc_menu.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {

	emake DESTDIR="${D}" install

	dodoc LICENSE
}


