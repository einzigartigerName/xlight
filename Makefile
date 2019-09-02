SOURCE			:= xlight.s
MAN				:= xlight.1
TARGET			:= xlight
INSTALL			:= install
INSTALL_ARGS	:= -o root -g root -m 4755
PREFIX			:= /usr/local/
INSTALL_DIR		:= bin/
MAN_DIR			:= man/man1/

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

	@strip --strip-unneeded $(TARGET)

clean:
# clean source-file
	@sed -i '/MAX_VALUE equ/d' $(SOURCE)
	@sed -i '/file db/d' $(SOURCE)

# remove old files
	rm -f *.o xlight

install:
# install binary
	$(INSTALL) $(INSTALL_ARGS) $(TARGET) $(PREFIX)$(INSTALL_DIR)
# install man-page
	mkdir -p $(PREFIX)$(MAN_DIR)
	cp $(MAN) $(PREFIX)$(MAN_DIR)

uninstall: clean
	rm -f $(PREFIX)$(INSTALL_DIR)$(TARGET)
	rm -f $(PREFIX)$(MAN_DIR)$(MAN)
