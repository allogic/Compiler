#include "config.h"
#include "heap.h"
#include "map.h"

void map_alloc(map_t* map, uint64_t value_size)
{
	memset(map, 0, sizeof(map_t));

	map->table = (map_pair_t**)heap_alloc(MAP_INITIAL_CAPACITY * sizeof(map_pair_t*), 0);
	map->table_count = MAP_INITIAL_CAPACITY;
	map->pair_count = 0;
	map->value_size = value_size;

	memset(map->table, 0, MAP_INITIAL_CAPACITY * sizeof(map_pair_t*));
}
map_pair_t* map_pair_alloc(map_t* map, void const* key, uint64_t key_size, void const* value)
{
	map_pair_t* pair = (map_pair_t*)heap_alloc(sizeof(map_pair_t), 0);

	memset(pair, 0, sizeof(map_pair_t));

	pair->next = 0;
	pair->key = (char const*)heap_alloc(key_size, key);
	pair->value = heap_alloc(map->value_size, value);
	pair->key_size = key_size;

	return pair;
}
uint8_t map_insert(map_t* map, void const* key, uint64_t key_size, void const* value)
{
	uint8_t key_exists = 0;

	if ((((float_t)(map->pair_count + 1)) / (float_t)map->table_count) > MAP_LOAD_FACTOR)
	{
		map_expand(map);
	}

	uint64_t hash = map_compute_hash((char const*)key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];

	while (curr)
	{
		if (strncmp(curr->key, (char const*)key, MIN(curr->key_size, key_size)) == 0)
		{
			key_exists = 1;

			break;
		}

		curr = curr->next;
	}

	if (key_exists == 0)
	{
		curr = map_pair_alloc(map, key, key_size, value);

		curr->next = map->table[hash];

		map->table[hash] = curr;
		map->pair_count++;
	}

	return key_exists;
}
uint8_t map_insert_by_string(map_t* map, char const* key, void const* value)
{
	uint8_t key_exists = 0;

	if ((((float_t)(map->pair_count + 1)) / (float_t)map->table_count) > MAP_LOAD_FACTOR)
	{
		map_expand(map);
	}

	uint64_t key_size = strlen(key);
	uint64_t hash = map_compute_hash(key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];

	while (curr)
	{
		if (strncmp(curr->key, key, MIN(curr->key_size, key_size)) == 0)
		{
			key_exists = 1;

			break;
		}

		curr = curr->next;
	}

	if (key_exists == 0)
	{
		curr = map_pair_alloc(map, key, key_size, value);

		curr->next = map->table[hash];

		map->table[hash] = curr;
		map->pair_count++;
	}

	return key_exists;
}
uint8_t map_remove(map_t* map, void const* key, uint64_t key_size, void* value)
{
	uint64_t hash = map_compute_hash((char const*)key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];
	map_pair_t* prev = 0;

	while (curr)
	{
		if (strncmp(curr->key, (char const*)key, MIN(curr->key_size, key_size)) == 0)
		{
			if (prev)
			{
				prev->next = curr->next;
			}
			else
			{
				map->table[hash] = curr->next;
			}

			memcpy(value, curr->value, map->value_size);

			heap_free(curr->key);
			heap_free(curr->value);
			heap_free(curr);

			map->pair_count--;

			return 1;
		}

		prev = curr;
		curr = curr->next;
	}

	return 0;
}
uint8_t map_remove_by_string(map_t* map, char const* key, void* value)
{
	uint64_t key_size = strlen(key);
	uint64_t hash = map_compute_hash(key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];
	map_pair_t* prev = 0;

	while (curr)
	{
		if (strncmp(curr->key, key, MIN(curr->key_size, key_size)) == 0)
		{
			if (prev)
			{
				prev->next = curr->next;
			}
			else
			{
				map->table[hash] = curr->next;
			}

			memcpy(value, curr->value, map->value_size);

			heap_free(curr->key);
			heap_free(curr->value);
			heap_free(curr);

			map->pair_count--;

			return 1;
		}

		prev = curr;
		curr = curr->next;
	}

	return 0;
}
void* map_at(map_t* map, void const* key, uint64_t key_size)
{
	uint64_t hash = map_compute_hash((char const*)key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];

	while (curr)
	{
		if (strncmp(curr->key, (char const*)key, MIN(curr->key_size, key_size)) == 0)
		{
			return curr->value;
		}

		curr = curr->next;
	}

	return 0;
}
void* map_at_by_string(map_t* map, char const* key)
{
	uint64_t key_size = strlen(key);
	uint64_t hash = map_compute_hash(key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];

	while (curr)
	{
		if (strncmp(curr->key, key, MIN(curr->key_size, key_size)) == 0)
		{
			return curr->value;
		}

		curr = curr->next;
	}

	return 0;
}
map_pair_t* map_get_pair(map_t* map, uint64_t index)
{
	return map->table[index];
}
uint8_t map_contains_key(map_t* map, void const* key, uint64_t key_size)
{
	uint64_t hash = map_compute_hash(key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];

	while (curr)
	{
		if (strncmp(curr->key, (char const*)key, MIN(curr->key_size, key_size)) == 0)
		{
			return 1;
		}

		curr = curr->next;
	}

	return 0;
}
uint8_t map_contains_string_key(map_t* map, char const* key)
{
	uint64_t key_size = strlen(key);
	uint64_t hash = map_compute_hash(key, key_size, map->table_count);

	map_pair_t* curr = map->table[hash];

	while (curr)
	{
		if (strncmp(curr->key, key, MIN(curr->key_size, key_size)) == 0)
		{
			return 1;
		}

		curr = curr->next;
	}

	return 0;
}
uint64_t map_count(map_t* map)
{
	return map->table_count;
}
void map_expand(map_t* map)
{
	uint64_t table_index = 0;
	uint64_t new_table_count = map->table_count * 2;

	map_pair_t** new_table = (map_pair_t**)heap_alloc(new_table_count * sizeof(map_pair_t*), 0);

	memset(new_table, 0, new_table_count * sizeof(map_pair_t*));

	while (table_index < map->table_count)
	{
		map_pair_t* curr = map->table[table_index];

		while (curr)
		{
			uint64_t hash = map_compute_hash(curr->key, curr->key_size, new_table_count);

			curr->next = new_table[hash];
			new_table[hash] = curr;

			curr = curr->next;
		}

		table_index++;
	}

	heap_free(map->table);

	map->table = new_table;
	map->table_count = new_table_count;
}
void map_free(map_t* map)
{
	uint64_t table_index = 0;

	while (table_index < map->table_count)
	{
		map_pair_t* curr = map->table[table_index];

		while (curr)
		{
			map_pair_t* tmp = curr;
			curr = curr->next;

			heap_free(tmp->key);
			heap_free(tmp->value);
			heap_free(tmp);
		}

		table_index++;
	}

	heap_free(map->table);
}
uint64_t map_compute_hash(char const* key, uint64_t key_size, uint64_t modulus)
{
	uint64_t hash = MAP_INITIAL_HASH;
	uint64_t key_index = 0;

	while (key_index < key_size)
	{
		hash = ((hash << 5) + hash) + key[key_index];
		key_index++;
	}

	return hash % modulus;
}
