#!/bin/bash
# COMP303 Starter Project Script

# Exit on first failures
set -e

mkdir -p ~/Downloads
cd ~/Downloads || exit 1

#This is for Linux, Using neovim to run the java code

#First: Download Junit4
wget https://repo1.maven.org/maven2/junit/junit/4.13.2/junit-4.13.2.jar

#Then Junit5 (We dont need it, but hey...)
wget https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-api/5.11.3/junit-jupiter-api-5.11.3.jar
wget https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-engine/5.11.3/junit-jupiter-engine-5.11.3.jar
wget https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-params/5.11.3/junit-jupiter-params-5.11.3.jar

#Then JavaFX: (I'm using Java17 cause It seems the Neovim packages are there)
wget https://download2.gluonhq.com/openjfx/17.0.13/openjfx-17.0.13_linux-x64_bin-sdk.zip
#(https://gluonhq.com/products/javafx/) (If you want to manually download it)

IS_ARCH=0
IS_DEBIAN=0

if grep -q "Arch" /etc/os-release; then
	echo "This system is Arch-based."
	IS_ARCH=1
elif grep -q "Debian" /etc/os-release || grep -q "Ubuntu" /etc/os-release; then
	echo "This system is Debian-based."
	IS_DEBIAN=1
else
	echo "Unknown distribution. Exiting."
	exit
fi

Example usage
if [[ $IS_ARCH -eq 1 ]]; then
	echo "Running Arch-specific command"
	sudo pacman -S --needed unzip jdk17-openjdk

elif [[ $IS_DEBIAN -eq 1 ]]; then
	echo "Running Debian-specific command"
	#No needed check, reinstalling shouldn't cause problem, but im not gonna create perfect code for debian lol
	sudo apt install unzip openjdk-17-jdk
else
	echo "No specific commands for this distribution."
fi

unzip openjfx-17.0.13_linux-x64_bin-sdk.zip

sudo mkdir -p /usr/lib/jvm
sudo mkdir -p /usr/lib/jvm/junit4
sudo mkdir -p /usr/lib/jvm/junit5

sudo mv javafx-sdk-17.0.13 /usr/lib/jvm
sudo mv junit-4.13.2.jar /usr/lib/jvm/junit4

sudo mv junit-jupiter-api-5.11.3.jar /usr/lib/jvm/junit5
sudo mv junit-jupiter-engine-5.11.3.jar /usr/lib/jvm/junit5
sudo mv junit-jupiter-params-5.11.3.jar /usr/lib/jvm/junit5
