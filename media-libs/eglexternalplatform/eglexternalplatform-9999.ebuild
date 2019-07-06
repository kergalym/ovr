# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

EGIT_REPO_URI="https://github.com/NVIDIA/${PN}.git"

DESCRIPTION="EGL External Platform interface"
HOMEPAGE="https://github.com/NVIDIA/eglexternalplatform/"

LICENSE="MIT"
SLOT="0"

KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	chmod -R 644 "${S}/"

	dodir /usr/include/EGL/
	dodir /usr/share/pkgconfig/

	cp -R ${S}/interface/* "${D}/usr/include/EGL/" || die "Install failed!"
	cp ${S}/*.pc "${D}/usr/share/pkgconfig" || die "Install failed!"
	dodoc COPYING
}
