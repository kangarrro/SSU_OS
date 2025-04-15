// P2. Implement MLFQ scheduler

#define MAX_PRIORITY_LEVEL 3

#define TIMESLICE(priority)       \
    ((priority) == HIGH ? 100 :    \
    (priority) == MID ? 200 :      \
    (priority) == LOW ? 300 : 300)



#define queue_empty(q) ((q)->next == (q))

#define queue_head(q) ((q)->next)
    