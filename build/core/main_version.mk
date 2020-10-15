# Build fingerprint
ifneq ($(BUILD_FINGERPRINT),)
ADDITIONAL_BUILD_PROPERTIES += \
    ro.build.fingerprint=$(BUILD_FINGERPRINT)
endif

# requiemOS System Version
ADDITIONAL_BUILD_PROPERTIES += \
    ro.requiem.version=$(REQUIEM_VERSION) \
    ro.requiem.releasetype=$(REQUIEM_BUILDTYPE) \
    ro.requiem.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.modversion=$(REQUIEM_VERSION) \
    ro.requiemlegal.url=https://requiem-os.com/legal

# requiemOS Platform Display Version
ADDITIONAL_BUILD_PROPERTIES += \
    ro.requiem.display.version=$(REQUIEM_DISPLAY_VERSION)