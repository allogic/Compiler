#include "config.h"
#include "heap.h"
#include "vector.h"

void vector_alloc(vector_t* vector, uint64_t value_size)
{
	memset(vector, 0, sizeof(vector_t));

	vector->buffer = (uint8_t*)heap_alloc(value_size * VECTOR_INITIAL_CAPACITY, 0);
	vector->value_size = value_size;
	vector->buffer_size = value_size * VECTOR_INITIAL_CAPACITY;
	vector->buffer_count = VECTOR_INITIAL_CAPACITY;
	vector->buffer_index = 0;
	vector->buffer_offset = 0;
}
void vector_push(vector_t* vector, void const* value)
{
	memcpy(vector->buffer + vector->buffer_offset, value, vector->value_size);

	vector->buffer_index++;
	vector->buffer_offset += vector->value_size;

	if (vector->buffer_index >= vector->buffer_count)
	{
		vector_expand(vector);
	}
}
void vector_pop(vector_t* vector, void* value)
{
	vector->buffer_index -= 1;
	vector->buffer_offset -= vector->value_size;

	if (value)
	{
		memcpy(value, vector->buffer + vector->buffer_offset, vector->value_size);
	}

	memset(vector->buffer + vector->buffer_offset, 0, vector->value_size);
}
void vector_resize(vector_t* vector, uint64_t count)
{
	if (count > vector->buffer_count)
	{
		vector->buffer = (uint8_t*)heap_realloc(vector->buffer, count * vector->value_size);
		vector->buffer_count = count;
		vector->buffer_size = count * vector->value_size;
	}
	else if (count < vector->buffer_count)
	{
		vector->buffer = (uint8_t*)heap_realloc(vector->buffer, count * vector->value_size);
		vector->buffer_count = count;
		vector->buffer_size = count * vector->value_size;
		vector->buffer_index = MIN(vector->buffer_index, count);
		vector->buffer_offset = MIN(vector->buffer_index, count) * vector->value_size;
	}
}
void vector_clear(vector_t* vector)
{
	vector->buffer_index = 0;
	vector->buffer_offset = 0;
}
void* vector_back(vector_t* vector)
{
	return vector->buffer + vector->buffer_offset - vector->value_size;
}
void* vector_front(vector_t* vector)
{
	return vector->buffer;
}
void* vector_at(vector_t* vector, uint64_t index)
{
	return vector->buffer + (index * vector->value_size);
}
void const* vector_buffer(vector_t* vector)
{
	return (void const*)vector->buffer;
}
uint8_t vector_empty(vector_t* vector)
{
	return vector->buffer_index == 0;
}
uint64_t vector_count(vector_t* vector)
{
	return vector->buffer_index;
}
uint64_t vector_size(vector_t* vector)
{
	return vector->buffer_offset;
}
void vector_expand(vector_t* vector)
{
	uint64_t new_buffer_count = vector->buffer_count * 2;
	uint64_t new_buffer_size = vector->buffer_size * 2;

	vector->buffer = (uint8_t*)heap_realloc(vector->buffer, new_buffer_size);
	vector->buffer_count = new_buffer_count;
	vector->buffer_size = new_buffer_size;
}
void vector_free(vector_t* vector)
{
	heap_free(vector->buffer);
}
vector_t vector_from(uint64_t value_size, void const* values, uint64_t value_count)
{
	vector_t vector;

	vector_alloc(&vector, value_size);

	uint64_t value_index = 0;

	while (value_index < value_count)
	{
		vector_push(&vector, (((uint8_t*)values) + (value_index * value_size)));

		value_index++;
	}

	return vector;
}
vector_t vector_copy(vector_t* src)
{
	vector_t vector;

	memset(&vector, 0, sizeof(vector_t));

	vector.buffer = (uint8_t*)heap_alloc(src->buffer_size, src->buffer);
	vector.value_size = src->value_size;
	vector.buffer_size = src->buffer_size;
	vector.buffer_count = src->buffer_count;
	vector.buffer_index = src->buffer_index;
	vector.buffer_offset = src->buffer_offset;

	return vector;
}
