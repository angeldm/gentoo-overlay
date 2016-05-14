# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

EGO_SRC=github.com/xenserver/${PN}
EGO_PN="github.com/xenserver/xe-guest-utilities/..."

inherit versionator

MY_PV=$(get_version_component_range 1-3)
MY_P=${PN}-${MY_PV}

if [[ ${PV} = *9999* ]]; then
	inherit golang-vcs
else
	KEYWORDS="~amd64"
	EGIT_COMMIT="${MY_PV}"
	SRC_URI="https://github.com/xenserver/${PN}/archive/v${EGIT_COMMIT}.tar.gz -> ${MY_P}.tar.gz"
	inherit golang-vcs-snapshot
fi
inherit golang-build systemd udev eutils linux-info

DESCRIPTION="Sarama is a Go library for Apache Kafka"
HOMEPAGE="https://${EGO_SRC}"
LICENSE="MIT"
SLOT="0/${MY_PV}"
IUSE=""
DEPEND=""
RDEPEND=""
CONFIG_CHECK="~XENFS"

PRODUCT_MAJOR_VERSION=6
PRODUCT_MINOR_VERSION=6
PRODUCT_MICRO_VERSION=80
RELEASE=17

src_prepare() {
	local go_src="${EGO_PN%/...}"
	rm -rf src/${go_src}/.git* || die
	#rm -rf src/${go_src}/mk* || die
	rm -rf src/${go_src}/Makefile || die
	#sed -i -e 's/guestmetric \"..\/guestmetric\"/\"github.com\/xenserver\/xe-guest-utilities\/guestmetric\"/g' src/${go_src}/xe-daemon/xe-daemon.go || die
	#sed -i -e 's/xenstoreclient \"..\/xenstoreclient\"/\"github.com\/xenserver\/xe-guest-utilities\/xenstoreclient\"/g' src/${go_src}/xe-daemon/xe-daemon.go || die
	#sed -i -e 's/xenstoreclient \"..\/xenstoreclient\"/\"github.com\/xenserver\/xe-guest-utilities\/xenstoreclient\"/g' src/${go_src}/guestmetric/guestmetric_linux.go || die
	#sed -i -e 's/xenstoreclient \"..\/xenstoreclient\"/\"github.com\/xenserver\/xe-guest-utilities\/xenstoreclient\"/g' src/${go_src}/xenstore/xenstore.go || die
	cd	src
	EPATCH_SOURCE="${FILESDIR}" EPATCH_SUFFIX="patch" EPATCH_FORCE="yes" epatch
	##sed -i -e "s/@PRODUCT_MAJOR_VERSION@/${PRODUCT_MAJOR_VERSION}/g" src/${go_src}/guestmetric/guestmetric_linux.go || die
	#sed -i -e "s/@PRODUCT_MINOR_VERSION@/${PRODUCT_MINOR_VERSION}/g" src/${go_src}/guestmetric/guestmetric_linux.go || die
	#sed -i -e "s/@PRODUCT_MICRO_VERSION@/${PRODUCT_MICRO_VERSION}/g" src/${go_src}/guestmetric/guestmetric_linux.go || die
	#sed -i -e "s/@NUMERIC_BUILD_NUMBER@/${RELEASE}/g" src/${go_src}/guestmetric/guestmetric_linux.go || die
	eapply_user
}

src_install() {
	golang-build_src_install
	dosbin bin/xe-daemon
	dobin bin/xenstore
	dosym /usr/bin/xenstore /usr/bin/xenstore-read
	dosym /usr/bin/xenstore /usr/bin/xenstore-write
	dosym /usr/bin/xenstore /usr/bin/xenstore-exists
	dosym /usr/bin/xenstore /usr/bin/xenstore-rm

	systemd_dounit "${FILESDIR}/xe-linux-distribution.service"
	systemd_dounit "${FILESDIR}/proc-xen.mount"
	#dsystemd_newtmpfilesd "${FILESDIR}/tmpfile" "xe-daemon.conf"
	udev_newrules   "${FILESDIR}/xen-vcpu-hotplug.rules" "10-xen-vcpu-hotplug.rules"
	dosbin "${FILESDIR}/xe-linux-distribution"

}
