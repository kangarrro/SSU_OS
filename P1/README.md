# P1 - System Calls
> Append SystemCall

### 개요
 직접 system call을 추가해보며, xv6의 system call호출과정을 이해한다.
 추가할 system call은 총 3개가 있으며, 아레 명세에서 확인할 수 있다.

 proc.h/proc구조체와 system call을 테스트 하기 위한, 테스트 프로그램은 과제의 편의를 위해 교수자가 제공하였으며,<br>
 각각 proc.h/struct proc, user/test_nice.c, user/test_ps.c 에서 확인할 수 있다.

### 과제 명세

- **setnice()** : 프로세스의 우선순위(nice)를 설정하는 시스템 콜 추가
  - int setnice(int pid, int nice)
  - 인자로 pid, nice를 받아, pid에 해당하는 프로세스의 우선순위를 nice로 설정
- **getnice()** : 프로세스의 우선순위(nice)를 반환하는 시스템 콜 추가
  - int getnice(int pid)
  - 인자로 pid를 받아, pid에 해당하는 프로세스의 우선순위를 반환
- **ps()** : 모든 프로세스들의 정보(name, pid, state, priority, runtime)을 출력하는 시스템 콜 추가
  - void ps(void)
  - 모든 프로세스들(Not UNUSED)의 정보(name, pid, state, priority, runtime)를 출력

### Solution


### Code