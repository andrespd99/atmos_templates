# Default variables (can be overridden by arguments)
PROJECT_ID ?= default_project_id
BASE_BUNDLE_ID ?= com.default.app
OUTPUT_DIR ?= .

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

ANDROID_GOOGLE_SERVICES_JSON_PATH := $(OUTPUT_DIR)/android/app/google-services.json
IOS_GOOGLE_SERVICES_PLIST_PATH := $(OUTPUT_DIR)/ios/Runner/GoogleService-Info.plist

IOS_CONFIG_DIR := $(OUTPUT_DIR)/ios/config
DEV_PLIST := $(IOS_CONFIG_DIR)/$(DEV_FLAVOR_NAME)/GoogleService-Info.plist
STG_PLIST := $(IOS_CONFIG_DIR)/$(STG_FLAVOR_NAME)/GoogleService-Info.plist
PROD_PLIST := $(IOS_CONFIG_DIR)/$(PROD_FLAVOR_NAME)/GoogleService-Info.plist

SETUP_SCRIPT := setup_config_files.rb
RENAME_SCRIPT := rename_firebase_options_classes.sh

# Default target
all: _setup_directories _configure_development _configure_staging _configure_production _link_to_xcode _class_renaming _post_cleanup

# Targets for each flavor
development: _setup_directories _configure_development _link_to_xcode _class_renaming _post_cleanup
	@echo "Firebase configured for development flavor ✅"

staging: _setup_directories _configure_staging _link_to_xcode _class_renaming _post_cleanup
	@echo "Firebase configured for staging flavor ✅"

production: _setup_directories _configure_production _link_to_xcode _class_renaming _post_cleanup
	@echo "Firebase configured for production flavor ✅"

# Create necessary directories
_setup_directories:
	mkdir -p $(IOS_CONFIG_DIR)/$(DEV_FLAVOR_NAME) $(IOS_CONFIG_DIR)/$(STG_FLAVOR_NAME) $(IOS_CONFIG_DIR)/$(PROD_FLAVOR_NAME)

_configure_development:
	@cd $(OUTPUT_DIR) && flutterfire configure --project=$(PROJECT_ID) --android-package-name=$(DEV_BUNDLE_ID) --ios-bundle-id=$(DEV_BUNDLE_ID) --platforms=ios,android --out=$(DEV_OUTPUT)
	mv $(IOS_GOOGLE_SERVICES_PLIST_PATH) $(DEV_PLIST)

_configure_staging:
	@cd $(OUTPUT_DIR) && flutterfire configure --project=$(PROJECT_ID) --android-package-name=$(STG_BUNDLE_ID) --ios-bundle-id=$(STG_BUNDLE_ID) --platforms=ios,android --out=$(STG_OUTPUT)
	mv $(IOS_GOOGLE_SERVICES_PLIST_PATH) $(STG_PLIST)

_configure_production:
	@cd $(OUTPUT_DIR) && flutterfire configure --project=$(PROJECT_ID) --android-package-name=$(PROD_BUNDLE_ID) --ios-bundle-id=$(PROD_BUNDLE_ID) --platforms=ios,android --out=$(PROD_OUTPUT)
	mv $(IOS_GOOGLE_SERVICES_PLIST_PATH) $(PROD_PLIST)

# Programmatically link config files to Xcode
_link_to_xcode:
	@echo "Updating Xcode indexes..."
	@if [ ! -f "$(SETUP_SCRIPT)" ]; then echo "Error: $(SETUP_SCRIPT) not found."; exit 1; fi
	ruby $(SETUP_SCRIPT) $(OUTPUT_DIR)

_class_renaming:
	@echo "Renaming DefaultFirebaseOptions classes..."
	@if [ ! -f "$(RENAME_SCRIPT)" ]; then echo "Error: $(RENAME_SCRIPT) not found."; exit 1; fi
	chmod +x $(RENAME_SCRIPT)
	./$(RENAME_SCRIPT) $(OUTPUT_DIR)/lib/firebase

_post_cleanup:
	@echo "Cleaning up project..."
	rm -f $(RENAME_SCRIPT) $(SETUP_SCRIPT) Makefile
	@echo "Firebase setup complete 🎉"

# Clean target (optional, to clear outputs)
clean:
	rm -f $(DEV_OUTPUT) $(STG_OUTPUT) $(PROD_OUTPUT)
	rm -rf $(IOS_CONFIG_DIR)/dev $(IOS_CONFIG_DIR)/stg $(IOS_CONFIG_DIR)/prod
	rm -f $(ANDROID_GOOGLE_SERVICES_JSON_PATH) $(IOS_GOOGLE_SERVICES_PLIST_PATH)

# Help target
help:
	@echo "Usage:"
	@echo "  make all PROJECT_ID=<project_id> BASE_BUNDLE_ID=<base_bundle_id> OUTPUT_DIR=<output_dir>   Run configuration for all flavors"
	@echo "  make development PROJECT_ID=<project_id> BASE_BUNDLE_ID=<base_bundle_id> OUTPUT_DIR=<output_dir>   Configure development flavor"
	@echo "  make staging PROJECT_ID=<project_id> BASE_BUNDLE_ID=<base_bundle_id> OUTPUT_DIR=<output_dir>   Configure staging flavor"
	@echo "  make production PROJECT_ID=<project_id> BASE_BUNDLE_ID=<base_bundle_id> OUTPUT_DIR=<output_dir>   Configure production flavor"
	@echo "  make clean      Remove all generated output files"