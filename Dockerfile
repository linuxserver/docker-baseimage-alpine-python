FROM lsiobase/alpine
MAINTAINER sparklyballs

# environment settings
ENV LANG C.UTF-8
ENV PATH /usr/local/bin:$PATH

# build time environment settings
ENV GPG_KEY C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF
ENV LXML_VER 3.6.4
ENV PYTHON_PIP_VERSION 8.1.2
ENV PYTHON_VERSION 2.7.12

# install ca-certificates
RUN \
 apk add --no-cache \
	ca-certificates

# install build dependencies set 1
RUN \
 set -e && \
 apk add --no-cache --virtual=build-dependencies \
	openssl \
	tar \
	xz && \

# fetch and verify source
 wget -O \
 /tmp/python-src.tar.xz \
	"https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" && \
 wget -O \
 /tmp/lxml-src.tar.gz \
	"https://files.pythonhosted.org/packages/source/l/lxml/lxml-${LXML_VER}.tar.gz" && \
 mkdir -p \
	/tmp/lxml \
	/tmp/python && \
 tar -xf \
 /tmp/python-src.tar.xz -C \
 	/tmp/python --strip-components=1 && \
 tar -xf \
 /tmp/lxml-src.tar.gz -C \
	/tmp/lxml --strip-components=1 && \

# add 2nd set of build dependencies and remove 1st set
 apk add --no-cache --virtual=build-dependencies2 \
	autoconf \
	automake \
	bzip2-dev \
	freetype-dev \
	g++ \
	gcc \
	gdbm-dev \
	jpeg-dev \
	lcms2-dev \
	libc-dev \
	libffi-dev \
	libpng-dev \
	libwebp-dev \
	libxml2-dev \
	libxslt-dev \
	linux-headers \
	make \
	ncurses-dev \
	openjpeg-dev \
	openssl \
	openssl-dev \
	pax-utils \
	readline-dev \
	sqlite-dev \
	tcl-dev \
	tiff-dev \
	tk \
	tk-dev \
	zlib-dev && \
 apk del --purge \
	build-dependencies && \

# compile python
 cd /tmp/python && \
 ./configure \
	--enable-shared \
	--enable-unicode=ucs4 && \
 make -j$(getconf _NPROCESSORS_ONLN) && \
 make install && \

# install pip
 wget -O \
 /tmp/get-pip.py \
	'https://bootstrap.pypa.io/get-pip.py' && \
 python2 \
	/tmp/get-pip.py "pip==$PYTHON_PIP_VERSION" && \
 rm \
	/tmp/get-pip.py && \
 pip install --no-cache-dir --upgrade --force-reinstall \
	"pip==$PYTHON_PIP_VERSION" \
	cheetah \
	configparser \
	ndg-httpsclient \
	notify \
	paramiko \
	pillow \
	psutil \
	pyopenssl \
	requests \
	setuptools \
	urllib3 \
	virtualenv && \

# compile py lxml
 cd /tmp/lxml && \
 python \
	setup.py build && \
 python \
	setup.py install && \

 [ "$(pip list |tac|tac| awk -F '[ ()]+' '$1 == "pip" { print $2; exit }')" = "$PYTHON_PIP_VERSION" ] && \
 find /usr/local -depth \
 \( \
	\( -type d -a -name test -o -name tests \) \
	-o \
	\( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
	\) -exec rm -rf '{}' + && \

# add python runtime packages
 runDeps="$( \
	scanelf --needed --nobanner --recursive /usr/local \
	| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
	| sort -u \
	| xargs -r apk info --installed \
	| sort -u \
	)" && \
 apk add --no-cache --virtual .python-rundeps \
	curl \
	freetype \
	git \
	lcms2 \
	libjpeg-turbo \
	libwebp \
	openjpeg \
	p7zip \
	$runDeps \
	tar \
	tiff \
	unrar \
	unzip \
	wget \
	xz \
	zlib && \

 apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/testing \
	vnstat && \
# cleanup
 apk del --purge \
	build-dependencies2 && \
 rm -rf \
	/tmp/* && \
 find /root -name . -o -prune -exec rm -rf -- {} + && \
 mkdir -p \
	/root

