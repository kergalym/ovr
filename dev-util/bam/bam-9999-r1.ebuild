# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit git-r3 eutils python-any-r1 toolchain-funcs

DESCRIPTION="Fast and flexible Lua-based build system"
HOMEPAGE="https://matricks.github.com/bam/"
EGIT_REPO_URI="git://github.com/matricks/bam.git"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="doc test"

RDEPEND="dev-lang/lua:="
DEPEND="${RDEPEND}
	doc? ( ${PYTHON_DEPS} )
	test? ( ${PYTHON_DEPS} )"

pkg_setup() {
	if use doc || use test; then
		python-any-r1_pkg_setup
	fi
}

src_compile() {
	sh make_unix.sh
	if use doc; then
		"${PYTHON}" scripts/gendocs.py || die "doc generation failed"
	fi
}

src_install() {
	dobin ${PN}
	if use doc; then
		dohtml docs/${PN}{.html,_logo.png}
	fi
}
