%define parse.assert
%define parse.error verbose

%locations

%code requires
{
	#include <stdio.h>
	#include <string.h>
	#include <limits.h>
	#include <float.h>
	#include <errno.h>
	#include <stdarg.h>
	#include <assert.h>

	#ifndef MAX
		#define MAX(A, B) (((A) > (B)) ? (A) : (B))
	#endif // MAX

	#ifndef MIN
		#define MIN(A, B) (((A) < (B)) ? (A) : (B))
	#endif // MIN

	#ifndef UPDATE_CURSOR_LOCATION_SINGLE_LINE
		#define UPDATE_CURSOR_LOCATION_SINGLE_LINE() \
			yylloc.first_line = g_line_number; \
			yylloc.first_column = g_column_number; \
			g_column_number += yyleng; \
			yylloc.last_line = g_line_number; \
			yylloc.last_column = g_column_number - 1
	#endif // UPDATE_CURSOR_LOCATION_SINGLE_LINE

	#ifndef UPDATE_CURSOR_LOCATION_MULTI_LINE
		#define UPDATE_CURSOR_LOCATION_MULTI_LINE() \
			yylloc.first_line = g_line_number; \
			yylloc.first_column = g_column_number; \
			{ \
				char* ptr = yytext; \
				while (*ptr) \
				{ \
					if (*ptr == '\r') \
					{ \
						g_column_number = 1; \
					} \
					else if (*ptr == '\n') \
					{ \
						g_line_number++; \
					} \
					else \
					{ \
						g_column_number++; \
					} \
					ptr++; \
				} \
			} \
			yylloc.last_line = g_line_number; \
			yylloc.last_column = g_column_number
	#endif // UPDATE_CURSOR_LOCATION_MULTI_LINE

	#ifndef UPDATE_CURSOR_LOCATION_CARRIAGE_RETURN
		#define UPDATE_CURSOR_LOCATION_CARRIAGE_RETURN() \
			yylloc.first_line = g_line_number; \
			yylloc.first_column = g_column_number; \
			g_column_number = 1; \
			yylloc.last_line = g_line_number; \
			yylloc.last_column = g_column_number
	#endif // UPDATE_CURSOR_LOCATION_CARRIAGE_RETURN

	#ifndef UPDATE_CURSOR_LOCATION_NEW_LINE
		#define UPDATE_CURSOR_LOCATION_NEW_LINE() \
			yylloc.first_line = g_line_number; \
			yylloc.first_column = g_column_number; \
			g_line_number++; \
			yylloc.last_line = g_line_number; \
			yylloc.last_column = g_column_number
	#endif // UPDATE_CURSOR_LOCATION_NEW_LINE

	#ifndef STATIC_ASSERT
		#define STATIC_ASSERT(EXPRESSION, MESSAGE) typedef char static_assertion_##MESSAGE[(EXPRESSION) ? 1 : -1]
	#endif // STATIC_ASSERT

	#ifndef ERROR_FORMAT_BUFFER_SIZE
		#define ERROR_FORMAT_BUFFER_SIZE (0x1000ULL)
	#endif // ERROR_FORMAT_BUFFER_SIZE

	#ifndef INTEGER_FORMAT_BUFFER_SIZE
		#define INTEGER_FORMAT_BUFFER_SIZE (0x100ULL)
	#endif // INTEGER_FORMAT_BUFFER_SIZE

	#ifndef REAL_FORMAT_BUFFER_SIZE
		#define REAL_FORMAT_BUFFER_SIZE (0x100ULL)
	#endif // REAL_FORMAT_BUFFER_SIZE

	#ifndef MAP_INITIAL_CAPACITY
		#define MAP_INITIAL_CAPACITY (128ULL)
	#endif // MAP_INITIAL_CAPACITY

	#ifndef MAP_INITIAL_HASH
		#define MAP_INITIAL_HASH (5381ULL)
	#endif // MAP_INITIAL_HASH

	#ifndef MAP_LOAD_FACTOR
		#define MAP_LOAD_FACTOR (0.75F)
	#endif // MAP_LOAD_FACTOR

	#ifndef VECTOR_INITIAL_CAPACITY
		#define VECTOR_INITIAL_CAPACITY (16ULL)
	#endif // VECTOR_INITIAL_CAPACITY

	STATIC_ASSERT(sizeof(char) == 1, invalid_char_size_detected);
	STATIC_ASSERT(sizeof(short) == 2, invalid_short_size_detected);
	STATIC_ASSERT(sizeof(int) == 4, invalid_int_size_detected);
	STATIC_ASSERT(sizeof(long long) == 8, invalid_long_long_size_detected);
	STATIC_ASSERT(sizeof(float) == 4, invalid_float_size_detected);
	STATIC_ASSERT(sizeof(double) == 8, invalid_double_size_detected);

	typedef struct _map_pair_t
	{
		struct _map_pair_t* next;
		char const* key;
		void* value;
		long long unsigned key_size;
	} map_pair_t;

	typedef struct _map_t
	{
		map_pair_t** table;
		long long unsigned table_count;
		long long unsigned pair_count;
		long long unsigned value_size;
	} map_t;

	typedef struct _vector_t
	{
		char unsigned* buffer;
		long long unsigned value_size;
		long long unsigned buffer_size;
		long long unsigned buffer_count;
		long long unsigned buffer_index;
		long long unsigned buffer_offset;
	} vector_t;

	typedef enum _primitive_type_t
	{
		PRIMITIVE_TYPE_NONE,
		PRIMITIVE_TYPE_I8,
		PRIMITIVE_TYPE_I16,
		PRIMITIVE_TYPE_I32,
		PRIMITIVE_TYPE_I64,
		PRIMITIVE_TYPE_U8,
		PRIMITIVE_TYPE_U16,
		PRIMITIVE_TYPE_U32,
		PRIMITIVE_TYPE_U64,
		PRIMITIVE_TYPE_R32,
		PRIMITIVE_TYPE_R64
	} primitive_type_t;

	typedef enum _expression_type_t
	{
		EXPRESSION_TYPE_NONE,
		EXPRESSION_TYPE_COPY,
		EXPRESSION_TYPE_COMPOUND,
		EXPRESSION_TYPE_FUNCTION,
		EXPRESSION_TYPE_ARGUMENT,
		EXPRESSION_TYPE_VARIABLE,
		EXPRESSION_TYPE_IDENTIFIER,
		EXPRESSION_TYPE_STRING,
		EXPRESSION_TYPE_I8,
		EXPRESSION_TYPE_I16,
		EXPRESSION_TYPE_I32,
		EXPRESSION_TYPE_I64,
		EXPRESSION_TYPE_U8,
		EXPRESSION_TYPE_U16,
		EXPRESSION_TYPE_U32,
		EXPRESSION_TYPE_U64,
		EXPRESSION_TYPE_R32,
		EXPRESSION_TYPE_R64
	} expression_type_t;

	typedef struct _suffix_t
	{
		char unsigned available;
		int unsigned offset;
		int unsigned length;
		primitive_type_t type;
	} suffix_t;

	typedef struct _declarator_t
	{
		primitive_type_t type;
		char const* identifier;
	} declarator_t;

	typedef struct _expression_t
	{
		expression_type_t type;
		struct
		{
			vector_t children;
			declarator_t declarator;
			char const* identifier;
			char const* string;
			char signed i8;
			short signed i16;
			int signed i32;
			long long signed i64;
			char unsigned u8;
			short unsigned u16;
			int unsigned u32;
			long long unsigned u64;
			float r32;
			double r64;
		};
	} expression_t;

	typedef struct _scope_t
	{
		map_t declarators;
	} scope_t;

	typedef struct _context_t
	{
		vector_t expressions;
		vector_t scopes;
	} context_t;

	extern int yyerror(char const* msg, ...);
	extern int yywrap(void);

	extern void* memory_alloc(long long unsigned size, void const* reference);
	extern void* memory_realloc(void const* block, long long unsigned size);
	extern void memory_free(void const* block);

	extern void map_alloc(map_t* map, long long unsigned value_size);
	extern map_pair_t* map_pair_alloc(map_t* map, void const* key, long long unsigned key_size, void const* value);
	extern char unsigned map_insert(map_t* map, void const* key, long long unsigned key_size, void const* value);
	extern char unsigned map_insert_by_string(map_t* map, char const* key, void const* value);
	extern char unsigned map_remove(map_t* map, void const* key, long long unsigned key_size);
	extern char unsigned map_remove_by_string(map_t* map, char const* key);
	extern void* map_get(map_t* map, void const* key, long long unsigned key_size);
	extern void* map_get_by_string(map_t* map, char const* key);
	extern map_pair_t* map_get_pair(map_t* map, long long unsigned index);
	extern char unsigned map_contains_key(map_t* map, void const* key, long long unsigned key_size);
	extern char unsigned map_contains_string_key(map_t* map, char const* key);
	extern long long unsigned map_count(map_t* map);
	extern void map_expand(map_t* map);
	extern void map_free(map_t* map);
	extern long long unsigned map_compute_hash(char const* key, long long unsigned key_size, long long unsigned modulus);

	extern void vector_alloc(vector_t* vector, long long unsigned value_size);
	extern void vector_push(vector_t* vector, void const* value);
	extern void vector_pop(vector_t* vector, void* value);
	extern void vector_resize(vector_t* vector, long long unsigned count);
	extern void vector_clear(vector_t* vector);
	extern void* vector_back(vector_t* vector);
	extern void* vector_front(vector_t* vector);
	extern void* vector_get(vector_t* vector, long long unsigned index);
	extern void const* vector_buffer(vector_t* vector);
	extern char unsigned vector_empty(vector_t* vector);
	extern long long unsigned vector_count(vector_t* vector);
	extern long long unsigned vector_size(vector_t* vector);
	extern void vector_expand(vector_t* vector);
	extern void vector_free(vector_t* vector);

	extern void declarator_alloc(declarator_t* declarator, primitive_type_t type, char const* identifier);
	extern void declarator_free(declarator_t* declarator);

	extern expression_t expression_none(void);
	extern expression_t expression_copy(expression_t a, expression_t b);
	extern expression_t expression_compound(expression_t sub_expression);
	extern expression_t expression_function(declarator_t declarator, expression_t argument, expression_t sub_expression);
	extern expression_t expression_argument(declarator_t declarator);
	extern expression_t expression_variable(declarator_t declarator);
	extern expression_t expression_identifier(declarator_t declarator);
	extern expression_t expression_string(char const* string);
	extern expression_t expression_i8(char signed i8);
	extern expression_t expression_i16(short signed i16);
	extern expression_t expression_i32(int signed i32);
	extern expression_t expression_i64(long long signed i64);
	extern expression_t expression_u8(char unsigned u8);
	extern expression_t expression_u16(short unsigned u16);
	extern expression_t expression_u32(int unsigned u32);
	extern expression_t expression_u64(long long unsigned u64);
	extern expression_t expression_r32(float r32);
	extern expression_t expression_r64(double r64);
	extern void expression_print(expression_t expression, int unsigned indent_count, char unsigned is_global, char unsigned is_last);
	extern void expression_free(expression_t expression);

	extern void scope_alloc(scope_t* scope);
	extern void scope_free(scope_t* scope);

	extern void context_alloc(void);
	extern void context_push_scope(void);
	extern void context_pop_scope(void);
	extern void context_add_expression(expression_t expression);
	extern void context_create_declarator(primitive_type_t type, char const* identifier);
	extern declarator_t context_get_declarator_by_identifier(char const* identifier);
	extern void context_print(void);
	extern void context_free(void);

	extern suffix_t find_suffix(char indicator);

	extern primitive_type_t parse_signed_integer(int unsigned prefix_length, int unsigned base);
	extern primitive_type_t parse_unsigned_integer(int unsigned prefix_length, int unsigned base);
	extern primitive_type_t parse_real(void);

	extern char const* g_current_filename;

	extern long long unsigned g_allocated_bytes;

	extern context_t g_context;

	extern int g_line_number;
	extern int g_column_number;

	extern char* yytext;
	extern int yyleng;
}

%token IDENTIFIER
%token I8_LITERAL
%token I16_LITERAL
%token I32_LITERAL
%token I64_LITERAL
%token U8_LITERAL
%token U16_LITERAL
%token U32_LITERAL
%token U64_LITERAL
%token R32_LITERAL
%token R64_LITERAL
%token STRING_LITERAL
%token INVALID_LITERAL

%token PRIM_TYPE_I8
%token PRIM_TYPE_I16
%token PRIM_TYPE_I32
%token PRIM_TYPE_I64
%token PRIM_TYPE_U8
%token PRIM_TYPE_U16
%token PRIM_TYPE_U32
%token PRIM_TYPE_U64
%token PRIM_TYPE_R32
%token PRIM_TYPE_R64

%token EQUALS
%token SEMICOLON
%token LEFT_PAREN
%token RIGHT_PAREN
%token LEFT_BRACE
%token RIGHT_BRACE

%union
{
	char const* string;
	char signed i8;
	short signed i16;
	int signed i32;
	long long signed i64;
	char unsigned u8;
	short unsigned u16;
	int unsigned u32;
	long long unsigned u64;
	float r32;
	double r64;
	primitive_type_t primitive_type;
	declarator_t declarator;
	expression_t expression;
}

%type <string> IDENTIFIER
%type <string> STRING_LITERAL
%type <i8> I8_LITERAL
%type <i16> I16_LITERAL
%type <i32> I32_LITERAL
%type <i64> I64_LITERAL
%type <u8> U8_LITERAL
%type <u16> U16_LITERAL
%type <u32> U32_LITERAL
%type <u64> U64_LITERAL
%type <r32> R32_LITERAL
%type <r64> R64_LITERAL

%type <primitive_type> PRIM_TYPE
%type <primitive_type> PRIM_TYPE_I8
%type <primitive_type> PRIM_TYPE_I16
%type <primitive_type> PRIM_TYPE_I32
%type <primitive_type> PRIM_TYPE_I64
%type <primitive_type> PRIM_TYPE_U8
%type <primitive_type> PRIM_TYPE_U16
%type <primitive_type> PRIM_TYPE_U32
%type <primitive_type> PRIM_TYPE_U64
%type <primitive_type> PRIM_TYPE_R32
%type <primitive_type> PRIM_TYPE_R64

%type <declarator> DECLARATOR

%type <expression> EXPRESSION
%type <expression> FUNC_DECL
%type <expression> ARG_DECL
%type <expression> VAR_DECL
%type <expression> STATEMENT
%type <expression> COMP_STATEMENT

%%
PROGRAM:
	PROGRAM VAR_DECL { context_add_expression($2); }
	| PROGRAM FUNC_DECL { context_add_expression($2); }
	| %empty
	;

DECLARATOR:
	PRIM_TYPE IDENTIFIER { context_create_declarator($1, $2); $$ = context_get_declarator_by_identifier($2); }
	;

VAR_DECL:
	DECLARATOR SEMICOLON { $$ = expression_variable($1); }
	| DECLARATOR EQUALS EXPRESSION SEMICOLON { $$ = expression_copy(expression_variable($1), $3); }
	;

FUNC_DECL:
	DECLARATOR LEFT_PAREN ARG_DECL RIGHT_PAREN LEFT_BRACE RIGHT_BRACE { $$ = expression_function($1, $3, expression_none()); }
	| DECLARATOR LEFT_PAREN ARG_DECL RIGHT_PAREN LEFT_BRACE STATEMENT RIGHT_BRACE { $$ = expression_function($1, $3, $6); }
	;

ARG_DECL:
	DECLARATOR { $$ = expression_argument($1); }
	;

STATEMENT:
	VAR_DECL
	| COMP_STATEMENT
	;

COMP_STATEMENT:
	LEFT_BRACE STATEMENT RIGHT_BRACE { $$ = expression_compound($2); }
	;

PRIM_TYPE:
	PRIM_TYPE_I8 { $$ = PRIMITIVE_TYPE_I8; }
	| PRIM_TYPE_I16 { $$ = PRIMITIVE_TYPE_I16; }
	| PRIM_TYPE_I32 { $$ = PRIMITIVE_TYPE_I32; }
	| PRIM_TYPE_I64 { $$ = PRIMITIVE_TYPE_I64; }
	| PRIM_TYPE_U8 { $$ = PRIMITIVE_TYPE_U8; }
	| PRIM_TYPE_U16 { $$ = PRIMITIVE_TYPE_U16; }
	| PRIM_TYPE_U32 { $$ = PRIMITIVE_TYPE_U32; }
	| PRIM_TYPE_U64 { $$ = PRIMITIVE_TYPE_U64; }
	| PRIM_TYPE_R32 { $$ = PRIMITIVE_TYPE_R32; }
	| PRIM_TYPE_R64 { $$ = PRIMITIVE_TYPE_R64; }
	;

EXPRESSION:
	IDENTIFIER { $$ = expression_identifier(context_get_declarator_by_identifier($1)); }
	| STRING_LITERAL { $$ = expression_string($1); }
	| I8_LITERAL { $$ = expression_i8($1); }
	| I16_LITERAL { $$ = expression_i16($1); }
	| I32_LITERAL { $$ = expression_i32($1); }
	| I64_LITERAL { $$ = expression_i64($1); }
	| U8_LITERAL { $$ = expression_u8($1); }
	| U16_LITERAL { $$ = expression_u16($1); }
	| U32_LITERAL { $$ = expression_u32($1); }
	| U64_LITERAL { $$ = expression_u64($1); }
	| R32_LITERAL { $$ = expression_r32($1); }
	| R64_LITERAL { $$ = expression_r64($1); }
	;
%%

char const* g_current_filename;

long long unsigned g_allocated_bytes;

int g_line_number;
int g_column_number;

context_t g_context;

int main(int argc, char** argv)
{
	g_current_filename = argv[1];

	g_allocated_bytes = 0;

	g_line_number = 1;
	g_column_number = 1;

	FILE* file = fopen(argv[1], "r");

	if (file)
	{
		context_alloc();
		context_push_scope();

		yyrestart(file);
		yyparse();

		context_print();
		context_pop_scope();
		context_free();

		fclose(file);
	}

#ifdef _DEBUG
	if (g_allocated_bytes)
	{
		printf("%llu bytes not freed\n", g_allocated_bytes);
	}
#endif // _DEBUG

	assert(g_allocated_bytes == 0);

	return 0;
}
int yyerror(char const* msg, ...)
{
	static char string_buffer[ERROR_FORMAT_BUFFER_SIZE];

	va_list arguments;

	va_start(arguments, msg);
	vsnprintf(string_buffer, ERROR_FORMAT_BUFFER_SIZE, msg, arguments);
	va_end(arguments);

	printf("%s:%d:%d: %s\n", g_current_filename, yylloc.first_line, yylloc.first_column, string_buffer);

	return 0;
}
int yywrap(void)
{
	return 1;
}
void* memory_alloc(long long unsigned size, void const* reference)
{
#ifdef _DEBUG
	long long unsigned new_size = sizeof(long long unsigned) + size;

	long long unsigned* new_block = (long long unsigned*)malloc(new_size);

	g_allocated_bytes += new_size;

	*new_block = new_size;
	new_block++;

	if (reference)
	{
		memcpy(new_block, reference, size);
	}

	return new_block;
#else
	void* new_block = malloc(size);

	if (reference)
	{
		memcpy(new_block, reference, size);
	}

	return new_block;
#endif // _DEBUG
}
void* memory_realloc(void const* block, long long unsigned size)
{
#ifdef _DEBUG
	if (block)
	{
		long long unsigned* old_block = (long long unsigned*)block;

		old_block -= 1;

		long long unsigned old_size = *old_block;
		long long unsigned new_size = sizeof(long long unsigned) + size;

		g_allocated_bytes -= old_size;

		long long unsigned* new_block = (long long unsigned*)realloc(old_block, new_size);

		g_allocated_bytes += new_size;

		*new_block = new_size;
		new_block++;

		return new_block;
	}
	else
	{
		return memory_alloc(size, 0);
	}
#else
	return realloc(block, size);
#endif // _DEBUG
}
void memory_free(void const* block)
{
#ifdef _DEBUG
	long long unsigned* old_block = (long long unsigned*)block;

	old_block -= 1;

	long long unsigned old_size = *old_block;

	g_allocated_bytes -= old_size;

	free(old_block);
#else
	free(block);
#endif // _DEBUG
}
void map_alloc(map_t* map, long long unsigned value_size)
{
	memset(map, 0, sizeof(map_t));

	map->table = (map_pair_t**)memory_alloc(MAP_INITIAL_CAPACITY * sizeof(map_pair_t*), 0);
	map->table_count = MAP_INITIAL_CAPACITY;
	map->pair_count = 0;
	map->value_size = value_size;

	memset(map->table, 0, MAP_INITIAL_CAPACITY * sizeof(map_pair_t*));
}
map_pair_t* map_pair_alloc(map_t* map, void const* key, long long unsigned key_size, void const* value)
{
	map_pair_t* pair = (map_pair_t*)memory_alloc(sizeof(map_pair_t), 0);

	memset(pair, 0, sizeof(map_pair_t));

	pair->next = 0;
	pair->key = (char const*)memory_alloc(key_size, key);
	pair->value = memory_alloc(map->value_size, value);
	pair->key_size = key_size;

	return pair;
}
char unsigned map_insert(map_t* map, void const* key, long long unsigned key_size, void const* value)
{
	char unsigned key_exists = 0;

	if ((((float)(map->pair_count + 1)) / (float)map->table_count) > MAP_LOAD_FACTOR)
	{
		map_expand(map);
	}

	long long unsigned hash = map_compute_hash((char const*)key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];

	while (curr)
	{
		if (strncmp(curr->key, (char const*)key, MIN(curr->key_size, key_size)) == 0)
		{
			key_exists = 1;

			break;
		}

		curr = curr->next;
	}

	if (key_exists == 0)
	{
		curr = map_pair_alloc(map, key, key_size, value);

		curr->next = map->table[hash];

		map->table[hash] = curr;
		map->pair_count++;
	}

	return key_exists;
}
char unsigned map_insert_by_string(map_t* map, char const* key, void const* value)
{
	char unsigned key_exists = 0;

	if ((((float)(map->pair_count + 1)) / (float)map->table_count) > MAP_LOAD_FACTOR)
	{
		map_expand(map);
	}

	long long unsigned key_size = strlen(key);
	long long unsigned hash = map_compute_hash(key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];

	while (curr)
	{
		if (strncmp(curr->key, key, MIN(curr->key_size, key_size)) == 0)
		{
			key_exists = 1;

			break;
		}

		curr = curr->next;
	}

	if (key_exists == 0)
	{
		curr = map_pair_alloc(map, key, key_size, value);

		curr->next = map->table[hash];

		map->table[hash] = curr;
		map->pair_count++;
	}

	return key_exists;
}
char unsigned map_remove(map_t* map, void const* key, long long unsigned key_size)
{
	long long unsigned hash = map_compute_hash((char const*)key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];
	map_pair_t* prev = 0;

	while (curr)
	{
		if (strncmp(curr->key, (char const*)key, MIN(curr->key_size, key_size)) == 0)
		{
			if (prev)
			{
				prev->next = curr->next;
			}
			else
			{
				map->table[hash] = curr->next;
			}

			memory_free(curr->key);
			memory_free(curr->value);
			memory_free(curr);

			map->pair_count--;

			return 1;
		}

		prev = curr;
		curr = curr->next;
	}

	return 0;
}
char unsigned map_remove_by_string(map_t* map, char const* key)
{
	long long unsigned key_size = strlen(key);
	long long unsigned hash = map_compute_hash(key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];
	map_pair_t* prev = 0;

	while (curr)
	{
		if (strncmp(curr->key, key, MIN(curr->key_size, key_size)) == 0)
		{
			if (prev)
			{
				prev->next = curr->next;
			}
			else
			{
				map->table[hash] = curr->next;
			}

			memory_free(curr->key);
			memory_free(curr->value);
			memory_free(curr);

			map->pair_count--;

			return 1;
		}

		prev = curr;
		curr = curr->next;
	}

	return 0;
}
void* map_get(map_t* map, void const* key, long long unsigned key_size)
{
	long long unsigned hash = map_compute_hash((char const*)key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];

	while (curr)
	{
		if (strncmp(curr->key, (char const*)key, MIN(curr->key_size, key_size)) == 0)
		{
			return curr->value;
		}

		curr = curr->next;
	}

	return 0;
}
void* map_get_by_string(map_t* map, char const* key)
{
	long long unsigned key_size = strlen(key);
	long long unsigned hash = map_compute_hash(key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];

	while (curr)
	{
		if (strncmp(curr->key, key, MIN(curr->key_size, key_size)) == 0)
		{
			return curr->value;
		}

		curr = curr->next;
	}

	return 0;
}
map_pair_t* map_get_pair(map_t* map, long long unsigned index)
{
	return map->table[index];
}
char unsigned map_contains_key(map_t* map, void const* key, long long unsigned key_size)
{
	long long unsigned hash = map_compute_hash(key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];

	while (curr)
	{
		if (strncmp(curr->key, (char const*)key, MIN(curr->key_size, key_size)) == 0)
		{
			return 1;
		}

		curr = curr->next;
	}

	return 0;
}
char unsigned map_contains_string_key(map_t* map, char const* key)
{
	long long unsigned key_size = strlen(key);
	long long unsigned hash = map_compute_hash(key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];

	while (curr)
	{
		if (strncmp(curr->key, key, MIN(curr->key_size, key_size)) == 0)
		{
			return 1;
		}

		curr = curr->next;
	}

	return 0;
}
long long unsigned map_count(map_t* map)
{
	return map->table_count;
}
void map_expand(map_t* map)
{
	long long unsigned table_index = 0;
	long long unsigned new_table_count = map->table_count * 2;

	map_pair_t** new_table = (map_pair_t**)memory_alloc(new_table_count * sizeof(map_pair_t*), 0);

	memset(new_table, 0, new_table_count * sizeof(map_pair_t*));

	while (table_index < map->table_count)
	{
		map_pair_t* curr = map->table[table_index];

		while (curr)
		{
			long long unsigned hash = map_compute_hash(curr->key, curr->key_size, new_table_count);

			curr->next = new_table[hash];
			new_table[hash] = curr;

			curr = curr->next;
		}

		table_index++;
	}

	memory_free(map->table);

	map->table = new_table;
	map->table_count = new_table_count;
}
void map_free(map_t* map)
{
	long long unsigned table_index = 0;

	while (table_index < map->table_count)
	{
		map_pair_t* curr = map->table[table_index];

		while (curr)
		{
			map_pair_t* tmp = curr;
			curr = curr->next;

			memory_free(tmp->key);
			memory_free(tmp->value);
			memory_free(tmp);
		}

		table_index++;
	}

	memory_free(map->table);
}
long long unsigned map_compute_hash(char const* key, long long unsigned key_size, long long unsigned modulus)
{
	long long unsigned hash = MAP_INITIAL_HASH;
	long long unsigned key_index = 0;

	while (key_index < key_size)
	{
		hash = ((hash << 5) + hash) + key[key_index];
		key_index++;
	}

	return hash % modulus;
}
void vector_alloc(vector_t* vector, long long unsigned value_size)
{
	memset(vector, 0, sizeof(vector_t));

	vector->buffer = (char unsigned*)memory_alloc(value_size * VECTOR_INITIAL_CAPACITY, 0);
	vector->value_size = value_size;
	vector->buffer_size = value_size * VECTOR_INITIAL_CAPACITY;
	vector->buffer_count = VECTOR_INITIAL_CAPACITY;
	vector->buffer_index = 0;
	vector->buffer_offset = 0;
}
void vector_push(vector_t* vector, void const* value)
{
	memcpy(vector->buffer + vector->buffer_offset, value, vector->value_size);

	vector->buffer_index++;
	vector->buffer_offset += vector->value_size;

	if (vector->buffer_index >= vector->buffer_count)
	{
		vector_expand(vector);
	}
}
void vector_pop(vector_t* vector, void* value)
{
	vector->buffer_index -= 1;
	vector->buffer_offset -= vector->value_size;

	if (value)
	{
		memcpy(value, vector->buffer + vector->buffer_offset, vector->value_size);
	}

	memset(vector->buffer + vector->buffer_offset, 0, vector->value_size);
}
void vector_resize(vector_t* vector, long long unsigned count)
{
	if (count > vector->buffer_count)
	{
		vector->buffer = (char unsigned*)memory_realloc(vector->buffer, count * vector->value_size);
		vector->buffer_count = count;
		vector->buffer_size = count * vector->value_size;
	}
	else if (count < vector->buffer_count)
	{
		vector->buffer = (char unsigned*)memory_realloc(vector->buffer, count * vector->value_size);
		vector->buffer_count = count;
		vector->buffer_size = count * vector->value_size;
		vector->buffer_index = MIN(vector->buffer_index, count);
		vector->buffer_offset = MIN(vector->buffer_index, count) * vector->value_size;
	}
}
void vector_clear(vector_t* vector)
{
	vector->buffer_index = 0;
	vector->buffer_offset = 0;
}
void* vector_back(vector_t* vector)
{
	return vector->buffer + vector->buffer_offset - vector->value_size;
}
void* vector_front(vector_t* vector)
{
	return vector->buffer;
}
void* vector_get(vector_t* vector, long long unsigned index)
{
	return vector->buffer + (index * vector->value_size);
}
void const* vector_buffer(vector_t* vector)
{
	return (void const*)vector->buffer;
}
char unsigned vector_empty(vector_t* vector)
{
	return vector->buffer_index == 0;
}
long long unsigned vector_count(vector_t* vector)
{
	return vector->buffer_index;
}
long long unsigned vector_size(vector_t* vector)
{
	return vector->buffer_offset;
}
void vector_expand(vector_t* vector)
{
	long long unsigned new_buffer_count = vector->buffer_count * 2;
	long long unsigned new_buffer_size = vector->buffer_size * 2;

	vector->buffer = (char unsigned*)memory_realloc(vector->buffer, new_buffer_size);
	vector->buffer_count = new_buffer_count;
	vector->buffer_size = new_buffer_size;
}
void vector_free(vector_t* vector)
{
	memory_free(vector->buffer);
}
void declarator_alloc(declarator_t* declarator, primitive_type_t type, char const* identifier)
{
	memset(declarator, 0, sizeof(declarator_t));

	declarator->type = type;
	declarator->identifier = memory_alloc(strlen(identifier), identifier);
}
void declarator_free(declarator_t* declarator)
{
	memory_free(declarator->identifier);
}
expression_t expression_none(void)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_NONE;

	return expression;
}
expression_t expression_copy(expression_t a, expression_t b)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_COPY;

	vector_alloc(&expression.children, sizeof(expression_t));

	vector_push(&expression.children, &a);
	vector_push(&expression.children, &b);

	return expression;
}
expression_t expression_compound(expression_t sub_expression)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_COMPOUND;
	
	vector_alloc(&expression.children, sizeof(expression_t));

	vector_push(&expression.children, &sub_expression);

	return expression;
}
expression_t expression_function(declarator_t declarator, expression_t argument, expression_t sub_expression)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_FUNCTION;
	expression.declarator = declarator;

	vector_alloc(&expression.children, sizeof(expression_t));

	vector_push(&expression.children, &argument);
	vector_push(&expression.children, &sub_expression);

	return expression;
}
expression_t expression_argument(declarator_t declarator)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_ARGUMENT;
	expression.declarator = declarator;

	return expression;
}
expression_t expression_variable(declarator_t declarator)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_VARIABLE;
	expression.declarator = declarator;

	return expression;
}
expression_t expression_identifier(declarator_t declarator)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_IDENTIFIER;
	expression.identifier = (char const*)memory_alloc(strlen(declarator.identifier), declarator.identifier);

	return expression;
}
expression_t expression_string(char const* string)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_STRING;
	expression.string = (char const*)memory_alloc(strlen(string) - 2, string + 1);

	return expression;
}
expression_t expression_i8(char signed i8)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_I8;
	expression.i8 = i8;

	return expression;
}
expression_t expression_i16(short signed i16)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_I16;
	expression.i16 = i16;

	return expression;
}
expression_t expression_i32(int signed i32)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_I32;
	expression.i32 = i32;

	return expression;
}
expression_t expression_i64(long long signed i64)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_I64;
	expression.i64 = i64;

	return expression;
}
expression_t expression_u8(char unsigned u8)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_U8;
	expression.u8 = u8;

	return expression;
}
expression_t expression_u16(short unsigned u16)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_U16;
	expression.u16 = u16;

	return expression;
}
expression_t expression_u32(int unsigned u32)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_U32;
	expression.u32 = u32;

	return expression;
}
expression_t expression_u64(long long unsigned u64)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_U64;
	expression.u64 = u64;

	return expression;
}
expression_t expression_r32(float r32)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_R32;
	expression.r32 = r32;

	return expression;
}
expression_t expression_r64(double r64)
{
	expression_t expression;

	memset(&expression, 0, sizeof(expression_t));

	expression.type = EXPRESSION_TYPE_R64;
	expression.r64 = r64;

	return expression;
}
void expression_print(expression_t expression, int unsigned indent_count, char unsigned is_global, char unsigned is_last)
{
	int unsigned indent_increment = 1;

	if (is_global == 0)
	{
		int unsigned indent_index = 0;

		while (indent_index < indent_count)
		{
			printf(" ");

			indent_index++;
		}
	}

	if (is_global == 0)
	{
		if (is_last)
		{
			if (vector_empty(&expression.children))
			{
				printf("└──");
			}
			else
			{
				printf("└┬─");
			}
		}
		else
		{
			printf("├──");
		}
	}

	switch (expression.type)
	{
		case EXPRESSION_TYPE_NONE:
		{
			printf("none\n");

			break;
		}
		case EXPRESSION_TYPE_COPY:
		{
			printf("copy\n");

			long long unsigned child_index = 0;
			long long unsigned child_count = vector_count(&expression.children);

			while (child_index < child_count)
			{
				expression_t child = *(expression_t*)vector_get(&expression.children, child_index);

				expression_print(child, indent_count + indent_increment, 0, child_index == (child_count - 1));

				child_index++;
			}

			break;
		}
		case EXPRESSION_TYPE_COMPOUND:
		{
			printf("comp\n");

			long long unsigned child_index = 0;
			long long unsigned child_count = vector_count(&expression.children);

			while (child_index < child_count)
			{
				expression_t child = *(expression_t*)vector_get(&expression.children, child_index);

				expression_print(child, indent_count + indent_increment, 0, child_index == (child_count - 1));

				child_index++;
			}

			break;
		}
		case EXPRESSION_TYPE_FUNCTION:
		{
			printf("func ");

			switch (expression.declarator.type)
			{
				case PRIMITIVE_TYPE_NONE: printf("none"); break;
				case PRIMITIVE_TYPE_I8: printf("i8"); break;
				case PRIMITIVE_TYPE_I16: printf("i16"); break;
				case PRIMITIVE_TYPE_I32: printf("i32"); break;
				case PRIMITIVE_TYPE_I64: printf("i64"); break;
				case PRIMITIVE_TYPE_U8: printf("u8"); break;
				case PRIMITIVE_TYPE_U16: printf("u16"); break;
				case PRIMITIVE_TYPE_U32: printf("u32"); break;
				case PRIMITIVE_TYPE_U64: printf("u64"); break;
				case PRIMITIVE_TYPE_R32: printf("r32"); break;
				case PRIMITIVE_TYPE_R64: printf("r64"); break;
			}

			printf(" %s\n", expression.declarator.identifier);

			long long unsigned child_index = 0;
			long long unsigned child_count = vector_count(&expression.children);

			while (child_index < child_count)
			{
				expression_t child = *(expression_t*)vector_get(&expression.children, child_index);

				expression_print(child, indent_count + indent_increment, 0, child_index == (child_count - 1));

				child_index++;
			}

			break;
		}
		case EXPRESSION_TYPE_ARGUMENT:
		{
			printf("arg ");

			switch (expression.declarator.type)
			{
				case PRIMITIVE_TYPE_NONE: printf("none"); break;
				case PRIMITIVE_TYPE_I8: printf("i8"); break;
				case PRIMITIVE_TYPE_I16: printf("i16"); break;
				case PRIMITIVE_TYPE_I32: printf("i32"); break;
				case PRIMITIVE_TYPE_I64: printf("i64"); break;
				case PRIMITIVE_TYPE_U8: printf("u8"); break;
				case PRIMITIVE_TYPE_U16: printf("u16"); break;
				case PRIMITIVE_TYPE_U32: printf("u32"); break;
				case PRIMITIVE_TYPE_U64: printf("u64"); break;
				case PRIMITIVE_TYPE_R32: printf("r32"); break;
				case PRIMITIVE_TYPE_R64: printf("r64"); break;
			}

			printf(" %s\n", expression.declarator.identifier);

			break;
		}
		case EXPRESSION_TYPE_VARIABLE:
		{
			printf("var ");

			switch (expression.declarator.type)
			{
				case PRIMITIVE_TYPE_NONE: printf("none"); break;
				case PRIMITIVE_TYPE_I8: printf("i8"); break;
				case PRIMITIVE_TYPE_I16: printf("i16"); break;
				case PRIMITIVE_TYPE_I32: printf("i32"); break;
				case PRIMITIVE_TYPE_I64: printf("i64"); break;
				case PRIMITIVE_TYPE_U8: printf("u8"); break;
				case PRIMITIVE_TYPE_U16: printf("u16"); break;
				case PRIMITIVE_TYPE_U32: printf("u32"); break;
				case PRIMITIVE_TYPE_U64: printf("u64"); break;
				case PRIMITIVE_TYPE_R32: printf("r32"); break;
				case PRIMITIVE_TYPE_R64: printf("r64"); break;
			}

			printf(" %s\n", expression.declarator.identifier);

			break;
		}
		case EXPRESSION_TYPE_IDENTIFIER:
		{
			printf("ident %s\n", expression.identifier);

			break;
		}
		case EXPRESSION_TYPE_STRING:
		{
			printf("lit str \"%s\"\n", expression.string);

			break;
		}
		case EXPRESSION_TYPE_I8:
		{
			printf("lit i8 %d\n", expression.i8);

			break;
		}
		case EXPRESSION_TYPE_I16:
		{
			printf("lit i16 %d\n", expression.i16);

			break;
		}
		case EXPRESSION_TYPE_I32:
		{
			printf("lit i32 %d\n", expression.i32);

			break;
		}
		case EXPRESSION_TYPE_I64:
		{
			printf("lit i64 %lld\n", expression.i64);

			break;
		}
		case EXPRESSION_TYPE_U8:
		{
			printf("lit u8 %u\n", expression.u8);

			break;
		}
		case EXPRESSION_TYPE_U16:
		{
			printf("lit u16 %u\n", expression.u16);

			break;
		}
		case EXPRESSION_TYPE_U32:
		{
			printf("lit u32 %u\n", expression.u32);

			break;
		}
		case EXPRESSION_TYPE_U64:
		{
			printf("lit u64 %llu\n", expression.u64);

			break;
		}
		case EXPRESSION_TYPE_R32:
		{
			printf("lit r32 %f\n", expression.r32);

			break;
		}
		case EXPRESSION_TYPE_R64:
		{
			printf("lit r64 %f\n", expression.r64);

			break;
		}
	}

	if (is_global && (is_last == 0))
	{
		printf("\n");
	}
}
void expression_free(expression_t expression)
{
	switch (expression.type)
	{
		case EXPRESSION_TYPE_NONE:
		{
			break;
		}
		case EXPRESSION_TYPE_COPY:
		{
			long long unsigned child_index = 0;
			long long unsigned child_count = vector_count(&expression.children);

			while (child_index < child_count)
			{
				expression_t child = *(expression_t*)vector_get(&expression.children, child_index);

				expression_free(child);

				child_index++;
			}

			vector_free(&expression.children);

			break;
		}
		case EXPRESSION_TYPE_COMPOUND:
		{
			long long unsigned child_index = 0;
			long long unsigned child_count = vector_count(&expression.children);

			while (child_index < child_count)
			{
				expression_t child = *(expression_t*)vector_get(&expression.children, child_index);

				expression_free(child);

				child_index++;
			}

			vector_free(&expression.children);

			break;
		}
		case EXPRESSION_TYPE_FUNCTION:
		{
			long long unsigned child_index = 0;
			long long unsigned child_count = vector_count(&expression.children);

			while (child_index < child_count)
			{
				expression_t child = *(expression_t*)vector_get(&expression.children, child_index);

				expression_free(child);

				child_index++;
			}

			vector_free(&expression.children);

			break;
		}
		case EXPRESSION_TYPE_ARGUMENT:
		{
			break;
		}
		case EXPRESSION_TYPE_VARIABLE:
		{
			break;
		}
		case EXPRESSION_TYPE_IDENTIFIER:
		{
			memory_free(expression.identifier);

			break;
		}
		case EXPRESSION_TYPE_STRING:
		{
			memory_free(expression.string);

			break;
		}
		case EXPRESSION_TYPE_I8:
		{
			break;
		}
		case EXPRESSION_TYPE_I16:
		{
			break;
		}
		case EXPRESSION_TYPE_I32:
		{
			break;
		}
		case EXPRESSION_TYPE_I64:
		{
			break;
		}
		case EXPRESSION_TYPE_U8:
		{
			break;
		}
		case EXPRESSION_TYPE_U16:
		{
			break;
		}
		case EXPRESSION_TYPE_U32:
		{
			break;
		}
		case EXPRESSION_TYPE_U64:
		{
			break;
		}
		case EXPRESSION_TYPE_R32:
		{
			break;
		}
		case EXPRESSION_TYPE_R64:
		{
			break;
		}
	}
}
void scope_alloc(scope_t* scope)
{
	memset(scope, 0, sizeof(scope_t));

	map_alloc(&scope->declarators, sizeof(declarator_t));
}
void scope_free(scope_t* scope)
{
	long long unsigned table_index = 0;
	long long unsigned table_count = map_count(&scope->declarators);

	while (table_index < table_count)
	{
		map_pair_t* pair = map_get_pair(&scope->declarators, table_index);

		while (pair)
		{
			declarator_t* declarator = (declarator_t*)pair->value;

			memory_free(declarator->identifier);

			pair = pair->next;
		}

		table_index++;
	}

	map_free(&scope->declarators);

	memset(scope, 0, sizeof(scope_t));
}
void context_alloc(void)
{
	memset(&g_context, 0, sizeof(context_t));

	vector_alloc(&g_context.expressions, sizeof(expression_t));
	vector_alloc(&g_context.scopes, sizeof(scope_t));
}
void context_push_scope(void)
{
	scope_t scope;
	
	scope_alloc(&scope);

	vector_push(&g_context.scopes, &scope);
}
void context_pop_scope(void)
{
	scope_t scope;

	vector_pop(&g_context.scopes, &scope);

	scope_free(&scope);
}
void context_add_expression(expression_t expression)
{
	vector_push(&g_context.expressions, &expression);
}
void context_create_declarator(primitive_type_t type, char const* identifier)
{
	scope_t* scope = (scope_t*)vector_back(&g_context.scopes);

	if (map_contains_string_key(&scope->declarators, identifier))
	{
		yyerror("duplicate identifier <%s>", identifier);
	}
	else
	{
		declarator_t declarator;

		declarator_alloc(&declarator, type, identifier);

		map_insert_by_string(&scope->declarators, identifier, &declarator);
	}
}
declarator_t context_get_declarator_by_identifier(char const* identifier)
{
	declarator_t declarator;

	memset(&declarator, 0, sizeof(declarator_t));

	char unsigned declarator_exists = 0;

	long long unsigned scope_index = 0;
	long long unsigned scope_count = vector_count(&g_context.scopes);

	while (scope_index < scope_count)
	{
		scope_t* scope = (scope_t*)vector_get(&g_context.scopes, scope_count - scope_index - 1);

		declarator_exists = map_contains_string_key(&scope->declarators, identifier);

		if (declarator_exists)
		{
			declarator = *(declarator_t*)map_get_by_string(&scope->declarators, identifier);

			break;
		}

		scope_index++;
	}

	if (declarator_exists == 0)
	{
		yyerror("undefined identifier <%s>", identifier);
	}

	return declarator;
}
void context_print(void)
{
	long long unsigned expression_index = 0;
	long long unsigned expression_count = vector_count(&g_context.expressions);

	while (expression_index < expression_count)
	{
		expression_t expression = *(expression_t*)vector_get(&g_context.expressions, expression_index);

		expression_print(expression, 0, 1, expression_index == (expression_count - 1));

		expression_index++;
	}
}
void context_free(void)
{
	long long unsigned expression_index = 0;
	long long unsigned expression_count = vector_count(&g_context.expressions);

	while (expression_index < expression_count)
	{
		expression_t expression = *(expression_t*)vector_get(&g_context.expressions, expression_index);

		expression_free(expression);

		expression_index++;
	}

	vector_free(&g_context.expressions);
	vector_free(&g_context.scopes);

	memset(&g_context, 0, sizeof(context_t));
}
suffix_t find_suffix(char indicator)
{
	suffix_t suffix;

	memset(&suffix, 0, sizeof(suffix_t));

	char* string = yytext;

	while (*string++)
	{
		if (*string == indicator)
		{
			suffix.available = 1;
			suffix.offset = string - yytext;

			break;
		}
	}

	if (suffix.available)
	{
		while (*string++) suffix.length++;

		if (strncmp(yytext + suffix.offset, "i8", suffix.length) == 0) suffix.type = PRIMITIVE_TYPE_I8;
		else if (strncmp(yytext + suffix.offset, "i16", suffix.length) == 0) suffix.type = PRIMITIVE_TYPE_I16;
		else if (strncmp(yytext + suffix.offset, "i32", suffix.length) == 0) suffix.type = PRIMITIVE_TYPE_I32;
		else if (strncmp(yytext + suffix.offset, "i64", suffix.length) == 0) suffix.type = PRIMITIVE_TYPE_I64;
		else if (strncmp(yytext + suffix.offset, "u8", suffix.length) == 0) suffix.type = PRIMITIVE_TYPE_U8;
		else if (strncmp(yytext + suffix.offset, "u16", suffix.length) == 0) suffix.type = PRIMITIVE_TYPE_U16;
		else if (strncmp(yytext + suffix.offset, "u32", suffix.length) == 0) suffix.type = PRIMITIVE_TYPE_U32;
		else if (strncmp(yytext + suffix.offset, "u64", suffix.length) == 0) suffix.type = PRIMITIVE_TYPE_U64;
		else if (strncmp(yytext + suffix.offset, "r32", suffix.length) == 0) suffix.type = PRIMITIVE_TYPE_R32;
		else if (strncmp(yytext + suffix.offset, "r64", suffix.length) == 0) suffix.type = PRIMITIVE_TYPE_R64;
		else suffix.type = PRIMITIVE_TYPE_NONE;
	}

	return suffix;
}
primitive_type_t parse_signed_integer(int unsigned prefix_length, int unsigned base)
{
	primitive_type_t type = PRIMITIVE_TYPE_NONE;

	static char string_buffer[INTEGER_FORMAT_BUFFER_SIZE];

	memset(string_buffer, 0, sizeof(string_buffer));

	suffix_t suffix = find_suffix('i');

	int unsigned sign_offset = 0;

	if ((yytext[0] == '-') || (yytext[0] == '+'))
	{
		sign_offset = 1;
		string_buffer[0] = yytext[0];
	}

	strncpy(string_buffer + sign_offset, yytext + sign_offset + prefix_length, yyleng - suffix.length - sign_offset - prefix_length);

	errno = 0;
	char* string_buffer_end = 0;
	long long signed value = strtoll(string_buffer, &string_buffer_end, base);

	if (errno == ERANGE)
	{
		yyerror("integer overflow <%s>", string_buffer);
	}
	else
	{
		if (string_buffer_end == string_buffer)
		{
			yyerror("invalid signed integer value <%s>", string_buffer);
		}
		else
		{
			if (suffix.available)
			{
				switch (suffix.type)
				{
					case PRIMITIVE_TYPE_I8: yylval.i8 = (char signed)value; type = PRIMITIVE_TYPE_I8; break;
					case PRIMITIVE_TYPE_I16: yylval.i16 = (short signed)value; type = PRIMITIVE_TYPE_I16; break;
					case PRIMITIVE_TYPE_I32: yylval.i32 = (int signed)value; type = PRIMITIVE_TYPE_I32; break;
					case PRIMITIVE_TYPE_I64: yylval.i64 = (long long signed)value; type = PRIMITIVE_TYPE_I64; break;
					default: yyerror("invalid signed integer suffix <%s>", string_buffer); break;
				}
			}
			else
			{
				if (value >= SCHAR_MIN && value <= SCHAR_MAX)
				{
					yylval.i8 = (char signed)value;
					type = PRIMITIVE_TYPE_I8;
				}
				else if (value >= SHRT_MIN && value <= SHRT_MAX)
				{
					yylval.i16 = (short signed)value;
					type = PRIMITIVE_TYPE_I16;
				}
				else if (value >= INT_MIN && value <= INT_MAX)
				{
					yylval.i32 = (int signed)value;
					type = PRIMITIVE_TYPE_I32;
				}
				else if (value >= LLONG_MIN && value <= LLONG_MAX)
				{
					yylval.i64 = (long long signed)value;
					type = PRIMITIVE_TYPE_I64;
				}
			}
		}
	}

	return type;
}
primitive_type_t parse_unsigned_integer(int unsigned prefix_length, int unsigned base)
{
	primitive_type_t type = PRIMITIVE_TYPE_NONE;

	static char string_buffer[INTEGER_FORMAT_BUFFER_SIZE];

	memset(string_buffer, 0, sizeof(string_buffer));

	suffix_t suffix = find_suffix('u');

	strncpy(string_buffer, yytext + prefix_length, yyleng - suffix.length - prefix_length);

	errno = 0;
	char* string_buffer_end = 0;
	long long unsigned value = strtoull(string_buffer, &string_buffer_end, base);

	if (errno == ERANGE)
	{
		yyerror("integer overflow <%s>", string_buffer);
	}
	else
	{
		if (string_buffer_end == string_buffer)
		{
			yyerror("invalid unsigned integer value <%s>", string_buffer);
		}
		else
		{
			if (suffix.available)
			{
				switch (suffix.type)
				{
					case PRIMITIVE_TYPE_U8: yylval.u8 = (char unsigned)value; type = PRIMITIVE_TYPE_U8; break;
					case PRIMITIVE_TYPE_U16: yylval.u16 = (short unsigned)value; type = PRIMITIVE_TYPE_U16; break;
					case PRIMITIVE_TYPE_U32: yylval.u32 = (int unsigned)value; type = PRIMITIVE_TYPE_U32; break;
					case PRIMITIVE_TYPE_U64: yylval.u64 = (long long unsigned)value; type = PRIMITIVE_TYPE_U64; break;
					default: yyerror("invalid unsigned integer suffix <%s>", string_buffer); break;
				}
			}
			else
			{
				if (value <= UCHAR_MAX)
				{
					yylval.u8 = (char unsigned)value;
					type = PRIMITIVE_TYPE_U8;
				}
				else if (value <= USHRT_MAX)
				{
					yylval.u16 = (short unsigned)value;
					type = PRIMITIVE_TYPE_U16;
				}
				else if (value <= UINT_MAX)
				{
					yylval.u32 = (int unsigned)value;
					type = PRIMITIVE_TYPE_U32;
				}
				else if (value <= ULLONG_MAX)
				{
					yylval.u64 = (long long unsigned)value;
					type = PRIMITIVE_TYPE_U64;
				}
			}
		}
	}

	return type;
}
primitive_type_t parse_real(void)
{
	primitive_type_t type = PRIMITIVE_TYPE_NONE;

	static char string_buffer[REAL_FORMAT_BUFFER_SIZE];

	memset(string_buffer, 0, sizeof(string_buffer));

	suffix_t suffix = find_suffix('r');

	strncpy(string_buffer, yytext, yyleng - suffix.length);

	errno = 0;
	char* string_buffer_end = 0;
	double value = strtod(string_buffer, &string_buffer_end);

	if (errno == ERANGE)
	{
		yyerror("real overflow <%s>", string_buffer);
	}
	else
	{
		if (string_buffer_end == string_buffer)
		{
			yyerror("invalid real value <%s>", string_buffer);
		}
		else
		{
			if (suffix.available)
			{
				switch (suffix.type)
				{
					case PRIMITIVE_TYPE_R32: yylval.r32 = (float)value; type = PRIMITIVE_TYPE_R32; break;
					case PRIMITIVE_TYPE_R64: yylval.r64 = value; type = PRIMITIVE_TYPE_R64; break;
					default: yyerror("invalid real suffix <%s>", string_buffer); break;
				}
			}
		}
	}

	return type;
}