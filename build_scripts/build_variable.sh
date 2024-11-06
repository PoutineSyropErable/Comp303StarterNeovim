#!/bin/bash

# Set JAVA_HOME and add Java to PATH
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

# If executed the one in ./build_script, it cd back to the project root
if [[ ! -d "src" ]]; then
	cd ..
fi

#--------------------------------------GETTING THE FILE----------------------------------------------

#^ The file we wish to compile (if given no argument) dirname.filename (Since we are only 2 directory deep)
DEFAULT_MODULE_TO_EXECUTE="demo.Welcome"

# Check if argument $1 is provided
if [[ -n "$1" ]]; then
	# Extract directory and filename components
	ABSOLUTE_PATH=$(realpath "$1")
	SCRIPT_PATH=$(realpath "$0")
	printf "\ninput path: $1\n"
	echo "Absolute path: $ABSOLUTE_PATH"
	printf "script path: $SCRIPT_PATH\n\n"

	DIRNAME_PATH=$(dirname "$ABSOLUTE_PATH") # Remove "src/" prefix
	DIRNAME=$(basename "$DIRNAME_PATH")
	FILENAME=$(basename "$1" .java) # Strip .java extension
	echo "dirname_path: $DIRNAME_PATH"
	echo "dirname: $DIRNAME"
	printf "filename: $FILENAME\n\n"

	MODULE_TO_EXECUTE="$DIRNAME.$FILENAME" # Convert path to module notation
	printf "using $MODULE_TO_EXECUTE\n\n"

else
	# Use default module if no file is specified
	MODULE_TO_EXECUTE="$DEFAULT_MODULE_TO_EXECUTE"
	printf "No file specified. Using default module: $DEFAULT_MODULE_TO_EXECUTE\n\n"
fi
#-------------------------------------------------------------------------------------

#-------------------------------------COMPILING & OPTIONS----------------------------
# Variables for paths and modules
OUTPUT_DIR="out" # The output directory for compiled files
SRC_DIR="src"    # The source directory
MODULE_NAME="demo"
ALL_JAVA_FILES=$(find "$SRC_DIR" -name "*.java")      # All .java files in the source directory
MAIN_MODULE="$MODULE_NAME/comp303.$MODULE_TO_EXECUTE" # Main module to run

# Recompile all Java files (Overkill, but let's not recreate a makefile from scratch for java)
javac --module-path "$PATH_TO_FX:$JUNIT4_PATH" \
	--add-modules "javafx.base,javafx.controls,javafx.graphics" \
	-d "$OUTPUT_DIR" $ALL_JAVA_FILES

#-----------------------------------EXECUTING THE FILE--------------------------------

printf -- "\n\n-------------------------START OF PROGRAM-----------------------------\n\n"

java --module-path "$PATH_TO_FX:$OUTPUT_DIR" \
	--add-modules "javafx.base,javafx.controls,javafx.graphics" \
	-cp "$JUNIT4_PATH" \
	-m "$MAIN_MODULE"
