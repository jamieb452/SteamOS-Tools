# -----------------------------------------------------------------------
# Author: 	    	Michael DeGuzis
# Git:		      	https://github.com/ProfessorKaos64/SteamOS-Tools
# Scipt Name:	  	extra-pkgs.
# Script Ver:	  	0.1.1
# Description:		Script for installing Android apps on Linux
#                 	Debs: http://static.davidedmundson.co.uk/shashlik/
#	
# Usage:	      	n/a , module
# -----------------------------------------------------------------------

install_android_apk()
{
	echo -e "\n==> APK installation routine"

	# NOTE!
	# Shashlik currently only supports x86 compatible Android APKs!!!
	
	# Ask where APK is and copy to APK dir for safekeeping and running later on
	
	echo -e "\nPlease enter the temporarly path to the APK file. Include the full path and extension\n"
	sleep 0.2s
	read -erp 
	
	# Copy APK to fixed location
	cp "${APK}" "${APK_DIR}"
	
	# Get base name of APK
	APK_BASENAME=$(basename "${APK}")
	
	echo -e "\n"Installing APK, please wait...\n"
	
	# Install APK from fixed location
	/opt/shashlik/bin/shashlik-install "${APK_DIR}/${APK_BASENAME}"


}

create_android_app_shortcut()
{

	if [[ "${skip_shorcut_prompts}" = "false" ]] then;
	
		echo -e "Currently installed APKS:
		
		# List APKS

	else

		read -erp "Enter a name for the application: " NAME
		REAL_NAME="$(echo ${APK_BASENAME} | sed 's/.apk//' )
		SHORTCUT="${REAL_NAME}.desktop"
		LAUNCHER="/usr/bin/${REAL_NAME}-launch.sh"
		BANNER_IMG="$scriptdir/artwork/banners/android-default.png"
		
	fi

	# copy default launcher, modify based on values pased
	sudo cp "$scriptdir/cfgs/android/shashlik.skel" "/usr/bin/${REAL_NAME}-launch.sh"
	LAUNCHER="/usr/bin/${REAL_NAME}-launch.sh"
	
	# copy over desktop shortcut
	sudo cp "$scriptdir/cfgs/android/shashlik.desktop" "/usr/share/applications/${REAL_NAME}.desktop"
	
	# copy banner
	sudo cp "$scriptdir/artwork/banners/android-default.png" "/home/steam/Pictures"
	BANNER_IMG="/home/steam/Pictures/android-default.png"
	
	# mark exec
	sudo chmod +x "/usr/bin/${REAL_NAME}-launch.sh"
	
	# perform sed replacements on skel files
	sudo sed -i "s|LAUNCHER_TMP|${LAUNCHER}|g" "/usr/share/applications/${REAL_NAME}.desktop"
	sudo sed -i "s|NAME_TMP|${REAL_NAME}|g" "/usr/share/applications/${REAL_NAME}.desktop"
	sudo sed -i "s|IMG_TMP|${BANNER_IMG}|g" "/usr/share/applications/${REAL_NAME}.desktop"
	
	# set launch file loc for easy swapout
	launch_loc="/usr/bin/${REAL_NAME}-launch.sh"

}

gamepad_profile_configuration()
{

	#######################################
	# Antimicro gamepad controls
	#######################################

	######!!!!!!!!!!#######
	# KEEP ???
	######!!!!!!!!!!#######
	
	# create antimicro dir
	antimicro_dir="/home/steam/antimicro"

	if [[ -d "$antimicro_dir" ]]; then
		# DIR found
		echo -e "Antimicro DIR found. Skipping..."
	else
		# create dir
		sudo mkdir -p "$antimicro_dir"
	fi

	# copy in default profiles
	sudo cp -r "$scriptdir/cfgs/gamepad/web/." "$antimicro_dir"

	cat<<- EOF
	#############################################################
	Setting controls for desired supported gamepads
	#############################################################

	Please choose your controller type for web app mouse control
	
	(1) Xbox 360 (wired)
	(2) Xbox 360 (wireless)
	(3) PS3 Sixaxis (wired)
	(4) PS3 Sixaxis (bluetooth)
	(5) PS4 Sixaxis (wired)
	(6) PS4 Sixaxis (bluetooth)
	(7) None (skip)

	EOF

	# the prompt sometimes likes to jump above sleep
	sleep 0.5s

	read -ep "Choice: " gp_mouse_choice

	case "$gp_mouse_choice" in

		1)
		gp_cmd="antimicro --hidden --no-tray --profile $antimicro_dir/x360-wired-mouse.gamecontroller.amgp \&"
		;;

		2)
		gp_cmd="antimicro --hidden --no-tray --profile $antimicro_dir/x360-wireless-mouse.gamecontroller.amgp \&"
		;;
		 
		3)
		gp_cmd="antimicro --hidden --no-tray --profile $antimicro_dir/ps3-wired-mouse.gamecontroller.amgp \&"
		;;

		4)
		gp_cmd="antimicro --hidden --no-tray --profile $antimicro_dir/ps3-wireless-mouse.gamecontroller.amgp \&"
		;;
		
		5)
		gp_cmd="antimicro --hidden --no-tray --profile $antimicro_dir/ps4-wired-mouse.gamecontroller.amgp \&"
		;;
		
		6)
		gp_cmd="antimicro --hidden --no-tray --profile $antimicro_dir/ps4-wireless-mouse.gamecontroller.amgp \&"
		;;
		
		7)
		gp_cmd="#mouse_control_disabled"
		;;
		 
		*)
		echo -e "\n==ERROR==\nInvalid Selection!"
		sleep 1s
		continue
		;;
	esac

	# perform swaps for mouse profiles
	
	sudo find /usr/bin -name '*Launch.sh' | while read line; do
	# echo "Processing file '$line'"
	sudo sed -i "s|#antimicro_tmp|$gp_cmd|" $line 
	
	done

	# remove launchers temp file
	rm -f /tmp/launchers.txt
	
fi

}

main()
{

	#######################################
	# Set dirs
	#######################################

	SHASHIK_HOME="$HOME/.config/shashik/
	APK_DIR="$HOME/android-apks"
	
	mkdir -p ${SHASHIK_HOME}
	mkdir -p ${APK_DIR}

	#######################################
	# Set vars
	#######################################
	
	#######################################
	# Pre-reqs
	#######################################
	
	# install shashik, if not installed
	
	if [[ $(dpkg-query -W --showformat='${Status}\n' shashlik | grep "installed") == "" ]]; then
	
		echo -e "\n==> Shaslik not found, installing...\n"
		sleep 2s
		sudo apt-get install -y --force-yes shashik
		
	else
	
		echo -e "\n==> Shashlik  found, updating...\n"
		sleep 2s
		# Update from latest in libregeek repo
		sudo apt-get install -yqq shashik
	
	fi
	
	###################################
	# Start android app addition loop
	###################################
	
	while [[ "$android_app_choice" != "x" || "$android_app_choice" != "done" ]];
	do	
		cat<<- EOF
		############################################################
		Shashlik - Android App installation
		#############################################################

		Please choose from the following. Choose Done when finished.
		(1) Install Android APK
		(2) Show installed APKs (coming soon)
		(x) Done

		EOF

		# the prompt sometimes likes to jump above sleep
		sleep 0.5s
		
		read -ep "Choice: " android_app_choice
		
		case "$android_app_choice" in
		        
		        1)
		        skip_shorcut_prompts="true"
		        install_android_apk
		        create_android_app_shortcut
		        ;;
		        
		        2)
		        continue
		        ;;
		        
		        3)
		        continue
		        ;;
		         
		        x|done)
		        # do nothing
		        echo -e "\n==> Exiting script\n"
		        exit 1
		        ;;
		         
		        *)
		        echo -e "\n==ERROR==\nInvalid Selection!"
		        sleep 1s
		        continue
			;;
	esac


}

# Main script routine
main