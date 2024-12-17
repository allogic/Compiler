#ifndef LIT_H
#define LIT_H

#include <stdint.h>
#include <limits.h>
#include <errno.h>

#include "parser.tab.h"

typedef struct _suffix_t // TODO: remove suffix..
{
	uint8_t available;
	uint32_t offset;
	uint32_t length;
	yytoken_kind_t type;
} suffix_t;

extern suffix_t lit_find_suffix(char indicator);
extern yytoken_kind_t lit_parse_signed_integer(uint32_t prefix_length, uint32_t base);
extern yytoken_kind_t lit_parse_unsigned_integer(uint32_t prefix_length, uint32_t base);
extern yytoken_kind_t lit_parse_real(void);

#endif // LIT_H
