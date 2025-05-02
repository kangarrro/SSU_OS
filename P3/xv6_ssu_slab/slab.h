#ifndef NULL
#define NULL ((void *) 0)
#endif

#define NSLAB 8                     // {16, 32, 64, 128, 256, 512, 1024, 2048}
#define MAX_PAGES_PER_SLAB 100

struct slab {
    int size;                       // slab cache 크기
    int num_pages;                  // 사용중인 Page 수
    int num_free_objects;           // 사용가능한 slab 수
    int num_used_objects;           // 사용중인 slab 수
    int num_objects_per_page;       // 페이지 별 slab 최대 개수 (256, 128, 64, 32, 16, 8, 4, 2)
    char *bitmap;                   // bitmap (1 Page)
    char *page[MAX_PAGES_PER_SLAB]; // 사용중인 Page들의 array
};

// Page의 상태 (bitmap을 보고 확인함)
typedef enum page_state {
    PAGE_NOT_ALLOCATED = 0,
    PAGE_AVAILABLE     = 1,
    PAGE_FULL          = 2
} page_state;

void slabdump();
