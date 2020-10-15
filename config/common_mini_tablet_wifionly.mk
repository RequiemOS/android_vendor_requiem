# Inherit mini common Requiem stuff
$(call inherit-product, vendor/requiem/config/common_mini.mk)

# Required packages
PRODUCT_PACKAGES += \
    LatinIME
