VERSION = v01-03

CWD := $(shell pwd)
IMAGE_DIR = $(CWD)

MLPP = PBB.upgradeSoftwareModule-$(VERSION).mlpp
TARGZ_FILE = PBB-Software.tar.gz

SW_FILES = pxelinux.cfg/default bootloader vmlinuz initramfs image.squashfs

GEN_FILES = Slot1/initramfs Slot1/image.squashfs $(MLPP)

all: $(MLPP)

$(MLPP): $(TARGZ_FILE)
	./mk_pbb_sw_upgrade.py $(VERSION) $(TARGZ_FILE)

$(TARGZ_FILE): $(SW_FILES:%=Slot1/%)
	cd Slot1 && tar czf ../$(TARGZ_FILE) $(SW_FILES)

Slot1/initramfs:
	cd $(IMAGE_DIR)/initramfs && find . | cpio -H newc -o | gzip - > $(CWD)/Slot1/initramfs

Slot1/image.squashfs:
	sudo mksquashfs $(IMAGE_DIR)/linuxrootdir Slot1/image.squashfs -ef exclude-list

clean:
	$(RM) $(GEN_FILES) $(TARGZ_FILE) $(MLPP)
