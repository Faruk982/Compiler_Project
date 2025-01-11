# Compiler and flags
CC = gcc
CFLAGS = -Wall -g

# Lex and Yacc programs
LEX = flex
YACC = bison -d -v

# Source files
LEX_SOURCE = faruki.l
YACC_SOURCE = faruki.y

# Generated files
LEX_C = lex.yy.c
YACC_C = faruki.tab.c
YACC_H = faruki.tab.h

# Output executable
TARGET = faruki

# Default target
all: $(TARGET)

# Generate parser and compile
$(TARGET): $(LEX_C) $(YACC_C)
	$(CC) $(CFLAGS) -o $(TARGET) $(LEX_C) $(YACC_C)

# Generate lexer
$(LEX_C): $(LEX_SOURCE) $(YACC_H)
	$(LEX) $(LEX_SOURCE)

# Generate parser
$(YACC_C) $(YACC_H): $(YACC_SOURCE)
	$(YACC) $(YACC_SOURCE)

# Clean generated files
clean:
	rm -f $(TARGET) $(LEX_C) $(YACC_C) $(YACC_H) *.o

# Test target
test: $(TARGET)
	./$(TARGET) input.txt

.PHONY: all clean test 