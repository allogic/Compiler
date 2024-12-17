%define parse.assert
%define parse.error verbose

%locations

%code requires
{
	// TODO: remove includes..

	#include <stdio.h>
	#include <string.h>
	#include <limits.h>
	#include <float.h>
	#include <errno.h>
	#include <stdarg.h>
	#include <assert.h>
	#include <time.h>
	#include <math.h>
	#include <stdint.h>

	#include "macros.h"
	#include "map.h"
	#include "vector.h"
	#include "expr.h"
	#include "prim.h"
	#include "decl.h"
	#include "scope.h"
	#include "func.h"
	#include "ctx.h"

	extern int32_t yyerror(char const* msg, ...);
	extern int32_t yywrap(void);

	extern char const* g_current_filename;

	extern int32_t g_line_number;
	extern int32_t g_column_number;

	extern char* yytext;
	extern int32_t yyleng;
}

%token IDENT
%token I8_LIT
%token I16_LIT
%token I32_LIT
%token I64_LIT
%token U8_LIT
%token U16_LIT
%token U32_LIT
%token U64_LIT
%token R32_LIT
%token R64_LIT
%token STR_LIT

%token PTYPE_I8
%token PTYPE_I16
%token PTYPE_I32
%token PTYPE_I64
%token PTYPE_U8
%token PTYPE_U16
%token PTYPE_U32
%token PTYPE_U64
%token PTYPE_R32
%token PTYPE_R64

%token COMMA
%token EQUALS
%token SEMICOLON
%token LEFT_PAREN
%token RIGHT_PAREN
%token LEFT_BRACE
%token RIGHT_BRACE

%union
{
	string_t string;
	int8_t i8;
	int16_t i16;
	int32_t i32;
	int64_t i64;
	uint8_t u8;
	uint16_t u16;
	uint32_t u32;
	uint64_t u64;
	float_t r32;
	double_t r64;
	prim_type_t ptype;
	decl_t decl;
	expr_t expr;
	func_t func;
}

%type <string> IDENT
%type <string> STR_LIT
%type <i8> I8_LIT
%type <i16> I16_LIT
%type <i32> I32_LIT
%type <i64> I64_LIT
%type <u8> U8_LIT
%type <u16> U16_LIT
%type <u32> U32_LIT
%type <u64> U64_LIT
%type <r32> R32_LIT
%type <r64> R64_LIT

%type <ptype> PTYPE
%type <ptype> PTYPE_I8
%type <ptype> PTYPE_I16
%type <ptype> PTYPE_I32
%type <ptype> PTYPE_I64
%type <ptype> PTYPE_U8
%type <ptype> PTYPE_U16
%type <ptype> PTYPE_U32
%type <ptype> PTYPE_U64
%type <ptype> PTYPE_R32
%type <ptype> PTYPE_R64

%type <decl> DECL

%type <args> ARGS
%type <arg> ARG

%type <func> FUNC_DECL

%type <expr> EXPR
%type <expr> VAR_DECL
%type <expr> STMT

%%
PROGRAM:
	PROGRAM VAR_DECL
		{
			ctx_push_expr($2);
		}
	| PROGRAM FUNC_DECL
		{
			ctx_push_func($2);
		}
	| %empty
	;

DECL:
	PTYPE IDENT
		{
			decl_t decl;
			decl_alloc(&decl, $1, $2);
			ctx_insert_decl(decl);
			string_free(&$2);
			$$ = decl;
		}
	;

VAR_DECL:
	DECL SEMICOLON
		{
			$$ = expr_var($1);
		}
	| DECL EQUALS EXPR SEMICOLON
		{
			$$ = expr_copy(expr_var($1), $3);
		}
	;

FUNC_DECL:
		{
			func_t func;
			func_begin(&func);
		}
	DECL ARGS COMP_STMT
		{
			func_end(&func);
			$$ = func;
			// TODO: context_remove_arg_identifiers();
		}
	;

ARGS:
		{
			args_t args;
			args_begin(&args);
		}
	LEFT_PAREN ARG RIGHT_PAREN
		{
			args_end(&args);
			$$ = args;
		}
	;

ARG:
	DECL
		{
			args_push($1);
		}
	| ARG COMMA DECL
		{
			args_push($1);
		}
	| %empty
	;

COMP_STMT:
		{
			ctx_push_scope();
		}
	LEFT_BRACE STMT RIGHT_BRACE
		{
			ctx_pop_scope();
		}
	;

STMT:
	VAR_DECL
		{
			expression_pack_push($1);
		}
	| COMP_STMT
		{
			// TODO
		}
	| STMT VAR_DECL
		{
			expression_pack_push($2);
		}
	| STMT COMP_STMT
		{
			// TODO
		}
	| %empty
	;

PTYPE:
	PTYPE_I8
		{
			$$ = PRIM_TYPE_I8;
		}
	| PTYPE_I16
		{
			$$ = PRIM_TYPE_I16;
		}
	| PTYPE_I32
		{
			$$ = PRIM_TYPE_I32;
		}
	| PTYPE_I64
		{
			$$ = PRIM_TYPE_I64;
		}
	| PTYPE_U8
		{
			$$ = PRIM_TYPE_U8;
		}
	| PTYPE_U16
		{
			$$ = PRIM_TYPE_U16;
		}
	| PTYPE_U32
		{
			$$ = PRIM_TYPE_U32;
		}
	| PTYPE_U64
		{
			$$ = PRIM_TYPE_U64;
		}
	| PTYPE_R32
		{
			$$ = PRIM_TYPE_R32;
		}
	| PTYPE_R64
		{
			$$ = PRIM_TYPE_R64;
		}
	;

EXPR:
	IDENT
		{
			decl_t decl = ctx_get_decl_by_ident($1);
			$$ = expr_ident(decl.ident); // TODO
		}
	| STR_LIT
		{
			$$ = expr_string($1);
		}
	| I8_LIT
		{
			$$ = expr_i8($1);
		}
	| I16_LIT
		{
			$$ = expr_i16($1);
		}
	| I32_LIT
		{
			$$ = expr_i32($1);
		}
	| I64_LIT
		{
			$$ = expr_i64($1);
		}
	| U8_LIT
		{
			$$ = expr_u8($1);
		}
	| U16_LIT
		{
			$$ = expr_u16($1);
		}
	| U32_LIT
		{
			$$ = expr_u32($1);
		}
	| U64_LIT
		{
			$$ = expr_u64($1);
		}
	| R32_LIT
		{
			$$ = expr_r32($1);
		}
	| R64_LIT
		{
			$$ = expr_r64($1);
		}
	;
%%

#include "config.h"

char const* g_current_filename;

int32_t g_line_number;
int32_t g_column_number;

int32_t main(int32_t argc, char** argv)
{
	g_current_filename = argv[1];

	g_line_number = 1;
	g_column_number = 1;

	FILE* file = fopen(argv[1], "r");

	if (file)
	{
		ctx_alloc();
		ctx_push_scope();

		struct timespec start;
		struct timespec end;

		clock_gettime(CLOCK_MONOTONIC, &start);

		yyrestart(file);
		yyparse();

		clock_gettime(CLOCK_MONOTONIC, &end);

		ctx_print();
		ctx_pop_scope();
		ctx_free();

		int64_t elapsed_ns = (end.tv_sec - start.tv_sec) * 1e9 + (end.tv_nsec - start.tv_nsec);
		int64_t elapsed_us = elapsed_ns / 1e3;
    	int64_t elapsed_ms = elapsed_ns / 1e6;

		printf("elapsed time %zdns\n", elapsed_ns);
		printf("elapsed time %zdus\n", elapsed_us);
		printf("elapsed time %zdms\n", elapsed_ms);

		fclose(file);
	}

	heap_check_leaks();

	return 0;
}
int32_t yyerror(char const* msg, ...)
{
	static char string_buffer[ERROR_FORMAT_BUFFER_SIZE];

	va_list args;

	va_start(args, msg);
	vsnprintf(string_buffer, ERROR_FORMAT_BUFFER_SIZE, msg, args);
	va_end(args);

	printf("%s:%d:%d: %s\n", g_current_filename, yylloc.first_line, yylloc.first_column, string_buffer);

	return 0;
}
int32_t yywrap(void)
{
	return 1;
}