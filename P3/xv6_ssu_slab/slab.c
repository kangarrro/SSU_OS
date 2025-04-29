#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "spinlock.h"
#include "slab.h"

struct {
    struct spinlock lock;
    struct slab slab[NSLAB];
} stable;

void slabinit()
{
    /* fill in the blank */
}

char *kmalloc(int size)
{
    /* fill in the blank */
    return 0x00;
}

void kmfree(char *addr, int size)
{
    /* fill in the blank */
}

/* Helper functions */
void slabdump()
{
    cprintf("__slabdump__\n");

    struct slab *s;

    cprintf("size\tnum_pages\tused_objects\tfree_objects\n");

    for (s = stable.slab; s < &stable.slab[NSLAB]; s++) {
        cprintf("%d\t%d\t\t%d\t\t%d\n", s->size, s->num_pages,
                s->num_used_objects, s->num_free_objects);
    }
}

int numobj_slab(int slabid)
{
    return stable.slab[slabid].num_used_objects;
}

int numpage_slab(int slabid)
{
    return stable.slab[slabid].num_pages;
}
