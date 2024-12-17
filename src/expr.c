#include "expr.h"

expr_t expr_copy(expr_t left, expr_t right)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_COPY;

	vector_alloc(&expr.exprs, sizeof(expr_t));

	vector_push(&expr.exprs, &left);
	vector_push(&expr.exprs, &right);

	return expr;
}
expr_t expr_var(decl_t decl)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_VAR;
	expr.decl = decl;

	return expr;
}
expr_t expr_ident(string_t ident)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_IDENT;
	expr.ident = ident;

	return expr;
}
expr_t expr_string(string_t string)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_STRING;
	expr.string = string;

	return expr;
}
expr_t expr_i8(int8_t i8)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_I8;
	expr.i8 = i8;

	return expr;
}
expr_t expr_i16(int16_t i16)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_I16;
	expr.i16 = i16;

	return expr;
}
expr_t expr_i32(int32_t i32)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_I32;
	expr.i32 = i32;

	return expr;
}
expr_t expr_i64(int64_t i64)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_I64;
	expr.i64 = i64;

	return expr;
}
expr_t expr_u8(uint8_t u8)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_U8;
	expr.u8 = u8;

	return expr;
}
expr_t expr_u16(uint16_t u16)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_U16;
	expr.u16 = u16;

	return expr;
}
expr_t expr_u32(uint32_t u32)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_U32;
	expr.u32 = u32;

	return expr;
}
expr_t expr_u64(uint64_t u64)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_U64;
	expr.u64 = u64;

	return expr;
}
expr_t expr_r32(float_t r32)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_R32;
	expr.r32 = r32;

	return expr;
}
expr_t expr_r64(double_t r64)
{
	expr_t expr;

	memset(&expr, 0, sizeof(expr_t));

	expr.type = EXPR_TYPE_R64;
	expr.r64 = r64;

	return expr;
}
void expr_print(expr_t expr, uint64_t indent_count, uint64_t parent_indent_index, uint8_t has_next, uint8_t is_global, uint8_t is_last)
{
	uint64_t indent_index = 0;

	while (indent_index < indent_count)
	{
		if (is_global)
		{
			printf(" ");
		}
		else
		{
			if (has_next && indent_index == parent_indent_index)
			{
				printf("│");
			}
			else
			{
				printf(" ");
			}
		}

		indent_index++;
	}

	if (is_global == 0)
	{
		if (vector_empty(&expr.exprs))
		{
			if (is_last)
			{
				printf("└──");
			}
			else
			{
				printf("├──");
			}
		}
		else
		{
			if (has_next)
			{
				printf("├┬─");
			}
			else
			{
				printf("└┬─");
			}
		}
	}

	switch (expr.type)
	{
		case EXPR_TYPE_NONE:
		{
			printf("none\n");

			break;
		}
		case EXPR_TYPE_COPY:
		{
			printf("copy\n");

			uint64_t expr_index = 0;
			uint64_t expr_count = vector_count(&expr.exprs);

			while (expr_index < expr_count)
			{
				expr_t sub_expr = *(expr_t*)vector_at(&expr.exprs, expr_index);

				expr_print(sub_expr, indent_count + 1, parent_indent_index, has_next, 0, expr_index == (expr_count - 1));

				expr_index++;
			}

			break;
		}
		case EXPR_TYPE_VAR:
		{
			printf("var ");
			declarator_print_type(expr.decl);
			printf(" %s\n", string_buffer(&expr.decl.ident));

			break;
		}
		case EXPR_TYPE_IDENT:
		{
			printf("ident %s\n", string_buffer(&expr.ident));

			break;
		}
		case EXPR_TYPE_STRING:
		{
			printf("lit str \"%s\"\n", string_buffer(&expr.string));

			break;
		}
		case EXPR_TYPE_I8:
		{
			printf("lit i8 %d\n", expr.i8);

			break;
		}
		case EXPR_TYPE_I16:
		{
			printf("lit i16 %d\n", expr.i16);

			break;
		}
		case EXPR_TYPE_I32:
		{
			printf("lit i32 %d\n", expr.i32);

			break;
		}
		case EXPR_TYPE_I64:
		{
			printf("lit i64 %zd\n", expr.i64);

			break;
		}
		case EXPR_TYPE_U8:
		{
			printf("lit u8 %u\n", expr.u8);

			break;
		}
		case EXPR_TYPE_U16:
		{
			printf("lit u16 %u\n", expr.u16);

			break;
		}
		case EXPR_TYPE_U32:
		{
			printf("lit u32 %u\n", expr.u32);

			break;
		}
		case EXPR_TYPE_U64:
		{
			printf("lit u64 %zu\n", expr.u64);

			break;
		}
		case EXPR_TYPE_R32:
		{
			printf("lit r32 %f\n", expr.r32);

			break;
		}
		case EXPR_TYPE_R64:
		{
			printf("lit r64 %f\n", expr.r64);

			break;
		}
	}

	if (is_global && (is_last == 0))
	{
		printf("\n");
	}
}
void expr_free(expr_t expr)
{
	switch (expr.type)
	{
		case EXPR_TYPE_NONE:
		{
			break;
		}
		case EXPR_TYPE_COPY:
		{
			uint64_t expr_index = 0;
			uint64_t expr_count = vector_count(&expr.exprs);

			while (expr_index < expr_count)
			{
				expr_t sub_expr = *(expr_t*)vector_at(&expr.exprs, expr_index);

				expr_free(sub_expr);

				expr_index++;
			}

			vector_free(&expr.exprs);

			break;
		}
		case EXPR_TYPE_VAR:
		{
			break;
		}
		case EXPR_TYPE_IDENT:
		{
			string_free(&expr.ident);

			break;
		}
		case EXPR_TYPE_STRING:
		{
			string_free(&expr.string);

			break;
		}
		case EXPR_TYPE_I8:
		{
			break;
		}
		case EXPR_TYPE_I16:
		{
			break;
		}
		case EXPR_TYPE_I32:
		{
			break;
		}
		case EXPR_TYPE_I64:
		{
			break;
		}
		case EXPR_TYPE_U8:
		{
			break;
		}
		case EXPR_TYPE_U16:
		{
			break;
		}
		case EXPR_TYPE_U32:
		{
			break;
		}
		case EXPR_TYPE_U64:
		{
			break;
		}
		case EXPR_TYPE_R32:
		{
			break;
		}
		case EXPR_TYPE_R64:
		{
			break;
		}
	}
}
