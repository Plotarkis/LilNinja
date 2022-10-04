#!/bin/bash


# ---------------------------------------COLOUR LIST------------------------------------------------------------------

NC='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# ----------------------------------------------START OF TOR,NMAP,WHOIS CHECK FUNCTION----------------------------------------------------------------------
function tnw_chk()
{
	echo "Required applications: "
	echo -e "1. ${Purple}TOR${NC}\n2. ${Purple}Nmap${NC}\n3. ${Purple}Whois${NC}\n4. ${Purple}sshpass${NC}\n5. ${Purple}Geoiplookup${NC}"
	echo ""
	sleep 1
	echo -e "${Cyan}Proceeding to check if these packages exist.${NC}"
	echo ""

# the loop below checks whether tor, whois and nmap by running the debian package manager command, with the status flag (-s), to
# view the status of the packages, which will tell us if the packages exist on the system. The error and output streams are directed to /dev/null

	for name in tor whois nmap sshpass geoip-bin
	do
		dpkg -s $name &> /dev/null

# If the package does not exist, the if block below runs a command to install the missing packages

		if [ $? -ne 0 ]
		then
			echo -e "package for ${name^^} is ${Red}not installed!${NC}"
			echo ""
			sleep 0.5
			echo -e "${Cyan}Installing packages now...${NC}"
			sudo apt-get install $name
			echo ""
			echo -e "${Green}$name installation complete.${NC}"
			echo ""
			tnw_chk
			
# Else block below runs if the relevant package DOES exist				
		else
			echo -e "${Purple}${name^^}${NC} package ${Green}PRESENT.${NC}"
		fi

	done
}

# ---------------END OF TNW FUNCTION-------------------------------------------------
#----------------START OF NIPE CHECK FUNCTION----------------------------------------

# below commands to send user to home directory, then do a pwd to display home directory before trying to cd into nipe.

function nipe_chk()
{
	# this first block below switches to the home directory, then runs pwd to let the user know that we are starting in the home directory.
	echo "switching to home directory.."
	sleep 0.5
	cd
	pwd
	echo ""
	sleep 1
	echo "Simulating directory change.."
	echo ""

	# Below is the command to attempt to navigate to the nipe directory, if there is no nipe/, then an error will be returned and
	# the user will be prompted to install Nipe and the relevant resources. If not, it will navigate to it and run the next set of commands under the
	# 'else' block of the main if/statement
	# 2> /dev/null outputs the standard error output stream into the void known as /dev/null, the Linux Abyss from which nothing returns
	cd nipe 2> /dev/null 

	# this main if/else statement checks to see if changing into the nipe directory is possible, to verify its existence in the home directory
	# If the value of the above statement returns 0, it means that it is TRUE, and the nipe folder exists.

	if [ $? -ne 0 ]
	then
		echo -e "${Red}This directory doesnt exist here.${NC}"
		echo ""
		sleep 0.5
		echo "Would you like to install nipe and its relevant resources? [y/n]"
		read pkg_inst
		# this is the first nested if statement, which activates in the scenario where the nipe folder does not exist
		# If it does not, it asks whether the user would like to install, if yes it will proceed with the full installation process.
		if [ "$pkg_inst" == "y" ]
		then
			git clone https://github.com/htrgouvea/nipe && cd nipe
			echo ""
			pwd
			echo ""
			echo "You are now in the newly created nipe folder."
			echo "Now installing libs and dependencies.."
			sudo cpan install Try::Tiny Config::Simple JSON
			echo -e "${Green}Libs and dependencies installed.${NC}"
			echo ""
			sleep 0.5
			echo -e "${Cyan}installation of perl nipe.pl script in progress...${NC}"
			sudo perl nipe.pl install
			echo -e "${Green}nipe.pl installed.${NC}"
			sleep 0.5
			echo -e "${Green}Nipe installation complete and ready for activation.${NC}"
			echo ""
			
		elif [ "$pkg_inst" == "n" ]
		then
			echo "Nipe is not being installed."
			echo -e "${Red}Anonymization using nipe scripts will not be possible.${NC}"
			echo "Without anonymization, conducting scans is HIGHLY discouraged. Exiting"
			exit
		
		else
			echo "Invalid option, please input a valid option."
			nipe_chk
		fi
		
	else
		#the pwd command below displays to the user that changing directories into the nipe folder was successful.
		pwd
		echo ""
		# the nested if statement below checks for the existence of the nipe.pl script in the nipe folder
		# on the off chance it does not exist, it prompts the user on whether they would like to leave it as is
		# or proceed with removing the directory entirely, then looping back to the start of this script to
		# allow for a proper reinstallation.
		
		if [ -e "nipe.pl" ]
		then
			echo -e "${Green}nipe.pl is present!${NC}"
			echo "------------------------------------------------------------------------------------------"
			echo -e "${Cyan}Nipe check complete.\nProceeding to Anonymization phase.${NC}"
			echo ""
			
		else
			echo -e "${Red}That file does not exist in /nipe${NC}."
			echo ""
			echo -e "Recommend ${Red}completely removing${NC} the nipe folder and reinstalling."
			echo "Would you like to do this? [y/n] "
			read rm_reinst
			
			if [ "$rm_reinst" == "y" ]
			then
				cd
				rm -r nipe
				nipe_chk
				
			elif [ "$rm_reinst" == "n" ]
			then
				echo "nipe folder still exists, but does not have the necessary script to function."
				echo -e "${Red}Anonymization will not be possible. Exiting${NC}"
				exit
			
			else
				echo "Invalid option, try again."
				nipe_chk
				
			fi

		fi
	fi
}

# --------------------------END OF NIPE FUNCTION----------------------- 
# --------------------------START OF ANON FUNCTION---------------------

function phantom()
{
	cd ~/nipe
	echo "Your current directory is: "
	pwd

	echo ""

	function anon_check()
	{
		echo "Checking anonimity..."
		echo ""
		current_ip=$(curl -s ifconfig.co | tr -d [:alpha:] | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | tr -d '\<\>\"\=\-\/' | tr -d [:blank:])
		current_ip_loc=$(geoiplookup "$current_ip" | awk '{print $5}')
		echo -e "${Yellow}$current_ip_loc${NC}"
		echo -e "${Yellow}$current_ip${NC}"
		echo ""
	# the if condition below checks that the country of my current IP is not SG
	# If it is, it runs nipe.
		if [ "$current_ip_loc" == "Singapore" ]
		then
			echo -e "${Red}You are not anonymous!${NC} ${Blue}Anonmizing now...${NC}"
			sudo perl nipe.pl start
			anon_ip=$(sudo perl nipe.pl status | grep Ip | awk '{print $3}')
			loc=$(geoiplookup "$anon_ip" | awk '{print $4, $5}')
			
			echo -e "${Green}Anonimity achieved!${NC}"
			echo ""
			echo -e "Your IP origin point is now: ${Yellow}$loc${NC}"
			echo -e "IP Address: ${Yellow}$anon_ip${NC}"
			echo ""
			anon_check
		
		else
			echo -e "${Green}You are already anonymous!${NC}"
			echo -e "Would you like to ${Yellow}RESTART${NC}, ${Red}STOP${NC}, or ${Green}CONTINUE${NC} with ${Blue}ANON mode${NC}? [r/s/c]"

			read ans
			
			if [ "$ans" == "r" ]
			then
				sudo perl nipe.pl restart
				echo ""
				echo -e "You are ${Red}NO LONGER anonymous${NC}. ${Blue}Rerunning anon function.${NC}"
				echo ""
				anon_check
				
			elif [ "$ans" == "s" ]
			then
				sudo perl nipe.pl stop
				echo -e "${Red}NO LONGER ANONYMOUS.${NC}"
				echo -e "${Red}EXITING${NC}"
				exit
				
			elif [ "$ans" == "c" ]
			then
				echo ""
				echo -e "${Green}You continue to BE ANONYMOUS.${NC}"
				echo "------------------------------------------------------------------------------------------"
				echo ""
			
			else
				echo ""
				echo "Invalid option, running anon check again"
				sleep 1
				echo ""
				anon_check
			fi
		fi
	}	
}

# -------------------------------------END OF ANON FUNCTION-------------------------------------------------------
# -------------------------------------START OF REMOTE FUNCTION---------------------------------------------------

function creds()
{
		echo -e "Please input you target ${Blue}USERNAME${NC}: "
		read -r user
		echo ""
		
		echo -e "Input target ${Blue}IP address${NC}: "
		read -r ip
		echo ""
		
		echo -e "Input target ${Blue}PASSWORD${NC}: "
		read -r pass
		echo ""
# The entire section above this collects info on the target remote host.
# The function is nested so that the above is not prompted again when I loop the below function.
	function remote_commands()
	{
		echo -e "${Blue}OPTIONS${NC}:\n${Purple}NMAP of target${NC} or ${Purple}WHOIS query of target external IP${NC}:"
		echo ""
# The user is given the option to either conduct an NMAP scan of the target OR a WHOIS Query of the target's external IP. Both options execute commands on the remote host/server
# via SSH
		select scan_opt in nmap whois change_target quit

		do 
			case $scan_opt in
# The NMAP option creates a directory called tempn, then stores the results of the nmap scan in all 3 formats in that folder.
# Then an scp command is used to download the entire new folder from the remote host onto the local machine
# Once the download is done, another command is executed via ssh to delete the folder off the remote host			
			
			nmap)
				echo ""
				sshpass -p "$pass" ssh -o StrictHostKeyChecking=no "$user"@"$ip" "mkdir tempn && cd tempn && nmap $ip/24 -oA scans"
				sshpass -p "$pass" scp -r "$user"@"$ip":~/tempn ~/RAT/rat_logs
				sshpass -p "$pass" ssh -o StrictHostKeyChecking=no "$user"@"$ip"  "rm -r tempn"
				echo ""
				echo -e "${Yellow}NMAP scan complete, outputs stored in the 'scans' files within the tempn/ directory locally.${NC}"
				echo ""
				sleep 1
				remote_commands
			;;
# The WHOIS option does the same as the NMAP option, except with a different folder name and that it uses curl ifconfig.co to obtain the external IP then stores that in a text file.
# It then conducts a whois on the output of the (curl ifconfig)	command and stores  THAT in another text file. Both these text files are stored in the new tempw folder.
# The next steps are the exact same as the previous option. Download commences, directories are deleted off the remote machine.		
			whois)
				sshpass -p "$pass" ssh -o StrictHostKeyChecking=no "$user"@"$ip" "mkdir tempw && cd tempw && curl -s ifconfig.co | tr -d [:alpha:] | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | tr -d '\<\>\"\=\-\/' > externalip.txt"
				sshpass -p "$pass" scp -r "$user"@"$ip":~/tempw ~/RAT/rat_logs
				sshpass -p "$pass" ssh -o StrictHostKeyChecking=no "$user"@"$ip" "rm -r tempw"
				echo ""
				echo -e "${Yellow}External IP gained, and stored in the new tempw/ directory locally.${NC}"
				echo ""
				cd ~/RAT/rat_logs/tempw || exit
				pwd
				echo ""
				whois $(cat externalip.txt) > whois.txt
				echo -e "${Yellow}whois.txt created for $ip, stored in tempw/ ${NC}"
				sleep 1
				echo ""
				remote_commands
			;;
			
			change_target)
				echo "Returning to target selection.."
				sleep 1
				
				creds
				remote_commands
			;;
# The option below allows the user to exit the program		
			quit)
				exit
			;;
			
			*)
				echo "Invalid option, please choose either option 1 - NMAP or option 2 - WHOIS."
			;;

			esac
			
		done
	}

}

#--------------------------------------START OF DIRECTORY CHECK-------------------------------------------------
function dircheck()
{
	cd
	mkdir -p RAT
	cd RAT
	mkdir -p rat_logs
}
# -------------------------------------END OF REMOTE FUNCTION---------------------------------------------------
# -------------------------------------END OF ALL FUNCTIONS-----------------------------------------------------

#Directory check/creation
dircheck

#Running updates so fresh machines can run the script
sudo apt-get update && sudo apt-get dist-upgrade -y

# Intro Header

echo "LIL' NINJA" | figlet -f smslant
echo ""

# First, the program checks that the local machine has all the necessary applications
tnw_chk
echo "------------------------------------------------------------------------------------------"
echo -e "${Cyan}Check for necessary applications done.${NC}"
echo -e "${Cyan}Proceeding with check for Nipe.${NC}"
echo ""
nipe_chk

# Then the program checks if the local machine's IP has been torified. If not, it torifies the connection.
phantom
anon_check
echo -e "${Cyan}Anonymization phase over. Proceeding to remote access phase.${NC}"
echo ""

# After anonymization, the program prompts for the credentials of the target machine. 
creds
remote_commands

