FROM ubuntu:14.04

MAINTAINER blurryroots <blurryroots@posteo.de>

# Silence terminal output
ENV DEBIAN_FRONTEND noninteractive
# Update source lists
RUN apt-get update -y
# Install general tools and openttd library dependencies
RUN apt-get install -y wget
RUN apt-get install -y libfontconfig1 libfreetype6 libicu52 liblzo2-2
RUN apt-get install -y libsdl1.2debian

# Asset packages
# Open graphics
ENV ottd_gfx opengfx-0.5.0-all.zip
ENV ottd_gfx_url http://binaries.openttd.org/extra/opengfx/0.5.0/$ottd_gfx
# Open sounds
ENV ottd_sfx opensfx-0.2.3-all.zip
ENV ottd_sfx_url http://binaries.openttd.org/extra/opensfx/0.2.3/$ottd_sfx
# Open music
ENV ottd_msx openmsx-0.3.1-all.zip
ENV ottd_msx_url http://binaries.openttd.org/extra/openmsx/0.3.1/$ottd_msx

# Base game files
ENV ottd_version 1.4.4
ENV ottd_base http://binaries.openttd.org/releases
ENV ottd_release openttd-${ottd_version}-linux-ubuntu-trusty-amd64.deb 

# Download openttd installer and asset packages
WORKDIR /tmp
RUN wget $ottd_base/$ottd_version/$ottd_release
RUN wget $ottd_gfx_url
RUN wget $ottd_sfx_url
RUN wget $ottd_msx_url

# Install openttd 
RUN dpkg -i /tmp/$ottd_release

# Create user to run server
RUN useradd -U -d /home/openttd openttd
# Create home directory
RUN mkdir -p /home/openttd/
# Set ownership of home folder and asset zip files
RUN chown -R openttd:openttd /home/openttd *.zip

# Install unzip
RUN apt-get install -y unzip tar

# Change to server user
USER openttd
WORKDIR /home/openttd/
RUN mkdir -p /home/openttd/.openttd/baseset
WORKDIR /home/openttd/.openttd/baseset
# Move assets into baseset directory
RUN unzip -d . /tmp/$ottd_gfx && \
	tar -xf opengfx-0.5.0.tar && \
	mv opengfx-0.5.0/* . && \
	rmdir opengfx-0.5.0
RUN unzip -d . /tmp/$ottd_sfx && \
	mv opensfx-0.2.3/* . && \
	rmdir opensfx-0.2.3
RUN unzip -d . /tmp/$ottd_msx && \
	mv openmsx-0.3.1/* . && \
	rmdir openmsx-0.3.1

# Change context to user home folder
WORKDIR /home/openttd

# Set default container command
#ENTRYPOINT /usr/games/openttd -D -g save/$SAVEGAME_NAME
ENTRYPOINT /usr/games/openttd -D
