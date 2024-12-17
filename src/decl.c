#include "decl.h"

void decl_alloc(decl_t* decl, prim_type_t type, string_t ident)
{
	memset(decl, 0, sizeof(decl_t));

	decl->type = type;
	decl->ident = string_copy(&ident);
}
void decl_print_type(decl_t decl)
{
	switch (decl.type)
	{
		case PRIM_TYPE_NONE: printf("none"); break;
		case PRIM_TYPE_I8: printf("i8"); break;
		case PRIM_TYPE_I16: printf("i16"); break;
		case PRIM_TYPE_I32: printf("i32"); break;
		case PRIM_TYPE_I64: printf("i64"); break;
		case PRIM_TYPE_U8: printf("u8"); break;
		case PRIM_TYPE_U16: printf("u16"); break;
		case PRIM_TYPE_U32: printf("u32"); break;
		case PRIM_TYPE_U64: printf("u64"); break;
		case PRIM_TYPE_R32: printf("r32"); break;
		case PRIM_TYPE_R64: printf("r64"); break;
	}
}
void decl_free(decl_t* decl)
{
	string_free(&decl->ident);
}
