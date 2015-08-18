#!/bin/bash

# -------------------------------------------------------------------------------
# Author:    		Michael DeGuzis
# Git:			https://github.com/ProfessorKaos64/SteamOS-Tools
# Scipt Name:	  	build-kodi-src.sh
# Script Ver:		0.1.3
# Description:		Attempts to build a deb package from kodi-src
#               	https://github.com/xbmc/xbmc/blob/master/docs/README.linux
#               	This is a fork of the build-deb-from-src.sh script. Due to the 
#               	amount of steps to build kodi, it was decided to have it's own 
#               	script. A deb package is built from this script. 
#
# Usage:      		./build-kodi-src.sh
# -------------------------------------------------------------------------------

scriptdir=$(pwd)
time_start=$(date +%s)
time_stamp_start=(`date +"%T"`)

install_prereqs()
{
	clear
	echo -e "==> Assessing prerequisites for building...\n"
	sleep 1s
	
	# install needed packages for building kodi
	
	sudo apt-get install autoconf, automake, autopoint, autotools-dev, cmake, curl,
	debhelper, default-jre, gawk, gperf, libao-dev, libasound2-dev,
	libass-dev, libavahi-client-dev, libavahi-common-dev, libbluetooth-dev,
	libbluray-dev, libboost-dev, libboost-thread-dev, libbz2-dev, libcap-dev, libcdio-dev,
	libcec-dev, libcurl4-openssl-dev,libcurl4-gnutls-dev, libcurl-dev, libcwiid-dev,
	libdbus-1-dev, libfontconfig-dev, libfreetype6-dev, libfribidi-dev, libgif-dev, 
	libgl1-mesa-dev, libgl-dev, libglew-dev, libglu1-mesa-dev, libglu-dev, libiso9660-dev, 
	libjasper-dev, libjpeg-dev, libltdl-dev, liblzo2-dev, libmicrohttpd-dev, libmodplug-dev, 
	libmpcdec-dev, libmpeg2-4-dev, libmysqlclient-dev, libnfs-dev, libogg-dev, libpcre3-dev, 
	libplist-dev, libpng12-dev, libpng-dev, libpulse-dev, librtmp-dev,libsdl2-dev,
	libshairplay-dev, libsmbclient-dev, libsqlite3-dev, libssh-dev, libssl-dev, libswscale-dev,
	libtag1-dev, libtiff-dev, libtinyxml-dev, libtool, libudev-dev, libusb-dev, libva-dev, 
	libvdpau-dev, libvorbis-dev, libxinerama-dev, libxml2-dev, libxmu-dev, libxrandr-dev, 
	libxslt1-dev, libxt-dev, libyajl-dev, lsb-release, nasm, python-dev, python-imaging, 
	python-support, swig, unzip, uuid-dev, yasm, zip, zlib1g-dev

}

main()
{
	build_dir="/home/desktop/build-kodi-tmp"
	
	clear
	
	# set var for git URL
	git_url="git://github.com/xbmc/xbmc.git build-kodi-tmp"
	
	# If git folder exists, evaluate it
	# Avoiding a large download again is much desired.
	# If the DIR is already there, the fetch info should be intact
	
	if [[ -d "$build_dir" ]]; then
	
		echo -e "\n==Info==\nGit folder already exists! Rebuild [r] or [p] pull?\n"
		sleep 1s
		read -ep "Choice: " git_choice
		
		if [[ "$git_choice" == "p" ]]; then
			# attempt to pull the latest source first
			echo -e "\n==> Attempting git pull..."
			sleep 2s
			cd "$build_dir"
			# eval git status
			output=$(git pull 2> /dev/null)
		
			# evaluate git pull. Remove, create, and clone if it fails
			if [[ "$output" != "Already up-to-date." ]]; then
	
				echo -e "\n==Info==\nGit directory pull failed. Removing and cloning..."
				sleep 2s
				cd
				rm -rf "$build_dir"
				mkdir -p "$build_dir"
				# create and clone
				git clone "$git_url"
				# enter build dir
				cd "$build_dir"
			fi
			
		elif [[ "$git_choice" == "r" ]]; then
			echo -e "\n==> Removing and cloning repository again..."
			sleep 2s
			# remove, clone, enter
			cd
			rm -rf "$build_dir"
			mkdir -p "$build_dir"
			# create and clone
			git clone "$git_url"
			# enter build dir
			cd "$build_dir"
		else
		
			echo -e "\n==Info==\nGit directory does not exist. cloning now..."
			sleep 2s
			# create DIRS
			mkdir -p "$build_dir"
			# create and clone
			git clone "$git_url"
			# enter build dir
			cd "$build_dir"
		
		fi
	
	else
		
			echo -e "\n==Info==\nGit directory does not exist. cloning now..."
			sleep 2s
			# create DIRS
			mkdir -p "$build_dir"
			# create and clone to current dir
			git clone "$git_url"
			# enter build dir
			cd "$build_dir" 
	fi
	
 
	#################################################
	# Build Kodi
	#################################################
  
  	#create the Kodi executable manually perform these steps:
	
	./bootstrap
	
	# ./configure <option1> <option2> PREFIX=<system prefix>... 
	# (See --help for available options). For now, use the default PREFIX
        # A full listing of supported options can be viewed by typing './configure --help'.
	# Default install path is: 
	
	./configure
	
	# make the package
	# By adding -j<number> to the make command, you describe how many
     	# concurrent jobs will be used. So for quad-core the command is:
	
	make -j4
	
	# since we are building a deb pkg, we will not use 'make install'
	# make install

	# From v14 with commit 4090a5f a new API for binary addons is available. 
	# Not used for now ...

	# make -C tools/depends/target/binary-addons
	
	####################################
	# (Optional) build Kodi test suite
	####################################
	
	make check
	
	# compile the test suite without running it
	make testsuite

	# The test suite program can be run manually as well.
	# The name of the test suite program is 'kodi-test' and will build in the Kodi source tree.
	# To bring up the 'help' notes for the program, type the following:
	
	# ./kodi-test --gtest_help
  
	############################
	# proceed to DEB BUILD
	############################
	
	echo -e "\n==> Building Debian package from source"
	sleep 2s
	
	# build deb package
	sudo checkinstall

	# Alternate method
	# dpkg-buildpackage -us -uc -nc

	#################################################
	# Post install configuration
	#################################################
	
	# TODO
	
	#################################################
	# Cleanup
	#################################################
	
	# clean up dirs
	
	# note time ended
	time_end=$(date +%s)
	time_stamp_end=(`date +"%T"`)
	runtime=$(echo "scale=2; ($time_end-$time_start) / 60 " | bc)
	
	# output finish
	echo -e "\nTime started: ${time_stamp_start}"
	echo -e "Time started: ${time_stamp_end}"
	echo -e "Total Runtime (minutes): $runtime\n"

	
	# assign value to build folder for exit warning below
	build_folder=$(ls -l | grep "^d" | cut -d ' ' -f12)
	
	# back out of build temp to script dir if called from git clone
	if [[ "$scriptdir" != "" ]]; then
		cd "$scriptdir"
	else
		cd "$HOME"
	fi
	
	# inform user of packages
	echo -e "\n############################################################"
	echo -e "If package was built without errors you will see it below."
	echo -e "If you don't, please check build dependcy errors listed above."
	echo -e "############################################################\n"
	
	echo -e "Showing contents of: $build_dir:"
	ls "$build_dir" 
	echo ""

}

# start main
install_prereqs
main
