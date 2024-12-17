#include "heap.h"

static uint64_t s_allocated_bytes = 0;

void* heap_alloc(uint64_t size, void const* reference)
{
#ifdef _DEBUG
	uint64_t new_size = sizeof(uint64_t) + size;

	uint64_t* new_block = (uint64_t*)malloc(new_size);

	s_allocated_bytes += new_size;

	*new_block = new_size;
	new_block++;

	if (reference)
	{
		memcpy(new_block, reference, size);
	}

	return new_block;
#else
	void* new_block = malloc(size);

	if (reference)
	{
		memcpy(new_block, reference, size);
	}

	return new_block;
#endif // _DEBUG
}
void* heap_realloc(void const* block, uint64_t size)
{
#ifdef _DEBUG
	if (block)
	{
		uint64_t* old_block = (uint64_t*)block;

		old_block -= 1;

		uint64_t old_size = *old_block;
		uint64_t new_size = sizeof(uint64_t) + size;

		s_allocated_bytes -= old_size;

		uint64_t* new_block = (uint64_t*)realloc(old_block, new_size);

		s_allocated_bytes += new_size;

		*new_block = new_size;
		new_block++;

		return new_block;
	}
	else
	{
		return heap_alloc(size, 0);
	}
#else
	return realloc(block, size);
#endif // _DEBUG
}
void heap_free(void const* block)
{
#ifdef _DEBUG
	uint64_t* old_block = (uint64_t*)block;

	old_block -= 1;

	uint64_t old_size = *old_block;

	s_allocated_bytes -= old_size;

	free(old_block);
#else
	free(block);
#endif // _DEBUG
}
void heap_check_leaks(void)
{
#ifdef _DEBUG
	if (s_allocated_bytes)
	{
		printf("%zu bytes not freed\n", s_allocated_bytes);
	}
#endif // _DEBUG

	assert(s_allocated_bytes == 0);
}
