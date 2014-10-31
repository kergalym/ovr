# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit git-2 autotools eutils toolchain-funcs multilib

DESCRIPTION="A GTK+ language binding for the librep Lisp environment"
HOMEPAGE="http://git.tuxfamily.org/?p=gitroot/librep/gtk.git;a=summary"
EGIT_REPO_URI="git://git.tuxfamily.org/gitroot/librep/gtk.git"

LICENSE="GPL-2"
SLOT="gtk-2.0"
KEYWORDS=""
IUSE=""

RDEPEND=">=dev-libs/librep-9999
	>=x11-libs/gtk+-2.10.0
	!x11-libs/rep-gtk
	!x11-libs/rep-gtk-svn"

DEPEND="${RDEPEND}
	virtual/pckgconfig"

src_unpack() {
	git-2_src_unpack
	cd "${S}"
	eautoreconf || die "eautoreconf failed"
}

src_configure() {
	econf \
		--prefix=/usr || die "configure failed"
}

src_compile() {
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	dodoc AUTHORS ChangeLog INSTALL NEWS README* TODO
	docinto examples
	dodoc examples/*
}
