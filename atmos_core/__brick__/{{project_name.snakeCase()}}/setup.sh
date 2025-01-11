#!/bin/bash

set -e  # Stop execution on error

echo "🚀 Starting Avila Tek app setup..."

# Step 0: Check if Dart and Flutter are installed
if ! command -v dart &> /dev/null; then
    echo "⚠️  Dart is not installed."
    read -p "Do you want to install it? [y/N]: " install_dart
    if [[ "$install_dart" == "y" || "$install_dart" == "Y" ]]; then
        echo "Installing Dart..."
        brew install dart
    else
        echo "Dart installation canceled. Exiting..."
        exit 1
    fi
fi

# Step 1: Check if Mason is installed
if ! command -v mason &> /dev/null; then
    echo "⚠️  Mason is not installed."
    read -p "Do you want to install it? [y/N]: " install_mason
    if [[ "$install_mason" == "y" || "$install_mason" == "Y" ]]; then
        echo "Installing Mason CLI..."
        dart pub global activate mason_cli
    else
        echo "Mason installation canceled. Exiting..."
        exit 1
    fi
fi


# Step 2: Check if FVM is installed and use the latest Flutter version
if ! command -v fvm &> /dev/null; then
    echo "⚠️  FVM (Flutter Version Manager) is not installed."
    read -p "Do you want to install it? [y/N]: " install_fvm
    if [[ "$install_fvm" == "y" || "$install_fvm" == "Y" ]]; then
        echo "💾 Installing FVM via Homebrew..."
        brew tap leoafarias/fvm
        brew install fvm
    else
        echo "FVM installation canceled. Exiting..."
        exit 1
    fi
fi

# Get the latest stable Flutter version from the internet
echo "Fetching the latest Flutter stable version..."
latest_flutter_version=$(curl -s https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json | jq -r '.releases[] | select(.channel == "stable") | .version' | head -n 1)

if [[ -z "$latest_flutter_version" ]]; then
    echo "Failed to fetch the latest Flutter version. Please check your internet connection."
    exit 1
fi

echo "Switching to Flutter $latest_flutter_version using FVM. You may be prompted to install it, but you can skip it and do it later by running 'fvm use' in the command-line"
sleep 2
fvm use "$latest_flutter_version"

# Step 3: Run Mason commands

# Run `mason get`
echo "Running 'mason get'"
mason get

# Run `mason make` for every brick
echo
echo "🧱 Generating templates with Mason..."
sleep 2

# Extract the project name from the README.md heading
if [[ -f "README.md" ]]; then
    project_name=$(grep -m 1 "^# " README.md | sed 's/^# //')
    if [[ -z "$project_name" ]]; then
        echo "Tried to deduce app name from README.md file but found no valid heading in README.md. Using 'Avila Tek App' as README title."
        project_name="Avila Tek App"
    fi
else
    echo "README.md not found. Using 'Avila Tek App' as README title."
    project_name="Avila Tek App"
fi

 # Extract the bundle_id from the android/app/build.gradle file
bundle_id=$(grep -m 1 "applicationId " android/app/build.gradle | awk '{print $2}' | tr -d '"')
if [[ -z "$bundle_id" ]]; then
    echo "Failed to extract bundle_id. Please check your build.gradle file."
    exit 1
fi

echo
echo "Creating README file"
mason make avilatek_readme --on-conflict overwrite --project_name "$project_name" --uses_fvm true --uses_go_router true --uses_codemagic true

echo
echo "Creating codemagic.yaml"
mason make avilatek_codemagic --on-conflict prompt --flutter_version "$latest_flutter_version" --bundle_identifier "$bundle_id" --path_to_main_files lib/

echo
echo "Creating app routes with go_router"
mason make avilatek_go_router --on-conflict overwrite -o lib/src/

echo
echo "Creating app theme files"
mason make avilatek_variables_template --on-conflict prompt -o lib/core/

# Step 3: Configure Firebase (optional)
project_id=""
show_firebase_config_tip="false"

echo
read -p "Do you want to configure Firebase for this app? [y/N]: " configure_firebase
if [[ "$configure_firebase" == "y" || "$configure_firebase" == "Y" ]]; then
    while true; do
        firebase projects:list
        read -p "Please enter the Firebase project ID: " project_id
        if [[ -z "$project_id" ]]; then
            read -p "Project ID is empty. Do you want to skip this step? [y/N]: " skip_step
            if [[ "$skip_step" == "y" || "$skip_step" == "Y" ]]; then
                echo "Skipping Firebase configuration..."
                break
            fi
        else
            # Run commands to configure Firebase
            echo "Configuring Firebase..."
            make all PROJECT_ID="$project_id" BASE_BUNDLE_ID="$bundle_id"
            ruby setup_config_files.rb
            show_firebase_config_tip="true"
            break
        fi
    done
fi

echo "Installing dependencies"
flutter pub add firebase_core go_router 
flutter pub get

echo "Running 'dart fix --apply'"
output=$(dart fix --apply)

# Step 4: Clean up temporary files
echo "Cleaning up temporary files..."
rm -f setup.sh Makefile setup_config_files.rb

# Step 5: Final message
echo "🎉✨ App setup completed successfully. You are ready to start developing!"
sleep 2

echo
echo "💡 Next steps recommended:"
echo "  - Update theme variables"
if [[ show_firebase_config_tip == "true" ]]; then
    echo "- Setup service accounts for Firebase App Distribution and Google Play Console at https://console.cloud.google.com/iam-admin/serviceaccounts?project=$project_id"
fi
echo "  - Create and setup project at https://codemagic.io/apps"
echo "  - Register app in stores at https://appstoreconnect.apple.com/apps and https://play.google.com/console"
echo "  - Create beta tester groups in Test Flight and Firebase App Distribution"
sleep 1