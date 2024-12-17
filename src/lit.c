#include "config.h"
#include "lit.h"

suffix_t lit_find_suffix(char indicator)
{
	suffix_t suffix;

	memset(&suffix, 0, sizeof(suffix_t));

	char* string = yytext;

	while (*string++)
	{
		if (*string == indicator)
		{
			suffix.available = 1;
			suffix.offset = string - yytext;

			break;
		}
	}

	if (suffix.available)
	{
		while (*string++) suffix.length++;

		if (strncmp(yytext + suffix.offset, "i8", suffix.length) == 0) suffix.type = I8_LIT;
		else if (strncmp(yytext + suffix.offset, "i16", suffix.length) == 0) suffix.type = I16_LIT;
		else if (strncmp(yytext + suffix.offset, "i32", suffix.length) == 0) suffix.type = I32_LIT;
		else if (strncmp(yytext + suffix.offset, "i64", suffix.length) == 0) suffix.type = I64_LIT;
		else if (strncmp(yytext + suffix.offset, "u8", suffix.length) == 0) suffix.type = U8_LIT;
		else if (strncmp(yytext + suffix.offset, "u16", suffix.length) == 0) suffix.type = U16_LIT;
		else if (strncmp(yytext + suffix.offset, "u32", suffix.length) == 0) suffix.type = U32_LIT;
		else if (strncmp(yytext + suffix.offset, "u64", suffix.length) == 0) suffix.type = U64_LIT;
		else if (strncmp(yytext + suffix.offset, "r32", suffix.length) == 0) suffix.type = R32_LIT;
		else if (strncmp(yytext + suffix.offset, "r64", suffix.length) == 0) suffix.type = R64_LIT;
	}

	return suffix;
}
yytoken_kind_t lit_parse_signed_integer(uint32_t prefix_length, uint32_t base)
{
	yytoken_kind_t type = YYEMPTY;

	static char string_buffer[INTEGER_FORMAT_BUFFER_SIZE];

	memset(string_buffer, 0, sizeof(string_buffer));

	suffix_t suffix = lit_find_suffix('i');

	uint32_t sign_offset = 0;

	if ((yytext[0] == '-') || (yytext[0] == '+'))
	{
		sign_offset = 1;
		string_buffer[0] = yytext[0];
	}

	strncpy(string_buffer + sign_offset, yytext + sign_offset + prefix_length, yyleng - suffix.length - sign_offset - prefix_length);

	errno = 0;
	char* string_buffer_end = 0;
	int64_t value = strtoll(string_buffer, &string_buffer_end, base);

	if (errno == ERANGE)
	{
		yyerror("integer overflow <%s>", string_buffer);
	}
	else
	{
		if (string_buffer_end == string_buffer)
		{
			yyerror("invalid signed integer value <%s>", string_buffer);
		}
		else
		{
			if (suffix.available)
			{
				switch (suffix.type)
				{
					case I8_LIT: yylval.i8 = (int8_t)value; break;
					case I16_LIT: yylval.i16 = (int16_t)value; break;
					case I32_LIT: yylval.i32 = (int32_t)value; break;
					case I64_LIT: yylval.i64 = (int64_t)value; break;
					default: yyerror("invalid signed integer suffix <%s>", string_buffer); break;
				}

				type = suffix.type;
			}
			else
			{
				if (value >= SCHAR_MIN && value <= SCHAR_MAX)
				{
					yylval.i8 = (int8_t)value;
					type = I8_LIT;
				}
				else if (value >= SHRT_MIN && value <= SHRT_MAX)
				{
					yylval.i16 = (int16_t)value;
					type = I16_LIT;
				}
				else if (value >= INT_MIN && value <= INT_MAX)
				{
					yylval.i32 = (int32_t)value;
					type = I32_LIT;
				}
				else if (value >= LLONG_MIN && value <= LLONG_MAX)
				{
					yylval.i64 = (int64_t)value;
					type = I64_LIT;
				}
			}
		}
	}

	return type;
}
yytoken_kind_t lit_parse_unsigned_integer(uint32_t prefix_length, uint32_t base)
{
	yytoken_kind_t type = YYEMPTY;

	static char string_buffer[INTEGER_FORMAT_BUFFER_SIZE];

	memset(string_buffer, 0, sizeof(string_buffer));

	suffix_t suffix = lit_find_suffix('u');

	strncpy(string_buffer, yytext + prefix_length, yyleng - suffix.length - prefix_length);

	errno = 0;
	char* string_buffer_end = 0;
	uint64_t value = strtoull(string_buffer, &string_buffer_end, base);

	if (errno == ERANGE)
	{
		yyerror("integer overflow <%s>", string_buffer);
	}
	else
	{
		if (string_buffer_end == string_buffer)
		{
			yyerror("invalid unsigned integer value <%s>", string_buffer);
		}
		else
		{
			if (suffix.available)
			{
				switch (suffix.type)
				{
					case U8_LIT: yylval.u8 = (uint8_t)value; break;
					case U16_LIT: yylval.u16 = (uint16_t)value; break;
					case U32_LIT: yylval.u32 = (uint32_t)value; break;
					case U64_LIT: yylval.u64 = (uint64_t)value; break;
					default: yyerror("invalid unsigned integer suffix <%s>", string_buffer); break;
				}

				type = suffix.type;
			}
			else
			{
				if (value <= UCHAR_MAX)
				{
					yylval.u8 = (uint8_t)value;
					type = U8_LIT;
				}
				else if (value <= USHRT_MAX)
				{
					yylval.u16 = (uint16_t)value;
					type = U16_LIT;
				}
				else if (value <= UINT_MAX)
				{
					yylval.u32 = (uint32_t)value;
					type = U32_LIT;
				}
				else if (value <= ULLONG_MAX)
				{
					yylval.u64 = (uint64_t)value;
					type = U64_LIT;
				}
			}
		}
	}

	return type;
}
yytoken_kind_t lit_parse_real(void)
{
	yytoken_kind_t type = YYEMPTY;

	static char string_buffer[REAL_FORMAT_BUFFER_SIZE];

	memset(string_buffer, 0, sizeof(string_buffer));

	suffix_t suffix = lit_find_suffix('r');

	strncpy(string_buffer, yytext, yyleng - suffix.length);

	errno = 0;
	char* string_buffer_end = 0;
	double_t value = strtod(string_buffer, &string_buffer_end);

	if (errno == ERANGE)
	{
		yyerror("real overflow <%s>", string_buffer);
	}
	else
	{
		if (string_buffer_end == string_buffer)
		{
			yyerror("invalid real value <%s>", string_buffer);
		}
		else
		{
			if (suffix.available)
			{
				switch (suffix.type)
				{
					case R32_LIT: yylval.r32 = (float_t)value; break;
					case R64_LIT: yylval.r64 = value; break;
					default: yyerror("invalid real suffix <%s>", string_buffer); break;
				}

				type = suffix.type;
			}
		}
	}

	return type;
}
