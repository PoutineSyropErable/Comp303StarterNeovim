# COMP303 Starter Project

#This is for Linux, Using neovim to run the java code
If you are really lazy and you trust me:

sudo -E ./setup
(If you want to have the init.lua append, you need the -E).
Fucking hell it took way to long to debug that

I have tested it on a clean arch vm, it works. Don't know about debian i forgot my password of my ubuntu vm and im not creating a new one. 
Already 1am



(Assuming you have wget, if you don't, you don't need this guide lol. You must be a No bloat purist linux pro)
#First: Download Junit4
## You can use wget or just copy paste in your browser/whatever
wget https://repo1.maven.org/maven2/junit/junit/4.13.2/junit-4.13.2.jar
#Download hamcrest
wget https://repo1.maven.org/maven2/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar



#Then Junit5 (We dont need it, but hey...)
wget https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-api/5.11.3/junit-jupiter-api-5.11.3.jar
wget https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-engine/5.11.3/junit-jupiter-engine-5.11.3.jar 
wget https://repo1.maven.org/maven2/org/junit/jupiter/junit-jupiter-params/5.11.3/junit-jupiter-params-5.11.3.jar 


#Then JavaFX: (I'm using Java17 cause It seems the Neovim packages are there)
wget https://download2.gluonhq.com/openjfx/23.0.1/openjfx-23.0.1_linux-x64_bin-sdk.zip
#(https://gluonhq.com/products/javafx/) (If you want to manually download it)


#(Install unzip to unzip the file. pacman on Arch-Based, apt install on Debian-based)
sudo pacman -S --needed unzip jdk17-openjdk
sudo apt install unzip openjdk-17-jdk


unzip openjfx-23.0.1_linux-x64_bin-sdk.zip

sudo mkdir /usr/lib/jvm/junit4
sudo mkdir /usr/lib/jvm/junit5


sudo mv javafx-sdk-17.0.13 /usr/lib/jvm
sudo mv junit-4.13.2.jar /usr/lib/jvm/junit4
sudo mv hamcrest-core-1.3.jar /usr/lib/jvm/junit4/


sudo mv junit-jupiter-api-5.11.3.jar /usr/lib/jvm/junit5
sudo mv junit-jupiter-engine-5.11.3.jar /usr/lib/jvm/junit5
sudo mv junit-jupiter-params-5.11.3.jar /usr/lib/jvm/junit5


Add this to your neovim config. (either your dedicated keymaps file, or ~/.config/nvim/init.lua if
you are new to neovim) 
"""
vim.api.nvim_set_keymap(
	"n",
	"<F6>",
	':lua vim.cmd("!bash ./build.sh " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(0)))<CR>',
	{ noremap = true, silent = true }
)
"""


Then, you can copy the initial exports of ./build_scripts/build_basic.sh (or the variable one) to 
your bashrc/fishrc/zshrc

It shouldn't really be needed, but if you want to do it manually from cmdline, it would be easier.

""" 

# Set JAVA_HOME and add Java to PATH
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

"""
