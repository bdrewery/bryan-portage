# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils
# Short one-line description of this package.
DESCRIPTION="MIRACL crypto library"

# Homepage, not used by Portage directly but handy for developer reference
HOMEPAGE="http://www.shamus.ie"

# Point to any required sources; these will be automatically downloaded by
# Portage.
SRC_URI="ftp://ftp.computing.dcu.ie/pub/crypto/miracl.zip"

LICENSE="free-noncomm"
SLOT="0"
KEYWORDS="x86"

IUSE=""

DEPEND=""
RDEPEND="
	${DEPEND}"

S="${WORKDIR}"


src_unpack() {
	vecho ">>> Unpacking ${A} to ${PWD}"

	unzip -qo -j -aa -L "${DISTDIR}/${A}" || die "failure unpacking {$A}"
	cd "${S}"
}

src_compile() {
	# The source tarbal provides no Makefile/autoconf
	# Instead of providing a patch with a Makefile, let's just modify the given compile script
	sed --in-place=~ "s/\(gcc .*\) -O2 \(.*\)/\1 ${CFLAGS} \2/" linux || die "Failed to update build script"
	sed --in-place=~ "s/\(g++ .*\) -O2 \(.*\)/\1 ${CXXFLAGS} \2/" linux || die "Failed to update build script"

	# source tarbal provides a linux compile script -- No output given
	sh linux || die "Compile failed"
}

src_install() {

	dolib "${S}/${PN}.a" || die "Installing library failed"

	insinto /usr/include
	doins "${S}/miracl.h" "${S}/mirdef.h" || die "Installing headers failed"
}
