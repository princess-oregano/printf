SRCDIR := src
OBJDIR := obj

SRC_C := main.c 
SRC_S := print.s
OBJ_C := $(addprefix $(OBJDIR)/, $(SRC:.c=.o))
OBJ_S := $(addprefix $(OBJDIR)/, $(SRC:.s=.o))
TARGET := out

ASM := nasm
ASMFLAGS := -g -f elf64
CC := gcc
CFLAGS := -g -no-pie

.SILENT:
all: out run

run:
	printf "%s\n" "Running..."
	./$(TARGET)
	printf "%s\n" "Finished."

out: $(OBJDIR) $(OBJDIR)/$(SRC_C:.c=.o) $(OBJDIR)/$(SRC_S:.s=.o)
	printf "%s\n" "Linking..."
	$(CC) $(CFLAGS) $(OBJDIR)/$(SRC_C:.c=.o) $(OBJDIR)/$(SRC_S:.s=.o) -o $(TARGET) 

$(OBJDIR)/$(SRC_C:.c=.o): $(SRCDIR)/$(SRC_C)
	printf "%s\n" "Compiling $@..."
	$(CC) $(CFLAGS) -c $^ -o  $@

$(OBJDIR)/$(SRC_S:.s=.o): $(SRCDIR)/$(SRC_S)
	printf "%s\n" "Compiling $@..."
	$(ASM) $(ASMFLAGS) $^ -o $@

$(OBJDIR):
	printf "%s\n" "Making $@/ directory..."
	mkdir $@

clean:
	printf "%s\n" "Removing $(OBJDIR)/ directory..."
	rm -rf $(OBJDIR)
	printf "%s\n" "Done."

distclean:
	printf "%s\n" "Removing built files..."
	rm -rf $(OBJDIR)
	rm $(TARGET)
	printf "%s\n" "Done."

