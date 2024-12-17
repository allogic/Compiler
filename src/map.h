#ifndef MAP_H
#define MAP_H

#include <stdint.h>
#include <math.h>

typedef struct _map_pair_t
{
	struct _map_pair_t* next;
	char const* key;
	void* value;
	uint64_t key_size;
} map_pair_t;

typedef struct _map_t
{
	map_pair_t** table;
	uint64_t table_count;
	uint64_t pair_count;
	uint64_t value_size;
} map_t;

extern void map_alloc(map_t* map, uint64_t value_size);
extern map_pair_t* map_pair_alloc(map_t* map, void const* key, uint64_t key_size, void const* value);
extern uint8_t map_insert(map_t* map, void const* key, uint64_t key_size, void const* value);
extern uint8_t map_insert_by_string(map_t* map, char const* key, void const* value);
extern uint8_t map_remove(map_t* map, void const* key, uint64_t key_size, void* value);
extern uint8_t map_remove_by_string(map_t* map, char const* key, void* value);
extern void* map_at(map_t* map, void const* key, uint64_t key_size);
extern void* map_at_by_string(map_t* map, char const* key);
extern map_pair_t* map_get_pair(map_t* map, uint64_t index);
extern uint8_t map_contains_key(map_t* map, void const* key, uint64_t key_size);
extern uint8_t map_contains_string_key(map_t* map, char const* key);
extern uint64_t map_count(map_t* map);
extern void map_expand(map_t* map);
extern void map_free(map_t* map);
extern uint64_t map_compute_hash(char const* key, uint64_t key_size, uint64_t modulus);

#endif // MAP_H
