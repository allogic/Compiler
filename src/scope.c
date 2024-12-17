#include "decl.h"
#include "scope.h"

void scope_alloc(scope_t* scope)
{
	memset(scope, 0, sizeof(scope_t));

	map_alloc(&scope->decls, sizeof(decl_t));
}
void scope_free(scope_t* scope)
{
	uint64_t table_index = 0;
	uint64_t table_count = map_count(&scope->decls);

	while (table_index < table_count)
	{
		map_pair_t* pair = map_get_pair(&scope->decls, table_index);

		while (pair)
		{
			decl_t decl = *(decl_t*)pair->value;

			string_free(&decl.ident);

			pair = pair->next;
		}

		table_index++;
	}

	map_free(&scope->decls);

	memset(scope, 0, sizeof(scope_t));
}
