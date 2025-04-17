# SSU_OS
> 2025학년 1학기 숭실대학교 운영체제(이길호 교수) 과제


## 과제 설명 : 총 5번의 과제가 있으며, 주어진 템플릿(xv6)에서 구현한다.

### 1. P0 : [Init](https://github.com/kangarrro/SSU_OS/tree/main/P0)
- 과제 요약: xv6 환경을 구성하고, main.c/init.c 등을 살펴본다
    - **P0-1**: shell이 실행되기 전, 자신의 이름과 학번을 출력한다.
    - **P0-2**: gdb를 이용해 fork()를 디버깅해본다.
- [과제 상세 명세](https://github.com/kangarrro/SSU_OS/tree/main/P0/README.md): 자세한 과제 요구사항을 확인할 수 있습니다.
- [상세 구현 내용](https://github.com/kangarrro/SSU_OS/tree/main/P0/solution.md): 자세한 과제해결과정을 확인할 수 있습니다.


### 2. P1 : [SystemCall](https://github.com/kangarrro/SSU_OS/tree/main/P1)
- 과제요약: set_nice(), set_nice(), ps() 총 3개의 시스템 콜을 추가로 구현한다.
  - **int set_nice(int pid, int nice)**: pid에 해당하는 프로세스의 우선순위를 nice로 설정한다.
  - **int get_nice(int pid)**: pid에 해당하는 프로세스의 우선순위를 반환한다.
  - **void ps(void)**: ps명령어와 같이 프로세스들의 정보를 콘솔에 출력한다.
- [과제 상세 명세](https://github.com/kangarrro/SSU_OS/tree/main/P1/README.md): 자세한 과제 요구사항을 확인할 수 있습니다.
- [상세 구현 내용](https://github.com/kangarrro/SSU_OS/tree/main/P1/solution.md): 자세한 과제해결과정을 확인할 수 있습니다.

### 3. P2 : [MLFQ Scheduler](https://github.com/kangarrro/SSU_OS/tree/main/P2)
- 과제 요약: 누적시간을 기반으로 한 3레벨 MLFQ스케줄러를 구현한다.
    - 누적시간이란, 프로세스가 해당 큐 레벨에서 실행된 총 시간을 의미한다.
    - 우선순위는 3가지의 상태, HIGH(0), MID(1), LOW(2)를 가지며 각각의 우선순위는 10, 20, 30 tick의 time_slice를 가진다.
    - 모든 프로세스의 우선순위는 누적시간이 해당 큐의 time_slice를 초과했을때만, 강등되며, 별도의 priority boost는 없다.
- [과제 상세 명세](https://github.com/kangarrro/SSU_OS/blob/main/P2/README.md): 자세한 과제 요구사항을 확인할 수 있습니다.
- [상세 구현 내용](https://github.com/kangarrro/SSU_OS/blob/main/P2/solution.md): 자세한 과제해결과정을 확인할 수 있습니다.

### 4. P3 : [Slab Allocator](https://github.com/kangarrro/SSU_OS/tree/main/P3)
- 과제 요약:
  - Slab allocator
- [과제 상세 명세](https://github.com/kangarrro/SSU_OS/blob/main/P3/README.md): 자세한 과제 요구사항을 확인할 수 있습니다.
- [상세 구현 내용](https://github.com/kangarrro/SSU_OS/blob/main/P3/solution.md): 자세한 과제해결과정을 확인할 수 있습니다.
### 5. P4 : [Copy-On-Write](https://github.com/kangarrro/SSU_OS/tree/main/P4)
- 과제 요약:
  - Copy-On-Write
- [과제 상세 명세](https://github.com/kangarrro/SSU_OS/blob/main/P4/README.md)
- [상세 구현 내용](https://github.com/kangarrro/SSU_OS/blob/main/P4/solution.md): 자세한 과제해결과정을 확인할 수 있습니다.