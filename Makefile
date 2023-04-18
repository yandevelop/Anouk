TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = MobileSlideShow tccd
ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless
FINALPACKAGE = 1
PACKAGE_VERSION = 1.0.1

THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

export SYSROOT = $(THEOS)/sdks/iPhoneOS15.5.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Anouk

Anouk_FILES = Tweak.x
Anouk_CFLAGS = -fobjc-arc
Anouk_FRAMEWORKS = UIKit LocalAuthentication

include $(THEOS_MAKE_PATH)/tweak.mk
