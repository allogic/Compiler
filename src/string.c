#include "config.h"
#include "heap.h"
#include "string.h"

void string_alloc(string_t* string)
{
	memset(string->buffer, 0, sizeof(string_t));

	string->buffer = (char*)heap_alloc(STRING_INITIAL_CAPACITY, 0);
	string->buffer_length = 0;
	string->buffer_size = STRING_INITIAL_CAPACITY;
}
void string_append(string_t* string, char const* value)
{
	uint64_t value_length = strlen(value);

	while ((string->buffer_length + value_length) >= string->buffer_size)
	{
		string_expand(string);
	}

	memcpy(string->buffer, value, value_length);

	string->buffer_length += value_length;
}
void string_resize(string_t* string, uint64_t size)
{
	if (size > string->buffer_size)
	{
		string->buffer = (char*)heap_realloc(string->buffer, size);
		string->buffer_size = size;
	}
	else if (size < string->buffer_size)
	{
		string->buffer = (char*)heap_realloc(string->buffer, size);
		string->buffer_size = size;
		string->buffer_length = MIN(string->buffer_length, size);
		string->buffer[string->buffer_length - 1] = 0;
	}
}
void string_clear(string_t* string)
{
	string->buffer[0] = 0;
	string->buffer_length = 0;
}
char const string_at(string_t* string, uint64_t index)
{
	return string->buffer[index];
}
char const* string_buffer(string_t* string)
{
	return (char const*)string->buffer;
}
uint8_t string_empty(string_t* string)
{
	return string->buffer_length == 0;
}
uint64_t string_length(string_t* string)
{
	return string->buffer_length;
}
void string_expand(string_t* string)
{
	uint64_t new_buffer_size = string->buffer_size * 2;

	string->buffer = (char*)heap_realloc(string->buffer, new_buffer_size);
	string->buffer_size = new_buffer_size;
}
void string_free(string_t* string)
{
	heap_free(string->buffer);

	// TODO: clear
}
string_t string_from(char const* value)
{
	string_t string;

	string_alloc(&string);
	string_append(&string, value);

	return string;
}
string_t string_copy(string_t* src)
{
	string_t string;

	memset(string.buffer, 0, sizeof(string_t));

	string.buffer = (char*)heap_alloc(src->buffer_size, src->buffer);
	string.buffer_length = src->buffer_length;
	string.buffer_size = src->buffer_size;

	return string;
}
