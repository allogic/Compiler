%option yylineno

%x MULTI_LINE_COMMENT

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

"," {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return COMMA;
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

	BEGIN(MULTI_LINE_COMMENT);
}

<MULTI_LINE_COMMENT>"\r" {
	UPDATE_CURSOR_LOCATION_CARRIAGE_RETURN();
}

<MULTI_LINE_COMMENT>"\n" {
	UPDATE_CURSOR_LOCATION_NEW_LINE();
}

<MULTI_LINE_COMMENT>. {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();
}

<MULTI_LINE_COMMENT>"*/" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();
	
	BEGIN(INITIAL);
}

[a-zA-Z_][a-zA-Z0-9_]* {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	yylval.string = string_from(yytext);

	return IDENT;
}

"\""[^"]*"\"" {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	yylval.string = string_from(yytext);

	return STR_LIT;
}

{SIGN}?{DEC_DIGITS}{SIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return lit_parse_signed_integer(0, 10);
}

{DEC_DIGITS}{UNSIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return lit_parse_unsigned_integer(0, 10);
}

{SIGN}?{HEX_PREFIX}{HEX_DIGITS}{SIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return lit_parse_signed_integer(2, 16);
}

{HEX_PREFIX}{HEX_DIGITS}{UNSIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return lit_parse_unsigned_integer(2, 16);
}

{SIGN}?{OCT_PREFIX}{OCT_DIGITS}{SIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return lit_parse_signed_integer(2, 8);
}

{OCT_PREFIX}{OCT_DIGITS}{UNSIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return lit_parse_unsigned_integer(2, 8);
}

{SIGN}?{BIN_PREFIX}{BIN_DIGITS}{SIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return lit_parse_signed_integer(2, 2);
}

{BIN_PREFIX}{BIN_DIGITS}{UNSIGNED_INTEGER_SUFFIX}? {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return lit_parse_unsigned_integer(2, 2);
}

{SIGN}?{DEC_DIGITS}({DECIMAL_POINT}{DEC_DIGITS})?({EXPONENT}{SIGN}?{DEC_DIGITS})?{REAL_SUFFIX} {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();

	return lit_parse_real();
}

. {
	UPDATE_CURSOR_LOCATION_SINGLE_LINE();
}
%%