# TARGET = iphone:11.2:10.3
ARCHS = arm64 armv7
OS := $(shell uname)
ifeq ($(OS),Darwin)
  ARCHS += arm64e
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AFont
AFont_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += afontprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
