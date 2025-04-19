// P2. Implement MLFQ scheduler
#define MAX_PRIORITY_LEVEL 3

enum priority_level {
    HIGH = 0,
    MID = 1,
    LOW = 2
};

enum tSlice { // time slice size (3 level)
    T_HIGH = 10,
    T_MID = 20,
    T_LOW = 30,
};

// priority에 대응되는 time slice 반환
#define TIMESLICE(priority)        \
    ((priority) == HIGH ? T_HIGH : \
    (priority) == MID ? T_MID :    \
    (priority) == LOW ? T_LOW : T_LOW)

// 큐가 비어있는지 반환
#define queue_empty(q) ((q)->next == (q))

// 큐의 가장 앞 노드를 반환
#define queue_head(q) ((q)->next)
