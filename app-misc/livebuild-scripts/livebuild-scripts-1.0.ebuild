# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="Live System Build Scripts"
HOMEPAGE="https://github.com/kergalym/livebuild-gentoo"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${FILESDIR}"

RDEPEND="sys-devel/gcc
sys-fs/e2fsprogs 
app-cdr/cdrtools 
sys-fs/squashfs-tools 
sys-boot/syslinux 
>=app-misc/livedvd-configs-1.0"

src_unpack() {
    unpack ${A}
    cd "${S}"
}

src_install() {
 dodir "/usr/share/livebuild-scripts"
 cp -r "${A}/*" ${D}/usr/share/livebuild-scripts/ || die
 dodir "/usr/bin"
 insinto ${S}/livebuild64_xfce.sh 
 insinto ${S}/livebuild32_xfce.sh
}

pkg_postinst() {
elog "These scripts are semi-automated and designed to create and modify" 
elog "custom Gentoo-based LiveSystem (from stage3) that can be burned to DVD or recorded" 
elog "to Flash Drive. Don't hesitate to adjust them for youself!"
elog "Usage:"
elog "Running buildsysio.sh without any argument shows list of exist arguments, here they are:"
elog "start: chrooting into exist system to made changes"
elog "stop: umounts exist chroot session"
elog "iso: packing live system into squashfs image and then create iso image"
elog "buildroot: create live system from scratch (from stage3)"
}
