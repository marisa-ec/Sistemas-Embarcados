
# Toolchain/library path. LIB_PATH is an exported environmental variable which
# shall point to the installation of toolchain
#
LIB_GCC=${LIB_PATH}/usr/lib/gcc/arm-none-eabi/4.8/
LIB_C=${LIB_PATH}/usr/lib/arm-none-eabi/lib
SYSCONFIG_BIN=lib

#
# Target and Compiler definitions (Device and EVM specified by makefile)
#
TARGET=armv7a
COMPILER=gcc

#
# Device and EVM definitions
#
DEVICE=am335x

#
# The application directory and name
#
APPNAME=gpioMarisa
SRC=src

#
# Include paths
#
IPATH=-Iinc \
      -Iinc/hw \
      -Iinc/${TARGET}\
      -Iinc/${TARGET}/${DEVICE}

#
# Library paths
#
LPATH=-L"${LIB_C}" \
      -L"${LIB_GCC}" \
      -L${SYSCONFIG_BIN}/${TARGET_MODE}
 
#
# C compilation options
#
Debug_FLAG=-g
Release_FLAG=-g -O2
ifdef DEVICE
DEVICE_D=-D${DEVICE}
endif


CFLAGS=-mcpu=cortex-a8 -mtune=cortex-a8 -march=armv7-a
CFLAGS+=-c ${${TARGET_MODE}_FLAG} -mlong-calls -fdata-sections -funsigned-char \
            -ffunction-sections -Wall ${IPATH} -Dgcc

#
# Defining the cross compiler tool prefix
#
ifndef PREFIX
PREFIX=arm-none-eabi-
endif

#
# Compiler, Linker and Archiver with respect to the toolchain
#
CC=${PREFIX}gcc
LD=${PREFIX}ld
AR=${PREFIX}ar
BIN=$(PREFIX)objcopy

#
# Archiver options
#
ARFLAGS=-c -r

#
# Linker options
#
LDFLAGS=-e Entry -u Entry -u __aeabi_uidiv -u __aeabi_idiv --gc-sections

#
# Binary options
#
BINFLAGS=-O binary

#
# Where the application will be loaded to. This is required to generate
# image with Header (Load Address and Size)
#
IMG_LOAD_ADDR = 0x80000000

#
# Application Location
#
APP=${SRC}
APP_BIN=binary$(APPDIR)

#
# Application source files
#
APP_SRC=$(APP)/*.c

#
# Required library files
#
APP_LIB= -lsystem_config


#
# Rules for building the application and library
#
all: debug release

debug:
	make TARGET_MODE=Debug bin

release:
	make TARGET_MODE=Release bin

bin:
	$(CC)  $(CFLAGS) $(APP_SRC)
	@mkdir -p $(TARGET_MODE)
	@mv *.o* $(TARGET_MODE)
	$(LD) ${LDFLAGS} ${LPATH} -o $(TARGET_MODE)/$(APPNAME).out \
          -Map $(TARGET_MODE)/$(APPNAME).map $(TARGET_MODE)/*.o* \
          $(APP_LIB) -lc -lgcc $(APP_LIB) $(RUNTIMELIB) -T ${SRC}/$(APPNAME).lds
	@mkdir -p $(APP_BIN)/$(TARGET_MODE)
	@cp $(TARGET_MODE)/$(APPNAME).out $(APP_BIN)/$(TARGET_MODE)/$(APPNAME).out
	$(BIN) $(BINFLAGS) $(APP_BIN)/$(TARGET_MODE)/$(APPNAME).out \
               $(APP_BIN)/$(TARGET_MODE)/$(APPNAME).bin 

#
# Rules for cleaning
#
clean:
	@rm -rf Debug Release $(APP_BIN)/Debug $(APP_BIN)/Release


