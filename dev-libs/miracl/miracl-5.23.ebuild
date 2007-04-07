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
#Use my own mirror to ensure builds don't change from 'miracl.zip' from upstream
SRC_URI="http://www.shatow.net/gentoo/mirror/miracl-5.23.zip"

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

	# The source tarbal provides no Makefile/autoconf
	# Instead of providing a patch with a Makefile, let's just modify the given compile script
	local script="linux"
	local myfail="Failed to update build script"
	einfo "Applying patches to build script"
	sed -i \
		-e "s/\(^gcc\) \(.*\) -O2 \(.*\)/$(tc-getCC) \2 ${CFLAGS} \3/" \
		-e "s/\(^g++\) \(.*\) -O2 \(.*\)/$(tc-getCXX) \2 ${CXXFLAGS} \3/" \
		-e "s/\(^gcc\) \(.*\)/$(tc-getCC) \2/" \
		-e "s/\(^g++\) \(.*\)/$(tc-getCXX) \2/" \
		-e "s/\(^ar\) \(.*\)/$(tc-getAR) \2/" \
		-e "s/\(^as\) \(.*\)/$(tc-getAS) \2/" \
		${script} || die ${myfail}
}

src_compile() {
	local script="linux"

	# source tarbal provides a linux compile script -- No output given
	sh ${script} || die "Compile failed"
}

src_install() {
	cd ${S}
	dolib.a miracl.a || die "Installing library failed"

	insopts -m 644
	insinto /usr/include
	doins miracl.h mirdef.h || die "Installing headers failed"

	dodoc update.txt first.txt problems.txt readme.txt
}
