#ifndef SCOPE_H
#define SCOPE_H

#include "map.h"

typedef struct _scope_t
{
	map_t decls;
} scope_t;

extern void scope_alloc(scope_t* scope);
extern void scope_free(scope_t* scope);

#endif // SCOPE_H
