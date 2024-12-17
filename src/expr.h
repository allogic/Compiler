#ifndef EXPR_H
#define EXPR_H

#include <stdint.h>
#include <math.h>

#include "decl.h"
#include "string.h"
#include "vector.h"

typedef enum _expr_type_t
{
	EXPR_TYPE_NONE,
	EXPR_TYPE_COPY,
	EXPR_TYPE_VAR,
	EXPR_TYPE_IDENT,
	EXPR_TYPE_STRING,
	EXPR_TYPE_I8,
	EXPR_TYPE_I16,
	EXPR_TYPE_I32,
	EXPR_TYPE_I64,
	EXPR_TYPE_U8,
	EXPR_TYPE_U16,
	EXPR_TYPE_U32,
	EXPR_TYPE_U64,
	EXPR_TYPE_R32,
	EXPR_TYPE_R64
} expr_type_t;

typedef struct _expr_t
{
	expr_type_t type;
	vector_t exprs;
	decl_t decl;
	string_t ident;
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
} expr_t;

extern expr_t expr_copy(expr_t left, expr_t right);
extern expr_t expr_var(decl_t decl);
extern expr_t expr_ident(string_t ident);
extern expr_t expr_string(string_t string);
extern expr_t expr_i8(int8_t i8);
extern expr_t expr_i16(int16_t i16);
extern expr_t expr_i32(int32_t i32);
extern expr_t expr_i64(int64_t i64);
extern expr_t expr_u8(uint8_t u8);
extern expr_t expr_u16(uint16_t u16);
extern expr_t expr_u32(uint32_t u32);
extern expr_t expr_u64(uint64_t u64);
extern expr_t expr_r32(float_t r32);
extern expr_t expr_r64(double_t r64);
extern void expr_print(expr_t expr, uint64_t indent_count, uint64_t parent_indent_index, uint8_t has_next, uint8_t is_global, uint8_t is_last);
extern void expr_free(expr_t expr);

#endif // EXPR_H
