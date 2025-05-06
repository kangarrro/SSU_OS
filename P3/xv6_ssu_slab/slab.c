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


// bitmap을 순회하며 Page의 상태를 반환하는 함수
static page_state get_page_state(struct slab *s, int page_index)
{
	int byte_index, bit_index;
	int obj_per_page = s->num_objects_per_page;
	int count = 0;

	int base = page_index * obj_per_page;
	for (int i = 0; i < obj_per_page; i++) {
		byte_index = (base + i) / 8;
		bit_index = (base + i) % 8;
		if (s->bitmap[byte_index] & (1 << bit_index))
			count++;
	}

	if (s->page[page_index]) {     // page 존재
		if (count == 0)
			return PAGE_EMPTY;
		else if (count == obj_per_page) // 꽉찬 Page
			return PAGE_FULL;
		else                       // 사용가능한 Page
			return PAGE_AVAILABLE;
	} else {                       // page 존재 x
		return PAGE_NOT_ALLOCATED;
	}
}

/*
	1. slab[NSLAB] 각각 초기화 + (bitmap 초기화)
*/
void slabinit()
{
	int base_size = 16;
	int size;

	acquire(&stable.lock);
	for (int i=0; i<NSLAB; i++) {
		// bitmap 초기화
		stable.slab[i].bitmap = kalloc();
		if (!stable.slab[i].bitmap) goto done;

		memset(stable.slab[i].bitmap, 0, PGSIZE);
		
		// *page 초기화
		for (int j = 0; j < MAX_PAGES_PER_SLAB; j++)
			stable.slab[i].page[j] = NULL;

		// 첫 page 할당
		stable.slab[i].page[0] = kalloc();
		if (!stable.slab[i].page[0]) goto done;

		size = base_size << i;
		// stable.slab[] 초기화
		stable.slab[i].size = size;
		stable.slab[i].num_objects_per_page = PGSIZE / size;
		
		stable.slab[i].num_pages = 1;
		stable.slab[i].num_free_objects = stable.slab[i].num_objects_per_page;
		stable.slab[i].num_used_objects = 0;
		cprintf("[init] i: %d, size: %d", i, stable.slab[i].size);
		cprintf(", n_page: %d, n_free: %d\n", stable.slab[i].num_pages, stable.slab[i].num_free_objects);
	}
done:
	release(&stable.lock);
}

/*
	error:
		1. slab is FULL
		2. 
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
	for (slab_id = 0; slab_id < NSLAB-1; slab_id++) {
		if (stable.slab[slab_id].size >= size) break;
	}
	s = &stable.slab[slab_id];

	if (s->num_pages >= MAX_PAGES_PER_SLAB && s->num_free_objects == 0)
		goto error;

	int found = 0;
	for (page_idx = 0; page_idx < MAX_PAGES_PER_SLAB; page_idx++) {
		if (get_page_state(s, page_idx) == PAGE_AVAILABLE || get_page_state(s, page_idx) == PAGE_EMPTY) {
			found = 1;
			break;
		}
	}

	if (!found) {
		// 새 페이지 할당
		for (page_idx = 0; page_idx < MAX_PAGES_PER_SLAB; page_idx++) {
			if (s->page[page_idx] == NULL)
				break;
		}

		////////////////// ?????????????????????????????????????????????????????????????????????????
		if (page_idx == MAX_PAGES_PER_SLAB) {
			// cprintf("[kmalloc] ERROR: no room for new page in slab_id=%d\n", slab_id);
			goto error;
		}

		s->page[page_idx] = kalloc();
		if (!s->page[page_idx]) goto error;

		s->num_pages++;
		s->num_free_objects += s->num_objects_per_page;
	}
	
	if (!s->page[page_idx]) goto error;
	// 빈 slab 검색
	int base = page_idx * s->num_objects_per_page;
	for (obj_idx = base; obj_idx < base + s->num_objects_per_page; obj_idx++)
		if ((s->bitmap[obj_idx / 8] & (1 << (obj_idx % 8))) == 0) break;
	
	// 비트맵 설정
	s->bitmap[obj_idx / 8] |= (1 << (obj_idx % 8));
	
	// slab 할당
	s->num_free_objects--;
	s->num_used_objects++;

	// object 주소 계산	
	char *obj_addr = (char *)((uint)s->page[page_idx] + ((uint)(obj_idx % s->num_objects_per_page) * (uint)s->size));
	
	// cprintf("alloc: id=%d ", slab_id);
	// cprintf("[kmalloc] s->page[%d] = %p\n", page_idx, s->page[page_idx]);
	
	// cprintf("[kmalloc] n_page: %d, n_free: %d", s->num_pages, s->num_free_objects);
	// cprintf(", addr=%p\n", obj_addr);
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
	struct slab *s = NULL;
	char *page_addr = NULL;
	int slab_id;
	int page_idx, obj_idx;
	
	acquire(&stable.lock);
	
	if (!addr) goto done;
	if (size > stable.slab[NSLAB-1].size || size < 0) goto done;
	
    // 1. size -> slab cache 찾기
	for (slab_id = 0; slab_id < NSLAB-1; slab_id++) {
		if (stable.slab[slab_id].size >= size) break;
	}
	s = &stable.slab[slab_id];

	page_addr = (char *)((uint)addr & ~(PGSIZE - 1));
	// page_inx 검색
	for (page_idx = 0; page_idx < MAX_PAGES_PER_SLAB; page_idx++)
		if (s->page[page_idx] == page_addr) break;

	if (page_idx == MAX_PAGES_PER_SLAB) {
		// cprintf("[kmfree] ERROR: page not found for address %p\n", addr);
		goto done;
	}

	// obj_idx
	obj_idx = (page_idx * s->num_objects_per_page) + (((uint)addr - (uint)page_addr) / s->size);
	
	if (!(s->bitmap[obj_idx / 8] & (1 << obj_idx % 8))) goto done;

	if (obj_idx >= s->num_objects_per_page * MAX_PAGES_PER_SLAB) {
		cprintf("[kmfree] ERROR: invalid object index %d\n", obj_idx);
		goto done;
	}
	
	s->bitmap[obj_idx / 8] &= ~(1 << (obj_idx % 8));
	
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
	// cprintf("[kmfree] n_page: %d, n_free: %d", s->num_pages, s->num_free_objects);
	// cprintf(", addr=%p\n", addr);
	release(&stable.lock);
	return;
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
