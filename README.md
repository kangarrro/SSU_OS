# SSU_OS
> 2025학년 1학기 숭실대학교 운영체제(이길호 교수) 과제


## 과제 설명 : 총 5번의 과제가 있으며, 주어진 템플릿(xv6)에서 구현한다.

1. P0 : [Init](https://github.com/kangarrro/SSU_OS/tree/main/P0)
    - P0-1 : xv6개발환경을 구축하고, 쉘이 실행되기 전, 학번과 이름을 출력
      - sol : user/init.c에서 printf("ID(학번) ...") // in printf.c
    - P0-2 : gdb를 이용해 proc.c/fork()의 np->sz 디버깅
      - sol : gdb를 이용해 proc.c/fork()의 np->sz 출력

2. P1 : [SystemCall](https://github.com/kangarrro/SSU_OS/tree/main/P1)
    - 1. setnice(pid, nice)/getnice(pid) system call 추가 : process의 priority(nice)를 설정/확인 하는 시스템콜 추가
      - sol : ptable을 순회하며 주어진 pid에 해당하는 process를 찾아, nice설정 혹은 반환하는 함수 구현
            , 이후 user.h, syscall.h, syscall.c, sysproc.c, def.h 등을 수정해 system call로 설정
      - code : [xv6_ssu_syscall/proc.c/setnice(), getnice()](https://github.com/kangarrro/SSU_OS/blob/df4a3b0b7a1f2b879cc681ad2ba6551a1c15bfed/P1/xv6_ssu_syscall/proc.c#L531)

    - 2. ps system call추가 : process table에서 모든 process정보를 출력하는 시스템콜 추가
      - sol : ptable을 순회하며, process의 정보를 출력(cprintf)
            , 이후 user.h, syscall.h, syscall.c, sysproc.c, def.h 등을 수정해 system call로 설정
      - code : [xv6_ssu_syscall/proc.c/ps()](https://github.com/kangarrro/SSU_OS/blob/main/P1/xv6_ssu_syscall/proc.c#L569)

3. P2 : [MLFQ Scheduler](https://github.com/kangarrro/SSU_OS/tree/main/P2)
    - 과제 요약: 누적시간을 기반으로 한 3레벨 MLFQ스케줄러를 구현한다.
    - 누적시간이란, 프로세스가 해당 큐 레벨에서 실행된 총 시간을 의미한다.
    - [과제 상세 명세](https://github.com/kangarrro/SSU_OS/blob/main/P2/README.md)
    - [과제 구현 코드](https://github.com/kangarrro/SSU_OS/blob/main/P2/solution.md)

4. P3 : [Slab?](https://github.com/kangarrro/SSU_OS/tree/main/P3)

5. P4 : [Copy-On-Write](https://github.com/kangarrro/SSU_OS/tree/main/P4)
