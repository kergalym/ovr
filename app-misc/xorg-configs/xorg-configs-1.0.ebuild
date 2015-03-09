# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils

DESCRIPTION="Splash live theme, system, polkit and xorg.configs"
HOMEPAGE=""
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${FILESDIR}"

RDEPEND=">=sys-auth/polkit-0.110
media-gfx/splashutils[fbcondecor]
media-libs/alsa-lib
net-fs/samba"

src_install() {
 dodir "/etc/pm/power.d/"
 insinto "/etc/pm/power.d/"
 doins "${S}/power" || die
 dodir "/etc/X11/xorg.conf.d/"
 insinto "/etc/X11/xorg.conf.d/"
 doins "${S}/30-keyboard.conf" || die
 insinto "/etc/X11/xorg.conf.d/"
 doins "${S}/50-mouse-deceleration.conf" || die
 insinto "/etc/X11/xorg.conf.d/"
 doins "${S}/50-nvidia.conf.back" || die
 dodir "/var/lib/samba/usershares"
# Not permitted in sandbox
# chgrp users "/var/lib/samba/usershares"
 fperms 1775 "/var/lib/samba/usershares"
 fperms +t "/var/lib/samba/usershares"
 dodir "/etc/samba"
 insinto "/etc/samba"
 doins "${S}/smb.conf" || die
 insinto "/etc/polkit-1/rules.d"
 doins "${S}/10-users.rules" || die
 dodir "/etc/splash"
 cp -r "${S}/livecd-12.0" ${D}/etc/splash/ || die
 cp  "${S}/luxisri.ttf" ${D}/etc/splash/ || die
}

pkg_postinst() {
chgrp users "/var/lib/samba/usershares"
elog "You will need to add user to polkitd group using"
elog "coomand 'gpasswd -a USER polkitd' and relogin"
touch /etc/udev/rules.d/80-net-name-slot.rules 
}
