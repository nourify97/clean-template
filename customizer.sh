#!/bin/bash
#
# Template Customizer Script
# Usage: bash customizer.sh com.company.myapp MyApp
#
# IMPORTANT: Run this script BEFORE opening the project in Android Studio!
#
# This script customizes the template for a new project by:
# - Renaming the package from com.nourify.template to your package
# - Renaming the app name
# - Updating all related configurations
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [[ $# -lt 2 ]]; then
    echo -e "${YELLOW}Usage: bash customizer.sh <new.package.name> <AppName>${NC}"
    echo ""
    echo "Example: bash customizer.sh nl.coffeeit.heko Heko"
    echo ""
    echo "Arguments:"
    echo "  <new.package.name>  The new package name (e.g., nl.coffeeit.heko)"
    echo "  <AppName>           The new app name (e.g., Heko)"
    echo ""
    echo -e "${RED}IMPORTANT: Run this BEFORE opening the project in Android Studio!${NC}"
    exit 2
fi

NEW_PACKAGE=$1
APP_NAME=$2

# Current package info
OLD_PACKAGE="com.nourify.template"
OLD_SUBDIR="com/nourify/template"
NEW_SUBDIR=${NEW_PACKAGE//.//} # Replaces . with /

# Derived names
PROJECT_NAME=$(echo "$APP_NAME" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]')
THEME_NAME=$(echo "$APP_NAME" | sed 's/[^a-zA-Z0-9]//g')

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
echo ""

# Confirm before proceeding
read -p "Do you want to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "${YELLOW}Step 1: Moving files to new package structure...${NC}"

# Move files to new package directories using the same pattern as the reference script
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

echo ""
echo -e "${YELLOW}Step 2: Updating package declarations in Kotlin files...${NC}"

# Update package and import statements in Kotlin files
find ./ -type f -name "*.kt" -exec sed -i.bak "s/package $OLD_PACKAGE/package $NEW_PACKAGE/g" {} \;
find ./ -type f -name "*.kt" -exec sed -i.bak "s/import $OLD_PACKAGE/import $NEW_PACKAGE/g" {} \;

echo ""
echo -e "${YELLOW}Step 3: Updating Gradle files...${NC}"

# Update build.gradle.kts files
find ./ -type f -name "*.kts" -exec sed -i.bak "s/$OLD_PACKAGE/$NEW_PACKAGE/g" {} \;

echo ""
echo -e "${YELLOW}Step 4: Updating app name in resources...${NC}"

# Update strings.xml
sed -i.bak "s/<string name=\"app_name\">.*<\/string>/<string name=\"app_name\">$APP_NAME<\/string>/g" app/src/main/res/values/strings.xml

echo ""
echo -e "${YELLOW}Step 5: Updating theme name...${NC}"

# Update theme references in xml and kt files
find ./ -type f \( -name "*.xml" -o -name "*.kt" \) -exec sed -i.bak "s/Theme\.Template/Theme.$THEME_NAME/g" {} \;

echo ""
echo -e "${YELLOW}Step 6: Updating settings.gradle.kts project name...${NC}"

# Update project name in settings.gradle.kts
sed -i.bak "s/rootProject.name = \".*\"/rootProject.name = \"$PROJECT_NAME\"/g" settings.gradle.kts

echo ""
echo -e "${YELLOW}Step 7: Cleaning up...${NC}"

# Remove backup files created by sed
find . -name "*.bak" -type f -delete

# Clean build directories and IDE files
rm -rf app/build
rm -rf build
rm -rf .gradle
rm -rf .idea
rm -rf .kotlin

echo ""
echo -e "${YELLOW}Step 8: Removing git history and customizer script...${NC}"

# Remove git history and this script for fresh start
rm -rf .git
rm -f customizer.sh

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}            Customization Complete!         ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. ${YELLOW}Rename the folder${NC} (optional): mv ../$(basename "$(pwd)") ../$PROJECT_NAME"
echo -e "  2. ${YELLOW}Open in Android Studio${NC} and let it sync"
echo -e "  3. ${YELLOW}Update local.properties${NC} with your BASE_URL"
echo -e "  4. ${YELLOW}Initialize git${NC}: git init && git add . && git commit -m 'Initial commit'"
echo -e "  5. ${YELLOW}Build and run${NC} to verify everything works"
echo ""
echo -e "${GREEN}Happy coding!${NC}"
