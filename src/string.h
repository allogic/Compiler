#ifndef STRING_H
#define STRING_H

#include <stdint.h>

typedef struct _string_t
{
	char* buffer;
	uint64_t buffer_length;
	uint64_t buffer_size;
} string_t;

extern void string_alloc(string_t* string);
extern void string_append(string_t* string, char const* value);
extern void string_resize(string_t* string, uint64_t size);
extern void string_clear(string_t* string);
extern char const string_at(string_t* string, uint64_t index);
extern char const* string_buffer(string_t* string);
extern uint8_t string_empty(string_t* string);
extern uint64_t string_length(string_t* string);
extern void string_expand(string_t* string);
extern void string_free(string_t* string);

extern string_t string_from(char const* value);
extern string_t string_copy(string_t* src);

#endif // STRING_H
