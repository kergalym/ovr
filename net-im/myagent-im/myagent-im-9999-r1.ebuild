EAPI=2

inherit qt4-r2 eutils git-2

EGIT_REPO_URI="https://code.google.com/p/myagent-im/"

DESCRIPTION="Mail.ru protocol instant messenger"
HOMEPAGE="http://code.google.com/p/myagent-im"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="dev-qt/qtgui
        dev-libs/xapian
        sys-libs/zlib
        app-text/aspell
        x11-libs/libXScrnSaver"
#        x11-libs/qt-phonon
#"
#        =media-libs/swfdec-0.6.8

DEPEND=${RDEPEND}

src_unpack() {
	git-2_src_unpack
}

src_prepare() {
	sed -i 's|<Phonon/|<phonon/|g' "${S}"/src/soundplayer.h
}

src_configure() {
	cd "${S}"
	eqmake4 PREFIX=/usr
}

src_compile() {
	emake
}


src_install() {
	emake INSTALL_ROOT="${D}" DESTDIR="${D}" install || die "Emake install failed!!!"
}

