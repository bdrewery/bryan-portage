# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
inherit eutils toolchain-funcs

IRSSI_PV="0.8.9"

DESCRIPTION="FiSH irssi module"

# Homepage, not used by Portage directly but handy for developer reference
HOMEPAGE="http://www.shatow.net/gentoo/"

# Point to any required sources; these will be automatically downloaded by
# Portage.
SRC_URI="http://irssi.org/files/irssi-${IRSSI_PV}.tar.bz2
	http://fish.sekure.us/irssi/FiSH-irssi.v${PV}-source.zip"

LICENSE="as-is"
SLOT="0"
KEYWORDS="x86"

RESTRICT="mirror"

IUSE=""
DEPEND="
	>=dev-libs/glib-2.2.1
	dev-libs/miracl
"

RDEPEND="
	>=net-irc/irssi-0.8.9
	${DEPEND}"

# Source directory; the dir where the sources can be found (automatically
# unpacked) inside ${WORKDIR}.  The default value for S is ${WORKDIR}/${P}
# If you don't need to change it, leave the S= line out of the ebuild
# to keep it tidy.
S="${WORKDIR}/FiSH-irssi.v${PV}-source"

S_IRSSI="${S}/../irssi-${IRSSI_PV}"

src_unpack() {
	unpack ${A}

	cd ${S}
	#lame .zip unpacking forces dos2unix
	find ${S} -type f -exec sed -i 's/\r$//' {} \; || die "Failed to dos2unix files"

	sed -i \
		-e "s:-O2:${CFLAGS}:" \
		-e "s:gcc:$(tc-getCC):" \
		-e "s:-shared:-shared -fPIC -DPIC:" \
		-e "s:\#glib_dir = /usr/local/include/glib-1\.2:glib_include_dir = $(get_ml_incdir)/glib-2.0:" \
		-e "s:\$(HOME)/irssi-0\.8\.9:${S_IRSSI}:" \
		-e "s:\$(HOME)/glib-1\.2\.10:/usr/$(get_libdir)/glib-2.0/include:" \
		-e "s:miracl\.a:/usr/$(get_libdir)/miracl.a:" \
		-e "s:-I\$(glib_dir) -I\$(glib_dir)/include -I\$(glib_dir)/glib:-I\$(glib_dir) -I\$(glib_include_dir) -I\$(glib_include_dir)/glib:" \
		-e 's:\@echo "Press ENTER to continue or CTRL+C to abort\.\.\."\; read junk::' \
		Makefile || die "Failed to update Makefile"
}

src_compile() {
	cd ${S_IRSSI}
	econf || die "Irssi configure failed"

	cd ${S}
	emake || die "emake failed"
}

src_install() {
	insopts -m 644
	insinto /usr/$(get_libdir)/irssi/modules
	doins libfish.so

	dodoc FiSH-irssi.txt FiSH-irssi_History.txt blow.ini-EXAMPLE
}
