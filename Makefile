ASM := nasm
QEMU := qemu-system-i386
BUILD_DIR := build
BOOT_SRC := src/boot/boot.asm
IMAGE := $(BUILD_DIR)/sentinel.img

.PHONY: all run clean check smoke

all: $(IMAGE)

$(IMAGE): $(BOOT_SRC)
	mkdir -p $(BUILD_DIR)
	$(ASM) -f bin $< -o $@

check: $(IMAGE)
	test "$$(wc -c < $(IMAGE))" -eq 512
	printf '%s' "$$(tail -c 2 $(IMAGE) | od -An -tx1 | tr -d ' \n')" | grep -qi '^55aa$$'

run: $(IMAGE)
	$(QEMU) -drive format=raw,file=$(IMAGE) -boot c

smoke: $(IMAGE)
	timeout 5s $(QEMU) -drive format=raw,file=$(IMAGE) -boot c -display none; \
	code=$$?; \
	if [ "$$code" -eq 124 ]; then echo qemu_started_ok; else exit "$$code"; fi

clean:
	rm -rf $(BUILD_DIR)
