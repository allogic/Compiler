#ifndef VECTOR_H
#define VECTOR_H

#include <stdint.h>

typedef struct _vector_t
{
	uint8_t* buffer;
	uint64_t value_size;
	uint64_t buffer_size;
	uint64_t buffer_count;
	uint64_t buffer_index;
	uint64_t buffer_offset;
} vector_t;

extern void vector_alloc(vector_t* vector, uint64_t value_size);
extern void vector_push(vector_t* vector, void const* value);
extern void vector_pop(vector_t* vector, void* value);
extern void vector_resize(vector_t* vector, uint64_t count);
extern void vector_clear(vector_t* vector);
extern void* vector_back(vector_t* vector);
extern void* vector_front(vector_t* vector);
extern void* vector_at(vector_t* vector, uint64_t index);
extern void const* vector_buffer(vector_t* vector);
extern uint8_t vector_empty(vector_t* vector);
extern uint64_t vector_count(vector_t* vector);
extern uint64_t vector_size(vector_t* vector);
extern void vector_expand(vector_t* vector);
extern void vector_free(vector_t* vector);

extern vector_t vector_from(uint64_t value_size, void const* values, uint64_t value_count);
extern vector_t vector_copy(vector_t* src);

#endif // VECTOR_H
