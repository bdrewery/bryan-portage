# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils toolchain-funcs
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

RESTRICT="mirror"

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
	local script="linux"
	local myfail="Failed to update build script"

	sed --in-place=~ "s/\(^gcc\) \(.*\) -O2 \(.*\)/$(tc-getCC) \2 ${CFLAGS} \3/" ${script} || die ${myfail}
	sed --in-place=~ "s/\(^g++\) \(.*\) -O2 \(.*\)/$(tc-getCXX) \2 ${CXXFLAGS} \3/" ${script} || die ${myfail}
	sed --in-place=~ "s/\(^gcc\) \(.*\)/$(tc-getCC) \2/" ${script} || die ${myfail}
	sed --in-place=~ "s/\(^g++\) \(.*\)/$(tc-getCXX) \2/" ${script} || die ${myfail}
	sed --in-place=~ "s/\(^ar\) \(.*\)/$(tc-getAR) \2/" ${script} || die ${myfail}
	sed --in-place=~ "s/\(^as\) \(.*\)/$(tc-getAS) \2/" ${script} || die ${myfail}

	# source tarbal provides a linux compile script -- No output given
	sh ${script} || die "Compile failed"
}

src_install() {

	dolib "${S}/${PN}.a" || die "Installing library failed"

	insinto /usr/include
	doins "${S}/miracl.h" "${S}/mirdef.h" || die "Installing headers failed"
}
