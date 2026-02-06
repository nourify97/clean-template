#!/bin/bash
#
# Template Customizer Script
# Usage: bash customizer.sh com.company.myapp MyApp
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

# Verify bash version (macOS comes with bash 3 preinstalled)
if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    echo -e "${RED}You need at least bash 4 to run this script.${NC}"
    echo "On macOS, you can install it with: brew install bash"
    exit 1
fi

# Check arguments
if [[ $# -lt 2 ]]; then
    echo -e "${YELLOW}Usage: bash customizer.sh <new.package.name> <AppName>${NC}"
    echo ""
    echo "Example: bash customizer.sh com.company.myapp MyAwesomeApp"
    echo ""
    echo "Arguments:"
    echo "  <new.package.name>  The new package name (e.g., com.company.myapp)"
    echo "  <AppName>           The new app name (e.g., MyAwesomeApp)"
    exit 2
fi

NEW_PACKAGE=$1
APP_NAME=$2

# Current package info
OLD_PACKAGE="com.nourify.template"
OLD_PACKAGE_PATH="com/nourify/template"
NEW_PACKAGE_PATH=${NEW_PACKAGE//.//}

# Derived names
PROJECT_NAME=$(echo "$APP_NAME" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]')
THEME_NAME=$(echo "$APP_NAME" | sed 's/[^a-zA-Z0-9]//g')

# Validate package name
if [[ ! $NEW_PACKAGE =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
    echo -e "${RED}Invalid package name: $NEW_PACKAGE${NC}"
    echo "Package name must be lowercase, start with a letter, and contain at least two segments"
    echo "Example: com.company.myapp"
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
echo -e "  Folder:       ${YELLOW}$(basename "$(pwd)")${NC} -> ${GREEN}$PROJECT_NAME${NC}"
echo ""

# Confirm before proceeding
read -p "Do you want to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "${YELLOW}Step 1: Creating new directory structure...${NC}"

# Create new package directories
for src_dir in app/src/main/java app/src/test/java app/src/androidTest/java; do
    if [[ -d "$src_dir/$OLD_PACKAGE_PATH" ]]; then
        echo "  Creating $src_dir/$NEW_PACKAGE_PATH"
        mkdir -p "$src_dir/$NEW_PACKAGE_PATH"

        echo "  Moving files from $src_dir/$OLD_PACKAGE_PATH to $src_dir/$NEW_PACKAGE_PATH"
        cp -R "$src_dir/$OLD_PACKAGE_PATH/"* "$src_dir/$NEW_PACKAGE_PATH/" 2>/dev/null || true

        echo "  Removing old directory $src_dir/$OLD_PACKAGE_PATH"
        rm -rf "$src_dir/com/nourify"
    fi
done

echo ""
echo -e "${YELLOW}Step 2: Updating package declarations in Kotlin files...${NC}"

# Update package and import statements in Kotlin files
find . -type f -name "*.kt" -not -path "./build/*" -not -path "./.gradle/*" -exec sed -i.bak "s/package $OLD_PACKAGE/package $NEW_PACKAGE/g" {} \;
find . -type f -name "*.kt" -not -path "./build/*" -not -path "./.gradle/*" -exec sed -i.bak "s/import $OLD_PACKAGE/import $NEW_PACKAGE/g" {} \;

echo ""
echo -e "${YELLOW}Step 3: Updating Gradle files...${NC}"

# Update build.gradle.kts files
find . -type f -name "*.kts" -not -path "./build/*" -not -path "./.gradle/*" -exec sed -i.bak "s/$OLD_PACKAGE/$NEW_PACKAGE/g" {} \;

echo ""
echo -e "${YELLOW}Step 4: Updating app name in resources...${NC}"

# Update strings.xml
sed -i.bak "s/<string name=\"app_name\">.*<\/string>/<string name=\"app_name\">$APP_NAME<\/string>/g" app/src/main/res/values/strings.xml

echo ""
echo -e "${YELLOW}Step 5: Updating theme name...${NC}"

# Update theme references
find . -type f \( -name "*.xml" -o -name "*.kt" \) -not -path "./build/*" -not -path "./.gradle/*" -not -path "./.idea/*" -exec sed -i.bak "s/Theme\.Template/Theme.$THEME_NAME/g" {} \;

# Rename theme file content
if [[ -f "app/src/main/res/values/themes.xml" ]]; then
    sed -i.bak "s/Theme\.Template/Theme.$THEME_NAME/g" app/src/main/res/values/themes.xml
fi

echo ""
echo -e "${YELLOW}Step 6: Cleaning up backup files...${NC}"

# Remove backup files created by sed
find . -name "*.bak" -type f -delete

echo ""
echo -e "${YELLOW}Step 7: Cleaning build directories...${NC}"

# Clean build directories
rm -rf app/build
rm -rf build
rm -rf .gradle

echo ""
echo -e "${YELLOW}Step 8: Updating settings.gradle.kts project name...${NC}"

# Update project name in settings.gradle.kts
sed -i.bak "s/rootProject.name = \".*\"/rootProject.name = \"$PROJECT_NAME\"/g" settings.gradle.kts
find . -name "*.bak" -type f -delete

echo ""
echo -e "${YELLOW}Step 9: Removing customizer script and git history...${NC}"

# Remove this script and git history for fresh start
rm -rf .git
rm -f customizer.sh

echo ""
echo -e "${YELLOW}Step 10: Renaming project folder...${NC}"

# Get current and new folder paths
CURRENT_DIR=$(pwd)
PARENT_DIR=$(dirname "$CURRENT_DIR")
NEW_FOLDER_NAME="$PROJECT_NAME"
NEW_DIR="$PARENT_DIR/$NEW_FOLDER_NAME"

# Check if we need to rename (only if different)
if [[ "$(basename "$CURRENT_DIR")" != "$NEW_FOLDER_NAME" ]]; then
    # Check if target folder already exists
    if [[ -d "$NEW_DIR" ]]; then
        echo -e "${RED}Warning: Folder $NEW_DIR already exists. Skipping folder rename.${NC}"
    else
        echo "  Renaming folder to: $NEW_FOLDER_NAME"
        cd "$PARENT_DIR"
        mv "$(basename "$CURRENT_DIR")" "$NEW_FOLDER_NAME"
        cd "$NEW_DIR"
        echo -e "${GREEN}  Folder renamed successfully!${NC}"
    fi
else
    echo "  Folder name already matches: $NEW_FOLDER_NAME"
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}            Customization Complete!         ${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "Project folder: ${YELLOW}$NEW_FOLDER_NAME${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. ${YELLOW}cd $NEW_DIR${NC}"
echo -e "  2. ${YELLOW}Review the changes${NC} to make sure everything looks correct"
echo -e "  3. ${YELLOW}Update local.properties${NC} with your BASE_URL"
echo -e "  4. ${YELLOW}Initialize git${NC}: git init && git add . && git commit -m 'Initial commit'"
echo -e "  5. ${YELLOW}Open in Android Studio${NC} and sync Gradle"
echo -e "  6. ${YELLOW}Build and run${NC} to verify everything works"
echo ""
echo -e "${GREEN}Happy coding!${NC}"
