# 环境变量预设
THEOS ?= /opt/theos
THEOS_MAKE_PATH ?= $(THEOS)/makefiles

# 目标配置
export TARGET = iphone:clang:14.5:14.5
export ARCHS = arm64 arm64e
export FINALPACKAGE = 0

# 项目名称
TWEAK_NAME = SimpleSwitchPlugin

# 源文件（使用 Tab 缩进 ⇥）
SimpleSwitchPlugin_FILES = Tweak.xm \
	$(wildcard Hooks/*.xm) \
	$(wildcard Sources/*.m)

# 编译选项
SimpleSwitchPlugin_CFLAGS = -fobjc-arc -Wno-error -Wno-nonnull -Wno-deprecated-declarations -Wno-incompatible-pointer-types \
                    -I$(THEOS_PROJECT_DIR)/Sources \
                    -mios-version-min=14.5

# 框架依赖
SimpleSwitchPlugin_FRAMEWORKS = UIKit Foundation QuartzCore

# 加载构建规则
include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

