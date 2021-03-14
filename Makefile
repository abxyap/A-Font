TARGET = iphone:12.2:12.2
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AFont
AFont_FILES = Tweak.xm
AFont_PRIVATE_FRAMEWORKS = AppSupport

export STRCRY = 1
export INDIBRAN = 1
AFont_CFLAGS = -Xclang -load -Xclang /Library/Developer/HikariCore/libLLVMObfuscationHook.dylib

include $(THEOS_MAKE_PATH)/tweak.mk

# after-install::
# 	install.exec "killall -9 SpringBoard"
SUBPROJECTS += afontprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
