#ifndef HEAP_H
#define HEAP_H

#include <stdint.h>

extern void* heap_alloc(uint64_t size, void const* reference);
extern void* heap_realloc(void const* block, uint64_t size);
extern void heap_free(void const* block);
extern void heap_check_leaks(void);

#endif // HEAP_H
