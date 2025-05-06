#ifndef SLAB_H
#define SLAB_H

#ifndef NULL
#define NULL ((void *) 0)
#endif

#define NSLAB 8
#define MAX_PAGES_PER_SLAB 100

struct slab {
    int size;
    int num_pages;
    int num_free_objects;
    int num_used_objects;
    int num_objects_per_page;
    char *bitmap;
    char *page[MAX_PAGES_PER_SLAB];
};

typedef enum page_state {
    PAGE_EMPTY         = 0,
    PAGE_AVAILABLE     = 1,
    PAGE_FULL          = 2,
    PAGE_NOT_ALLOCATED = 3
} page_state;

void slabdump();

#endif // SLAB_H