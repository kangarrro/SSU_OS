#ifndef SLAB_H
#define SLAB_H

#ifndef NULL
#define NULL ((void *) 0)
#endif // NULL

#define NSLAB 8
#define MAX_PAGES_PER_SLAB 100

typedef enum page_state {
    PAGE_NOT_ALLOCATED = 0,
    PAGE_EMPTY         = 1,
    PAGE_PARTIAL       = 2,
    PAGE_FULL          = 3
} page_state;

struct slab {
    int size;
    int num_pages;
    int num_free_objects;
    int num_used_objects;
    int num_objects_per_page;
    char *bitmap;
    char *page[MAX_PAGES_PER_SLAB];
};

void slabdump();

#endif // SLAB_H