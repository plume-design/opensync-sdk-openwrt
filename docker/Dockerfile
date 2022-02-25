FROM ubuntu:20.04
RUN \
	apt update && \
	apt -y install software-properties-common && \
	add-apt-repository -y ppa:git-core/ppa
RUN \
	apt update && \
	apt -y install build-essential \
		gcc \
		g++ \
		binutils \
		patch \
		bzip2 \
		flex \
		make \
		gettext \
		pkg-config \
		unzip \
		zlib1g-dev \
		libc6-dev \
		subversion \
		libncurses5-dev \
		gawk \
		sharutils \
		curl \
		libxml-parser-perl \
		ocaml-nox \
		ocaml \
		ocaml-findlib \
		libpcre3-dev \
		binutils-gold \
		python-yaml \
		libgd-dev \
		lib32z1 \
		libssl-dev \
		device-tree-compiler \
		u-boot-tools \
		vim \
		wget \
		zip \
		quilt \
		libc6-dev-i386 \
		python3-pip \
		ccache \
		openvswitch-switch \
		libfdt-dev \
		git \
		stow \
		python3-pydot \
		pigz \
		dropbear-bin \
		squashfs-tools \
		apt-transport-https ca-certificates

# Install kconfiglib required for menuconfig
RUN pip3 install kconfiglib
RUN pip3 install 'MarkupSafe<2.0.0' 'Jinja2<3.0.0'
RUN pip3 install pyyaml

RUN update-ca-certificates
