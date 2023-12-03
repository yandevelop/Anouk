TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = MobileSlideShow tccd
ARCHS = arm64 arm64e
FINALPACKAGE = 1
PACKAGE_VERSION = 1.2

include $(THEOS)/makefiles/common.mk

THEOS_PACKAGE_SCHEME = rootless

TWEAK_NAME = Anouk

Anouk_FILES = Tweak.x
Anouk_CFLAGS = -fobjc-arc
Anouk_FRAMEWORKS = UIKit LocalAuthentication

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += anoukpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
