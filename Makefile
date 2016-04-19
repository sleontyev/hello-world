#///////////////////////////////////////////////////////////////////////////////
#                     Makefile
#///////////////////////////////////////////////////////////////////////////////
# Использование: make


# Set environment variables for the build.
SHELL = /bin/sh

#Средства компиляции и сборки (Variables Used by Implicit Rules)
CC := gcc
RM := rm -f
#CFLAGS :=

#Пути к директориям
PROG_NAME := hello-world
SRC_DIRS := $(shell ls src -F | grep / | tr -d /)
SRC_DIRS := src $(addprefix src/, $(SRC_DIRS))
INC_DIRS := include $(SRC_DIRS)
INC_DIRS_OPT := $(addprefix -I, $(INC_DIRS))
OBJ_DIR := dev/obj
BIN_DIR := dev/bin

INC_DIR_FILES := $(addsuffix /*.h, $(INC_DIRS))
INC_FILES := $(notdir $(wildcard $(INC_DIR_FILES)))

#Опции архитектуры процессора
#CPU= -march=5kf -mdouble-float -mgp64 -mhard-float -mabi=o64

#Для отладочной версии
#DEBUG_FLAGS= -O0 -g -G0
DEBUG_FLAGS= -O0 -g

#Для рабочей версии
#DEBUG_FLAGS= -O3

#Опции компилятора
#CC_OPTS = -MD -I $(INC_DIRS) -I $(REDBOOT)/include $(ENDIAN) $(CPU) $(DEBUG_FLAGS)
CC_OPTS = $(INC_DIRS_OPT) $(DEBUG_FLAGS)

#Опции компоновщика
#LNK_OPTS = -nostartfiles -T ram.ld -Wl,-Map=$(PROG_NAME).map -lm $(ENDIAN) -g -nostdlib

#c-файлы
SRC_DIR_FILES := $(addsuffix /*.c, $(SRC_DIRS))
SRC_FILES := $(notdir $(wildcard $(SRC_DIR_FILES)))
OBJ_FILES := $(patsubst %.c, %.o, $(SRC_FILES))
MAKE_FILES := $(patsubst %.c, %.d, $(SRC_FILES))
#$(info $(OBJ_FILES)) #printf


OBJ_FILES := $(addprefix $(OBJ_DIR)/, $(OBJ_FILES))
MAKE_FILES := $(addprefix $(OBJ_DIR)/, $(MAKE_FILES))
PROG_NAME := $(addprefix $(BIN_DIR)/, $(PROG_NAME))

#Абстрактные цели
.PHONY: all clean prog1
.PHONY: cleanall cleanobj cleanmap

#Главные цели (Default target executed when no arguments are given to make)
all: prog1

prog1: $(MAKE_FILES) $(OBJ_FILES)
	$(CC) -o $(PROG_NAME) $(OBJ_FILES)
	@echo $(PROG_NAME) finished

# bin/obj/main.o: src/application/main.c include/my_type.h

#VPATH включает пути к исходным(*.c) и заголовочным(*.h) файлам
VPATH := $(SRC_DIRS) include

#Зависимости объектных файлов обновляются при изменении любого *.h файла
$(MAKE_FILES): $(INC_FILES)
$(OBJ_DIR)/%.d: %.c
	@set -e; rm -f $@; \
	$(CC) $(INC_DIRS_OPT) -MM $< > $@.$$$$; \
	echo -n $(OBJ_DIR)/ > $@; \
	cat $@.$$$$ >> $@; \
	rm -f $@.$$$$

#Включение зависимостей объектных файлов(*.o) от исходных(*.c) и заголовочных(*.h)
include $(wildcard $(OBJ_DIR)/*.d)

$(OBJ_DIR)/%.o: %.c
	$(CC) -c $(CC_OPTS) $< -o $@
#%.o: %.S
#	$(CC) -c $(CC_OPTS) $< -o $@

#При изменении любого *.h файла производит пересборку всего проекта
#(не используется, т.к. есть MAKE_FILES)
#$(OBJ_FILES): $(INC_FILES)

clean:
	$(RM) $(OBJ_DIR)/*.d
	$(RM) $(OBJ_DIR)/*.o
#	$(RM) $(BIN_DIR)/*.map
	$(RM) $(PROG_NAME)

# Help Target
help:
	@echo The following are some of the valid targets for this Makefile:
	@echo ... all (the default if no target is provided)
	@echo ... prog1
	@echo ... clean
.PHONY : help

#-------------------------
##End of makefile
#-------------------------

#-------------------------
#Standard target names
#all: //Make all the top-level targets the makefile knows about.
#clean: //Delete all files that are normally created by running make.
#mostlyclean: //Like ‘clean’, but may refrain from deleting a few files that people normally don’t want to recompile. For example, the ‘mostlyclean’ target for GCC does not delete libgcc.a, because recompiling it is rarely necessary and takes a lot of time.
#install: //Copy the executable file into a directory that users typically search for commands; copy any auxiliary files that the executable uses into the directories where it will look for them.
#print: //Print listings of the source files that have changed.
#tar: //Create a tar file of the source files.
#-------------------------
