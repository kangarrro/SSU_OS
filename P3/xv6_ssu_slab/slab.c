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

	if (count == 0)                 // 할당되지 않은 Page
		return PAGE_EMPTY;
	else if (count == obj_per_page) // 꽉찬 Page
		return PAGE_FULL;
	else                            // 사용가능한 Page
		return PAGE_AVAILABLE;
}

/*
	1. slab[NSLAB] 각각 초기화 + (bitmap 초기화)
*/
void slabinit()
{
	int base_size = 16;
	int size;

	acquire(&stable.lock);
	// stable.slab[] 초기화
	for (int i=0; i<NSLAB; i++) {
		size = base_size << i;
		stable.slab[i].size = size;
		stable.slab[i].num_pages = 0;
		stable.slab[i].num_free_objects = 0;
		stable.slab[i].num_used_objects = 0;
		stable.slab[i].num_objects_per_page = PGSIZE / size;
		// bitmap 초기화
		stable.slab[i].bitmap = kalloc();
		memset(stable.slab[i].bitmap, 0, PGSIZE);
		// *page 초기화
		for (int j = 0; j < MAX_PAGES_PER_SLAB; j++)
			stable.slab[i].page[j] = NULL;

		cprintf("[init] i: %d, size: %d\n", i, stable.slab[i].size);
	}
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
	// if (size > stable.slab[NSLAB-1].size)
	// 	goto error;
	
    // 1. size -> slab cache 찾기
	for (slab_id = 0; slab_id < NSLAB; slab_id++) {
		if (stable.slab[slab_id].size >= size) break;
	}
	if (slab_id == NSLAB) goto error;
	s = &stable.slab[slab_id];

	// for (slab_id = NSLAB - 1; stable.slab[slab_id].size >= size; slab_id--);

	
	// if (slab_id == NSLAB)
	// 	goto error;
	s = &stable.slab[slab_id];

	// 새 Page 할당 ; (PAGE_EMPTY OR PAGE_FULL)
	if (s->num_free_objects == 0) {
		// 빈 페이지 검색
		for (page_idx = 0; page_idx < MAX_PAGES_PER_SLAB; page_idx++)
			if (s->page[page_idx] == NULL) break;
		
		// 새 페이지 할당
		s->page[page_idx] = kalloc();
		// cprintf("[kalloc] page_idx: %d, page_addr: %p\n", page_idx, s->page[page_idx]);
		if (s->page[page_idx] == NULL)
			goto error;

		s->num_pages++;
		s->num_free_objects += s->num_objects_per_page;
	}
	else { // PAGE_AVAILABLE한 PAGE 검색 (search bitmap)
		for (page_idx = 0; page_idx < MAX_PAGES_PER_SLAB; page_idx++)
			if (get_page_state(s, page_idx) == PAGE_AVAILABLE) break;
	}

	// 빈 slab 검색
	int base = page_idx * s->num_objects_per_page;
	for (obj_idx = base; obj_idx < base + s->num_objects_per_page; obj_idx++)
		if ((s->bitmap[obj_idx / 8] & (1 << (obj_idx % 8))) == 0) break;
	
	// 비트맵 설정
	s->bitmap[obj_idx / 8] |= (1 << obj_idx % 8);
	
	// slab 할당
	s->num_free_objects--;
	s->num_used_objects++;

	// object 주소 계산	
	// char *obj_addr = s->page[page_idx] + (obj_idx * s->size);
	char *obj_addr = s->page[page_idx] + ((obj_idx % s->num_objects_per_page) * s->size);
	
	release(&stable.lock);
	// cprintf("alloc: id=%d ", slab_id);
	// cprintf("pg=%d idx=%d ", page_idx, obj_idx);
	// cprintf("addr=%p\n", obj_addr);
	return obj_addr;

error:
	release(&stable.lock);
	return NULL;
}

/*
	1. bitmap 확인 후, 사용중인 slab인지 확인
	2. 해당 slab memset(1) 인지 확인
	3. bitmap에서 해당 슬랩 해제
	4. slab cache(stable[]) 조정(사용중, 사용x 숫자)
*/
void kmfree(char *addr, int size)
{
    // 1. size로 slab 찾기
	// 2. addr이 있는지 확인
	// 3. addr로 page_idx, bit_offset 계산 ???
	//      -> page(12bit), offset(20bit)

	struct slab *s = NULL;
	char *page_addr = NULL;
	int slab_id;
	int page_idx, obj_idx;
	
	acquire(&stable.lock);
	
	// if (size > stable.slab[NSLAB-1].size)
	// 	goto error;

	for (slab_id = 0; slab_id < NSLAB; slab_id++) {
		if (stable.slab[slab_id].size >= size) break;
	}
	if (slab_id == NSLAB) goto error;
	s = &stable.slab[slab_id];
	
	
	// page_addr = (char *)((uint)addr & 0xFFF00000);
	// obj_idx = ((uint)addr & 0x000FFFFF) / s->size;
	page_addr = (char *)((uint)addr & ~(PGSIZE - 1));
	obj_idx = ((uint)addr - (uint)page_addr) / s->size;
	if (page_addr == NULL) return;


	// s->page[]순회하며 page_idx 검색
	for (page_idx = 0; page_idx < MAX_PAGES_PER_SLAB; page_idx++)
		if (s->page[page_idx] == page_addr) break;

	// 해제
	// s->bitmap[page_idx * s->num_objects_per_page / 8] &= ~(1 << obj_idx);
	int bit_idx = page_idx * s->num_objects_per_page + obj_idx;
	s->bitmap[bit_idx / 8] &= ~(1 << (bit_idx % 8));

	s->num_free_objects++;
	s->num_used_objects--;
	
	// page가 비었으면 페이지 해제
	if (get_page_state(s, page_idx) == PAGE_EMPTY) {
		kfree(page_addr);
		s->num_pages -= 1;
		s->num_free_objects -= s->num_objects_per_page;
		s->page[page_idx] = NULL;
	}
	release(&stable.lock);
	return;

error:
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
