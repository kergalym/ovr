# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools-utils eutils git-r3

DESCRIPTION="BTFS a bittorrent filesystem"
HOMEPAGE="https://github.com/johang/btfs"
EGIT_REPO_URI="https://github.com/johang/btfs.git" 

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+openssl"

DEPEND="
	sys-devel/autoconf
	sys-devel/automake
	>=sys-fs/fuse-2.9.4
	=net-libs/rb_libtorrent-0.16.17
	openssl? ( >=net-misc/curl-7.45.0 )" 
RDEPEND="${DEPEND}"

src_configure() {
	eautoreconf -i
	econf
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}
