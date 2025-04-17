# P0 (Solution)
> P0. Init 과제 해결 과정을 서술합니다.

### [과제 명세](https://github.com/kangarrro/SSU_OS/tree/main/P0/README.md): 과제명세는 이곳을 참고 해주세요.

### Solution

#### P0-1: Print your name, id in xv6 boot message
1. xv6의 부팅과정 분석
2. boot message에 printf() 추가
   - [**code**](https://github.com/kangarrro/SSU_OS/blob/main/P0/xv6_ssu_init/user/init.c#L23):
    ```C
    // user/init.c
    int main()
    {
        ...
        for(;;) {
            printf(1, "init: starting sh\n");
            printf(1, "ID: 20231759\nNAME: wooin Kim\n");
            pid = fork();
            ...
        }
    }
    ```
#### P0-2: debug "fork/np->sz"
1. xv6를 make qemu-nox-gdb로 빌드
2. gdb에서 xv6에 연결 후, proc.c/fork()에 break point 설정 후 display np->sz