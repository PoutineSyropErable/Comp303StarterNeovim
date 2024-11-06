#!/bin/bash
# COMP303 Starter Project Script

# Exit on first failures
set -e

mkdir -p ~/Downloads
cd ~/Downloads || exit 1

#This is for Linux, Using neovim to run the java code

#------------------------------------------------------find distro

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

if [[ $IS_ARCH -eq 1 ]]; then
	echo "Running Arch-specific command"
	sudo pacman -S --needed unzip jdk17-openjdk wget

elif [[ $IS_DEBIAN -eq 1 ]]; then
	echo "Running Debian-specific command"
	#No needed check, reinstalling shouldn't cause problem, but im not gonna create perfect code for debian lol
	sudo apt install unzip openjdk-17-jdk wget
else
	echo "No specific commands for this distribution."
fi

#--------------------------------------------------------- CHECK IF YOU HAVEN'T ALREADY DOWNLOADED THE FILES, THEN DOWNLOAD

# Define download URLs and target paths
JUNIT4_URL="https://repo1.maven.org/maven2/junit/junit/4.13.2/junit-4.13.2.jar"
JUNIT5_API_URL="https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-api/5.11.3/junit-jupiter-api-5.11.3.jar"
JUNIT5_ENGINE_URL="https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-engine/5.11.3/junit-jupiter-engine-5.11.3.jar"
JUNIT5_PARAMS_URL="https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-params/5.11.3/junit-jupiter-params-5.11.3.jar"
JAVAFX_URL="https://download2.gluonhq.com/openjfx/17.0.13/openjfx-17.0.13_linux-x64_bin-sdk.zip"

# Define local paths
DOWNLOAD_DIR="/usr/lib/jvm"
JUNIT4_PATH="$DOWNLOAD_DIR/junit-4.13.2.jar"
JUNIT5_API_PATH="$DOWNLOAD_DIR/junit-jupiter-api-5.11.3.jar"
JUNIT5_ENGINE_PATH="$DOWNLOAD_DIR/junit-jupiter-engine-5.11.3.jar"
JUNIT5_PARAMS_PATH="$DOWNLOAD_DIR/junit-jupiter-params-5.11.3.jar"
JAVAFX_ZIP_PATH="$DOWNLOAD_DIR/openjfx-17.0.13_linux-x64_bin-sdk.zip"

# Function to download a file if it doesn't already exist
download_if_missing() {
	local url=$1
	local target_path=$2
	if [ ! -f "$target_path" ]; then
		echo "Downloading $(basename "$target_path")..."
		wget -q "$url" -O "$target_path"
		echo "$(basename "$target_path") downloaded."
	else
		echo "$(basename "$target_path") already exists, skipping download."
	fi
}

# Download files with checks
download_if_missing "$JUNIT4_URL" "$JUNIT4_PATH"
download_if_missing "$JUNIT5_API_URL" "$JUNIT5_API_PATH"
download_if_missing "$JUNIT5_ENGINE_URL" "$JUNIT5_ENGINE_PATH"
download_if_missing "$JUNIT5_PARAMS_URL" "$JUNIT5_PARAMS_PATH"
download_if_missing "$JAVAFX_URL" "$JAVAFX_ZIP_PATH"

unzip openjfx-17.0.13_linux-x64_bin-sdk.zip

sudo mkdir -p /usr/lib/jvm
sudo mkdir -p /usr/lib/jvm/junit4
sudo mkdir -p /usr/lib/jvm/junit5

sudo mv javafx-sdk-17.0.13 /usr/lib/jvm
sudo mv junit-4.13.2.jar /usr/lib/jvm/junit4

sudo mv junit-jupiter-api-5.11.3.jar /usr/lib/jvm/junit5
sudo mv junit-jupiter-engine-5.11.3.jar /usr/lib/jvm/junit5
sudo mv junit-jupiter-params-5.11.3.jar /usr/lib/jvm/junit5

#------------------------------Adding stuff to paths, not really needed but hey--------------------------------------------
if ! grep -q "^#ADDING JAVA PATHS" ~/.bashrc; then
	cat <<'EOF' >>~/.bashrc

#ADDING JAVA PATHS
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH_TO_FX="/usr/lib/jvm/javafx-sdk-17.0.13/lib"
export PATH="$JAVA_HOME/bin:$PATH"

# Set paths for JUnit 5 and JUnit 4
export JUNIT5_PATH="/usr/lib/jvm/junit5"
export JUNIT4_PATH="/usr/lib/jvm/junit4"

# Add JUnit paths to CLASSPATH // WE DO NOT USE JUNIT5 FOR NOW BUT IT IS THERE
export CLASSPATH="$JUNIT5_PATH/junit-jupiter-api-5.11.3.jar:\
$JUNIT5_PATH/junit-jupiter-engine-5.11.3.jar:\
$JUNIT5_PATH/junit-jupiter-params-5.11.3.jar:\
$JUNIT4_PATH/junit-4.13.2.jar"

EOF
fi

#--------------------Adding the neovim command--------------------------------
if ! grep -q '!bash ./build.sh' ~/.config/nvim/init.lua; then
	cat <<'EOF' >>~/.config/nvim/init.lua

vim.api.nvim_set_keymap(
	"n",
	"<F6>",
	':lua vim.cmd("!bash ./build.sh " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))<CR>',
	{ noremap = true, silent = true }
)

EOF
fi
