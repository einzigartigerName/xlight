SOURCE		:= xlight.s
TARGET		:= xlight

all: clean build

build:
	nasm $(SOURCE) -o $(TARGET).o -f elf64
	ld $(TARGET).o -o $(TARGET)

clean:
	rm -f *.o xlight