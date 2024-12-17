#ifndef CTX_H
#define CTX_H

#include "vector.h"
#include "expr.h"
#include "decl.h"
#include "func.h"
#include "scope.h"

typedef struct _ctx_t
{
	vector_t exprs;
	vector_t funcs;
	vector_t scopes;
} ctx_t;

extern ctx_t g_ctx;

extern void ctx_alloc(void);
extern void ctx_push_scope(void);
extern void ctx_pop_scope(void);
extern void ctx_push_expr(expr_t expr);
extern void ctx_push_func(func_t func);
extern void ctx_insert_decl(decl_t decl);
extern void ctx_remove_decl(decl_t decl);
extern void ctx_remove_arg_idents(void);
extern decl_t ctx_get_decl_by_ident(string_t ident);
extern void ctx_print(void);
extern void ctx_free(void);

#endif // CTX_H
