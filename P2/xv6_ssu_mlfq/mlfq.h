// P2. Implement MLFQ scheduler

#define MAX_PRIORITY_LEVEL 3

#define TIMESLICE(priority)       \
    ((priority) == HIGH ? 10 :    \
    (priority) == MID ? 20 :      \
    (priority) == LOW ? 30 : 30)



#define queue_empty(q) ((q)->next == (q))

#define queue_head(q) ((q)->next)
    