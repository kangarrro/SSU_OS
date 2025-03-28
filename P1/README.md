# P1 - System Calls
> Append SystemCall

### 과제 명세
- **setnice()** : 프로세스의 우선순위(nice)를 설정하는 시스템 콜 추가
  - int setnice(int pid, int nice)
  - 인자로 pid, nice를 받아, pid에 해당하는 프로세스의 우선순위를 nice로 설정
- **getnice()** : 프로세스의 우선순위(nice)를 반환하는 시스템 콜 추가
  - int getnice(int pid)
- **ps()** : 모든 프로세스들의 정보(name, pid, state, priority, runtime)을 출력하는 시스템 콜 추가
  - void ps(void)

### Solution


### Code