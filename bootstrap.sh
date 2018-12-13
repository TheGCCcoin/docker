#!/bin/bash
echo "Compile Global Cryptocurrency"
GCC_ROOT=/root/build
DOWNLOADS=$GCC_ROOT/tmp
DEPENDS=$GCC_ROOT/deps
PREFIX=$DEPENDS/local
CORE=2

install_ubuntu_debs () {
	echo 'Install Ubuntu deps'
	apt-get -qq update >> /dev/null
	apt-get install -qq -y wget git automake libtool unzip build-essential mesa-common-dev >> /dev/null
}

make_dir () {
	echo 'Create dirs: '
	echo $DOWNLOADS
	echo $PREFIX
	echo $PREFIX/include
	echo $PREFIX/lib
	mkdir -p $PREFIX $DOWNLOADS $PREFIX/include $PREFIX/lib
}

download_deps () {
	echo 'Download dependencies'
	cd $DOWNLOADS
	echo "Download: leveldb"
	git clone -q https://github.com/google/leveldb
	# Crypto++ 5.6.5
	echo "Download: Crypto++ 5.6.5"
	wget -q 'https://www.cryptopp.com/cryptopp565.zip'
	echo "a75ef486fe3128008bbb201efee3dcdcffbe791120952910883b26337ec32c34	cryptopp565.zip" >> deps.sha256
	# Oracle Berkeley DB 
	echo "Download: Oracle Berkeley DB "
	wget -q 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
	echo "12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef	db-4.8.30.NC.tar.gz" >> deps.sha256
	# MiniUPnP 1.6.20120509
	echo "Download: MiniUPnP 1.6"
	wget -q 'http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.6.20120509.tar.gz' -O miniupnpc-1.6.20120509.tar.gz
	echo "cd023862ae3882246102594fda7dc5efd4feb2531bf7903abc62aa02e76193d8	miniupnpc-1.6.20120509.tar.gz" >> deps.sha256
	# OpenSSL 1.0.2p
	echo "Download: OpenSSL 1.0.2p"
	wget -q 'https://www.openssl.org/source/openssl-1.0.2p.tar.gz'
	echo "50a98e07b1a89eb8f6a99477f262df71c6fa7bef77df4dc83025a2845c827d00	openssl-1.0.2p.tar.gz" >> deps.sha256
	# Boost C++ Libraries 1.64.0
	echo "Download: Boost C++ Libraries 1.64.0"
	wget -q 'https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.gz'
	echo "0445c22a5ef3bd69f5dfb48354978421a85ab395254a26b1ffb0aa1bfd63a108	boost_1_64_0.tar.gz" >> deps.sha256
	# libevent
	echo "Download: libevent 2.1.8"
	wget -q 'https://github.com/libevent/libevent/archive/release-2.1.8-stable.tar.gz'
	echo "316ddb401745ac5d222d7c529ef1eada12f58f6376a66c1118eee803cb70f83d	release-2.1.8-stable.tar.gz" >> deps.sha256
	# zlib 1.2.11
	echo "Download: zlib 1.2.11"
	wget -q 'https://zlib.net/zlib-1.2.11.tar.gz'
	echo "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1	zlib-1.2.11.tar.gz" >> deps.sha256
	# LIBPNG: PNG reference library
	echo "Download: LIBPNG 1.6.16"
	wget -q 'https://sourceforge.net/projects/libpng/files/libpng16/older-releases/1.6.16/libpng-1.6.16.tar.gz'
	echo "02f96b6bad5a381d36d7ba7a5d9be3b06f7fe6c274da00707509c23592a073ad	libpng-1.6.16.tar.gz" >> deps.sha256
	# libqrencode 3.4.4
	echo "Download: libqrencode"
	wget -q 'https://fukuchi.org/works/qrencode/qrencode-3.4.4.tar.gz'
	echo "e794e26a96019013c0e3665cb06b18992668f352c5553d0a553f5d144f7f2a72	qrencode-3.4.4.tar.gz" >> deps.sha256
}

checksum_deps () {
	echo "Deps Check file checksum"
	sha256sum --check deps.sha256
	if ! sha256sum --check --status deps.sha256; then
		echo "Fail checksum. Exit" 
		exit 1
	fi
}

unpuck_deps () {
	echo 'Unpack dependencies'
	cd $DOWNLOADS
	unzip -qq -o cryptopp565.zip -d cryptopp565
	tar -xzf db-4.8.30.NC.tar.gz
	tar -xzf miniupnpc-1.6.20120509.tar.gz
	tar -xzf openssl-1.0.2p.tar.gz
	tar -xzf boost_1_64_0.tar.gz
	tar -xzf release-2.1.8-stable.tar.gz
	tar -xzf zlib-1.2.11.tar.gz
	tar -xzf libpng-1.6.16.tar.gz
	tar -xzf qrencode-3.4.4.tar.gz
}

dep_build_cryptopp565 () {
	echo "Build: cryptopp"
	cd $DOWNLOADS
	cd cryptopp565
	make > /dev/null
	make install PREFIX=$PREFIX > /dev/null
}

dep_build_leveldb () {
	echo "Build: leveldb"
	cd $DOWNLOADS
	cd leveldb
	git checkout -q .
	git checkout -q 41172a24016bc29fc795ed504737392587f54e3d
	git config core.autocrlf false
	git config core.eol lf
	
	make out-static/libleveldb.a out-static/libmemenv.a > /dev/null
	cp out-static/*.a $PREFIX/lib
	cp -rf include/* $PREFIX/include
	mkdir -p $PREFIX/include/memenv/
	cp -rf helpers/memenv/*.h $PREFIX/include/memenv/
}

dep_build_miniupnpc () {
	echo "Build: miniupnpc"
	cd $DOWNLOADS
	cd miniupnpc-1.6.20120509
	CFLAGS=-D_DEFAULT_SOURCE make > /dev/null
	INSTALLPREFIX=$PREFIX make install > /dev/null
}

dep_build_openssl () {
	echo "Build: openssl"
	cd $DOWNLOADS
	cd openssl-1.0.2p
	./config no-shared --prefix=$PREFIX --openssldir=$PREFIX/openssl > /dev/null
	make > /dev/null
	make install > /dev/null
}

dep_build_boost () {
	echo "Build: boost_1_64_0"
	cd $DOWNLOADS
	cd boost_1_64_0/
	./bootstrap.sh  > /dev/null
	./b2 --prefix=$PREFIX --build-type=minimal --layout=tagged --with-chrono --with-filesystem --with-program_options --with-system --with-thread toolset=gcc variant=release link=static threading=multi runtime-link=static install  > /dev/null
}

dep_build_berkeley () {
	echo "Build: db-4.8.30.NC"
	cd $DOWNLOADS
	cd db-4.8.30.NC
	wget -q 'https://gitlab.com/mrtall/db-4.8.30.nc/raw/master/patch_clang.patch'
	patch -p0 < patch_clang.patch
	cd build_unix/
	../dist/configure --disable-replication --enable-cxx --prefix=$PREFIX  > /dev/null
	make > /dev/null
	make install > /dev/null
}

dep_build_libevent () {
	echo "Build: libevent"
	cd $DOWNLOADS
	cd libevent-release-2.1.8-stable
	./autogen.sh > /dev/null
	./configure --prefix=$PREFIX CPPFLAGS="-I$PREFIX/include" > /dev/null
	LDFLAGS="-L$PREFIX/lib"
	make > /dev/null
	make install > /dev/null
}

dep_build_zlib () {
	echo "Build: zlib"
	cd $DOWNLOADS
	cd zlib-1.2.11

	export CFLAGS="-I$PREFIX/include"
	export CXXFLAGS="$CFLAGS"
	export CPPFLAGS="$CFLAGS"
	export LDFLAGS="-L$PREFIX/lib"
	./configure --prefix=$PREFIX --static --64 > /dev/null
	make > /dev/null
	make install > /dev/null
}

dep_build_libpng () {
	echo "Build: libpng"
	cd $DOWNLOADS
	cd libpng-1.6.16/
	./configure --disable-shared --prefix=$PREFIX > /dev/null
	make > /dev/null
	make install > /dev/null
}

dep_build_qrencode () {
	echo "Build: qrencode"
	cd $DOWNLOADS
	cd qrencode-3.4.4/
	./configure --enable-static --enable-shared=no --without-tools --prefix=$PREFIX > /dev/null
	make > /dev/null
	make install > /dev/null
}

build_deps () {
	echo "Build dependencies"
	dep_build_cryptopp565
	dep_build_leveldb
	dep_build_miniupnpc
	dep_build_openssl
	dep_build_boost
	dep_build_berkeley
	dep_build_libevent
	dep_build_zlib
	dep_build_libpng
	dep_build_qrencode
}

download_thegcccoin () {
	echo "Download TheGCCcoin source"
	cd $GCC_ROOT
	git clone -q https://github.com/TheGCCcoin/TheGCCcoin-source-code.git
}

build_thegcccoind () {
	echo "Compile TheGCCcoind"
	cd $GCC_ROOT
	cd TheGCCcoin-source-code/src
	make -f makefile.unix DEPSDIR=$PREFIX LIB_BOOST=$PREFIX/lib  > /dev/null
	chmod +x TheGCCcoind 
}
set -e
#install_ubuntu_debs
make_dir
download_deps
checksum_deps
unpuck_deps
build_deps
download_thegcccoin
build_thegcccoind
echo "Done!"




