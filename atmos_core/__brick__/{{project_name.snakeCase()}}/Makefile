# Default variables (can be overridden by arguments)
PROJECT_ID ?= default_project_id
BASE_BUNDLE_ID ?= com.default.app

DEV_FLAVOR_NAME=development
STG_FLAVOR_NAME=staging
PROD_FLAVOR_NAME=production

# Derived variables
DEV_BUNDLE_ID := $(BASE_BUNDLE_ID).dev
STG_BUNDLE_ID := $(BASE_BUNDLE_ID).stg
PROD_BUNDLE_ID := $(BASE_BUNDLE_ID)

DEV_OUTPUT := lib/firebase/$(DEV_FLAVOR_NAME)_firebase_options.dart
STG_OUTPUT := lib/firebase/$(STG_FLAVOR_NAME)_firebase_options.dart
PROD_OUTPUT := lib/firebase/$(PROD_FLAVOR_NAME)_firebase_options.dart

ANDROID_GOOGLE_SERVICES_JSON_PATH := android/app/google-services.json
IOS_GOOGLE_SERVICES_PLIST_PATH := ios/Runner/GoogleService-Info.plist

IOS_CONFIG_DIR := ios/config
DEV_PLIST := $(IOS_CONFIG_DIR)/$(DEV_FLAVOR_NAME)/GoogleService-Info.plist
STG_PLIST := $(IOS_CONFIG_DIR)/$(STG_FLAVOR_NAME)/GoogleService-Info.plist
PROD_PLIST := $(IOS_CONFIG_DIR)/$(PROD_FLAVOR_NAME)/GoogleService-Info.plist

# Default target
all: setup_directories development staging production link_to_xcode

# Create necessary directories
setup_directories:
	mkdir -p $(IOS_CONFIG_DIR)/$(DEV_FLAVOR_NAME) $(IOS_CONFIG_DIR)/$(STG_FLAVOR_NAME) $(IOS_CONFIG_DIR)/$(PROD_FLAVOR_NAME)

# Targets for each flavor
development:
	flutterfire configure --project=$(PROJECT_ID) --android-package-name=$(DEV_BUNDLE_ID) --ios-bundle-id=$(DEV_BUNDLE_ID) --platforms=ios,android --out=$(DEV_OUTPUT)
	mv $(IOS_GOOGLE_SERVICES_PLIST_PATH) $(DEV_PLIST)

staging:
	flutterfire configure --project=$(PROJECT_ID) --android-package-name=$(STG_BUNDLE_ID) --ios-bundle-id=$(STG_BUNDLE_ID) --platforms=ios,android --out=$(STG_OUTPUT)
	mv $(IOS_GOOGLE_SERVICES_PLIST_PATH) $(STG_PLIST)

production:
	flutterfire configure --project=$(PROJECT_ID) --android-package-name=$(PROD_BUNDLE_ID) --ios-bundle-id=$(PROD_BUNDLE_ID) --platforms=ios,android --out=$(PROD_OUTPUT)
	mv $(IOS_GOOGLE_SERVICES_PLIST_PATH) $(PROD_PLIST)

# Programmatically link config files to Xcode
link_to_xcode:
	@echo "Updating XCode indexes..."
	ruby setup_config_files.rb
	@echo "Project index updated."

# Clean target (optional, to clear outputs)
clean:
	rm -f $(DEV_OUTPUT) $(STG_OUTPUT) $(PROD_OUTPUT)
	rm -rf $(IOS_CONFIG_DIR)/dev $(IOS_CONFIG_DIR)/stg $(IOS_CONFIG_DIR)/prod
	rm -f $(ANDROID_GOOGLE_SERVICES_JSON_PATH) $(IOS_GOOGLE_SERVICES_PLIST_PATH)

# Help target
help:
	@echo "Usage:"
	@echo "  make all PROJECT_ID=<project_id> BASE_BUNDLE_ID=<base_bundle_id>   Run configuration for all flavors"
	@echo "  make development PROJECT_ID=<project_id> BASE_BUNDLE_ID=<base_bundle_id>   Configure development flavor"
	@echo "  make staging PROJECT_ID=<project_id> BASE_BUNDLE_ID=<base_bundle_id>   Configure staging flavor"
	@echo "  make production PROJECT_ID=<project_id> BASE_BUNDLE_ID=<base_bundle_id>   Configure production flavor"
	@echo "  make clean      Remove all generated output files"