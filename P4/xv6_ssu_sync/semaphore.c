#include "types.h"
#include "defs.h"
#include "param.h"
#include "x86.h"
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"
#include "semaphore.h"


extern struct queue priority_queue[MAX_PRIO];

void sem_init(struct semaphore *s, int init_value)
{
    initlock(&s->lock, "sema");
    s->count  = init_value;
    s->holder = 0;
}

void sem_wait(struct semaphore *s)
{
    struct proc *cur = myproc();

    acquire(&s->lock);
    s->count--;

    if (s->count < 0 && s->holder && s->holder->priority > cur->priority) {
        s->holder->priority = cur->priority;
        remove_from_queue(priority_queue, s->holder);
        enqueue(priority_queue, s->holder);
    }

    if (s->count < 0) {
        sleep(s, &s->lock);
        s->holder = cur;
    } else {
        s->holder = cur;
    }

    release(&s->lock);
}

void sem_post(struct semaphore *s)
{
    struct proc *cur = myproc();

    acquire(&s->lock);

    if (cur->priority != cur->base_priority) {
        cur->priority = cur->base_priority;
        remove_from_queue(priority_queue, cur);
        enqueue(priority_queue, cur);
    }

    s->count++;
    if (s->count <= 0) {
        wakeup(s);
    }

    s->holder = 0;
    release(&s->lock);

    yield();
}

void sem_destroy(struct semaphore *s)
{
    acquire(&s->lock);
    wakeup(s);
    s->count  = 0;
    s->holder = 0;
    release(&s->lock);
}
