FROM lsiobase/alpine
MAINTAINER sparklyballs

# package versions
ARG PAR2_VER="v0.6.14"
ARG YENC_VER="0.4.0"

# install build dependencies
RUN \
apk add --no-cache --virtual=build-dependencies \
	autoconf \
	automake \
	freetype-dev \
	g++ \
	gcc \
	jpeg-dev \
	lcms2-dev \
	libffi-dev \
	libpng-dev \
	libwebp-dev \
	linux-headers \
	make \
	openjpeg-dev \
	openssl-dev \
	python-dev \
	tiff-dev \
	zlib-dev && \

# install runtime packages needed in build stage
apk add --no-cache \
	curl \
	py-lxml \
	py-pip \
	tar \
	&& \

# fetch source
 mkdir -p \
	/tmp/par2-source \
	/tmp/yenc-source && \
 curl -o \
	/tmp/par2.tar.gz -L \
		"https://github.com/Parchive/par2cmdline/archive/${PAR2_VER}.tar.gz" && \
 curl -o \
	/tmp/yenc.tar.gz -L \
		"http://www.golug.it/pub/yenc/yenc-${YENC_VER}.tar.gz" && \

# unpack source
 tar xvf /tmp/par2.tar.gz -C \
	/tmp/par2-source --strip-components=1 && \
 tar xvf /tmp/yenc.tar.gz -C \
	/tmp/yenc-source --strip-components=1 && \

# compile par2
 cd /tmp/par2-source && \
	aclocal && \
	automake --add-missing && \
	autoconf && \
	./configure && \
	make install && \

# compile yenc
 cd /tmp/yenc-source && \
	python setup.py build && \
	python setup.py install && \

# add pip packages
 pip install --no-cache-dir -U \
	pip && \
 LIBRARY_PATH=/lib:/usr/lib \
 pip install --no-cache-dir -U \
	cheetah \
	cherrypy \
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

# clean up
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# install runtime dependencies
RUN \
 apk add --no-cache \
	freetype \
	git \
	lcms2 \
	libjpeg-turbo \
	libwebp \
	openjpeg \
	p7zip \
	python \
	tiff \
	unrar \
	unzip \
	wget \
	xz \
	zlib && \

 apk add --no-cache --repository http://nl.alpinelinux.org/alpine/edge/testing \
	vnstat
