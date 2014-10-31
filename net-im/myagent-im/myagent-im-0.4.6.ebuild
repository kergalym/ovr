EAPI=3

inherit qt4-r2

DESCRIPTION="Mail.ru protocol instant messenger"
HOMEPAGE="http://code.google.com/p/myagent-im"
SRC_URI=http://${PN}.googlecode.com/files/${PN}_${PV}.tar.gz

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="debug"

S=${WORKDIR}/${PN}

RDEPEND=">=x11-libs/qt-gui-4.4
        dev-libs/xapian
        sys-libs/zlib
        app-text/aspell
        x11-libs/libXScrnSaver"
        #x11-libs/qt-phonon

DEPEND=${RDEPEND}

#src_unpack() {
#	unpack ${A}
#}

src_prepare() {
	sed -i 's|<Phonon/|<phonon/|g' "${S}/src/soundplayer.h"
}

src_configure() {
	cd "${S}"
	eqmake4 PREFIX=/usr
}

src_compile() {
	emake
}


src_install() {
	emake INSTALL_ROOT="${D}" DESTDIR="${D}" install || die "Install failed"
}

