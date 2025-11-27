#!/bin/bash

BASE_URL="https://raw.githubusercontent.com/TheG00DMan/CCD/main/INSTALLS"
LIST_URL="https://api.github.com/repos/TheG00DMan/CCD/contents/INSTALLS"

# Fetch file list from GitHub API
echo "Fetching available install scripts..."
FILES=$(curl -fsSL "$LIST_URL" | grep '"name"' | cut -d '"' -f 4)

# Filter to only install_*.sh files
INSTALL_SCRIPTS=()
for f in $FILES; do
    if [[ "$f" == install_*.sh ]]; then
        INSTALL_SCRIPTS+=("$f")
    fi
done

# No scripts found?
if [ ${#INSTALL_SCRIPTS[@]} -eq 0 ]; then
    echo "No install scripts found in the INSTALLS folder."
    exit 1
fi

# Display menu
echo ""
echo "===== CCD Installer Menu ====="
i=1
for script in "${INSTALL_SCRIPTS[@]}"; do
    echo "  $i) $script"
    ((i++))
done
echo "  0) Exit"
echo "=============================="
echo ""

# Read choice
read -p "Choose an install option: " choice

# Exit
if [[ "$choice" == "0" ]]; then
    echo "Exiting."
    exit 0
fi

# Validate choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#INSTALL_SCRIPTS[@]} ]; then
    echo "Invalid selection."
    exit 1
fi

# Selected script
SELECTED="${INSTALL_SCRIPTS[$((choice-1))]}"
URL="$BASE_URL/$SELECTED"

echo ""
echo "Running installer: $SELECTED"
echo "---------------------------------"
bash <(curl -fsSL "$URL")
