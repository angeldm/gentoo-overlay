# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"
inherit eutils

DESCRIPTION="Multimedia communication libraries written in C language for building VoIP applications."
HOMEPAGE="http://www.pjsip.org/"
SRC_URI="http://www.pjsip.org/release/${PV}/pjproject-${PV}.tar.bz2"
KEYWORDS="~amd64 ~x86"

LICENSE="GPL-2"
SLOT="0"
IUSE="alsa amr doc epoll examples ext-sound ffmpeg g711 g722 g7221 gsm ilbc ipv6 l16 libyuv openh264 oss python resample sound speex srtp static-libs sdl ssl v4l2 video libressl"


DEPEND="virtual/pkgconfig
	alsa? ( media-libs/alsa-lib )
	amr? ( media-libs/opencore-amr )
	gsm? ( media-sound/gsm )
	ilbc? ( dev-libs/ilbc-rfc3951 )
	openh264? ( media-libs/openh264 )
	resample? ( media-libs/libsamplerate )
	sdl? ( media-libs/libsdl )
	speex? ( media-libs/speex )
	srtp? ( net-libs/libsrtp )
	ssl? ( !libressl? ( dev-libs/openssl:0= )
		libressl? ( dev-libs/libressl:0= ) ) "
RDEPEND="${DEPEND}"

S="${WORKDIR}/pjproject-${PV}"

src_prepare() {
	EPATCH_SOURCE="${FILESDIR}" EPATCH_SUFFIX="patch" EPATCH_FORCE="yes" epatch
	eapply_user
	rm -rf third_party/{gsm,ilbc,portaudio,resample,speex,srtp}
}

src_configure() {
#	econf --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr --with-external-speex --with-external-srtp --with-external-gsm --disable-ilbc-codec
	local myconf=()

	if ( use sdl || use v4l2 || use ffmpeg || use libyuv || use openh264 ) && ! use video; then
		die "sdl, v4l2, ffmpeg, libyuv and openh264 require USE flag 'video'. Bailing out."
	fi

	econf \
		--enable-shared \
		--disable-silk \
		$(use_enable sound) \
		$(use_enable resample) \
		$(use_enable amr opencore-amr) \
		$(use_enable epoll) \
		$(use_enable alsa sound) \
		$(use_enable gsm gsm-codec) \
		$(use_with gsm external-gsm) \
		$(use_enable ilbc ilbc-codec) \
		$(use_enable oss) \
		$(use_enable ext-sound) \
		$(use_enable libyuv) \
		$(use_enable sdl) \
		$(use_enable speex speex-aec) \
		$(use_enable speex speex-codec) \
		$(use_with speex  external-speex) \
		$(use_with srtp  external-srtp) \
		$(use_enable g711 g711-codec) \
		$(use_enable l16 l16-codec) \
		$(use_enable g722 g722-codec) \
		$(use_enable g7221 g7221-codec) \
		$(use_enable v4l2) \
		$(use_enable video) \
		"${myconf[@]}" \
		|| die "econf failed."
}

src_compile() {
	emake dep || die "emake dep failed"
	emake || die "emake failed"
}

src_install() {
	DESTDIR="${D}" emake install || die "emake install failed."

	if use python; then
		pushd pjsip-apps/src/python
		python setup.py install --prefix="${D}/usr/"
		popd
	fi

	if use doc; then
		dodoc README.txt README-RTEMS
	fi

	if use examples; then
		insinto "/usr/share/doc/${P}/examples"
		doins "${S}/pjsip-apps/src/samples/"*
	fi

        # Remove static library if needed
        use static-libs || rm -f "${D}"/usr/lib*/lib*.a
}
