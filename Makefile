SOURCE		:= xlight.s
TARGET		:= xlight

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
