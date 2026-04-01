TARGET := iphone:clang:latest:15.0

export ARCHS = arm64

THEOS_PACKAGE_SCHEME = rootless

export DEBUG=0
export FINALPACKAGE=1

export THEOS_DEVICE_IP=localhost
export THEOS_DEVICE_PORT=2222

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LepaoHelper

LepaoHelper_FILES = LepaoAntiCheat.xm
LepaoHelper_CFLAGS = -fobjc-arc
LepaoHelper_FRAMEWORKS = UIKit CoreLocation

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	chmod 644 $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/LepaoHelper.plist
