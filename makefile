CFLAGS += -std=c11
CFLAGS += -O0
CFLAGS += -Wall
CFLAGS += -pedantic
CFLAGS += -ansi

CFLAGS += -Wno-comment
CFLAGS += -Wno-implicit-function-declaration
CFLAGS += -Wno-unused-function
CFLAGS += -Wno-long-long
CFLAGS += -Wno-declaration-after-statement
CFLAGS += -Wno-c11-extensions
CFLAGS += -Wno-c99-extensions

CFLAGS += -D_POSIX_C_SOURCE=200809L
CFLAGS += -D_DEBUG

all: compiler

clean:
	rm -rf parser.output parser.tab.h parser.tab.c lex.yy.c compiler

compiler: parser lexer
	clang -o compiler $(CFLAGS) parser.tab.c lex.yy.c

parser: parser.y
	bison -d parser.y

lexer: lexer.l
	flex lexer.l