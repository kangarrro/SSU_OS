# P1 - System Call
> Append SystemCall

### 과제목표
 - system call을 추가해보며, xv6의 system call호출과정을 이해한다.


### 과제 명세
> proc.h/proc구조체와 system call을 테스트 하기 위한, 테스트 프로그램은 과제의 편의를 위해 교수자가 제공하였으며,<br>
> 각각 user/test_nice.c, user/test_ps.c 에서 확인할 수 있다.
1. **setnice()** 시스템 콜 추가
  - 인자로 pid, nice를 받아, pid에 해당하는 프로세스의 우선순위를 nice로 설정한다.
  - 교수자가 제공한 user/test_nice.c가 동작할 수 있도록 한다.
2. **getnice()**  시스템 콜 추가
  - 인자로 pid를 받아, pid에 해당하는 프로세스의 우선순위를 반환한다.
  - 교수자가 제공한 user/test_nice.c가 동작할 수 있도록 한다.
3. **ps()** 시스템 콜 추가
  - 모든 프로세스들의 정보(name, pid, state, priority, runtime)를 출력한다.
  - 교수자가 제공한 user/ps.c가 동작할 수 있도록 한다.

## [Solution](https://github.com/kangarrro/SSU_OS/tree/main/P0/solution.md)
  - **setnice() / getnice()** 
    - 우선순위를 설정하고, 반환하는 시스템 콜 구현
  - **P0-2** : Get the Process size with GDB
    - gdb로 접속 후 디버깅
