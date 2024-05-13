#!/bin/bash
# Source: https://github.com/ptitSeb/box64/blob/main/docs/X64WINE.md

### User-defined Wine version variables ################
# - Replace the variables below with your system's info.
# - Note that we need the amd64 version for Box64 even though we're installing it on our ARM processor.
# - Wine download links from WineHQ: https://dl.winehq.org/wine-builds/

branch="staging" #example: devel, staging, or stable (wine-staging 4.5+ requires libfaudio0:i386)
version="9.4" #example: "7.1"
id="debian" #example: debian, ubuntu
dist="bookworm" #example (for debian): bullseye, buster, jessie, wheezy, ${VERSION_CODENAME}, etc 
tag="-1" #example: -1 (some wine .deb files have -1 tag on the end and some don't)

path="/opt/"

########################################################

# Wine download links from WineHQ: https://dl.winehq.org/wine-builds/
LNKA="https://dl.winehq.org/wine-builds/${id}/dists/${dist}/main/binary-amd64/" #amd64-wine links
DEB_A1="wine-${branch}-amd64_${version}~${dist}${tag}_amd64.deb" #wine64 main bin
DEB_A2="wine-${branch}_${version}~${dist}${tag}_amd64.deb" #wine64 support files (required for wine64 / can work alongside wine_i386 main bin)

# Install amd64-wine (64-bit) alongside i386-wine (32-bit)
echo -e "Downloading wine . . ."
wget -q ${LNKA}${DEB_A1} 
wget -q ${LNKA}${DEB_A2} 
echo -e "Extracting wine . . ."
dpkg-deb -x ${DEB_A1} wine-installer
dpkg-deb -x ${DEB_A2} wine-installer
echo -e "Installing wine . . ."
mkdir -p $path
mv wine-installer/opt/wine* $path
binpath=$path/wine-${branch}/bin

# Download wine dependencies
# - these packages are needed for running box64/wine-amd64 on RPiOS (box64 only runs on 64-bit OS's)
apt-get install -y libasound2:arm64 libc6:arm64 libglib2.0-0:arm64 libgphoto2-6:arm64 libgphoto2-port12:arm64 \
  libgstreamer-plugins-base1.0-0:arm64 libgstreamer1.0-0:arm64 libldap-2.4-2:arm64 libopenal1:arm64 libpcap0.8:arm64 \
  libpulse0:arm64 libsane1:arm64 libudev1:arm64 libunwind8:arm64 libusb-1.0-0:arm64 libvkd3d1:arm64 libx11-6:arm64 libxext6:arm64 \
  ocl-icd-libopencl1:arm64 libasound2-plugins:arm64 libncurses6:arm64 libncurses5:arm64 libcups2:arm64 \
  libdbus-1-3:arm64 libfontconfig1:arm64 libfreetype6:arm64 libglu1-mesa:arm64 libgnutls30:arm64 \
  libgssapi-krb5-2:arm64 libjpeg62-turbo:arm64 libkrb5-3:arm64 libodbc1:arm64 libosmesa6:arm64 libsdl2-2.0-0:arm64 libv4l-0:arm64 \
  libxcomposite1:arm64 libxcursor1:arm64 libxfixes3:arm64 libxi6:arm64 libxinerama1:arm64 libxrandr2:arm64 \
  libxrender1:arm64 libxxf86vm1:arm64 libc6:arm64 libcap2-bin:arm64
  # This list found by downloading...
  #	wget https://dl.winehq.org/wine-builds/debian/dists/bullseye/main/binary-amd64/wine-devel_7.1~bullseye-1_amd64.deb
  #	wget https://dl.winehq.org/wine-builds/debian/dists/bullseye/main/binary-amd64/wine-devel-amd64_7.1~bullseye-1_amd64.deb
  # then `dpkg-deb -I package.deb`. Read output, add `:arm64` to packages in dep list, then try installing them on Pi aarch64.	

# Install symlinks
ln -s $binpath/wine /usr/local/bin/wine
ln -s $binpath/wine64 /usr/local/bin/wine64
ln -s $binpath/wineboot /usr/local/bin/wineboot
ln -s $binpath/winecfg /usr/local/bin/winecfg
ln -s $binpath/wineserver /usr/local/bin/wineserver
