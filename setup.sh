#!/bin/bash
# COMP303 Starter Project Script

# Exit on first failure
set -e

# Define paths for downloads and installation directories
DOWNLOAD_DIR="$HOME/Downloads"
JAVAFX_ZIP_PATH="$DOWNLOAD_DIR/openjfx-17.0.13_linux-x64_bin-sdk.zip"

JVM_DIR="/usr/lib/jvm"
JAVAFX_DIR="$JVM_DIR/javafx-sdk-17.0.13"

JUNIT4_DIR="$JVM_DIR/junit4"
JUNIT4_PATH="$JUNIT4_DIR/junit-4.13.2.jar"
HAMCREST_PATH="$JUNIT4_DIR/hamcrest-core-1.3.jar"

JUNIT5_DIR="$JVM_DIR/junit5"
JUNIT5_API_PATH="$JUNIT5_DIR/junit-jupiter-api-5.11.3.jar"
JUNIT5_ENGINE_PATH="$JUNIT5_DIR/junit-jupiter-engine-5.11.3.jar"
JUNIT5_PARAMS_PATH="$JUNIT5_DIR/junit-jupiter-params-5.11.3.jar"

# URLs for required downloads
JUNIT4_URL="https://repo1.maven.org/maven2/junit/junit/4.13.2/junit-4.13.2.jar"
HAMCREST_URL="https://repo1.maven.org/maven2/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar"
JUNIT5_API_URL="https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-api/5.11.3/junit-jupiter-api-5.11.3.jar"
JUNIT5_ENGINE_URL="https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-engine/5.11.3/junit-jupiter-engine-5.11.3.jar"
JUNIT5_PARAMS_URL="https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-params/5.11.3/junit-jupiter-params-5.11.3.jar"
JAVAFX_URL="https://download2.gluonhq.com/openjfx/17.0.13/openjfx-17.0.13_linux-x64_bin-sdk.zip"

# Create necessary directories
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$JUNIT5_DIR" "$JVM_DIR/junit4"

#---------------fuck it lets make sure we have ~/.bashrc because debians sucks that much balls

bashrc="$HOME/.bashrc"
if [ ! -f "$bashrc" ]; then
	touch "$bashrc"
fi

#-----making sure we even have nvim.lua because otherwise the code afterward somehow doesnt work

mkdir -p "$HOME/.config/nvim"
nvim_init="$HOME/.config/nvim/init.lua"
if [ ! -f "$nvim_init" ]; then
	touch "$nvim_init"
	printf "\n\ntouching $nvim_init\n\n"
	#Some fucking how, the prinf line is necessary i have no clue
else
	printf "\n\n WTf it exists????\n\n"
	cat "$nvim_init"
	printf "\n"

fi

debian_install() {

	# Check if packages are installed, install only if missing
	for package in unzip openjdk-17-jdk wget; do
		if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed"; then
			echo "$package is not installed. Installing..."
			sudo apt install -y "$package"
		else
			echo "$package is already installed. Skipping..."
		fi
	done
}

# Determine distribution and install required packages
if grep -q "Arch" /etc/os-release; then
	echo "This system is Arch-based."
	sudo pacman -S --needed unzip jdk17-openjdk wget
elif grep -q "Debian" /etc/os-release || grep -q "Ubuntu" /etc/os-release; then
	echo "This system is Debian-based."
	debian_install
else
	echo "Unknown distribution. Exiting."
	exit 1
fi

# Function to download a file if it doesn't already exist
download_if_missing() {
	local url=$1
	local target_path=$2
	# echo "($1) | ($2)"
	if [ ! -f "$target_path" ]; then
		echo "Downloading $(basename "$target_path")..."
		wget -q --progress=bar "$url" -O "$target_path"
		echo "$(basename "$target_path") downloaded."
	else
		echo "$(basename "$target_path") already exists, skipping download."
	fi
}

# Download files if they are missing
download_if_missing "$JUNIT4_URL" "$JUNIT4_PATH"
download_if_missing "$HAMCREST_URL" "$HAMCREST_PATH"
download_if_missing "$JUNIT5_API_URL" "$JUNIT5_API_PATH"
download_if_missing "$JUNIT5_ENGINE_URL" "$JUNIT5_ENGINE_PATH"
download_if_missing "$JUNIT5_PARAMS_URL" "$JUNIT5_PARAMS_PATH"
download_if_missing "$JAVAFX_URL" "$JAVAFX_ZIP_PATH"

# Unzip JavaFX SDK if not already unzipped
if [ ! -d "$JAVAFX_DIR" ]; then
	echo "Unzipping JavaFX SDK..."
	unzip -q "$JAVAFX_ZIP_PATH" -d "$JVM_DIR"
	echo "JavaFX SDK unzipped."
else
	echo "JavaFX SDK already exists, skipping unzip."
fi

#------------APPENDING TO THE FILES-------------
# Function to append the init.lua from the repository to ~/.config/nvim/init.lua
append_to_init_lua() {
	REPO_INIT_LUA="./init.lua"
	TARGET_INIT_LUA="$HOME/.config/nvim/init.lua"

	if [ -f "$REPO_INIT_LUA" ]; then
		echo "Appending $REPO_INIT_LUA to $TARGET_INIT_LUA..."
		cat "$REPO_INIT_LUA" >>"$TARGET_INIT_LUA"
		echo "Content from init.lua in repo added to ~/.config/nvim/init.lua."
	else
		echo "init.lua in repository not found at $REPO_INIT_LUA."
	fi
}

# Function to append the .bashrc from the repository to ~/.bashrc
append_to_bashrc() {
	REPO_BASHRC="./.bashrc"
	TARGET_BASHRC="$HOME/.bashrc"

	if [ -f "$REPO_BASHRC" ]; then
		echo "Appending $REPO_BASHRC to $TARGET_BASHRC..."
		cat "$REPO_BASHRC" >>"$TARGET_BASHRC"
		echo "Content from .bashrc in repo added to ~/.bashrc."
	else
		echo ".bashrc in repository not found at $REPO_BASHRC."
	fi
}

# Conditionally call functions based on content of init.lua and .bashrc
if ! grep -q '!bash ./build.sh' ~/.config/nvim/init.lua; then
	append_to_init_lua
fi

if ! grep -q '#ADDING JAVA PATHS' ~/.bashrc; then
	append_to_bashrc
fi
