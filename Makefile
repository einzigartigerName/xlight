SOURCE			:= xlight.s
TARGET			:= xlight
INSTALL			:= install
INSTALL_ARGS	:= -o root -g root -m 4755
INSTALL_DIR		:= /usr/local/bin/

BRIGHTNESSFILE = $(shell find /sys/class/backlight/*/brightness | head -1)
MAXVALUE = $(shell find /sys/class/backlight/*/max_brightness | head -1 | xargs cat)

all: clean build

build:
# auto-config
	@sed -i '/max-brightness/a MAX_VALUE equ $(MAXVALUE)' $(SOURCE)
	@sed -i '/brightness-file/a file db "$(BRIGHTNESSFILE)",0' $(SOURCE)

# build
	nasm $(SOURCE) -o $(TARGET).o -f elf64
	ld $(TARGET).o -o $(TARGET)

clean:
# clean source-file
	@sed -i '/MAX_VALUE equ/d' $(SOURCE)
	@sed -i '/file db/d' $(SOURCE)

# remove old files
	rm -f *.o xlight

install:
	$(INSTALL) $(INSTALL_ARGS) $(TARGET) $(INSTALL_DIR)

uninstall: clean
	rm -f $(INSTALL_DIR)$(TARGET)
