# Inherit common Lineage stuff
$(call inherit-product, vendor/requiem/config/common.mk)

# Inherit Lineage atv device tree
$(call inherit-product, device/requiem/atv/requiem_atv.mk)

# AOSP packages
PRODUCT_PACKAGES += \
    LeanbackIME

# Lineage packages
PRODUCT_PACKAGES += \
    AppDrawer \
    LineageCustomizer

DEVICE_PACKAGE_OVERLAYS += vendor/requiem/overlay/tv
