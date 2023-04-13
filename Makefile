SRCDIR := src
OBJDIR := obj

SRC_C := main.c 
SRC_S := print.s
OBJ_C := $(addprefix $(OBJDIR)/, $(SRC:.c=.o))
OBJ_S := $(addprefix $(OBJDIR)/, $(SRC:.s=.o))
SRC_C2S := c2asm.s
ASM2C := asm2c
C2ASM := c2asm
ASM2ASM := asm2asm

ASM := nasm
ASMFLAGS := -g -f elf64
CC := gcc
CFLAGS := -g -no-pie

.SILENT:
all: out_asm2c out_c2asm out_asm2asm run

run:
	printf "%s\n" "Running..."
	printf "%s\n\n" "Asm print(), called from C:"
	./$(ASM2C)
	printf "\n%s\n\n" "C printf(), called from Asm:"
	./$(C2ASM)
	printf "\n%s\n\n" "Asm print(), called from Asm:"
	./$(ASM2ASM)
	printf "\n%s\n" "Finished."

out_c2asm:
	$(ASM) $(ASMFLAGS) src/c2asm.s -o obj/c2asm.o
	$(CC) $(CFLAGS) obj/c2asm.o -o $(C2ASM)

out_asm2c: $(OBJDIR) $(OBJDIR)/$(SRC_C:.c=.o) $(OBJDIR)/$(SRC_S:.s=.o)
	printf "%s\n" "Linking..."
	$(CC) $(CFLAGS) $(OBJDIR)/$(SRC_C:.c=.o) $(OBJDIR)/$(SRC_S:.s=.o) -o $(ASM2C) 

out_asm2asm:
	$(ASM) $(ASMFLAGS) src/asm_print.s -o obj/asm2asm.o
	$(CC) $(CFLAGS) obj/asm2asm.o obj/print.o -o $(ASM2ASM)

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
	rm $(ASM2C)
	rm $(C2ASM)
	rm $(ASM2ASM)
	printf "%s\n" "Done."

