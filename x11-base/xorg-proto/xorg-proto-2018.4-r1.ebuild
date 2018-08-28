# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PN="${PN/xorg-/xorg}"
MY_P="${MY_PN}-${PV}"

EGIT_REPO_URI="https://anongit.freedesktop.org/git/xorg/proto/${MY_PN}"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git-r3"
fi

inherit ${GIT_ECLASS} meson

DESCRIPTION="X.Org combined protocol headers"
HOMEPAGE="https://cgit.freedesktop.org/xorg/proto/xorgproto/"
if [[ ${PV} = 9999* ]]; then
	SRC_URI=""
else
	KEYWORDS="alpha amd64 arm arm64 hppa ia64 ~mips ppc ppc64 s390 sparc x86 ~amd64-fbsd ~x64-macos ~x64-solaris"
	SRC_URI="https://xorg.freedesktop.org/archive/individual/proto/${MY_P}.tar.gz"
	S="${WORKDIR}/${MY_P}"
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	default
	[[ $PV = 9999* ]] && git-r3_src_unpack
}
