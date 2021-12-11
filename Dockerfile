# MingW64 + Qt5 for cross-compile builds to Windows
# Based on ArchLinux image

# Note: pacman cache is cleared to reduce image size by a few 100 mbs in total.
# `pacman -Scc --noconfirm` responds 'N' by default to removing the cache, hence
# the echo mechanism.

FROM archlinux:latest AS base
MAINTAINER Wouter Haffmans <wouter@simply-life.net>

# Update base system
RUN    pacman -Sy --noconfirm --noprogressbar archlinux-keyring \
    && pacman-key --populate \
    && pacman -Su --noconfirm --noprogressbar pacman \
    && pacman-db-upgrade \
    && pacman -Su --noconfirm --noprogressbar ca-certificates \
    && trust extract-compat \
    && pacman -Syyu --noconfirm --noprogressbar \
    && (echo -e "y\ny\n" | pacman -Scc)

# Add martchus.no-ip.biz repo for mingw binaries
RUN    echo "[ownstuff]" >> /etc/pacman.conf \
    && echo "Server = https://martchus.no-ip.biz/repo/arch/\$repo/os/\$arch " >> /etc/pacman.conf \
    && pacman-key --recv-keys B9E36A7275FC61B464B67907E06FE8F53CDC6A4C \
    && pacman-key --finger    B9E36A7275FC61B464B67907E06FE8F53CDC6A4C \
    && pacman-key --lsign-key B9E36A7275FC61B464B67907E06FE8F53CDC6A4C \
    && pacman -Sy

# Add some useful packages to the base system
RUN pacman -S --noconfirm --noprogressbar --needed \
        imagemagick \
        make \
        ninja \
        git \
        binutils \
        patch \
        base-devel \
        unzip \
        protobuf \
    && (echo -e "y\ny\n" | pacman -Scc)

# Install core MingW packages
RUN pacman -S --noconfirm --noprogressbar \
        mingw-w64-binutils \
        mingw-w64-crt \
        mingw-w64-gcc \
        mingw-w64-configure \
        mingw-w64-headers \
        mingw-w64-winpthreads \
        mingw-w64-bzip2 \
        mingw-w64-cmake \
        mingw-w64-expat \
        mingw-w64-extra-cmake-modules \
        mingw-w64-fontconfig \
        mingw-w64-freeglut \
        mingw-w64-freetype2 \
        mingw-w64-gettext \
        mingw-w64-libdbus \
        mingw-w64-libiconv \
        mingw-w64-libjpeg-turbo \
        mingw-w64-libpng \
        mingw-w64-libtiff \
        mingw-w64-libxml2 \
        mingw-w64-mariadb-connector-c \
        nsis \
        mingw-w64-openssl \
        mingw-w64-openjpeg \
        mingw-w64-openjpeg2 \
        mingw-w64-pcre \
        mingw-w64-pdcurses \
        mingw-w64-pkg-config \
        mingw-w64-protobuf \
        mingw-w64-readline \
        mingw-w64-sdl2 \
        mingw-w64-sqlite \
        mingw-w64-termcap \
        mingw-w64-tools \
        mingw-w64-zlib \
    && (echo -e "y\ny\n" | pacman -Scc)

RUN echo 'MAKEFLAGS="-j8"' >> /etc/makepkg.conf

# Create devel user
RUN useradd -m -d /home/devel -u 1000 -U -G users,tty -s /bin/bash devel
USER devel
ENV HOME=/home/devel
WORKDIR /home/devel

# Back to devel user, but not for subsequent image builds
USER devel
ONBUILD USER root
ONBUILD WORKDIR /

FROM base AS qt5

# Install MingW packages
RUN pacman -S --noconfirm --noprogressbar \
        mingw-w64-qt5-base \
        mingw-w64-qt5-base-static \
        mingw-w64-qt5-3d \
        mingw-w64-qt5-connectivity \
        mingw-w64-qt5-charts \
        mingw-w64-qt5-datavis3d \
        mingw-w64-qt5-declarative \
        mingw-w64-qt5-gamepad \
        mingw-w64-qt5-graphicaleffects \
        mingw-w64-qt5-imageformats \
        mingw-w64-qt5-location \
        mingw-w64-qt5-multimedia \
        mingw-w64-qt5-networkauth \
        mingw-w64-qt5-quickcontrols \
        mingw-w64-qt5-quickcontrols2 \
        mingw-w64-qt5-remoteobjects \
        mingw-w64-qt5-script \
        mingw-w64-qt5-scxml \
        mingw-w64-qt5-sensors \
        mingw-w64-qt5-serialport \
        mingw-w64-qt5-svg \
        mingw-w64-qt5-virtualkeyboard \
        mingw-w64-qt5-webchannel \
        mingw-w64-qt5-webglplugin \
        mingw-w64-qt5-websockets \
        mingw-w64-qt5-winextras \
        mingw-w64-qt5-xmlpatterns \
        mingw-w64-kirigami2 \
        mingw-w64-qt5-tools \
        mingw-w64-qt5-translations \
    && (echo -e "y\ny\n" | pacman -Scc)

ADD Qt5CoreMacros.cmake /usr/i686-w64-mingw32/lib/cmake/Qt5Core/
ADD Qt5CoreMacros.cmake /usr/x86_64-w64-mingw32/lib/cmake/Qt5Core/

# Back to devel user, but not for subsequent image builds
USER devel
ONBUILD USER root
ONBUILD WORKDIR /

FROM base AS qt6

# Install MingW packages
RUN pacman -S --noconfirm --noprogressbar \
        mingw-w64-qt6-base \
        mingw-w64-qt6-base-static \
        mingw-w64-qt6-5compat \
        mingw-w64-qt6-charts \
        mingw-w64-qt6-connectivity \
        mingw-w64-qt6-datavis3d \
        mingw-w64-qt6-declarative \
        mingw-w64-qt6-imageformats \
        mingw-w64-qt6-lottie \
        mingw-w64-qt6-multimedia \
        mingw-w64-qt6-networkauth \
        mingw-w64-qt6-quick3d \
        mingw-w64-qt6-quickcontrols2 \
        mingw-w64-qt6-quicktimeline \
        mingw-w64-qt6-scxml \
        mingw-w64-qt6-sensors \
        mingw-w64-qt6-serialbus \
        mingw-w64-qt6-serialport \
        mingw-w64-qt6-shadertools \
        mingw-w64-qt6-svg \
        mingw-w64-qt6-tools \
        mingw-w64-qt6-translations \
        mingw-w64-qt6-virtualkeyboard \
        mingw-w64-qt6-webchannel \
        mingw-w64-qt6-websockets \
    && (echo -e "y\ny\n" | pacman -Scc)

# Back to devel user, but not for subsequent image builds
USER devel
ONBUILD USER root
ONBUILD WORKDIR /
