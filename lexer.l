%option yylineno

%x COMMENT

%{
#include "parser.tab.h"
%}

SIGN                    [-+]
DEC_DIGITS              [0-9]+
HEX_PREFIX              "0x"
HEX_DIGITS              [0-9a-f]+
OCT_PREFIX              "0o"
OCT_DIGITS              [0-7]+
BIN_PREFIX              "0b"
BIN_DIGITS              [01]+
EXPONENT                "e"
DECIMAL_POINT           "."
SIGNED_INTEGER_SUFFIX   "i"(8|16|32|64)
UNSIGNED_INTEGER_SUFFIX "u"(8|16|32|64)
REAL_SUFFIX             "r"(32|64)

%%
"i8" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return PRIM_TYPE_I8;
}

"i16" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return PRIM_TYPE_I16;
}

"i32" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return PRIM_TYPE_I32;
}

"i64" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return PRIM_TYPE_I64;
}

"u8" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return PRIM_TYPE_U8;
}

"u16" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return PRIM_TYPE_U16;
}

"u32" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return PRIM_TYPE_U32;
}

"u64" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return PRIM_TYPE_U64;
}

"r32" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return PRIM_TYPE_R32;
}

"r64" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return PRIM_TYPE_R64;
}

"=" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return EQUALS;
}

";" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();
	
	return SEMICOLON;
}

"(" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();
	
	return LEFT_PAREN;
}

")" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();
	
	return RIGHT_PAREN;
}

"{" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();
	
	return LEFT_BRACE;
}

"}" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();
	
	return RIGHT_BRACE;
}

"\r" {
	UPDATE_CURSOR_LOCATION_CARRIAGE_RETURN();
}

"\n" {
	UPDATE_CURSOR_LOCATION_NEW_LINE();
}

[\t ] {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();
}

"//"[^\r\n]* {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();
}

"/*" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	BEGIN(COMMENT);
}

<COMMENT>"\r" {
	UPDATE_CURSOR_LOCATION_CARRIAGE_RETURN();
}

<COMMENT>"\n" {
	UPDATE_CURSOR_LOCATION_NEW_LINE();
}

<COMMENT>. {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();
}

<COMMENT>"*/" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();
	
	BEGIN(INITIAL);
}

[a-zA-Z_][a-zA-Z0-9_]* {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	yylval.string = yytext;

	return IDENTIFIER;
}

"\""[^"]*"\"" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	yylval.string = yytext;

	return STRING_LITERAL;
}

{SIGN}?{DEC_DIGITS}{SIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	primitive_type_t type = parse_signed_integer(0, 10);

	switch (type)
	{
		case PRIMITIVE_TYPE_I8: return I8_LITERAL;
		case PRIMITIVE_TYPE_I16: return I16_LITERAL;
		case PRIMITIVE_TYPE_I32: return I32_LITERAL;
		case PRIMITIVE_TYPE_I64: return I64_LITERAL;
		default: return INVALID_LITERAL;
	}
}

{DEC_DIGITS}{UNSIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	primitive_type_t type = parse_unsigned_integer(0, 10);

	switch (type)
	{
		case PRIMITIVE_TYPE_U8: return U8_LITERAL;
		case PRIMITIVE_TYPE_U16: return U16_LITERAL;
		case PRIMITIVE_TYPE_U32: return U32_LITERAL;
		case PRIMITIVE_TYPE_U64: return U64_LITERAL;
		default: return INVALID_LITERAL;
	}
}

{SIGN}?{HEX_PREFIX}{HEX_DIGITS}{SIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	primitive_type_t type = parse_signed_integer(2, 16);

	switch (type)
	{
		case PRIMITIVE_TYPE_I8: return I8_LITERAL;
		case PRIMITIVE_TYPE_I16: return I16_LITERAL;
		case PRIMITIVE_TYPE_I32: return I32_LITERAL;
		case PRIMITIVE_TYPE_I64: return I64_LITERAL;
		default: return INVALID_LITERAL;
	}
}

{HEX_PREFIX}{HEX_DIGITS}{UNSIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	primitive_type_t type = parse_unsigned_integer(2, 16);

	switch (type)
	{
		case PRIMITIVE_TYPE_U8: return U8_LITERAL;
		case PRIMITIVE_TYPE_U16: return U16_LITERAL;
		case PRIMITIVE_TYPE_U32: return U32_LITERAL;
		case PRIMITIVE_TYPE_U64: return U64_LITERAL;
		default: return INVALID_LITERAL;
	}
}

{SIGN}?{OCT_PREFIX}{OCT_DIGITS}{SIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	primitive_type_t type = parse_signed_integer(2, 8);

	switch (type)
	{
		case PRIMITIVE_TYPE_I8: return I8_LITERAL;
		case PRIMITIVE_TYPE_I16: return I16_LITERAL;
		case PRIMITIVE_TYPE_I32: return I32_LITERAL;
		case PRIMITIVE_TYPE_I64: return I64_LITERAL;
		default: return INVALID_LITERAL;
	}
}

{OCT_PREFIX}{OCT_DIGITS}{UNSIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	primitive_type_t type = parse_unsigned_integer(2, 8);

	switch (type)
	{
		case PRIMITIVE_TYPE_U8: return U8_LITERAL;
		case PRIMITIVE_TYPE_U16: return U16_LITERAL;
		case PRIMITIVE_TYPE_U32: return U32_LITERAL;
		case PRIMITIVE_TYPE_U64: return U64_LITERAL;
		default: return INVALID_LITERAL;
	}
}

{SIGN}?{BIN_PREFIX}{BIN_DIGITS}{SIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	primitive_type_t type = parse_signed_integer(2, 2);

	switch (type)
	{
		case PRIMITIVE_TYPE_I8: return I8_LITERAL;
		case PRIMITIVE_TYPE_I16: return I16_LITERAL;
		case PRIMITIVE_TYPE_I32: return I32_LITERAL;
		case PRIMITIVE_TYPE_I64: return I64_LITERAL;
		default: return INVALID_LITERAL;
	}
}

{BIN_PREFIX}{BIN_DIGITS}{UNSIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	primitive_type_t type = parse_unsigned_integer(2, 2);

	switch (type)
	{
		case PRIMITIVE_TYPE_U8: return U8_LITERAL;
		case PRIMITIVE_TYPE_U16: return U16_LITERAL;
		case PRIMITIVE_TYPE_U32: return U32_LITERAL;
		case PRIMITIVE_TYPE_U64: return U64_LITERAL;
		default: return INVALID_LITERAL;
	}
}

{SIGN}?{DEC_DIGITS}({DECIMAL_POINT}{DEC_DIGITS})?({EXPONENT}{SIGN}?{DEC_DIGITS})?{REAL_SUFFIX} {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	primitive_type_t type = parse_real();

	switch (type)
	{
		case PRIMITIVE_TYPE_R32: return R32_LITERAL;
		case PRIMITIVE_TYPE_R64: return R64_LITERAL;
		default: return INVALID_LITERAL;
	}
}

. {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();
}
%%