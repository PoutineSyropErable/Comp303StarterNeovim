#!/bin/bash
# COMP303 Starter Project Script

# Exit on first failure
set -e

# Define paths for downloads and installation directories
DOWNLOAD_DIR="$HOME/Downloads"
JVM_DIR="/usr/lib/jvm"
JAVAFX_ZIP_PATH="$DOWNLOAD_DIR/openjfx-17.0.13_linux-x64_bin-sdk.zip"
JAVAFX_DIR="$JVM_DIR/javafx-sdk-17.0.13"
JUNIT4_PATH="$JVM_DIR/junit4/junit-4.13.2.jar"
JUNIT5_DIR="$JVM_DIR/junit5"
JUNIT5_API_PATH="$JUNIT5_DIR/junit-jupiter-api-5.11.3.jar"
JUNIT5_ENGINE_PATH="$JUNIT5_DIR/junit-jupiter-engine-5.11.3.jar"
JUNIT5_PARAMS_PATH="$JUNIT5_DIR/junit-jupiter-params-5.11.3.jar"

# URLs for required downloads
JUNIT4_URL="https://repo1.maven.org/maven2/junit/junit/4.13.2/junit-4.13.2.jar"
JUNIT5_API_URL="https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-api/5.11.3/junit-jupiter-api-5.11.3.jar"
JUNIT5_ENGINE_URL="https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-engine/5.11.3/junit-jupiter-engine-5.11.3.jar"
JUNIT5_PARAMS_URL="https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-params/5.11.3/junit-jupiter-params-5.11.3.jar"
JAVAFX_URL="https://download2.gluonhq.com/openjfx/17.0.13/openjfx-17.0.13_linux-x64_bin-sdk.zip"

# Create necessary directories
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$JUNIT5_DIR" "$JVM_DIR/junit4"

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
	if [ ! -f "$target_path" ]; then
		echo "Downloading $(basename "$target_path")..."
		wget -q "$url" -O "$target_path"
		echo "$(basename "$target_path") downloaded."
	else
		echo "$(basename "$target_path") already exists, skipping download."
	fi
}

# Download files if they are missing
download_if_missing "$JUNIT4_URL" "$JUNIT4_PATH"
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

#---------------------------------------------------- Add Java paths to ~/.bashrc if not already added
if ! grep -q "^#ADDING JAVA PATHS" ~/.bashrc; then
	echo "Adding Java paths to ~/.bashrc..."
	cat <<'EOF' >>~/.bashrc

#ADDING JAVA PATHS
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH_TO_FX="/usr/lib/jvm/javafx-sdk-17.0.13/lib"
export PATH="$JAVA_HOME/bin:$PATH"

# Set paths for JUnit 5 and JUnit 4
export JUNIT5_PATH="/usr/lib/jvm/junit5"
export JUNIT4_PATH="/usr/lib/jvm/junit4"

# Add JUnit paths to CLASSPATH
export CLASSPATH="$JUNIT5_PATH/junit-jupiter-api-5.11.3.jar:\
$JUNIT5_PATH/junit-jupiter-engine-5.11.3.jar:\
$JUNIT5_PATH/junit-jupiter-params-5.11.3.jar:\
$JUNIT4_PATH/junit-4.13.2.jar"

EOF
	echo "Java paths added to ~/.bashrc."
else
	echo "Java paths already exist in ~/.bashrc."
fi

#--------------------------------------------------------------
mkdir -p ~/.config/nvim
nvim_init="$HOME/.config/nvim/init.lua"
[ ! -f "$nvim_init" ] && touch "$nvim_init"

#------------------------------------------ Add Neovim build script mapping to init.lua if not already added
if ! grep -q '!bash ./build.sh' ~/.config/nvim/init.lua; then
	echo "Adding Neovim <F6> mapping for build script to init.lua..."
	cat <<'EOF' >>~/.config/nvim/init.lua




vim.api.nvim_set_keymap(
	"n",
	"<F6>",
	':lua vim.cmd("!bash ./build.sh " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))<CR>',
	{ noremap = true, silent = true }
)

EOF
	echo "Neovim mapping added."
else
	echo "Neovim mapping already exists in init.lua."
fi

echo "Setup complete."
