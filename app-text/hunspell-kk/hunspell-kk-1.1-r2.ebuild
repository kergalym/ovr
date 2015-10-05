# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils git-r3

MY_P=${PN}-${PV/_beta/b}

DESCRIPTION=" Kazakh dictionaries for myspell/hunspell"
EGIT_REPO_URI="https://github.com/kergalym/hunspell-kk.git"
HOMEPAGE="http://hunspell.sourceforge.net/"

SLOT="0"
LICENSE="MPL-1.1 GPL-2 LGPL-2.1"
IUSE="ncurses nls readline static-libs"
KEYWORDS="alpha amd64 arm ~arm64 hppa ia64 ~mips ppc ppc64 ~sh sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"

RDEPEND="
	ncurses? ( sys-libs/ncurses )
	readline? ( sys-libs/readline )"
DEPEND="${RDEPEND}
	sys-devel/gettext
	app-text/hunspell
	app-dicts/myspell-en
	app-dicts/myspell-ru"

S=${WORKDIR}/${MY_P}

src_install() {
 dodir "/usr/share/myspell"
 insinto "/usr/share/myspell"
 doins "${S}/kk_KZ.aff" || die
 doins "${S}/kk_noun_adj.aff" || die
 doins "${S}/kk_test.aff" || die
 doins "${S}/kk_noun_adj.dic" || die
 doins "${S}/kk_test.dic" || die
 doins "${S}/kk_KZ.dic" || die
 dodoc README_kk_KZ.txt
}