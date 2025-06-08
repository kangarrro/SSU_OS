struct semaphore {
    struct spinlock lock;
    int count;
    struct proc *holder;
};

extern struct semaphore usema[NLOCK];
