#ifndef FUNC_H
#define FUNC_H

#include "vector.h"
#include "decl.h"

typedef struct _arg_t
{
	decl_t decl;
} arg_t;

typedef struct _args_t
{
	vector_t args;
} args_t;

typedef struct _func_t
{
	decl_t decl;
	args_t args;
	vector_t exprs;
} func_t;

extern func_t func_decl(decl_t decl, vector_t* args, vector_t* exprs);
extern void func_print(func_t func, uint8_t is_last);
extern void func_free(func_t func);

#endif // FUNC_H
