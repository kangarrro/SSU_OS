// P2. Implement MLFQ scheduler
#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "mlfq.h"      // P2. Implement MLFQ scheduler
#include "x86.h"
#include "proc.h"
#include "spinlock.h"


// proc.c/ptable
extern struct {
    struct spinlock lock;
    struct proc proc[NPROC];
} ptable;

struct list_head mlfq_queue[MAX_PRIORITY_LEVEL];


// MLFQ QUEUE Functions
void queue_init(void)
{
    for(int i=0; i<MAX_PRIORITY_LEVEL; i++) {
        mlfq_queue[i].next = &mlfq_queue[i];
        mlfq_queue[i].prev = &mlfq_queue[i];
    }
}

// Insert process p at the end of queue
void queue_push(int level, struct proc *p)
{
    struct list_head *q = &mlfq_queue[level];
    struct list_head *entry = &p->queue_link;

    entry->next = q;
    entry->prev = q->prev;
    q->prev->next = entry;
    q->prev = entry;
    p->in_queue = 1;
}

// 현재 큐의 head 다음 위치(head->next)에 삽입
void queue_push_head(int level, struct proc *p)
{
    struct list_head *q = &mlfq_queue[level];
    struct list_head *entry = &p->queue_link;

    entry->next = q->next;
    entry->prev = q;
    q->next->prev = entry;
    q->next = entry;
    p->in_queue = 1;
}


struct proc *queue_pop(int level)
{
    struct list_head *q = &mlfq_queue[level];
    if (queue_empty(q))
        return NULL;

    struct list_head *first = q->next;
    q->next = first->next;
    first->next->prev = q;
    struct proc *p = container_of(first, struct proc, queue_link);
    p->in_queue = 0;
    return p;
}

void queue_remove(struct proc *p)
{
    struct list_head *entry = &p->queue_link;
    
    if (!p->in_queue) return;

    entry->prev->next = entry->next;
    entry->next->prev = entry->prev;

    entry->next = entry;
    entry->prev = entry;
    p->in_queue = 0;
}

// MLFQ Priority Functiosn
// void set_priority(int priority) {}
// void get_priority() {}