# P0
> Install XV6 & Tour XV^ source cdoe

### 과제 명세
- **P0-1** : Print Your Name!
  - Print your ID and Name in the xv6 boot message
  - ex) 
    xv6...
    cpu1: starting 1
    ...
    init: starting sh
    Name : Kangarrro
    ID : 20231234
    $
- **P0-2** : Get the Process size with GDB
  - Get the Process size with GDB
    Breakpoint at proc.c/fork()
    display np->sz

### Solution
- **P0-1** : Print Your Name!<br>
  - Look for sh entry point(user/init.c)
  - [Append your code]()(user/init.c)
- **P0-2** : Get the Process size with GDB
  - In xv6 : make qemu-nox-gdb
  - In GDB : target remote [XV6_PORT]
  - b proc.c/fork
  - d np->sz