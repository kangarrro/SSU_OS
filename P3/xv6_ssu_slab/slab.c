#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "spinlock.h"
#include "slab.h"     // P3. Slab Allocator


struct {
    struct spinlock lock;
    struct slab slab[NSLAB];
} stable;


static int get_slab_size(int size) {
	for (int i = 0; i < NSLAB; i++)
		if (stable.slab[i].size >= size)
			return i;
	return -1;
}

static inline int popcount8(unsigned char x) {
	x = x - ((x >> 1) & 0x55);
	x = (x & 0x33) + ((x >> 2) & 0x33);
	return (((x + (x >> 4)) & 0x0F));
}

static page_state get_page_state(struct slab *s, int page_index)
{
    if (s == NULL || s->page[page_index] == NULL) {
        return PAGE_NOT_ALLOCATED;
	}
	
	int obj_per_page = s->num_objects_per_page;
	int bit_start = page_index * obj_per_page;
	int byte_start = bit_start / 8;
	int bit_offset = bit_start % 8;

	int count = 0;
	int full_bytes = obj_per_page / 8;
	int remaining_bits = obj_per_page % 8;

	// 첫 비트가 byte 경계에 딱 맞으면 바로 계산
	if (bit_offset == 0) {
		for (int i = 0; i < full_bytes; i++) {
			count += popcount8((unsigned char)s->bitmap[byte_start + i]);
		}
		if (remaining_bits > 0) {
			unsigned char last = s->bitmap[byte_start + full_bytes];
			last &= (1 << remaining_bits) - 1;
			count += popcount8(last);
		}
	} else { // 정렬되어 있지 않으면 비트 단위로 체크
		for (int i = 0; i < obj_per_page; i++) {
			if (BITMAP_GET(s->bitmap, (bit_start + i)))
				count++;
		}
	}

	if (count == 0)
		return PAGE_EMPTY;
	else if (count == obj_per_page)
		return PAGE_FULL;
	else
		return PAGE_PARTIAL;
}

// static page_state get_page_state(struct slab *s, int page_index)
// {
// 	if (!s || !s->page[page_index])
// 		return PAGE_NOT_ALLOCATED;
	
// 	int obj_per_page = s->num_objects_per_page;
// 	int bit_start = page_index * obj_per_page;
// 	int count = 0;

// 	for (int i = 0; i < obj_per_page; i++) {
// 		if (BITMAP_GET(s->bitmap, (bit_start + i)))
// 			count++;
// 	}

// 	if (count == 0)
// 		return PAGE_EMPTY;
// 	else if (count == obj_per_page)
// 		return PAGE_FULL;
// 	else
// 		return PAGE_PARTIAL;
// }


void slabinit()
{
    int base = 16;
    acquire(&stable.lock);
    for (int i = 0; i < NSLAB; i++) {
        struct slab *s = &stable.slab[i];
        s->bitmap = kalloc();
        if (!s->bitmap) break;
		memset(s->bitmap, 0, PGSIZE);
        memset(s->page, 0, sizeof(s->page));

        s->page[0] = kalloc();
        if (!s->page[0]) break;

        s->size = base << i;
        s->num_pages = 1;
        s->num_objects_per_page = PGSIZE / s->size;
        s->num_free_objects = s->num_objects_per_page;
        s->num_used_objects = 0;
    }
    release(&stable.lock);
}


char *kmalloc(int size)
{
	int slab_id, n_obj;
	int page_idx, obj_idx;
	int null_pg_idx = -1;
	struct slab *s = NULL;

	acquire(&stable.lock);
	
	if (size > stable.slab[NSLAB-1].size || size < 0)
		goto fail;
	
    // 1. size -> slab cache 찾기
	if((slab_id = get_slab_size(size)) < 0)
		goto fail;
	
	s = &stable.slab[slab_id];
	n_obj = s->num_objects_per_page;

	// slab full
	if (s->num_pages >= MAX_PAGES_PER_SLAB && s->num_free_objects == 0)
		goto fail;

	for (page_idx = 0; page_idx < MAX_PAGES_PER_SLAB; page_idx++) {
		page_state p_state = get_page_state(s, page_idx);
		if (p_state == PAGE_EMPTY || p_state == PAGE_PARTIAL)
			break;
		else if (p_state == PAGE_NOT_ALLOCATED)
			null_pg_idx = page_idx;
	}
	
	// 새 페이지 할당
	if (page_idx == MAX_PAGES_PER_SLAB) {
		if (null_pg_idx < 0)
            goto fail;
		page_idx = null_pg_idx;
		s->page[page_idx] = kalloc();
		if (!s->page[page_idx]) goto fail;

		s->num_pages++;
		s->num_free_objects += n_obj;
	}
	
	if (!s->page[page_idx]) goto fail;
	// 빈 slab 검색
	int base = page_idx * n_obj;
	for (obj_idx = base; obj_idx < base + n_obj; obj_idx++)
		if (BITMAP_GET(s->bitmap, obj_idx) == 0) break;
	
	// 비트맵 설정
	BITMAP_SET(s->bitmap, obj_idx);
	// slab 할당
	s->num_free_objects--;
	s->num_used_objects++;

	// object 주소 계산	
	char *obj_addr = (char *)((uint)s->page[page_idx] + ((uint)(obj_idx % n_obj) * (uint)s->size));
	
	release(&stable.lock);
	return obj_addr;

fail:
	// cprintf("[ERROR] kmalloc\n");
	release(&stable.lock);
	return NULL;
}


void kmfree(char *addr, int size)
{
	int slab_id, n_obj;
	int page_idx, obj_idx;
	struct slab *s = NULL;
	char *page_addr = NULL;
	
	acquire(&stable.lock);
	
	if (!addr) goto done;
	if (size > stable.slab[NSLAB-1].size || size < 0) goto done;
	
    // 1. size -> slab cache 찾기
	if((slab_id = get_slab_size(size)) < 0) goto done;
	s = &stable.slab[slab_id];
	n_obj = s->num_objects_per_page;

	page_addr = (char *)((uint)addr & ~(PGSIZE - 1));
	// page_inx 검색
	for (page_idx = 0; page_idx < MAX_PAGES_PER_SLAB; page_idx++)
		if (s->page[page_idx] == page_addr) break;

	// page_addr not found
	if (page_idx == MAX_PAGES_PER_SLAB) goto done;

	// obj_idx (bitmap index)
	obj_idx = (page_idx * n_obj) + (((uint)addr & (uint)(PGSIZE - 1)) / s->size);

	// freed object
	if (!BITMAP_GET(s->bitmap, obj_idx)) goto done;
	
	BITMAP_CLEAR(s->bitmap, obj_idx);
	s->num_free_objects++;
	s->num_used_objects--;

	if (get_page_state(s, page_idx) == PAGE_EMPTY) {
		if (s->num_pages <= 1){
			goto done;
		}
			
		kfree(s->page[page_idx]);
		s->page[page_idx] = NULL;
		s->num_pages--;
		s->num_free_objects -= n_obj;
	}	
done:
	release(&stable.lock);
	return;
}





/* Helper functions */
void slabdump()
{
    struct slab *s;
    cprintf("__slabdump__\n");
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