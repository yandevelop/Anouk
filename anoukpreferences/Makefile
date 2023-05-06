TARGET := iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AnoukPreferences

AnoukPreferences_FILES = $(wildcard *.m)
AnoukPreferences_FRAMEWORKS = UIKit
AnoukPreferences_PRIVATE_FRAMEWORKS = Preferences
AnoukPreferences_INSTALL_PATH = /Library/PreferenceBundles
AnoukPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
