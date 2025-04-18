# X86 (IA-32) Registers
> 컴퓨터구조를 ARM으로 배운 나를 위한 X86 레지스터 정리

### 범용 레지스터 (General Purpose Registers)
|32-bit|16-bit|8-bit|용도|
|:----:|:----:|:---:|:-:|
|EAX   |AX    |AH/AL|누산기(accumulator), 함수반환값|
|EBX   |BX    |BH/BL|베이스 주소|
|ECX   |CX    |CH/CL|카운터(loop, shift 등)|
|EDX   |DX    |DH/DL|곱셈/나눗셈 보조, I/O 포트접근 등|
|ESI   |SI    |none |Source Index(문자열 연산 등)|
|EDI   |DI    |none |Destination Index|
|EBP   |BP    |node |Base Pointer(함수 프레임 기준점)|
|ESP   |SP    |none |Stacp Pointer(스택 최상단)|


### 명령어 관련 레지스터
|이름|설명|
|:-:|:-:|
|EIP|Instruction Pointer(다음에 실행할 명령어 주소)|
|EFLAGS|상태플래그(Zero, Carry, Sign, Overflow 등)|

- 주요 플래그 비트(EFLAGS)
  |비트 위치|이름|설명|
  |:-----:|:-:|:-:|
  |0|CF(Carry Flag)|자리올림, 자리내림|
  |2|PF(Parity Flag)|결과 패리티|
  |6|ZF(Zero Flag)|0인지|
  |7|SF(Sign Flag)|부호|
  |9|IF(Interupt Flag)|인터럽트 허용 여부|
  |11|OF(Overflow Flag)|부호 오버플로우|


### 세그먼트 레지스터 (Segment Registers)
|이름|설명|
|:-:|:-:|
|CS|Code Segment|
|DS|Data Segment|
|SS|Stack Segment|
|ES|Extra Segment(문자열 명령어 등에서 사용)|
|FS, GS|보조 세그먼트(TLS, 커널데이터 등에서 사용)|

### 제어 레지스터 (Control Registers)
|이름|설명|
|:-:|:-:|
|CR0|시스템 동작 전반(Protection Enable, Paging 등)|
|CR2|페이지 폴트 주소 저장|
|CR3|현재 페이지 디렉터리의 물리 주소|
|CR4|고급 기능 제어(PAE, SSE, TSD 등)|

### 디버깅 레지스터 (Debig Registers)
|이름|설명|
|:-:|:-:|
|DR0~3|하드웨어 브레이크 포인트 주소|
|DR6|디버깅 상태|
|DR7|디버깅 제어|

### 시스템 레지스터
|이름|설명|
|:-:|:-:|
|GDTR, IDTR|GDT, IDT의 베이스주소와 크기|
|LDTR|Local Descriptor Table Register|
|TR|Task Register(TSS 주소)|