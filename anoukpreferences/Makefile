TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AnoukPreferences

AnoukPreferences_FILES = $(wildcard *.m)
AnoukPreferences_FRAMEWORKS = UIKit
AnoukPreferences_PRIVATE_FRAMEWORKS = Preferences
AnoukPreferences_INSTALL_PATH = /Library/PreferenceBundles
AnoukPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME).plist$(ECHO_END)
