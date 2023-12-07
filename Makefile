TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = MobileSlideShow tccd SpringBoard
ARCHS = arm64 arm64e
FINALPACKAGE = 1
PACKAGE_VERSION = 1.2

THEOS_PACKAGE_SCHEME = rootless

THEOS_DEVICE_IP = 192.168.178.20

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Anouk

Anouk_FILES = Tweak.x
Anouk_CFLAGS = -fobjc-arc
Anouk_FRAMEWORKS = UIKit LocalAuthentication

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += anoukpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
