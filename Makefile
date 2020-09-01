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

all: clean build man

# ---------------------------------------------------------
#							BUILD
# ---------------------------------------------------------
build:
# auto-config
	@sed -i '/max-brightness/a MAX_VALUE equ $(MAXVALUE)' $(SOURCE)
	@sed -i '/brightness-file/a file db "$(BRIGHTNESSFILE)",0' $(SOURCE)

# build
	nasm $(SOURCE) -o $(TARGET).o -f elf64
	ld.lld $(TARGET).o -o $(TARGET)

	@strip --strip-unneeded $(TARGET)

# ---------------------------------------------------------
#							MAN
# ---------------------------------------------------------
man:
# generate man-page with specific values
	@echo ".TH xlight 1" > $(MAN)
	@echo ".SH NAME" >> $(MAN)
	@echo "xlight \- extremely lightweight and simple brightness control" >> $(MAN)
	@echo ".SH SYNOPSIS" >> $(MAN)
	@echo ".sp" >> $(MAN)
	@echo "\fIxlight\fR" >> $(MAN)
	@echo "[\fB\+-[0\-$(MAXVALUE)]\fR]" >> $(MAN)
	@echo ".SH DESCRIPTION" >> $(MAN)
	@echo ".B xlight" >> $(MAN)
	@echo "controls your brightness by directly manipulating the brightness value between 0 and $(MAXVALUE) \
	in the brightness file. The brightness value is calculated by adding the given offset \
	to the current value and applying the changes." >> $(MAN)
	@echo ".SH OPTIONS" >> $(MAN)
	@echo ".TP" >> $(MAN)
	@echo ".BR \+[0\-$(MAXVALUE)]" >> $(MAN)
	@echo "Increases the brightness value by the given offset." >> $(MAN)
	@echo "Should the value drop below 0, it will be set to 0." >> $(MAN)
	@echo ".TP" >> $(MAN)
	@echo ".BR \-[0\-$(MAXVALUE)]" >> $(MAN)
	@echo "Decreases the brightness value by the given offset." >> $(MAN)
	@echo "Should the value be greater then the maximum, it will be set to $(MAXVALUE)." >> $(MAN)
	@echo ".SH BRIGHTNESS FILE" >> $(MAN)
	@echo "xlight will apply all changes to this file. If it is NOT the correct file, manually change \
	the value \fBBRIGHTNESSFILE\fR and \fBMAXVALUE\fR in the Makefile." >> $(MAN)
	@echo ".sp" >> $(MAN)
	@echo "$(BRIGHTNESSFILE)" >> $(MAN)


# ---------------------------------------------------------
#							CLEAN
# ---------------------------------------------------------
clean:
# clean source-file
	@sed -i '/MAX_VALUE equ/d' $(SOURCE)
	@sed -i '/file db/d' $(SOURCE)

# remove old files
	rm -f *.o $(TARGET)

#remove man page
	rm -f $(MAN)


# ---------------------------------------------------------
#							INSTALL
# ---------------------------------------------------------
install: install-bin install-man

install-bin:
	$(INSTALL) $(INSTALL_ARGS) $(TARGET) $(PREFIX)$(INSTALL_DIR)

install-man:
	mkdir -p $(PREFIX)$(MAN_DIR)
	cp $(MAN) $(PREFIX)$(MAN_DIR)

# ---------------------------------------------------------
#							UNINSTALL
# ---------------------------------------------------------
uninstall: clean uninstall-bin uninstall-man

uninstall-bin:
	rm -f $(PREFIX)$(INSTALL_DIR)$(TARGET)

uninstall-man:
	rm -f $(PREFIX)$(MAN_DIR)$(MAN)
