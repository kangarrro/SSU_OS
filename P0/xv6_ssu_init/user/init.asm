
user/_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 08             	sub    $0x8,%esp
  12:	6a 02                	push   $0x2
  14:	68 f0 06 00 00       	push   $0x6f0
  19:	e8 d0 02 00 00       	call   2ee <open>
  1e:	83 c4 10             	add    $0x10,%esp
  21:	85 c0                	test   %eax,%eax
  23:	78 1b                	js     40 <main+0x40>
  25:	83 ec 0c             	sub    $0xc,%esp
  28:	6a 00                	push   $0x0
  2a:	e8 f7 02 00 00       	call   326 <dup>
  2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  36:	e8 eb 02 00 00       	call   326 <dup>
  3b:	83 c4 10             	add    $0x10,%esp
  3e:	eb 58                	jmp    98 <main+0x98>
  40:	83 ec 04             	sub    $0x4,%esp
  43:	6a 01                	push   $0x1
  45:	6a 01                	push   $0x1
  47:	68 f0 06 00 00       	push   $0x6f0
  4c:	e8 a5 02 00 00       	call   2f6 <mknod>
  51:	83 c4 08             	add    $0x8,%esp
  54:	6a 02                	push   $0x2
  56:	68 f0 06 00 00       	push   $0x6f0
  5b:	e8 8e 02 00 00       	call   2ee <open>
  60:	83 c4 10             	add    $0x10,%esp
  63:	eb c0                	jmp    25 <main+0x25>
  65:	83 ec 08             	sub    $0x8,%esp
  68:	68 29 07 00 00       	push   $0x729
  6d:	6a 01                	push   $0x1
  6f:	e8 64 03 00 00       	call   3d8 <printf>
  74:	e8 35 02 00 00       	call   2ae <exit>
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 55 07 00 00       	push   $0x755
  81:	6a 01                	push   $0x1
  83:	e8 50 03 00 00       	call   3d8 <printf>
  88:	83 c4 10             	add    $0x10,%esp
  8b:	e8 26 02 00 00       	call   2b6 <wait>
  90:	39 c3                	cmp    %eax,%ebx
  92:	74 04                	je     98 <main+0x98>
  94:	85 c0                	test   %eax,%eax
  96:	79 e1                	jns    79 <main+0x79>
  98:	83 ec 08             	sub    $0x8,%esp
  9b:	68 f8 06 00 00       	push   $0x6f8
  a0:	6a 01                	push   $0x1
  a2:	e8 31 03 00 00       	call   3d8 <printf>
  a7:	83 c4 08             	add    $0x8,%esp
  aa:	68 0b 07 00 00       	push   $0x70b
  af:	6a 01                	push   $0x1
  b1:	e8 22 03 00 00       	call   3d8 <printf>
  b6:	e8 eb 01 00 00       	call   2a6 <fork>
  bb:	89 c3                	mov    %eax,%ebx
  bd:	83 c4 10             	add    $0x10,%esp
  c0:	85 c0                	test   %eax,%eax
  c2:	78 a1                	js     65 <main+0x65>
  c4:	85 c0                	test   %eax,%eax
  c6:	75 c3                	jne    8b <main+0x8b>
  c8:	83 ec 08             	sub    $0x8,%esp
  cb:	68 d4 09 00 00       	push   $0x9d4
  d0:	68 3c 07 00 00       	push   $0x73c
  d5:	e8 0c 02 00 00       	call   2e6 <exec>
  da:	83 c4 08             	add    $0x8,%esp
  dd:	68 3f 07 00 00       	push   $0x73f
  e2:	6a 01                	push   $0x1
  e4:	e8 ef 02 00 00       	call   3d8 <printf>
  e9:	e8 c0 01 00 00       	call   2ae <exit>

000000ee <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  ee:	55                   	push   %ebp
  ef:	89 e5                	mov    %esp,%ebp
  f1:	53                   	push   %ebx
  f2:	8b 45 08             	mov    0x8(%ebp),%eax
  f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  f8:	89 c2                	mov    %eax,%edx
  fa:	83 c1 01             	add    $0x1,%ecx
  fd:	83 c2 01             	add    $0x1,%edx
 100:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
 104:	88 5a ff             	mov    %bl,-0x1(%edx)
 107:	84 db                	test   %bl,%bl
 109:	75 ef                	jne    fa <strcpy+0xc>
    ;
  return os;
}
 10b:	5b                   	pop    %ebx
 10c:	5d                   	pop    %ebp
 10d:	c3                   	ret    

0000010e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 10e:	55                   	push   %ebp
 10f:	89 e5                	mov    %esp,%ebp
 111:	8b 4d 08             	mov    0x8(%ebp),%ecx
 114:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 117:	0f b6 01             	movzbl (%ecx),%eax
 11a:	84 c0                	test   %al,%al
 11c:	74 15                	je     133 <strcmp+0x25>
 11e:	3a 02                	cmp    (%edx),%al
 120:	75 11                	jne    133 <strcmp+0x25>
    p++, q++;
 122:	83 c1 01             	add    $0x1,%ecx
 125:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 128:	0f b6 01             	movzbl (%ecx),%eax
 12b:	84 c0                	test   %al,%al
 12d:	74 04                	je     133 <strcmp+0x25>
 12f:	3a 02                	cmp    (%edx),%al
 131:	74 ef                	je     122 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 133:	0f b6 c0             	movzbl %al,%eax
 136:	0f b6 12             	movzbl (%edx),%edx
 139:	29 d0                	sub    %edx,%eax
}
 13b:	5d                   	pop    %ebp
 13c:	c3                   	ret    

0000013d <strlen>:

uint
strlen(const char *s)
{
 13d:	55                   	push   %ebp
 13e:	89 e5                	mov    %esp,%ebp
 140:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 143:	80 39 00             	cmpb   $0x0,(%ecx)
 146:	74 12                	je     15a <strlen+0x1d>
 148:	ba 00 00 00 00       	mov    $0x0,%edx
 14d:	83 c2 01             	add    $0x1,%edx
 150:	89 d0                	mov    %edx,%eax
 152:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 156:	75 f5                	jne    14d <strlen+0x10>
    ;
  return n;
}
 158:	5d                   	pop    %ebp
 159:	c3                   	ret    
  for(n = 0; s[n]; n++)
 15a:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
 15f:	eb f7                	jmp    158 <strlen+0x1b>

00000161 <memset>:

void*
memset(void *dst, int c, uint n)
{
 161:	55                   	push   %ebp
 162:	89 e5                	mov    %esp,%ebp
 164:	57                   	push   %edi
 165:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 168:	89 d7                	mov    %edx,%edi
 16a:	8b 4d 10             	mov    0x10(%ebp),%ecx
 16d:	8b 45 0c             	mov    0xc(%ebp),%eax
 170:	fc                   	cld    
 171:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 173:	89 d0                	mov    %edx,%eax
 175:	5f                   	pop    %edi
 176:	5d                   	pop    %ebp
 177:	c3                   	ret    

00000178 <strchr>:

char*
strchr(const char *s, char c)
{
 178:	55                   	push   %ebp
 179:	89 e5                	mov    %esp,%ebp
 17b:	53                   	push   %ebx
 17c:	8b 45 08             	mov    0x8(%ebp),%eax
 17f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  for(; *s; s++)
 182:	0f b6 10             	movzbl (%eax),%edx
 185:	84 d2                	test   %dl,%dl
 187:	74 1e                	je     1a7 <strchr+0x2f>
 189:	89 d9                	mov    %ebx,%ecx
    if(*s == c)
 18b:	38 d3                	cmp    %dl,%bl
 18d:	74 15                	je     1a4 <strchr+0x2c>
  for(; *s; s++)
 18f:	83 c0 01             	add    $0x1,%eax
 192:	0f b6 10             	movzbl (%eax),%edx
 195:	84 d2                	test   %dl,%dl
 197:	74 06                	je     19f <strchr+0x27>
    if(*s == c)
 199:	38 ca                	cmp    %cl,%dl
 19b:	75 f2                	jne    18f <strchr+0x17>
 19d:	eb 05                	jmp    1a4 <strchr+0x2c>
      return (char*)s;
  return 0;
 19f:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1a4:	5b                   	pop    %ebx
 1a5:	5d                   	pop    %ebp
 1a6:	c3                   	ret    
  return 0;
 1a7:	b8 00 00 00 00       	mov    $0x0,%eax
 1ac:	eb f6                	jmp    1a4 <strchr+0x2c>

000001ae <gets>:

char*
gets(char *buf, int max)
{
 1ae:	55                   	push   %ebp
 1af:	89 e5                	mov    %esp,%ebp
 1b1:	57                   	push   %edi
 1b2:	56                   	push   %esi
 1b3:	53                   	push   %ebx
 1b4:	83 ec 1c             	sub    $0x1c,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b7:	be 00 00 00 00       	mov    $0x0,%esi
    cc = read(0, &c, 1);
 1bc:	8d 7d e7             	lea    -0x19(%ebp),%edi
  for(i=0; i+1 < max; ){
 1bf:	8d 5e 01             	lea    0x1(%esi),%ebx
 1c2:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 1c5:	7d 2b                	jge    1f2 <gets+0x44>
    cc = read(0, &c, 1);
 1c7:	83 ec 04             	sub    $0x4,%esp
 1ca:	6a 01                	push   $0x1
 1cc:	57                   	push   %edi
 1cd:	6a 00                	push   $0x0
 1cf:	e8 f2 00 00 00       	call   2c6 <read>
    if(cc < 1)
 1d4:	83 c4 10             	add    $0x10,%esp
 1d7:	85 c0                	test   %eax,%eax
 1d9:	7e 17                	jle    1f2 <gets+0x44>
      break;
    buf[i++] = c;
 1db:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1df:	8b 55 08             	mov    0x8(%ebp),%edx
 1e2:	88 44 1a ff          	mov    %al,-0x1(%edx,%ebx,1)
  for(i=0; i+1 < max; ){
 1e6:	89 de                	mov    %ebx,%esi
    if(c == '\n' || c == '\r')
 1e8:	3c 0a                	cmp    $0xa,%al
 1ea:	74 04                	je     1f0 <gets+0x42>
 1ec:	3c 0d                	cmp    $0xd,%al
 1ee:	75 cf                	jne    1bf <gets+0x11>
  for(i=0; i+1 < max; ){
 1f0:	89 de                	mov    %ebx,%esi
      break;
  }
  buf[i] = '\0';
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
 1f5:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)
  return buf;
}
 1f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1fc:	5b                   	pop    %ebx
 1fd:	5e                   	pop    %esi
 1fe:	5f                   	pop    %edi
 1ff:	5d                   	pop    %ebp
 200:	c3                   	ret    

00000201 <stat>:

int
stat(const char *n, struct stat *st)
{
 201:	55                   	push   %ebp
 202:	89 e5                	mov    %esp,%ebp
 204:	56                   	push   %esi
 205:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 206:	83 ec 08             	sub    $0x8,%esp
 209:	6a 00                	push   $0x0
 20b:	ff 75 08             	pushl  0x8(%ebp)
 20e:	e8 db 00 00 00       	call   2ee <open>
  if(fd < 0)
 213:	83 c4 10             	add    $0x10,%esp
 216:	85 c0                	test   %eax,%eax
 218:	78 24                	js     23e <stat+0x3d>
 21a:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 21c:	83 ec 08             	sub    $0x8,%esp
 21f:	ff 75 0c             	pushl  0xc(%ebp)
 222:	50                   	push   %eax
 223:	e8 de 00 00 00       	call   306 <fstat>
 228:	89 c6                	mov    %eax,%esi
  close(fd);
 22a:	89 1c 24             	mov    %ebx,(%esp)
 22d:	e8 a4 00 00 00       	call   2d6 <close>
  return r;
 232:	83 c4 10             	add    $0x10,%esp
}
 235:	89 f0                	mov    %esi,%eax
 237:	8d 65 f8             	lea    -0x8(%ebp),%esp
 23a:	5b                   	pop    %ebx
 23b:	5e                   	pop    %esi
 23c:	5d                   	pop    %ebp
 23d:	c3                   	ret    
    return -1;
 23e:	be ff ff ff ff       	mov    $0xffffffff,%esi
 243:	eb f0                	jmp    235 <stat+0x34>

00000245 <atoi>:

int
atoi(const char *s)
{
 245:	55                   	push   %ebp
 246:	89 e5                	mov    %esp,%ebp
 248:	53                   	push   %ebx
 249:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 24c:	0f b6 11             	movzbl (%ecx),%edx
 24f:	8d 42 d0             	lea    -0x30(%edx),%eax
 252:	3c 09                	cmp    $0x9,%al
 254:	77 20                	ja     276 <atoi+0x31>
  n = 0;
 256:	b8 00 00 00 00       	mov    $0x0,%eax
    n = n*10 + *s++ - '0';
 25b:	83 c1 01             	add    $0x1,%ecx
 25e:	8d 04 80             	lea    (%eax,%eax,4),%eax
 261:	0f be d2             	movsbl %dl,%edx
 264:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
  while('0' <= *s && *s <= '9')
 268:	0f b6 11             	movzbl (%ecx),%edx
 26b:	8d 5a d0             	lea    -0x30(%edx),%ebx
 26e:	80 fb 09             	cmp    $0x9,%bl
 271:	76 e8                	jbe    25b <atoi+0x16>
  return n;
}
 273:	5b                   	pop    %ebx
 274:	5d                   	pop    %ebp
 275:	c3                   	ret    
  n = 0;
 276:	b8 00 00 00 00       	mov    $0x0,%eax
  return n;
 27b:	eb f6                	jmp    273 <atoi+0x2e>

0000027d <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 27d:	55                   	push   %ebp
 27e:	89 e5                	mov    %esp,%ebp
 280:	56                   	push   %esi
 281:	53                   	push   %ebx
 282:	8b 45 08             	mov    0x8(%ebp),%eax
 285:	8b 75 0c             	mov    0xc(%ebp),%esi
 288:	8b 5d 10             	mov    0x10(%ebp),%ebx
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 28b:	85 db                	test   %ebx,%ebx
 28d:	7e 13                	jle    2a2 <memmove+0x25>
 28f:	ba 00 00 00 00       	mov    $0x0,%edx
    *dst++ = *src++;
 294:	0f b6 0c 16          	movzbl (%esi,%edx,1),%ecx
 298:	88 0c 10             	mov    %cl,(%eax,%edx,1)
 29b:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0)
 29e:	39 d3                	cmp    %edx,%ebx
 2a0:	75 f2                	jne    294 <memmove+0x17>
  return vdst;
}
 2a2:	5b                   	pop    %ebx
 2a3:	5e                   	pop    %esi
 2a4:	5d                   	pop    %ebp
 2a5:	c3                   	ret    

000002a6 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2a6:	b8 01 00 00 00       	mov    $0x1,%eax
 2ab:	cd 40                	int    $0x40
 2ad:	c3                   	ret    

000002ae <exit>:
SYSCALL(exit)
 2ae:	b8 02 00 00 00       	mov    $0x2,%eax
 2b3:	cd 40                	int    $0x40
 2b5:	c3                   	ret    

000002b6 <wait>:
SYSCALL(wait)
 2b6:	b8 03 00 00 00       	mov    $0x3,%eax
 2bb:	cd 40                	int    $0x40
 2bd:	c3                   	ret    

000002be <pipe>:
SYSCALL(pipe)
 2be:	b8 04 00 00 00       	mov    $0x4,%eax
 2c3:	cd 40                	int    $0x40
 2c5:	c3                   	ret    

000002c6 <read>:
SYSCALL(read)
 2c6:	b8 05 00 00 00       	mov    $0x5,%eax
 2cb:	cd 40                	int    $0x40
 2cd:	c3                   	ret    

000002ce <write>:
SYSCALL(write)
 2ce:	b8 10 00 00 00       	mov    $0x10,%eax
 2d3:	cd 40                	int    $0x40
 2d5:	c3                   	ret    

000002d6 <close>:
SYSCALL(close)
 2d6:	b8 15 00 00 00       	mov    $0x15,%eax
 2db:	cd 40                	int    $0x40
 2dd:	c3                   	ret    

000002de <kill>:
SYSCALL(kill)
 2de:	b8 06 00 00 00       	mov    $0x6,%eax
 2e3:	cd 40                	int    $0x40
 2e5:	c3                   	ret    

000002e6 <exec>:
SYSCALL(exec)
 2e6:	b8 07 00 00 00       	mov    $0x7,%eax
 2eb:	cd 40                	int    $0x40
 2ed:	c3                   	ret    

000002ee <open>:
SYSCALL(open)
 2ee:	b8 0f 00 00 00       	mov    $0xf,%eax
 2f3:	cd 40                	int    $0x40
 2f5:	c3                   	ret    

000002f6 <mknod>:
SYSCALL(mknod)
 2f6:	b8 11 00 00 00       	mov    $0x11,%eax
 2fb:	cd 40                	int    $0x40
 2fd:	c3                   	ret    

000002fe <unlink>:
SYSCALL(unlink)
 2fe:	b8 12 00 00 00       	mov    $0x12,%eax
 303:	cd 40                	int    $0x40
 305:	c3                   	ret    

00000306 <fstat>:
SYSCALL(fstat)
 306:	b8 08 00 00 00       	mov    $0x8,%eax
 30b:	cd 40                	int    $0x40
 30d:	c3                   	ret    

0000030e <link>:
SYSCALL(link)
 30e:	b8 13 00 00 00       	mov    $0x13,%eax
 313:	cd 40                	int    $0x40
 315:	c3                   	ret    

00000316 <mkdir>:
SYSCALL(mkdir)
 316:	b8 14 00 00 00       	mov    $0x14,%eax
 31b:	cd 40                	int    $0x40
 31d:	c3                   	ret    

0000031e <chdir>:
SYSCALL(chdir)
 31e:	b8 09 00 00 00       	mov    $0x9,%eax
 323:	cd 40                	int    $0x40
 325:	c3                   	ret    

00000326 <dup>:
SYSCALL(dup)
 326:	b8 0a 00 00 00       	mov    $0xa,%eax
 32b:	cd 40                	int    $0x40
 32d:	c3                   	ret    

0000032e <getpid>:
SYSCALL(getpid)
 32e:	b8 0b 00 00 00       	mov    $0xb,%eax
 333:	cd 40                	int    $0x40
 335:	c3                   	ret    

00000336 <sbrk>:
SYSCALL(sbrk)
 336:	b8 0c 00 00 00       	mov    $0xc,%eax
 33b:	cd 40                	int    $0x40
 33d:	c3                   	ret    

0000033e <sleep>:
SYSCALL(sleep)
 33e:	b8 0d 00 00 00       	mov    $0xd,%eax
 343:	cd 40                	int    $0x40
 345:	c3                   	ret    

00000346 <uptime>:
SYSCALL(uptime)
 346:	b8 0e 00 00 00       	mov    $0xe,%eax
 34b:	cd 40                	int    $0x40
 34d:	c3                   	ret    

0000034e <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 34e:	55                   	push   %ebp
 34f:	89 e5                	mov    %esp,%ebp
 351:	57                   	push   %edi
 352:	56                   	push   %esi
 353:	53                   	push   %ebx
 354:	83 ec 3c             	sub    $0x3c,%esp
 357:	89 c6                	mov    %eax,%esi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 359:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 35d:	74 14                	je     373 <printint+0x25>
 35f:	85 d2                	test   %edx,%edx
 361:	79 10                	jns    373 <printint+0x25>
    neg = 1;
    x = -xx;
 363:	f7 da                	neg    %edx
    neg = 1;
 365:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 36c:	bf 00 00 00 00       	mov    $0x0,%edi
 371:	eb 0b                	jmp    37e <printint+0x30>
  neg = 0;
 373:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
 37a:	eb f0                	jmp    36c <printint+0x1e>
  do{
    buf[i++] = digits[x % base];
 37c:	89 df                	mov    %ebx,%edi
 37e:	8d 5f 01             	lea    0x1(%edi),%ebx
 381:	89 d0                	mov    %edx,%eax
 383:	ba 00 00 00 00       	mov    $0x0,%edx
 388:	f7 f1                	div    %ecx
 38a:	0f b6 92 68 07 00 00 	movzbl 0x768(%edx),%edx
 391:	88 54 1d d7          	mov    %dl,-0x29(%ebp,%ebx,1)
  }while((x /= base) != 0);
 395:	89 c2                	mov    %eax,%edx
 397:	85 c0                	test   %eax,%eax
 399:	75 e1                	jne    37c <printint+0x2e>
  if(neg)
 39b:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
 39f:	74 08                	je     3a9 <printint+0x5b>
    buf[i++] = '-';
 3a1:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
 3a6:	8d 5f 02             	lea    0x2(%edi),%ebx

  while(--i >= 0)
 3a9:	83 eb 01             	sub    $0x1,%ebx
 3ac:	78 22                	js     3d0 <printint+0x82>
  write(fd, &c, 1);
 3ae:	8d 7d d7             	lea    -0x29(%ebp),%edi
 3b1:	0f b6 44 1d d8       	movzbl -0x28(%ebp,%ebx,1),%eax
 3b6:	88 45 d7             	mov    %al,-0x29(%ebp)
 3b9:	83 ec 04             	sub    $0x4,%esp
 3bc:	6a 01                	push   $0x1
 3be:	57                   	push   %edi
 3bf:	56                   	push   %esi
 3c0:	e8 09 ff ff ff       	call   2ce <write>
  while(--i >= 0)
 3c5:	83 eb 01             	sub    $0x1,%ebx
 3c8:	83 c4 10             	add    $0x10,%esp
 3cb:	83 fb ff             	cmp    $0xffffffff,%ebx
 3ce:	75 e1                	jne    3b1 <printint+0x63>
    putc(fd, buf[i]);
}
 3d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
 3d3:	5b                   	pop    %ebx
 3d4:	5e                   	pop    %esi
 3d5:	5f                   	pop    %edi
 3d6:	5d                   	pop    %ebp
 3d7:	c3                   	ret    

000003d8 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3d8:	55                   	push   %ebp
 3d9:	89 e5                	mov    %esp,%ebp
 3db:	57                   	push   %edi
 3dc:	56                   	push   %esi
 3dd:	53                   	push   %ebx
 3de:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 3e1:	8b 75 0c             	mov    0xc(%ebp),%esi
 3e4:	0f b6 1e             	movzbl (%esi),%ebx
 3e7:	84 db                	test   %bl,%bl
 3e9:	0f 84 b1 01 00 00    	je     5a0 <printf+0x1c8>
 3ef:	83 c6 01             	add    $0x1,%esi
  ap = (uint*)(void*)&fmt + 1;
 3f2:	8d 45 10             	lea    0x10(%ebp),%eax
 3f5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  state = 0;
 3f8:	bf 00 00 00 00       	mov    $0x0,%edi
 3fd:	eb 2d                	jmp    42c <printf+0x54>
 3ff:	88 5d e2             	mov    %bl,-0x1e(%ebp)
  write(fd, &c, 1);
 402:	83 ec 04             	sub    $0x4,%esp
 405:	6a 01                	push   $0x1
 407:	8d 45 e2             	lea    -0x1e(%ebp),%eax
 40a:	50                   	push   %eax
 40b:	ff 75 08             	pushl  0x8(%ebp)
 40e:	e8 bb fe ff ff       	call   2ce <write>
 413:	83 c4 10             	add    $0x10,%esp
 416:	eb 05                	jmp    41d <printf+0x45>
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 418:	83 ff 25             	cmp    $0x25,%edi
 41b:	74 22                	je     43f <printf+0x67>
 41d:	83 c6 01             	add    $0x1,%esi
  for(i = 0; fmt[i]; i++){
 420:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
 424:	84 db                	test   %bl,%bl
 426:	0f 84 74 01 00 00    	je     5a0 <printf+0x1c8>
    c = fmt[i] & 0xff;
 42c:	0f be d3             	movsbl %bl,%edx
 42f:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 432:	85 ff                	test   %edi,%edi
 434:	75 e2                	jne    418 <printf+0x40>
      if(c == '%'){
 436:	83 f8 25             	cmp    $0x25,%eax
 439:	75 c4                	jne    3ff <printf+0x27>
        state = '%';
 43b:	89 c7                	mov    %eax,%edi
 43d:	eb de                	jmp    41d <printf+0x45>
      if(c == 'd'){
 43f:	83 f8 64             	cmp    $0x64,%eax
 442:	74 59                	je     49d <printf+0xc5>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 444:	81 e2 f7 00 00 00    	and    $0xf7,%edx
 44a:	83 fa 70             	cmp    $0x70,%edx
 44d:	74 7a                	je     4c9 <printf+0xf1>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 44f:	83 f8 73             	cmp    $0x73,%eax
 452:	0f 84 9d 00 00 00    	je     4f5 <printf+0x11d>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 458:	83 f8 63             	cmp    $0x63,%eax
 45b:	0f 84 f2 00 00 00    	je     553 <printf+0x17b>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 461:	83 f8 25             	cmp    $0x25,%eax
 464:	0f 84 15 01 00 00    	je     57f <printf+0x1a7>
 46a:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
  write(fd, &c, 1);
 46e:	83 ec 04             	sub    $0x4,%esp
 471:	6a 01                	push   $0x1
 473:	8d 45 e7             	lea    -0x19(%ebp),%eax
 476:	50                   	push   %eax
 477:	ff 75 08             	pushl  0x8(%ebp)
 47a:	e8 4f fe ff ff       	call   2ce <write>
 47f:	88 5d e6             	mov    %bl,-0x1a(%ebp)
 482:	83 c4 0c             	add    $0xc,%esp
 485:	6a 01                	push   $0x1
 487:	8d 45 e6             	lea    -0x1a(%ebp),%eax
 48a:	50                   	push   %eax
 48b:	ff 75 08             	pushl  0x8(%ebp)
 48e:	e8 3b fe ff ff       	call   2ce <write>
 493:	83 c4 10             	add    $0x10,%esp
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 496:	bf 00 00 00 00       	mov    $0x0,%edi
 49b:	eb 80                	jmp    41d <printf+0x45>
        printint(fd, *ap, 10, 1);
 49d:	83 ec 0c             	sub    $0xc,%esp
 4a0:	6a 01                	push   $0x1
 4a2:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4a7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 4aa:	8b 17                	mov    (%edi),%edx
 4ac:	8b 45 08             	mov    0x8(%ebp),%eax
 4af:	e8 9a fe ff ff       	call   34e <printint>
        ap++;
 4b4:	89 f8                	mov    %edi,%eax
 4b6:	83 c0 04             	add    $0x4,%eax
 4b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 4bc:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4bf:	bf 00 00 00 00       	mov    $0x0,%edi
 4c4:	e9 54 ff ff ff       	jmp    41d <printf+0x45>
        printint(fd, *ap, 16, 0);
 4c9:	83 ec 0c             	sub    $0xc,%esp
 4cc:	6a 00                	push   $0x0
 4ce:	b9 10 00 00 00       	mov    $0x10,%ecx
 4d3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 4d6:	8b 17                	mov    (%edi),%edx
 4d8:	8b 45 08             	mov    0x8(%ebp),%eax
 4db:	e8 6e fe ff ff       	call   34e <printint>
        ap++;
 4e0:	89 f8                	mov    %edi,%eax
 4e2:	83 c0 04             	add    $0x4,%eax
 4e5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 4e8:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4eb:	bf 00 00 00 00       	mov    $0x0,%edi
 4f0:	e9 28 ff ff ff       	jmp    41d <printf+0x45>
        s = (char*)*ap;
 4f5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
 4f8:	8b 01                	mov    (%ecx),%eax
        ap++;
 4fa:	83 c1 04             	add    $0x4,%ecx
 4fd:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
        if(s == 0)
 500:	85 c0                	test   %eax,%eax
 502:	74 13                	je     517 <printf+0x13f>
        s = (char*)*ap;
 504:	89 c3                	mov    %eax,%ebx
        while(*s != 0){
 506:	0f b6 00             	movzbl (%eax),%eax
      state = 0;
 509:	bf 00 00 00 00       	mov    $0x0,%edi
        while(*s != 0){
 50e:	84 c0                	test   %al,%al
 510:	75 0f                	jne    521 <printf+0x149>
 512:	e9 06 ff ff ff       	jmp    41d <printf+0x45>
          s = "(null)";
 517:	bb 5e 07 00 00       	mov    $0x75e,%ebx
        while(*s != 0){
 51c:	b8 28 00 00 00       	mov    $0x28,%eax
  write(fd, &c, 1);
 521:	8d 7d e3             	lea    -0x1d(%ebp),%edi
 524:	89 75 d0             	mov    %esi,-0x30(%ebp)
 527:	8b 75 08             	mov    0x8(%ebp),%esi
 52a:	88 45 e3             	mov    %al,-0x1d(%ebp)
 52d:	83 ec 04             	sub    $0x4,%esp
 530:	6a 01                	push   $0x1
 532:	57                   	push   %edi
 533:	56                   	push   %esi
 534:	e8 95 fd ff ff       	call   2ce <write>
          s++;
 539:	83 c3 01             	add    $0x1,%ebx
        while(*s != 0){
 53c:	0f b6 03             	movzbl (%ebx),%eax
 53f:	83 c4 10             	add    $0x10,%esp
 542:	84 c0                	test   %al,%al
 544:	75 e4                	jne    52a <printf+0x152>
 546:	8b 75 d0             	mov    -0x30(%ebp),%esi
      state = 0;
 549:	bf 00 00 00 00       	mov    $0x0,%edi
 54e:	e9 ca fe ff ff       	jmp    41d <printf+0x45>
        putc(fd, *ap);
 553:	8b 7d d4             	mov    -0x2c(%ebp),%edi
 556:	8b 07                	mov    (%edi),%eax
 558:	88 45 e4             	mov    %al,-0x1c(%ebp)
  write(fd, &c, 1);
 55b:	83 ec 04             	sub    $0x4,%esp
 55e:	6a 01                	push   $0x1
 560:	8d 45 e4             	lea    -0x1c(%ebp),%eax
 563:	50                   	push   %eax
 564:	ff 75 08             	pushl  0x8(%ebp)
 567:	e8 62 fd ff ff       	call   2ce <write>
        ap++;
 56c:	83 c7 04             	add    $0x4,%edi
 56f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
 572:	83 c4 10             	add    $0x10,%esp
      state = 0;
 575:	bf 00 00 00 00       	mov    $0x0,%edi
 57a:	e9 9e fe ff ff       	jmp    41d <printf+0x45>
 57f:	88 5d e5             	mov    %bl,-0x1b(%ebp)
  write(fd, &c, 1);
 582:	83 ec 04             	sub    $0x4,%esp
 585:	6a 01                	push   $0x1
 587:	8d 45 e5             	lea    -0x1b(%ebp),%eax
 58a:	50                   	push   %eax
 58b:	ff 75 08             	pushl  0x8(%ebp)
 58e:	e8 3b fd ff ff       	call   2ce <write>
 593:	83 c4 10             	add    $0x10,%esp
      state = 0;
 596:	bf 00 00 00 00       	mov    $0x0,%edi
 59b:	e9 7d fe ff ff       	jmp    41d <printf+0x45>
    }
  }
}
 5a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
 5a3:	5b                   	pop    %ebx
 5a4:	5e                   	pop    %esi
 5a5:	5f                   	pop    %edi
 5a6:	5d                   	pop    %ebp
 5a7:	c3                   	ret    

000005a8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5a8:	55                   	push   %ebp
 5a9:	89 e5                	mov    %esp,%ebp
 5ab:	57                   	push   %edi
 5ac:	56                   	push   %esi
 5ad:	53                   	push   %ebx
 5ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5b1:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5b4:	a1 dc 09 00 00       	mov    0x9dc,%eax
 5b9:	eb 0c                	jmp    5c7 <free+0x1f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5bb:	8b 10                	mov    (%eax),%edx
 5bd:	39 c2                	cmp    %eax,%edx
 5bf:	77 04                	ja     5c5 <free+0x1d>
 5c1:	39 ca                	cmp    %ecx,%edx
 5c3:	77 10                	ja     5d5 <free+0x2d>
{
 5c5:	89 d0                	mov    %edx,%eax
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5c7:	39 c8                	cmp    %ecx,%eax
 5c9:	73 f0                	jae    5bb <free+0x13>
 5cb:	8b 10                	mov    (%eax),%edx
 5cd:	39 ca                	cmp    %ecx,%edx
 5cf:	77 04                	ja     5d5 <free+0x2d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5d1:	39 c2                	cmp    %eax,%edx
 5d3:	77 f0                	ja     5c5 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5d5:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5d8:	8b 10                	mov    (%eax),%edx
 5da:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5dd:	39 fa                	cmp    %edi,%edx
 5df:	74 19                	je     5fa <free+0x52>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5e1:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5e4:	8b 50 04             	mov    0x4(%eax),%edx
 5e7:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5ea:	39 f1                	cmp    %esi,%ecx
 5ec:	74 1b                	je     609 <free+0x61>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5ee:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5f0:	a3 dc 09 00 00       	mov    %eax,0x9dc
}
 5f5:	5b                   	pop    %ebx
 5f6:	5e                   	pop    %esi
 5f7:	5f                   	pop    %edi
 5f8:	5d                   	pop    %ebp
 5f9:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5fa:	03 72 04             	add    0x4(%edx),%esi
 5fd:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 600:	8b 10                	mov    (%eax),%edx
 602:	8b 12                	mov    (%edx),%edx
 604:	89 53 f8             	mov    %edx,-0x8(%ebx)
 607:	eb db                	jmp    5e4 <free+0x3c>
    p->s.size += bp->s.size;
 609:	03 53 fc             	add    -0x4(%ebx),%edx
 60c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 60f:	8b 53 f8             	mov    -0x8(%ebx),%edx
 612:	89 10                	mov    %edx,(%eax)
 614:	eb da                	jmp    5f0 <free+0x48>

00000616 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 616:	55                   	push   %ebp
 617:	89 e5                	mov    %esp,%ebp
 619:	57                   	push   %edi
 61a:	56                   	push   %esi
 61b:	53                   	push   %ebx
 61c:	83 ec 0c             	sub    $0xc,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 61f:	8b 45 08             	mov    0x8(%ebp),%eax
 622:	8d 58 07             	lea    0x7(%eax),%ebx
 625:	c1 eb 03             	shr    $0x3,%ebx
 628:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 62b:	8b 15 dc 09 00 00    	mov    0x9dc,%edx
 631:	85 d2                	test   %edx,%edx
 633:	74 20                	je     655 <malloc+0x3f>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 635:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 637:	8b 48 04             	mov    0x4(%eax),%ecx
 63a:	39 cb                	cmp    %ecx,%ebx
 63c:	76 3c                	jbe    67a <malloc+0x64>
 63e:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
 644:	be 00 10 00 00       	mov    $0x1000,%esi
 649:	0f 43 f3             	cmovae %ebx,%esi
  p = sbrk(nu * sizeof(Header));
 64c:	8d 3c f5 00 00 00 00 	lea    0x0(,%esi,8),%edi
 653:	eb 70                	jmp    6c5 <malloc+0xaf>
    base.s.ptr = freep = prevp = &base;
 655:	c7 05 dc 09 00 00 e0 	movl   $0x9e0,0x9dc
 65c:	09 00 00 
 65f:	c7 05 e0 09 00 00 e0 	movl   $0x9e0,0x9e0
 666:	09 00 00 
    base.s.size = 0;
 669:	c7 05 e4 09 00 00 00 	movl   $0x0,0x9e4
 670:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 673:	ba e0 09 00 00       	mov    $0x9e0,%edx
 678:	eb bb                	jmp    635 <malloc+0x1f>
      if(p->s.size == nunits)
 67a:	39 cb                	cmp    %ecx,%ebx
 67c:	74 1c                	je     69a <malloc+0x84>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 67e:	29 d9                	sub    %ebx,%ecx
 680:	89 48 04             	mov    %ecx,0x4(%eax)
        p += p->s.size;
 683:	8d 04 c8             	lea    (%eax,%ecx,8),%eax
        p->s.size = nunits;
 686:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 689:	89 15 dc 09 00 00    	mov    %edx,0x9dc
      return (void*)(p + 1);
 68f:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 692:	8d 65 f4             	lea    -0xc(%ebp),%esp
 695:	5b                   	pop    %ebx
 696:	5e                   	pop    %esi
 697:	5f                   	pop    %edi
 698:	5d                   	pop    %ebp
 699:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 69a:	8b 08                	mov    (%eax),%ecx
 69c:	89 0a                	mov    %ecx,(%edx)
 69e:	eb e9                	jmp    689 <malloc+0x73>
  hp->s.size = nu;
 6a0:	89 70 04             	mov    %esi,0x4(%eax)
  free((void*)(hp + 1));
 6a3:	83 ec 0c             	sub    $0xc,%esp
 6a6:	83 c0 08             	add    $0x8,%eax
 6a9:	50                   	push   %eax
 6aa:	e8 f9 fe ff ff       	call   5a8 <free>
  return freep;
 6af:	8b 15 dc 09 00 00    	mov    0x9dc,%edx
      if((p = morecore(nunits)) == 0)
 6b5:	83 c4 10             	add    $0x10,%esp
 6b8:	85 d2                	test   %edx,%edx
 6ba:	74 2b                	je     6e7 <malloc+0xd1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6bc:	8b 02                	mov    (%edx),%eax
    if(p->s.size >= nunits){
 6be:	8b 48 04             	mov    0x4(%eax),%ecx
 6c1:	39 d9                	cmp    %ebx,%ecx
 6c3:	73 b5                	jae    67a <malloc+0x64>
 6c5:	89 c2                	mov    %eax,%edx
    if(p == freep)
 6c7:	39 05 dc 09 00 00    	cmp    %eax,0x9dc
 6cd:	75 ed                	jne    6bc <malloc+0xa6>
  p = sbrk(nu * sizeof(Header));
 6cf:	83 ec 0c             	sub    $0xc,%esp
 6d2:	57                   	push   %edi
 6d3:	e8 5e fc ff ff       	call   336 <sbrk>
  if(p == (char*)-1)
 6d8:	83 c4 10             	add    $0x10,%esp
 6db:	83 f8 ff             	cmp    $0xffffffff,%eax
 6de:	75 c0                	jne    6a0 <malloc+0x8a>
        return 0;
 6e0:	b8 00 00 00 00       	mov    $0x0,%eax
 6e5:	eb ab                	jmp    692 <malloc+0x7c>
 6e7:	b8 00 00 00 00       	mov    $0x0,%eax
 6ec:	eb a4                	jmp    692 <malloc+0x7c>
