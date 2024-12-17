#include "ctx.h"

ctx_t g_ctx;

void ctx_alloc(void)
{
	memset(&g_ctx, 0, sizeof(ctx_t));

	vector_alloc(&g_ctx.exprs, sizeof(expr_t));
	vector_alloc(&g_ctx.funcs, sizeof(func_t));
	vector_alloc(&g_ctx.scopes, sizeof(scope_t));
}
void ctx_push_scope(void)
{
	scope_t scope;
	
	scope_alloc(&scope);

	vector_push(&g_ctx.scopes, &scope);
}
void ctx_pop_scope(void)
{
	scope_t scope;

	vector_pop(&g_ctx.scopes, &scope);

	scope_free(&scope);
}
void ctx_push_expr(expr_t expr)
{
	vector_push(&g_ctx.exprs, &expr);
}
void ctx_push_func(func_t func)
{
	vector_push(&g_ctx.funcs, &func);
}
void ctx_insert_decl(decl_t decl)
{
	scope_t* scope = (scope_t*)vector_back(&g_ctx.scopes);
	char const* ident_buffer = string_buffer(&decl.ident);

	if (map_contains_string_key(&scope->decls, ident_buffer)) // TODO: who is owner of the string..
	{
		yyerror("duplicate identifier <%s>", ident_buffer);
	}
	else
	{
		map_insert_by_string(&scope->decls, ident_buffer, &decl);
	}
}
void ctx_remove_decl(decl_t decl)
{
	scope_t* scope = (scope_t*)vector_back(&g_ctx.scopes);
	char const* ident_buffer = string_buffer(&decl.ident);

	if (map_remove_by_string(&scope->decls, ident_buffer, &decl)) // TODO: who is owner of the string..
	{
		decl_free(&decl); // TODO
	}
	else
	{
		yyerror("undefined identifier <%s>", ident_buffer);
	}
}
void ctx_remove_arg_idents(void)
{
	/*
	uint64_t pack_index = 0;
	uint64_t pack_count = vector_count(&g_argument_pack);

	while (pack_index < pack_count)
	{
		declarator_t declarator = *(declarator_t*)vector_at(&g_argument_pack, pack_index);

		ctx_remove_identifier(declarator.identifier);

		pack_index++;
	}
	*/
}
decl_t ctx_get_decl_by_ident(string_t ident) // TODO
{
	decl_t decl;

	/*
	memset(&declarator, 0, sizeof(declarator_t));

	uint8_t declarator_exists = 0;

	uint64_t scope_index = 0;
	uint64_t scope_count = vector_count(&g_ctx.scopes);

	while (scope_index < scope_count)
	{
		scope_t* scope = (scope_t*)vector_at(&g_ctx.scopes, scope_count - scope_index - 1);

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
	*/

	return decl;
}
void ctx_print(void)
{
	uint64_t expr_index = 0;
	uint64_t expr_count = vector_count(&g_ctx.exprs);

	while (expr_index < expr_count)
	{
		expr_t expr = *(expr_t*)vector_at(&g_ctx.exprs, expr_index);

		expr_print(expr, 0, 0, 0, 1, expr_index == (expr_count - 1));

		expr_index++;
	}

	uint64_t func_index = 0;
	uint64_t func_count = vector_count(&g_ctx.funcs);

	if (func_count)
	{
		printf("\n");
	}

	while (func_index < func_count)
	{
		func_t func = *(func_t*)vector_at(&g_ctx.funcs, func_index);

		func_print(func, func_index == (func_count - 1));

		func_index++;
	}
}
void ctx_free(void)
{
	uint64_t expr_index = 0;
	uint64_t expr_count = vector_count(&g_ctx.exprs);

	while (expr_index < expr_count)
	{
		expr_t expr = *(expr_t*)vector_at(&g_ctx.exprs, expr_index);

		expr_free(expr);

		expr_index++;
	}

	uint64_t func_index = 0;
	uint64_t func_count = vector_count(&g_ctx.funcs);

	while (func_index < func_count)
	{
		func_t func = *(func_t*)vector_at(&g_ctx.funcs, func_index);

		func_free(func);

		func_index++;
	}

	vector_free(&g_ctx.exprs);
	vector_free(&g_ctx.funcs);
	vector_free(&g_ctx.scopes);

	memset(&g_ctx, 0, sizeof(ctx_t));
}
