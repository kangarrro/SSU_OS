# P0 - Init
> Install XV6 & Tour XV6 source cdoe with GDB

## 과제 명세
### **P0-1** : Print Your Name!
  - XV6 boot message에 학번과 이름을 출력
  - ex)
    <pre>
    xv6...
    cpu1: starting 1
    ...
    init: starting sh
    Name : Kangarrro
    ID : 20231234
    $
    </pre>
### **P0-2** : Get the Process size with GDB
  - GDB를 이용해 프로세스의 크기를 출력
    - Breakpoint at proc.c/fork()
    - display np->sz

## Solution
### **P0-1** : Print Your Name!<br>
  - shell로 진입하는 부분을 찾아 printf추가 (user/init.c)
  - [Append your code](https://github.com/kangarrro/SSU_OS/blob/main/P0/xv6_ssu_init/user/init.c#L22)(user/init.c)
### **P0-2** : Get the Process size with GDB
  - In xv6 : make qemu-nox-gdb
  - In GDB : target remote [XV6_PORT]
  - b proc.c/fork
  - d np->sz






      - sol : user/init.c에서 printf("ID(학번) ...") // in printf.c
    - P0-2 : gdb를 이용해 proc.c/fork()의 np->sz 디버깅
      - sol : gdb를 이용해 proc.c/fork()의 np->sz 출력