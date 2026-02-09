#!/bin/bash
#
# Template Customizer Script
# Usage: bash customizer.sh com.company.myapp MyApp [--signing]
#
# IMPORTANT: Run this script BEFORE opening the project in Android Studio!
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [[ $# -lt 2 ]]; then
    echo -e "${YELLOW}Usage: bash customizer.sh <package.name> <AppName> [--signing]${NC}"
    echo ""
    echo "Example: bash customizer.sh nl.coffeeit.heko Heko"
    echo "Example: bash customizer.sh nl.coffeeit.heko Heko --signing"
    echo ""
    echo -e "${RED}IMPORTANT: Run this BEFORE opening the project in Android Studio!${NC}"
    exit 2
fi

NEW_PACKAGE=$1
APP_NAME=$2

# Check for --signing flag
ENABLE_SIGNING=false
for arg in "${@:3}"; do
    if [[ "$arg" == "--signing" ]]; then
        ENABLE_SIGNING=true
    fi
done

# Default BASE_URL for testing
BASE_URL="https://jsonplaceholder.typicode.com/"

# Current package info
OLD_PACKAGE="com.nourify.template"
OLD_SUBDIR="com/nourify/template"
NEW_SUBDIR=${NEW_PACKAGE//.//} # Replaces . with /

# Derived names
PROJECT_NAME=$(echo "$APP_NAME" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]')
THEME_NAME=$(echo "$APP_NAME" | sed 's/[^a-zA-Z0-9]//g')

# Store folder paths for later renaming
CURRENT_DIR=$(pwd)
PARENT_DIR=$(dirname "$CURRENT_DIR")
CURRENT_FOLDER=$(basename "$CURRENT_DIR")
NEW_FOLDER="$PROJECT_NAME"

# Validate package name
if [[ ! $NEW_PACKAGE =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
    echo -e "${RED}Invalid package name: $NEW_PACKAGE${NC}"
    echo "Package name must be lowercase, start with a letter, and contain at least two segments"
    echo "Example: nl.coffeeit.myapp"
    exit 1
fi

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}       Template Customizer Script          ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "The following changes will be made:"
echo ""
echo -e "  Package:      ${YELLOW}$OLD_PACKAGE${NC} -> ${GREEN}$NEW_PACKAGE${NC}"
echo -e "  App name:     ${YELLOW}template${NC} -> ${GREEN}$APP_NAME${NC}"
echo -e "  Theme:        ${YELLOW}Theme.Template${NC} -> ${GREEN}Theme.$THEME_NAME${NC}"
echo -e "  Project name: ${YELLOW}template${NC} -> ${GREEN}$PROJECT_NAME${NC}"
echo -e "  Folder:       ${YELLOW}$CURRENT_FOLDER${NC} -> ${GREEN}$NEW_FOLDER${NC}"
if [[ "$ENABLE_SIGNING" == true ]]; then
    echo -e "  Signing:      ${GREEN}Enabled${NC} (will generate release keystore)"
else
    echo -e "  Signing:      ${YELLOW}Disabled${NC} (use --signing to enable)"
fi
echo ""

# Confirm before proceeding
read -p "Do you want to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

STEP=1

echo ""
echo -e "${YELLOW}Step $STEP: Moving files to new package structure...${NC}"

# Move files to new package directories
for n in $(find . -type d \( -path '*/src/androidTest' -or -path '*/src/main' -or -path '*/src/test' \) )
do
    if [[ -d "$n/java/$OLD_SUBDIR" ]]; then
        echo "  Creating $n/java/$NEW_SUBDIR"
        mkdir -p "$n/java/$NEW_SUBDIR"

        echo "  Moving files to $n/java/$NEW_SUBDIR"
        mv "$n/java/$OLD_SUBDIR"/* "$n/java/$NEW_SUBDIR/" 2>/dev/null || true

        echo "  Removing old directory $n/java/com"
        rm -rf "$n/java/com"
    fi
done

STEP=$((STEP + 1))
echo ""
echo -e "${YELLOW}Step $STEP: Updating package declarations in Kotlin files...${NC}"

# Update package and import statements in Kotlin files
find ./ -type f -name "*.kt" -exec sed -i.bak "s/package $OLD_PACKAGE/package $NEW_PACKAGE/g" {} \;
find ./ -type f -name "*.kt" -exec sed -i.bak "s/import $OLD_PACKAGE/import $NEW_PACKAGE/g" {} \;

# Update string literals (e.g., @ComponentScan annotation)
find ./ -type f -name "*.kt" -exec sed -i.bak "s/\"$OLD_PACKAGE\"/\"$NEW_PACKAGE\"/g" {} \;

STEP=$((STEP + 1))
echo ""
echo -e "${YELLOW}Step $STEP: Updating Gradle files...${NC}"

# Update build.gradle.kts files
find ./ -type f -name "*.kts" -exec sed -i.bak "s/$OLD_PACKAGE/$NEW_PACKAGE/g" {} \;

STEP=$((STEP + 1))
echo ""
echo -e "${YELLOW}Step $STEP: Updating app name in resources...${NC}"

# Update strings.xml
sed -i.bak "s/<string name=\"app_name\">.*<\/string>/<string name=\"app_name\">$APP_NAME<\/string>/g" app/src/main/res/values/strings.xml

STEP=$((STEP + 1))
echo ""
echo -e "${YELLOW}Step $STEP: Updating app name in product flavors...${NC}"

# Update product flavor app names in build.gradle.kts
sed -i.bak "s/resValue(\"string\", \"app_name\", \"Template Dev\")/resValue(\"string\", \"app_name\", \"$APP_NAME Dev\")/g" app/build.gradle.kts
sed -i.bak "s/resValue(\"string\", \"app_name\", \"Template Tst\")/resValue(\"string\", \"app_name\", \"$APP_NAME Tst\")/g" app/build.gradle.kts
sed -i.bak "s/resValue(\"string\", \"app_name\", \"Template Acc\")/resValue(\"string\", \"app_name\", \"$APP_NAME Acc\")/g" app/build.gradle.kts
sed -i.bak "s/resValue(\"string\", \"app_name\", \"Template\")/resValue(\"string\", \"app_name\", \"$APP_NAME\")/g" app/build.gradle.kts

STEP=$((STEP + 1))
echo ""
echo -e "${YELLOW}Step $STEP: Updating theme name...${NC}"

# Update theme references in xml and kt files
find ./ -type f \( -name "*.xml" -o -name "*.kt" \) -exec sed -i.bak "s/Theme\.Template/Theme.$THEME_NAME/g" {} \;

STEP=$((STEP + 1))
echo ""
echo -e "${YELLOW}Step $STEP: Updating settings.gradle.kts project name...${NC}"

# Update project name in settings.gradle.kts
sed -i.bak "s/rootProject.name = \".*\"/rootProject.name = \"$PROJECT_NAME\"/g" settings.gradle.kts

STEP=$((STEP + 1))
echo ""
echo -e "${YELLOW}Step $STEP: Configuring local.properties...${NC}"

# Create local.properties with SDK path and environment-specific BASE_URLs
cat > local.properties << EOF
## This file must *NOT* be checked into Version Control Systems,
# as it contains information specific to your local configuration.
#
# Location of the SDK. This is only used by Gradle.
sdk.dir=$HOME/Library/Android/sdk

# Environment-specific BASE URLs
BASE_URL=$BASE_URL
BASE_URL_DEV=$BASE_URL
BASE_URL_TST=$BASE_URL
BASE_URL_ACC=$BASE_URL
BASE_URL_PROD=$BASE_URL
EOF

echo "  Environment-specific BASE URLs configured (all set to: $BASE_URL)"
echo "  You can customize each environment's URL in local.properties if needed"

# Signing key generation (optional)
if [[ "$ENABLE_SIGNING" == true ]]; then
    STEP=$((STEP + 1))
    echo ""
    echo -e "${YELLOW}Step $STEP: Generating signing key...${NC}"

    # Check keytool is available
    if ! command -v keytool &> /dev/null; then
        echo -e "${RED}Error: keytool not found. Make sure JDK is installed and on your PATH.${NC}"
        exit 1
    fi

    KEYSTORE_DIR="$HOME/.android/keystores"
    KEYSTORE_FILE="$KEYSTORE_DIR/${PROJECT_NAME}-release.jks"

    # Prompt for signing details
    echo ""
    read -p "  Key alias [$PROJECT_NAME-key]: " KEY_ALIAS
    KEY_ALIAS=${KEY_ALIAS:-"$PROJECT_NAME-key"}

    while true; do
        read -s -p "  Store password (min 6 chars): " STORE_PASSWORD
        echo
        if [[ ${#STORE_PASSWORD} -lt 6 ]]; then
            echo -e "  ${RED}Password must be at least 6 characters.${NC}"
            continue
        fi
        read -s -p "  Confirm store password: " STORE_PASSWORD_CONFIRM
        echo
        if [[ "$STORE_PASSWORD" != "$STORE_PASSWORD_CONFIRM" ]]; then
            echo -e "  ${RED}Passwords do not match. Try again.${NC}"
            continue
        fi
        break
    done

    while true; do
        read -s -p "  Key password (min 6 chars): " KEY_PASSWORD
        echo
        if [[ ${#KEY_PASSWORD} -lt 6 ]]; then
            echo -e "  ${RED}Password must be at least 6 characters.${NC}"
            continue
        fi
        read -s -p "  Confirm key password: " KEY_PASSWORD_CONFIRM
        echo
        if [[ "$KEY_PASSWORD" != "$KEY_PASSWORD_CONFIRM" ]]; then
            echo -e "  ${RED}Passwords do not match. Try again.${NC}"
            continue
        fi
        break
    done

    read -p "  Organization [$APP_NAME]: " KEY_ORG
    KEY_ORG=${KEY_ORG:-"$APP_NAME"}

    read -p "  Country code [US]: " KEY_COUNTRY
    KEY_COUNTRY=${KEY_COUNTRY:-"US"}

    # Create keystores directory
    mkdir -p "$KEYSTORE_DIR"

    # Check if keystore already exists
    if [[ -f "$KEYSTORE_FILE" ]]; then
        echo -e "  ${RED}Warning: Keystore already exists at $KEYSTORE_FILE${NC}"
        read -p "  Overwrite? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "  ${YELLOW}Skipping keystore generation. Using existing keystore.${NC}"
        else
            rm -f "$KEYSTORE_FILE"
        fi
    fi

    # Generate keystore if it doesn't exist (or was just deleted)
    if [[ ! -f "$KEYSTORE_FILE" ]]; then
        echo ""
        echo "  Generating keystore..."
        keytool -genkeypair -v \
            -keystore "$KEYSTORE_FILE" \
            -alias "$KEY_ALIAS" \
            -keyalg RSA \
            -keysize 2048 \
            -validity 10000 \
            -storepass "$STORE_PASSWORD" \
            -keypass "$KEY_PASSWORD" \
            -dname "CN=$APP_NAME, O=$KEY_ORG, C=$KEY_COUNTRY"

        echo -e "  ${GREEN}Keystore created at: $KEYSTORE_FILE${NC}"
    fi

    # Append signing properties to local.properties
    cat >> local.properties << EOF
STORE_FILE=$KEYSTORE_FILE
STORE_PASSWORD=$STORE_PASSWORD
KEY_ALIAS=$KEY_ALIAS
KEY_PASSWORD=$KEY_PASSWORD
EOF

    echo -e "  ${GREEN}Signing properties added to local.properties${NC}"
fi

STEP=$((STEP + 1))
echo ""
echo -e "${YELLOW}Step $STEP: Cleaning up...${NC}"

# Remove backup files created by sed
find . -name "*.bak" -type f -delete

# Clean build directories and IDE files
rm -rf app/build
rm -rf build
rm -rf .gradle
rm -rf .idea
rm -rf .kotlin

STEP=$((STEP + 1))
echo ""
echo -e "${YELLOW}Step $STEP: Creating .gitignore...${NC}"

cat > .gitignore << 'GITIGNORE'
# Built application files
*.apk
*.aar
*.ap_
*.aab

# Files for the ART/Dalvik VM
*.dex

# Java class files
*.class

# Generated files
bin/
gen/
out/

# Gradle files
.gradle/
build/

# Local configuration file (sdk path, etc)
local.properties

# Android Studio
*.iml
.idea/
.idea/caches
.idea/libraries
.idea/modules.xml
.idea/workspace.xml
.idea/navEditor.xml
.idea/assetWizardSettings.xml

# Keystore files
*.jks
*.keystore

# External native build folder generated in Android Studio 2.2 and later
.externalNativeBuild/
.cxx/

# Google Services
google-services.json

# OS files
.DS_Store
Thumbs.db

# Captures
/captures
GITIGNORE

STEP=$((STEP + 1))
echo ""
echo -e "${YELLOW}Step $STEP: Creating README.md...${NC}"

cat > README.md << README
# $APP_NAME

Android application built with Clean Architecture.

## Tech Stack

- **Language:** Kotlin
- **UI:** Jetpack Compose
- **Architecture:** MVVM + Clean Architecture
- **DI:** Hilt
- **Networking:** Retrofit
- **Local DB:** Room
- **Navigation:** Compose Navigation

## Project Structure

\`\`\`
$NEW_PACKAGE
├── core/di/          # Dependency injection modules
├── data/
│   ├── dto/          # Data transfer objects
│   ├── local/db/     # Room database, DAOs, entities
│   ├── mappers/      # Data <-> Domain mappers
│   ├── remote/api/   # Retrofit API service
│   └── repositories/ # Repository implementations
├── domain/
│   ├── models/       # Domain models
│   ├── repositories/ # Repository interfaces
│   └── usecases/     # Use cases
└── ui/
    ├── navigation/   # Nav graph & destinations
    ├── screens/      # Screen composables & ViewModels
    └── theme/        # Color, Theme, Typography
\`\`\`

## Getting Started

1. Open the project in Android Studio
2. Let Gradle sync
3. Build and run
README

STEP=$((STEP + 1))
echo ""
echo -e "${YELLOW}Step $STEP: Removing git history and customizer script...${NC}"

# Remove git history and this script for fresh start
rm -rf .git
rm -f customizer.sh

STEP=$((STEP + 1))
echo ""
echo -e "${YELLOW}Step $STEP: Renaming project folder...${NC}"

# Rename the folder if needed
if [[ "$CURRENT_FOLDER" != "$NEW_FOLDER" ]]; then
    if [[ -d "$PARENT_DIR/$NEW_FOLDER" ]]; then
        echo -e "${RED}  Warning: Folder '$NEW_FOLDER' already exists. Skipping rename.${NC}"
        echo -e "  You can manually rename: mv '$CURRENT_DIR' '$PARENT_DIR/$NEW_FOLDER'"
    else
        cd "$PARENT_DIR"
        mv "$CURRENT_FOLDER" "$NEW_FOLDER"
        echo -e "${GREEN}  Folder renamed to: $NEW_FOLDER${NC}"
        CURRENT_DIR="$PARENT_DIR/$NEW_FOLDER"
    fi
else
    echo "  Folder name already matches: $NEW_FOLDER"
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}            Customization Complete!         ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "Project location: ${GREEN}$CURRENT_DIR${NC}"
echo ""
if [[ "$ENABLE_SIGNING" == true ]]; then
    echo -e "Keystore location: ${GREEN}$KEYSTORE_FILE${NC}"
    echo -e "Key alias:         ${GREEN}$KEY_ALIAS${NC}"
    echo ""
fi
echo -e "Next steps:"
echo -e "  1. ${YELLOW}Open in Android Studio${NC} and let it sync"
echo -e "  2. ${YELLOW}Initialize git${NC}:"
echo -e "     cd $CURRENT_DIR"
echo -e "     git init && git add . && git commit -m 'Initial commit'"
echo -e "  3. ${YELLOW}Build and run${NC} to verify everything works"
echo ""
echo -e "${GREEN}Happy coding!${NC}"
