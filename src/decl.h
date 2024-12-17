#ifndef DECL_H
#define DECL_H

#include "prim.h"
#include "string.h"

typedef struct _decl_t
{
	prim_type_t type;
	string_t ident;
} decl_t;

extern void decl_alloc(decl_t* decl, prim_type_t type, string_t ident);
extern void decl_print_type(decl_t decl);
extern void decl_free(decl_t* decl);

#endif // DECL_H
