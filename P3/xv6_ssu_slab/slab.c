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


static char* kzalloc(void)
{
	char *p = kalloc();
    if(p)
	memset(p, 0, PGSIZE);
return p;
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

static int slab_id_for_size(int size) {
    for (int i = 0; i < NSLAB; i++)
        if (stable.slab[i].size >= size)
            return i;
    return -1;
}

/*
	1. slab[NSLAB] 각각 초기화 + (bitmap 초기화)
*/
void slabinit()
{
    int base = 16;
    acquire(&stable.lock);
    for (int i = 0; i < NSLAB; i++) {
        struct slab *s = &stable.slab[i];
        s->bitmap = kzalloc();
        if (!s->bitmap) break;
        memset(s->page, 0, sizeof(s->page));

        s->page[0] = kzalloc();
        if (!s->page[0]) break;

        s->size = base << i;
        s->num_pages = 1;
        s->num_objects_per_page = PGSIZE / s->size;
        s->num_free_objects = s->num_objects_per_page;
        s->num_used_objects = 0;
    }
    release(&stable.lock);
}

/*
	error:
		1. slab is FULL
		2. size < 0 or > 2048
	1. size에 해당하는 slab cache 찾기
	2. 새 페이지 할당 여부 결정
		2-1: 빈 페이지 검색 후 할당
		2-2: 사용가능한 페이지 검색
	3. 빈 slab 검색 후 할당
	4. 할당된 slab의 시작주소 반환
*/
char *kmalloc(int size)
{
	struct slab *s = NULL;
	int slab_id;
	int page_idx, obj_idx;

	acquire(&stable.lock);
	
	if (size > stable.slab[NSLAB-1].size || size < 0) goto error;
	
    // 1. size -> slab cache 찾기
	if((slab_id = slab_id_for_size(size)) < 0) goto error;
	s = &stable.slab[slab_id];

	// slab full
	if (s->num_pages >= MAX_PAGES_PER_SLAB && s->num_free_objects == 0)
		goto error;

	int found = 0;
	for (page_idx = 0; page_idx < MAX_PAGES_PER_SLAB; page_idx++) {
		page_state p_state = get_page_state(s, page_idx);
		if (p_state == PAGE_EMPTY || p_state == PAGE_PARTIAL) {
			found = 1;
			break;
		}
	}
	
	// 새 페이지 할당
	if (!found) {
		for (page_idx = 0; page_idx < MAX_PAGES_PER_SLAB; page_idx++) {
			if (s->page[page_idx] == NULL)
				break;
		}

		if (page_idx == MAX_PAGES_PER_SLAB) goto error;

		s->page[page_idx] = kzalloc();
		if (!s->page[page_idx]) goto error;

		s->num_pages++;
		s->num_free_objects += s->num_objects_per_page;
	}
	
	if (!s->page[page_idx]) goto error;
	// 빈 slab 검색
	int base = page_idx * s->num_objects_per_page;
	for (obj_idx = base; obj_idx < base + s->num_objects_per_page; obj_idx++)
		if (BITMAP_GET(s->bitmap, obj_idx) == 0) break;
	
	// 비트맵 설정
	BITMAP_SET(s->bitmap, obj_idx);
	// slab 할당
	s->num_free_objects--;
	s->num_used_objects++;

	// object 주소 계산	
	char *obj_addr = (char *)((uint)s->page[page_idx] + ((uint)(obj_idx % s->num_objects_per_page) * (uint)s->size));
	
	release(&stable.lock);
	return obj_addr;

error:
	// cprintf("[ERROR] kmalloc\n");
	release(&stable.lock);
	return NULL;
}


// 1. size로 slab 찾기
// 2. addr이 있는지 확인
// 3. addr로 page_idx, bit_offset 계산 ???
//      -> page(12bit), offset(20bit)
void kmfree(char *addr, int size)
{
	int slab_id;
	int page_idx, obj_idx;
	struct slab *s = NULL;
	char *page_addr = NULL;
	
	acquire(&stable.lock);
	
	if (!addr) goto done;
	if (size > stable.slab[NSLAB-1].size || size < 0) goto done;
	
    // 1. size -> slab cache 찾기
	if((slab_id = slab_id_for_size(size)) < 0) goto done;
	s = &stable.slab[slab_id];

	page_addr = (char *)((uint)addr & ~(PGSIZE - 1));
	// page_inx 검색
	for (page_idx = 0; page_idx < MAX_PAGES_PER_SLAB; page_idx++)
		if (s->page[page_idx] == page_addr) break;

	// page_addr not found
	if (page_idx == MAX_PAGES_PER_SLAB) goto done;

	// obj_idx (bitmap index)
	obj_idx = (page_idx * s->num_objects_per_page) + (((uint)addr & (uint)(PGSIZE - 1)) / s->size);

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
		s->num_free_objects -= s->num_objects_per_page;
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