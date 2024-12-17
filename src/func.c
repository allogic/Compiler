#include "expr.h"
#include "func.h"

func_t func_decl(decl_t decl, vector_t* args, vector_t* exprs)
{
	func_t func;

	memset(&func, 0, sizeof(func_t));

	func.decl = decl;
	func.args = vector_copy(args);
	func.exprs = vector_copy(exprs);

	return func;
}
void func_print(func_t func, uint8_t is_last)
{
	printf("func ");
	decl_print_type(func.decl);
	printf(" %s\n", string_buffer(&func.decl.ident));

	uint64_t arg_index = 0;
	uint64_t arg_count = vector_count(&func.args);

	while (arg_index < arg_count)
	{
		decl_t decl = *(decl_t*)vector_at(&func.args, arg_index);

		argument_print(decl, 1, 0, arg_index == (arg_count - 1));

		arg_index++;
	}

	uint64_t expr_index = 0;
	uint64_t expr_count = vector_count(&func.exprs);

	while (expr_index < expr_count)
	{
		expr_t expr = *(expr_t*)vector_at(&func.exprs, expr_index);

		expression_print(expr, 1, 1, expr_index != (expr_count - 1), 0, expr_index == (expr_count - 1)); // TODO: remove one arg..

		expr_index++;
	}

	if (is_last == 0)
	{
		printf("\n");
	}
}
void func_free(func_t func)
{
	/*
	uint64_t argument_index = 0;
	uint64_t argument_count = vector_count(&expression.arguments);

	while (argument_index < argument_count)
	{
		expression_t argument = *(expression_t*)vector_at(&expression.arguments, arg_index);

		expression_free(arg);

		arg_index++;
	}

	uint64_t child_index = 0;
	uint64_t child_count = vector_count(&expression.children);

	while (child_index < child_count)
	{
		expression_t child = *(expression_t*)vector_at(&expression.children, child_index);

		expression_free(child);

		child_index++;
	}

	vector_free(&expression.arguments);
	vector_free(&expression.children);
	*/
}
