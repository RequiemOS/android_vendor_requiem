# Allow vendor/extra to override any property by setting it first
$(call inherit-product-if-exists, vendor/extra/product.mk)

PRODUCT_BRAND ?= RequiemOS

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

ifeq ($(TARGET_BUILD_VARIANT),eng)
# Disable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=0
else
# Enable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/requiem/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/requiem/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/requiem/prebuilt/common/bin/50-requiem.sh:$(TARGET_COPY_OUT_SYSTEM)/addon.d/50-requiem.sh

ifneq ($(AB_OTA_PARTITIONS),)
PRODUCT_COPY_FILES += \
    vendor/requiem/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/requiem/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/requiem/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.ota.allow_downgrade=true
endif
endif

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/requiem/config/permissions/backup.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/backup.xml

# requiem-specific broadcast actions whitelist
PRODUCT_COPY_FILES += \
    vendor/requiem/config/permissions/requiem-sysconfig.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/requiem-sysconfig.xml

# Copy all requiem-specific init rc files
$(foreach f,$(wildcard vendor/requiem/prebuilt/common/etc/init/*.rc),\
	$(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM)/etc/init/$(notdir $f)))

# Copy over added mimetype supported in libcore.net.MimeUtils
PRODUCT_COPY_FILES += \
    vendor/requiem/prebuilt/common/lib/content-types.properties:$(TARGET_COPY_OUT_SYSTEM)/lib/content-types.properties

# Enable Android Beam on all targets
PRODUCT_COPY_FILES += \
    vendor/requiem/config/permissions/android.software.nfc.beam.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.software.nfc.beam.xml

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_0719.kl

# This is requiem!
PRODUCT_COPY_FILES += \
    vendor/requiem/config/permissions/org.requiemos.android.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/org.requiemos.android.xml

# Enforce privapp-permissions whitelist
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.control_privapp_permissions=enforce

# Include AOSP audio files
include vendor/requiem/config/aosp_audio.mk

# Include requiem audio files
include vendor/requiem/config/requiem_audio.mk

ifneq ($(TARGET_DISABLE_REQUIEM_SDK), true)
# requiem SDK
include vendor/requiem/config/requiem_sdk_common.mk
endif

# TWRP
ifeq ($(WITH_TWRP),true)
include vendor/requiem/config/twrp.mk
endif

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

# Bootanimation
PRODUCT_PACKAGES += \
    bootanimation.zip

# AOSP packages
PRODUCT_PACKAGES += \
    Terminal

# requiem packages
PRODUCT_PACKAGES += \
    requiemParts \
    requiemSettingsProvider \
    requiemSetupWizard \
    Updater

# Themes
PRODUCT_PACKAGES += \
    requiemThemesStub \
    ThemePicker

# Extra tools in requiem
PRODUCT_PACKAGES += \
    7z \
    awk \
    bash \
    bzip2 \
    curl \
    getcap \
    htop \
    lib7z \
    libsepol \
    nano \
    pigz \
    powertop \
    setcap \
    unrar \
    unzip \
    vim \
    wget \
    zip

# Filesystems tools
PRODUCT_PACKAGES += \
    fsck.exfat \
    fsck.ntfs \
    mke2fs \
    mkfs.exfat \
    mkfs.ntfs \
    mount.ntfs

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Storage manager
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.storage_manager.enabled=true

# These packages are excluded from user builds
PRODUCT_PACKAGES_DEBUG += \
    procmem

# Root
PRODUCT_PACKAGES += \
    adb_root
ifneq ($(TARGET_BUILD_VARIANT),user)
ifeq ($(WITH_SU),true)
PRODUCT_PACKAGES += \
    su
endif
endif

# Dex preopt
PRODUCT_DEXPREOPT_SPEED_APPS += \
    SystemUI \
    TrebuchetQuickStep

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/requiem/overlay
DEVICE_PACKAGE_OVERLAYS += vendor/requiem/overlay/common

PRODUCT_VERSION_MAJOR = 18
PRODUCT_VERSION_MINOR = 0
PRODUCT_VERSION_MAINTENANCE := 0

ifeq ($(TARGET_VENDOR_SHOW_MAINTENANCE_VERSION),true)
    REQUIEM_VERSION_MAINTENANCE := $(PRODUCT_VERSION_MAINTENANCE)
else
    REQUIEM_VERSION_MAINTENANCE := 0
endif

# Set REQUIEM_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef REQUIEM_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "REQUIEM_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^REQUIEM_||g')
        REQUIEM_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(REQUIEM_BUILDTYPE)),)
    REQUIEM_BUILDTYPE :=
endif

ifdef REQUIEM_BUILDTYPE
    ifneq ($(REQUIEM_BUILDTYPE), SNAPSHOT)
        ifdef REQUIEM_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            REQUIEM_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from REQUIEM_EXTRAVERSION
            REQUIEM_EXTRAVERSION := $(shell echo $(REQUIEM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to REQUIEM_EXTRAVERSION
            REQUIEM_EXTRAVERSION := -$(REQUIEM_EXTRAVERSION)
        endif
    else
        ifndef REQUIEM_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            REQUIEM_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from REQUIEM_EXTRAVERSION
            REQUIEM_EXTRAVERSION := $(shell echo $(REQUIEM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to REQUIEM_EXTRAVERSION
            REQUIEM_EXTRAVERSION := -$(REQUIEM_EXTRAVERSION)
        endif
    endif
else
    # If REQUIEM_BUILDTYPE is not defined, set to UNOFFICIAL
    REQUIEM_BUILDTYPE := UNOFFICIAL
    REQUIEM_EXTRAVERSION :=
endif

ifeq ($(REQUIEM_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        REQUIEM_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

ifeq ($(REQUIEM_BUILDTYPE), RELEASE)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        REQUIEM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(REQUIEM_BUILD)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            ifeq ($(REQUIEM_VERSION_MAINTENANCE),0)
                REQUIEM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(REQUIEM_BUILD)
            else
                REQUIEM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(REQUIEM_VERSION_MAINTENANCE)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(REQUIEM_BUILD)
            endif
        else
            REQUIEM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(REQUIEM_BUILD)
        endif
    endif
else
    ifeq ($(REQUIEM_VERSION_MAINTENANCE),0)
        ifeq ($(REQUIEM_VERSION_APPEND_TIME_OF_DAY),true)
            REQUIEM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d_%H%M%S)-$(REQUIEM_BUILDTYPE)$(REQUIEM_EXTRAVERSION)-$(REQUIEM_BUILD)
        else
            REQUIEM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(REQUIEM_BUILDTYPE)$(REQUIEM_EXTRAVERSION)-$(REQUIEM_BUILD)
        endif
    else
        ifeq ($(REQUIEM_VERSION_APPEND_TIME_OF_DAY),true)
            REQUIEM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(REQUIEM_VERSION_MAINTENANCE)-$(shell date -u +%Y%m%d_%H%M%S)-$(REQUIEM_BUILDTYPE)$(REQUIEM_EXTRAVERSION)-$(REQUIEM_BUILD)
        else
            REQUIEM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(REQUIEM_VERSION_MAINTENANCE)-$(shell date -u +%Y%m%d)-$(REQUIEM_BUILDTYPE)$(REQUIEM_EXTRAVERSION)-$(REQUIEM_BUILD)
        endif
    endif
endif

PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/requiem/build/target/product/security/requiem

-include vendor/requiem-priv/keys/keys.mk

REQUIEM_DISPLAY_VERSION := $(REQUIEM_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
    ifneq ($(REQUIEM_BUILDTYPE), UNOFFICIAL)
        ifndef TARGET_VENDOR_RELEASE_BUILD_ID
            ifneq ($(REQUIEM_EXTRAVERSION),)
                # Remove leading dash from REQUIEM_EXTRAVERSION
                REQUIEM_EXTRAVERSION := $(shell echo $(REQUIEM_EXTRAVERSION) | sed 's/-//')
                TARGET_VENDOR_RELEASE_BUILD_ID := $(REQUIEM_EXTRAVERSION)
            else
                TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d)
            endif
        else
            TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
        endif
        ifeq ($(REQUIEM_VERSION_MAINTENANCE),0)
            REQUIEM_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(REQUIEM_BUILD)
        else
            REQUIEM_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(REQUIEM_VERSION_MAINTENANCE)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(REQUIEM_BUILD)
        endif
    endif
endif
endif

-include $(WORKSPACE)/build_env/image-auto-bits.mk
-include vendor/requiem/config/partner_gms.mk
