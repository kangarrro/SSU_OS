
## 1. 큐 및 struct proc 설계

## 2. proc.c 함수들 수정
- allocproc()
    ```C
    static struct proc *allocproc(void) {
        ...
    found:
        p->state = EMBRYO;
        p->pid = nextpid++;
        // priority, proc_tick 초기화
        p->priority = HIGH;
        p->proc_tick = 0;
        p->sched_tick = 0;
        
        release(&ptable.lock);
        ...
    }

    ```

- userinit()
    ```C
    void userinit(void) {
        ...
        acquire(&ptable.lock);

        p->state = RUNNABLE;
        queue_push(p->priority, p); // 큐에 추가(p는 allocproc에 의해 초기화된 상태)

        release(&ptable.lock);
    }
    ```
- fork()
    ```C
    int fork(void) {
        ...
        acquire(&ptable.lock);
        np->priority = HIGH;
        np->proc_tick = 0;
        np->sched_tick = ticks;
        np->state = RUNNABLE;
        queue_push(np->priority, np);

        release(&ptable.lock);
        ...
    }
    ```
<!-- - wait() -->
- scheduler()
- yield()
    ```C
    void yield(void)
    {
        struct proc *p = myproc();
        acquire(&ptable.lock); // DOC: yieldlock
        p->state = RUNNABLE;
        p->proc_tick = 0;
        queue_push(p->priority, p); // priority 갱신은 trap에서
        sched();
        release(&ptable.lock);
    }
    ```
- sleep()
- wakeup1()
    ```C
    void sleep(void *chan, struct spinlock *lk) {
        ...
        p->state = SLEEPING;
        queue_remove(p); // P2. MLFQ
        sched();
        ...
    }
    ```
- kill()

## 3. trap.c 수정
- trap()

## 4. scheduler 구현