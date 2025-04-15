
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc c0 b5 10 80       	mov    $0x8010b5c0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 8b 2a 10 80       	mov    $0x80102a8b,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
    // head.next is most recently used.
    struct buf head;
} bcache;

void binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	53                   	push   %ebx
80100038:	83 ec 0c             	sub    $0xc,%esp
    struct buf *b;

    initlock(&bcache.lock, "bcache");
8010003b:	68 00 69 10 80       	push   $0x80106900
80100040:	68 c0 b5 10 80       	push   $0x8010b5c0
80100045:	e8 e3 3e 00 00       	call   80103f2d <initlock>

    // PAGEBREAK!
    //  Create linked list of buffers
    bcache.head.prev = &bcache.head;
8010004a:	c7 05 0c fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd0c
80100051:	fc 10 80 
    bcache.head.next = &bcache.head;
80100054:	c7 05 10 fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd10
8010005b:	fc 10 80 
8010005e:	83 c4 10             	add    $0x10,%esp
    for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
80100061:	bb f4 b5 10 80       	mov    $0x8010b5f4,%ebx
        b->next = bcache.head.next;
80100066:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010006b:	89 43 54             	mov    %eax,0x54(%ebx)
        b->prev = &bcache.head;
8010006e:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
        initsleeplock(&b->lock, "buffer");
80100075:	83 ec 08             	sub    $0x8,%esp
80100078:	68 07 69 10 80       	push   $0x80106907
8010007d:	8d 43 0c             	lea    0xc(%ebx),%eax
80100080:	50                   	push   %eax
80100081:	e8 9d 3d 00 00       	call   80103e23 <initsleeplock>
        bcache.head.next->prev = b;
80100086:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010008b:	89 58 50             	mov    %ebx,0x50(%eax)
        bcache.head.next = b;
8010008e:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
    for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
80100094:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010009a:	83 c4 10             	add    $0x10,%esp
8010009d:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
801000a3:	72 c1                	jb     80100066 <binit+0x32>
    }
}
801000a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801000a8:	c9                   	leave  
801000a9:	c3                   	ret    

801000aa <bread>:
    panic("bget: no buffers");
}

// Return a locked buf with the contents of the indicated block.
struct buf *bread(uint dev, uint blockno)
{
801000aa:	55                   	push   %ebp
801000ab:	89 e5                	mov    %esp,%ebp
801000ad:	57                   	push   %edi
801000ae:	56                   	push   %esi
801000af:	53                   	push   %ebx
801000b0:	83 ec 18             	sub    $0x18,%esp
801000b3:	8b 75 08             	mov    0x8(%ebp),%esi
801000b6:	8b 7d 0c             	mov    0xc(%ebp),%edi
    acquire(&bcache.lock);
801000b9:	68 c0 b5 10 80       	push   $0x8010b5c0
801000be:	e8 b2 3f 00 00       	call   80104075 <acquire>
    for (b = bcache.head.next; b != &bcache.head; b = b->next) {
801000c3:	8b 1d 10 fd 10 80    	mov    0x8010fd10,%ebx
801000c9:	83 c4 10             	add    $0x10,%esp
801000cc:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
801000d2:	75 26                	jne    801000fa <bread+0x50>
    for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
801000d4:	8b 1d 0c fd 10 80    	mov    0x8010fd0c,%ebx
801000da:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
801000e0:	75 4e                	jne    80100130 <bread+0x86>
    panic("bget: no buffers");
801000e2:	83 ec 0c             	sub    $0xc,%esp
801000e5:	68 0e 69 10 80       	push   $0x8010690e
801000ea:	e8 55 02 00 00       	call   80100344 <panic>
    for (b = bcache.head.next; b != &bcache.head; b = b->next) {
801000ef:	8b 5b 54             	mov    0x54(%ebx),%ebx
801000f2:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
801000f8:	74 da                	je     801000d4 <bread+0x2a>
        if (b->dev == dev && b->blockno == blockno) {
801000fa:	3b 73 04             	cmp    0x4(%ebx),%esi
801000fd:	75 f0                	jne    801000ef <bread+0x45>
801000ff:	3b 7b 08             	cmp    0x8(%ebx),%edi
80100102:	75 eb                	jne    801000ef <bread+0x45>
            b->refcnt++;
80100104:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
            release(&bcache.lock);
80100108:	83 ec 0c             	sub    $0xc,%esp
8010010b:	68 c0 b5 10 80       	push   $0x8010b5c0
80100110:	e8 c7 3f 00 00       	call   801040dc <release>
            acquiresleep(&b->lock);
80100115:	8d 43 0c             	lea    0xc(%ebx),%eax
80100118:	89 04 24             	mov    %eax,(%esp)
8010011b:	e8 36 3d 00 00       	call   80103e56 <acquiresleep>
80100120:	83 c4 10             	add    $0x10,%esp
80100123:	eb 44                	jmp    80100169 <bread+0xbf>
    for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
80100125:	8b 5b 50             	mov    0x50(%ebx),%ebx
80100128:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
8010012e:	74 b2                	je     801000e2 <bread+0x38>
        if (b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100130:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80100134:	75 ef                	jne    80100125 <bread+0x7b>
80100136:	f6 03 04             	testb  $0x4,(%ebx)
80100139:	75 ea                	jne    80100125 <bread+0x7b>
            b->dev = dev;
8010013b:	89 73 04             	mov    %esi,0x4(%ebx)
            b->blockno = blockno;
8010013e:	89 7b 08             	mov    %edi,0x8(%ebx)
            b->flags = 0;
80100141:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
            b->refcnt = 1;
80100147:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
            release(&bcache.lock);
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	68 c0 b5 10 80       	push   $0x8010b5c0
80100156:	e8 81 3f 00 00       	call   801040dc <release>
            acquiresleep(&b->lock);
8010015b:	8d 43 0c             	lea    0xc(%ebx),%eax
8010015e:	89 04 24             	mov    %eax,(%esp)
80100161:	e8 f0 3c 00 00       	call   80103e56 <acquiresleep>
80100166:	83 c4 10             	add    $0x10,%esp
    struct buf *b;

    b = bget(dev, blockno);
    if ((b->flags & B_VALID) == 0) {
80100169:	f6 03 02             	testb  $0x2,(%ebx)
8010016c:	74 0a                	je     80100178 <bread+0xce>
        iderw(b);
    }
    return b;
}
8010016e:	89 d8                	mov    %ebx,%eax
80100170:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100173:	5b                   	pop    %ebx
80100174:	5e                   	pop    %esi
80100175:	5f                   	pop    %edi
80100176:	5d                   	pop    %ebp
80100177:	c3                   	ret    
        iderw(b);
80100178:	83 ec 0c             	sub    $0xc,%esp
8010017b:	53                   	push   %ebx
8010017c:	e8 0e 1d 00 00       	call   80101e8f <iderw>
80100181:	83 c4 10             	add    $0x10,%esp
    return b;
80100184:	eb e8                	jmp    8010016e <bread+0xc4>

80100186 <bwrite>:

// Write b's contents to disk.  Must be locked.
void bwrite(struct buf *b)
{
80100186:	55                   	push   %ebp
80100187:	89 e5                	mov    %esp,%ebp
80100189:	53                   	push   %ebx
8010018a:	83 ec 10             	sub    $0x10,%esp
8010018d:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (!holdingsleep(&b->lock))
80100190:	8d 43 0c             	lea    0xc(%ebx),%eax
80100193:	50                   	push   %eax
80100194:	e8 4a 3d 00 00       	call   80103ee3 <holdingsleep>
80100199:	83 c4 10             	add    $0x10,%esp
8010019c:	85 c0                	test   %eax,%eax
8010019e:	74 14                	je     801001b4 <bwrite+0x2e>
        panic("bwrite");
    b->flags |= B_DIRTY;
801001a0:	83 0b 04             	orl    $0x4,(%ebx)
    iderw(b);
801001a3:	83 ec 0c             	sub    $0xc,%esp
801001a6:	53                   	push   %ebx
801001a7:	e8 e3 1c 00 00       	call   80101e8f <iderw>
}
801001ac:	83 c4 10             	add    $0x10,%esp
801001af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001b2:	c9                   	leave  
801001b3:	c3                   	ret    
        panic("bwrite");
801001b4:	83 ec 0c             	sub    $0xc,%esp
801001b7:	68 1f 69 10 80       	push   $0x8010691f
801001bc:	e8 83 01 00 00       	call   80100344 <panic>

801001c1 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void brelse(struct buf *b)
{
801001c1:	55                   	push   %ebp
801001c2:	89 e5                	mov    %esp,%ebp
801001c4:	56                   	push   %esi
801001c5:	53                   	push   %ebx
801001c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (!holdingsleep(&b->lock))
801001c9:	8d 73 0c             	lea    0xc(%ebx),%esi
801001cc:	83 ec 0c             	sub    $0xc,%esp
801001cf:	56                   	push   %esi
801001d0:	e8 0e 3d 00 00       	call   80103ee3 <holdingsleep>
801001d5:	83 c4 10             	add    $0x10,%esp
801001d8:	85 c0                	test   %eax,%eax
801001da:	74 6b                	je     80100247 <brelse+0x86>
        panic("brelse");

    releasesleep(&b->lock);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	56                   	push   %esi
801001e0:	e8 c3 3c 00 00       	call   80103ea8 <releasesleep>

    acquire(&bcache.lock);
801001e5:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
801001ec:	e8 84 3e 00 00       	call   80104075 <acquire>
    b->refcnt--;
801001f1:	8b 43 4c             	mov    0x4c(%ebx),%eax
801001f4:	83 e8 01             	sub    $0x1,%eax
801001f7:	89 43 4c             	mov    %eax,0x4c(%ebx)
    if (b->refcnt == 0) {
801001fa:	83 c4 10             	add    $0x10,%esp
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 2f                	jne    80100230 <brelse+0x6f>
        // no one is waiting for it.
        b->next->prev = b->prev;
80100201:	8b 43 54             	mov    0x54(%ebx),%eax
80100204:	8b 53 50             	mov    0x50(%ebx),%edx
80100207:	89 50 50             	mov    %edx,0x50(%eax)
        b->prev->next = b->next;
8010020a:	8b 43 50             	mov    0x50(%ebx),%eax
8010020d:	8b 53 54             	mov    0x54(%ebx),%edx
80100210:	89 50 54             	mov    %edx,0x54(%eax)
        b->next = bcache.head.next;
80100213:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
80100218:	89 43 54             	mov    %eax,0x54(%ebx)
        b->prev = &bcache.head;
8010021b:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
        bcache.head.next->prev = b;
80100222:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
80100227:	89 58 50             	mov    %ebx,0x50(%eax)
        bcache.head.next = b;
8010022a:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
    }

    release(&bcache.lock);
80100230:	83 ec 0c             	sub    $0xc,%esp
80100233:	68 c0 b5 10 80       	push   $0x8010b5c0
80100238:	e8 9f 3e 00 00       	call   801040dc <release>
}
8010023d:	83 c4 10             	add    $0x10,%esp
80100240:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100243:	5b                   	pop    %ebx
80100244:	5e                   	pop    %esi
80100245:	5d                   	pop    %ebp
80100246:	c3                   	ret    
        panic("brelse");
80100247:	83 ec 0c             	sub    $0xc,%esp
8010024a:	68 26 69 10 80       	push   $0x80106926
8010024f:	e8 f0 00 00 00       	call   80100344 <panic>

80100254 <consoleread>:
        procdump(); // now call procdump() wo. cons.lock held
    }
}

int consoleread(struct inode *ip, char *dst, int n)
{
80100254:	55                   	push   %ebp
80100255:	89 e5                	mov    %esp,%ebp
80100257:	57                   	push   %edi
80100258:	56                   	push   %esi
80100259:	53                   	push   %ebx
8010025a:	83 ec 28             	sub    $0x28,%esp
8010025d:	8b 7d 0c             	mov    0xc(%ebp),%edi
80100260:	8b 75 10             	mov    0x10(%ebp),%esi
    uint target;
    int c;

    iunlock(ip);
80100263:	ff 75 08             	pushl  0x8(%ebp)
80100266:	e8 3d 13 00 00       	call   801015a8 <iunlock>
    target = n;
8010026b:	89 75 e4             	mov    %esi,-0x1c(%ebp)
    acquire(&cons.lock);
8010026e:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
80100275:	e8 fb 3d 00 00       	call   80104075 <acquire>
    while (n > 0) {
8010027a:	83 c4 10             	add    $0x10,%esp
        while (input.r == input.w) {
8010027d:	bb 20 ff 10 80       	mov    $0x8010ff20,%ebx
    while (n > 0) {
80100282:	85 f6                	test   %esi,%esi
80100284:	7e 68                	jle    801002ee <consoleread+0x9a>
        while (input.r == input.w) {
80100286:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
8010028c:	3b 83 84 00 00 00    	cmp    0x84(%ebx),%eax
80100292:	75 2e                	jne    801002c2 <consoleread+0x6e>
            if (myproc()->killed) {
80100294:	e8 32 32 00 00       	call   801034cb <myproc>
80100299:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010029d:	75 71                	jne    80100310 <consoleread+0xbc>
                release(&cons.lock);
                ilock(ip);
                return -1;
            }
            sleep(&input.r, &cons.lock);
8010029f:	83 ec 08             	sub    $0x8,%esp
801002a2:	68 20 a5 10 80       	push   $0x8010a520
801002a7:	68 a0 ff 10 80       	push   $0x8010ffa0
801002ac:	e8 d2 37 00 00       	call   80103a83 <sleep>
        while (input.r == input.w) {
801002b1:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
801002b7:	83 c4 10             	add    $0x10,%esp
801002ba:	3b 83 84 00 00 00    	cmp    0x84(%ebx),%eax
801002c0:	74 d2                	je     80100294 <consoleread+0x40>
        }
        c = input.buf[input.r++ % INPUT_BUF];
801002c2:	8d 50 01             	lea    0x1(%eax),%edx
801002c5:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
801002cb:	89 c2                	mov    %eax,%edx
801002cd:	83 e2 7f             	and    $0x7f,%edx
801002d0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
801002d4:	0f be d1             	movsbl %cl,%edx
        if (c == C('D')) { // EOF
801002d7:	83 fa 04             	cmp    $0x4,%edx
801002da:	74 5c                	je     80100338 <consoleread+0xe4>
                // caller gets a 0-byte result.
                input.r--;
            }
            break;
        }
        *dst++ = c;
801002dc:	83 c7 01             	add    $0x1,%edi
801002df:	88 4f ff             	mov    %cl,-0x1(%edi)
        --n;
801002e2:	83 ee 01             	sub    $0x1,%esi
        if (c == '\n')
801002e5:	83 fa 0a             	cmp    $0xa,%edx
801002e8:	74 04                	je     801002ee <consoleread+0x9a>
    while (n > 0) {
801002ea:	85 f6                	test   %esi,%esi
801002ec:	75 98                	jne    80100286 <consoleread+0x32>
            break;
    }
    release(&cons.lock);
801002ee:	83 ec 0c             	sub    $0xc,%esp
801002f1:	68 20 a5 10 80       	push   $0x8010a520
801002f6:	e8 e1 3d 00 00       	call   801040dc <release>
    ilock(ip);
801002fb:	83 c4 04             	add    $0x4,%esp
801002fe:	ff 75 08             	pushl  0x8(%ebp)
80100301:	e8 e0 11 00 00       	call   801014e6 <ilock>

    return target - n;
80100306:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100309:	29 f0                	sub    %esi,%eax
8010030b:	83 c4 10             	add    $0x10,%esp
8010030e:	eb 20                	jmp    80100330 <consoleread+0xdc>
                release(&cons.lock);
80100310:	83 ec 0c             	sub    $0xc,%esp
80100313:	68 20 a5 10 80       	push   $0x8010a520
80100318:	e8 bf 3d 00 00       	call   801040dc <release>
                ilock(ip);
8010031d:	83 c4 04             	add    $0x4,%esp
80100320:	ff 75 08             	pushl  0x8(%ebp)
80100323:	e8 be 11 00 00       	call   801014e6 <ilock>
                return -1;
80100328:	83 c4 10             	add    $0x10,%esp
8010032b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100330:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100333:	5b                   	pop    %ebx
80100334:	5e                   	pop    %esi
80100335:	5f                   	pop    %edi
80100336:	5d                   	pop    %ebp
80100337:	c3                   	ret    
            if (n < target) {
80100338:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
8010033b:	73 b1                	jae    801002ee <consoleread+0x9a>
                input.r--;
8010033d:	a3 a0 ff 10 80       	mov    %eax,0x8010ffa0
80100342:	eb aa                	jmp    801002ee <consoleread+0x9a>

80100344 <panic>:
{
80100344:	55                   	push   %ebp
80100345:	89 e5                	mov    %esp,%ebp
80100347:	56                   	push   %esi
80100348:	53                   	push   %ebx
80100349:	83 ec 30             	sub    $0x30,%esp
    asm volatile("movw %0, %%gs" : : "r"(v));
}

static inline void cli(void)
{
    asm volatile("cli");
8010034c:	fa                   	cli    
    cons.locking = 0;
8010034d:	c7 05 54 a5 10 80 00 	movl   $0x0,0x8010a554
80100354:	00 00 00 
    cprintf("lapicid %d: panic: ", lapicid());
80100357:	e8 e4 20 00 00       	call   80102440 <lapicid>
8010035c:	83 ec 08             	sub    $0x8,%esp
8010035f:	50                   	push   %eax
80100360:	68 2d 69 10 80       	push   $0x8010692d
80100365:	e8 77 02 00 00       	call   801005e1 <cprintf>
    cprintf(s);
8010036a:	83 c4 04             	add    $0x4,%esp
8010036d:	ff 75 08             	pushl  0x8(%ebp)
80100370:	e8 6c 02 00 00       	call   801005e1 <cprintf>
    cprintf("\n");
80100375:	c7 04 24 7b 72 10 80 	movl   $0x8010727b,(%esp)
8010037c:	e8 60 02 00 00       	call   801005e1 <cprintf>
    getcallerpcs(&s, pcs);
80100381:	83 c4 08             	add    $0x8,%esp
80100384:	8d 5d d0             	lea    -0x30(%ebp),%ebx
80100387:	53                   	push   %ebx
80100388:	8d 45 08             	lea    0x8(%ebp),%eax
8010038b:	50                   	push   %eax
8010038c:	e8 b7 3b 00 00       	call   80103f48 <getcallerpcs>
80100391:	8d 75 f8             	lea    -0x8(%ebp),%esi
80100394:	83 c4 10             	add    $0x10,%esp
        cprintf(" %p", pcs[i]);
80100397:	83 ec 08             	sub    $0x8,%esp
8010039a:	ff 33                	pushl  (%ebx)
8010039c:	68 41 69 10 80       	push   $0x80106941
801003a1:	e8 3b 02 00 00       	call   801005e1 <cprintf>
801003a6:	83 c3 04             	add    $0x4,%ebx
    for (i = 0; i < 10; i++)
801003a9:	83 c4 10             	add    $0x10,%esp
801003ac:	39 f3                	cmp    %esi,%ebx
801003ae:	75 e7                	jne    80100397 <panic+0x53>
    panicked = 1; // freeze other CPU
801003b0:	c7 05 58 a5 10 80 01 	movl   $0x1,0x8010a558
801003b7:	00 00 00 
801003ba:	eb fe                	jmp    801003ba <panic+0x76>

801003bc <consputc>:
    if (panicked) {
801003bc:	83 3d 58 a5 10 80 00 	cmpl   $0x0,0x8010a558
801003c3:	74 03                	je     801003c8 <consputc+0xc>
801003c5:	fa                   	cli    
801003c6:	eb fe                	jmp    801003c6 <consputc+0xa>
{
801003c8:	55                   	push   %ebp
801003c9:	89 e5                	mov    %esp,%ebp
801003cb:	57                   	push   %edi
801003cc:	56                   	push   %esi
801003cd:	53                   	push   %ebx
801003ce:	83 ec 0c             	sub    $0xc,%esp
801003d1:	89 c6                	mov    %eax,%esi
    if (c == BACKSPACE) {
801003d3:	3d 00 01 00 00       	cmp    $0x100,%eax
801003d8:	74 5f                	je     80100439 <consputc+0x7d>
        uartputc(c);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 5a 51 00 00       	call   8010553d <uartputc>
801003e3:	83 c4 10             	add    $0x10,%esp
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
801003e6:	bb d4 03 00 00       	mov    $0x3d4,%ebx
801003eb:	b8 0e 00 00 00       	mov    $0xe,%eax
801003f0:	89 da                	mov    %ebx,%edx
801003f2:	ee                   	out    %al,(%dx)
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
801003f3:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801003f8:	89 ca                	mov    %ecx,%edx
801003fa:	ec                   	in     (%dx),%al
    pos = inb(CRTPORT + 1) << 8;
801003fb:	0f b6 c0             	movzbl %al,%eax
801003fe:	c1 e0 08             	shl    $0x8,%eax
80100401:	89 c7                	mov    %eax,%edi
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
80100403:	b8 0f 00 00 00       	mov    $0xf,%eax
80100408:	89 da                	mov    %ebx,%edx
8010040a:	ee                   	out    %al,(%dx)
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
8010040b:	89 ca                	mov    %ecx,%edx
8010040d:	ec                   	in     (%dx),%al
    pos |= inb(CRTPORT + 1);
8010040e:	0f b6 d8             	movzbl %al,%ebx
80100411:	09 fb                	or     %edi,%ebx
    if (c == '\n')
80100413:	83 fe 0a             	cmp    $0xa,%esi
80100416:	74 48                	je     80100460 <consputc+0xa4>
    else if (c == BACKSPACE) {
80100418:	81 fe 00 01 00 00    	cmp    $0x100,%esi
8010041e:	0f 84 93 00 00 00    	je     801004b7 <consputc+0xfb>
        crt[pos++] = (c & 0xff) | 0x0700; // black on white
80100424:	89 f0                	mov    %esi,%eax
80100426:	0f b6 c0             	movzbl %al,%eax
80100429:	80 cc 07             	or     $0x7,%ah
8010042c:	66 89 84 1b 00 80 0b 	mov    %ax,-0x7ff48000(%ebx,%ebx,1)
80100433:	80 
80100434:	8d 5b 01             	lea    0x1(%ebx),%ebx
80100437:	eb 35                	jmp    8010046e <consputc+0xb2>
        uartputc('\b');
80100439:	83 ec 0c             	sub    $0xc,%esp
8010043c:	6a 08                	push   $0x8
8010043e:	e8 fa 50 00 00       	call   8010553d <uartputc>
        uartputc(' ');
80100443:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010044a:	e8 ee 50 00 00       	call   8010553d <uartputc>
        uartputc('\b');
8010044f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100456:	e8 e2 50 00 00       	call   8010553d <uartputc>
8010045b:	83 c4 10             	add    $0x10,%esp
8010045e:	eb 86                	jmp    801003e6 <consputc+0x2a>
        pos += 80 - pos % 80;
80100460:	b9 50 00 00 00       	mov    $0x50,%ecx
80100465:	89 d8                	mov    %ebx,%eax
80100467:	99                   	cltd   
80100468:	f7 f9                	idiv   %ecx
8010046a:	29 d1                	sub    %edx,%ecx
8010046c:	01 cb                	add    %ecx,%ebx
    if (pos < 0 || pos > 25 * 80)
8010046e:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100474:	77 4a                	ja     801004c0 <consputc+0x104>
    if ((pos / 80) >= 24) { // Scroll up.
80100476:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
8010047c:	7f 4f                	jg     801004cd <consputc+0x111>
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
8010047e:	be d4 03 00 00       	mov    $0x3d4,%esi
80100483:	b8 0e 00 00 00       	mov    $0xe,%eax
80100488:	89 f2                	mov    %esi,%edx
8010048a:	ee                   	out    %al,(%dx)
    outb(CRTPORT + 1, pos >> 8);
8010048b:	89 d8                	mov    %ebx,%eax
8010048d:	c1 f8 08             	sar    $0x8,%eax
80100490:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
80100495:	89 ca                	mov    %ecx,%edx
80100497:	ee                   	out    %al,(%dx)
80100498:	b8 0f 00 00 00       	mov    $0xf,%eax
8010049d:	89 f2                	mov    %esi,%edx
8010049f:	ee                   	out    %al,(%dx)
801004a0:	89 d8                	mov    %ebx,%eax
801004a2:	89 ca                	mov    %ecx,%edx
801004a4:	ee                   	out    %al,(%dx)
    crt[pos] = ' ' | 0x0700;
801004a5:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
801004ac:	80 20 07 
}
801004af:	8d 65 f4             	lea    -0xc(%ebp),%esp
801004b2:	5b                   	pop    %ebx
801004b3:	5e                   	pop    %esi
801004b4:	5f                   	pop    %edi
801004b5:	5d                   	pop    %ebp
801004b6:	c3                   	ret    
        if (pos > 0)
801004b7:	85 db                	test   %ebx,%ebx
801004b9:	7e b3                	jle    8010046e <consputc+0xb2>
            --pos;
801004bb:	83 eb 01             	sub    $0x1,%ebx
801004be:	eb ae                	jmp    8010046e <consputc+0xb2>
        panic("pos under/overflow");
801004c0:	83 ec 0c             	sub    $0xc,%esp
801004c3:	68 45 69 10 80       	push   $0x80106945
801004c8:	e8 77 fe ff ff       	call   80100344 <panic>
        memmove(crt, crt + 80, sizeof(crt[0]) * 23 * 80);
801004cd:	83 ec 04             	sub    $0x4,%esp
801004d0:	68 60 0e 00 00       	push   $0xe60
801004d5:	68 a0 80 0b 80       	push   $0x800b80a0
801004da:	68 00 80 0b 80       	push   $0x800b8000
801004df:	e8 d4 3c 00 00       	call   801041b8 <memmove>
        pos -= 80;
801004e4:	83 eb 50             	sub    $0x50,%ebx
        memset(crt + pos, 0, sizeof(crt[0]) * (24 * 80 - pos));
801004e7:	83 c4 0c             	add    $0xc,%esp
801004ea:	b8 80 07 00 00       	mov    $0x780,%eax
801004ef:	29 d8                	sub    %ebx,%eax
801004f1:	01 c0                	add    %eax,%eax
801004f3:	50                   	push   %eax
801004f4:	6a 00                	push   $0x0
801004f6:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
801004f9:	2d 00 80 f4 7f       	sub    $0x7ff48000,%eax
801004fe:	50                   	push   %eax
801004ff:	e8 1f 3c 00 00       	call   80104123 <memset>
80100504:	83 c4 10             	add    $0x10,%esp
80100507:	e9 72 ff ff ff       	jmp    8010047e <consputc+0xc2>

8010050c <printint>:
{
8010050c:	55                   	push   %ebp
8010050d:	89 e5                	mov    %esp,%ebp
8010050f:	57                   	push   %edi
80100510:	56                   	push   %esi
80100511:	53                   	push   %ebx
80100512:	83 ec 1c             	sub    $0x1c,%esp
80100515:	89 d6                	mov    %edx,%esi
    if (sign && (sign = xx < 0))
80100517:	85 c9                	test   %ecx,%ecx
80100519:	74 04                	je     8010051f <printint+0x13>
8010051b:	85 c0                	test   %eax,%eax
8010051d:	78 0e                	js     8010052d <printint+0x21>
        x = xx;
8010051f:	89 c2                	mov    %eax,%edx
80100521:	bf 00 00 00 00       	mov    $0x0,%edi
    i = 0;
80100526:	b9 00 00 00 00       	mov    $0x0,%ecx
8010052b:	eb 0d                	jmp    8010053a <printint+0x2e>
        x = -xx;
8010052d:	f7 d8                	neg    %eax
8010052f:	89 c2                	mov    %eax,%edx
    if (sign && (sign = xx < 0))
80100531:	bf 01 00 00 00       	mov    $0x1,%edi
        x = -xx;
80100536:	eb ee                	jmp    80100526 <printint+0x1a>
        buf[i++] = digits[x % base];
80100538:	89 d9                	mov    %ebx,%ecx
8010053a:	8d 59 01             	lea    0x1(%ecx),%ebx
8010053d:	89 d0                	mov    %edx,%eax
8010053f:	ba 00 00 00 00       	mov    $0x0,%edx
80100544:	f7 f6                	div    %esi
80100546:	0f b6 92 70 69 10 80 	movzbl -0x7fef9690(%edx),%edx
8010054d:	88 54 1d d7          	mov    %dl,-0x29(%ebp,%ebx,1)
    } while ((x /= base) != 0);
80100551:	89 c2                	mov    %eax,%edx
80100553:	85 c0                	test   %eax,%eax
80100555:	75 e1                	jne    80100538 <printint+0x2c>
    if (sign)
80100557:	85 ff                	test   %edi,%edi
80100559:	74 08                	je     80100563 <printint+0x57>
        buf[i++] = '-';
8010055b:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
80100560:	8d 59 02             	lea    0x2(%ecx),%ebx
    while (--i >= 0)
80100563:	83 eb 01             	sub    $0x1,%ebx
80100566:	78 12                	js     8010057a <printint+0x6e>
        consputc(buf[i]);
80100568:	0f be 44 2b d8       	movsbl -0x28(%ebx,%ebp,1),%eax
8010056d:	e8 4a fe ff ff       	call   801003bc <consputc>
    while (--i >= 0)
80100572:	83 eb 01             	sub    $0x1,%ebx
80100575:	83 fb ff             	cmp    $0xffffffff,%ebx
80100578:	75 ee                	jne    80100568 <printint+0x5c>
}
8010057a:	83 c4 1c             	add    $0x1c,%esp
8010057d:	5b                   	pop    %ebx
8010057e:	5e                   	pop    %esi
8010057f:	5f                   	pop    %edi
80100580:	5d                   	pop    %ebp
80100581:	c3                   	ret    

80100582 <consolewrite>:

int consolewrite(struct inode *ip, char *buf, int n)
{
80100582:	55                   	push   %ebp
80100583:	89 e5                	mov    %esp,%ebp
80100585:	57                   	push   %edi
80100586:	56                   	push   %esi
80100587:	53                   	push   %ebx
80100588:	83 ec 18             	sub    $0x18,%esp
8010058b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010058e:	8b 7d 10             	mov    0x10(%ebp),%edi
    int i;

    iunlock(ip);
80100591:	ff 75 08             	pushl  0x8(%ebp)
80100594:	e8 0f 10 00 00       	call   801015a8 <iunlock>
    acquire(&cons.lock);
80100599:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801005a0:	e8 d0 3a 00 00       	call   80104075 <acquire>
    for (i = 0; i < n; i++)
801005a5:	83 c4 10             	add    $0x10,%esp
801005a8:	85 ff                	test   %edi,%edi
801005aa:	7e 13                	jle    801005bf <consolewrite+0x3d>
801005ac:	89 f3                	mov    %esi,%ebx
801005ae:	01 fe                	add    %edi,%esi
        consputc(buf[i] & 0xff);
801005b0:	0f b6 03             	movzbl (%ebx),%eax
801005b3:	e8 04 fe ff ff       	call   801003bc <consputc>
801005b8:	83 c3 01             	add    $0x1,%ebx
    for (i = 0; i < n; i++)
801005bb:	39 f3                	cmp    %esi,%ebx
801005bd:	75 f1                	jne    801005b0 <consolewrite+0x2e>
    release(&cons.lock);
801005bf:	83 ec 0c             	sub    $0xc,%esp
801005c2:	68 20 a5 10 80       	push   $0x8010a520
801005c7:	e8 10 3b 00 00       	call   801040dc <release>
    ilock(ip);
801005cc:	83 c4 04             	add    $0x4,%esp
801005cf:	ff 75 08             	pushl  0x8(%ebp)
801005d2:	e8 0f 0f 00 00       	call   801014e6 <ilock>

    return n;
}
801005d7:	89 f8                	mov    %edi,%eax
801005d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801005dc:	5b                   	pop    %ebx
801005dd:	5e                   	pop    %esi
801005de:	5f                   	pop    %edi
801005df:	5d                   	pop    %ebp
801005e0:	c3                   	ret    

801005e1 <cprintf>:
{
801005e1:	55                   	push   %ebp
801005e2:	89 e5                	mov    %esp,%ebp
801005e4:	57                   	push   %edi
801005e5:	56                   	push   %esi
801005e6:	53                   	push   %ebx
801005e7:	83 ec 1c             	sub    $0x1c,%esp
    locking = cons.locking;
801005ea:	a1 54 a5 10 80       	mov    0x8010a554,%eax
801005ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (locking)
801005f2:	85 c0                	test   %eax,%eax
801005f4:	75 2b                	jne    80100621 <cprintf+0x40>
    if (fmt == 0)
801005f6:	8b 7d 08             	mov    0x8(%ebp),%edi
801005f9:	85 ff                	test   %edi,%edi
801005fb:	74 36                	je     80100633 <cprintf+0x52>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++) {
801005fd:	0f b6 07             	movzbl (%edi),%eax
    argp = (uint *)(void *)(&fmt + 1);
80100600:	8d 4d 0c             	lea    0xc(%ebp),%ecx
80100603:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++) {
80100606:	bb 00 00 00 00       	mov    $0x0,%ebx
8010060b:	85 c0                	test   %eax,%eax
8010060d:	75 41                	jne    80100650 <cprintf+0x6f>
    if (locking)
8010060f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100613:	0f 85 0d 01 00 00    	jne    80100726 <cprintf+0x145>
}
80100619:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010061c:	5b                   	pop    %ebx
8010061d:	5e                   	pop    %esi
8010061e:	5f                   	pop    %edi
8010061f:	5d                   	pop    %ebp
80100620:	c3                   	ret    
        acquire(&cons.lock);
80100621:	83 ec 0c             	sub    $0xc,%esp
80100624:	68 20 a5 10 80       	push   $0x8010a520
80100629:	e8 47 3a 00 00       	call   80104075 <acquire>
8010062e:	83 c4 10             	add    $0x10,%esp
80100631:	eb c3                	jmp    801005f6 <cprintf+0x15>
        panic("null fmt");
80100633:	83 ec 0c             	sub    $0xc,%esp
80100636:	68 5f 69 10 80       	push   $0x8010695f
8010063b:	e8 04 fd ff ff       	call   80100344 <panic>
            consputc(c);
80100640:	e8 77 fd ff ff       	call   801003bc <consputc>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++) {
80100645:	83 c3 01             	add    $0x1,%ebx
80100648:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
8010064c:	85 c0                	test   %eax,%eax
8010064e:	74 bf                	je     8010060f <cprintf+0x2e>
        if (c != '%') {
80100650:	83 f8 25             	cmp    $0x25,%eax
80100653:	75 eb                	jne    80100640 <cprintf+0x5f>
        c = fmt[++i] & 0xff;
80100655:	83 c3 01             	add    $0x1,%ebx
80100658:	0f b6 34 1f          	movzbl (%edi,%ebx,1),%esi
        if (c == 0)
8010065c:	85 f6                	test   %esi,%esi
8010065e:	74 af                	je     8010060f <cprintf+0x2e>
        switch (c) {
80100660:	83 fe 70             	cmp    $0x70,%esi
80100663:	74 4c                	je     801006b1 <cprintf+0xd0>
80100665:	83 fe 70             	cmp    $0x70,%esi
80100668:	7f 2a                	jg     80100694 <cprintf+0xb3>
8010066a:	83 fe 25             	cmp    $0x25,%esi
8010066d:	0f 84 a4 00 00 00    	je     80100717 <cprintf+0x136>
80100673:	83 fe 64             	cmp    $0x64,%esi
80100676:	75 26                	jne    8010069e <cprintf+0xbd>
            printint(*argp++, 10, 1);
80100678:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010067b:	8d 70 04             	lea    0x4(%eax),%esi
8010067e:	b9 01 00 00 00       	mov    $0x1,%ecx
80100683:	ba 0a 00 00 00       	mov    $0xa,%edx
80100688:	8b 00                	mov    (%eax),%eax
8010068a:	e8 7d fe ff ff       	call   8010050c <printint>
8010068f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
            break;
80100692:	eb b1                	jmp    80100645 <cprintf+0x64>
        switch (c) {
80100694:	83 fe 73             	cmp    $0x73,%esi
80100697:	74 37                	je     801006d0 <cprintf+0xef>
80100699:	83 fe 78             	cmp    $0x78,%esi
8010069c:	74 13                	je     801006b1 <cprintf+0xd0>
            consputc('%');
8010069e:	b8 25 00 00 00       	mov    $0x25,%eax
801006a3:	e8 14 fd ff ff       	call   801003bc <consputc>
            consputc(c);
801006a8:	89 f0                	mov    %esi,%eax
801006aa:	e8 0d fd ff ff       	call   801003bc <consputc>
            break;
801006af:	eb 94                	jmp    80100645 <cprintf+0x64>
            printint(*argp++, 16, 0);
801006b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801006b4:	8d 70 04             	lea    0x4(%eax),%esi
801006b7:	b9 00 00 00 00       	mov    $0x0,%ecx
801006bc:	ba 10 00 00 00       	mov    $0x10,%edx
801006c1:	8b 00                	mov    (%eax),%eax
801006c3:	e8 44 fe ff ff       	call   8010050c <printint>
801006c8:	89 75 e4             	mov    %esi,-0x1c(%ebp)
            break;
801006cb:	e9 75 ff ff ff       	jmp    80100645 <cprintf+0x64>
            if ((s = (char *)*argp++) == 0)
801006d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801006d3:	8d 50 04             	lea    0x4(%eax),%edx
801006d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
801006d9:	8b 00                	mov    (%eax),%eax
801006db:	85 c0                	test   %eax,%eax
801006dd:	74 11                	je     801006f0 <cprintf+0x10f>
801006df:	89 c6                	mov    %eax,%esi
            for (; *s; s++)
801006e1:	0f b6 00             	movzbl (%eax),%eax
            if ((s = (char *)*argp++) == 0)
801006e4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            for (; *s; s++)
801006e7:	84 c0                	test   %al,%al
801006e9:	75 0f                	jne    801006fa <cprintf+0x119>
801006eb:	e9 55 ff ff ff       	jmp    80100645 <cprintf+0x64>
                s = "(null)";
801006f0:	be 58 69 10 80       	mov    $0x80106958,%esi
            for (; *s; s++)
801006f5:	b8 28 00 00 00       	mov    $0x28,%eax
                consputc(*s);
801006fa:	0f be c0             	movsbl %al,%eax
801006fd:	e8 ba fc ff ff       	call   801003bc <consputc>
            for (; *s; s++)
80100702:	83 c6 01             	add    $0x1,%esi
80100705:	0f b6 06             	movzbl (%esi),%eax
80100708:	84 c0                	test   %al,%al
8010070a:	75 ee                	jne    801006fa <cprintf+0x119>
            if ((s = (char *)*argp++) == 0)
8010070c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010070f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100712:	e9 2e ff ff ff       	jmp    80100645 <cprintf+0x64>
            consputc('%');
80100717:	b8 25 00 00 00       	mov    $0x25,%eax
8010071c:	e8 9b fc ff ff       	call   801003bc <consputc>
            break;
80100721:	e9 1f ff ff ff       	jmp    80100645 <cprintf+0x64>
        release(&cons.lock);
80100726:	83 ec 0c             	sub    $0xc,%esp
80100729:	68 20 a5 10 80       	push   $0x8010a520
8010072e:	e8 a9 39 00 00       	call   801040dc <release>
80100733:	83 c4 10             	add    $0x10,%esp
}
80100736:	e9 de fe ff ff       	jmp    80100619 <cprintf+0x38>

8010073b <consoleintr>:
{
8010073b:	55                   	push   %ebp
8010073c:	89 e5                	mov    %esp,%ebp
8010073e:	57                   	push   %edi
8010073f:	56                   	push   %esi
80100740:	53                   	push   %ebx
80100741:	83 ec 28             	sub    $0x28,%esp
80100744:	8b 7d 08             	mov    0x8(%ebp),%edi
    acquire(&cons.lock);
80100747:	68 20 a5 10 80       	push   $0x8010a520
8010074c:	e8 24 39 00 00       	call   80104075 <acquire>
    while ((c = getc()) >= 0) {
80100751:	83 c4 10             	add    $0x10,%esp
    int c, doprocdump = 0;
80100754:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            if (c != 0 && input.e - input.r < INPUT_BUF) {
8010075b:	bb 20 ff 10 80       	mov    $0x8010ff20,%ebx
    while ((c = getc()) >= 0) {
80100760:	e9 c2 00 00 00       	jmp    80100827 <consoleintr+0xec>
        switch (c) {
80100765:	83 fe 08             	cmp    $0x8,%esi
80100768:	0f 84 dd 00 00 00    	je     8010084b <consoleintr+0x110>
            if (c != 0 && input.e - input.r < INPUT_BUF) {
8010076e:	85 f6                	test   %esi,%esi
80100770:	0f 84 b1 00 00 00    	je     80100827 <consoleintr+0xec>
80100776:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
8010077c:	89 c2                	mov    %eax,%edx
8010077e:	2b 93 80 00 00 00    	sub    0x80(%ebx),%edx
80100784:	83 fa 7f             	cmp    $0x7f,%edx
80100787:	0f 87 9a 00 00 00    	ja     80100827 <consoleintr+0xec>
                c = (c == '\r') ? '\n' : c;
8010078d:	83 fe 0d             	cmp    $0xd,%esi
80100790:	0f 84 fd 00 00 00    	je     80100893 <consoleintr+0x158>
                input.buf[input.e++ % INPUT_BUF] = c;
80100796:	8d 50 01             	lea    0x1(%eax),%edx
80100799:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
8010079f:	83 e0 7f             	and    $0x7f,%eax
801007a2:	89 f1                	mov    %esi,%ecx
801007a4:	88 0c 03             	mov    %cl,(%ebx,%eax,1)
                consputc(c);
801007a7:	89 f0                	mov    %esi,%eax
801007a9:	e8 0e fc ff ff       	call   801003bc <consputc>
                if (c == '\n' || c == C('D') ||
801007ae:	83 fe 0a             	cmp    $0xa,%esi
801007b1:	0f 84 f6 00 00 00    	je     801008ad <consoleintr+0x172>
801007b7:	83 fe 04             	cmp    $0x4,%esi
801007ba:	0f 84 ed 00 00 00    	je     801008ad <consoleintr+0x172>
                    input.e == input.r + INPUT_BUF) {
801007c0:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
801007c6:	83 e8 80             	sub    $0xffffff80,%eax
                if (c == '\n' || c == C('D') ||
801007c9:	39 83 88 00 00 00    	cmp    %eax,0x88(%ebx)
801007cf:	75 56                	jne    80100827 <consoleintr+0xec>
801007d1:	e9 d7 00 00 00       	jmp    801008ad <consoleintr+0x172>
            while (input.e != input.w &&
801007d6:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
801007dc:	3b 83 84 00 00 00    	cmp    0x84(%ebx),%eax
801007e2:	74 43                	je     80100827 <consoleintr+0xec>
                   input.buf[(input.e - 1) % INPUT_BUF] != '\n') {
801007e4:	83 e8 01             	sub    $0x1,%eax
801007e7:	89 c2                	mov    %eax,%edx
801007e9:	83 e2 7f             	and    $0x7f,%edx
            while (input.e != input.w &&
801007ec:	80 3c 13 0a          	cmpb   $0xa,(%ebx,%edx,1)
801007f0:	74 35                	je     80100827 <consoleintr+0xec>
                input.e--;
801007f2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
                consputc(BACKSPACE);
801007f8:	b8 00 01 00 00       	mov    $0x100,%eax
801007fd:	e8 ba fb ff ff       	call   801003bc <consputc>
            while (input.e != input.w &&
80100802:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
80100808:	3b 83 84 00 00 00    	cmp    0x84(%ebx),%eax
8010080e:	74 17                	je     80100827 <consoleintr+0xec>
                   input.buf[(input.e - 1) % INPUT_BUF] != '\n') {
80100810:	83 e8 01             	sub    $0x1,%eax
80100813:	89 c2                	mov    %eax,%edx
80100815:	83 e2 7f             	and    $0x7f,%edx
            while (input.e != input.w &&
80100818:	80 3c 13 0a          	cmpb   $0xa,(%ebx,%edx,1)
8010081c:	75 d4                	jne    801007f2 <consoleintr+0xb7>
8010081e:	eb 07                	jmp    80100827 <consoleintr+0xec>
            doprocdump = 1;
80100820:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
    while ((c = getc()) >= 0) {
80100827:	ff d7                	call   *%edi
80100829:	89 c6                	mov    %eax,%esi
8010082b:	85 c0                	test   %eax,%eax
8010082d:	78 3f                	js     8010086e <consoleintr+0x133>
        switch (c) {
8010082f:	83 fe 10             	cmp    $0x10,%esi
80100832:	74 ec                	je     80100820 <consoleintr+0xe5>
80100834:	83 fe 10             	cmp    $0x10,%esi
80100837:	0f 8e 28 ff ff ff    	jle    80100765 <consoleintr+0x2a>
8010083d:	83 fe 15             	cmp    $0x15,%esi
80100840:	74 94                	je     801007d6 <consoleintr+0x9b>
80100842:	83 fe 7f             	cmp    $0x7f,%esi
80100845:	0f 85 23 ff ff ff    	jne    8010076e <consoleintr+0x33>
            if (input.e != input.w) {
8010084b:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
80100851:	3b 83 84 00 00 00    	cmp    0x84(%ebx),%eax
80100857:	74 ce                	je     80100827 <consoleintr+0xec>
                input.e--;
80100859:	83 e8 01             	sub    $0x1,%eax
8010085c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
                consputc(BACKSPACE);
80100862:	b8 00 01 00 00       	mov    $0x100,%eax
80100867:	e8 50 fb ff ff       	call   801003bc <consputc>
8010086c:	eb b9                	jmp    80100827 <consoleintr+0xec>
    release(&cons.lock);
8010086e:	83 ec 0c             	sub    $0xc,%esp
80100871:	68 20 a5 10 80       	push   $0x8010a520
80100876:	e8 61 38 00 00       	call   801040dc <release>
    if (doprocdump) {
8010087b:	83 c4 10             	add    $0x10,%esp
8010087e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100882:	75 08                	jne    8010088c <consoleintr+0x151>
}
80100884:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100887:	5b                   	pop    %ebx
80100888:	5e                   	pop    %esi
80100889:	5f                   	pop    %edi
8010088a:	5d                   	pop    %ebp
8010088b:	c3                   	ret    
        procdump(); // now call procdump() wo. cons.lock held
8010088c:	e8 8c 34 00 00       	call   80103d1d <procdump>
}
80100891:	eb f1                	jmp    80100884 <consoleintr+0x149>
                input.buf[input.e++ % INPUT_BUF] = c;
80100893:	8d 50 01             	lea    0x1(%eax),%edx
80100896:	89 93 88 00 00 00    	mov    %edx,0x88(%ebx)
8010089c:	83 e0 7f             	and    $0x7f,%eax
8010089f:	c6 04 03 0a          	movb   $0xa,(%ebx,%eax,1)
                consputc(c);
801008a3:	b8 0a 00 00 00       	mov    $0xa,%eax
801008a8:	e8 0f fb ff ff       	call   801003bc <consputc>
                    input.w = input.e;
801008ad:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
801008b3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
                    wakeup(&input.r);
801008b9:	83 ec 0c             	sub    $0xc,%esp
801008bc:	68 a0 ff 10 80       	push   $0x8010ffa0
801008c1:	e8 95 33 00 00       	call   80103c5b <wakeup>
801008c6:	83 c4 10             	add    $0x10,%esp
801008c9:	e9 59 ff ff ff       	jmp    80100827 <consoleintr+0xec>

801008ce <consoleinit>:

void consoleinit(void)
{
801008ce:	55                   	push   %ebp
801008cf:	89 e5                	mov    %esp,%ebp
801008d1:	83 ec 10             	sub    $0x10,%esp
    initlock(&cons.lock, "console");
801008d4:	68 68 69 10 80       	push   $0x80106968
801008d9:	68 20 a5 10 80       	push   $0x8010a520
801008de:	e8 4a 36 00 00       	call   80103f2d <initlock>

    devsw[CONSOLE].write = consolewrite;
801008e3:	c7 05 6c 09 11 80 82 	movl   $0x80100582,0x8011096c
801008ea:	05 10 80 
    devsw[CONSOLE].read = consoleread;
801008ed:	c7 05 68 09 11 80 54 	movl   $0x80100254,0x80110968
801008f4:	02 10 80 
    cons.locking = 1;
801008f7:	c7 05 54 a5 10 80 01 	movl   $0x1,0x8010a554
801008fe:	00 00 00 

    ioapicenable(IRQ_KBD, 0);
80100901:	83 c4 08             	add    $0x8,%esp
80100904:	6a 00                	push   $0x0
80100906:	6a 01                	push   $0x1
80100908:	e8 f9 16 00 00       	call   80102006 <ioapicenable>
}
8010090d:	83 c4 10             	add    $0x10,%esp
80100910:	c9                   	leave  
80100911:	c3                   	ret    

80100912 <exec>:
#include "defs.h"
#include "x86.h"
#include "elf.h"

int exec(char *path, char **argv)
{
80100912:	55                   	push   %ebp
80100913:	89 e5                	mov    %esp,%ebp
80100915:	57                   	push   %edi
80100916:	56                   	push   %esi
80100917:	53                   	push   %ebx
80100918:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
    uint argc, sz, sp, ustack[3 + MAXARG + 1];
    struct elfhdr elf;
    struct inode *ip;
    struct proghdr ph;
    pde_t *pgdir, *oldpgdir;
    struct proc *curproc = myproc();
8010091e:	e8 a8 2b 00 00       	call   801034cb <myproc>
80100923:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

    begin_op();
80100929:	e8 7f 1e 00 00       	call   801027ad <begin_op>

    if ((ip = namei(path)) == 0) {
8010092e:	83 ec 0c             	sub    $0xc,%esp
80100931:	ff 75 08             	pushl  0x8(%ebp)
80100934:	e8 4a 13 00 00       	call   80101c83 <namei>
80100939:	83 c4 10             	add    $0x10,%esp
8010093c:	85 c0                	test   %eax,%eax
8010093e:	74 42                	je     80100982 <exec+0x70>
80100940:	89 c3                	mov    %eax,%ebx
        end_op();
        cprintf("exec: fail\n");
        return -1;
    }
    ilock(ip);
80100942:	83 ec 0c             	sub    $0xc,%esp
80100945:	50                   	push   %eax
80100946:	e8 9b 0b 00 00       	call   801014e6 <ilock>
    pgdir = 0;

    // Check ELF header
    if (readi(ip, (char *)&elf, 0, sizeof(elf)) != sizeof(elf))
8010094b:	6a 34                	push   $0x34
8010094d:	6a 00                	push   $0x0
8010094f:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100955:	50                   	push   %eax
80100956:	53                   	push   %ebx
80100957:	e8 1e 0e 00 00       	call   8010177a <readi>
8010095c:	83 c4 20             	add    $0x20,%esp
8010095f:	83 f8 34             	cmp    $0x34,%eax
80100962:	74 3a                	je     8010099e <exec+0x8c>

bad:
    if (pgdir)
        freevm(pgdir);
    if (ip) {
        iunlockput(ip);
80100964:	83 ec 0c             	sub    $0xc,%esp
80100967:	53                   	push   %ebx
80100968:	e8 c2 0d 00 00       	call   8010172f <iunlockput>
        end_op();
8010096d:	e8 b6 1e 00 00       	call   80102828 <end_op>
80100972:	83 c4 10             	add    $0x10,%esp
    }
    return -1;
80100975:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010097a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010097d:	5b                   	pop    %ebx
8010097e:	5e                   	pop    %esi
8010097f:	5f                   	pop    %edi
80100980:	5d                   	pop    %ebp
80100981:	c3                   	ret    
        end_op();
80100982:	e8 a1 1e 00 00       	call   80102828 <end_op>
        cprintf("exec: fail\n");
80100987:	83 ec 0c             	sub    $0xc,%esp
8010098a:	68 81 69 10 80       	push   $0x80106981
8010098f:	e8 4d fc ff ff       	call   801005e1 <cprintf>
        return -1;
80100994:	83 c4 10             	add    $0x10,%esp
80100997:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010099c:	eb dc                	jmp    8010097a <exec+0x68>
    if (elf.magic != ELF_MAGIC)
8010099e:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
801009a5:	45 4c 46 
801009a8:	75 ba                	jne    80100964 <exec+0x52>
    if ((pgdir = setupkvm()) == 0)
801009aa:	e8 ff 5c 00 00       	call   801066ae <setupkvm>
801009af:	89 c7                	mov    %eax,%edi
801009b1:	85 c0                	test   %eax,%eax
801009b3:	74 af                	je     80100964 <exec+0x52>
    for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
801009b5:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
801009bb:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009c1:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
801009c8:	00 
801009c9:	0f 84 bf 00 00 00    	je     80100a8e <exec+0x17c>
    sz = 0;
801009cf:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
801009d6:	00 00 00 
    for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
801009d9:	be 00 00 00 00       	mov    $0x0,%esi
801009de:	eb 12                	jmp    801009f2 <exec+0xe0>
801009e0:	83 c6 01             	add    $0x1,%esi
801009e3:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
801009ea:	39 f0                	cmp    %esi,%eax
801009ec:	0f 8e a6 00 00 00    	jle    80100a98 <exec+0x186>
        if (readi(ip, (char *)&ph, off, sizeof(ph)) != sizeof(ph))
801009f2:	6a 20                	push   $0x20
801009f4:	89 f0                	mov    %esi,%eax
801009f6:	c1 e0 05             	shl    $0x5,%eax
801009f9:	03 85 f0 fe ff ff    	add    -0x110(%ebp),%eax
801009ff:	50                   	push   %eax
80100a00:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100a06:	50                   	push   %eax
80100a07:	53                   	push   %ebx
80100a08:	e8 6d 0d 00 00       	call   8010177a <readi>
80100a0d:	83 c4 10             	add    $0x10,%esp
80100a10:	83 f8 20             	cmp    $0x20,%eax
80100a13:	0f 85 c2 00 00 00    	jne    80100adb <exec+0x1c9>
        if (ph.type != ELF_PROG_LOAD)
80100a19:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100a20:	75 be                	jne    801009e0 <exec+0xce>
        if (ph.memsz < ph.filesz)
80100a22:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100a28:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100a2e:	0f 82 a7 00 00 00    	jb     80100adb <exec+0x1c9>
        if (ph.vaddr + ph.memsz < ph.vaddr)
80100a34:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100a3a:	0f 82 9b 00 00 00    	jb     80100adb <exec+0x1c9>
        if ((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100a40:	83 ec 04             	sub    $0x4,%esp
80100a43:	50                   	push   %eax
80100a44:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a4a:	57                   	push   %edi
80100a4b:	e8 fd 5a 00 00       	call   8010654d <allocuvm>
80100a50:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
80100a56:	83 c4 10             	add    $0x10,%esp
80100a59:	85 c0                	test   %eax,%eax
80100a5b:	74 7e                	je     80100adb <exec+0x1c9>
        if (ph.vaddr % PGSIZE != 0)
80100a5d:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a63:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a68:	75 71                	jne    80100adb <exec+0x1c9>
        if (loaduvm(pgdir, (char *)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a6a:	83 ec 0c             	sub    $0xc,%esp
80100a6d:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a73:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a79:	53                   	push   %ebx
80100a7a:	50                   	push   %eax
80100a7b:	57                   	push   %edi
80100a7c:	e8 8f 59 00 00       	call   80106410 <loaduvm>
80100a81:	83 c4 20             	add    $0x20,%esp
80100a84:	85 c0                	test   %eax,%eax
80100a86:	0f 89 54 ff ff ff    	jns    801009e0 <exec+0xce>
bad:
80100a8c:	eb 4d                	jmp    80100adb <exec+0x1c9>
    sz = 0;
80100a8e:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
80100a95:	00 00 00 
    iunlockput(ip);
80100a98:	83 ec 0c             	sub    $0xc,%esp
80100a9b:	53                   	push   %ebx
80100a9c:	e8 8e 0c 00 00       	call   8010172f <iunlockput>
    end_op();
80100aa1:	e8 82 1d 00 00       	call   80102828 <end_op>
    sz = PGROUNDUP(sz);
80100aa6:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100aac:	05 ff 0f 00 00       	add    $0xfff,%eax
80100ab1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ab6:	89 c2                	mov    %eax,%edx
    if ((sz = allocuvm(pgdir, sz, sz + 2 * PGSIZE)) == 0)
80100ab8:	83 c4 0c             	add    $0xc,%esp
80100abb:	8d 80 00 20 00 00    	lea    0x2000(%eax),%eax
80100ac1:	50                   	push   %eax
80100ac2:	52                   	push   %edx
80100ac3:	57                   	push   %edi
80100ac4:	e8 84 5a 00 00       	call   8010654d <allocuvm>
80100ac9:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100acf:	83 c4 10             	add    $0x10,%esp
    ip = 0;
80100ad2:	bb 00 00 00 00       	mov    $0x0,%ebx
    if ((sz = allocuvm(pgdir, sz, sz + 2 * PGSIZE)) == 0)
80100ad7:	85 c0                	test   %eax,%eax
80100ad9:	75 1e                	jne    80100af9 <exec+0x1e7>
        freevm(pgdir);
80100adb:	83 ec 0c             	sub    $0xc,%esp
80100ade:	57                   	push   %edi
80100adf:	e8 57 5b 00 00       	call   8010663b <freevm>
    if (ip) {
80100ae4:	83 c4 10             	add    $0x10,%esp
80100ae7:	85 db                	test   %ebx,%ebx
80100ae9:	0f 85 75 fe ff ff    	jne    80100964 <exec+0x52>
    return -1;
80100aef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100af4:	e9 81 fe ff ff       	jmp    8010097a <exec+0x68>
    clearpteu(pgdir, (char *)(sz - 2 * PGSIZE));
80100af9:	83 ec 08             	sub    $0x8,%esp
80100afc:	89 c3                	mov    %eax,%ebx
80100afe:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100b04:	50                   	push   %eax
80100b05:	57                   	push   %edi
80100b06:	e8 28 5c 00 00       	call   80106733 <clearpteu>
    for (argc = 0; argv[argc]; argc++) {
80100b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b0e:	8b 00                	mov    (%eax),%eax
80100b10:	83 c4 10             	add    $0x10,%esp
80100b13:	be 00 00 00 00       	mov    $0x0,%esi
80100b18:	85 c0                	test   %eax,%eax
80100b1a:	74 5f                	je     80100b7b <exec+0x269>
        sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100b1c:	83 ec 0c             	sub    $0xc,%esp
80100b1f:	50                   	push   %eax
80100b20:	e8 c1 37 00 00       	call   801042e6 <strlen>
80100b25:	f7 d0                	not    %eax
80100b27:	01 d8                	add    %ebx,%eax
80100b29:	83 e0 fc             	and    $0xfffffffc,%eax
80100b2c:	89 c3                	mov    %eax,%ebx
        if (copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100b2e:	83 c4 04             	add    $0x4,%esp
80100b31:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b34:	ff 34 b0             	pushl  (%eax,%esi,4)
80100b37:	e8 aa 37 00 00       	call   801042e6 <strlen>
80100b3c:	83 c0 01             	add    $0x1,%eax
80100b3f:	50                   	push   %eax
80100b40:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b43:	ff 34 b0             	pushl  (%eax,%esi,4)
80100b46:	53                   	push   %ebx
80100b47:	57                   	push   %edi
80100b48:	e8 31 5d 00 00       	call   8010687e <copyout>
80100b4d:	83 c4 20             	add    $0x20,%esp
80100b50:	85 c0                	test   %eax,%eax
80100b52:	0f 88 f4 00 00 00    	js     80100c4c <exec+0x33a>
        ustack[3 + argc] = sp;
80100b58:	89 9c b5 64 ff ff ff 	mov    %ebx,-0x9c(%ebp,%esi,4)
    for (argc = 0; argv[argc]; argc++) {
80100b5f:	83 c6 01             	add    $0x1,%esi
80100b62:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b65:	8b 04 b0             	mov    (%eax,%esi,4),%eax
80100b68:	85 c0                	test   %eax,%eax
80100b6a:	74 15                	je     80100b81 <exec+0x26f>
        if (argc >= MAXARG)
80100b6c:	83 fe 20             	cmp    $0x20,%esi
80100b6f:	75 ab                	jne    80100b1c <exec+0x20a>
    ip = 0;
80100b71:	bb 00 00 00 00       	mov    $0x0,%ebx
80100b76:	e9 60 ff ff ff       	jmp    80100adb <exec+0x1c9>
    sp = sz;
80100b7b:	8b 9d f0 fe ff ff    	mov    -0x110(%ebp),%ebx
    ustack[3 + argc] = 0;
80100b81:	c7 84 b5 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%esi,4)
80100b88:	00 00 00 00 
    ustack[0] = 0xffffffff; // fake return PC
80100b8c:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b93:	ff ff ff 
    ustack[1] = argc;
80100b96:	89 b5 5c ff ff ff    	mov    %esi,-0xa4(%ebp)
    ustack[2] = sp - (argc + 1) * 4; // argv pointer
80100b9c:	8d 04 b5 04 00 00 00 	lea    0x4(,%esi,4),%eax
80100ba3:	89 da                	mov    %ebx,%edx
80100ba5:	29 c2                	sub    %eax,%edx
80100ba7:	89 95 60 ff ff ff    	mov    %edx,-0xa0(%ebp)
    sp -= (3 + argc + 1) * 4;
80100bad:	83 c0 0c             	add    $0xc,%eax
80100bb0:	89 de                	mov    %ebx,%esi
80100bb2:	29 c6                	sub    %eax,%esi
    if (copyout(pgdir, sp, ustack, (3 + argc + 1) * 4) < 0)
80100bb4:	50                   	push   %eax
80100bb5:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100bbb:	50                   	push   %eax
80100bbc:	56                   	push   %esi
80100bbd:	57                   	push   %edi
80100bbe:	e8 bb 5c 00 00       	call   8010687e <copyout>
80100bc3:	83 c4 10             	add    $0x10,%esp
80100bc6:	85 c0                	test   %eax,%eax
80100bc8:	0f 88 88 00 00 00    	js     80100c56 <exec+0x344>
    for (last = s = path; *s; s++)
80100bce:	8b 45 08             	mov    0x8(%ebp),%eax
80100bd1:	0f b6 10             	movzbl (%eax),%edx
80100bd4:	84 d2                	test   %dl,%dl
80100bd6:	74 1a                	je     80100bf2 <exec+0x2e0>
80100bd8:	83 c0 01             	add    $0x1,%eax
80100bdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
            last = s + 1;
80100bde:	80 fa 2f             	cmp    $0x2f,%dl
80100be1:	0f 44 c8             	cmove  %eax,%ecx
80100be4:	83 c0 01             	add    $0x1,%eax
    for (last = s = path; *s; s++)
80100be7:	0f b6 50 ff          	movzbl -0x1(%eax),%edx
80100beb:	84 d2                	test   %dl,%dl
80100bed:	75 ef                	jne    80100bde <exec+0x2cc>
80100bef:	89 4d 08             	mov    %ecx,0x8(%ebp)
    safestrcpy(curproc->name, last, sizeof(curproc->name));
80100bf2:	83 ec 04             	sub    $0x4,%esp
80100bf5:	6a 10                	push   $0x10
80100bf7:	ff 75 08             	pushl  0x8(%ebp)
80100bfa:	8b 9d f4 fe ff ff    	mov    -0x10c(%ebp),%ebx
80100c00:	89 d8                	mov    %ebx,%eax
80100c02:	83 c0 6c             	add    $0x6c,%eax
80100c05:	50                   	push   %eax
80100c06:	e8 a7 36 00 00       	call   801042b2 <safestrcpy>
    oldpgdir = curproc->pgdir;
80100c0b:	89 d8                	mov    %ebx,%eax
80100c0d:	8b 5b 04             	mov    0x4(%ebx),%ebx
    curproc->pgdir = pgdir;
80100c10:	89 78 04             	mov    %edi,0x4(%eax)
    curproc->sz = sz;
80100c13:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c19:	89 10                	mov    %edx,(%eax)
    curproc->tf->eip = elf.entry; // main
80100c1b:	89 c7                	mov    %eax,%edi
80100c1d:	8b 40 18             	mov    0x18(%eax),%eax
80100c20:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100c26:	89 50 38             	mov    %edx,0x38(%eax)
    curproc->tf->esp = sp;
80100c29:	8b 47 18             	mov    0x18(%edi),%eax
80100c2c:	89 70 44             	mov    %esi,0x44(%eax)
    switchuvm(curproc);
80100c2f:	89 3c 24             	mov    %edi,(%esp)
80100c32:	e8 72 56 00 00       	call   801062a9 <switchuvm>
    freevm(oldpgdir);
80100c37:	89 1c 24             	mov    %ebx,(%esp)
80100c3a:	e8 fc 59 00 00       	call   8010663b <freevm>
    return 0;
80100c3f:	83 c4 10             	add    $0x10,%esp
80100c42:	b8 00 00 00 00       	mov    $0x0,%eax
80100c47:	e9 2e fd ff ff       	jmp    8010097a <exec+0x68>
    ip = 0;
80100c4c:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c51:	e9 85 fe ff ff       	jmp    80100adb <exec+0x1c9>
80100c56:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c5b:	e9 7b fe ff ff       	jmp    80100adb <exec+0x1c9>

80100c60 <fileinit>:
    struct spinlock lock;
    struct file file[NFILE];
} ftable;

void fileinit(void)
{
80100c60:	55                   	push   %ebp
80100c61:	89 e5                	mov    %esp,%ebp
80100c63:	83 ec 10             	sub    $0x10,%esp
    initlock(&ftable.lock, "ftable");
80100c66:	68 8d 69 10 80       	push   $0x8010698d
80100c6b:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c70:	e8 b8 32 00 00       	call   80103f2d <initlock>
}
80100c75:	83 c4 10             	add    $0x10,%esp
80100c78:	c9                   	leave  
80100c79:	c3                   	ret    

80100c7a <filealloc>:

// Allocate a file structure.
struct file *filealloc(void)
{
80100c7a:	55                   	push   %ebp
80100c7b:	89 e5                	mov    %esp,%ebp
80100c7d:	53                   	push   %ebx
80100c7e:	83 ec 10             	sub    $0x10,%esp
    struct file *f;

    acquire(&ftable.lock);
80100c81:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c86:	e8 ea 33 00 00       	call   80104075 <acquire>
    for (f = ftable.file; f < ftable.file + NFILE; f++) {
        if (f->ref == 0) {
80100c8b:	83 c4 10             	add    $0x10,%esp
80100c8e:	83 3d f8 ff 10 80 00 	cmpl   $0x0,0x8010fff8
80100c95:	74 2d                	je     80100cc4 <filealloc+0x4a>
    for (f = ftable.file; f < ftable.file + NFILE; f++) {
80100c97:	bb 0c 00 11 80       	mov    $0x8011000c,%ebx
        if (f->ref == 0) {
80100c9c:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100ca0:	74 27                	je     80100cc9 <filealloc+0x4f>
    for (f = ftable.file; f < ftable.file + NFILE; f++) {
80100ca2:	83 c3 18             	add    $0x18,%ebx
80100ca5:	81 fb 54 09 11 80    	cmp    $0x80110954,%ebx
80100cab:	72 ef                	jb     80100c9c <filealloc+0x22>
            f->ref = 1;
            release(&ftable.lock);
            return f;
        }
    }
    release(&ftable.lock);
80100cad:	83 ec 0c             	sub    $0xc,%esp
80100cb0:	68 c0 ff 10 80       	push   $0x8010ffc0
80100cb5:	e8 22 34 00 00       	call   801040dc <release>
    return 0;
80100cba:	83 c4 10             	add    $0x10,%esp
80100cbd:	bb 00 00 00 00       	mov    $0x0,%ebx
80100cc2:	eb 1c                	jmp    80100ce0 <filealloc+0x66>
    for (f = ftable.file; f < ftable.file + NFILE; f++) {
80100cc4:	bb f4 ff 10 80       	mov    $0x8010fff4,%ebx
            f->ref = 1;
80100cc9:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
            release(&ftable.lock);
80100cd0:	83 ec 0c             	sub    $0xc,%esp
80100cd3:	68 c0 ff 10 80       	push   $0x8010ffc0
80100cd8:	e8 ff 33 00 00       	call   801040dc <release>
            return f;
80100cdd:	83 c4 10             	add    $0x10,%esp
}
80100ce0:	89 d8                	mov    %ebx,%eax
80100ce2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ce5:	c9                   	leave  
80100ce6:	c3                   	ret    

80100ce7 <filedup>:

// Increment ref count for file f.
struct file *filedup(struct file *f)
{
80100ce7:	55                   	push   %ebp
80100ce8:	89 e5                	mov    %esp,%ebp
80100cea:	53                   	push   %ebx
80100ceb:	83 ec 10             	sub    $0x10,%esp
80100cee:	8b 5d 08             	mov    0x8(%ebp),%ebx
    acquire(&ftable.lock);
80100cf1:	68 c0 ff 10 80       	push   $0x8010ffc0
80100cf6:	e8 7a 33 00 00       	call   80104075 <acquire>
    if (f->ref < 1)
80100cfb:	8b 43 04             	mov    0x4(%ebx),%eax
80100cfe:	83 c4 10             	add    $0x10,%esp
80100d01:	85 c0                	test   %eax,%eax
80100d03:	7e 1a                	jle    80100d1f <filedup+0x38>
        panic("filedup");
    f->ref++;
80100d05:	83 c0 01             	add    $0x1,%eax
80100d08:	89 43 04             	mov    %eax,0x4(%ebx)
    release(&ftable.lock);
80100d0b:	83 ec 0c             	sub    $0xc,%esp
80100d0e:	68 c0 ff 10 80       	push   $0x8010ffc0
80100d13:	e8 c4 33 00 00       	call   801040dc <release>
    return f;
}
80100d18:	89 d8                	mov    %ebx,%eax
80100d1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d1d:	c9                   	leave  
80100d1e:	c3                   	ret    
        panic("filedup");
80100d1f:	83 ec 0c             	sub    $0xc,%esp
80100d22:	68 94 69 10 80       	push   $0x80106994
80100d27:	e8 18 f6 ff ff       	call   80100344 <panic>

80100d2c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void fileclose(struct file *f)
{
80100d2c:	55                   	push   %ebp
80100d2d:	89 e5                	mov    %esp,%ebp
80100d2f:	57                   	push   %edi
80100d30:	56                   	push   %esi
80100d31:	53                   	push   %ebx
80100d32:	83 ec 28             	sub    $0x28,%esp
80100d35:	8b 5d 08             	mov    0x8(%ebp),%ebx
    struct file ff;

    acquire(&ftable.lock);
80100d38:	68 c0 ff 10 80       	push   $0x8010ffc0
80100d3d:	e8 33 33 00 00       	call   80104075 <acquire>
    if (f->ref < 1)
80100d42:	8b 43 04             	mov    0x4(%ebx),%eax
80100d45:	83 c4 10             	add    $0x10,%esp
80100d48:	85 c0                	test   %eax,%eax
80100d4a:	7e 22                	jle    80100d6e <fileclose+0x42>
        panic("fileclose");
    if (--f->ref > 0) {
80100d4c:	83 e8 01             	sub    $0x1,%eax
80100d4f:	89 43 04             	mov    %eax,0x4(%ebx)
80100d52:	85 c0                	test   %eax,%eax
80100d54:	7e 25                	jle    80100d7b <fileclose+0x4f>
        release(&ftable.lock);
80100d56:	83 ec 0c             	sub    $0xc,%esp
80100d59:	68 c0 ff 10 80       	push   $0x8010ffc0
80100d5e:	e8 79 33 00 00       	call   801040dc <release>
80100d63:	83 c4 10             	add    $0x10,%esp
    else if (ff.type == FD_INODE) {
        begin_op();
        iput(ff.ip);
        end_op();
    }
}
80100d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100d69:	5b                   	pop    %ebx
80100d6a:	5e                   	pop    %esi
80100d6b:	5f                   	pop    %edi
80100d6c:	5d                   	pop    %ebp
80100d6d:	c3                   	ret    
        panic("fileclose");
80100d6e:	83 ec 0c             	sub    $0xc,%esp
80100d71:	68 9c 69 10 80       	push   $0x8010699c
80100d76:	e8 c9 f5 ff ff       	call   80100344 <panic>
    ff = *f;
80100d7b:	8b 33                	mov    (%ebx),%esi
80100d7d:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
80100d81:	88 45 e7             	mov    %al,-0x19(%ebp)
80100d84:	8b 7b 0c             	mov    0xc(%ebx),%edi
80100d87:	8b 43 10             	mov    0x10(%ebx),%eax
80100d8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    f->ref = 0;
80100d8d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
    f->type = FD_NONE;
80100d94:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    release(&ftable.lock);
80100d9a:	83 ec 0c             	sub    $0xc,%esp
80100d9d:	68 c0 ff 10 80       	push   $0x8010ffc0
80100da2:	e8 35 33 00 00       	call   801040dc <release>
    if (ff.type == FD_PIPE)
80100da7:	83 c4 10             	add    $0x10,%esp
80100daa:	83 fe 01             	cmp    $0x1,%esi
80100dad:	74 1f                	je     80100dce <fileclose+0xa2>
    else if (ff.type == FD_INODE) {
80100daf:	83 fe 02             	cmp    $0x2,%esi
80100db2:	75 b2                	jne    80100d66 <fileclose+0x3a>
        begin_op();
80100db4:	e8 f4 19 00 00       	call   801027ad <begin_op>
        iput(ff.ip);
80100db9:	83 ec 0c             	sub    $0xc,%esp
80100dbc:	ff 75 e0             	pushl  -0x20(%ebp)
80100dbf:	e8 29 08 00 00       	call   801015ed <iput>
        end_op();
80100dc4:	e8 5f 1a 00 00       	call   80102828 <end_op>
80100dc9:	83 c4 10             	add    $0x10,%esp
80100dcc:	eb 98                	jmp    80100d66 <fileclose+0x3a>
        pipeclose(ff.pipe, ff.writable);
80100dce:	83 ec 08             	sub    $0x8,%esp
80100dd1:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
80100dd5:	50                   	push   %eax
80100dd6:	57                   	push   %edi
80100dd7:	e8 3d 22 00 00       	call   80103019 <pipeclose>
80100ddc:	83 c4 10             	add    $0x10,%esp
80100ddf:	eb 85                	jmp    80100d66 <fileclose+0x3a>

80100de1 <filestat>:

// Get metadata about file f.
int filestat(struct file *f, struct stat *st)
{
80100de1:	55                   	push   %ebp
80100de2:	89 e5                	mov    %esp,%ebp
80100de4:	53                   	push   %ebx
80100de5:	83 ec 04             	sub    $0x4,%esp
80100de8:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (f->type == FD_INODE) {
80100deb:	83 3b 02             	cmpl   $0x2,(%ebx)
80100dee:	75 31                	jne    80100e21 <filestat+0x40>
        ilock(f->ip);
80100df0:	83 ec 0c             	sub    $0xc,%esp
80100df3:	ff 73 10             	pushl  0x10(%ebx)
80100df6:	e8 eb 06 00 00       	call   801014e6 <ilock>
        stati(f->ip, st);
80100dfb:	83 c4 08             	add    $0x8,%esp
80100dfe:	ff 75 0c             	pushl  0xc(%ebp)
80100e01:	ff 73 10             	pushl  0x10(%ebx)
80100e04:	e8 46 09 00 00       	call   8010174f <stati>
        iunlock(f->ip);
80100e09:	83 c4 04             	add    $0x4,%esp
80100e0c:	ff 73 10             	pushl  0x10(%ebx)
80100e0f:	e8 94 07 00 00       	call   801015a8 <iunlock>
        return 0;
80100e14:	83 c4 10             	add    $0x10,%esp
80100e17:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    return -1;
}
80100e1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e1f:	c9                   	leave  
80100e20:	c3                   	ret    
    return -1;
80100e21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e26:	eb f4                	jmp    80100e1c <filestat+0x3b>

80100e28 <fileread>:

// Read from file f.
int fileread(struct file *f, char *addr, int n)
{
80100e28:	55                   	push   %ebp
80100e29:	89 e5                	mov    %esp,%ebp
80100e2b:	56                   	push   %esi
80100e2c:	53                   	push   %ebx
80100e2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
    int r;

    if (f->readable == 0)
80100e30:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100e34:	74 70                	je     80100ea6 <fileread+0x7e>
        return -1;
    if (f->type == FD_PIPE)
80100e36:	8b 03                	mov    (%ebx),%eax
80100e38:	83 f8 01             	cmp    $0x1,%eax
80100e3b:	74 44                	je     80100e81 <fileread+0x59>
        return piperead(f->pipe, addr, n);
    if (f->type == FD_INODE) {
80100e3d:	83 f8 02             	cmp    $0x2,%eax
80100e40:	75 57                	jne    80100e99 <fileread+0x71>
        ilock(f->ip);
80100e42:	83 ec 0c             	sub    $0xc,%esp
80100e45:	ff 73 10             	pushl  0x10(%ebx)
80100e48:	e8 99 06 00 00       	call   801014e6 <ilock>
        if ((r = readi(f->ip, addr, f->off, n)) > 0)
80100e4d:	ff 75 10             	pushl  0x10(%ebp)
80100e50:	ff 73 14             	pushl  0x14(%ebx)
80100e53:	ff 75 0c             	pushl  0xc(%ebp)
80100e56:	ff 73 10             	pushl  0x10(%ebx)
80100e59:	e8 1c 09 00 00       	call   8010177a <readi>
80100e5e:	89 c6                	mov    %eax,%esi
80100e60:	83 c4 20             	add    $0x20,%esp
80100e63:	85 c0                	test   %eax,%eax
80100e65:	7e 03                	jle    80100e6a <fileread+0x42>
            f->off += r;
80100e67:	01 43 14             	add    %eax,0x14(%ebx)
        iunlock(f->ip);
80100e6a:	83 ec 0c             	sub    $0xc,%esp
80100e6d:	ff 73 10             	pushl  0x10(%ebx)
80100e70:	e8 33 07 00 00       	call   801015a8 <iunlock>
        return r;
80100e75:	83 c4 10             	add    $0x10,%esp
    }
    panic("fileread");
}
80100e78:	89 f0                	mov    %esi,%eax
80100e7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e7d:	5b                   	pop    %ebx
80100e7e:	5e                   	pop    %esi
80100e7f:	5d                   	pop    %ebp
80100e80:	c3                   	ret    
        return piperead(f->pipe, addr, n);
80100e81:	83 ec 04             	sub    $0x4,%esp
80100e84:	ff 75 10             	pushl  0x10(%ebp)
80100e87:	ff 75 0c             	pushl  0xc(%ebp)
80100e8a:	ff 73 0c             	pushl  0xc(%ebx)
80100e8d:	e8 0c 23 00 00       	call   8010319e <piperead>
80100e92:	89 c6                	mov    %eax,%esi
80100e94:	83 c4 10             	add    $0x10,%esp
80100e97:	eb df                	jmp    80100e78 <fileread+0x50>
    panic("fileread");
80100e99:	83 ec 0c             	sub    $0xc,%esp
80100e9c:	68 a6 69 10 80       	push   $0x801069a6
80100ea1:	e8 9e f4 ff ff       	call   80100344 <panic>
        return -1;
80100ea6:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100eab:	eb cb                	jmp    80100e78 <fileread+0x50>

80100ead <filewrite>:

// PAGEBREAK!
//  Write to file f.
int filewrite(struct file *f, char *addr, int n)
{
80100ead:	55                   	push   %ebp
80100eae:	89 e5                	mov    %esp,%ebp
80100eb0:	57                   	push   %edi
80100eb1:	56                   	push   %esi
80100eb2:	53                   	push   %ebx
80100eb3:	83 ec 1c             	sub    $0x1c,%esp
80100eb6:	8b 75 08             	mov    0x8(%ebp),%esi
    int r;

    if (f->writable == 0)
80100eb9:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
80100ebd:	0f 84 e8 00 00 00    	je     80100fab <filewrite+0xfe>
        return -1;
    if (f->type == FD_PIPE)
80100ec3:	8b 06                	mov    (%esi),%eax
80100ec5:	83 f8 01             	cmp    $0x1,%eax
80100ec8:	74 1a                	je     80100ee4 <filewrite+0x37>
        return pipewrite(f->pipe, addr, n);
    if (f->type == FD_INODE) {
80100eca:	83 f8 02             	cmp    $0x2,%eax
80100ecd:	0f 85 cb 00 00 00    	jne    80100f9e <filewrite+0xf1>
        // and 2 blocks of slop for non-aligned writes.
        // this really belongs lower down, since writei()
        // might be writing a device like the console.
        int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * 512;
        int i = 0;
        while (i < n) {
80100ed3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100ed7:	0f 8e 9e 00 00 00    	jle    80100f7b <filewrite+0xce>
        int i = 0;
80100edd:	bf 00 00 00 00       	mov    $0x0,%edi
80100ee2:	eb 3f                	jmp    80100f23 <filewrite+0x76>
        return pipewrite(f->pipe, addr, n);
80100ee4:	83 ec 04             	sub    $0x4,%esp
80100ee7:	ff 75 10             	pushl  0x10(%ebp)
80100eea:	ff 75 0c             	pushl  0xc(%ebp)
80100eed:	ff 76 0c             	pushl  0xc(%esi)
80100ef0:	e8 b0 21 00 00       	call   801030a5 <pipewrite>
80100ef5:	89 45 10             	mov    %eax,0x10(%ebp)
80100ef8:	83 c4 10             	add    $0x10,%esp
80100efb:	e9 93 00 00 00       	jmp    80100f93 <filewrite+0xe6>

            begin_op();
            ilock(f->ip);
            if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
                f->off += r;
            iunlock(f->ip);
80100f00:	83 ec 0c             	sub    $0xc,%esp
80100f03:	ff 76 10             	pushl  0x10(%esi)
80100f06:	e8 9d 06 00 00       	call   801015a8 <iunlock>
            end_op();
80100f0b:	e8 18 19 00 00       	call   80102828 <end_op>

            if (r < 0)
80100f10:	83 c4 10             	add    $0x10,%esp
80100f13:	85 db                	test   %ebx,%ebx
80100f15:	78 6b                	js     80100f82 <filewrite+0xd5>
                break;
            if (r != n1)
80100f17:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100f1a:	75 4e                	jne    80100f6a <filewrite+0xbd>
                panic("short filewrite");
            i += r;
80100f1c:	01 df                	add    %ebx,%edi
        while (i < n) {
80100f1e:	39 7d 10             	cmp    %edi,0x10(%ebp)
80100f21:	7e 54                	jle    80100f77 <filewrite+0xca>
            int n1 = n - i;
80100f23:	8b 45 10             	mov    0x10(%ebp),%eax
80100f26:	29 f8                	sub    %edi,%eax
80100f28:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f2d:	ba 00 06 00 00       	mov    $0x600,%edx
80100f32:	0f 4f c2             	cmovg  %edx,%eax
80100f35:	89 c3                	mov    %eax,%ebx
80100f37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            begin_op();
80100f3a:	e8 6e 18 00 00       	call   801027ad <begin_op>
            ilock(f->ip);
80100f3f:	83 ec 0c             	sub    $0xc,%esp
80100f42:	ff 76 10             	pushl  0x10(%esi)
80100f45:	e8 9c 05 00 00       	call   801014e6 <ilock>
            if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100f4a:	53                   	push   %ebx
80100f4b:	ff 76 14             	pushl  0x14(%esi)
80100f4e:	89 f8                	mov    %edi,%eax
80100f50:	03 45 0c             	add    0xc(%ebp),%eax
80100f53:	50                   	push   %eax
80100f54:	ff 76 10             	pushl  0x10(%esi)
80100f57:	e8 1a 09 00 00       	call   80101876 <writei>
80100f5c:	89 c3                	mov    %eax,%ebx
80100f5e:	83 c4 20             	add    $0x20,%esp
80100f61:	85 c0                	test   %eax,%eax
80100f63:	7e 9b                	jle    80100f00 <filewrite+0x53>
                f->off += r;
80100f65:	01 46 14             	add    %eax,0x14(%esi)
80100f68:	eb 96                	jmp    80100f00 <filewrite+0x53>
                panic("short filewrite");
80100f6a:	83 ec 0c             	sub    $0xc,%esp
80100f6d:	68 af 69 10 80       	push   $0x801069af
80100f72:	e8 cd f3 ff ff       	call   80100344 <panic>
80100f77:	89 f8                	mov    %edi,%eax
80100f79:	eb 09                	jmp    80100f84 <filewrite+0xd7>
        int i = 0;
80100f7b:	b8 00 00 00 00       	mov    $0x0,%eax
80100f80:	eb 02                	jmp    80100f84 <filewrite+0xd7>
80100f82:	89 f8                	mov    %edi,%eax
        }
        return i == n ? n : -1;
80100f84:	39 45 10             	cmp    %eax,0x10(%ebp)
80100f87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f8c:	0f 44 45 10          	cmove  0x10(%ebp),%eax
80100f90:	89 45 10             	mov    %eax,0x10(%ebp)
    }
    panic("filewrite");
}
80100f93:	8b 45 10             	mov    0x10(%ebp),%eax
80100f96:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f99:	5b                   	pop    %ebx
80100f9a:	5e                   	pop    %esi
80100f9b:	5f                   	pop    %edi
80100f9c:	5d                   	pop    %ebp
80100f9d:	c3                   	ret    
    panic("filewrite");
80100f9e:	83 ec 0c             	sub    $0xc,%esp
80100fa1:	68 b5 69 10 80       	push   $0x801069b5
80100fa6:	e8 99 f3 ff ff       	call   80100344 <panic>
        return -1;
80100fab:	c7 45 10 ff ff ff ff 	movl   $0xffffffff,0x10(%ebp)
80100fb2:	eb df                	jmp    80100f93 <filewrite+0xe6>

80100fb4 <bfree>:
    panic("balloc: out of blocks");
}

// Free a disk block.
static void bfree(int dev, uint b)
{
80100fb4:	55                   	push   %ebp
80100fb5:	89 e5                	mov    %esp,%ebp
80100fb7:	56                   	push   %esi
80100fb8:	53                   	push   %ebx
80100fb9:	89 d3                	mov    %edx,%ebx
    struct buf *bp;
    int bi, m;

    bp = bread(dev, BBLOCK(b, sb));
80100fbb:	83 ec 08             	sub    $0x8,%esp
80100fbe:	c1 ea 0c             	shr    $0xc,%edx
80100fc1:	03 15 d8 09 11 80    	add    0x801109d8,%edx
80100fc7:	52                   	push   %edx
80100fc8:	50                   	push   %eax
80100fc9:	e8 dc f0 ff ff       	call   801000aa <bread>
80100fce:	89 c6                	mov    %eax,%esi
    bi = b % BPB;
    m = 1 << (bi % 8);
80100fd0:	89 d9                	mov    %ebx,%ecx
80100fd2:	83 e1 07             	and    $0x7,%ecx
80100fd5:	b8 01 00 00 00       	mov    $0x1,%eax
80100fda:	d3 e0                	shl    %cl,%eax
    bi = b % BPB;
80100fdc:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
    if ((bp->data[bi / 8] & m) == 0)
80100fe2:	83 c4 10             	add    $0x10,%esp
80100fe5:	c1 fb 03             	sar    $0x3,%ebx
80100fe8:	0f b6 54 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%edx
80100fed:	0f b6 ca             	movzbl %dl,%ecx
80100ff0:	85 c1                	test   %eax,%ecx
80100ff2:	74 23                	je     80101017 <bfree+0x63>
        panic("freeing free block");
    bp->data[bi / 8] &= ~m;
80100ff4:	f7 d0                	not    %eax
80100ff6:	21 d0                	and    %edx,%eax
80100ff8:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
    log_write(bp);
80100ffc:	83 ec 0c             	sub    $0xc,%esp
80100fff:	56                   	push   %esi
80101000:	e8 68 19 00 00       	call   8010296d <log_write>
    brelse(bp);
80101005:	89 34 24             	mov    %esi,(%esp)
80101008:	e8 b4 f1 ff ff       	call   801001c1 <brelse>
}
8010100d:	83 c4 10             	add    $0x10,%esp
80101010:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101013:	5b                   	pop    %ebx
80101014:	5e                   	pop    %esi
80101015:	5d                   	pop    %ebp
80101016:	c3                   	ret    
        panic("freeing free block");
80101017:	83 ec 0c             	sub    $0xc,%esp
8010101a:	68 bf 69 10 80       	push   $0x801069bf
8010101f:	e8 20 f3 ff ff       	call   80100344 <panic>

80101024 <balloc>:
{
80101024:	55                   	push   %ebp
80101025:	89 e5                	mov    %esp,%ebp
80101027:	57                   	push   %edi
80101028:	56                   	push   %esi
80101029:	53                   	push   %ebx
8010102a:	83 ec 2c             	sub    $0x2c,%esp
8010102d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    for (b = 0; b < sb.size; b += BPB) {
80101030:	83 3d c0 09 11 80 00 	cmpl   $0x0,0x801109c0
80101037:	0f 84 32 01 00 00    	je     8010116f <balloc+0x14b>
8010103d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
80101044:	e9 8f 00 00 00       	jmp    801010d8 <balloc+0xb4>
80101049:	89 c3                	mov    %eax,%ebx
                bp->data[bi / 8] |= m;         // Mark block in use.
8010104b:	09 ca                	or     %ecx,%edx
8010104d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101050:	88 54 03 5c          	mov    %dl,0x5c(%ebx,%eax,1)
                log_write(bp);
80101054:	83 ec 0c             	sub    $0xc,%esp
80101057:	53                   	push   %ebx
80101058:	e8 10 19 00 00       	call   8010296d <log_write>
                brelse(bp);
8010105d:	89 1c 24             	mov    %ebx,(%esp)
80101060:	e8 5c f1 ff ff       	call   801001c1 <brelse>
    bp = bread(dev, bno);
80101065:	83 c4 08             	add    $0x8,%esp
80101068:	ff 75 e4             	pushl  -0x1c(%ebp)
8010106b:	ff 75 d4             	pushl  -0x2c(%ebp)
8010106e:	e8 37 f0 ff ff       	call   801000aa <bread>
80101073:	89 c6                	mov    %eax,%esi
    memset(bp->data, 0, BSIZE);
80101075:	83 c4 0c             	add    $0xc,%esp
80101078:	68 00 02 00 00       	push   $0x200
8010107d:	6a 00                	push   $0x0
8010107f:	8d 40 5c             	lea    0x5c(%eax),%eax
80101082:	50                   	push   %eax
80101083:	e8 9b 30 00 00       	call   80104123 <memset>
    log_write(bp);
80101088:	89 34 24             	mov    %esi,(%esp)
8010108b:	e8 dd 18 00 00       	call   8010296d <log_write>
    brelse(bp);
80101090:	89 34 24             	mov    %esi,(%esp)
80101093:	e8 29 f1 ff ff       	call   801001c1 <brelse>
}
80101098:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010109b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010109e:	5b                   	pop    %ebx
8010109f:	5e                   	pop    %esi
801010a0:	5f                   	pop    %edi
801010a1:	5d                   	pop    %ebp
801010a2:	c3                   	ret    
801010a3:	89 c3                	mov    %eax,%ebx
        for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
801010a5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
            m = 1 << (bi % 8);
801010a8:	b9 01 00 00 00       	mov    $0x1,%ecx
            if ((bp->data[bi / 8] & m) == 0) { // Is block free?
801010ad:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
801010b4:	eb 95                	jmp    8010104b <balloc+0x27>
        brelse(bp);
801010b6:	83 ec 0c             	sub    $0xc,%esp
801010b9:	50                   	push   %eax
801010ba:	e8 02 f1 ff ff       	call   801001c1 <brelse>
    for (b = 0; b < sb.size; b += BPB) {
801010bf:	81 45 d8 00 10 00 00 	addl   $0x1000,-0x28(%ebp)
801010c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
801010c9:	83 c4 10             	add    $0x10,%esp
801010cc:	39 05 c0 09 11 80    	cmp    %eax,0x801109c0
801010d2:	0f 86 97 00 00 00    	jbe    8010116f <balloc+0x14b>
        bp = bread(dev, BBLOCK(b, sb));
801010d8:	83 ec 08             	sub    $0x8,%esp
801010db:	8b 7d d8             	mov    -0x28(%ebp),%edi
801010de:	89 fb                	mov    %edi,%ebx
801010e0:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
801010e6:	85 ff                	test   %edi,%edi
801010e8:	0f 49 c7             	cmovns %edi,%eax
801010eb:	c1 f8 0c             	sar    $0xc,%eax
801010ee:	03 05 d8 09 11 80    	add    0x801109d8,%eax
801010f4:	50                   	push   %eax
801010f5:	ff 75 d4             	pushl  -0x2c(%ebp)
801010f8:	e8 ad ef ff ff       	call   801000aa <bread>
        for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
801010fd:	8b 0d c0 09 11 80    	mov    0x801109c0,%ecx
80101103:	83 c4 10             	add    $0x10,%esp
80101106:	39 cf                	cmp    %ecx,%edi
80101108:	73 ac                	jae    801010b6 <balloc+0x92>
            if ((bp->data[bi / 8] & m) == 0) { // Is block free?
8010110a:	0f b6 50 5c          	movzbl 0x5c(%eax),%edx
8010110e:	f6 c2 01             	test   $0x1,%dl
80101111:	74 90                	je     801010a3 <balloc+0x7f>
80101113:	29 f9                	sub    %edi,%ecx
80101115:	89 4d e0             	mov    %ecx,-0x20(%ebp)
        for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
80101118:	be 01 00 00 00       	mov    $0x1,%esi
8010111d:	8d 3c 1e             	lea    (%esi,%ebx,1),%edi
80101120:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101123:	3b 75 e0             	cmp    -0x20(%ebp),%esi
80101126:	74 8e                	je     801010b6 <balloc+0x92>
            m = 1 << (bi % 8);
80101128:	89 f2                	mov    %esi,%edx
8010112a:	c1 fa 1f             	sar    $0x1f,%edx
8010112d:	c1 ea 1d             	shr    $0x1d,%edx
80101130:	8d 0c 16             	lea    (%esi,%edx,1),%ecx
80101133:	83 e1 07             	and    $0x7,%ecx
80101136:	29 d1                	sub    %edx,%ecx
80101138:	bf 01 00 00 00       	mov    $0x1,%edi
8010113d:	d3 e7                	shl    %cl,%edi
8010113f:	89 f9                	mov    %edi,%ecx
            if ((bp->data[bi / 8] & m) == 0) { // Is block free?
80101141:	8d 56 07             	lea    0x7(%esi),%edx
80101144:	85 f6                	test   %esi,%esi
80101146:	0f 49 d6             	cmovns %esi,%edx
80101149:	c1 fa 03             	sar    $0x3,%edx
8010114c:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010114f:	0f b6 54 10 5c       	movzbl 0x5c(%eax,%edx,1),%edx
80101154:	0f b6 fa             	movzbl %dl,%edi
80101157:	85 cf                	test   %ecx,%edi
80101159:	0f 84 ea fe ff ff    	je     80101049 <balloc+0x25>
        for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
8010115f:	83 c6 01             	add    $0x1,%esi
80101162:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
80101168:	75 b3                	jne    8010111d <balloc+0xf9>
8010116a:	e9 47 ff ff ff       	jmp    801010b6 <balloc+0x92>
    panic("balloc: out of blocks");
8010116f:	83 ec 0c             	sub    $0xc,%esp
80101172:	68 d2 69 10 80       	push   $0x801069d2
80101177:	e8 c8 f1 ff ff       	call   80100344 <panic>

8010117c <bmap>:
//  listed in block ip->addrs[NDIRECT].

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint bmap(struct inode *ip, uint bn)
{
8010117c:	55                   	push   %ebp
8010117d:	89 e5                	mov    %esp,%ebp
8010117f:	57                   	push   %edi
80101180:	56                   	push   %esi
80101181:	53                   	push   %ebx
80101182:	83 ec 1c             	sub    $0x1c,%esp
80101185:	89 c6                	mov    %eax,%esi
    uint addr, *a;
    struct buf *bp;

    if (bn < NDIRECT) {
80101187:	83 fa 0b             	cmp    $0xb,%edx
8010118a:	77 18                	ja     801011a4 <bmap+0x28>
8010118c:	8d 3c 90             	lea    (%eax,%edx,4),%edi
        if ((addr = ip->addrs[bn]) == 0)
8010118f:	8b 5f 5c             	mov    0x5c(%edi),%ebx
80101192:	85 db                	test   %ebx,%ebx
80101194:	75 49                	jne    801011df <bmap+0x63>
            ip->addrs[bn] = addr = balloc(ip->dev);
80101196:	8b 00                	mov    (%eax),%eax
80101198:	e8 87 fe ff ff       	call   80101024 <balloc>
8010119d:	89 c3                	mov    %eax,%ebx
8010119f:	89 47 5c             	mov    %eax,0x5c(%edi)
801011a2:	eb 3b                	jmp    801011df <bmap+0x63>
        return addr;
    }
    bn -= NDIRECT;
801011a4:	8d 5a f4             	lea    -0xc(%edx),%ebx

    if (bn < NINDIRECT) {
801011a7:	83 fb 7f             	cmp    $0x7f,%ebx
801011aa:	77 68                	ja     80101214 <bmap+0x98>
        // Load indirect block, allocating if necessary.
        if ((addr = ip->addrs[NDIRECT]) == 0)
801011ac:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
801011b2:	85 c0                	test   %eax,%eax
801011b4:	74 33                	je     801011e9 <bmap+0x6d>
            ip->addrs[NDIRECT] = addr = balloc(ip->dev);
        bp = bread(ip->dev, addr);
801011b6:	83 ec 08             	sub    $0x8,%esp
801011b9:	50                   	push   %eax
801011ba:	ff 36                	pushl  (%esi)
801011bc:	e8 e9 ee ff ff       	call   801000aa <bread>
801011c1:	89 c7                	mov    %eax,%edi
        a = (uint *)bp->data;
        if ((addr = a[bn]) == 0) {
801011c3:	8d 44 98 5c          	lea    0x5c(%eax,%ebx,4),%eax
801011c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801011ca:	8b 18                	mov    (%eax),%ebx
801011cc:	83 c4 10             	add    $0x10,%esp
801011cf:	85 db                	test   %ebx,%ebx
801011d1:	74 25                	je     801011f8 <bmap+0x7c>
            a[bn] = addr = balloc(ip->dev);
            log_write(bp);
        }
        brelse(bp);
801011d3:	83 ec 0c             	sub    $0xc,%esp
801011d6:	57                   	push   %edi
801011d7:	e8 e5 ef ff ff       	call   801001c1 <brelse>
        return addr;
801011dc:	83 c4 10             	add    $0x10,%esp
    }

    panic("bmap: out of range");
}
801011df:	89 d8                	mov    %ebx,%eax
801011e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011e4:	5b                   	pop    %ebx
801011e5:	5e                   	pop    %esi
801011e6:	5f                   	pop    %edi
801011e7:	5d                   	pop    %ebp
801011e8:	c3                   	ret    
            ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801011e9:	8b 06                	mov    (%esi),%eax
801011eb:	e8 34 fe ff ff       	call   80101024 <balloc>
801011f0:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
801011f6:	eb be                	jmp    801011b6 <bmap+0x3a>
            a[bn] = addr = balloc(ip->dev);
801011f8:	8b 06                	mov    (%esi),%eax
801011fa:	e8 25 fe ff ff       	call   80101024 <balloc>
801011ff:	89 c3                	mov    %eax,%ebx
80101201:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101204:	89 18                	mov    %ebx,(%eax)
            log_write(bp);
80101206:	83 ec 0c             	sub    $0xc,%esp
80101209:	57                   	push   %edi
8010120a:	e8 5e 17 00 00       	call   8010296d <log_write>
8010120f:	83 c4 10             	add    $0x10,%esp
80101212:	eb bf                	jmp    801011d3 <bmap+0x57>
    panic("bmap: out of range");
80101214:	83 ec 0c             	sub    $0xc,%esp
80101217:	68 e8 69 10 80       	push   $0x801069e8
8010121c:	e8 23 f1 ff ff       	call   80100344 <panic>

80101221 <iget>:
{
80101221:	55                   	push   %ebp
80101222:	89 e5                	mov    %esp,%ebp
80101224:	57                   	push   %edi
80101225:	56                   	push   %esi
80101226:	53                   	push   %ebx
80101227:	83 ec 28             	sub    $0x28,%esp
8010122a:	89 c7                	mov    %eax,%edi
8010122c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    acquire(&icache.lock);
8010122f:	68 e0 09 11 80       	push   $0x801109e0
80101234:	e8 3c 2e 00 00       	call   80104075 <acquire>
80101239:	83 c4 10             	add    $0x10,%esp
    empty = 0;
8010123c:	be 00 00 00 00       	mov    $0x0,%esi
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101241:	bb 14 0a 11 80       	mov    $0x80110a14,%ebx
80101246:	eb 1c                	jmp    80101264 <iget+0x43>
        if (empty == 0 && ip->ref == 0) // Remember empty slot.
80101248:	85 c0                	test   %eax,%eax
8010124a:	75 0a                	jne    80101256 <iget+0x35>
8010124c:	85 f6                	test   %esi,%esi
8010124e:	0f 94 c0             	sete   %al
80101251:	84 c0                	test   %al,%al
80101253:	0f 45 f3             	cmovne %ebx,%esi
    for (ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++) {
80101256:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010125c:	81 fb 34 26 11 80    	cmp    $0x80112634,%ebx
80101262:	73 2d                	jae    80101291 <iget+0x70>
        if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
80101264:	8b 43 08             	mov    0x8(%ebx),%eax
80101267:	85 c0                	test   %eax,%eax
80101269:	7e dd                	jle    80101248 <iget+0x27>
8010126b:	39 3b                	cmp    %edi,(%ebx)
8010126d:	75 e7                	jne    80101256 <iget+0x35>
8010126f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101272:	39 4b 04             	cmp    %ecx,0x4(%ebx)
80101275:	75 df                	jne    80101256 <iget+0x35>
            ip->ref++;
80101277:	83 c0 01             	add    $0x1,%eax
8010127a:	89 43 08             	mov    %eax,0x8(%ebx)
            release(&icache.lock);
8010127d:	83 ec 0c             	sub    $0xc,%esp
80101280:	68 e0 09 11 80       	push   $0x801109e0
80101285:	e8 52 2e 00 00       	call   801040dc <release>
            return ip;
8010128a:	83 c4 10             	add    $0x10,%esp
8010128d:	89 de                	mov    %ebx,%esi
8010128f:	eb 2a                	jmp    801012bb <iget+0x9a>
    if (empty == 0)
80101291:	85 f6                	test   %esi,%esi
80101293:	74 30                	je     801012c5 <iget+0xa4>
    ip->dev = dev;
80101295:	89 3e                	mov    %edi,(%esi)
    ip->inum = inum;
80101297:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010129a:	89 46 04             	mov    %eax,0x4(%esi)
    ip->ref = 1;
8010129d:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
    ip->valid = 0;
801012a4:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
    release(&icache.lock);
801012ab:	83 ec 0c             	sub    $0xc,%esp
801012ae:	68 e0 09 11 80       	push   $0x801109e0
801012b3:	e8 24 2e 00 00       	call   801040dc <release>
    return ip;
801012b8:	83 c4 10             	add    $0x10,%esp
}
801012bb:	89 f0                	mov    %esi,%eax
801012bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801012c0:	5b                   	pop    %ebx
801012c1:	5e                   	pop    %esi
801012c2:	5f                   	pop    %edi
801012c3:	5d                   	pop    %ebp
801012c4:	c3                   	ret    
        panic("iget: no inodes");
801012c5:	83 ec 0c             	sub    $0xc,%esp
801012c8:	68 fb 69 10 80       	push   $0x801069fb
801012cd:	e8 72 f0 ff ff       	call   80100344 <panic>

801012d2 <readsb>:
{
801012d2:	55                   	push   %ebp
801012d3:	89 e5                	mov    %esp,%ebp
801012d5:	53                   	push   %ebx
801012d6:	83 ec 0c             	sub    $0xc,%esp
    bp = bread(dev, 1);
801012d9:	6a 01                	push   $0x1
801012db:	ff 75 08             	pushl  0x8(%ebp)
801012de:	e8 c7 ed ff ff       	call   801000aa <bread>
801012e3:	89 c3                	mov    %eax,%ebx
    memmove(sb, bp->data, sizeof(*sb));
801012e5:	83 c4 0c             	add    $0xc,%esp
801012e8:	6a 1c                	push   $0x1c
801012ea:	8d 40 5c             	lea    0x5c(%eax),%eax
801012ed:	50                   	push   %eax
801012ee:	ff 75 0c             	pushl  0xc(%ebp)
801012f1:	e8 c2 2e 00 00       	call   801041b8 <memmove>
    brelse(bp);
801012f6:	89 1c 24             	mov    %ebx,(%esp)
801012f9:	e8 c3 ee ff ff       	call   801001c1 <brelse>
}
801012fe:	83 c4 10             	add    $0x10,%esp
80101301:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101304:	c9                   	leave  
80101305:	c3                   	ret    

80101306 <iinit>:
{
80101306:	55                   	push   %ebp
80101307:	89 e5                	mov    %esp,%ebp
80101309:	56                   	push   %esi
8010130a:	53                   	push   %ebx
    initlock(&icache.lock, "icache");
8010130b:	83 ec 08             	sub    $0x8,%esp
8010130e:	68 0b 6a 10 80       	push   $0x80106a0b
80101313:	68 e0 09 11 80       	push   $0x801109e0
80101318:	e8 10 2c 00 00       	call   80103f2d <initlock>
8010131d:	bb 20 0a 11 80       	mov    $0x80110a20,%ebx
80101322:	be 40 26 11 80       	mov    $0x80112640,%esi
80101327:	83 c4 10             	add    $0x10,%esp
        initsleeplock(&icache.inode[i].lock, "inode");
8010132a:	83 ec 08             	sub    $0x8,%esp
8010132d:	68 12 6a 10 80       	push   $0x80106a12
80101332:	53                   	push   %ebx
80101333:	e8 eb 2a 00 00       	call   80103e23 <initsleeplock>
80101338:	81 c3 90 00 00 00    	add    $0x90,%ebx
    for (i = 0; i < NINODE; i++) {
8010133e:	83 c4 10             	add    $0x10,%esp
80101341:	39 f3                	cmp    %esi,%ebx
80101343:	75 e5                	jne    8010132a <iinit+0x24>
    readsb(dev, &sb);
80101345:	83 ec 08             	sub    $0x8,%esp
80101348:	68 c0 09 11 80       	push   $0x801109c0
8010134d:	ff 75 08             	pushl  0x8(%ebp)
80101350:	e8 7d ff ff ff       	call   801012d2 <readsb>
    cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101355:	ff 35 d8 09 11 80    	pushl  0x801109d8
8010135b:	ff 35 d4 09 11 80    	pushl  0x801109d4
80101361:	ff 35 d0 09 11 80    	pushl  0x801109d0
80101367:	ff 35 cc 09 11 80    	pushl  0x801109cc
8010136d:	ff 35 c8 09 11 80    	pushl  0x801109c8
80101373:	ff 35 c4 09 11 80    	pushl  0x801109c4
80101379:	ff 35 c0 09 11 80    	pushl  0x801109c0
8010137f:	68 78 6a 10 80       	push   $0x80106a78
80101384:	e8 58 f2 ff ff       	call   801005e1 <cprintf>
}
80101389:	83 c4 30             	add    $0x30,%esp
8010138c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010138f:	5b                   	pop    %ebx
80101390:	5e                   	pop    %esi
80101391:	5d                   	pop    %ebp
80101392:	c3                   	ret    

80101393 <ialloc>:
{
80101393:	55                   	push   %ebp
80101394:	89 e5                	mov    %esp,%ebp
80101396:	57                   	push   %edi
80101397:	56                   	push   %esi
80101398:	53                   	push   %ebx
80101399:	83 ec 1c             	sub    $0x1c,%esp
8010139c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010139f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    for (inum = 1; inum < sb.ninodes; inum++) {
801013a2:	83 3d c8 09 11 80 01 	cmpl   $0x1,0x801109c8
801013a9:	76 4d                	jbe    801013f8 <ialloc+0x65>
801013ab:	bb 01 00 00 00       	mov    $0x1,%ebx
801013b0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
        bp = bread(dev, IBLOCK(inum, sb));
801013b3:	83 ec 08             	sub    $0x8,%esp
801013b6:	89 d8                	mov    %ebx,%eax
801013b8:	c1 e8 03             	shr    $0x3,%eax
801013bb:	03 05 d4 09 11 80    	add    0x801109d4,%eax
801013c1:	50                   	push   %eax
801013c2:	ff 75 08             	pushl  0x8(%ebp)
801013c5:	e8 e0 ec ff ff       	call   801000aa <bread>
801013ca:	89 c6                	mov    %eax,%esi
        dip = (struct dinode *)bp->data + inum % IPB;
801013cc:	89 d8                	mov    %ebx,%eax
801013ce:	83 e0 07             	and    $0x7,%eax
801013d1:	c1 e0 06             	shl    $0x6,%eax
801013d4:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
        if (dip->type == 0) { // a free inode
801013d8:	83 c4 10             	add    $0x10,%esp
801013db:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013df:	74 24                	je     80101405 <ialloc+0x72>
        brelse(bp);
801013e1:	83 ec 0c             	sub    $0xc,%esp
801013e4:	56                   	push   %esi
801013e5:	e8 d7 ed ff ff       	call   801001c1 <brelse>
    for (inum = 1; inum < sb.ninodes; inum++) {
801013ea:	83 c3 01             	add    $0x1,%ebx
801013ed:	83 c4 10             	add    $0x10,%esp
801013f0:	39 1d c8 09 11 80    	cmp    %ebx,0x801109c8
801013f6:	77 b8                	ja     801013b0 <ialloc+0x1d>
    panic("ialloc: no inodes");
801013f8:	83 ec 0c             	sub    $0xc,%esp
801013fb:	68 18 6a 10 80       	push   $0x80106a18
80101400:	e8 3f ef ff ff       	call   80100344 <panic>
            memset(dip, 0, sizeof(*dip));
80101405:	83 ec 04             	sub    $0x4,%esp
80101408:	6a 40                	push   $0x40
8010140a:	6a 00                	push   $0x0
8010140c:	57                   	push   %edi
8010140d:	e8 11 2d 00 00       	call   80104123 <memset>
            dip->type = type;
80101412:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80101416:	66 89 07             	mov    %ax,(%edi)
            log_write(bp); // mark it allocated on the disk
80101419:	89 34 24             	mov    %esi,(%esp)
8010141c:	e8 4c 15 00 00       	call   8010296d <log_write>
            brelse(bp);
80101421:	89 34 24             	mov    %esi,(%esp)
80101424:	e8 98 ed ff ff       	call   801001c1 <brelse>
            return iget(dev, inum);
80101429:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010142c:	8b 45 08             	mov    0x8(%ebp),%eax
8010142f:	e8 ed fd ff ff       	call   80101221 <iget>
}
80101434:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101437:	5b                   	pop    %ebx
80101438:	5e                   	pop    %esi
80101439:	5f                   	pop    %edi
8010143a:	5d                   	pop    %ebp
8010143b:	c3                   	ret    

8010143c <iupdate>:
{
8010143c:	55                   	push   %ebp
8010143d:	89 e5                	mov    %esp,%ebp
8010143f:	56                   	push   %esi
80101440:	53                   	push   %ebx
80101441:	8b 5d 08             	mov    0x8(%ebp),%ebx
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101444:	83 ec 08             	sub    $0x8,%esp
80101447:	8b 43 04             	mov    0x4(%ebx),%eax
8010144a:	c1 e8 03             	shr    $0x3,%eax
8010144d:	03 05 d4 09 11 80    	add    0x801109d4,%eax
80101453:	50                   	push   %eax
80101454:	ff 33                	pushl  (%ebx)
80101456:	e8 4f ec ff ff       	call   801000aa <bread>
8010145b:	89 c6                	mov    %eax,%esi
    dip = (struct dinode *)bp->data + ip->inum % IPB;
8010145d:	8b 43 04             	mov    0x4(%ebx),%eax
80101460:	83 e0 07             	and    $0x7,%eax
80101463:	c1 e0 06             	shl    $0x6,%eax
80101466:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    dip->type = ip->type;
8010146a:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
8010146e:	66 89 10             	mov    %dx,(%eax)
    dip->major = ip->major;
80101471:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
80101475:	66 89 50 02          	mov    %dx,0x2(%eax)
    dip->minor = ip->minor;
80101479:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
8010147d:	66 89 50 04          	mov    %dx,0x4(%eax)
    dip->nlink = ip->nlink;
80101481:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
80101485:	66 89 50 06          	mov    %dx,0x6(%eax)
    dip->size = ip->size;
80101489:	8b 53 58             	mov    0x58(%ebx),%edx
8010148c:	89 50 08             	mov    %edx,0x8(%eax)
    memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010148f:	83 c4 0c             	add    $0xc,%esp
80101492:	6a 34                	push   $0x34
80101494:	83 c3 5c             	add    $0x5c,%ebx
80101497:	53                   	push   %ebx
80101498:	83 c0 0c             	add    $0xc,%eax
8010149b:	50                   	push   %eax
8010149c:	e8 17 2d 00 00       	call   801041b8 <memmove>
    log_write(bp);
801014a1:	89 34 24             	mov    %esi,(%esp)
801014a4:	e8 c4 14 00 00       	call   8010296d <log_write>
    brelse(bp);
801014a9:	89 34 24             	mov    %esi,(%esp)
801014ac:	e8 10 ed ff ff       	call   801001c1 <brelse>
}
801014b1:	83 c4 10             	add    $0x10,%esp
801014b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801014b7:	5b                   	pop    %ebx
801014b8:	5e                   	pop    %esi
801014b9:	5d                   	pop    %ebp
801014ba:	c3                   	ret    

801014bb <idup>:
{
801014bb:	55                   	push   %ebp
801014bc:	89 e5                	mov    %esp,%ebp
801014be:	53                   	push   %ebx
801014bf:	83 ec 10             	sub    $0x10,%esp
801014c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
    acquire(&icache.lock);
801014c5:	68 e0 09 11 80       	push   $0x801109e0
801014ca:	e8 a6 2b 00 00       	call   80104075 <acquire>
    ip->ref++;
801014cf:	83 43 08 01          	addl   $0x1,0x8(%ebx)
    release(&icache.lock);
801014d3:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801014da:	e8 fd 2b 00 00       	call   801040dc <release>
}
801014df:	89 d8                	mov    %ebx,%eax
801014e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801014e4:	c9                   	leave  
801014e5:	c3                   	ret    

801014e6 <ilock>:
{
801014e6:	55                   	push   %ebp
801014e7:	89 e5                	mov    %esp,%ebp
801014e9:	56                   	push   %esi
801014ea:	53                   	push   %ebx
801014eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (ip == 0 || ip->ref < 1)
801014ee:	85 db                	test   %ebx,%ebx
801014f0:	74 22                	je     80101514 <ilock+0x2e>
801014f2:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
801014f6:	7e 1c                	jle    80101514 <ilock+0x2e>
    acquiresleep(&ip->lock);
801014f8:	83 ec 0c             	sub    $0xc,%esp
801014fb:	8d 43 0c             	lea    0xc(%ebx),%eax
801014fe:	50                   	push   %eax
801014ff:	e8 52 29 00 00       	call   80103e56 <acquiresleep>
    if (ip->valid == 0) {
80101504:	83 c4 10             	add    $0x10,%esp
80101507:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
8010150b:	74 14                	je     80101521 <ilock+0x3b>
}
8010150d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101510:	5b                   	pop    %ebx
80101511:	5e                   	pop    %esi
80101512:	5d                   	pop    %ebp
80101513:	c3                   	ret    
        panic("ilock");
80101514:	83 ec 0c             	sub    $0xc,%esp
80101517:	68 2a 6a 10 80       	push   $0x80106a2a
8010151c:	e8 23 ee ff ff       	call   80100344 <panic>
        bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101521:	83 ec 08             	sub    $0x8,%esp
80101524:	8b 43 04             	mov    0x4(%ebx),%eax
80101527:	c1 e8 03             	shr    $0x3,%eax
8010152a:	03 05 d4 09 11 80    	add    0x801109d4,%eax
80101530:	50                   	push   %eax
80101531:	ff 33                	pushl  (%ebx)
80101533:	e8 72 eb ff ff       	call   801000aa <bread>
80101538:	89 c6                	mov    %eax,%esi
        dip = (struct dinode *)bp->data + ip->inum % IPB;
8010153a:	8b 43 04             	mov    0x4(%ebx),%eax
8010153d:	83 e0 07             	and    $0x7,%eax
80101540:	c1 e0 06             	shl    $0x6,%eax
80101543:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
        ip->type = dip->type;
80101547:	0f b7 10             	movzwl (%eax),%edx
8010154a:	66 89 53 50          	mov    %dx,0x50(%ebx)
        ip->major = dip->major;
8010154e:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101552:	66 89 53 52          	mov    %dx,0x52(%ebx)
        ip->minor = dip->minor;
80101556:	0f b7 50 04          	movzwl 0x4(%eax),%edx
8010155a:	66 89 53 54          	mov    %dx,0x54(%ebx)
        ip->nlink = dip->nlink;
8010155e:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101562:	66 89 53 56          	mov    %dx,0x56(%ebx)
        ip->size = dip->size;
80101566:	8b 50 08             	mov    0x8(%eax),%edx
80101569:	89 53 58             	mov    %edx,0x58(%ebx)
        memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010156c:	83 c4 0c             	add    $0xc,%esp
8010156f:	6a 34                	push   $0x34
80101571:	83 c0 0c             	add    $0xc,%eax
80101574:	50                   	push   %eax
80101575:	8d 43 5c             	lea    0x5c(%ebx),%eax
80101578:	50                   	push   %eax
80101579:	e8 3a 2c 00 00       	call   801041b8 <memmove>
        brelse(bp);
8010157e:	89 34 24             	mov    %esi,(%esp)
80101581:	e8 3b ec ff ff       	call   801001c1 <brelse>
        ip->valid = 1;
80101586:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
        if (ip->type == 0)
8010158d:	83 c4 10             	add    $0x10,%esp
80101590:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
80101595:	0f 85 72 ff ff ff    	jne    8010150d <ilock+0x27>
            panic("ilock: no type");
8010159b:	83 ec 0c             	sub    $0xc,%esp
8010159e:	68 30 6a 10 80       	push   $0x80106a30
801015a3:	e8 9c ed ff ff       	call   80100344 <panic>

801015a8 <iunlock>:
{
801015a8:	55                   	push   %ebp
801015a9:	89 e5                	mov    %esp,%ebp
801015ab:	56                   	push   %esi
801015ac:	53                   	push   %ebx
801015ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801015b0:	85 db                	test   %ebx,%ebx
801015b2:	74 2c                	je     801015e0 <iunlock+0x38>
801015b4:	8d 73 0c             	lea    0xc(%ebx),%esi
801015b7:	83 ec 0c             	sub    $0xc,%esp
801015ba:	56                   	push   %esi
801015bb:	e8 23 29 00 00       	call   80103ee3 <holdingsleep>
801015c0:	83 c4 10             	add    $0x10,%esp
801015c3:	85 c0                	test   %eax,%eax
801015c5:	74 19                	je     801015e0 <iunlock+0x38>
801015c7:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
801015cb:	7e 13                	jle    801015e0 <iunlock+0x38>
    releasesleep(&ip->lock);
801015cd:	83 ec 0c             	sub    $0xc,%esp
801015d0:	56                   	push   %esi
801015d1:	e8 d2 28 00 00       	call   80103ea8 <releasesleep>
}
801015d6:	83 c4 10             	add    $0x10,%esp
801015d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015dc:	5b                   	pop    %ebx
801015dd:	5e                   	pop    %esi
801015de:	5d                   	pop    %ebp
801015df:	c3                   	ret    
        panic("iunlock");
801015e0:	83 ec 0c             	sub    $0xc,%esp
801015e3:	68 3f 6a 10 80       	push   $0x80106a3f
801015e8:	e8 57 ed ff ff       	call   80100344 <panic>

801015ed <iput>:
{
801015ed:	55                   	push   %ebp
801015ee:	89 e5                	mov    %esp,%ebp
801015f0:	57                   	push   %edi
801015f1:	56                   	push   %esi
801015f2:	53                   	push   %ebx
801015f3:	83 ec 28             	sub    $0x28,%esp
801015f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
    acquiresleep(&ip->lock);
801015f9:	8d 73 0c             	lea    0xc(%ebx),%esi
801015fc:	56                   	push   %esi
801015fd:	e8 54 28 00 00       	call   80103e56 <acquiresleep>
    if (ip->valid && ip->nlink == 0) {
80101602:	83 c4 10             	add    $0x10,%esp
80101605:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
80101609:	74 07                	je     80101612 <iput+0x25>
8010160b:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80101610:	74 30                	je     80101642 <iput+0x55>
    releasesleep(&ip->lock);
80101612:	83 ec 0c             	sub    $0xc,%esp
80101615:	56                   	push   %esi
80101616:	e8 8d 28 00 00       	call   80103ea8 <releasesleep>
    acquire(&icache.lock);
8010161b:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101622:	e8 4e 2a 00 00       	call   80104075 <acquire>
    ip->ref--;
80101627:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
    release(&icache.lock);
8010162b:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101632:	e8 a5 2a 00 00       	call   801040dc <release>
}
80101637:	83 c4 10             	add    $0x10,%esp
8010163a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010163d:	5b                   	pop    %ebx
8010163e:	5e                   	pop    %esi
8010163f:	5f                   	pop    %edi
80101640:	5d                   	pop    %ebp
80101641:	c3                   	ret    
        acquire(&icache.lock);
80101642:	83 ec 0c             	sub    $0xc,%esp
80101645:	68 e0 09 11 80       	push   $0x801109e0
8010164a:	e8 26 2a 00 00       	call   80104075 <acquire>
        int r = ip->ref;
8010164f:	8b 7b 08             	mov    0x8(%ebx),%edi
        release(&icache.lock);
80101652:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101659:	e8 7e 2a 00 00       	call   801040dc <release>
        if (r == 1) {
8010165e:	83 c4 10             	add    $0x10,%esp
80101661:	83 ff 01             	cmp    $0x1,%edi
80101664:	75 ac                	jne    80101612 <iput+0x25>
80101666:	8d 7b 5c             	lea    0x5c(%ebx),%edi
80101669:	8d 83 8c 00 00 00    	lea    0x8c(%ebx),%eax
8010166f:	89 75 e4             	mov    %esi,-0x1c(%ebp)
80101672:	89 c6                	mov    %eax,%esi
80101674:	eb 07                	jmp    8010167d <iput+0x90>
80101676:	83 c7 04             	add    $0x4,%edi
{
    int i, j;
    struct buf *bp;
    uint *a;

    for (i = 0; i < NDIRECT; i++) {
80101679:	39 f7                	cmp    %esi,%edi
8010167b:	74 15                	je     80101692 <iput+0xa5>
        if (ip->addrs[i]) {
8010167d:	8b 17                	mov    (%edi),%edx
8010167f:	85 d2                	test   %edx,%edx
80101681:	74 f3                	je     80101676 <iput+0x89>
            bfree(ip->dev, ip->addrs[i]);
80101683:	8b 03                	mov    (%ebx),%eax
80101685:	e8 2a f9 ff ff       	call   80100fb4 <bfree>
            ip->addrs[i] = 0;
8010168a:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
80101690:	eb e4                	jmp    80101676 <iput+0x89>
80101692:	8b 75 e4             	mov    -0x1c(%ebp),%esi
        }
    }

    if (ip->addrs[NDIRECT]) {
80101695:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
8010169b:	85 c0                	test   %eax,%eax
8010169d:	75 2d                	jne    801016cc <iput+0xdf>
        brelse(bp);
        bfree(ip->dev, ip->addrs[NDIRECT]);
        ip->addrs[NDIRECT] = 0;
    }

    ip->size = 0;
8010169f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
    iupdate(ip);
801016a6:	83 ec 0c             	sub    $0xc,%esp
801016a9:	53                   	push   %ebx
801016aa:	e8 8d fd ff ff       	call   8010143c <iupdate>
            ip->type = 0;
801016af:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
            iupdate(ip);
801016b5:	89 1c 24             	mov    %ebx,(%esp)
801016b8:	e8 7f fd ff ff       	call   8010143c <iupdate>
            ip->valid = 0;
801016bd:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
801016c4:	83 c4 10             	add    $0x10,%esp
801016c7:	e9 46 ff ff ff       	jmp    80101612 <iput+0x25>
        bp = bread(ip->dev, ip->addrs[NDIRECT]);
801016cc:	83 ec 08             	sub    $0x8,%esp
801016cf:	50                   	push   %eax
801016d0:	ff 33                	pushl  (%ebx)
801016d2:	e8 d3 e9 ff ff       	call   801000aa <bread>
801016d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        a = (uint *)bp->data;
801016da:	8d 78 5c             	lea    0x5c(%eax),%edi
801016dd:	05 5c 02 00 00       	add    $0x25c,%eax
801016e2:	83 c4 10             	add    $0x10,%esp
801016e5:	89 75 e0             	mov    %esi,-0x20(%ebp)
801016e8:	89 c6                	mov    %eax,%esi
801016ea:	eb 07                	jmp    801016f3 <iput+0x106>
801016ec:	83 c7 04             	add    $0x4,%edi
        for (j = 0; j < NINDIRECT; j++) {
801016ef:	39 fe                	cmp    %edi,%esi
801016f1:	74 0f                	je     80101702 <iput+0x115>
            if (a[j])
801016f3:	8b 17                	mov    (%edi),%edx
801016f5:	85 d2                	test   %edx,%edx
801016f7:	74 f3                	je     801016ec <iput+0xff>
                bfree(ip->dev, a[j]);
801016f9:	8b 03                	mov    (%ebx),%eax
801016fb:	e8 b4 f8 ff ff       	call   80100fb4 <bfree>
80101700:	eb ea                	jmp    801016ec <iput+0xff>
80101702:	8b 75 e0             	mov    -0x20(%ebp),%esi
        brelse(bp);
80101705:	83 ec 0c             	sub    $0xc,%esp
80101708:	ff 75 e4             	pushl  -0x1c(%ebp)
8010170b:	e8 b1 ea ff ff       	call   801001c1 <brelse>
        bfree(ip->dev, ip->addrs[NDIRECT]);
80101710:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
80101716:	8b 03                	mov    (%ebx),%eax
80101718:	e8 97 f8 ff ff       	call   80100fb4 <bfree>
        ip->addrs[NDIRECT] = 0;
8010171d:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80101724:	00 00 00 
80101727:	83 c4 10             	add    $0x10,%esp
8010172a:	e9 70 ff ff ff       	jmp    8010169f <iput+0xb2>

8010172f <iunlockput>:
{
8010172f:	55                   	push   %ebp
80101730:	89 e5                	mov    %esp,%ebp
80101732:	53                   	push   %ebx
80101733:	83 ec 10             	sub    $0x10,%esp
80101736:	8b 5d 08             	mov    0x8(%ebp),%ebx
    iunlock(ip);
80101739:	53                   	push   %ebx
8010173a:	e8 69 fe ff ff       	call   801015a8 <iunlock>
    iput(ip);
8010173f:	89 1c 24             	mov    %ebx,(%esp)
80101742:	e8 a6 fe ff ff       	call   801015ed <iput>
}
80101747:	83 c4 10             	add    $0x10,%esp
8010174a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010174d:	c9                   	leave  
8010174e:	c3                   	ret    

8010174f <stati>:
}

// Copy stat information from inode.
// Caller must hold ip->lock.
void stati(struct inode *ip, struct stat *st)
{
8010174f:	55                   	push   %ebp
80101750:	89 e5                	mov    %esp,%ebp
80101752:	8b 55 08             	mov    0x8(%ebp),%edx
80101755:	8b 45 0c             	mov    0xc(%ebp),%eax
    st->dev = ip->dev;
80101758:	8b 0a                	mov    (%edx),%ecx
8010175a:	89 48 04             	mov    %ecx,0x4(%eax)
    st->ino = ip->inum;
8010175d:	8b 4a 04             	mov    0x4(%edx),%ecx
80101760:	89 48 08             	mov    %ecx,0x8(%eax)
    st->type = ip->type;
80101763:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101767:	66 89 08             	mov    %cx,(%eax)
    st->nlink = ip->nlink;
8010176a:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
8010176e:	66 89 48 0c          	mov    %cx,0xc(%eax)
    st->size = ip->size;
80101772:	8b 52 58             	mov    0x58(%edx),%edx
80101775:	89 50 10             	mov    %edx,0x10(%eax)
}
80101778:	5d                   	pop    %ebp
80101779:	c3                   	ret    

8010177a <readi>:

// PAGEBREAK!
//  Read data from inode.
//  Caller must hold ip->lock.
int readi(struct inode *ip, char *dst, uint off, uint n)
{
8010177a:	55                   	push   %ebp
8010177b:	89 e5                	mov    %esp,%ebp
8010177d:	57                   	push   %edi
8010177e:	56                   	push   %esi
8010177f:	53                   	push   %ebx
80101780:	83 ec 1c             	sub    $0x1c,%esp
80101783:	8b 7d 10             	mov    0x10(%ebp),%edi
    uint tot, m;
    struct buf *bp;

    if (ip->type == T_DEV) {
80101786:	8b 45 08             	mov    0x8(%ebp),%eax
80101789:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010178e:	0f 84 9d 00 00 00    	je     80101831 <readi+0xb7>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
            return -1;
        return devsw[ip->major].read(ip, dst, n);
    }

    if (off > ip->size || off + n < off)
80101794:	8b 45 08             	mov    0x8(%ebp),%eax
80101797:	8b 40 58             	mov    0x58(%eax),%eax
8010179a:	39 f8                	cmp    %edi,%eax
8010179c:	0f 82 c6 00 00 00    	jb     80101868 <readi+0xee>
801017a2:	89 fa                	mov    %edi,%edx
801017a4:	03 55 14             	add    0x14(%ebp),%edx
801017a7:	0f 82 c2 00 00 00    	jb     8010186f <readi+0xf5>
        return -1;
    if (off + n > ip->size)
        n = ip->size - off;
801017ad:	89 c1                	mov    %eax,%ecx
801017af:	29 f9                	sub    %edi,%ecx
801017b1:	39 d0                	cmp    %edx,%eax
801017b3:	0f 43 4d 14          	cmovae 0x14(%ebp),%ecx
801017b7:	89 4d 14             	mov    %ecx,0x14(%ebp)

    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
801017ba:	85 c9                	test   %ecx,%ecx
801017bc:	74 68                	je     80101826 <readi+0xac>
801017be:	be 00 00 00 00       	mov    $0x0,%esi
        bp = bread(ip->dev, bmap(ip, off / BSIZE));
801017c3:	89 fa                	mov    %edi,%edx
801017c5:	c1 ea 09             	shr    $0x9,%edx
801017c8:	8b 45 08             	mov    0x8(%ebp),%eax
801017cb:	e8 ac f9 ff ff       	call   8010117c <bmap>
801017d0:	83 ec 08             	sub    $0x8,%esp
801017d3:	50                   	push   %eax
801017d4:	8b 45 08             	mov    0x8(%ebp),%eax
801017d7:	ff 30                	pushl  (%eax)
801017d9:	e8 cc e8 ff ff       	call   801000aa <bread>
801017de:	89 c1                	mov    %eax,%ecx
        m = min(n - tot, BSIZE - off % BSIZE);
801017e0:	89 f8                	mov    %edi,%eax
801017e2:	25 ff 01 00 00       	and    $0x1ff,%eax
801017e7:	bb 00 02 00 00       	mov    $0x200,%ebx
801017ec:	29 c3                	sub    %eax,%ebx
801017ee:	8b 55 14             	mov    0x14(%ebp),%edx
801017f1:	29 f2                	sub    %esi,%edx
801017f3:	83 c4 0c             	add    $0xc,%esp
801017f6:	39 d3                	cmp    %edx,%ebx
801017f8:	0f 47 da             	cmova  %edx,%ebx
        memmove(dst, bp->data + off % BSIZE, m);
801017fb:	53                   	push   %ebx
801017fc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
801017ff:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101803:	50                   	push   %eax
80101804:	ff 75 0c             	pushl  0xc(%ebp)
80101807:	e8 ac 29 00 00       	call   801041b8 <memmove>
        brelse(bp);
8010180c:	83 c4 04             	add    $0x4,%esp
8010180f:	ff 75 e4             	pushl  -0x1c(%ebp)
80101812:	e8 aa e9 ff ff       	call   801001c1 <brelse>
    for (tot = 0; tot < n; tot += m, off += m, dst += m) {
80101817:	01 de                	add    %ebx,%esi
80101819:	01 df                	add    %ebx,%edi
8010181b:	01 5d 0c             	add    %ebx,0xc(%ebp)
8010181e:	83 c4 10             	add    $0x10,%esp
80101821:	39 75 14             	cmp    %esi,0x14(%ebp)
80101824:	77 9d                	ja     801017c3 <readi+0x49>
    }
    return n;
80101826:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101829:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010182c:	5b                   	pop    %ebx
8010182d:	5e                   	pop    %esi
8010182e:	5f                   	pop    %edi
8010182f:	5d                   	pop    %ebp
80101830:	c3                   	ret    
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101831:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101835:	66 83 f8 09          	cmp    $0x9,%ax
80101839:	77 1f                	ja     8010185a <readi+0xe0>
8010183b:	98                   	cwtl   
8010183c:	8b 04 c5 60 09 11 80 	mov    -0x7feef6a0(,%eax,8),%eax
80101843:	85 c0                	test   %eax,%eax
80101845:	74 1a                	je     80101861 <readi+0xe7>
        return devsw[ip->major].read(ip, dst, n);
80101847:	83 ec 04             	sub    $0x4,%esp
8010184a:	ff 75 14             	pushl  0x14(%ebp)
8010184d:	ff 75 0c             	pushl  0xc(%ebp)
80101850:	ff 75 08             	pushl  0x8(%ebp)
80101853:	ff d0                	call   *%eax
80101855:	83 c4 10             	add    $0x10,%esp
80101858:	eb cf                	jmp    80101829 <readi+0xaf>
            return -1;
8010185a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010185f:	eb c8                	jmp    80101829 <readi+0xaf>
80101861:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101866:	eb c1                	jmp    80101829 <readi+0xaf>
        return -1;
80101868:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010186d:	eb ba                	jmp    80101829 <readi+0xaf>
8010186f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101874:	eb b3                	jmp    80101829 <readi+0xaf>

80101876 <writei>:

// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int writei(struct inode *ip, char *src, uint off, uint n)
{
80101876:	55                   	push   %ebp
80101877:	89 e5                	mov    %esp,%ebp
80101879:	57                   	push   %edi
8010187a:	56                   	push   %esi
8010187b:	53                   	push   %ebx
8010187c:	83 ec 1c             	sub    $0x1c,%esp
8010187f:	8b 75 10             	mov    0x10(%ebp),%esi
    uint tot, m;
    struct buf *bp;

    if (ip->type == T_DEV) {
80101882:	8b 45 08             	mov    0x8(%ebp),%eax
80101885:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
8010188a:	0f 84 ae 00 00 00    	je     8010193e <writei+0xc8>
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
            return -1;
        return devsw[ip->major].write(ip, src, n);
    }

    if (off > ip->size || off + n < off)
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	39 70 58             	cmp    %esi,0x58(%eax)
80101896:	0f 82 ed 00 00 00    	jb     80101989 <writei+0x113>
8010189c:	89 f0                	mov    %esi,%eax
8010189e:	03 45 14             	add    0x14(%ebp),%eax
        return -1;
    if (off + n > MAXFILE * BSIZE)
801018a1:	3d 00 18 01 00       	cmp    $0x11800,%eax
801018a6:	0f 87 e4 00 00 00    	ja     80101990 <writei+0x11a>
801018ac:	39 f0                	cmp    %esi,%eax
801018ae:	0f 82 dc 00 00 00    	jb     80101990 <writei+0x11a>
        return -1;

    for (tot = 0; tot < n; tot += m, off += m, src += m) {
801018b4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801018b8:	74 79                	je     80101933 <writei+0xbd>
801018ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
        bp = bread(ip->dev, bmap(ip, off / BSIZE));
801018c1:	89 f2                	mov    %esi,%edx
801018c3:	c1 ea 09             	shr    $0x9,%edx
801018c6:	8b 45 08             	mov    0x8(%ebp),%eax
801018c9:	e8 ae f8 ff ff       	call   8010117c <bmap>
801018ce:	83 ec 08             	sub    $0x8,%esp
801018d1:	50                   	push   %eax
801018d2:	8b 45 08             	mov    0x8(%ebp),%eax
801018d5:	ff 30                	pushl  (%eax)
801018d7:	e8 ce e7 ff ff       	call   801000aa <bread>
801018dc:	89 c7                	mov    %eax,%edi
        m = min(n - tot, BSIZE - off % BSIZE);
801018de:	89 f0                	mov    %esi,%eax
801018e0:	25 ff 01 00 00       	and    $0x1ff,%eax
801018e5:	bb 00 02 00 00       	mov    $0x200,%ebx
801018ea:	29 c3                	sub    %eax,%ebx
801018ec:	8b 55 14             	mov    0x14(%ebp),%edx
801018ef:	2b 55 e4             	sub    -0x1c(%ebp),%edx
801018f2:	83 c4 0c             	add    $0xc,%esp
801018f5:	39 d3                	cmp    %edx,%ebx
801018f7:	0f 47 da             	cmova  %edx,%ebx
        memmove(bp->data + off % BSIZE, src, m);
801018fa:	53                   	push   %ebx
801018fb:	ff 75 0c             	pushl  0xc(%ebp)
801018fe:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
80101902:	50                   	push   %eax
80101903:	e8 b0 28 00 00       	call   801041b8 <memmove>
        log_write(bp);
80101908:	89 3c 24             	mov    %edi,(%esp)
8010190b:	e8 5d 10 00 00       	call   8010296d <log_write>
        brelse(bp);
80101910:	89 3c 24             	mov    %edi,(%esp)
80101913:	e8 a9 e8 ff ff       	call   801001c1 <brelse>
    for (tot = 0; tot < n; tot += m, off += m, src += m) {
80101918:	01 5d e4             	add    %ebx,-0x1c(%ebp)
8010191b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010191e:	01 de                	add    %ebx,%esi
80101920:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101923:	83 c4 10             	add    $0x10,%esp
80101926:	39 4d 14             	cmp    %ecx,0x14(%ebp)
80101929:	77 96                	ja     801018c1 <writei+0x4b>
    }

    if (n > 0 && off > ip->size) {
8010192b:	8b 45 08             	mov    0x8(%ebp),%eax
8010192e:	39 70 58             	cmp    %esi,0x58(%eax)
80101931:	72 34                	jb     80101967 <writei+0xf1>
        ip->size = off;
        iupdate(ip);
    }
    return n;
80101933:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101936:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101939:	5b                   	pop    %ebx
8010193a:	5e                   	pop    %esi
8010193b:	5f                   	pop    %edi
8010193c:	5d                   	pop    %ebp
8010193d:	c3                   	ret    
        if (ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010193e:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101942:	66 83 f8 09          	cmp    $0x9,%ax
80101946:	77 33                	ja     8010197b <writei+0x105>
80101948:	98                   	cwtl   
80101949:	8b 04 c5 64 09 11 80 	mov    -0x7feef69c(,%eax,8),%eax
80101950:	85 c0                	test   %eax,%eax
80101952:	74 2e                	je     80101982 <writei+0x10c>
        return devsw[ip->major].write(ip, src, n);
80101954:	83 ec 04             	sub    $0x4,%esp
80101957:	ff 75 14             	pushl  0x14(%ebp)
8010195a:	ff 75 0c             	pushl  0xc(%ebp)
8010195d:	ff 75 08             	pushl  0x8(%ebp)
80101960:	ff d0                	call   *%eax
80101962:	83 c4 10             	add    $0x10,%esp
80101965:	eb cf                	jmp    80101936 <writei+0xc0>
        ip->size = off;
80101967:	8b 45 08             	mov    0x8(%ebp),%eax
8010196a:	89 70 58             	mov    %esi,0x58(%eax)
        iupdate(ip);
8010196d:	83 ec 0c             	sub    $0xc,%esp
80101970:	50                   	push   %eax
80101971:	e8 c6 fa ff ff       	call   8010143c <iupdate>
80101976:	83 c4 10             	add    $0x10,%esp
80101979:	eb b8                	jmp    80101933 <writei+0xbd>
            return -1;
8010197b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101980:	eb b4                	jmp    80101936 <writei+0xc0>
80101982:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101987:	eb ad                	jmp    80101936 <writei+0xc0>
        return -1;
80101989:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010198e:	eb a6                	jmp    80101936 <writei+0xc0>
        return -1;
80101990:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101995:	eb 9f                	jmp    80101936 <writei+0xc0>

80101997 <namecmp>:

// PAGEBREAK!
//  Directories

int namecmp(const char *s, const char *t)
{
80101997:	55                   	push   %ebp
80101998:	89 e5                	mov    %esp,%ebp
8010199a:	83 ec 0c             	sub    $0xc,%esp
    return strncmp(s, t, DIRSIZ);
8010199d:	6a 0e                	push   $0xe
8010199f:	ff 75 0c             	pushl  0xc(%ebp)
801019a2:	ff 75 08             	pushl  0x8(%ebp)
801019a5:	e8 6d 28 00 00       	call   80104217 <strncmp>
}
801019aa:	c9                   	leave  
801019ab:	c3                   	ret    

801019ac <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *dirlookup(struct inode *dp, char *name, uint *poff)
{
801019ac:	55                   	push   %ebp
801019ad:	89 e5                	mov    %esp,%ebp
801019af:	57                   	push   %edi
801019b0:	56                   	push   %esi
801019b1:	53                   	push   %ebx
801019b2:	83 ec 1c             	sub    $0x1c,%esp
801019b5:	8b 75 08             	mov    0x8(%ebp),%esi
    uint off, inum;
    struct dirent de;

    if (dp->type != T_DIR)
801019b8:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019bd:	75 15                	jne    801019d4 <dirlookup+0x28>
        panic("dirlookup not DIR");

    for (off = 0; off < dp->size; off += sizeof(de)) {
801019bf:	bb 00 00 00 00       	mov    $0x0,%ebx
        if (readi(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
801019c4:	8d 7d d8             	lea    -0x28(%ebp),%edi
            inum = de.inum;
            return iget(dp->dev, inum);
        }
    }

    return 0;
801019c7:	b8 00 00 00 00       	mov    $0x0,%eax
    for (off = 0; off < dp->size; off += sizeof(de)) {
801019cc:	83 7e 58 00          	cmpl   $0x0,0x58(%esi)
801019d0:	75 24                	jne    801019f6 <dirlookup+0x4a>
801019d2:	eb 6e                	jmp    80101a42 <dirlookup+0x96>
        panic("dirlookup not DIR");
801019d4:	83 ec 0c             	sub    $0xc,%esp
801019d7:	68 47 6a 10 80       	push   $0x80106a47
801019dc:	e8 63 e9 ff ff       	call   80100344 <panic>
            panic("dirlookup read");
801019e1:	83 ec 0c             	sub    $0xc,%esp
801019e4:	68 59 6a 10 80       	push   $0x80106a59
801019e9:	e8 56 e9 ff ff       	call   80100344 <panic>
    for (off = 0; off < dp->size; off += sizeof(de)) {
801019ee:	83 c3 10             	add    $0x10,%ebx
801019f1:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019f4:	76 47                	jbe    80101a3d <dirlookup+0x91>
        if (readi(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
801019f6:	6a 10                	push   $0x10
801019f8:	53                   	push   %ebx
801019f9:	57                   	push   %edi
801019fa:	56                   	push   %esi
801019fb:	e8 7a fd ff ff       	call   8010177a <readi>
80101a00:	83 c4 10             	add    $0x10,%esp
80101a03:	83 f8 10             	cmp    $0x10,%eax
80101a06:	75 d9                	jne    801019e1 <dirlookup+0x35>
        if (de.inum == 0)
80101a08:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a0d:	74 df                	je     801019ee <dirlookup+0x42>
        if (namecmp(name, de.name) == 0) {
80101a0f:	83 ec 08             	sub    $0x8,%esp
80101a12:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a15:	50                   	push   %eax
80101a16:	ff 75 0c             	pushl  0xc(%ebp)
80101a19:	e8 79 ff ff ff       	call   80101997 <namecmp>
80101a1e:	83 c4 10             	add    $0x10,%esp
80101a21:	85 c0                	test   %eax,%eax
80101a23:	75 c9                	jne    801019ee <dirlookup+0x42>
            if (poff)
80101a25:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a29:	74 05                	je     80101a30 <dirlookup+0x84>
                *poff = off;
80101a2b:	8b 45 10             	mov    0x10(%ebp),%eax
80101a2e:	89 18                	mov    %ebx,(%eax)
            inum = de.inum;
80101a30:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
            return iget(dp->dev, inum);
80101a34:	8b 06                	mov    (%esi),%eax
80101a36:	e8 e6 f7 ff ff       	call   80101221 <iget>
80101a3b:	eb 05                	jmp    80101a42 <dirlookup+0x96>
    return 0;
80101a3d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101a42:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a45:	5b                   	pop    %ebx
80101a46:	5e                   	pop    %esi
80101a47:	5f                   	pop    %edi
80101a48:	5d                   	pop    %ebp
80101a49:	c3                   	ret    

80101a4a <namex>:
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *namex(char *path, int nameiparent, char *name)
{
80101a4a:	55                   	push   %ebp
80101a4b:	89 e5                	mov    %esp,%ebp
80101a4d:	57                   	push   %edi
80101a4e:	56                   	push   %esi
80101a4f:	53                   	push   %ebx
80101a50:	83 ec 1c             	sub    $0x1c,%esp
80101a53:	89 c6                	mov    %eax,%esi
80101a55:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101a58:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
    struct inode *ip, *next;

    if (*path == '/')
80101a5b:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a5e:	74 1a                	je     80101a7a <namex+0x30>
        ip = iget(ROOTDEV, ROOTINO);
    else
        ip = idup(myproc()->cwd);
80101a60:	e8 66 1a 00 00       	call   801034cb <myproc>
80101a65:	83 ec 0c             	sub    $0xc,%esp
80101a68:	ff 70 68             	pushl  0x68(%eax)
80101a6b:	e8 4b fa ff ff       	call   801014bb <idup>
80101a70:	89 c7                	mov    %eax,%edi
80101a72:	83 c4 10             	add    $0x10,%esp
80101a75:	e9 d4 00 00 00       	jmp    80101b4e <namex+0x104>
        ip = iget(ROOTDEV, ROOTINO);
80101a7a:	ba 01 00 00 00       	mov    $0x1,%edx
80101a7f:	b8 01 00 00 00       	mov    $0x1,%eax
80101a84:	e8 98 f7 ff ff       	call   80101221 <iget>
80101a89:	89 c7                	mov    %eax,%edi
80101a8b:	e9 be 00 00 00       	jmp    80101b4e <namex+0x104>

    while ((path = skipelem(path, name)) != 0) {
        ilock(ip);
        if (ip->type != T_DIR) {
            iunlockput(ip);
80101a90:	83 ec 0c             	sub    $0xc,%esp
80101a93:	57                   	push   %edi
80101a94:	e8 96 fc ff ff       	call   8010172f <iunlockput>
            return 0;
80101a99:	83 c4 10             	add    $0x10,%esp
80101a9c:	bf 00 00 00 00       	mov    $0x0,%edi
    if (nameiparent) {
        iput(ip);
        return 0;
    }
    return ip;
}
80101aa1:	89 f8                	mov    %edi,%eax
80101aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101aa6:	5b                   	pop    %ebx
80101aa7:	5e                   	pop    %esi
80101aa8:	5f                   	pop    %edi
80101aa9:	5d                   	pop    %ebp
80101aaa:	c3                   	ret    
            iunlock(ip);
80101aab:	83 ec 0c             	sub    $0xc,%esp
80101aae:	57                   	push   %edi
80101aaf:	e8 f4 fa ff ff       	call   801015a8 <iunlock>
            return ip;
80101ab4:	83 c4 10             	add    $0x10,%esp
80101ab7:	eb e8                	jmp    80101aa1 <namex+0x57>
            iunlockput(ip);
80101ab9:	83 ec 0c             	sub    $0xc,%esp
80101abc:	57                   	push   %edi
80101abd:	e8 6d fc ff ff       	call   8010172f <iunlockput>
            return 0;
80101ac2:	83 c4 10             	add    $0x10,%esp
80101ac5:	89 f7                	mov    %esi,%edi
80101ac7:	eb d8                	jmp    80101aa1 <namex+0x57>
    while (*path != '/' && *path != 0)
80101ac9:	89 f3                	mov    %esi,%ebx
    len = path - s;
80101acb:	89 d8                	mov    %ebx,%eax
80101acd:	29 f0                	sub    %esi,%eax
80101acf:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if (len >= DIRSIZ)
80101ad2:	83 f8 0d             	cmp    $0xd,%eax
80101ad5:	0f 8e b4 00 00 00    	jle    80101b8f <namex+0x145>
        memmove(name, s, DIRSIZ);
80101adb:	83 ec 04             	sub    $0x4,%esp
80101ade:	6a 0e                	push   $0xe
80101ae0:	56                   	push   %esi
80101ae1:	ff 75 e4             	pushl  -0x1c(%ebp)
80101ae4:	e8 cf 26 00 00       	call   801041b8 <memmove>
80101ae9:	83 c4 10             	add    $0x10,%esp
    while (*path == '/')
80101aec:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101aef:	75 08                	jne    80101af9 <namex+0xaf>
        path++;
80101af1:	83 c3 01             	add    $0x1,%ebx
    while (*path == '/')
80101af4:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101af7:	74 f8                	je     80101af1 <namex+0xa7>
    while ((path = skipelem(path, name)) != 0) {
80101af9:	85 db                	test   %ebx,%ebx
80101afb:	0f 84 ad 00 00 00    	je     80101bae <namex+0x164>
        ilock(ip);
80101b01:	83 ec 0c             	sub    $0xc,%esp
80101b04:	57                   	push   %edi
80101b05:	e8 dc f9 ff ff       	call   801014e6 <ilock>
        if (ip->type != T_DIR) {
80101b0a:	83 c4 10             	add    $0x10,%esp
80101b0d:	66 83 7f 50 01       	cmpw   $0x1,0x50(%edi)
80101b12:	0f 85 78 ff ff ff    	jne    80101a90 <namex+0x46>
        if (nameiparent && *path == '\0') {
80101b18:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80101b1c:	74 05                	je     80101b23 <namex+0xd9>
80101b1e:	80 3b 00             	cmpb   $0x0,(%ebx)
80101b21:	74 88                	je     80101aab <namex+0x61>
        if ((next = dirlookup(ip, name, 0)) == 0) {
80101b23:	83 ec 04             	sub    $0x4,%esp
80101b26:	6a 00                	push   $0x0
80101b28:	ff 75 e4             	pushl  -0x1c(%ebp)
80101b2b:	57                   	push   %edi
80101b2c:	e8 7b fe ff ff       	call   801019ac <dirlookup>
80101b31:	89 c6                	mov    %eax,%esi
80101b33:	83 c4 10             	add    $0x10,%esp
80101b36:	85 c0                	test   %eax,%eax
80101b38:	0f 84 7b ff ff ff    	je     80101ab9 <namex+0x6f>
        iunlockput(ip);
80101b3e:	83 ec 0c             	sub    $0xc,%esp
80101b41:	57                   	push   %edi
80101b42:	e8 e8 fb ff ff       	call   8010172f <iunlockput>
        ip = next;
80101b47:	83 c4 10             	add    $0x10,%esp
80101b4a:	89 f7                	mov    %esi,%edi
80101b4c:	89 de                	mov    %ebx,%esi
    while (*path == '/')
80101b4e:	0f b6 06             	movzbl (%esi),%eax
80101b51:	3c 2f                	cmp    $0x2f,%al
80101b53:	75 0a                	jne    80101b5f <namex+0x115>
        path++;
80101b55:	83 c6 01             	add    $0x1,%esi
    while (*path == '/')
80101b58:	0f b6 06             	movzbl (%esi),%eax
80101b5b:	3c 2f                	cmp    $0x2f,%al
80101b5d:	74 f6                	je     80101b55 <namex+0x10b>
    if (*path == 0)
80101b5f:	84 c0                	test   %al,%al
80101b61:	74 4b                	je     80101bae <namex+0x164>
    while (*path != '/' && *path != 0)
80101b63:	0f b6 06             	movzbl (%esi),%eax
80101b66:	3c 2f                	cmp    $0x2f,%al
80101b68:	0f 84 5b ff ff ff    	je     80101ac9 <namex+0x7f>
80101b6e:	84 c0                	test   %al,%al
80101b70:	0f 84 53 ff ff ff    	je     80101ac9 <namex+0x7f>
80101b76:	89 f3                	mov    %esi,%ebx
        path++;
80101b78:	83 c3 01             	add    $0x1,%ebx
    while (*path != '/' && *path != 0)
80101b7b:	0f b6 03             	movzbl (%ebx),%eax
80101b7e:	3c 2f                	cmp    $0x2f,%al
80101b80:	0f 84 45 ff ff ff    	je     80101acb <namex+0x81>
80101b86:	84 c0                	test   %al,%al
80101b88:	75 ee                	jne    80101b78 <namex+0x12e>
80101b8a:	e9 3c ff ff ff       	jmp    80101acb <namex+0x81>
        memmove(name, s, len);
80101b8f:	83 ec 04             	sub    $0x4,%esp
80101b92:	ff 75 e0             	pushl  -0x20(%ebp)
80101b95:	56                   	push   %esi
80101b96:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80101b99:	56                   	push   %esi
80101b9a:	e8 19 26 00 00       	call   801041b8 <memmove>
        name[len] = 0;
80101b9f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80101ba2:	c6 04 0e 00          	movb   $0x0,(%esi,%ecx,1)
80101ba6:	83 c4 10             	add    $0x10,%esp
80101ba9:	e9 3e ff ff ff       	jmp    80101aec <namex+0xa2>
    if (nameiparent) {
80101bae:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80101bb2:	0f 84 e9 fe ff ff    	je     80101aa1 <namex+0x57>
        iput(ip);
80101bb8:	83 ec 0c             	sub    $0xc,%esp
80101bbb:	57                   	push   %edi
80101bbc:	e8 2c fa ff ff       	call   801015ed <iput>
        return 0;
80101bc1:	83 c4 10             	add    $0x10,%esp
80101bc4:	bf 00 00 00 00       	mov    $0x0,%edi
80101bc9:	e9 d3 fe ff ff       	jmp    80101aa1 <namex+0x57>

80101bce <dirlink>:
{
80101bce:	55                   	push   %ebp
80101bcf:	89 e5                	mov    %esp,%ebp
80101bd1:	57                   	push   %edi
80101bd2:	56                   	push   %esi
80101bd3:	53                   	push   %ebx
80101bd4:	83 ec 20             	sub    $0x20,%esp
80101bd7:	8b 75 08             	mov    0x8(%ebp),%esi
    if ((ip = dirlookup(dp, name, 0)) != 0) {
80101bda:	6a 00                	push   $0x0
80101bdc:	ff 75 0c             	pushl  0xc(%ebp)
80101bdf:	56                   	push   %esi
80101be0:	e8 c7 fd ff ff       	call   801019ac <dirlookup>
80101be5:	83 c4 10             	add    $0x10,%esp
80101be8:	85 c0                	test   %eax,%eax
80101bea:	75 6a                	jne    80101c56 <dirlink+0x88>
    for (off = 0; off < dp->size; off += sizeof(de)) {
80101bec:	8b 5e 58             	mov    0x58(%esi),%ebx
80101bef:	85 db                	test   %ebx,%ebx
80101bf1:	74 29                	je     80101c1c <dirlink+0x4e>
80101bf3:	bb 00 00 00 00       	mov    $0x0,%ebx
        if (readi(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
80101bf8:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101bfb:	6a 10                	push   $0x10
80101bfd:	53                   	push   %ebx
80101bfe:	57                   	push   %edi
80101bff:	56                   	push   %esi
80101c00:	e8 75 fb ff ff       	call   8010177a <readi>
80101c05:	83 c4 10             	add    $0x10,%esp
80101c08:	83 f8 10             	cmp    $0x10,%eax
80101c0b:	75 5c                	jne    80101c69 <dirlink+0x9b>
        if (de.inum == 0)
80101c0d:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101c12:	74 08                	je     80101c1c <dirlink+0x4e>
    for (off = 0; off < dp->size; off += sizeof(de)) {
80101c14:	83 c3 10             	add    $0x10,%ebx
80101c17:	3b 5e 58             	cmp    0x58(%esi),%ebx
80101c1a:	72 df                	jb     80101bfb <dirlink+0x2d>
    strncpy(de.name, name, DIRSIZ);
80101c1c:	83 ec 04             	sub    $0x4,%esp
80101c1f:	6a 0e                	push   $0xe
80101c21:	ff 75 0c             	pushl  0xc(%ebp)
80101c24:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101c27:	8d 45 da             	lea    -0x26(%ebp),%eax
80101c2a:	50                   	push   %eax
80101c2b:	e8 33 26 00 00       	call   80104263 <strncpy>
    de.inum = inum;
80101c30:	8b 45 10             	mov    0x10(%ebp),%eax
80101c33:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
    if (writei(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
80101c37:	6a 10                	push   $0x10
80101c39:	53                   	push   %ebx
80101c3a:	57                   	push   %edi
80101c3b:	56                   	push   %esi
80101c3c:	e8 35 fc ff ff       	call   80101876 <writei>
80101c41:	83 c4 20             	add    $0x20,%esp
80101c44:	83 f8 10             	cmp    $0x10,%eax
80101c47:	75 2d                	jne    80101c76 <dirlink+0xa8>
    return 0;
80101c49:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c51:	5b                   	pop    %ebx
80101c52:	5e                   	pop    %esi
80101c53:	5f                   	pop    %edi
80101c54:	5d                   	pop    %ebp
80101c55:	c3                   	ret    
        iput(ip);
80101c56:	83 ec 0c             	sub    $0xc,%esp
80101c59:	50                   	push   %eax
80101c5a:	e8 8e f9 ff ff       	call   801015ed <iput>
        return -1;
80101c5f:	83 c4 10             	add    $0x10,%esp
80101c62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c67:	eb e5                	jmp    80101c4e <dirlink+0x80>
            panic("dirlink read");
80101c69:	83 ec 0c             	sub    $0xc,%esp
80101c6c:	68 68 6a 10 80       	push   $0x80106a68
80101c71:	e8 ce e6 ff ff       	call   80100344 <panic>
        panic("dirlink");
80101c76:	83 ec 0c             	sub    $0xc,%esp
80101c79:	68 62 70 10 80       	push   $0x80107062
80101c7e:	e8 c1 e6 ff ff       	call   80100344 <panic>

80101c83 <namei>:

struct inode *namei(char *path)
{
80101c83:	55                   	push   %ebp
80101c84:	89 e5                	mov    %esp,%ebp
80101c86:	83 ec 18             	sub    $0x18,%esp
    char name[DIRSIZ];
    return namex(path, 0, name);
80101c89:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101c8c:	ba 00 00 00 00       	mov    $0x0,%edx
80101c91:	8b 45 08             	mov    0x8(%ebp),%eax
80101c94:	e8 b1 fd ff ff       	call   80101a4a <namex>
}
80101c99:	c9                   	leave  
80101c9a:	c3                   	ret    

80101c9b <nameiparent>:

struct inode *nameiparent(char *path, char *name)
{
80101c9b:	55                   	push   %ebp
80101c9c:	89 e5                	mov    %esp,%ebp
80101c9e:	83 ec 08             	sub    $0x8,%esp
    return namex(path, 1, name);
80101ca1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101ca4:	ba 01 00 00 00       	mov    $0x1,%edx
80101ca9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cac:	e8 99 fd ff ff       	call   80101a4a <namex>
}
80101cb1:	c9                   	leave  
80101cb2:	c3                   	ret    

80101cb3 <idestart>:
    outb(0x1f6, 0xe0 | (0 << 4));
}

// Start the request for b.  Caller must hold idelock.
static void idestart(struct buf *b)
{
80101cb3:	55                   	push   %ebp
80101cb4:	89 e5                	mov    %esp,%ebp
80101cb6:	56                   	push   %esi
80101cb7:	53                   	push   %ebx
    if (b == 0)
80101cb8:	85 c0                	test   %eax,%eax
80101cba:	0f 84 84 00 00 00    	je     80101d44 <idestart+0x91>
80101cc0:	89 c6                	mov    %eax,%esi
        panic("idestart");
    if (b->blockno >= FSSIZE)
80101cc2:	8b 58 08             	mov    0x8(%eax),%ebx
80101cc5:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101ccb:	0f 87 80 00 00 00    	ja     80101d51 <idestart+0x9e>
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
80101cd1:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cd6:	ec                   	in     (%dx),%al
    while (((r = inb(0x1f7)) & (IDE_BSY | IDE_DRDY)) != IDE_DRDY)
80101cd7:	83 e0 c0             	and    $0xffffffc0,%eax
80101cda:	3c 40                	cmp    $0x40,%al
80101cdc:	75 f8                	jne    80101cd6 <idestart+0x23>
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
80101cde:	b8 00 00 00 00       	mov    $0x0,%eax
80101ce3:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101ce8:	ee                   	out    %al,(%dx)
80101ce9:	b8 01 00 00 00       	mov    $0x1,%eax
80101cee:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101cf3:	ee                   	out    %al,(%dx)
80101cf4:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101cf9:	89 d8                	mov    %ebx,%eax
80101cfb:	ee                   	out    %al,(%dx)

    idewait(0);
    outb(0x3f6, 0);                // generate interrupt
    outb(0x1f2, sector_per_block); // number of sectors
    outb(0x1f3, sector & 0xff);
    outb(0x1f4, (sector >> 8) & 0xff);
80101cfc:	89 d8                	mov    %ebx,%eax
80101cfe:	c1 f8 08             	sar    $0x8,%eax
80101d01:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101d06:	ee                   	out    %al,(%dx)
    outb(0x1f5, (sector >> 16) & 0xff);
80101d07:	89 d8                	mov    %ebx,%eax
80101d09:	c1 f8 10             	sar    $0x10,%eax
80101d0c:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101d11:	ee                   	out    %al,(%dx)
    outb(0x1f6, 0xe0 | ((b->dev & 1) << 4) | ((sector >> 24) & 0x0f));
80101d12:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101d16:	c1 e0 04             	shl    $0x4,%eax
80101d19:	83 e0 10             	and    $0x10,%eax
80101d1c:	83 c8 e0             	or     $0xffffffe0,%eax
80101d1f:	c1 fb 18             	sar    $0x18,%ebx
80101d22:	83 e3 0f             	and    $0xf,%ebx
80101d25:	09 d8                	or     %ebx,%eax
80101d27:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d2c:	ee                   	out    %al,(%dx)
    if (b->flags & B_DIRTY) {
80101d2d:	f6 06 04             	testb  $0x4,(%esi)
80101d30:	75 2c                	jne    80101d5e <idestart+0xab>
80101d32:	b8 20 00 00 00       	mov    $0x20,%eax
80101d37:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d3c:	ee                   	out    %al,(%dx)
        outb(0x1f7, write_cmd);
        outsl(0x1f0, b->data, BSIZE / 4);
    } else {
        outb(0x1f7, read_cmd);
    }
}
80101d3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101d40:	5b                   	pop    %ebx
80101d41:	5e                   	pop    %esi
80101d42:	5d                   	pop    %ebp
80101d43:	c3                   	ret    
        panic("idestart");
80101d44:	83 ec 0c             	sub    $0xc,%esp
80101d47:	68 cb 6a 10 80       	push   $0x80106acb
80101d4c:	e8 f3 e5 ff ff       	call   80100344 <panic>
        panic("incorrect blockno");
80101d51:	83 ec 0c             	sub    $0xc,%esp
80101d54:	68 d4 6a 10 80       	push   $0x80106ad4
80101d59:	e8 e6 e5 ff ff       	call   80100344 <panic>
80101d5e:	b8 30 00 00 00       	mov    $0x30,%eax
80101d63:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d68:	ee                   	out    %al,(%dx)
        outsl(0x1f0, b->data, BSIZE / 4);
80101d69:	83 c6 5c             	add    $0x5c,%esi
    asm volatile("cld; rep outsl"
80101d6c:	b9 80 00 00 00       	mov    $0x80,%ecx
80101d71:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101d76:	fc                   	cld    
80101d77:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101d79:	eb c2                	jmp    80101d3d <idestart+0x8a>

80101d7b <ideinit>:
{
80101d7b:	55                   	push   %ebp
80101d7c:	89 e5                	mov    %esp,%ebp
80101d7e:	83 ec 10             	sub    $0x10,%esp
    initlock(&idelock, "ide");
80101d81:	68 e6 6a 10 80       	push   $0x80106ae6
80101d86:	68 80 a5 10 80       	push   $0x8010a580
80101d8b:	e8 9d 21 00 00       	call   80103f2d <initlock>
    ioapicenable(IRQ_IDE, ncpu - 1);
80101d90:	83 c4 08             	add    $0x8,%esp
80101d93:	a1 00 2d 11 80       	mov    0x80112d00,%eax
80101d98:	83 e8 01             	sub    $0x1,%eax
80101d9b:	50                   	push   %eax
80101d9c:	6a 0e                	push   $0xe
80101d9e:	e8 63 02 00 00       	call   80102006 <ioapicenable>
80101da3:	83 c4 10             	add    $0x10,%esp
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
80101da6:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101dab:	ec                   	in     (%dx),%al
    while (((r = inb(0x1f7)) & (IDE_BSY | IDE_DRDY)) != IDE_DRDY)
80101dac:	83 e0 c0             	and    $0xffffffc0,%eax
80101daf:	3c 40                	cmp    $0x40,%al
80101db1:	75 f8                	jne    80101dab <ideinit+0x30>
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
80101db3:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101db8:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101dbd:	ee                   	out    %al,(%dx)
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
80101dbe:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101dc3:	ec                   	in     (%dx),%al
        if (inb(0x1f7) != 0) {
80101dc4:	84 c0                	test   %al,%al
80101dc6:	75 11                	jne    80101dd9 <ideinit+0x5e>
80101dc8:	b9 e7 03 00 00       	mov    $0x3e7,%ecx
80101dcd:	ec                   	in     (%dx),%al
80101dce:	84 c0                	test   %al,%al
80101dd0:	75 07                	jne    80101dd9 <ideinit+0x5e>
    for (i = 0; i < 1000; i++) {
80101dd2:	83 e9 01             	sub    $0x1,%ecx
80101dd5:	75 f6                	jne    80101dcd <ideinit+0x52>
80101dd7:	eb 0a                	jmp    80101de3 <ideinit+0x68>
            havedisk1 = 1;
80101dd9:	c7 05 60 a5 10 80 01 	movl   $0x1,0x8010a560
80101de0:	00 00 00 
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
80101de3:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101de8:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101ded:	ee                   	out    %al,(%dx)
}
80101dee:	c9                   	leave  
80101def:	c3                   	ret    

80101df0 <ideintr>:

// Interrupt handler.
void ideintr(void)
{
80101df0:	55                   	push   %ebp
80101df1:	89 e5                	mov    %esp,%ebp
80101df3:	57                   	push   %edi
80101df4:	53                   	push   %ebx
    struct buf *b;

    // First queued buffer is the active request.
    acquire(&idelock);
80101df5:	83 ec 0c             	sub    $0xc,%esp
80101df8:	68 80 a5 10 80       	push   $0x8010a580
80101dfd:	e8 73 22 00 00       	call   80104075 <acquire>

    if ((b = idequeue) == 0) {
80101e02:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80101e08:	83 c4 10             	add    $0x10,%esp
80101e0b:	85 db                	test   %ebx,%ebx
80101e0d:	74 48                	je     80101e57 <ideintr+0x67>
        release(&idelock);
        return;
    }
    idequeue = b->qnext;
80101e0f:	8b 43 58             	mov    0x58(%ebx),%eax
80101e12:	a3 64 a5 10 80       	mov    %eax,0x8010a564

    // Read data if needed.
    if (!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101e17:	f6 03 04             	testb  $0x4,(%ebx)
80101e1a:	74 4d                	je     80101e69 <ideintr+0x79>
        insl(0x1f0, b->data, BSIZE / 4);

    // Wake process waiting for this buf.
    b->flags |= B_VALID;
    b->flags &= ~B_DIRTY;
80101e1c:	8b 03                	mov    (%ebx),%eax
80101e1e:	83 e0 fb             	and    $0xfffffffb,%eax
80101e21:	83 c8 02             	or     $0x2,%eax
80101e24:	89 03                	mov    %eax,(%ebx)
    wakeup(b);
80101e26:	83 ec 0c             	sub    $0xc,%esp
80101e29:	53                   	push   %ebx
80101e2a:	e8 2c 1e 00 00       	call   80103c5b <wakeup>

    // Start disk on next buf in queue.
    if (idequeue != 0)
80101e2f:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101e34:	83 c4 10             	add    $0x10,%esp
80101e37:	85 c0                	test   %eax,%eax
80101e39:	74 05                	je     80101e40 <ideintr+0x50>
        idestart(idequeue);
80101e3b:	e8 73 fe ff ff       	call   80101cb3 <idestart>

    release(&idelock);
80101e40:	83 ec 0c             	sub    $0xc,%esp
80101e43:	68 80 a5 10 80       	push   $0x8010a580
80101e48:	e8 8f 22 00 00       	call   801040dc <release>
80101e4d:	83 c4 10             	add    $0x10,%esp
}
80101e50:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101e53:	5b                   	pop    %ebx
80101e54:	5f                   	pop    %edi
80101e55:	5d                   	pop    %ebp
80101e56:	c3                   	ret    
        release(&idelock);
80101e57:	83 ec 0c             	sub    $0xc,%esp
80101e5a:	68 80 a5 10 80       	push   $0x8010a580
80101e5f:	e8 78 22 00 00       	call   801040dc <release>
        return;
80101e64:	83 c4 10             	add    $0x10,%esp
80101e67:	eb e7                	jmp    80101e50 <ideintr+0x60>
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
80101e69:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101e6e:	ec                   	in     (%dx),%al
80101e6f:	89 c1                	mov    %eax,%ecx
    while (((r = inb(0x1f7)) & (IDE_BSY | IDE_DRDY)) != IDE_DRDY)
80101e71:	83 e0 c0             	and    $0xffffffc0,%eax
80101e74:	3c 40                	cmp    $0x40,%al
80101e76:	75 f6                	jne    80101e6e <ideintr+0x7e>
    if (!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101e78:	f6 c1 21             	test   $0x21,%cl
80101e7b:	75 9f                	jne    80101e1c <ideintr+0x2c>
        insl(0x1f0, b->data, BSIZE / 4);
80101e7d:	8d 7b 5c             	lea    0x5c(%ebx),%edi
    asm volatile("cld; rep insl"
80101e80:	b9 80 00 00 00       	mov    $0x80,%ecx
80101e85:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101e8a:	fc                   	cld    
80101e8b:	f3 6d                	rep insl (%dx),%es:(%edi)
80101e8d:	eb 8d                	jmp    80101e1c <ideintr+0x2c>

80101e8f <iderw>:
// PAGEBREAK!
//  Sync buf with disk.
//  If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
//  Else if B_VALID is not set, read buf from disk, set B_VALID.
void iderw(struct buf *b)
{
80101e8f:	55                   	push   %ebp
80101e90:	89 e5                	mov    %esp,%ebp
80101e92:	53                   	push   %ebx
80101e93:	83 ec 10             	sub    $0x10,%esp
80101e96:	8b 5d 08             	mov    0x8(%ebp),%ebx
    struct buf **pp;

    if (!holdingsleep(&b->lock))
80101e99:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e9c:	50                   	push   %eax
80101e9d:	e8 41 20 00 00       	call   80103ee3 <holdingsleep>
80101ea2:	83 c4 10             	add    $0x10,%esp
80101ea5:	85 c0                	test   %eax,%eax
80101ea7:	74 41                	je     80101eea <iderw+0x5b>
        panic("iderw: buf not locked");
    if ((b->flags & (B_VALID | B_DIRTY)) == B_VALID)
80101ea9:	8b 03                	mov    (%ebx),%eax
80101eab:	83 e0 06             	and    $0x6,%eax
80101eae:	83 f8 02             	cmp    $0x2,%eax
80101eb1:	74 44                	je     80101ef7 <iderw+0x68>
        panic("iderw: nothing to do");
    if (b->dev != 0 && !havedisk1)
80101eb3:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101eb7:	74 09                	je     80101ec2 <iderw+0x33>
80101eb9:	83 3d 60 a5 10 80 00 	cmpl   $0x0,0x8010a560
80101ec0:	74 42                	je     80101f04 <iderw+0x75>
        panic("iderw: ide disk 1 not present");

    acquire(&idelock); // DOC:acquire-lock
80101ec2:	83 ec 0c             	sub    $0xc,%esp
80101ec5:	68 80 a5 10 80       	push   $0x8010a580
80101eca:	e8 a6 21 00 00       	call   80104075 <acquire>

    // Append b to idequeue.
    b->qnext = 0;
80101ecf:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
    for (pp = &idequeue; *pp; pp = &(*pp)->qnext) // DOC:insert-queue
80101ed6:	8b 15 64 a5 10 80    	mov    0x8010a564,%edx
80101edc:	83 c4 10             	add    $0x10,%esp
80101edf:	85 d2                	test   %edx,%edx
80101ee1:	75 30                	jne    80101f13 <iderw+0x84>
80101ee3:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101ee8:	eb 33                	jmp    80101f1d <iderw+0x8e>
        panic("iderw: buf not locked");
80101eea:	83 ec 0c             	sub    $0xc,%esp
80101eed:	68 ea 6a 10 80       	push   $0x80106aea
80101ef2:	e8 4d e4 ff ff       	call   80100344 <panic>
        panic("iderw: nothing to do");
80101ef7:	83 ec 0c             	sub    $0xc,%esp
80101efa:	68 00 6b 10 80       	push   $0x80106b00
80101eff:	e8 40 e4 ff ff       	call   80100344 <panic>
        panic("iderw: ide disk 1 not present");
80101f04:	83 ec 0c             	sub    $0xc,%esp
80101f07:	68 15 6b 10 80       	push   $0x80106b15
80101f0c:	e8 33 e4 ff ff       	call   80100344 <panic>
    for (pp = &idequeue; *pp; pp = &(*pp)->qnext) // DOC:insert-queue
80101f11:	89 c2                	mov    %eax,%edx
80101f13:	8b 42 58             	mov    0x58(%edx),%eax
80101f16:	85 c0                	test   %eax,%eax
80101f18:	75 f7                	jne    80101f11 <iderw+0x82>
80101f1a:	83 c2 58             	add    $0x58,%edx
        ;
    *pp = b;
80101f1d:	89 1a                	mov    %ebx,(%edx)

    // Start disk if necessary.
    if (idequeue == b)
80101f1f:	39 1d 64 a5 10 80    	cmp    %ebx,0x8010a564
80101f25:	74 3a                	je     80101f61 <iderw+0xd2>
        idestart(b);

    // Wait for request to finish.
    while ((b->flags & (B_VALID | B_DIRTY)) != B_VALID) {
80101f27:	8b 03                	mov    (%ebx),%eax
80101f29:	83 e0 06             	and    $0x6,%eax
80101f2c:	83 f8 02             	cmp    $0x2,%eax
80101f2f:	74 1b                	je     80101f4c <iderw+0xbd>
        sleep(b, &idelock);
80101f31:	83 ec 08             	sub    $0x8,%esp
80101f34:	68 80 a5 10 80       	push   $0x8010a580
80101f39:	53                   	push   %ebx
80101f3a:	e8 44 1b 00 00       	call   80103a83 <sleep>
    while ((b->flags & (B_VALID | B_DIRTY)) != B_VALID) {
80101f3f:	8b 03                	mov    (%ebx),%eax
80101f41:	83 e0 06             	and    $0x6,%eax
80101f44:	83 c4 10             	add    $0x10,%esp
80101f47:	83 f8 02             	cmp    $0x2,%eax
80101f4a:	75 e5                	jne    80101f31 <iderw+0xa2>
    }

    release(&idelock);
80101f4c:	83 ec 0c             	sub    $0xc,%esp
80101f4f:	68 80 a5 10 80       	push   $0x8010a580
80101f54:	e8 83 21 00 00       	call   801040dc <release>
}
80101f59:	83 c4 10             	add    $0x10,%esp
80101f5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101f5f:	c9                   	leave  
80101f60:	c3                   	ret    
        idestart(b);
80101f61:	89 d8                	mov    %ebx,%eax
80101f63:	e8 4b fd ff ff       	call   80101cb3 <idestart>
80101f68:	eb bd                	jmp    80101f27 <iderw+0x98>

80101f6a <ioapicinit>:
    ioapic->reg = reg;
    ioapic->data = data;
}

void ioapicinit(void)
{
80101f6a:	55                   	push   %ebp
80101f6b:	89 e5                	mov    %esp,%ebp
80101f6d:	56                   	push   %esi
80101f6e:	53                   	push   %ebx
    int i, id, maxintr;

    ioapic = (volatile struct ioapic *)IOAPIC;
80101f6f:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
80101f76:	00 c0 fe 
    ioapic->reg = reg;
80101f79:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80101f80:	00 00 00 
    return ioapic->data;
80101f83:	a1 34 26 11 80       	mov    0x80112634,%eax
80101f88:	8b 58 10             	mov    0x10(%eax),%ebx
    maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101f8b:	c1 eb 10             	shr    $0x10,%ebx
80101f8e:	0f b6 db             	movzbl %bl,%ebx
    ioapic->reg = reg;
80101f91:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    return ioapic->data;
80101f97:	a1 34 26 11 80       	mov    0x80112634,%eax
80101f9c:	8b 40 10             	mov    0x10(%eax),%eax
    id = ioapicread(REG_ID) >> 24;
    if (id != ioapicid)
80101f9f:	0f b6 15 60 27 11 80 	movzbl 0x80112760,%edx
    id = ioapicread(REG_ID) >> 24;
80101fa6:	c1 e8 18             	shr    $0x18,%eax
    if (id != ioapicid)
80101fa9:	39 c2                	cmp    %eax,%edx
80101fab:	75 47                	jne    80101ff4 <ioapicinit+0x8a>
{
80101fad:	ba 10 00 00 00       	mov    $0x10,%edx
80101fb2:	b8 00 00 00 00       	mov    $0x0,%eax
        cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

    // Mark all interrupts edge-triggered, active high, disabled,
    // and not routed to any CPUs.
    for (i = 0; i <= maxintr; i++) {
        ioapicwrite(REG_TABLE + 2 * i, INT_DISABLED | (T_IRQ0 + i));
80101fb7:	8d 48 20             	lea    0x20(%eax),%ecx
80101fba:	81 c9 00 00 01 00    	or     $0x10000,%ecx
    ioapic->reg = reg;
80101fc0:	8b 35 34 26 11 80    	mov    0x80112634,%esi
80101fc6:	89 16                	mov    %edx,(%esi)
    ioapic->data = data;
80101fc8:	8b 35 34 26 11 80    	mov    0x80112634,%esi
80101fce:	89 4e 10             	mov    %ecx,0x10(%esi)
80101fd1:	8d 4a 01             	lea    0x1(%edx),%ecx
    ioapic->reg = reg;
80101fd4:	89 0e                	mov    %ecx,(%esi)
    ioapic->data = data;
80101fd6:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80101fdc:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
    for (i = 0; i <= maxintr; i++) {
80101fe3:	83 c0 01             	add    $0x1,%eax
80101fe6:	83 c2 02             	add    $0x2,%edx
80101fe9:	39 c3                	cmp    %eax,%ebx
80101feb:	7d ca                	jge    80101fb7 <ioapicinit+0x4d>
        ioapicwrite(REG_TABLE + 2 * i + 1, 0);
    }
}
80101fed:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101ff0:	5b                   	pop    %ebx
80101ff1:	5e                   	pop    %esi
80101ff2:	5d                   	pop    %ebp
80101ff3:	c3                   	ret    
        cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101ff4:	83 ec 0c             	sub    $0xc,%esp
80101ff7:	68 34 6b 10 80       	push   $0x80106b34
80101ffc:	e8 e0 e5 ff ff       	call   801005e1 <cprintf>
80102001:	83 c4 10             	add    $0x10,%esp
80102004:	eb a7                	jmp    80101fad <ioapicinit+0x43>

80102006 <ioapicenable>:

void ioapicenable(int irq, int cpunum)
{
80102006:	55                   	push   %ebp
80102007:	89 e5                	mov    %esp,%ebp
80102009:	8b 45 08             	mov    0x8(%ebp),%eax
    // Mark interrupt edge-triggered, active high,
    // enabled, and routed to the given cpunum,
    // which happens to be that cpu's APIC ID.
    ioapicwrite(REG_TABLE + 2 * irq, T_IRQ0 + irq);
8010200c:	8d 50 20             	lea    0x20(%eax),%edx
8010200f:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
    ioapic->reg = reg;
80102013:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80102019:	89 01                	mov    %eax,(%ecx)
    ioapic->data = data;
8010201b:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80102021:	89 51 10             	mov    %edx,0x10(%ecx)
    ioapicwrite(REG_TABLE + 2 * irq + 1, cpunum << 24);
80102024:	8b 55 0c             	mov    0xc(%ebp),%edx
80102027:	c1 e2 18             	shl    $0x18,%edx
8010202a:	83 c0 01             	add    $0x1,%eax
    ioapic->reg = reg;
8010202d:	89 01                	mov    %eax,(%ecx)
    ioapic->data = data;
8010202f:	a1 34 26 11 80       	mov    0x80112634,%eax
80102034:	89 50 10             	mov    %edx,0x10(%eax)
}
80102037:	5d                   	pop    %ebp
80102038:	c3                   	ret    

80102039 <kfree>:
//  Free the page of physical memory pointed at by v,
//  which normally should have been returned by a
//  call to kalloc().  (The exception is when
//  initializing the allocator; see kinit above.)
void kfree(char *v)
{
80102039:	55                   	push   %ebp
8010203a:	89 e5                	mov    %esp,%ebp
8010203c:	53                   	push   %ebx
8010203d:	83 ec 04             	sub    $0x4,%esp
80102040:	8b 5d 08             	mov    0x8(%ebp),%ebx
    struct run *r;

    if ((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102043:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102049:	75 4c                	jne    80102097 <kfree+0x5e>
8010204b:	81 fb a8 5a 11 80    	cmp    $0x80115aa8,%ebx
80102051:	72 44                	jb     80102097 <kfree+0x5e>
80102053:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102059:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
8010205e:	77 37                	ja     80102097 <kfree+0x5e>
        panic("kfree");

    // Fill with junk to catch dangling refs.
    memset(v, 1, PGSIZE);
80102060:	83 ec 04             	sub    $0x4,%esp
80102063:	68 00 10 00 00       	push   $0x1000
80102068:	6a 01                	push   $0x1
8010206a:	53                   	push   %ebx
8010206b:	e8 b3 20 00 00       	call   80104123 <memset>

    if (kmem.use_lock)
80102070:	83 c4 10             	add    $0x10,%esp
80102073:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
8010207a:	75 28                	jne    801020a4 <kfree+0x6b>
        acquire(&kmem.lock);
    r = (struct run *)v;
    r->next = kmem.freelist;
8010207c:	a1 78 26 11 80       	mov    0x80112678,%eax
80102081:	89 03                	mov    %eax,(%ebx)
    kmem.freelist = r;
80102083:	89 1d 78 26 11 80    	mov    %ebx,0x80112678
    if (kmem.use_lock)
80102089:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102090:	75 24                	jne    801020b6 <kfree+0x7d>
        release(&kmem.lock);
}
80102092:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102095:	c9                   	leave  
80102096:	c3                   	ret    
        panic("kfree");
80102097:	83 ec 0c             	sub    $0xc,%esp
8010209a:	68 66 6b 10 80       	push   $0x80106b66
8010209f:	e8 a0 e2 ff ff       	call   80100344 <panic>
        acquire(&kmem.lock);
801020a4:	83 ec 0c             	sub    $0xc,%esp
801020a7:	68 40 26 11 80       	push   $0x80112640
801020ac:	e8 c4 1f 00 00       	call   80104075 <acquire>
801020b1:	83 c4 10             	add    $0x10,%esp
801020b4:	eb c6                	jmp    8010207c <kfree+0x43>
        release(&kmem.lock);
801020b6:	83 ec 0c             	sub    $0xc,%esp
801020b9:	68 40 26 11 80       	push   $0x80112640
801020be:	e8 19 20 00 00       	call   801040dc <release>
801020c3:	83 c4 10             	add    $0x10,%esp
}
801020c6:	eb ca                	jmp    80102092 <kfree+0x59>

801020c8 <freerange>:
{
801020c8:	55                   	push   %ebp
801020c9:	89 e5                	mov    %esp,%ebp
801020cb:	56                   	push   %esi
801020cc:	53                   	push   %ebx
801020cd:	8b 75 0c             	mov    0xc(%ebp),%esi
    p = (char *)PGROUNDUP((uint)vstart);
801020d0:	8b 45 08             	mov    0x8(%ebp),%eax
801020d3:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801020d9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    for (; p + PGSIZE <= (char *)vend; p += PGSIZE)
801020df:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801020e5:	39 de                	cmp    %ebx,%esi
801020e7:	72 1c                	jb     80102105 <freerange+0x3d>
        kfree(p);
801020e9:	83 ec 0c             	sub    $0xc,%esp
801020ec:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
801020f2:	50                   	push   %eax
801020f3:	e8 41 ff ff ff       	call   80102039 <kfree>
    for (; p + PGSIZE <= (char *)vend; p += PGSIZE)
801020f8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801020fe:	83 c4 10             	add    $0x10,%esp
80102101:	39 f3                	cmp    %esi,%ebx
80102103:	76 e4                	jbe    801020e9 <freerange+0x21>
}
80102105:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102108:	5b                   	pop    %ebx
80102109:	5e                   	pop    %esi
8010210a:	5d                   	pop    %ebp
8010210b:	c3                   	ret    

8010210c <kinit1>:
{
8010210c:	55                   	push   %ebp
8010210d:	89 e5                	mov    %esp,%ebp
8010210f:	83 ec 10             	sub    $0x10,%esp
    initlock(&kmem.lock, "kmem");
80102112:	68 6c 6b 10 80       	push   $0x80106b6c
80102117:	68 40 26 11 80       	push   $0x80112640
8010211c:	e8 0c 1e 00 00       	call   80103f2d <initlock>
    kmem.use_lock = 0;
80102121:	c7 05 74 26 11 80 00 	movl   $0x0,0x80112674
80102128:	00 00 00 
    freerange(vstart, vend);
8010212b:	83 c4 08             	add    $0x8,%esp
8010212e:	ff 75 0c             	pushl  0xc(%ebp)
80102131:	ff 75 08             	pushl  0x8(%ebp)
80102134:	e8 8f ff ff ff       	call   801020c8 <freerange>
}
80102139:	83 c4 10             	add    $0x10,%esp
8010213c:	c9                   	leave  
8010213d:	c3                   	ret    

8010213e <kinit2>:
{
8010213e:	55                   	push   %ebp
8010213f:	89 e5                	mov    %esp,%ebp
80102141:	83 ec 10             	sub    $0x10,%esp
    freerange(vstart, vend);
80102144:	ff 75 0c             	pushl  0xc(%ebp)
80102147:	ff 75 08             	pushl  0x8(%ebp)
8010214a:	e8 79 ff ff ff       	call   801020c8 <freerange>
    kmem.use_lock = 1;
8010214f:	c7 05 74 26 11 80 01 	movl   $0x1,0x80112674
80102156:	00 00 00 
}
80102159:	83 c4 10             	add    $0x10,%esp
8010215c:	c9                   	leave  
8010215d:	c3                   	ret    

8010215e <kalloc>:

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char *kalloc(void)
{
8010215e:	55                   	push   %ebp
8010215f:	89 e5                	mov    %esp,%ebp
80102161:	53                   	push   %ebx
80102162:	83 ec 04             	sub    $0x4,%esp
    struct run *r;

    if (kmem.use_lock)
80102165:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
8010216c:	75 21                	jne    8010218f <kalloc+0x31>
        acquire(&kmem.lock);
    r = kmem.freelist;
8010216e:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx
    if (r)
80102174:	85 db                	test   %ebx,%ebx
80102176:	74 10                	je     80102188 <kalloc+0x2a>
        kmem.freelist = r->next;
80102178:	8b 03                	mov    (%ebx),%eax
8010217a:	a3 78 26 11 80       	mov    %eax,0x80112678
    if (kmem.use_lock)
8010217f:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102186:	75 23                	jne    801021ab <kalloc+0x4d>
        release(&kmem.lock);
    return (char *)r;
}
80102188:	89 d8                	mov    %ebx,%eax
8010218a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010218d:	c9                   	leave  
8010218e:	c3                   	ret    
        acquire(&kmem.lock);
8010218f:	83 ec 0c             	sub    $0xc,%esp
80102192:	68 40 26 11 80       	push   $0x80112640
80102197:	e8 d9 1e 00 00       	call   80104075 <acquire>
    r = kmem.freelist;
8010219c:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx
    if (r)
801021a2:	83 c4 10             	add    $0x10,%esp
801021a5:	85 db                	test   %ebx,%ebx
801021a7:	75 cf                	jne    80102178 <kalloc+0x1a>
801021a9:	eb d4                	jmp    8010217f <kalloc+0x21>
        release(&kmem.lock);
801021ab:	83 ec 0c             	sub    $0xc,%esp
801021ae:	68 40 26 11 80       	push   $0x80112640
801021b3:	e8 24 1f 00 00       	call   801040dc <release>
801021b8:	83 c4 10             	add    $0x10,%esp
    return (char *)r;
801021bb:	eb cb                	jmp    80102188 <kalloc+0x2a>

801021bd <kbdgetc>:
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
801021bd:	ba 64 00 00 00       	mov    $0x64,%edx
801021c2:	ec                   	in     (%dx),%al
    static uint shift;
    static uchar *charcode[4] = {normalmap, shiftmap, ctlmap, ctlmap};
    uint st, data, c;

    st = inb(KBSTATP);
    if ((st & KBS_DIB) == 0)
801021c3:	a8 01                	test   $0x1,%al
801021c5:	0f 84 bb 00 00 00    	je     80102286 <kbdgetc+0xc9>
801021cb:	ba 60 00 00 00       	mov    $0x60,%edx
801021d0:	ec                   	in     (%dx),%al
        return -1;
    data = inb(KBDATAP);
801021d1:	0f b6 d0             	movzbl %al,%edx

    if (data == 0xE0) {
801021d4:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
801021da:	74 5b                	je     80102237 <kbdgetc+0x7a>
        shift |= E0ESC;
        return 0;
    } else if (data & 0x80) {
801021dc:	84 c0                	test   %al,%al
801021de:	78 64                	js     80102244 <kbdgetc+0x87>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
        shift &= ~(shiftcode[data] | E0ESC);
        return 0;
    } else if (shift & E0ESC) {
801021e0:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
801021e6:	f6 c1 40             	test   $0x40,%cl
801021e9:	74 0f                	je     801021fa <kbdgetc+0x3d>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
801021eb:	83 c8 80             	or     $0xffffff80,%eax
801021ee:	0f b6 d0             	movzbl %al,%edx
        shift &= ~E0ESC;
801021f1:	83 e1 bf             	and    $0xffffffbf,%ecx
801021f4:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
    }

    shift |= shiftcode[data];
801021fa:	0f b6 8a a0 6c 10 80 	movzbl -0x7fef9360(%edx),%ecx
80102201:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
    shift ^= togglecode[data];
80102207:	0f b6 82 a0 6b 10 80 	movzbl -0x7fef9460(%edx),%eax
8010220e:	31 c1                	xor    %eax,%ecx
80102210:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
    c = charcode[shift & (CTL | SHIFT)][data];
80102216:	89 c8                	mov    %ecx,%eax
80102218:	83 e0 03             	and    $0x3,%eax
8010221b:	8b 04 85 80 6b 10 80 	mov    -0x7fef9480(,%eax,4),%eax
80102222:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
    if (shift & CAPSLOCK) {
80102226:	f6 c1 08             	test   $0x8,%cl
80102229:	74 61                	je     8010228c <kbdgetc+0xcf>
        if ('a' <= c && c <= 'z')
8010222b:	8d 50 9f             	lea    -0x61(%eax),%edx
8010222e:	83 fa 19             	cmp    $0x19,%edx
80102231:	77 46                	ja     80102279 <kbdgetc+0xbc>
            c += 'A' - 'a';
80102233:	83 e8 20             	sub    $0x20,%eax
80102236:	c3                   	ret    
        shift |= E0ESC;
80102237:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
        return 0;
8010223e:	b8 00 00 00 00       	mov    $0x0,%eax
80102243:	c3                   	ret    
{
80102244:	55                   	push   %ebp
80102245:	89 e5                	mov    %esp,%ebp
80102247:	53                   	push   %ebx
        data = (shift & E0ESC ? data : data & 0x7F);
80102248:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
8010224e:	89 cb                	mov    %ecx,%ebx
80102250:	83 e3 40             	and    $0x40,%ebx
80102253:	83 e0 7f             	and    $0x7f,%eax
80102256:	85 db                	test   %ebx,%ebx
80102258:	0f 44 d0             	cmove  %eax,%edx
        shift &= ~(shiftcode[data] | E0ESC);
8010225b:	0f b6 82 a0 6c 10 80 	movzbl -0x7fef9360(%edx),%eax
80102262:	83 c8 40             	or     $0x40,%eax
80102265:	0f b6 c0             	movzbl %al,%eax
80102268:	f7 d0                	not    %eax
8010226a:	21 c8                	and    %ecx,%eax
8010226c:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4
        return 0;
80102271:	b8 00 00 00 00       	mov    $0x0,%eax
        else if ('A' <= c && c <= 'Z')
            c += 'a' - 'A';
    }
    return c;
}
80102276:	5b                   	pop    %ebx
80102277:	5d                   	pop    %ebp
80102278:	c3                   	ret    
        else if ('A' <= c && c <= 'Z')
80102279:	8d 48 bf             	lea    -0x41(%eax),%ecx
            c += 'a' - 'A';
8010227c:	8d 50 20             	lea    0x20(%eax),%edx
8010227f:	83 f9 1a             	cmp    $0x1a,%ecx
80102282:	0f 42 c2             	cmovb  %edx,%eax
    return c;
80102285:	c3                   	ret    
        return -1;
80102286:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010228b:	c3                   	ret    
}
8010228c:	f3 c3                	repz ret 

8010228e <kbdintr>:

void kbdintr(void)
{
8010228e:	55                   	push   %ebp
8010228f:	89 e5                	mov    %esp,%ebp
80102291:	83 ec 14             	sub    $0x14,%esp
    consoleintr(kbdgetc);
80102294:	68 bd 21 10 80       	push   $0x801021bd
80102299:	e8 9d e4 ff ff       	call   8010073b <consoleintr>
}
8010229e:	83 c4 10             	add    $0x10,%esp
801022a1:	c9                   	leave  
801022a2:	c3                   	ret    

801022a3 <lapicw>:

volatile uint *lapic; // Initialized in mp.c

// PAGEBREAK!
static void lapicw(int index, int value)
{
801022a3:	55                   	push   %ebp
801022a4:	89 e5                	mov    %esp,%ebp
    lapic[index] = value;
801022a6:	8b 0d 7c 26 11 80    	mov    0x8011267c,%ecx
801022ac:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801022af:	89 10                	mov    %edx,(%eax)
    lapic[ID]; // wait for write to finish, by reading
801022b1:	a1 7c 26 11 80       	mov    0x8011267c,%eax
801022b6:	8b 40 20             	mov    0x20(%eax),%eax
}
801022b9:	5d                   	pop    %ebp
801022ba:	c3                   	ret    

801022bb <fill_rtcdate>:

    return inb(CMOS_RETURN);
}

static void fill_rtcdate(struct rtcdate *r)
{
801022bb:	55                   	push   %ebp
801022bc:	89 e5                	mov    %esp,%ebp
801022be:	56                   	push   %esi
801022bf:	53                   	push   %ebx
801022c0:	89 c3                	mov    %eax,%ebx
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
801022c2:	be 70 00 00 00       	mov    $0x70,%esi
801022c7:	b8 00 00 00 00       	mov    $0x0,%eax
801022cc:	89 f2                	mov    %esi,%edx
801022ce:	ee                   	out    %al,(%dx)
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
801022cf:	b9 71 00 00 00       	mov    $0x71,%ecx
801022d4:	89 ca                	mov    %ecx,%edx
801022d6:	ec                   	in     (%dx),%al
    return inb(CMOS_RETURN);
801022d7:	0f b6 c0             	movzbl %al,%eax
801022da:	89 03                	mov    %eax,(%ebx)
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
801022dc:	b8 02 00 00 00       	mov    $0x2,%eax
801022e1:	89 f2                	mov    %esi,%edx
801022e3:	ee                   	out    %al,(%dx)
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
801022e4:	89 ca                	mov    %ecx,%edx
801022e6:	ec                   	in     (%dx),%al
801022e7:	0f b6 c0             	movzbl %al,%eax
801022ea:	89 43 04             	mov    %eax,0x4(%ebx)
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
801022ed:	b8 04 00 00 00       	mov    $0x4,%eax
801022f2:	89 f2                	mov    %esi,%edx
801022f4:	ee                   	out    %al,(%dx)
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
801022f5:	89 ca                	mov    %ecx,%edx
801022f7:	ec                   	in     (%dx),%al
801022f8:	0f b6 c0             	movzbl %al,%eax
801022fb:	89 43 08             	mov    %eax,0x8(%ebx)
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
801022fe:	b8 07 00 00 00       	mov    $0x7,%eax
80102303:	89 f2                	mov    %esi,%edx
80102305:	ee                   	out    %al,(%dx)
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
80102306:	89 ca                	mov    %ecx,%edx
80102308:	ec                   	in     (%dx),%al
80102309:	0f b6 c0             	movzbl %al,%eax
8010230c:	89 43 0c             	mov    %eax,0xc(%ebx)
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
8010230f:	b8 08 00 00 00       	mov    $0x8,%eax
80102314:	89 f2                	mov    %esi,%edx
80102316:	ee                   	out    %al,(%dx)
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
80102317:	89 ca                	mov    %ecx,%edx
80102319:	ec                   	in     (%dx),%al
8010231a:	0f b6 c0             	movzbl %al,%eax
8010231d:	89 43 10             	mov    %eax,0x10(%ebx)
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
80102320:	b8 09 00 00 00       	mov    $0x9,%eax
80102325:	89 f2                	mov    %esi,%edx
80102327:	ee                   	out    %al,(%dx)
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
80102328:	89 ca                	mov    %ecx,%edx
8010232a:	ec                   	in     (%dx),%al
8010232b:	0f b6 c0             	movzbl %al,%eax
8010232e:	89 43 14             	mov    %eax,0x14(%ebx)
    r->minute = cmos_read(MINS);
    r->hour = cmos_read(HOURS);
    r->day = cmos_read(DAY);
    r->month = cmos_read(MONTH);
    r->year = cmos_read(YEAR);
}
80102331:	5b                   	pop    %ebx
80102332:	5e                   	pop    %esi
80102333:	5d                   	pop    %ebp
80102334:	c3                   	ret    

80102335 <lapicinit>:
    if (!lapic)
80102335:	83 3d 7c 26 11 80 00 	cmpl   $0x0,0x8011267c
8010233c:	0f 84 fc 00 00 00    	je     8010243e <lapicinit+0x109>
{
80102342:	55                   	push   %ebp
80102343:	89 e5                	mov    %esp,%ebp
    lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102345:	ba 3f 01 00 00       	mov    $0x13f,%edx
8010234a:	b8 3c 00 00 00       	mov    $0x3c,%eax
8010234f:	e8 4f ff ff ff       	call   801022a3 <lapicw>
    lapicw(TDCR, X1);
80102354:	ba 0b 00 00 00       	mov    $0xb,%edx
80102359:	b8 f8 00 00 00       	mov    $0xf8,%eax
8010235e:	e8 40 ff ff ff       	call   801022a3 <lapicw>
    lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102363:	ba 20 00 02 00       	mov    $0x20020,%edx
80102368:	b8 c8 00 00 00       	mov    $0xc8,%eax
8010236d:	e8 31 ff ff ff       	call   801022a3 <lapicw>
    lapicw(TICR, 10000000);
80102372:	ba 80 96 98 00       	mov    $0x989680,%edx
80102377:	b8 e0 00 00 00       	mov    $0xe0,%eax
8010237c:	e8 22 ff ff ff       	call   801022a3 <lapicw>
    lapicw(LINT0, MASKED);
80102381:	ba 00 00 01 00       	mov    $0x10000,%edx
80102386:	b8 d4 00 00 00       	mov    $0xd4,%eax
8010238b:	e8 13 ff ff ff       	call   801022a3 <lapicw>
    lapicw(LINT1, MASKED);
80102390:	ba 00 00 01 00       	mov    $0x10000,%edx
80102395:	b8 d8 00 00 00       	mov    $0xd8,%eax
8010239a:	e8 04 ff ff ff       	call   801022a3 <lapicw>
    if (((lapic[VER] >> 16) & 0xFF) >= 4)
8010239f:	a1 7c 26 11 80       	mov    0x8011267c,%eax
801023a4:	8b 40 30             	mov    0x30(%eax),%eax
801023a7:	c1 e8 10             	shr    $0x10,%eax
801023aa:	3c 03                	cmp    $0x3,%al
801023ac:	77 7c                	ja     8010242a <lapicinit+0xf5>
    lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801023ae:	ba 33 00 00 00       	mov    $0x33,%edx
801023b3:	b8 dc 00 00 00       	mov    $0xdc,%eax
801023b8:	e8 e6 fe ff ff       	call   801022a3 <lapicw>
    lapicw(ESR, 0);
801023bd:	ba 00 00 00 00       	mov    $0x0,%edx
801023c2:	b8 a0 00 00 00       	mov    $0xa0,%eax
801023c7:	e8 d7 fe ff ff       	call   801022a3 <lapicw>
    lapicw(ESR, 0);
801023cc:	ba 00 00 00 00       	mov    $0x0,%edx
801023d1:	b8 a0 00 00 00       	mov    $0xa0,%eax
801023d6:	e8 c8 fe ff ff       	call   801022a3 <lapicw>
    lapicw(EOI, 0);
801023db:	ba 00 00 00 00       	mov    $0x0,%edx
801023e0:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023e5:	e8 b9 fe ff ff       	call   801022a3 <lapicw>
    lapicw(ICRHI, 0);
801023ea:	ba 00 00 00 00       	mov    $0x0,%edx
801023ef:	b8 c4 00 00 00       	mov    $0xc4,%eax
801023f4:	e8 aa fe ff ff       	call   801022a3 <lapicw>
    lapicw(ICRLO, BCAST | INIT | LEVEL);
801023f9:	ba 00 85 08 00       	mov    $0x88500,%edx
801023fe:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102403:	e8 9b fe ff ff       	call   801022a3 <lapicw>
    while (lapic[ICRLO] & DELIVS)
80102408:	8b 15 7c 26 11 80    	mov    0x8011267c,%edx
8010240e:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
80102414:	f6 c4 10             	test   $0x10,%ah
80102417:	75 f5                	jne    8010240e <lapicinit+0xd9>
    lapicw(TPR, 0);
80102419:	ba 00 00 00 00       	mov    $0x0,%edx
8010241e:	b8 20 00 00 00       	mov    $0x20,%eax
80102423:	e8 7b fe ff ff       	call   801022a3 <lapicw>
}
80102428:	5d                   	pop    %ebp
80102429:	c3                   	ret    
        lapicw(PCINT, MASKED);
8010242a:	ba 00 00 01 00       	mov    $0x10000,%edx
8010242f:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102434:	e8 6a fe ff ff       	call   801022a3 <lapicw>
80102439:	e9 70 ff ff ff       	jmp    801023ae <lapicinit+0x79>
8010243e:	f3 c3                	repz ret 

80102440 <lapicid>:
{
80102440:	55                   	push   %ebp
80102441:	89 e5                	mov    %esp,%ebp
    if (!lapic)
80102443:	8b 15 7c 26 11 80    	mov    0x8011267c,%edx
        return 0;
80102449:	b8 00 00 00 00       	mov    $0x0,%eax
    if (!lapic)
8010244e:	85 d2                	test   %edx,%edx
80102450:	74 06                	je     80102458 <lapicid+0x18>
    return lapic[ID] >> 24;
80102452:	8b 42 20             	mov    0x20(%edx),%eax
80102455:	c1 e8 18             	shr    $0x18,%eax
}
80102458:	5d                   	pop    %ebp
80102459:	c3                   	ret    

8010245a <lapiceoi>:
    if (lapic)
8010245a:	83 3d 7c 26 11 80 00 	cmpl   $0x0,0x8011267c
80102461:	74 14                	je     80102477 <lapiceoi+0x1d>
{
80102463:	55                   	push   %ebp
80102464:	89 e5                	mov    %esp,%ebp
        lapicw(EOI, 0);
80102466:	ba 00 00 00 00       	mov    $0x0,%edx
8010246b:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102470:	e8 2e fe ff ff       	call   801022a3 <lapicw>
}
80102475:	5d                   	pop    %ebp
80102476:	c3                   	ret    
80102477:	f3 c3                	repz ret 

80102479 <microdelay>:
{}
80102479:	55                   	push   %ebp
8010247a:	89 e5                	mov    %esp,%ebp
8010247c:	5d                   	pop    %ebp
8010247d:	c3                   	ret    

8010247e <lapicstartap>:
{
8010247e:	55                   	push   %ebp
8010247f:	89 e5                	mov    %esp,%ebp
80102481:	56                   	push   %esi
80102482:	53                   	push   %ebx
80102483:	8b 75 08             	mov    0x8(%ebp),%esi
80102486:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
80102489:	b8 0f 00 00 00       	mov    $0xf,%eax
8010248e:	ba 70 00 00 00       	mov    $0x70,%edx
80102493:	ee                   	out    %al,(%dx)
80102494:	b8 0a 00 00 00       	mov    $0xa,%eax
80102499:	ba 71 00 00 00       	mov    $0x71,%edx
8010249e:	ee                   	out    %al,(%dx)
    wrv[0] = 0;
8010249f:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801024a6:	00 00 
    wrv[1] = addr >> 4;
801024a8:	89 d8                	mov    %ebx,%eax
801024aa:	c1 e8 04             	shr    $0x4,%eax
801024ad:	66 a3 69 04 00 80    	mov    %ax,0x80000469
    lapicw(ICRHI, apicid << 24);
801024b3:	c1 e6 18             	shl    $0x18,%esi
801024b6:	89 f2                	mov    %esi,%edx
801024b8:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024bd:	e8 e1 fd ff ff       	call   801022a3 <lapicw>
    lapicw(ICRLO, INIT | LEVEL | ASSERT);
801024c2:	ba 00 c5 00 00       	mov    $0xc500,%edx
801024c7:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024cc:	e8 d2 fd ff ff       	call   801022a3 <lapicw>
    lapicw(ICRLO, INIT | LEVEL);
801024d1:	ba 00 85 00 00       	mov    $0x8500,%edx
801024d6:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024db:	e8 c3 fd ff ff       	call   801022a3 <lapicw>
        lapicw(ICRLO, STARTUP | (addr >> 12));
801024e0:	c1 eb 0c             	shr    $0xc,%ebx
801024e3:	80 cf 06             	or     $0x6,%bh
        lapicw(ICRHI, apicid << 24);
801024e6:	89 f2                	mov    %esi,%edx
801024e8:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024ed:	e8 b1 fd ff ff       	call   801022a3 <lapicw>
        lapicw(ICRLO, STARTUP | (addr >> 12));
801024f2:	89 da                	mov    %ebx,%edx
801024f4:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024f9:	e8 a5 fd ff ff       	call   801022a3 <lapicw>
        lapicw(ICRHI, apicid << 24);
801024fe:	89 f2                	mov    %esi,%edx
80102500:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102505:	e8 99 fd ff ff       	call   801022a3 <lapicw>
        lapicw(ICRLO, STARTUP | (addr >> 12));
8010250a:	89 da                	mov    %ebx,%edx
8010250c:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102511:	e8 8d fd ff ff       	call   801022a3 <lapicw>
}
80102516:	5b                   	pop    %ebx
80102517:	5e                   	pop    %esi
80102518:	5d                   	pop    %ebp
80102519:	c3                   	ret    

8010251a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010251a:	55                   	push   %ebp
8010251b:	89 e5                	mov    %esp,%ebp
8010251d:	57                   	push   %edi
8010251e:	56                   	push   %esi
8010251f:	53                   	push   %ebx
80102520:	83 ec 4c             	sub    $0x4c,%esp
80102523:	8b 7d 08             	mov    0x8(%ebp),%edi
80102526:	b8 0b 00 00 00       	mov    $0xb,%eax
8010252b:	ba 70 00 00 00       	mov    $0x70,%edx
80102530:	ee                   	out    %al,(%dx)
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
80102531:	ba 71 00 00 00       	mov    $0x71,%edx
80102536:	ec                   	in     (%dx),%al
80102537:	83 e0 04             	and    $0x4,%eax
8010253a:	88 45 b7             	mov    %al,-0x49(%ebp)

    bcd = (sb & (1 << 2)) == 0;

    // make sure CMOS doesn't modify time while we read it
    for (;;) {
        fill_rtcdate(&t1);
8010253d:	8d 75 d0             	lea    -0x30(%ebp),%esi
80102540:	89 f0                	mov    %esi,%eax
80102542:	e8 74 fd ff ff       	call   801022bb <fill_rtcdate>
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
80102547:	ba 70 00 00 00       	mov    $0x70,%edx
8010254c:	b8 0a 00 00 00       	mov    $0xa,%eax
80102551:	ee                   	out    %al,(%dx)
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
80102552:	ba 71 00 00 00       	mov    $0x71,%edx
80102557:	ec                   	in     (%dx),%al
        if (cmos_read(CMOS_STATA) & CMOS_UIP)
80102558:	84 c0                	test   %al,%al
8010255a:	78 e4                	js     80102540 <cmostime+0x26>
            continue;
        fill_rtcdate(&t2);
8010255c:	8d 5d b8             	lea    -0x48(%ebp),%ebx
8010255f:	89 d8                	mov    %ebx,%eax
80102561:	e8 55 fd ff ff       	call   801022bb <fill_rtcdate>
        if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80102566:	83 ec 04             	sub    $0x4,%esp
80102569:	6a 18                	push   $0x18
8010256b:	53                   	push   %ebx
8010256c:	56                   	push   %esi
8010256d:	e8 f5 1b 00 00       	call   80104167 <memcmp>
80102572:	83 c4 10             	add    $0x10,%esp
80102575:	85 c0                	test   %eax,%eax
80102577:	75 c7                	jne    80102540 <cmostime+0x26>
            break;
    }

    // convert
    if (bcd) {
80102579:	80 7d b7 00          	cmpb   $0x0,-0x49(%ebp)
8010257d:	75 78                	jne    801025f7 <cmostime+0xdd>
#define CONV(x) (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
        CONV(second);
8010257f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102582:	89 c2                	mov    %eax,%edx
80102584:	c1 ea 04             	shr    $0x4,%edx
80102587:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010258a:	83 e0 0f             	and    $0xf,%eax
8010258d:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102590:	89 45 d0             	mov    %eax,-0x30(%ebp)
        CONV(minute);
80102593:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102596:	89 c2                	mov    %eax,%edx
80102598:	c1 ea 04             	shr    $0x4,%edx
8010259b:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010259e:	83 e0 0f             	and    $0xf,%eax
801025a1:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        CONV(hour);
801025a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801025aa:	89 c2                	mov    %eax,%edx
801025ac:	c1 ea 04             	shr    $0x4,%edx
801025af:	8d 14 92             	lea    (%edx,%edx,4),%edx
801025b2:	83 e0 0f             	and    $0xf,%eax
801025b5:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
        CONV(day);
801025bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801025be:	89 c2                	mov    %eax,%edx
801025c0:	c1 ea 04             	shr    $0x4,%edx
801025c3:	8d 14 92             	lea    (%edx,%edx,4),%edx
801025c6:	83 e0 0f             	and    $0xf,%eax
801025c9:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
        CONV(month);
801025cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801025d2:	89 c2                	mov    %eax,%edx
801025d4:	c1 ea 04             	shr    $0x4,%edx
801025d7:	8d 14 92             	lea    (%edx,%edx,4),%edx
801025da:	83 e0 0f             	and    $0xf,%eax
801025dd:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        CONV(year);
801025e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801025e6:	89 c2                	mov    %eax,%edx
801025e8:	c1 ea 04             	shr    $0x4,%edx
801025eb:	8d 14 92             	lea    (%edx,%edx,4),%edx
801025ee:	83 e0 0f             	and    $0xf,%eax
801025f1:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef CONV
    }

    *r = t1;
801025f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801025fa:	89 07                	mov    %eax,(%edi)
801025fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801025ff:	89 47 04             	mov    %eax,0x4(%edi)
80102602:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102605:	89 47 08             	mov    %eax,0x8(%edi)
80102608:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010260b:	89 47 0c             	mov    %eax,0xc(%edi)
8010260e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102611:	89 47 10             	mov    %eax,0x10(%edi)
80102614:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102617:	89 47 14             	mov    %eax,0x14(%edi)
    r->year += 2000;
8010261a:	81 47 14 d0 07 00 00 	addl   $0x7d0,0x14(%edi)
}
80102621:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102624:	5b                   	pop    %ebx
80102625:	5e                   	pop    %esi
80102626:	5f                   	pop    %edi
80102627:	5d                   	pop    %ebp
80102628:	c3                   	ret    

80102629 <install_trans>:
// Copy committed blocks from log to their home location
static void install_trans(void)
{
    int tail;

    for (tail = 0; tail < log.lh.n; tail++) {
80102629:	83 3d c8 26 11 80 00 	cmpl   $0x0,0x801126c8
80102630:	0f 8e 84 00 00 00    	jle    801026ba <install_trans+0x91>
{
80102636:	55                   	push   %ebp
80102637:	89 e5                	mov    %esp,%ebp
80102639:	57                   	push   %edi
8010263a:	56                   	push   %esi
8010263b:	53                   	push   %ebx
8010263c:	83 ec 1c             	sub    $0x1c,%esp
    for (tail = 0; tail < log.lh.n; tail++) {
8010263f:	bb 00 00 00 00       	mov    $0x0,%ebx
        struct buf *lbuf =
            bread(log.dev, log.start + tail + 1);              // read log block
80102644:	be 80 26 11 80       	mov    $0x80112680,%esi
        struct buf *lbuf =
80102649:	83 ec 08             	sub    $0x8,%esp
            bread(log.dev, log.start + tail + 1);              // read log block
8010264c:	89 d8                	mov    %ebx,%eax
8010264e:	03 46 34             	add    0x34(%esi),%eax
80102651:	83 c0 01             	add    $0x1,%eax
        struct buf *lbuf =
80102654:	50                   	push   %eax
80102655:	ff 76 44             	pushl  0x44(%esi)
80102658:	e8 4d da ff ff       	call   801000aa <bread>
8010265d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102660:	83 c4 08             	add    $0x8,%esp
80102663:	ff 34 9d cc 26 11 80 	pushl  -0x7feed934(,%ebx,4)
8010266a:	ff 76 44             	pushl  0x44(%esi)
8010266d:	e8 38 da ff ff       	call   801000aa <bread>
80102672:	89 c7                	mov    %eax,%edi
        memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
80102674:	83 c4 0c             	add    $0xc,%esp
80102677:	68 00 02 00 00       	push   $0x200
8010267c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010267f:	83 c0 5c             	add    $0x5c,%eax
80102682:	50                   	push   %eax
80102683:	8d 47 5c             	lea    0x5c(%edi),%eax
80102686:	50                   	push   %eax
80102687:	e8 2c 1b 00 00       	call   801041b8 <memmove>
        bwrite(dbuf);                           // write dst to disk
8010268c:	89 3c 24             	mov    %edi,(%esp)
8010268f:	e8 f2 da ff ff       	call   80100186 <bwrite>
        brelse(lbuf);
80102694:	83 c4 04             	add    $0x4,%esp
80102697:	ff 75 e4             	pushl  -0x1c(%ebp)
8010269a:	e8 22 db ff ff       	call   801001c1 <brelse>
        brelse(dbuf);
8010269f:	89 3c 24             	mov    %edi,(%esp)
801026a2:	e8 1a db ff ff       	call   801001c1 <brelse>
    for (tail = 0; tail < log.lh.n; tail++) {
801026a7:	83 c3 01             	add    $0x1,%ebx
801026aa:	83 c4 10             	add    $0x10,%esp
801026ad:	39 5e 48             	cmp    %ebx,0x48(%esi)
801026b0:	7f 97                	jg     80102649 <install_trans+0x20>
    }
}
801026b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801026b5:	5b                   	pop    %ebx
801026b6:	5e                   	pop    %esi
801026b7:	5f                   	pop    %edi
801026b8:	5d                   	pop    %ebp
801026b9:	c3                   	ret    
801026ba:	f3 c3                	repz ret 

801026bc <write_head>:

// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void write_head(void)
{
801026bc:	55                   	push   %ebp
801026bd:	89 e5                	mov    %esp,%ebp
801026bf:	53                   	push   %ebx
801026c0:	83 ec 0c             	sub    $0xc,%esp
    struct buf *buf = bread(log.dev, log.start);
801026c3:	ff 35 b4 26 11 80    	pushl  0x801126b4
801026c9:	ff 35 c4 26 11 80    	pushl  0x801126c4
801026cf:	e8 d6 d9 ff ff       	call   801000aa <bread>
801026d4:	89 c3                	mov    %eax,%ebx
    struct logheader *hb = (struct logheader *)(buf->data);
    int i;
    hb->n = log.lh.n;
801026d6:	8b 0d c8 26 11 80    	mov    0x801126c8,%ecx
801026dc:	89 48 5c             	mov    %ecx,0x5c(%eax)
    for (i = 0; i < log.lh.n; i++) {
801026df:	83 c4 10             	add    $0x10,%esp
801026e2:	85 c9                	test   %ecx,%ecx
801026e4:	7e 19                	jle    801026ff <write_head+0x43>
801026e6:	c1 e1 02             	shl    $0x2,%ecx
801026e9:	b8 00 00 00 00       	mov    $0x0,%eax
        hb->block[i] = log.lh.block[i];
801026ee:	8b 90 cc 26 11 80    	mov    -0x7feed934(%eax),%edx
801026f4:	89 54 03 60          	mov    %edx,0x60(%ebx,%eax,1)
801026f8:	83 c0 04             	add    $0x4,%eax
    for (i = 0; i < log.lh.n; i++) {
801026fb:	39 c8                	cmp    %ecx,%eax
801026fd:	75 ef                	jne    801026ee <write_head+0x32>
    }
    bwrite(buf);
801026ff:	83 ec 0c             	sub    $0xc,%esp
80102702:	53                   	push   %ebx
80102703:	e8 7e da ff ff       	call   80100186 <bwrite>
    brelse(buf);
80102708:	89 1c 24             	mov    %ebx,(%esp)
8010270b:	e8 b1 da ff ff       	call   801001c1 <brelse>
}
80102710:	83 c4 10             	add    $0x10,%esp
80102713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102716:	c9                   	leave  
80102717:	c3                   	ret    

80102718 <initlog>:
{
80102718:	55                   	push   %ebp
80102719:	89 e5                	mov    %esp,%ebp
8010271b:	53                   	push   %ebx
8010271c:	83 ec 2c             	sub    $0x2c,%esp
8010271f:	8b 5d 08             	mov    0x8(%ebp),%ebx
    initlock(&log.lock, "log");
80102722:	68 a0 6d 10 80       	push   $0x80106da0
80102727:	68 80 26 11 80       	push   $0x80112680
8010272c:	e8 fc 17 00 00       	call   80103f2d <initlock>
    readsb(dev, &sb);
80102731:	83 c4 08             	add    $0x8,%esp
80102734:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102737:	50                   	push   %eax
80102738:	53                   	push   %ebx
80102739:	e8 94 eb ff ff       	call   801012d2 <readsb>
    log.start = sb.logstart;
8010273e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102741:	a3 b4 26 11 80       	mov    %eax,0x801126b4
    log.size = sb.nlog;
80102746:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102749:	89 15 b8 26 11 80    	mov    %edx,0x801126b8
    log.dev = dev;
8010274f:	89 1d c4 26 11 80    	mov    %ebx,0x801126c4
    struct buf *buf = bread(log.dev, log.start);
80102755:	83 c4 08             	add    $0x8,%esp
80102758:	50                   	push   %eax
80102759:	53                   	push   %ebx
8010275a:	e8 4b d9 ff ff       	call   801000aa <bread>
    log.lh.n = lh->n;
8010275f:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102762:	89 1d c8 26 11 80    	mov    %ebx,0x801126c8
    for (i = 0; i < log.lh.n; i++) {
80102768:	83 c4 10             	add    $0x10,%esp
8010276b:	85 db                	test   %ebx,%ebx
8010276d:	7e 19                	jle    80102788 <initlog+0x70>
8010276f:	c1 e3 02             	shl    $0x2,%ebx
80102772:	ba 00 00 00 00       	mov    $0x0,%edx
        log.lh.block[i] = lh->block[i];
80102777:	8b 4c 10 60          	mov    0x60(%eax,%edx,1),%ecx
8010277b:	89 8a cc 26 11 80    	mov    %ecx,-0x7feed934(%edx)
80102781:	83 c2 04             	add    $0x4,%edx
    for (i = 0; i < log.lh.n; i++) {
80102784:	39 d3                	cmp    %edx,%ebx
80102786:	75 ef                	jne    80102777 <initlog+0x5f>
    brelse(buf);
80102788:	83 ec 0c             	sub    $0xc,%esp
8010278b:	50                   	push   %eax
8010278c:	e8 30 da ff ff       	call   801001c1 <brelse>

static void recover_from_log(void)
{
    read_head();
    install_trans(); // if committed, copy from log to disk
80102791:	e8 93 fe ff ff       	call   80102629 <install_trans>
    log.lh.n = 0;
80102796:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
8010279d:	00 00 00 
    write_head(); // clear the log
801027a0:	e8 17 ff ff ff       	call   801026bc <write_head>
}
801027a5:	83 c4 10             	add    $0x10,%esp
801027a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027ab:	c9                   	leave  
801027ac:	c3                   	ret    

801027ad <begin_op>:
}

// called at the start of each FS system call.
void begin_op(void)
{
801027ad:	55                   	push   %ebp
801027ae:	89 e5                	mov    %esp,%ebp
801027b0:	53                   	push   %ebx
801027b1:	83 ec 10             	sub    $0x10,%esp
    acquire(&log.lock);
801027b4:	68 80 26 11 80       	push   $0x80112680
801027b9:	e8 b7 18 00 00       	call   80104075 <acquire>
801027be:	83 c4 10             	add    $0x10,%esp
    while (1) {
        if (log.committing) {
801027c1:	bb 80 26 11 80       	mov    $0x80112680,%ebx
801027c6:	eb 15                	jmp    801027dd <begin_op+0x30>
            sleep(&log, &log.lock);
801027c8:	83 ec 08             	sub    $0x8,%esp
801027cb:	68 80 26 11 80       	push   $0x80112680
801027d0:	68 80 26 11 80       	push   $0x80112680
801027d5:	e8 a9 12 00 00       	call   80103a83 <sleep>
801027da:	83 c4 10             	add    $0x10,%esp
        if (log.committing) {
801027dd:	83 7b 40 00          	cmpl   $0x0,0x40(%ebx)
801027e1:	75 e5                	jne    801027c8 <begin_op+0x1b>
        } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGSIZE) {
801027e3:	8b 43 3c             	mov    0x3c(%ebx),%eax
801027e6:	83 c0 01             	add    $0x1,%eax
801027e9:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801027ec:	8b 53 48             	mov    0x48(%ebx),%edx
801027ef:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
801027f2:	83 fa 1e             	cmp    $0x1e,%edx
801027f5:	7e 17                	jle    8010280e <begin_op+0x61>
            // this op might exhaust log space; wait for commit.
            sleep(&log, &log.lock);
801027f7:	83 ec 08             	sub    $0x8,%esp
801027fa:	68 80 26 11 80       	push   $0x80112680
801027ff:	68 80 26 11 80       	push   $0x80112680
80102804:	e8 7a 12 00 00       	call   80103a83 <sleep>
80102809:	83 c4 10             	add    $0x10,%esp
8010280c:	eb cf                	jmp    801027dd <begin_op+0x30>
        } else {
            log.outstanding += 1;
8010280e:	a3 bc 26 11 80       	mov    %eax,0x801126bc
            release(&log.lock);
80102813:	83 ec 0c             	sub    $0xc,%esp
80102816:	68 80 26 11 80       	push   $0x80112680
8010281b:	e8 bc 18 00 00       	call   801040dc <release>
            break;
        }
    }
}
80102820:	83 c4 10             	add    $0x10,%esp
80102823:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102826:	c9                   	leave  
80102827:	c3                   	ret    

80102828 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void end_op(void)
{
80102828:	55                   	push   %ebp
80102829:	89 e5                	mov    %esp,%ebp
8010282b:	57                   	push   %edi
8010282c:	56                   	push   %esi
8010282d:	53                   	push   %ebx
8010282e:	83 ec 28             	sub    $0x28,%esp
    int do_commit = 0;
    acquire(&log.lock);
80102831:	68 80 26 11 80       	push   $0x80112680
80102836:	e8 3a 18 00 00       	call   80104075 <acquire>
    log.outstanding -= 1;
8010283b:	a1 bc 26 11 80       	mov    0x801126bc,%eax
80102840:	8d 58 ff             	lea    -0x1(%eax),%ebx
80102843:	89 1d bc 26 11 80    	mov    %ebx,0x801126bc
    if (log.committing)
80102849:	83 c4 10             	add    $0x10,%esp
8010284c:	83 3d c0 26 11 80 00 	cmpl   $0x0,0x801126c0
80102853:	0f 85 e9 00 00 00    	jne    80102942 <end_op+0x11a>
        panic("log.committing");
    if (log.outstanding == 0) {
80102859:	85 db                	test   %ebx,%ebx
8010285b:	0f 85 ee 00 00 00    	jne    8010294f <end_op+0x127>
        do_commit = 1;
        log.committing = 1;
80102861:	c7 05 c0 26 11 80 01 	movl   $0x1,0x801126c0
80102868:	00 00 00 
        // begin_op() may be waiting for log space,
        // and decrementing log.outstanding has decreased
        // the amount of reserved space.
        wakeup(&log);
    }
    release(&log.lock);
8010286b:	83 ec 0c             	sub    $0xc,%esp
8010286e:	68 80 26 11 80       	push   $0x80112680
80102873:	e8 64 18 00 00       	call   801040dc <release>
    }
}

static void commit()
{
    if (log.lh.n > 0) {
80102878:	83 c4 10             	add    $0x10,%esp
        struct buf *to = bread(log.dev, log.start + tail + 1); // log block
8010287b:	be 80 26 11 80       	mov    $0x80112680,%esi
    if (log.lh.n > 0) {
80102880:	83 3d c8 26 11 80 00 	cmpl   $0x0,0x801126c8
80102887:	7e 7f                	jle    80102908 <end_op+0xe0>
        struct buf *to = bread(log.dev, log.start + tail + 1); // log block
80102889:	83 ec 08             	sub    $0x8,%esp
8010288c:	89 d8                	mov    %ebx,%eax
8010288e:	03 46 34             	add    0x34(%esi),%eax
80102891:	83 c0 01             	add    $0x1,%eax
80102894:	50                   	push   %eax
80102895:	ff 76 44             	pushl  0x44(%esi)
80102898:	e8 0d d8 ff ff       	call   801000aa <bread>
8010289d:	89 c7                	mov    %eax,%edi
        struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010289f:	83 c4 08             	add    $0x8,%esp
801028a2:	ff 34 9d cc 26 11 80 	pushl  -0x7feed934(,%ebx,4)
801028a9:	ff 76 44             	pushl  0x44(%esi)
801028ac:	e8 f9 d7 ff ff       	call   801000aa <bread>
        memmove(to->data, from->data, BSIZE);
801028b1:	83 c4 0c             	add    $0xc,%esp
801028b4:	68 00 02 00 00       	push   $0x200
801028b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801028bc:	83 c0 5c             	add    $0x5c,%eax
801028bf:	50                   	push   %eax
801028c0:	8d 47 5c             	lea    0x5c(%edi),%eax
801028c3:	50                   	push   %eax
801028c4:	e8 ef 18 00 00       	call   801041b8 <memmove>
        bwrite(to); // write the log
801028c9:	89 3c 24             	mov    %edi,(%esp)
801028cc:	e8 b5 d8 ff ff       	call   80100186 <bwrite>
        brelse(from);
801028d1:	83 c4 04             	add    $0x4,%esp
801028d4:	ff 75 e4             	pushl  -0x1c(%ebp)
801028d7:	e8 e5 d8 ff ff       	call   801001c1 <brelse>
        brelse(to);
801028dc:	89 3c 24             	mov    %edi,(%esp)
801028df:	e8 dd d8 ff ff       	call   801001c1 <brelse>
    for (tail = 0; tail < log.lh.n; tail++) {
801028e4:	83 c3 01             	add    $0x1,%ebx
801028e7:	83 c4 10             	add    $0x10,%esp
801028ea:	3b 5e 48             	cmp    0x48(%esi),%ebx
801028ed:	7c 9a                	jl     80102889 <end_op+0x61>
        write_log();     // Write modified blocks from cache to log
        write_head();    // Write header to disk -- the real commit
801028ef:	e8 c8 fd ff ff       	call   801026bc <write_head>
        install_trans(); // Now install writes to home locations
801028f4:	e8 30 fd ff ff       	call   80102629 <install_trans>
        log.lh.n = 0;
801028f9:	c7 05 c8 26 11 80 00 	movl   $0x0,0x801126c8
80102900:	00 00 00 
        write_head(); // Erase the transaction from the log
80102903:	e8 b4 fd ff ff       	call   801026bc <write_head>
        acquire(&log.lock);
80102908:	83 ec 0c             	sub    $0xc,%esp
8010290b:	68 80 26 11 80       	push   $0x80112680
80102910:	e8 60 17 00 00       	call   80104075 <acquire>
        log.committing = 0;
80102915:	c7 05 c0 26 11 80 00 	movl   $0x0,0x801126c0
8010291c:	00 00 00 
        wakeup(&log);
8010291f:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
80102926:	e8 30 13 00 00       	call   80103c5b <wakeup>
        release(&log.lock);
8010292b:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
80102932:	e8 a5 17 00 00       	call   801040dc <release>
80102937:	83 c4 10             	add    $0x10,%esp
}
8010293a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010293d:	5b                   	pop    %ebx
8010293e:	5e                   	pop    %esi
8010293f:	5f                   	pop    %edi
80102940:	5d                   	pop    %ebp
80102941:	c3                   	ret    
        panic("log.committing");
80102942:	83 ec 0c             	sub    $0xc,%esp
80102945:	68 a4 6d 10 80       	push   $0x80106da4
8010294a:	e8 f5 d9 ff ff       	call   80100344 <panic>
        wakeup(&log);
8010294f:	83 ec 0c             	sub    $0xc,%esp
80102952:	68 80 26 11 80       	push   $0x80112680
80102957:	e8 ff 12 00 00       	call   80103c5b <wakeup>
    release(&log.lock);
8010295c:	c7 04 24 80 26 11 80 	movl   $0x80112680,(%esp)
80102963:	e8 74 17 00 00       	call   801040dc <release>
80102968:	83 c4 10             	add    $0x10,%esp
8010296b:	eb cd                	jmp    8010293a <end_op+0x112>

8010296d <log_write>:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void log_write(struct buf *b)
{
8010296d:	55                   	push   %ebp
8010296e:	89 e5                	mov    %esp,%ebp
80102970:	53                   	push   %ebx
80102971:	83 ec 04             	sub    $0x4,%esp
80102974:	8b 5d 08             	mov    0x8(%ebp),%ebx
    int i;

    if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102977:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
8010297d:	83 fa 1d             	cmp    $0x1d,%edx
80102980:	7f 6b                	jg     801029ed <log_write+0x80>
80102982:	a1 b8 26 11 80       	mov    0x801126b8,%eax
80102987:	83 e8 01             	sub    $0x1,%eax
8010298a:	39 c2                	cmp    %eax,%edx
8010298c:	7d 5f                	jge    801029ed <log_write+0x80>
        panic("too big a transaction");
    if (log.outstanding < 1)
8010298e:	83 3d bc 26 11 80 00 	cmpl   $0x0,0x801126bc
80102995:	7e 63                	jle    801029fa <log_write+0x8d>
        panic("log_write outside of trans");

    acquire(&log.lock);
80102997:	83 ec 0c             	sub    $0xc,%esp
8010299a:	68 80 26 11 80       	push   $0x80112680
8010299f:	e8 d1 16 00 00       	call   80104075 <acquire>
    for (i = 0; i < log.lh.n; i++) {
801029a4:	8b 15 c8 26 11 80    	mov    0x801126c8,%edx
801029aa:	83 c4 10             	add    $0x10,%esp
801029ad:	85 d2                	test   %edx,%edx
801029af:	7e 56                	jle    80102a07 <log_write+0x9a>
        if (log.lh.block[i] == b->blockno) // log absorbtion
801029b1:	8b 4b 08             	mov    0x8(%ebx),%ecx
801029b4:	39 0d cc 26 11 80    	cmp    %ecx,0x801126cc
801029ba:	74 5b                	je     80102a17 <log_write+0xaa>
    for (i = 0; i < log.lh.n; i++) {
801029bc:	b8 00 00 00 00       	mov    $0x0,%eax
801029c1:	83 c0 01             	add    $0x1,%eax
801029c4:	39 d0                	cmp    %edx,%eax
801029c6:	74 56                	je     80102a1e <log_write+0xb1>
        if (log.lh.block[i] == b->blockno) // log absorbtion
801029c8:	39 0c 85 cc 26 11 80 	cmp    %ecx,-0x7feed934(,%eax,4)
801029cf:	75 f0                	jne    801029c1 <log_write+0x54>
            break;
    }
    log.lh.block[i] = b->blockno;
801029d1:	89 0c 85 cc 26 11 80 	mov    %ecx,-0x7feed934(,%eax,4)
    if (i == log.lh.n)
        log.lh.n++;
    b->flags |= B_DIRTY; // prevent eviction
801029d8:	83 0b 04             	orl    $0x4,(%ebx)
    release(&log.lock);
801029db:	83 ec 0c             	sub    $0xc,%esp
801029de:	68 80 26 11 80       	push   $0x80112680
801029e3:	e8 f4 16 00 00       	call   801040dc <release>
}
801029e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801029eb:	c9                   	leave  
801029ec:	c3                   	ret    
        panic("too big a transaction");
801029ed:	83 ec 0c             	sub    $0xc,%esp
801029f0:	68 b3 6d 10 80       	push   $0x80106db3
801029f5:	e8 4a d9 ff ff       	call   80100344 <panic>
        panic("log_write outside of trans");
801029fa:	83 ec 0c             	sub    $0xc,%esp
801029fd:	68 c9 6d 10 80       	push   $0x80106dc9
80102a02:	e8 3d d9 ff ff       	call   80100344 <panic>
    log.lh.block[i] = b->blockno;
80102a07:	8b 43 08             	mov    0x8(%ebx),%eax
80102a0a:	a3 cc 26 11 80       	mov    %eax,0x801126cc
    if (i == log.lh.n)
80102a0f:	85 d2                	test   %edx,%edx
80102a11:	75 c5                	jne    801029d8 <log_write+0x6b>
    for (i = 0; i < log.lh.n; i++) {
80102a13:	89 d0                	mov    %edx,%eax
80102a15:	eb 11                	jmp    80102a28 <log_write+0xbb>
80102a17:	b8 00 00 00 00       	mov    $0x0,%eax
80102a1c:	eb b3                	jmp    801029d1 <log_write+0x64>
    log.lh.block[i] = b->blockno;
80102a1e:	8b 53 08             	mov    0x8(%ebx),%edx
80102a21:	89 14 85 cc 26 11 80 	mov    %edx,-0x7feed934(,%eax,4)
        log.lh.n++;
80102a28:	83 c0 01             	add    $0x1,%eax
80102a2b:	a3 c8 26 11 80       	mov    %eax,0x801126c8
80102a30:	eb a6                	jmp    801029d8 <log_write+0x6b>

80102a32 <mpmain>:
    mpmain();
}

// Common CPU setup code.
static void mpmain(void)
{
80102a32:	55                   	push   %ebp
80102a33:	89 e5                	mov    %esp,%ebp
80102a35:	53                   	push   %ebx
80102a36:	83 ec 04             	sub    $0x4,%esp
    cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102a39:	e8 72 0a 00 00       	call   801034b0 <cpuid>
80102a3e:	89 c3                	mov    %eax,%ebx
80102a40:	e8 6b 0a 00 00       	call   801034b0 <cpuid>
80102a45:	83 ec 04             	sub    $0x4,%esp
80102a48:	53                   	push   %ebx
80102a49:	50                   	push   %eax
80102a4a:	68 e4 6d 10 80       	push   $0x80106de4
80102a4f:	e8 8d db ff ff       	call   801005e1 <cprintf>
    idtinit();                    // load idt register
80102a54:	e8 05 28 00 00       	call   8010525e <idtinit>
    xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a59:	e8 db 09 00 00       	call   80103439 <mycpu>
80102a5e:	89 c2                	mov    %eax,%edx
static inline uint xchg(volatile uint *addr, uint newval)
{
    uint result;

    // The + in "+m" denotes a read-modify-write operand.
    asm volatile("lock; xchgl %0, %1"
80102a60:	b8 01 00 00 00       	mov    $0x1,%eax
80102a65:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
    scheduler();                  // start running processes
80102a6c:	e8 fc 0b 00 00       	call   8010366d <scheduler>

80102a71 <mpenter>:
{
80102a71:	55                   	push   %ebp
80102a72:	89 e5                	mov    %esp,%ebp
80102a74:	83 ec 08             	sub    $0x8,%esp
    switchkvm();
80102a77:	e8 1b 38 00 00       	call   80106297 <switchkvm>
    seginit();
80102a7c:	e8 2f 37 00 00       	call   801061b0 <seginit>
    lapicinit();
80102a81:	e8 af f8 ff ff       	call   80102335 <lapicinit>
    mpmain();
80102a86:	e8 a7 ff ff ff       	call   80102a32 <mpmain>

80102a8b <main>:
{
80102a8b:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102a8f:	83 e4 f0             	and    $0xfffffff0,%esp
80102a92:	ff 71 fc             	pushl  -0x4(%ecx)
80102a95:	55                   	push   %ebp
80102a96:	89 e5                	mov    %esp,%ebp
80102a98:	53                   	push   %ebx
80102a99:	51                   	push   %ecx
    kinit1(end, P2V(4 * 1024 * 1024));          // phys page allocator
80102a9a:	83 ec 08             	sub    $0x8,%esp
80102a9d:	68 00 00 40 80       	push   $0x80400000
80102aa2:	68 a8 5a 11 80       	push   $0x80115aa8
80102aa7:	e8 60 f6 ff ff       	call   8010210c <kinit1>
    kvmalloc();                                 // kernel page table
80102aac:	e8 6b 3c 00 00       	call   8010671c <kvmalloc>
    mpinit();                                   // detect other processors
80102ab1:	e8 50 01 00 00       	call   80102c06 <mpinit>
    lapicinit();                                // interrupt controller
80102ab6:	e8 7a f8 ff ff       	call   80102335 <lapicinit>
    seginit();                                  // segment descriptors
80102abb:	e8 f0 36 00 00       	call   801061b0 <seginit>
    picinit();                                  // disable pic
80102ac0:	e8 40 04 00 00       	call   80102f05 <picinit>
    ioapicinit();                               // another interrupt controller
80102ac5:	e8 a0 f4 ff ff       	call   80101f6a <ioapicinit>
    consoleinit();                              // console hardware
80102aca:	e8 ff dd ff ff       	call   801008ce <consoleinit>
    uartinit();                                 // serial port
80102acf:	e8 c3 2a 00 00       	call   80105597 <uartinit>
    pinit();                                    // process table
80102ad4:	e8 3e 09 00 00       	call   80103417 <pinit>
    tvinit();                                   // trap vectors
80102ad9:	e8 f5 26 00 00       	call   801051d3 <tvinit>
    binit();                                    // buffer cache
80102ade:	e8 51 d5 ff ff       	call   80100034 <binit>
    fileinit();                                 // file table
80102ae3:	e8 78 e1 ff ff       	call   80100c60 <fileinit>
    ideinit();                                  // disk
80102ae8:	e8 8e f2 ff ff       	call   80101d7b <ideinit>

    // Write entry code to unused memory at 0x7000.
    // The linker has placed the image of entryother.S in
    // _binary_entryother_start.
    code = P2V(0x7000);
    memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102aed:	83 c4 0c             	add    $0xc,%esp
80102af0:	68 8a 00 00 00       	push   $0x8a
80102af5:	68 8c a4 10 80       	push   $0x8010a48c
80102afa:	68 00 70 00 80       	push   $0x80007000
80102aff:	e8 b4 16 00 00       	call   801041b8 <memmove>

    for (c = cpus; c < cpus + ncpu; c++) {
80102b04:	69 05 00 2d 11 80 b0 	imul   $0xb0,0x80112d00,%eax
80102b0b:	00 00 00 
80102b0e:	05 80 27 11 80       	add    $0x80112780,%eax
80102b13:	83 c4 10             	add    $0x10,%esp
80102b16:	3d 80 27 11 80       	cmp    $0x80112780,%eax
80102b1b:	76 6c                	jbe    80102b89 <main+0xfe>
80102b1d:	bb 80 27 11 80       	mov    $0x80112780,%ebx
80102b22:	eb 19                	jmp    80102b3d <main+0xb2>
80102b24:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102b2a:	69 05 00 2d 11 80 b0 	imul   $0xb0,0x80112d00,%eax
80102b31:	00 00 00 
80102b34:	05 80 27 11 80       	add    $0x80112780,%eax
80102b39:	39 c3                	cmp    %eax,%ebx
80102b3b:	73 4c                	jae    80102b89 <main+0xfe>
        if (c == mycpu()) // We've started already.
80102b3d:	e8 f7 08 00 00       	call   80103439 <mycpu>
80102b42:	39 d8                	cmp    %ebx,%eax
80102b44:	74 de                	je     80102b24 <main+0x99>
            continue;

        // Tell entryother.S what stack to use, where to enter, and what
        // pgdir to use. We cannot use kpgdir yet, because the AP processor
        // is running in low  memory, so we use entrypgdir for the APs too.
        stack = kalloc();
80102b46:	e8 13 f6 ff ff       	call   8010215e <kalloc>
        *(void **)(code - 4) = stack + KSTACKSIZE;
80102b4b:	05 00 10 00 00       	add    $0x1000,%eax
80102b50:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
        *(void (**)(void))(code - 8) = mpenter;
80102b55:	c7 05 f8 6f 00 80 71 	movl   $0x80102a71,0x80006ff8
80102b5c:	2a 10 80 
        *(int **)(code - 12) = (void *)V2P(entrypgdir);
80102b5f:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102b66:	90 10 00 

        lapicstartap(c->apicid, V2P(code));
80102b69:	83 ec 08             	sub    $0x8,%esp
80102b6c:	68 00 70 00 00       	push   $0x7000
80102b71:	0f b6 03             	movzbl (%ebx),%eax
80102b74:	50                   	push   %eax
80102b75:	e8 04 f9 ff ff       	call   8010247e <lapicstartap>
80102b7a:	83 c4 10             	add    $0x10,%esp

        // wait for cpu to finish mpmain()
        while (c->started == 0)
80102b7d:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102b83:	85 c0                	test   %eax,%eax
80102b85:	74 f6                	je     80102b7d <main+0xf2>
80102b87:	eb 9b                	jmp    80102b24 <main+0x99>
    kinit2(P2V(4 * 1024 * 1024), P2V(PHYSTOP)); // must come after startothers()
80102b89:	83 ec 08             	sub    $0x8,%esp
80102b8c:	68 00 00 00 8e       	push   $0x8e000000
80102b91:	68 00 00 40 80       	push   $0x80400000
80102b96:	e8 a3 f5 ff ff       	call   8010213e <kinit2>
    userinit();                                 // first user process
80102b9b:	e8 4f 09 00 00       	call   801034ef <userinit>
    mpmain();                                   // finish this processor's setup
80102ba0:	e8 8d fe ff ff       	call   80102a32 <mpmain>

80102ba5 <mpsearch1>:
    return sum;
}

// Look for an MP structure in the len bytes at addr.
static struct mp *mpsearch1(uint a, int len)
{
80102ba5:	55                   	push   %ebp
80102ba6:	89 e5                	mov    %esp,%ebp
80102ba8:	57                   	push   %edi
80102ba9:	56                   	push   %esi
80102baa:	53                   	push   %ebx
80102bab:	83 ec 0c             	sub    $0xc,%esp
    uchar *e, *p, *addr;

    addr = P2V(a);
80102bae:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
    e = addr + len;
80102bb4:	8d 34 13             	lea    (%ebx,%edx,1),%esi
    for (p = addr; p < e; p += sizeof(struct mp))
80102bb7:	39 f3                	cmp    %esi,%ebx
80102bb9:	72 12                	jb     80102bcd <mpsearch1+0x28>
        if (memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
            return (struct mp *)p;
    return 0;
80102bbb:	bb 00 00 00 00       	mov    $0x0,%ebx
80102bc0:	eb 3a                	jmp    80102bfc <mpsearch1+0x57>
        if (memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102bc2:	84 c0                	test   %al,%al
80102bc4:	74 36                	je     80102bfc <mpsearch1+0x57>
    for (p = addr; p < e; p += sizeof(struct mp))
80102bc6:	83 c3 10             	add    $0x10,%ebx
80102bc9:	39 de                	cmp    %ebx,%esi
80102bcb:	76 2a                	jbe    80102bf7 <mpsearch1+0x52>
        if (memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102bcd:	83 ec 04             	sub    $0x4,%esp
80102bd0:	6a 04                	push   $0x4
80102bd2:	68 f8 6d 10 80       	push   $0x80106df8
80102bd7:	53                   	push   %ebx
80102bd8:	e8 8a 15 00 00       	call   80104167 <memcmp>
80102bdd:	83 c4 10             	add    $0x10,%esp
80102be0:	85 c0                	test   %eax,%eax
80102be2:	75 e2                	jne    80102bc6 <mpsearch1+0x21>
80102be4:	89 d9                	mov    %ebx,%ecx
80102be6:	8d 7b 10             	lea    0x10(%ebx),%edi
        sum += addr[i];
80102be9:	0f b6 11             	movzbl (%ecx),%edx
80102bec:	01 d0                	add    %edx,%eax
80102bee:	83 c1 01             	add    $0x1,%ecx
    for (i = 0; i < len; i++)
80102bf1:	39 f9                	cmp    %edi,%ecx
80102bf3:	75 f4                	jne    80102be9 <mpsearch1+0x44>
80102bf5:	eb cb                	jmp    80102bc2 <mpsearch1+0x1d>
    return 0;
80102bf7:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102bfc:	89 d8                	mov    %ebx,%eax
80102bfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c01:	5b                   	pop    %ebx
80102c02:	5e                   	pop    %esi
80102c03:	5f                   	pop    %edi
80102c04:	5d                   	pop    %ebp
80102c05:	c3                   	ret    

80102c06 <mpinit>:
    *pmp = mp;
    return conf;
}

void mpinit(void)
{
80102c06:	55                   	push   %ebp
80102c07:	89 e5                	mov    %esp,%ebp
80102c09:	57                   	push   %edi
80102c0a:	56                   	push   %esi
80102c0b:	53                   	push   %ebx
80102c0c:	83 ec 1c             	sub    $0x1c,%esp
    if ((p = ((bda[0x0F] << 8) | bda[0x0E]) << 4)) {
80102c0f:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102c16:	c1 e0 08             	shl    $0x8,%eax
80102c19:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102c20:	09 d0                	or     %edx,%eax
80102c22:	c1 e0 04             	shl    $0x4,%eax
80102c25:	85 c0                	test   %eax,%eax
80102c27:	0f 84 b0 00 00 00    	je     80102cdd <mpinit+0xd7>
        if ((mp = mpsearch1(p, 1024)))
80102c2d:	ba 00 04 00 00       	mov    $0x400,%edx
80102c32:	e8 6e ff ff ff       	call   80102ba5 <mpsearch1>
80102c37:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102c3a:	85 c0                	test   %eax,%eax
80102c3c:	0f 84 cb 00 00 00    	je     80102d0d <mpinit+0x107>
    if ((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102c42:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102c45:	8b 58 04             	mov    0x4(%eax),%ebx
80102c48:	85 db                	test   %ebx,%ebx
80102c4a:	0f 84 d7 00 00 00    	je     80102d27 <mpinit+0x121>
    conf = (struct mpconf *)P2V((uint)mp->physaddr);
80102c50:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
    if (memcmp(conf, "PCMP", 4) != 0)
80102c56:	83 ec 04             	sub    $0x4,%esp
80102c59:	6a 04                	push   $0x4
80102c5b:	68 fd 6d 10 80       	push   $0x80106dfd
80102c60:	56                   	push   %esi
80102c61:	e8 01 15 00 00       	call   80104167 <memcmp>
80102c66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80102c69:	83 c4 10             	add    $0x10,%esp
80102c6c:	85 c0                	test   %eax,%eax
80102c6e:	0f 85 b3 00 00 00    	jne    80102d27 <mpinit+0x121>
    if (conf->version != 1 && conf->version != 4)
80102c74:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102c7b:	3c 01                	cmp    $0x1,%al
80102c7d:	74 08                	je     80102c87 <mpinit+0x81>
80102c7f:	3c 04                	cmp    $0x4,%al
80102c81:	0f 85 a0 00 00 00    	jne    80102d27 <mpinit+0x121>
    if (sum((uchar *)conf, conf->length) != 0)
80102c87:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
    for (i = 0; i < len; i++)
80102c8e:	66 85 d2             	test   %dx,%dx
80102c91:	74 1f                	je     80102cb2 <mpinit+0xac>
80102c93:	89 f0                	mov    %esi,%eax
80102c95:	0f b7 d2             	movzwl %dx,%edx
80102c98:	8d bc 13 00 00 00 80 	lea    -0x80000000(%ebx,%edx,1),%edi
    sum = 0;
80102c9f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        sum += addr[i];
80102ca2:	0f b6 08             	movzbl (%eax),%ecx
80102ca5:	01 ca                	add    %ecx,%edx
80102ca7:	83 c0 01             	add    $0x1,%eax
    for (i = 0; i < len; i++)
80102caa:	39 c7                	cmp    %eax,%edi
80102cac:	75 f4                	jne    80102ca2 <mpinit+0x9c>
    if (sum((uchar *)conf, conf->length) != 0)
80102cae:	84 d2                	test   %dl,%dl
80102cb0:	75 75                	jne    80102d27 <mpinit+0x121>
    struct mp *mp;
    struct mpconf *conf;
    struct mpproc *proc;
    struct mpioapic *ioapic;

    if ((conf = mpconfig(&mp)) == 0)
80102cb2:	85 f6                	test   %esi,%esi
80102cb4:	74 71                	je     80102d27 <mpinit+0x121>
        panic("Expect to run on an SMP");
    ismp = 1;
    lapic = (uint *)conf->lapicaddr;
80102cb6:	8b 83 24 00 00 80    	mov    -0x7fffffdc(%ebx),%eax
80102cbc:	a3 7c 26 11 80       	mov    %eax,0x8011267c
    for (p = (uchar *)(conf + 1), e = (uchar *)conf + conf->length; p < e;) {
80102cc1:	8d 83 2c 00 00 80    	lea    -0x7fffffd4(%ebx),%eax
80102cc7:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102cce:	01 d6                	add    %edx,%esi
    ismp = 1;
80102cd0:	b9 01 00 00 00       	mov    $0x1,%ecx
        case MPIOINTR:
        case MPLINTR:
            p += 8;
            continue;
        default:
            ismp = 0;
80102cd5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    for (p = (uchar *)(conf + 1), e = (uchar *)conf + conf->length; p < e;) {
80102cd8:	e9 88 00 00 00       	jmp    80102d65 <mpinit+0x15f>
        p = ((bda[0x14] << 8) | bda[0x13]) * 1024;
80102cdd:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102ce4:	c1 e0 08             	shl    $0x8,%eax
80102ce7:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102cee:	09 d0                	or     %edx,%eax
80102cf0:	c1 e0 0a             	shl    $0xa,%eax
        if ((mp = mpsearch1(p - 1024, 1024)))
80102cf3:	2d 00 04 00 00       	sub    $0x400,%eax
80102cf8:	ba 00 04 00 00       	mov    $0x400,%edx
80102cfd:	e8 a3 fe ff ff       	call   80102ba5 <mpsearch1>
80102d02:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102d05:	85 c0                	test   %eax,%eax
80102d07:	0f 85 35 ff ff ff    	jne    80102c42 <mpinit+0x3c>
    return mpsearch1(0xF0000, 0x10000);
80102d0d:	ba 00 00 01 00       	mov    $0x10000,%edx
80102d12:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102d17:	e8 89 fe ff ff       	call   80102ba5 <mpsearch1>
80102d1c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if ((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102d1f:	85 c0                	test   %eax,%eax
80102d21:	0f 85 1b ff ff ff    	jne    80102c42 <mpinit+0x3c>
        panic("Expect to run on an SMP");
80102d27:	83 ec 0c             	sub    $0xc,%esp
80102d2a:	68 02 6e 10 80       	push   $0x80106e02
80102d2f:	e8 10 d6 ff ff       	call   80100344 <panic>
            ismp = 0;
80102d34:	89 f9                	mov    %edi,%ecx
80102d36:	eb 34                	jmp    80102d6c <mpinit+0x166>
            if (ncpu < NCPU) {
80102d38:	8b 15 00 2d 11 80    	mov    0x80112d00,%edx
80102d3e:	83 fa 07             	cmp    $0x7,%edx
80102d41:	7f 1f                	jg     80102d62 <mpinit+0x15c>
                cpus[ncpu].apicid = proc->apicid; // apicid may differ from ncpu
80102d43:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80102d46:	69 da b0 00 00 00    	imul   $0xb0,%edx,%ebx
80102d4c:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80102d50:	88 93 80 27 11 80    	mov    %dl,-0x7feed880(%ebx)
                ncpu++;
80102d56:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102d59:	83 c2 01             	add    $0x1,%edx
80102d5c:	89 15 00 2d 11 80    	mov    %edx,0x80112d00
            p += sizeof(struct mpproc);
80102d62:	83 c0 14             	add    $0x14,%eax
    for (p = (uchar *)(conf + 1), e = (uchar *)conf + conf->length; p < e;) {
80102d65:	39 f0                	cmp    %esi,%eax
80102d67:	73 26                	jae    80102d8f <mpinit+0x189>
        switch (*p) {
80102d69:	0f b6 10             	movzbl (%eax),%edx
80102d6c:	80 fa 04             	cmp    $0x4,%dl
80102d6f:	77 c3                	ja     80102d34 <mpinit+0x12e>
80102d71:	0f b6 d2             	movzbl %dl,%edx
80102d74:	ff 24 95 3c 6e 10 80 	jmp    *-0x7fef91c4(,%edx,4)
            ioapicid = ioapic->apicno;
80102d7b:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80102d7f:	88 15 60 27 11 80    	mov    %dl,0x80112760
            p += sizeof(struct mpioapic);
80102d85:	83 c0 08             	add    $0x8,%eax
            continue;
80102d88:	eb db                	jmp    80102d65 <mpinit+0x15f>
            p += 8;
80102d8a:	83 c0 08             	add    $0x8,%eax
            continue;
80102d8d:	eb d6                	jmp    80102d65 <mpinit+0x15f>
            break;
        }
    }
    if (!ismp)
80102d8f:	85 c9                	test   %ecx,%ecx
80102d91:	74 26                	je     80102db9 <mpinit+0x1b3>
        panic("Didn't find a suitable machine");

    if (mp->imcrp) {
80102d93:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d96:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102d9a:	74 15                	je     80102db1 <mpinit+0x1ab>
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
80102d9c:	b8 70 00 00 00       	mov    $0x70,%eax
80102da1:	ba 22 00 00 00       	mov    $0x22,%edx
80102da6:	ee                   	out    %al,(%dx)
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
80102da7:	ba 23 00 00 00       	mov    $0x23,%edx
80102dac:	ec                   	in     (%dx),%al
        // Bochs doesn't support IMCR, so this doesn't run on Bochs.
        // But it would on real hardware.
        outb(0x22, 0x70);          // Select IMCR
        outb(0x23, inb(0x23) | 1); // Mask external interrupts.
80102dad:	83 c8 01             	or     $0x1,%eax
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
80102db0:	ee                   	out    %al,(%dx)
    }
}
80102db1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102db4:	5b                   	pop    %ebx
80102db5:	5e                   	pop    %esi
80102db6:	5f                   	pop    %edi
80102db7:	5d                   	pop    %ebp
80102db8:	c3                   	ret    
        panic("Didn't find a suitable machine");
80102db9:	83 ec 0c             	sub    $0xc,%esp
80102dbc:	68 1c 6e 10 80       	push   $0x80106e1c
80102dc1:	e8 7e d5 ff ff       	call   80100344 <panic>

80102dc6 <queue_init>:
struct list_head mlfq_queue[MAX_PRIORITY_LEVEL];


// MLFQ QUEUE Functions
void queue_init(void)
{
80102dc6:	55                   	push   %ebp
80102dc7:	89 e5                	mov    %esp,%ebp
    for(int i=0; i<MAX_PRIORITY_LEVEL; i++) {
        mlfq_queue[i].next = &mlfq_queue[i];
80102dc9:	c7 05 04 2d 11 80 04 	movl   $0x80112d04,0x80112d04
80102dd0:	2d 11 80 
        mlfq_queue[i].prev = &mlfq_queue[i];
80102dd3:	c7 05 08 2d 11 80 04 	movl   $0x80112d04,0x80112d08
80102dda:	2d 11 80 
        mlfq_queue[i].next = &mlfq_queue[i];
80102ddd:	c7 05 0c 2d 11 80 0c 	movl   $0x80112d0c,0x80112d0c
80102de4:	2d 11 80 
        mlfq_queue[i].prev = &mlfq_queue[i];
80102de7:	c7 05 10 2d 11 80 0c 	movl   $0x80112d0c,0x80112d10
80102dee:	2d 11 80 
        mlfq_queue[i].next = &mlfq_queue[i];
80102df1:	c7 05 14 2d 11 80 14 	movl   $0x80112d14,0x80112d14
80102df8:	2d 11 80 
        mlfq_queue[i].prev = &mlfq_queue[i];
80102dfb:	c7 05 18 2d 11 80 14 	movl   $0x80112d14,0x80112d18
80102e02:	2d 11 80 
    }
}
80102e05:	5d                   	pop    %ebp
80102e06:	c3                   	ret    

80102e07 <queue_push>:

// Insert process p at the end of queue
void queue_push(int level, struct proc *p)
{
80102e07:	55                   	push   %ebp
80102e08:	89 e5                	mov    %esp,%ebp
80102e0a:	53                   	push   %ebx
80102e0b:	8b 55 08             	mov    0x8(%ebp),%edx
80102e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
    struct list_head *q = &mlfq_queue[level];
    struct list_head *entry = &p->queue_link;
80102e11:	8d 88 80 00 00 00    	lea    0x80(%eax),%ecx
    struct list_head *q = &mlfq_queue[level];
80102e17:	8d 1c d5 04 2d 11 80 	lea    -0x7feed2fc(,%edx,8),%ebx
80102e1e:	89 98 80 00 00 00    	mov    %ebx,0x80(%eax)

    entry->next = q;
    entry->prev = q->prev;
80102e24:	8b 1c d5 08 2d 11 80 	mov    -0x7feed2f8(,%edx,8),%ebx
80102e2b:	89 98 84 00 00 00    	mov    %ebx,0x84(%eax)
    q->prev->next = entry;
80102e31:	89 0b                	mov    %ecx,(%ebx)
    q->prev = entry;
80102e33:	89 0c d5 08 2d 11 80 	mov    %ecx,-0x7feed2f8(,%edx,8)
    p->in_queue = 1;
80102e3a:	c7 40 7c 01 00 00 00 	movl   $0x1,0x7c(%eax)
}
80102e41:	5b                   	pop    %ebx
80102e42:	5d                   	pop    %ebp
80102e43:	c3                   	ret    

80102e44 <queue_push_head>:

void queue_push_head(int level, struct proc *p)
{
80102e44:	55                   	push   %ebp
80102e45:	89 e5                	mov    %esp,%ebp
80102e47:	56                   	push   %esi
80102e48:	53                   	push   %ebx
80102e49:	8b 55 08             	mov    0x8(%ebp),%edx
80102e4c:	8b 45 0c             	mov    0xc(%ebp),%eax
    struct list_head *q = &mlfq_queue[level];
    struct list_head *entry = &p->queue_link;
80102e4f:	8d 88 80 00 00 00    	lea    0x80(%eax),%ecx

    // 현재 큐의 head 다음 위치(head->next)에 삽입
    entry->next = q->next;
80102e55:	8b 1c d5 04 2d 11 80 	mov    -0x7feed2fc(,%edx,8),%ebx
80102e5c:	89 98 80 00 00 00    	mov    %ebx,0x80(%eax)
    struct list_head *q = &mlfq_queue[level];
80102e62:	8d 34 d5 04 2d 11 80 	lea    -0x7feed2fc(,%edx,8),%esi
80102e69:	89 b0 84 00 00 00    	mov    %esi,0x84(%eax)
    entry->prev = q;
    q->next->prev = entry;
80102e6f:	89 4b 04             	mov    %ecx,0x4(%ebx)
    q->next = entry;
80102e72:	89 0c d5 04 2d 11 80 	mov    %ecx,-0x7feed2fc(,%edx,8)
    p->in_queue = 1;
80102e79:	c7 40 7c 01 00 00 00 	movl   $0x1,0x7c(%eax)
}
80102e80:	5b                   	pop    %ebx
80102e81:	5e                   	pop    %esi
80102e82:	5d                   	pop    %ebp
80102e83:	c3                   	ret    

80102e84 <queue_pop>:


struct proc *queue_pop(int level)
{
80102e84:	55                   	push   %ebp
80102e85:	89 e5                	mov    %esp,%ebp
80102e87:	53                   	push   %ebx
80102e88:	8b 45 08             	mov    0x8(%ebp),%eax
    struct list_head *q = &mlfq_queue[level];
80102e8b:	8d 0c c5 04 2d 11 80 	lea    -0x7feed2fc(,%eax,8),%ecx
    if (queue_empty(q))
80102e92:	8b 14 c5 04 2d 11 80 	mov    -0x7feed2fc(,%eax,8),%edx
80102e99:	39 ca                	cmp    %ecx,%edx
80102e9b:	74 1b                	je     80102eb8 <queue_pop+0x34>
        return NULL;

    struct list_head *first = q->next;
    q->next = first->next;
80102e9d:	8b 1a                	mov    (%edx),%ebx
80102e9f:	89 1c c5 04 2d 11 80 	mov    %ebx,-0x7feed2fc(,%eax,8)
    first->next->prev = q;
80102ea6:	8b 02                	mov    (%edx),%eax
80102ea8:	89 48 04             	mov    %ecx,0x4(%eax)
    struct proc *p = container_of(first, struct proc, queue_link);
80102eab:	8d 42 80             	lea    -0x80(%edx),%eax
    p->in_queue = 0;
80102eae:	c7 42 fc 00 00 00 00 	movl   $0x0,-0x4(%edx)
    return p;
}
80102eb5:	5b                   	pop    %ebx
80102eb6:	5d                   	pop    %ebp
80102eb7:	c3                   	ret    
        return NULL;
80102eb8:	b8 00 00 00 00       	mov    $0x0,%eax
80102ebd:	eb f6                	jmp    80102eb5 <queue_pop+0x31>

80102ebf <queue_remove>:

void queue_remove(struct proc *p)
{
80102ebf:	55                   	push   %ebp
80102ec0:	89 e5                	mov    %esp,%ebp
80102ec2:	53                   	push   %ebx
80102ec3:	8b 45 08             	mov    0x8(%ebp),%eax
    struct list_head *entry = &p->queue_link;
    
    if (!p->in_queue) return;
80102ec6:	83 78 7c 00          	cmpl   $0x0,0x7c(%eax)
80102eca:	74 36                	je     80102f02 <queue_remove+0x43>
    struct list_head *entry = &p->queue_link;
80102ecc:	8d 90 80 00 00 00    	lea    0x80(%eax),%edx

    entry->prev->next = entry->next;
80102ed2:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
80102ed8:	8b 98 80 00 00 00    	mov    0x80(%eax),%ebx
80102ede:	89 19                	mov    %ebx,(%ecx)
    entry->next->prev = entry->prev;
80102ee0:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
80102ee6:	8b 98 84 00 00 00    	mov    0x84(%eax),%ebx
80102eec:	89 59 04             	mov    %ebx,0x4(%ecx)

    entry->next = entry;
80102eef:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
    entry->prev = entry;
80102ef5:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
    p->in_queue = 0;
80102efb:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
}
80102f02:	5b                   	pop    %ebx
80102f03:	5d                   	pop    %ebp
80102f04:	c3                   	ret    

80102f05 <picinit>:
#define IO_PIC1 0x20 // Master (IRQs 0-7)
#define IO_PIC2 0xA0 // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void picinit(void)
{
80102f05:	55                   	push   %ebp
80102f06:	89 e5                	mov    %esp,%ebp
80102f08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f0d:	ba 21 00 00 00       	mov    $0x21,%edx
80102f12:	ee                   	out    %al,(%dx)
80102f13:	ba a1 00 00 00       	mov    $0xa1,%edx
80102f18:	ee                   	out    %al,(%dx)
    // mask all interrupts
    outb(IO_PIC1 + 1, 0xFF);
    outb(IO_PIC2 + 1, 0xFF);
}
80102f19:	5d                   	pop    %ebp
80102f1a:	c3                   	ret    

80102f1b <pipealloc>:
    int readopen;  // read fd is still open
    int writeopen; // write fd is still open
};

int pipealloc(struct file **f0, struct file **f1)
{
80102f1b:	55                   	push   %ebp
80102f1c:	89 e5                	mov    %esp,%ebp
80102f1e:	57                   	push   %edi
80102f1f:	56                   	push   %esi
80102f20:	53                   	push   %ebx
80102f21:	83 ec 0c             	sub    $0xc,%esp
80102f24:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102f27:	8b 75 0c             	mov    0xc(%ebp),%esi
    struct pipe *p;

    p = 0;
    *f0 = *f1 = 0;
80102f2a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102f30:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102f36:	e8 3f dd ff ff       	call   80100c7a <filealloc>
80102f3b:	89 03                	mov    %eax,(%ebx)
80102f3d:	85 c0                	test   %eax,%eax
80102f3f:	0f 84 a9 00 00 00    	je     80102fee <pipealloc+0xd3>
80102f45:	e8 30 dd ff ff       	call   80100c7a <filealloc>
80102f4a:	89 06                	mov    %eax,(%esi)
80102f4c:	85 c0                	test   %eax,%eax
80102f4e:	0f 84 88 00 00 00    	je     80102fdc <pipealloc+0xc1>
        goto bad;
    if ((p = (struct pipe *)kalloc()) == 0)
80102f54:	e8 05 f2 ff ff       	call   8010215e <kalloc>
80102f59:	89 c7                	mov    %eax,%edi
80102f5b:	85 c0                	test   %eax,%eax
80102f5d:	75 0b                	jne    80102f6a <pipealloc+0x4f>

    // PAGEBREAK: 20
bad:
    if (p)
        kfree((char *)p);
    if (*f0)
80102f5f:	8b 03                	mov    (%ebx),%eax
80102f61:	85 c0                	test   %eax,%eax
80102f63:	75 7d                	jne    80102fe2 <pipealloc+0xc7>
80102f65:	e9 84 00 00 00       	jmp    80102fee <pipealloc+0xd3>
    p->readopen = 1;
80102f6a:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102f71:	00 00 00 
    p->writeopen = 1;
80102f74:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102f7b:	00 00 00 
    p->nwrite = 0;
80102f7e:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102f85:	00 00 00 
    p->nread = 0;
80102f88:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102f8f:	00 00 00 
    initlock(&p->lock, "pipe");
80102f92:	83 ec 08             	sub    $0x8,%esp
80102f95:	68 50 6e 10 80       	push   $0x80106e50
80102f9a:	50                   	push   %eax
80102f9b:	e8 8d 0f 00 00       	call   80103f2d <initlock>
    (*f0)->type = FD_PIPE;
80102fa0:	8b 03                	mov    (%ebx),%eax
80102fa2:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    (*f0)->readable = 1;
80102fa8:	8b 03                	mov    (%ebx),%eax
80102faa:	c6 40 08 01          	movb   $0x1,0x8(%eax)
    (*f0)->writable = 0;
80102fae:	8b 03                	mov    (%ebx),%eax
80102fb0:	c6 40 09 00          	movb   $0x0,0x9(%eax)
    (*f0)->pipe = p;
80102fb4:	8b 03                	mov    (%ebx),%eax
80102fb6:	89 78 0c             	mov    %edi,0xc(%eax)
    (*f1)->type = FD_PIPE;
80102fb9:	8b 06                	mov    (%esi),%eax
80102fbb:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
    (*f1)->readable = 0;
80102fc1:	8b 06                	mov    (%esi),%eax
80102fc3:	c6 40 08 00          	movb   $0x0,0x8(%eax)
    (*f1)->writable = 1;
80102fc7:	8b 06                	mov    (%esi),%eax
80102fc9:	c6 40 09 01          	movb   $0x1,0x9(%eax)
    (*f1)->pipe = p;
80102fcd:	8b 06                	mov    (%esi),%eax
80102fcf:	89 78 0c             	mov    %edi,0xc(%eax)
    return 0;
80102fd2:	83 c4 10             	add    $0x10,%esp
80102fd5:	b8 00 00 00 00       	mov    $0x0,%eax
80102fda:	eb 2e                	jmp    8010300a <pipealloc+0xef>
    if (*f0)
80102fdc:	8b 03                	mov    (%ebx),%eax
80102fde:	85 c0                	test   %eax,%eax
80102fe0:	74 30                	je     80103012 <pipealloc+0xf7>
        fileclose(*f0);
80102fe2:	83 ec 0c             	sub    $0xc,%esp
80102fe5:	50                   	push   %eax
80102fe6:	e8 41 dd ff ff       	call   80100d2c <fileclose>
80102feb:	83 c4 10             	add    $0x10,%esp
    if (*f1)
80102fee:	8b 16                	mov    (%esi),%edx
        fileclose(*f1);
    return -1;
80102ff0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    if (*f1)
80102ff5:	85 d2                	test   %edx,%edx
80102ff7:	74 11                	je     8010300a <pipealloc+0xef>
        fileclose(*f1);
80102ff9:	83 ec 0c             	sub    $0xc,%esp
80102ffc:	52                   	push   %edx
80102ffd:	e8 2a dd ff ff       	call   80100d2c <fileclose>
80103002:	83 c4 10             	add    $0x10,%esp
    return -1;
80103005:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010300a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010300d:	5b                   	pop    %ebx
8010300e:	5e                   	pop    %esi
8010300f:	5f                   	pop    %edi
80103010:	5d                   	pop    %ebp
80103011:	c3                   	ret    
    return -1;
80103012:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103017:	eb f1                	jmp    8010300a <pipealloc+0xef>

80103019 <pipeclose>:

void pipeclose(struct pipe *p, int writable)
{
80103019:	55                   	push   %ebp
8010301a:	89 e5                	mov    %esp,%ebp
8010301c:	53                   	push   %ebx
8010301d:	83 ec 10             	sub    $0x10,%esp
80103020:	8b 5d 08             	mov    0x8(%ebp),%ebx
    acquire(&p->lock);
80103023:	53                   	push   %ebx
80103024:	e8 4c 10 00 00       	call   80104075 <acquire>
    if (writable) {
80103029:	83 c4 10             	add    $0x10,%esp
8010302c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103030:	74 3f                	je     80103071 <pipeclose+0x58>
        p->writeopen = 0;
80103032:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80103039:	00 00 00 
        wakeup(&p->nread);
8010303c:	83 ec 0c             	sub    $0xc,%esp
8010303f:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103045:	50                   	push   %eax
80103046:	e8 10 0c 00 00       	call   80103c5b <wakeup>
8010304b:	83 c4 10             	add    $0x10,%esp
    } else {
        p->readopen = 0;
        wakeup(&p->nwrite);
    }
    if (p->readopen == 0 && p->writeopen == 0) {
8010304e:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80103055:	75 09                	jne    80103060 <pipeclose+0x47>
80103057:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
8010305e:	74 2f                	je     8010308f <pipeclose+0x76>
        release(&p->lock);
        kfree((char *)p);
    } else
        release(&p->lock);
80103060:	83 ec 0c             	sub    $0xc,%esp
80103063:	53                   	push   %ebx
80103064:	e8 73 10 00 00       	call   801040dc <release>
80103069:	83 c4 10             	add    $0x10,%esp
}
8010306c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010306f:	c9                   	leave  
80103070:	c3                   	ret    
        p->readopen = 0;
80103071:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103078:	00 00 00 
        wakeup(&p->nwrite);
8010307b:	83 ec 0c             	sub    $0xc,%esp
8010307e:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103084:	50                   	push   %eax
80103085:	e8 d1 0b 00 00       	call   80103c5b <wakeup>
8010308a:	83 c4 10             	add    $0x10,%esp
8010308d:	eb bf                	jmp    8010304e <pipeclose+0x35>
        release(&p->lock);
8010308f:	83 ec 0c             	sub    $0xc,%esp
80103092:	53                   	push   %ebx
80103093:	e8 44 10 00 00       	call   801040dc <release>
        kfree((char *)p);
80103098:	89 1c 24             	mov    %ebx,(%esp)
8010309b:	e8 99 ef ff ff       	call   80102039 <kfree>
801030a0:	83 c4 10             	add    $0x10,%esp
801030a3:	eb c7                	jmp    8010306c <pipeclose+0x53>

801030a5 <pipewrite>:

// PAGEBREAK: 40
int pipewrite(struct pipe *p, char *addr, int n)
{
801030a5:	55                   	push   %ebp
801030a6:	89 e5                	mov    %esp,%ebp
801030a8:	57                   	push   %edi
801030a9:	56                   	push   %esi
801030aa:	53                   	push   %ebx
801030ab:	83 ec 28             	sub    $0x28,%esp
801030ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
801030b1:	8b 75 0c             	mov    0xc(%ebp),%esi
    int i;

    acquire(&p->lock);
801030b4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801030b7:	53                   	push   %ebx
801030b8:	e8 b8 0f 00 00       	call   80104075 <acquire>
    for (i = 0; i < n; i++) {
801030bd:	83 c4 10             	add    $0x10,%esp
801030c0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801030c4:	0f 8e b5 00 00 00    	jle    8010317f <pipewrite+0xda>
801030ca:	89 75 e0             	mov    %esi,-0x20(%ebp)
801030cd:	03 75 10             	add    0x10(%ebp),%esi
801030d0:	89 75 dc             	mov    %esi,-0x24(%ebp)
        while (p->nwrite == p->nread + PIPESIZE) { // DOC: pipewrite-full
            if (p->readopen == 0 || myproc()->killed) {
                release(&p->lock);
                return -1;
            }
            wakeup(&p->nread);
801030d3:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
        while (p->nwrite == p->nread + PIPESIZE) { // DOC: pipewrite-full
801030d9:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
801030df:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801030e5:	05 00 02 00 00       	add    $0x200,%eax
801030ea:	39 c2                	cmp    %eax,%edx
801030ec:	75 69                	jne    80103157 <pipewrite+0xb2>
            if (p->readopen == 0 || myproc()->killed) {
801030ee:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
801030f5:	74 47                	je     8010313e <pipewrite+0x99>
            sleep(&p->nwrite, &p->lock); // DOC: pipewrite-sleep
801030f7:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
            if (p->readopen == 0 || myproc()->killed) {
801030fd:	e8 c9 03 00 00       	call   801034cb <myproc>
80103102:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103106:	75 36                	jne    8010313e <pipewrite+0x99>
            wakeup(&p->nread);
80103108:	83 ec 0c             	sub    $0xc,%esp
8010310b:	57                   	push   %edi
8010310c:	e8 4a 0b 00 00       	call   80103c5b <wakeup>
            sleep(&p->nwrite, &p->lock); // DOC: pipewrite-sleep
80103111:	83 c4 08             	add    $0x8,%esp
80103114:	ff 75 e4             	pushl  -0x1c(%ebp)
80103117:	56                   	push   %esi
80103118:	e8 66 09 00 00       	call   80103a83 <sleep>
        while (p->nwrite == p->nread + PIPESIZE) { // DOC: pipewrite-full
8010311d:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103123:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103129:	05 00 02 00 00       	add    $0x200,%eax
8010312e:	83 c4 10             	add    $0x10,%esp
80103131:	39 c2                	cmp    %eax,%edx
80103133:	75 22                	jne    80103157 <pipewrite+0xb2>
            if (p->readopen == 0 || myproc()->killed) {
80103135:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
8010313c:	75 bf                	jne    801030fd <pipewrite+0x58>
                release(&p->lock);
8010313e:	83 ec 0c             	sub    $0xc,%esp
80103141:	53                   	push   %ebx
80103142:	e8 95 0f 00 00       	call   801040dc <release>
                return -1;
80103147:	83 c4 10             	add    $0x10,%esp
8010314a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
        p->data[p->nwrite++ % PIPESIZE] = addr[i];
    }
    wakeup(&p->nread); // DOC: pipewrite-wakeup1
    release(&p->lock);
    return n;
}
8010314f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103152:	5b                   	pop    %ebx
80103153:	5e                   	pop    %esi
80103154:	5f                   	pop    %edi
80103155:	5d                   	pop    %ebp
80103156:	c3                   	ret    
        p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103157:	8d 42 01             	lea    0x1(%edx),%eax
8010315a:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80103160:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80103163:	0f b6 01             	movzbl (%ecx),%eax
80103166:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
8010316c:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
80103170:	83 c1 01             	add    $0x1,%ecx
80103173:	89 4d e0             	mov    %ecx,-0x20(%ebp)
    for (i = 0; i < n; i++) {
80103176:	3b 4d dc             	cmp    -0x24(%ebp),%ecx
80103179:	0f 85 5a ff ff ff    	jne    801030d9 <pipewrite+0x34>
    wakeup(&p->nread); // DOC: pipewrite-wakeup1
8010317f:	83 ec 0c             	sub    $0xc,%esp
80103182:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103188:	50                   	push   %eax
80103189:	e8 cd 0a 00 00       	call   80103c5b <wakeup>
    release(&p->lock);
8010318e:	89 1c 24             	mov    %ebx,(%esp)
80103191:	e8 46 0f 00 00       	call   801040dc <release>
    return n;
80103196:	83 c4 10             	add    $0x10,%esp
80103199:	8b 45 10             	mov    0x10(%ebp),%eax
8010319c:	eb b1                	jmp    8010314f <pipewrite+0xaa>

8010319e <piperead>:

int piperead(struct pipe *p, char *addr, int n)
{
8010319e:	55                   	push   %ebp
8010319f:	89 e5                	mov    %esp,%ebp
801031a1:	57                   	push   %edi
801031a2:	56                   	push   %esi
801031a3:	53                   	push   %ebx
801031a4:	83 ec 18             	sub    $0x18,%esp
801031a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
    int i;

    acquire(&p->lock);
801031aa:	53                   	push   %ebx
801031ab:	e8 c5 0e 00 00       	call   80104075 <acquire>
    while (p->nread == p->nwrite && p->writeopen) { // DOC: pipe-empty
801031b0:	83 c4 10             	add    $0x10,%esp
801031b3:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
801031b9:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
801031bf:	75 7c                	jne    8010323d <piperead+0x9f>
801031c1:	89 de                	mov    %ebx,%esi
801031c3:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
801031ca:	74 35                	je     80103201 <piperead+0x63>
        if (myproc()->killed) {
            release(&p->lock);
            return -1;
        }
        sleep(&p->nread, &p->lock); // DOC: piperead-sleep
801031cc:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
        if (myproc()->killed) {
801031d2:	e8 f4 02 00 00       	call   801034cb <myproc>
801031d7:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801031db:	75 4d                	jne    8010322a <piperead+0x8c>
        sleep(&p->nread, &p->lock); // DOC: piperead-sleep
801031dd:	83 ec 08             	sub    $0x8,%esp
801031e0:	56                   	push   %esi
801031e1:	57                   	push   %edi
801031e2:	e8 9c 08 00 00       	call   80103a83 <sleep>
    while (p->nread == p->nwrite && p->writeopen) { // DOC: pipe-empty
801031e7:	83 c4 10             	add    $0x10,%esp
801031ea:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
801031f0:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
801031f6:	75 45                	jne    8010323d <piperead+0x9f>
801031f8:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
801031ff:	75 d1                	jne    801031d2 <piperead+0x34>
    }
    for (i = 0; i < n; i++) { // DOC: piperead-copy
80103201:	be 00 00 00 00       	mov    $0x0,%esi
        if (p->nread == p->nwrite)
            break;
        addr[i] = p->data[p->nread++ % PIPESIZE];
    }
    wakeup(&p->nwrite); // DOC: piperead-wakeup
80103206:	83 ec 0c             	sub    $0xc,%esp
80103209:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010320f:	50                   	push   %eax
80103210:	e8 46 0a 00 00       	call   80103c5b <wakeup>
    release(&p->lock);
80103215:	89 1c 24             	mov    %ebx,(%esp)
80103218:	e8 bf 0e 00 00       	call   801040dc <release>
    return i;
8010321d:	83 c4 10             	add    $0x10,%esp
}
80103220:	89 f0                	mov    %esi,%eax
80103222:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103225:	5b                   	pop    %ebx
80103226:	5e                   	pop    %esi
80103227:	5f                   	pop    %edi
80103228:	5d                   	pop    %ebp
80103229:	c3                   	ret    
            release(&p->lock);
8010322a:	83 ec 0c             	sub    $0xc,%esp
8010322d:	53                   	push   %ebx
8010322e:	e8 a9 0e 00 00       	call   801040dc <release>
            return -1;
80103233:	83 c4 10             	add    $0x10,%esp
80103236:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010323b:	eb e3                	jmp    80103220 <piperead+0x82>
    for (i = 0; i < n; i++) { // DOC: piperead-copy
8010323d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80103241:	7e 3c                	jle    8010327f <piperead+0xe1>
        if (p->nread == p->nwrite)
80103243:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103249:	be 00 00 00 00       	mov    $0x0,%esi
        addr[i] = p->data[p->nread++ % PIPESIZE];
8010324e:	8d 50 01             	lea    0x1(%eax),%edx
80103251:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80103257:	25 ff 01 00 00       	and    $0x1ff,%eax
8010325c:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103261:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103264:	88 04 31             	mov    %al,(%ecx,%esi,1)
    for (i = 0; i < n; i++) { // DOC: piperead-copy
80103267:	83 c6 01             	add    $0x1,%esi
8010326a:	39 75 10             	cmp    %esi,0x10(%ebp)
8010326d:	74 97                	je     80103206 <piperead+0x68>
        if (p->nread == p->nwrite)
8010326f:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103275:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
8010327b:	75 d1                	jne    8010324e <piperead+0xb0>
8010327d:	eb 87                	jmp    80103206 <piperead+0x68>
    for (i = 0; i < n; i++) { // DOC: piperead-copy
8010327f:	be 00 00 00 00       	mov    $0x0,%esi
80103284:	eb 80                	jmp    80103206 <piperead+0x68>

80103286 <wakeup1>:

// PAGEBREAK!
//  Wake up all processes sleeping on chan.
//  The ptable lock must be held.
static void wakeup1(void *chan)
{
80103286:	55                   	push   %ebp
80103287:	89 e5                	mov    %esp,%ebp
80103289:	56                   	push   %esi
8010328a:	53                   	push   %ebx
8010328b:	89 c6                	mov    %eax,%esi
    struct proc *p;
    // cprintf("[DEBUG] wakeup1() chan: %p\n", chan);

    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010328d:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103292:	eb 0e                	jmp    801032a2 <wakeup1+0x1c>
80103294:	81 c3 94 00 00 00    	add    $0x94,%ebx
8010329a:	81 fb 54 52 11 80    	cmp    $0x80115254,%ebx
801032a0:	73 32                	jae    801032d4 <wakeup1+0x4e>
        if (p->state == SLEEPING && p->chan == chan) {
801032a2:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801032a6:	75 ec                	jne    80103294 <wakeup1+0xe>
801032a8:	39 73 20             	cmp    %esi,0x20(%ebx)
801032ab:	75 e7                	jne    80103294 <wakeup1+0xe>
            p->state = RUNNABLE;
801032ad:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
            p->priority = HIGH;
801032b4:	c7 83 88 00 00 00 00 	movl   $0x0,0x88(%ebx)
801032bb:	00 00 00 
            if (!p->in_queue)
801032be:	83 7b 7c 00          	cmpl   $0x0,0x7c(%ebx)
801032c2:	75 d0                	jne    80103294 <wakeup1+0xe>
                queue_push(p->priority, p);
801032c4:	83 ec 08             	sub    $0x8,%esp
801032c7:	53                   	push   %ebx
801032c8:	6a 00                	push   $0x0
801032ca:	e8 38 fb ff ff       	call   80102e07 <queue_push>
801032cf:	83 c4 10             	add    $0x10,%esp
801032d2:	eb c0                	jmp    80103294 <wakeup1+0xe>
            // cprintf("[WAKEUP1] checking pid %d name %s state %d chan %p\n", p->pid, p->name, p->state, p->chan);
        }
}
801032d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801032d7:	5b                   	pop    %ebx
801032d8:	5e                   	pop    %esi
801032d9:	5d                   	pop    %ebp
801032da:	c3                   	ret    

801032db <allocproc>:
{
801032db:	55                   	push   %ebp
801032dc:	89 e5                	mov    %esp,%ebp
801032de:	53                   	push   %ebx
801032df:	83 ec 10             	sub    $0x10,%esp
    acquire(&ptable.lock);
801032e2:	68 20 2d 11 80       	push   $0x80112d20
801032e7:	e8 89 0d 00 00       	call   80104075 <acquire>
        if (p->state == UNUSED)
801032ec:	83 c4 10             	add    $0x10,%esp
801032ef:	83 3d 60 2d 11 80 00 	cmpl   $0x0,0x80112d60
801032f6:	74 33                	je     8010332b <allocproc+0x50>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801032f8:	bb e8 2d 11 80       	mov    $0x80112de8,%ebx
        if (p->state == UNUSED)
801032fd:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
80103301:	74 2d                	je     80103330 <allocproc+0x55>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103303:	81 c3 94 00 00 00    	add    $0x94,%ebx
80103309:	81 fb 54 52 11 80    	cmp    $0x80115254,%ebx
8010330f:	72 ec                	jb     801032fd <allocproc+0x22>
    release(&ptable.lock);
80103311:	83 ec 0c             	sub    $0xc,%esp
80103314:	68 20 2d 11 80       	push   $0x80112d20
80103319:	e8 be 0d 00 00       	call   801040dc <release>
    return 0;
8010331e:	83 c4 10             	add    $0x10,%esp
80103321:	bb 00 00 00 00       	mov    $0x0,%ebx
80103326:	e9 94 00 00 00       	jmp    801033bf <allocproc+0xe4>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010332b:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
    p->state = EMBRYO;
80103330:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
    p->pid = nextpid++;
80103337:	a1 04 a0 10 80       	mov    0x8010a004,%eax
8010333c:	8d 50 01             	lea    0x1(%eax),%edx
8010333f:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80103345:	89 43 10             	mov    %eax,0x10(%ebx)
    p->priority = HIGH;
80103348:	c7 83 88 00 00 00 00 	movl   $0x0,0x88(%ebx)
8010334f:	00 00 00 
    p->proc_tick = 0;
80103352:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80103359:	00 00 00 
    p->sched_tick = ticks;
8010335c:	a1 a0 5a 11 80       	mov    0x80115aa0,%eax
80103361:	89 83 90 00 00 00    	mov    %eax,0x90(%ebx)
    p->in_queue = 0;
80103367:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
    release(&ptable.lock);
8010336e:	83 ec 0c             	sub    $0xc,%esp
80103371:	68 20 2d 11 80       	push   $0x80112d20
80103376:	e8 61 0d 00 00       	call   801040dc <release>
    if ((p->kstack = kalloc()) == 0) {
8010337b:	e8 de ed ff ff       	call   8010215e <kalloc>
80103380:	89 43 08             	mov    %eax,0x8(%ebx)
80103383:	83 c4 10             	add    $0x10,%esp
80103386:	85 c0                	test   %eax,%eax
80103388:	74 3c                	je     801033c6 <allocproc+0xeb>
    sp -= sizeof *p->tf;
8010338a:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
80103390:	89 53 18             	mov    %edx,0x18(%ebx)
    *(uint *)sp = (uint)trapret;
80103393:	c7 80 b0 0f 00 00 c8 	movl   $0x801051c8,0xfb0(%eax)
8010339a:	51 10 80 
    sp -= sizeof *p->context;
8010339d:	05 9c 0f 00 00       	add    $0xf9c,%eax
    p->context = (struct context *)sp;
801033a2:	89 43 1c             	mov    %eax,0x1c(%ebx)
    memset(p->context, 0, sizeof *p->context);
801033a5:	83 ec 04             	sub    $0x4,%esp
801033a8:	6a 14                	push   $0x14
801033aa:	6a 00                	push   $0x0
801033ac:	50                   	push   %eax
801033ad:	e8 71 0d 00 00       	call   80104123 <memset>
    p->context->eip = (uint)forkret;
801033b2:	8b 43 1c             	mov    0x1c(%ebx),%eax
801033b5:	c7 40 10 d4 33 10 80 	movl   $0x801033d4,0x10(%eax)
    return p;
801033bc:	83 c4 10             	add    $0x10,%esp
}
801033bf:	89 d8                	mov    %ebx,%eax
801033c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801033c4:	c9                   	leave  
801033c5:	c3                   	ret    
        p->state = UNUSED;
801033c6:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        return 0;
801033cd:	bb 00 00 00 00       	mov    $0x0,%ebx
801033d2:	eb eb                	jmp    801033bf <allocproc+0xe4>

801033d4 <forkret>:
{
801033d4:	55                   	push   %ebp
801033d5:	89 e5                	mov    %esp,%ebp
801033d7:	83 ec 14             	sub    $0x14,%esp
    release(&ptable.lock);
801033da:	68 20 2d 11 80       	push   $0x80112d20
801033df:	e8 f8 0c 00 00       	call   801040dc <release>
    if (first) {
801033e4:	83 c4 10             	add    $0x10,%esp
801033e7:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
801033ee:	75 02                	jne    801033f2 <forkret+0x1e>
}
801033f0:	c9                   	leave  
801033f1:	c3                   	ret    
        first = 0;
801033f2:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
801033f9:	00 00 00 
        iinit(ROOTDEV);
801033fc:	83 ec 0c             	sub    $0xc,%esp
801033ff:	6a 01                	push   $0x1
80103401:	e8 00 df ff ff       	call   80101306 <iinit>
        initlog(ROOTDEV);
80103406:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010340d:	e8 06 f3 ff ff       	call   80102718 <initlog>
80103412:	83 c4 10             	add    $0x10,%esp
}
80103415:	eb d9                	jmp    801033f0 <forkret+0x1c>

80103417 <pinit>:
{
80103417:	55                   	push   %ebp
80103418:	89 e5                	mov    %esp,%ebp
8010341a:	83 ec 08             	sub    $0x8,%esp
    queue_init();
8010341d:	e8 a4 f9 ff ff       	call   80102dc6 <queue_init>
    initlock(&ptable.lock, "ptable");
80103422:	83 ec 08             	sub    $0x8,%esp
80103425:	68 55 6e 10 80       	push   $0x80106e55
8010342a:	68 20 2d 11 80       	push   $0x80112d20
8010342f:	e8 f9 0a 00 00       	call   80103f2d <initlock>
}
80103434:	83 c4 10             	add    $0x10,%esp
80103437:	c9                   	leave  
80103438:	c3                   	ret    

80103439 <mycpu>:
{
80103439:	55                   	push   %ebp
8010343a:	89 e5                	mov    %esp,%ebp
8010343c:	56                   	push   %esi
8010343d:	53                   	push   %ebx
    asm volatile("pushfl; popl %0" : "=r"(eflags));
8010343e:	9c                   	pushf  
8010343f:	58                   	pop    %eax
    if (readeflags() & FL_IF)
80103440:	f6 c4 02             	test   $0x2,%ah
80103443:	75 4a                	jne    8010348f <mycpu+0x56>
    apicid = lapicid();
80103445:	e8 f6 ef ff ff       	call   80102440 <lapicid>
    for (i = 0; i < ncpu; ++i) {
8010344a:	8b 35 00 2d 11 80    	mov    0x80112d00,%esi
80103450:	85 f6                	test   %esi,%esi
80103452:	7e 4f                	jle    801034a3 <mycpu+0x6a>
        if (cpus[i].apicid == apicid)
80103454:	0f b6 15 80 27 11 80 	movzbl 0x80112780,%edx
8010345b:	39 d0                	cmp    %edx,%eax
8010345d:	74 3d                	je     8010349c <mycpu+0x63>
8010345f:	b9 30 28 11 80       	mov    $0x80112830,%ecx
    for (i = 0; i < ncpu; ++i) {
80103464:	ba 00 00 00 00       	mov    $0x0,%edx
80103469:	83 c2 01             	add    $0x1,%edx
8010346c:	39 f2                	cmp    %esi,%edx
8010346e:	74 33                	je     801034a3 <mycpu+0x6a>
        if (cpus[i].apicid == apicid)
80103470:	0f b6 19             	movzbl (%ecx),%ebx
80103473:	81 c1 b0 00 00 00    	add    $0xb0,%ecx
80103479:	39 c3                	cmp    %eax,%ebx
8010347b:	75 ec                	jne    80103469 <mycpu+0x30>
            return &cpus[i];
8010347d:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103483:	05 80 27 11 80       	add    $0x80112780,%eax
}
80103488:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010348b:	5b                   	pop    %ebx
8010348c:	5e                   	pop    %esi
8010348d:	5d                   	pop    %ebp
8010348e:	c3                   	ret    
        panic("mycpu called with interrupts enabled\n");
8010348f:	83 ec 0c             	sub    $0xc,%esp
80103492:	68 38 6f 10 80       	push   $0x80106f38
80103497:	e8 a8 ce ff ff       	call   80100344 <panic>
    for (i = 0; i < ncpu; ++i) {
8010349c:	ba 00 00 00 00       	mov    $0x0,%edx
801034a1:	eb da                	jmp    8010347d <mycpu+0x44>
    panic("unknown apicid\n");
801034a3:	83 ec 0c             	sub    $0xc,%esp
801034a6:	68 5c 6e 10 80       	push   $0x80106e5c
801034ab:	e8 94 ce ff ff       	call   80100344 <panic>

801034b0 <cpuid>:
{
801034b0:	55                   	push   %ebp
801034b1:	89 e5                	mov    %esp,%ebp
801034b3:	83 ec 08             	sub    $0x8,%esp
    return mycpu() - cpus;
801034b6:	e8 7e ff ff ff       	call   80103439 <mycpu>
801034bb:	2d 80 27 11 80       	sub    $0x80112780,%eax
801034c0:	c1 f8 04             	sar    $0x4,%eax
801034c3:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801034c9:	c9                   	leave  
801034ca:	c3                   	ret    

801034cb <myproc>:
{
801034cb:	55                   	push   %ebp
801034cc:	89 e5                	mov    %esp,%ebp
801034ce:	53                   	push   %ebx
801034cf:	83 ec 04             	sub    $0x4,%esp
    pushcli();
801034d2:	e8 cd 0a 00 00       	call   80103fa4 <pushcli>
    c = mycpu();
801034d7:	e8 5d ff ff ff       	call   80103439 <mycpu>
    p = c->proc;
801034dc:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
    popcli();
801034e2:	e8 fa 0a 00 00       	call   80103fe1 <popcli>
}
801034e7:	89 d8                	mov    %ebx,%eax
801034e9:	83 c4 04             	add    $0x4,%esp
801034ec:	5b                   	pop    %ebx
801034ed:	5d                   	pop    %ebp
801034ee:	c3                   	ret    

801034ef <userinit>:
{
801034ef:	55                   	push   %ebp
801034f0:	89 e5                	mov    %esp,%ebp
801034f2:	53                   	push   %ebx
801034f3:	83 ec 04             	sub    $0x4,%esp
    p = allocproc();
801034f6:	e8 e0 fd ff ff       	call   801032db <allocproc>
801034fb:	89 c3                	mov    %eax,%ebx
    initproc = p;
801034fd:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
    if ((p->pgdir = setupkvm()) == 0)
80103502:	e8 a7 31 00 00       	call   801066ae <setupkvm>
80103507:	89 43 04             	mov    %eax,0x4(%ebx)
8010350a:	85 c0                	test   %eax,%eax
8010350c:	0f 84 e1 00 00 00    	je     801035f3 <userinit+0x104>
    inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103512:	83 ec 04             	sub    $0x4,%esp
80103515:	68 2c 00 00 00       	push   $0x2c
8010351a:	68 60 a4 10 80       	push   $0x8010a460
8010351f:	50                   	push   %eax
80103520:	e8 82 2e 00 00       	call   801063a7 <inituvm>
    p->sz = PGSIZE;
80103525:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
    memset(p->tf, 0, sizeof(*p->tf));
8010352b:	83 c4 0c             	add    $0xc,%esp
8010352e:	6a 4c                	push   $0x4c
80103530:	6a 00                	push   $0x0
80103532:	ff 73 18             	pushl  0x18(%ebx)
80103535:	e8 e9 0b 00 00       	call   80104123 <memset>
    p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010353a:	8b 43 18             	mov    0x18(%ebx),%eax
8010353d:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103543:	8b 43 18             	mov    0x18(%ebx),%eax
80103546:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
    p->tf->es = p->tf->ds;
8010354c:	8b 43 18             	mov    0x18(%ebx),%eax
8010354f:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103553:	66 89 50 28          	mov    %dx,0x28(%eax)
    p->tf->ss = p->tf->ds;
80103557:	8b 43 18             	mov    0x18(%ebx),%eax
8010355a:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010355e:	66 89 50 48          	mov    %dx,0x48(%eax)
    p->tf->eflags = FL_IF;
80103562:	8b 43 18             	mov    0x18(%ebx),%eax
80103565:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    p->tf->esp = PGSIZE;
8010356c:	8b 43 18             	mov    0x18(%ebx),%eax
8010356f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
    p->tf->eip = 0; // beginning of initcode.S
80103576:	8b 43 18             	mov    0x18(%ebx),%eax
80103579:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
    safestrcpy(p->name, "initcode", sizeof(p->name));
80103580:	83 c4 0c             	add    $0xc,%esp
80103583:	6a 10                	push   $0x10
80103585:	68 85 6e 10 80       	push   $0x80106e85
8010358a:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010358d:	50                   	push   %eax
8010358e:	e8 1f 0d 00 00       	call   801042b2 <safestrcpy>
    p->cwd = namei("/");
80103593:	c7 04 24 8e 6e 10 80 	movl   $0x80106e8e,(%esp)
8010359a:	e8 e4 e6 ff ff       	call   80101c83 <namei>
8010359f:	89 43 68             	mov    %eax,0x68(%ebx)
    acquire(&ptable.lock);
801035a2:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801035a9:	e8 c7 0a 00 00       	call   80104075 <acquire>
    p->state = RUNNABLE;
801035ae:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
    p->priority = HIGH;
801035b5:	c7 83 88 00 00 00 00 	movl   $0x0,0x88(%ebx)
801035bc:	00 00 00 
    p->proc_tick = 0;
801035bf:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
801035c6:	00 00 00 
    p->sched_tick = ticks;
801035c9:	a1 a0 5a 11 80       	mov    0x80115aa0,%eax
801035ce:	89 83 90 00 00 00    	mov    %eax,0x90(%ebx)
    queue_push(p->priority, p);
801035d4:	83 c4 08             	add    $0x8,%esp
801035d7:	53                   	push   %ebx
801035d8:	6a 00                	push   $0x0
801035da:	e8 28 f8 ff ff       	call   80102e07 <queue_push>
    release(&ptable.lock);
801035df:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801035e6:	e8 f1 0a 00 00       	call   801040dc <release>
}
801035eb:	83 c4 10             	add    $0x10,%esp
801035ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801035f1:	c9                   	leave  
801035f2:	c3                   	ret    
        panic("userinit: out of memory?");
801035f3:	83 ec 0c             	sub    $0xc,%esp
801035f6:	68 6c 6e 10 80       	push   $0x80106e6c
801035fb:	e8 44 cd ff ff       	call   80100344 <panic>

80103600 <growproc>:
{
80103600:	55                   	push   %ebp
80103601:	89 e5                	mov    %esp,%ebp
80103603:	56                   	push   %esi
80103604:	53                   	push   %ebx
80103605:	8b 75 08             	mov    0x8(%ebp),%esi
    struct proc *curproc = myproc();
80103608:	e8 be fe ff ff       	call   801034cb <myproc>
8010360d:	89 c3                	mov    %eax,%ebx
    sz = curproc->sz;
8010360f:	8b 00                	mov    (%eax),%eax
    if (n > 0) {
80103611:	85 f6                	test   %esi,%esi
80103613:	7f 21                	jg     80103636 <growproc+0x36>
    } else if (n < 0) {
80103615:	85 f6                	test   %esi,%esi
80103617:	79 33                	jns    8010364c <growproc+0x4c>
        if ((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103619:	83 ec 04             	sub    $0x4,%esp
8010361c:	01 c6                	add    %eax,%esi
8010361e:	56                   	push   %esi
8010361f:	50                   	push   %eax
80103620:	ff 73 04             	pushl  0x4(%ebx)
80103623:	e8 96 2e 00 00       	call   801064be <deallocuvm>
80103628:	83 c4 10             	add    $0x10,%esp
8010362b:	85 c0                	test   %eax,%eax
8010362d:	75 1d                	jne    8010364c <growproc+0x4c>
            return -1;
8010362f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103634:	eb 29                	jmp    8010365f <growproc+0x5f>
        if ((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103636:	83 ec 04             	sub    $0x4,%esp
80103639:	01 c6                	add    %eax,%esi
8010363b:	56                   	push   %esi
8010363c:	50                   	push   %eax
8010363d:	ff 73 04             	pushl  0x4(%ebx)
80103640:	e8 08 2f 00 00       	call   8010654d <allocuvm>
80103645:	83 c4 10             	add    $0x10,%esp
80103648:	85 c0                	test   %eax,%eax
8010364a:	74 1a                	je     80103666 <growproc+0x66>
    curproc->sz = sz;
8010364c:	89 03                	mov    %eax,(%ebx)
    switchuvm(curproc);
8010364e:	83 ec 0c             	sub    $0xc,%esp
80103651:	53                   	push   %ebx
80103652:	e8 52 2c 00 00       	call   801062a9 <switchuvm>
    return 0;
80103657:	83 c4 10             	add    $0x10,%esp
8010365a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010365f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103662:	5b                   	pop    %ebx
80103663:	5e                   	pop    %esi
80103664:	5d                   	pop    %ebp
80103665:	c3                   	ret    
            return -1;
80103666:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010366b:	eb f2                	jmp    8010365f <growproc+0x5f>

8010366d <scheduler>:
{
8010366d:	55                   	push   %ebp
8010366e:	89 e5                	mov    %esp,%ebp
80103670:	57                   	push   %edi
80103671:	56                   	push   %esi
80103672:	53                   	push   %ebx
80103673:	83 ec 1c             	sub    $0x1c,%esp
    struct cpu *c = mycpu();
80103676:	e8 be fd ff ff       	call   80103439 <mycpu>
8010367b:	89 c7                	mov    %eax,%edi
    c->proc = 0;
8010367d:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103684:	00 00 00 
            swtch(&(c->scheduler), p->context);
80103687:	8d 40 04             	lea    0x4(%eax),%eax
8010368a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010368d:	eb 25                	jmp    801036b4 <scheduler+0x47>
                queue_push(level, p);  // RUNNABLE이 아니면 재삽입
8010368f:	83 ec 08             	sub    $0x8,%esp
80103692:	50                   	push   %eax
80103693:	53                   	push   %ebx
80103694:	e8 6e f7 ff ff       	call   80102e07 <queue_push>
                continue;
80103699:	83 c4 10             	add    $0x10,%esp
        for (int level = 0; level < MAX_PRIORITY_LEVEL; level++) {
8010369c:	83 c3 01             	add    $0x1,%ebx
8010369f:	83 fb 03             	cmp    $0x3,%ebx
801036a2:	75 26                	jne    801036ca <scheduler+0x5d>
        release(&ptable.lock);
801036a4:	83 ec 0c             	sub    $0xc,%esp
801036a7:	68 20 2d 11 80       	push   $0x80112d20
801036ac:	e8 2b 0a 00 00       	call   801040dc <release>
        sti();  // 인터럽트 허용
801036b1:	83 c4 10             	add    $0x10,%esp
    asm volatile("sti");
801036b4:	fb                   	sti    
        acquire(&ptable.lock);
801036b5:	83 ec 0c             	sub    $0xc,%esp
801036b8:	68 20 2d 11 80       	push   $0x80112d20
801036bd:	e8 b3 09 00 00       	call   80104075 <acquire>
801036c2:	83 c4 10             	add    $0x10,%esp
        for (int level = 0; level < MAX_PRIORITY_LEVEL; level++) {
801036c5:	bb 00 00 00 00       	mov    $0x0,%ebx
            if (queue_empty(&mlfq_queue[level]))
801036ca:	8d 04 dd 04 2d 11 80 	lea    -0x7feed2fc(,%ebx,8),%eax
801036d1:	39 04 dd 04 2d 11 80 	cmp    %eax,-0x7feed2fc(,%ebx,8)
801036d8:	74 c2                	je     8010369c <scheduler+0x2f>
            p = queue_pop(level);  // 반드시 pop()하여 제거
801036da:	83 ec 0c             	sub    $0xc,%esp
801036dd:	53                   	push   %ebx
801036de:	e8 a1 f7 ff ff       	call   80102e84 <queue_pop>
801036e3:	89 c6                	mov    %eax,%esi
            if (p->state != RUNNABLE) {
801036e5:	83 c4 10             	add    $0x10,%esp
801036e8:	83 78 0c 03          	cmpl   $0x3,0xc(%eax)
801036ec:	75 a1                	jne    8010368f <scheduler+0x22>
            c->proc = p;
801036ee:	89 87 ac 00 00 00    	mov    %eax,0xac(%edi)
            switchuvm(p);
801036f4:	83 ec 0c             	sub    $0xc,%esp
801036f7:	50                   	push   %eax
801036f8:	e8 ac 2b 00 00       	call   801062a9 <switchuvm>
            p->state = RUNNING;
801036fd:	c7 46 0c 04 00 00 00 	movl   $0x4,0xc(%esi)
            p->sched_tick = ticks;
80103704:	a1 a0 5a 11 80       	mov    0x80115aa0,%eax
80103709:	89 86 90 00 00 00    	mov    %eax,0x90(%esi)
            swtch(&(c->scheduler), p->context);
8010370f:	83 c4 08             	add    $0x8,%esp
80103712:	ff 76 1c             	pushl  0x1c(%esi)
80103715:	ff 75 e4             	pushl  -0x1c(%ebp)
80103718:	e8 eb 0b 00 00       	call   80104308 <swtch>
            switchkvm();
8010371d:	e8 75 2b 00 00       	call   80106297 <switchkvm>
            c->proc = 0;
80103722:	c7 87 ac 00 00 00 00 	movl   $0x0,0xac(%edi)
80103729:	00 00 00 
            break;
8010372c:	83 c4 10             	add    $0x10,%esp
8010372f:	e9 70 ff ff ff       	jmp    801036a4 <scheduler+0x37>

80103734 <sched>:
{
80103734:	55                   	push   %ebp
80103735:	89 e5                	mov    %esp,%ebp
80103737:	56                   	push   %esi
80103738:	53                   	push   %ebx
    struct proc *p = myproc();
80103739:	e8 8d fd ff ff       	call   801034cb <myproc>
8010373e:	89 c3                	mov    %eax,%ebx
    if (!holding(&ptable.lock))
80103740:	83 ec 0c             	sub    $0xc,%esp
80103743:	68 20 2d 11 80       	push   $0x80112d20
80103748:	e8 f4 08 00 00       	call   80104041 <holding>
8010374d:	83 c4 10             	add    $0x10,%esp
80103750:	85 c0                	test   %eax,%eax
80103752:	74 4f                	je     801037a3 <sched+0x6f>
    if (mycpu()->ncli != 1)
80103754:	e8 e0 fc ff ff       	call   80103439 <mycpu>
80103759:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103760:	75 4e                	jne    801037b0 <sched+0x7c>
    if (p->state == RUNNING)
80103762:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103766:	74 55                	je     801037bd <sched+0x89>
    asm volatile("pushfl; popl %0" : "=r"(eflags));
80103768:	9c                   	pushf  
80103769:	58                   	pop    %eax
    if (readeflags() & FL_IF)
8010376a:	f6 c4 02             	test   $0x2,%ah
8010376d:	75 5b                	jne    801037ca <sched+0x96>
    intena = mycpu()->intena;
8010376f:	e8 c5 fc ff ff       	call   80103439 <mycpu>
80103774:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
    swtch(&p->context, mycpu()->scheduler);
8010377a:	e8 ba fc ff ff       	call   80103439 <mycpu>
8010377f:	83 ec 08             	sub    $0x8,%esp
80103782:	ff 70 04             	pushl  0x4(%eax)
80103785:	83 c3 1c             	add    $0x1c,%ebx
80103788:	53                   	push   %ebx
80103789:	e8 7a 0b 00 00       	call   80104308 <swtch>
    mycpu()->intena = intena;
8010378e:	e8 a6 fc ff ff       	call   80103439 <mycpu>
80103793:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103799:	83 c4 10             	add    $0x10,%esp
8010379c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010379f:	5b                   	pop    %ebx
801037a0:	5e                   	pop    %esi
801037a1:	5d                   	pop    %ebp
801037a2:	c3                   	ret    
        panic("sched ptable.lock");
801037a3:	83 ec 0c             	sub    $0xc,%esp
801037a6:	68 90 6e 10 80       	push   $0x80106e90
801037ab:	e8 94 cb ff ff       	call   80100344 <panic>
        panic("sched locks");
801037b0:	83 ec 0c             	sub    $0xc,%esp
801037b3:	68 a2 6e 10 80       	push   $0x80106ea2
801037b8:	e8 87 cb ff ff       	call   80100344 <panic>
        panic("sched running");
801037bd:	83 ec 0c             	sub    $0xc,%esp
801037c0:	68 ae 6e 10 80       	push   $0x80106eae
801037c5:	e8 7a cb ff ff       	call   80100344 <panic>
        panic("sched interruptible");
801037ca:	83 ec 0c             	sub    $0xc,%esp
801037cd:	68 bc 6e 10 80       	push   $0x80106ebc
801037d2:	e8 6d cb ff ff       	call   80100344 <panic>

801037d7 <fork>:
{
801037d7:	55                   	push   %ebp
801037d8:	89 e5                	mov    %esp,%ebp
801037da:	57                   	push   %edi
801037db:	56                   	push   %esi
801037dc:	53                   	push   %ebx
801037dd:	83 ec 1c             	sub    $0x1c,%esp
    struct proc *curproc = myproc();
801037e0:	e8 e6 fc ff ff       	call   801034cb <myproc>
801037e5:	89 c3                	mov    %eax,%ebx
    if ((np = allocproc()) == 0) {
801037e7:	e8 ef fa ff ff       	call   801032db <allocproc>
801037ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801037ef:	85 c0                	test   %eax,%eax
801037f1:	0f 84 45 01 00 00    	je     8010393c <fork+0x165>
801037f7:	89 c7                	mov    %eax,%edi
    if ((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0) {
801037f9:	83 ec 08             	sub    $0x8,%esp
801037fc:	ff 33                	pushl  (%ebx)
801037fe:	ff 73 04             	pushl  0x4(%ebx)
80103801:	e8 59 2f 00 00       	call   8010675f <copyuvm>
80103806:	89 47 04             	mov    %eax,0x4(%edi)
80103809:	83 c4 10             	add    $0x10,%esp
8010380c:	85 c0                	test   %eax,%eax
8010380e:	74 28                	je     80103838 <fork+0x61>
    np->sz = curproc->sz;
80103810:	8b 03                	mov    (%ebx),%eax
80103812:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103815:	89 02                	mov    %eax,(%edx)
    np->parent = curproc;
80103817:	89 5a 14             	mov    %ebx,0x14(%edx)
    *np->tf = *curproc->tf;
8010381a:	8b 73 18             	mov    0x18(%ebx),%esi
8010381d:	8b 7a 18             	mov    0x18(%edx),%edi
80103820:	b9 13 00 00 00       	mov    $0x13,%ecx
80103825:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    np->tf->eax = 0;
80103827:	8b 42 18             	mov    0x18(%edx),%eax
8010382a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
    for (i = 0; i < NOFILE; i++)
80103831:	be 00 00 00 00       	mov    $0x0,%esi
80103836:	eb 31                	jmp    80103869 <fork+0x92>
        kfree(np->kstack);
80103838:	83 ec 0c             	sub    $0xc,%esp
8010383b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010383e:	ff 77 08             	pushl  0x8(%edi)
80103841:	e8 f3 e7 ff ff       	call   80102039 <kfree>
        np->kstack = 0;
80103846:	c7 47 08 00 00 00 00 	movl   $0x0,0x8(%edi)
        np->state = UNUSED;
8010384d:	c7 47 0c 00 00 00 00 	movl   $0x0,0xc(%edi)
        return -1;
80103854:	83 c4 10             	add    $0x10,%esp
80103857:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010385c:	e9 d1 00 00 00       	jmp    80103932 <fork+0x15b>
    for (i = 0; i < NOFILE; i++)
80103861:	83 c6 01             	add    $0x1,%esi
80103864:	83 fe 10             	cmp    $0x10,%esi
80103867:	74 1d                	je     80103886 <fork+0xaf>
        if (curproc->ofile[i])
80103869:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
8010386d:	85 c0                	test   %eax,%eax
8010386f:	74 f0                	je     80103861 <fork+0x8a>
            np->ofile[i] = filedup(curproc->ofile[i]);
80103871:	83 ec 0c             	sub    $0xc,%esp
80103874:	50                   	push   %eax
80103875:	e8 6d d4 ff ff       	call   80100ce7 <filedup>
8010387a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010387d:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
80103881:	83 c4 10             	add    $0x10,%esp
80103884:	eb db                	jmp    80103861 <fork+0x8a>
    np->cwd = idup(curproc->cwd);
80103886:	83 ec 0c             	sub    $0xc,%esp
80103889:	ff 73 68             	pushl  0x68(%ebx)
8010388c:	e8 2a dc ff ff       	call   801014bb <idup>
80103891:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103894:	89 47 68             	mov    %eax,0x68(%edi)
    safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103897:	83 c4 0c             	add    $0xc,%esp
8010389a:	6a 10                	push   $0x10
8010389c:	83 c3 6c             	add    $0x6c,%ebx
8010389f:	53                   	push   %ebx
801038a0:	8d 47 6c             	lea    0x6c(%edi),%eax
801038a3:	50                   	push   %eax
801038a4:	e8 09 0a 00 00       	call   801042b2 <safestrcpy>
    pid = np->pid;
801038a9:	8b 77 10             	mov    0x10(%edi),%esi
    acquire(&ptable.lock);
801038ac:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801038b3:	e8 bd 07 00 00       	call   80104075 <acquire>
    np->priority = HIGH;
801038b8:	c7 87 88 00 00 00 00 	movl   $0x0,0x88(%edi)
801038bf:	00 00 00 
    np->proc_tick = 0;
801038c2:	c7 87 8c 00 00 00 00 	movl   $0x0,0x8c(%edi)
801038c9:	00 00 00 
    np->sched_tick = ticks;
801038cc:	a1 a0 5a 11 80       	mov    0x80115aa0,%eax
801038d1:	89 87 90 00 00 00    	mov    %eax,0x90(%edi)
    np->state = RUNNABLE;
801038d7:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
    queue_push(np->priority, np);
801038de:	83 c4 08             	add    $0x8,%esp
801038e1:	57                   	push   %edi
801038e2:	6a 00                	push   $0x0
801038e4:	e8 1e f5 ff ff       	call   80102e07 <queue_push>
    release(&ptable.lock);
801038e9:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801038f0:	e8 e7 07 00 00       	call   801040dc <release>
    struct proc *p = myproc();
801038f5:	e8 d1 fb ff ff       	call   801034cb <myproc>
801038fa:	89 c3                	mov    %eax,%ebx
    acquire(&ptable.lock);
801038fc:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103903:	e8 6d 07 00 00       	call   80104075 <acquire>
    p->state = RUNNABLE;
80103908:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
    queue_push_head(p->priority, p);
8010390f:	83 c4 08             	add    $0x8,%esp
80103912:	53                   	push   %ebx
80103913:	ff b3 88 00 00 00    	pushl  0x88(%ebx)
80103919:	e8 26 f5 ff ff       	call   80102e44 <queue_push_head>
    sched();
8010391e:	e8 11 fe ff ff       	call   80103734 <sched>
    release(&ptable.lock);
80103923:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010392a:	e8 ad 07 00 00       	call   801040dc <release>
8010392f:	83 c4 10             	add    $0x10,%esp
}
80103932:	89 f0                	mov    %esi,%eax
80103934:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103937:	5b                   	pop    %ebx
80103938:	5e                   	pop    %esi
80103939:	5f                   	pop    %edi
8010393a:	5d                   	pop    %ebp
8010393b:	c3                   	ret    
        return -1;
8010393c:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103941:	eb ef                	jmp    80103932 <fork+0x15b>

80103943 <exit>:
{
80103943:	55                   	push   %ebp
80103944:	89 e5                	mov    %esp,%ebp
80103946:	57                   	push   %edi
80103947:	56                   	push   %esi
80103948:	53                   	push   %ebx
80103949:	83 ec 0c             	sub    $0xc,%esp
    struct proc *curproc = myproc();
8010394c:	e8 7a fb ff ff       	call   801034cb <myproc>
80103951:	89 c6                	mov    %eax,%esi
80103953:	8d 58 28             	lea    0x28(%eax),%ebx
80103956:	8d 78 68             	lea    0x68(%eax),%edi
    if (curproc == initproc)
80103959:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
8010395f:	75 14                	jne    80103975 <exit+0x32>
        panic("init exiting");
80103961:	83 ec 0c             	sub    $0xc,%esp
80103964:	68 d0 6e 10 80       	push   $0x80106ed0
80103969:	e8 d6 c9 ff ff       	call   80100344 <panic>
8010396e:	83 c3 04             	add    $0x4,%ebx
    for (fd = 0; fd < NOFILE; fd++) {
80103971:	39 df                	cmp    %ebx,%edi
80103973:	74 1a                	je     8010398f <exit+0x4c>
        if (curproc->ofile[fd]) {
80103975:	8b 03                	mov    (%ebx),%eax
80103977:	85 c0                	test   %eax,%eax
80103979:	74 f3                	je     8010396e <exit+0x2b>
            fileclose(curproc->ofile[fd]);
8010397b:	83 ec 0c             	sub    $0xc,%esp
8010397e:	50                   	push   %eax
8010397f:	e8 a8 d3 ff ff       	call   80100d2c <fileclose>
            curproc->ofile[fd] = 0;
80103984:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
8010398a:	83 c4 10             	add    $0x10,%esp
8010398d:	eb df                	jmp    8010396e <exit+0x2b>
    begin_op();
8010398f:	e8 19 ee ff ff       	call   801027ad <begin_op>
    iput(curproc->cwd);
80103994:	83 ec 0c             	sub    $0xc,%esp
80103997:	ff 76 68             	pushl  0x68(%esi)
8010399a:	e8 4e dc ff ff       	call   801015ed <iput>
    end_op();
8010399f:	e8 84 ee ff ff       	call   80102828 <end_op>
    curproc->cwd = 0;
801039a4:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
    acquire(&ptable.lock);
801039ab:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801039b2:	e8 be 06 00 00       	call   80104075 <acquire>
    wakeup1(curproc->parent);
801039b7:	8b 46 14             	mov    0x14(%esi),%eax
801039ba:	e8 c7 f8 ff ff       	call   80103286 <wakeup1>
801039bf:	83 c4 10             	add    $0x10,%esp
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801039c2:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
801039c7:	eb 0e                	jmp    801039d7 <exit+0x94>
801039c9:	81 c3 94 00 00 00    	add    $0x94,%ebx
801039cf:	81 fb 54 52 11 80    	cmp    $0x80115254,%ebx
801039d5:	73 1a                	jae    801039f1 <exit+0xae>
        if (p->parent == curproc) {
801039d7:	39 73 14             	cmp    %esi,0x14(%ebx)
801039da:	75 ed                	jne    801039c9 <exit+0x86>
            p->parent = initproc;
801039dc:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
801039e1:	89 43 14             	mov    %eax,0x14(%ebx)
            if (p->state == ZOMBIE)
801039e4:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801039e8:	75 df                	jne    801039c9 <exit+0x86>
                wakeup1(initproc);
801039ea:	e8 97 f8 ff ff       	call   80103286 <wakeup1>
801039ef:	eb d8                	jmp    801039c9 <exit+0x86>
    curproc->state = ZOMBIE;
801039f1:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
    sched();
801039f8:	e8 37 fd ff ff       	call   80103734 <sched>
    panic("zombie exit");
801039fd:	83 ec 0c             	sub    $0xc,%esp
80103a00:	68 dd 6e 10 80       	push   $0x80106edd
80103a05:	e8 3a c9 ff ff       	call   80100344 <panic>

80103a0a <yield>:
{
80103a0a:	55                   	push   %ebp
80103a0b:	89 e5                	mov    %esp,%ebp
80103a0d:	53                   	push   %ebx
80103a0e:	83 ec 04             	sub    $0x4,%esp
    struct proc *p = myproc();
80103a11:	e8 b5 fa ff ff       	call   801034cb <myproc>
80103a16:	89 c3                	mov    %eax,%ebx
    acquire(&ptable.lock);
80103a18:	83 ec 0c             	sub    $0xc,%esp
80103a1b:	68 20 2d 11 80       	push   $0x80112d20
80103a20:	e8 50 06 00 00       	call   80104075 <acquire>
    p->state = RUNNABLE;
80103a25:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
    if (p->priority < MAX_PRIORITY_LEVEL-1)
80103a2c:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
80103a32:	83 c4 10             	add    $0x10,%esp
80103a35:	83 f8 01             	cmp    $0x1,%eax
80103a38:	76 2a                	jbe    80103a64 <yield+0x5a>
    p->proc_tick = 0;
80103a3a:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80103a41:	00 00 00 
    if (!p->in_queue) queue_push(p->priority, p);
80103a44:	83 7b 7c 00          	cmpl   $0x0,0x7c(%ebx)
80103a48:	74 25                	je     80103a6f <yield+0x65>
    sched();
80103a4a:	e8 e5 fc ff ff       	call   80103734 <sched>
    release(&ptable.lock);
80103a4f:	83 ec 0c             	sub    $0xc,%esp
80103a52:	68 20 2d 11 80       	push   $0x80112d20
80103a57:	e8 80 06 00 00       	call   801040dc <release>
}
80103a5c:	83 c4 10             	add    $0x10,%esp
80103a5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a62:	c9                   	leave  
80103a63:	c3                   	ret    
        p->priority++;
80103a64:	83 c0 01             	add    $0x1,%eax
80103a67:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
80103a6d:	eb cb                	jmp    80103a3a <yield+0x30>
    if (!p->in_queue) queue_push(p->priority, p);
80103a6f:	83 ec 08             	sub    $0x8,%esp
80103a72:	53                   	push   %ebx
80103a73:	ff b3 88 00 00 00    	pushl  0x88(%ebx)
80103a79:	e8 89 f3 ff ff       	call   80102e07 <queue_push>
80103a7e:	83 c4 10             	add    $0x10,%esp
80103a81:	eb c7                	jmp    80103a4a <yield+0x40>

80103a83 <sleep>:
{
80103a83:	55                   	push   %ebp
80103a84:	89 e5                	mov    %esp,%ebp
80103a86:	56                   	push   %esi
80103a87:	53                   	push   %ebx
80103a88:	8b 75 0c             	mov    0xc(%ebp),%esi
    struct proc *p = myproc();
80103a8b:	e8 3b fa ff ff       	call   801034cb <myproc>
    if (p == 0)
80103a90:	85 c0                	test   %eax,%eax
80103a92:	74 7f                	je     80103b13 <sleep+0x90>
80103a94:	89 c3                	mov    %eax,%ebx
    if (lk == 0)
80103a96:	85 f6                	test   %esi,%esi
80103a98:	0f 84 82 00 00 00    	je     80103b20 <sleep+0x9d>
    if (lk != &ptable.lock) {  // DOC: sleeplock0
80103a9e:	81 fe 20 2d 11 80    	cmp    $0x80112d20,%esi
80103aa4:	0f 84 91 00 00 00    	je     80103b3b <sleep+0xb8>
        acquire(&ptable.lock); // DOC: sleeplock1
80103aaa:	83 ec 0c             	sub    $0xc,%esp
80103aad:	68 20 2d 11 80       	push   $0x80112d20
80103ab2:	e8 be 05 00 00       	call   80104075 <acquire>
        release(lk);
80103ab7:	89 34 24             	mov    %esi,(%esp)
80103aba:	e8 1d 06 00 00       	call   801040dc <release>
    p->chan = chan;
80103abf:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac2:	89 43 20             	mov    %eax,0x20(%ebx)
    p->state = SLEEPING;
80103ac5:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
    if (p->in_queue) {
80103acc:	83 c4 10             	add    $0x10,%esp
80103acf:	83 7b 7c 00          	cmpl   $0x0,0x7c(%ebx)
80103ad3:	74 58                	je     80103b2d <sleep+0xaa>
        queue_remove(p);
80103ad5:	83 ec 0c             	sub    $0xc,%esp
80103ad8:	53                   	push   %ebx
80103ad9:	e8 e1 f3 ff ff       	call   80102ebf <queue_remove>
        p->in_queue = 0;
80103ade:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
    sched();
80103ae5:	e8 4a fc ff ff       	call   80103734 <sched>
    p->chan = 0;
80103aea:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
80103af1:	83 c4 10             	add    $0x10,%esp
        release(&ptable.lock);
80103af4:	83 ec 0c             	sub    $0xc,%esp
80103af7:	68 20 2d 11 80       	push   $0x80112d20
80103afc:	e8 db 05 00 00       	call   801040dc <release>
        acquire(lk);
80103b01:	89 34 24             	mov    %esi,(%esp)
80103b04:	e8 6c 05 00 00       	call   80104075 <acquire>
80103b09:	83 c4 10             	add    $0x10,%esp
}
80103b0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b0f:	5b                   	pop    %ebx
80103b10:	5e                   	pop    %esi
80103b11:	5d                   	pop    %ebp
80103b12:	c3                   	ret    
        panic("sleep");
80103b13:	83 ec 0c             	sub    $0xc,%esp
80103b16:	68 e9 6e 10 80       	push   $0x80106ee9
80103b1b:	e8 24 c8 ff ff       	call   80100344 <panic>
        panic("sleep without lk");
80103b20:	83 ec 0c             	sub    $0xc,%esp
80103b23:	68 ef 6e 10 80       	push   $0x80106eef
80103b28:	e8 17 c8 ff ff       	call   80100344 <panic>
    sched();
80103b2d:	e8 02 fc ff ff       	call   80103734 <sched>
    p->chan = 0;
80103b32:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
80103b39:	eb b9                	jmp    80103af4 <sleep+0x71>
    p->chan = chan;
80103b3b:	8b 45 08             	mov    0x8(%ebp),%eax
80103b3e:	89 43 20             	mov    %eax,0x20(%ebx)
    p->state = SLEEPING;
80103b41:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
    if (p->in_queue) {
80103b48:	83 7b 7c 00          	cmpl   $0x0,0x7c(%ebx)
80103b4c:	75 0e                	jne    80103b5c <sleep+0xd9>
    sched();
80103b4e:	e8 e1 fb ff ff       	call   80103734 <sched>
    p->chan = 0;
80103b53:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
80103b5a:	eb b0                	jmp    80103b0c <sleep+0x89>
        queue_remove(p);
80103b5c:	83 ec 0c             	sub    $0xc,%esp
80103b5f:	53                   	push   %ebx
80103b60:	e8 5a f3 ff ff       	call   80102ebf <queue_remove>
        p->in_queue = 0;
80103b65:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
    sched();
80103b6c:	e8 c3 fb ff ff       	call   80103734 <sched>
    p->chan = 0;
80103b71:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
80103b78:	83 c4 10             	add    $0x10,%esp
80103b7b:	eb 8f                	jmp    80103b0c <sleep+0x89>

80103b7d <wait>:
{
80103b7d:	55                   	push   %ebp
80103b7e:	89 e5                	mov    %esp,%ebp
80103b80:	57                   	push   %edi
80103b81:	56                   	push   %esi
80103b82:	53                   	push   %ebx
80103b83:	83 ec 0c             	sub    $0xc,%esp
    struct proc *curproc = myproc();
80103b86:	e8 40 f9 ff ff       	call   801034cb <myproc>
80103b8b:	89 c6                	mov    %eax,%esi
    acquire(&ptable.lock);
80103b8d:	83 ec 0c             	sub    $0xc,%esp
80103b90:	68 20 2d 11 80       	push   $0x80112d20
80103b95:	e8 db 04 00 00       	call   80104075 <acquire>
80103b9a:	83 c4 10             	add    $0x10,%esp
            havekids = 1;
80103b9d:	bf 01 00 00 00       	mov    $0x1,%edi
        havekids = 0;
80103ba2:	b8 00 00 00 00       	mov    $0x0,%eax
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103ba7:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103bac:	eb 67                	jmp    80103c15 <wait+0x98>
                pid = p->pid;
80103bae:	8b 73 10             	mov    0x10(%ebx),%esi
                kfree(p->kstack);
80103bb1:	83 ec 0c             	sub    $0xc,%esp
80103bb4:	ff 73 08             	pushl  0x8(%ebx)
80103bb7:	e8 7d e4 ff ff       	call   80102039 <kfree>
                p->kstack = 0;
80103bbc:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
                freevm(p->pgdir);
80103bc3:	83 c4 04             	add    $0x4,%esp
80103bc6:	ff 73 04             	pushl  0x4(%ebx)
80103bc9:	e8 6d 2a 00 00       	call   8010663b <freevm>
                p->pid = 0;
80103bce:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
                p->parent = 0;
80103bd5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
                p->name[0] = 0;
80103bdc:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
                p->killed = 0;
80103be0:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
                p->state = UNUSED;
80103be7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
                release(&ptable.lock);
80103bee:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103bf5:	e8 e2 04 00 00       	call   801040dc <release>
                return pid;
80103bfa:	83 c4 10             	add    $0x10,%esp
}
80103bfd:	89 f0                	mov    %esi,%eax
80103bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103c02:	5b                   	pop    %ebx
80103c03:	5e                   	pop    %esi
80103c04:	5f                   	pop    %edi
80103c05:	5d                   	pop    %ebp
80103c06:	c3                   	ret    
        for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103c07:	81 c3 94 00 00 00    	add    $0x94,%ebx
80103c0d:	81 fb 54 52 11 80    	cmp    $0x80115254,%ebx
80103c13:	73 0f                	jae    80103c24 <wait+0xa7>
            if (p->parent != curproc)
80103c15:	39 73 14             	cmp    %esi,0x14(%ebx)
80103c18:	75 ed                	jne    80103c07 <wait+0x8a>
            if (p->state == ZOMBIE) {
80103c1a:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103c1e:	74 8e                	je     80103bae <wait+0x31>
            havekids = 1;
80103c20:	89 f8                	mov    %edi,%eax
80103c22:	eb e3                	jmp    80103c07 <wait+0x8a>
        if (!havekids || curproc->killed) {
80103c24:	85 c0                	test   %eax,%eax
80103c26:	74 06                	je     80103c2e <wait+0xb1>
80103c28:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103c2c:	74 17                	je     80103c45 <wait+0xc8>
            release(&ptable.lock);
80103c2e:	83 ec 0c             	sub    $0xc,%esp
80103c31:	68 20 2d 11 80       	push   $0x80112d20
80103c36:	e8 a1 04 00 00       	call   801040dc <release>
            return -1;
80103c3b:	83 c4 10             	add    $0x10,%esp
80103c3e:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103c43:	eb b8                	jmp    80103bfd <wait+0x80>
        sleep(curproc, &ptable.lock); // DOC: wait-sleep
80103c45:	83 ec 08             	sub    $0x8,%esp
80103c48:	68 20 2d 11 80       	push   $0x80112d20
80103c4d:	56                   	push   %esi
80103c4e:	e8 30 fe ff ff       	call   80103a83 <sleep>
        havekids = 0;
80103c53:	83 c4 10             	add    $0x10,%esp
80103c56:	e9 47 ff ff ff       	jmp    80103ba2 <wait+0x25>

80103c5b <wakeup>:

// Wake up all processes sleeping on chan.
void wakeup(void *chan)
{
80103c5b:	55                   	push   %ebp
80103c5c:	89 e5                	mov    %esp,%ebp
80103c5e:	83 ec 14             	sub    $0x14,%esp
    // cprintf("[DEBUG] wakeup() chan: %p\n", chan);
    acquire(&ptable.lock);
80103c61:	68 20 2d 11 80       	push   $0x80112d20
80103c66:	e8 0a 04 00 00       	call   80104075 <acquire>
    wakeup1(chan);
80103c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c6e:	e8 13 f6 ff ff       	call   80103286 <wakeup1>
    release(&ptable.lock);
80103c73:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103c7a:	e8 5d 04 00 00       	call   801040dc <release>
}
80103c7f:	83 c4 10             	add    $0x10,%esp
80103c82:	c9                   	leave  
80103c83:	c3                   	ret    

80103c84 <kill>:

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int kill(int pid)
{
80103c84:	55                   	push   %ebp
80103c85:	89 e5                	mov    %esp,%ebp
80103c87:	53                   	push   %ebx
80103c88:	83 ec 10             	sub    $0x10,%esp
80103c8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
    struct proc *p;

    acquire(&ptable.lock);
80103c8e:	68 20 2d 11 80       	push   $0x80112d20
80103c93:	e8 dd 03 00 00       	call   80104075 <acquire>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
        if (p->pid == pid) {
80103c98:	83 c4 10             	add    $0x10,%esp
80103c9b:	3b 1d 64 2d 11 80    	cmp    0x80112d64,%ebx
80103ca1:	74 2d                	je     80103cd0 <kill+0x4c>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103ca3:	b8 e8 2d 11 80       	mov    $0x80112de8,%eax
        if (p->pid == pid) {
80103ca8:	39 58 10             	cmp    %ebx,0x10(%eax)
80103cab:	74 28                	je     80103cd5 <kill+0x51>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103cad:	05 94 00 00 00       	add    $0x94,%eax
80103cb2:	3d 54 52 11 80       	cmp    $0x80115254,%eax
80103cb7:	72 ef                	jb     80103ca8 <kill+0x24>
            }
            release(&ptable.lock);
            return 0;
        }
    }
    release(&ptable.lock);
80103cb9:	83 ec 0c             	sub    $0xc,%esp
80103cbc:	68 20 2d 11 80       	push   $0x80112d20
80103cc1:	e8 16 04 00 00       	call   801040dc <release>
    return -1;
80103cc6:	83 c4 10             	add    $0x10,%esp
80103cc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cce:	eb 27                	jmp    80103cf7 <kill+0x73>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103cd0:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
            p->killed = 1;
80103cd5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
            if (p->state == SLEEPING) {
80103cdc:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103ce0:	74 1a                	je     80103cfc <kill+0x78>
            release(&ptable.lock);
80103ce2:	83 ec 0c             	sub    $0xc,%esp
80103ce5:	68 20 2d 11 80       	push   $0x80112d20
80103cea:	e8 ed 03 00 00       	call   801040dc <release>
            return 0;
80103cef:	83 c4 10             	add    $0x10,%esp
80103cf2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103cf7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103cfa:	c9                   	leave  
80103cfb:	c3                   	ret    
                p->state = RUNNABLE;
80103cfc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
                if (!p->in_queue)
80103d03:	83 78 7c 00          	cmpl   $0x0,0x7c(%eax)
80103d07:	75 d9                	jne    80103ce2 <kill+0x5e>
                    queue_push(p->priority, p);
80103d09:	83 ec 08             	sub    $0x8,%esp
80103d0c:	50                   	push   %eax
80103d0d:	ff b0 88 00 00 00    	pushl  0x88(%eax)
80103d13:	e8 ef f0 ff ff       	call   80102e07 <queue_push>
80103d18:	83 c4 10             	add    $0x10,%esp
80103d1b:	eb c5                	jmp    80103ce2 <kill+0x5e>

80103d1d <procdump>:
// PAGEBREAK: 36
//  Print a process listing to console.  For debugging.
//  Runs when user types ^P on console.
//  No lock to avoid wedging a stuck machine further.
void procdump(void)
{
80103d1d:	55                   	push   %ebp
80103d1e:	89 e5                	mov    %esp,%ebp
80103d20:	57                   	push   %edi
80103d21:	56                   	push   %esi
80103d22:	53                   	push   %ebx
80103d23:	83 ec 3c             	sub    $0x3c,%esp
    int i;
    struct proc *p;
    char *state;
    uint pc[10];

    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103d26:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103d2b:	8d 7d e8             	lea    -0x18(%ebp),%edi
80103d2e:	eb 39                	jmp    80103d69 <procdump+0x4c>
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
            state = states[p->state];
        else
            state = "???";
        cprintf("%d %s %s", p->pid, state, p->name);
80103d30:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103d33:	52                   	push   %edx
80103d34:	50                   	push   %eax
80103d35:	ff 73 10             	pushl  0x10(%ebx)
80103d38:	68 04 6f 10 80       	push   $0x80106f04
80103d3d:	e8 9f c8 ff ff       	call   801005e1 <cprintf>
        if (p->state == SLEEPING) {
80103d42:	83 c4 10             	add    $0x10,%esp
80103d45:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103d49:	74 42                	je     80103d8d <procdump+0x70>
            getcallerpcs((uint *)p->context->ebp + 2, pc);
            for (i = 0; i < 10 && pc[i] != 0; i++)
                cprintf(" %p", pc[i]);
        }
        cprintf("\n");
80103d4b:	83 ec 0c             	sub    $0xc,%esp
80103d4e:	68 7b 72 10 80       	push   $0x8010727b
80103d53:	e8 89 c8 ff ff       	call   801005e1 <cprintf>
80103d58:	83 c4 10             	add    $0x10,%esp
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103d5b:	81 c3 94 00 00 00    	add    $0x94,%ebx
80103d61:	81 fb 54 52 11 80    	cmp    $0x80115254,%ebx
80103d67:	73 7b                	jae    80103de4 <procdump+0xc7>
        if (p->state == UNUSED)
80103d69:	8b 53 0c             	mov    0xc(%ebx),%edx
80103d6c:	85 d2                	test   %edx,%edx
80103d6e:	74 eb                	je     80103d5b <procdump+0x3e>
            state = "???";
80103d70:	b8 00 6f 10 80       	mov    $0x80106f00,%eax
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103d75:	83 fa 05             	cmp    $0x5,%edx
80103d78:	77 b6                	ja     80103d30 <procdump+0x13>
80103d7a:	8b 04 95 60 6f 10 80 	mov    -0x7fef90a0(,%edx,4),%eax
80103d81:	85 c0                	test   %eax,%eax
            state = "???";
80103d83:	ba 00 6f 10 80       	mov    $0x80106f00,%edx
80103d88:	0f 44 c2             	cmove  %edx,%eax
80103d8b:	eb a3                	jmp    80103d30 <procdump+0x13>
            getcallerpcs((uint *)p->context->ebp + 2, pc);
80103d8d:	83 ec 08             	sub    $0x8,%esp
80103d90:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103d93:	50                   	push   %eax
80103d94:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103d97:	8b 40 0c             	mov    0xc(%eax),%eax
80103d9a:	83 c0 08             	add    $0x8,%eax
80103d9d:	50                   	push   %eax
80103d9e:	e8 a5 01 00 00       	call   80103f48 <getcallerpcs>
            for (i = 0; i < 10 && pc[i] != 0; i++)
80103da3:	8b 45 c0             	mov    -0x40(%ebp),%eax
80103da6:	83 c4 10             	add    $0x10,%esp
80103da9:	85 c0                	test   %eax,%eax
80103dab:	74 9e                	je     80103d4b <procdump+0x2e>
                cprintf(" %p", pc[i]);
80103dad:	83 ec 08             	sub    $0x8,%esp
80103db0:	50                   	push   %eax
80103db1:	68 41 69 10 80       	push   $0x80106941
80103db6:	e8 26 c8 ff ff       	call   801005e1 <cprintf>
80103dbb:	8d 75 c4             	lea    -0x3c(%ebp),%esi
80103dbe:	83 c4 10             	add    $0x10,%esp
            for (i = 0; i < 10 && pc[i] != 0; i++)
80103dc1:	8b 06                	mov    (%esi),%eax
80103dc3:	85 c0                	test   %eax,%eax
80103dc5:	74 84                	je     80103d4b <procdump+0x2e>
                cprintf(" %p", pc[i]);
80103dc7:	83 ec 08             	sub    $0x8,%esp
80103dca:	50                   	push   %eax
80103dcb:	68 41 69 10 80       	push   $0x80106941
80103dd0:	e8 0c c8 ff ff       	call   801005e1 <cprintf>
80103dd5:	83 c6 04             	add    $0x4,%esi
            for (i = 0; i < 10 && pc[i] != 0; i++)
80103dd8:	83 c4 10             	add    $0x10,%esp
80103ddb:	39 f7                	cmp    %esi,%edi
80103ddd:	75 e2                	jne    80103dc1 <procdump+0xa4>
80103ddf:	e9 67 ff ff ff       	jmp    80103d4b <procdump+0x2e>
    }
}
80103de4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103de7:	5b                   	pop    %ebx
80103de8:	5e                   	pop    %esi
80103de9:	5f                   	pop    %edi
80103dea:	5d                   	pop    %ebp
80103deb:	c3                   	ret    

80103dec <getlevel>:

// MLFQ debugging function provided
// Just debugging for Process's level in MLFQ test case
int getlevel(void)
{
80103dec:	55                   	push   %ebp
80103ded:	89 e5                	mov    %esp,%ebp
    struct proc *p;
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
        if (p->state == RUNNING)
80103def:	83 3d 60 2d 11 80 04 	cmpl   $0x4,0x80112d60
80103df6:	74 1e                	je     80103e16 <getlevel+0x2a>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103df8:	b8 e8 2d 11 80       	mov    $0x80112de8,%eax
        if (p->state == RUNNING)
80103dfd:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80103e01:	74 18                	je     80103e1b <getlevel+0x2f>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103e03:	05 94 00 00 00       	add    $0x94,%eax
80103e08:	3d 54 52 11 80       	cmp    $0x80115254,%eax
80103e0d:	72 ee                	jb     80103dfd <getlevel+0x11>
            return p->priority;
    }

    return -1;
80103e0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e14:	eb 0b                	jmp    80103e21 <getlevel+0x35>
    for (p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
80103e16:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
            return p->priority;
80103e1b:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
}
80103e21:	5d                   	pop    %ebp
80103e22:	c3                   	ret    

80103e23 <initsleeplock>:
#include "proc.h"
#include "spinlock.h"
#include "sleeplock.h"

void initsleeplock(struct sleeplock *lk, char *name)
{
80103e23:	55                   	push   %ebp
80103e24:	89 e5                	mov    %esp,%ebp
80103e26:	53                   	push   %ebx
80103e27:	83 ec 0c             	sub    $0xc,%esp
80103e2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
    initlock(&lk->lk, "sleep lock");
80103e2d:	68 78 6f 10 80       	push   $0x80106f78
80103e32:	8d 43 04             	lea    0x4(%ebx),%eax
80103e35:	50                   	push   %eax
80103e36:	e8 f2 00 00 00       	call   80103f2d <initlock>
    lk->name = name;
80103e3b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e3e:	89 43 38             	mov    %eax,0x38(%ebx)
    lk->locked = 0;
80103e41:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    lk->pid = 0;
80103e47:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103e4e:	83 c4 10             	add    $0x10,%esp
80103e51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e54:	c9                   	leave  
80103e55:	c3                   	ret    

80103e56 <acquiresleep>:

void acquiresleep(struct sleeplock *lk)
{
80103e56:	55                   	push   %ebp
80103e57:	89 e5                	mov    %esp,%ebp
80103e59:	56                   	push   %esi
80103e5a:	53                   	push   %ebx
80103e5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
    acquire(&lk->lk);
80103e5e:	8d 73 04             	lea    0x4(%ebx),%esi
80103e61:	83 ec 0c             	sub    $0xc,%esp
80103e64:	56                   	push   %esi
80103e65:	e8 0b 02 00 00       	call   80104075 <acquire>
    while (lk->locked) {
80103e6a:	83 c4 10             	add    $0x10,%esp
80103e6d:	83 3b 00             	cmpl   $0x0,(%ebx)
80103e70:	74 12                	je     80103e84 <acquiresleep+0x2e>
        sleep(lk, &lk->lk);
80103e72:	83 ec 08             	sub    $0x8,%esp
80103e75:	56                   	push   %esi
80103e76:	53                   	push   %ebx
80103e77:	e8 07 fc ff ff       	call   80103a83 <sleep>
    while (lk->locked) {
80103e7c:	83 c4 10             	add    $0x10,%esp
80103e7f:	83 3b 00             	cmpl   $0x0,(%ebx)
80103e82:	75 ee                	jne    80103e72 <acquiresleep+0x1c>
    }
    lk->locked = 1;
80103e84:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
    lk->pid = myproc()->pid;
80103e8a:	e8 3c f6 ff ff       	call   801034cb <myproc>
80103e8f:	8b 40 10             	mov    0x10(%eax),%eax
80103e92:	89 43 3c             	mov    %eax,0x3c(%ebx)
    release(&lk->lk);
80103e95:	83 ec 0c             	sub    $0xc,%esp
80103e98:	56                   	push   %esi
80103e99:	e8 3e 02 00 00       	call   801040dc <release>
}
80103e9e:	83 c4 10             	add    $0x10,%esp
80103ea1:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ea4:	5b                   	pop    %ebx
80103ea5:	5e                   	pop    %esi
80103ea6:	5d                   	pop    %ebp
80103ea7:	c3                   	ret    

80103ea8 <releasesleep>:

void releasesleep(struct sleeplock *lk)
{
80103ea8:	55                   	push   %ebp
80103ea9:	89 e5                	mov    %esp,%ebp
80103eab:	56                   	push   %esi
80103eac:	53                   	push   %ebx
80103ead:	8b 5d 08             	mov    0x8(%ebp),%ebx
    acquire(&lk->lk);
80103eb0:	8d 73 04             	lea    0x4(%ebx),%esi
80103eb3:	83 ec 0c             	sub    $0xc,%esp
80103eb6:	56                   	push   %esi
80103eb7:	e8 b9 01 00 00       	call   80104075 <acquire>
    lk->locked = 0;
80103ebc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    lk->pid = 0;
80103ec2:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
    wakeup(lk);
80103ec9:	89 1c 24             	mov    %ebx,(%esp)
80103ecc:	e8 8a fd ff ff       	call   80103c5b <wakeup>
    release(&lk->lk);
80103ed1:	89 34 24             	mov    %esi,(%esp)
80103ed4:	e8 03 02 00 00       	call   801040dc <release>
}
80103ed9:	83 c4 10             	add    $0x10,%esp
80103edc:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103edf:	5b                   	pop    %ebx
80103ee0:	5e                   	pop    %esi
80103ee1:	5d                   	pop    %ebp
80103ee2:	c3                   	ret    

80103ee3 <holdingsleep>:

int holdingsleep(struct sleeplock *lk)
{
80103ee3:	55                   	push   %ebp
80103ee4:	89 e5                	mov    %esp,%ebp
80103ee6:	57                   	push   %edi
80103ee7:	56                   	push   %esi
80103ee8:	53                   	push   %ebx
80103ee9:	83 ec 18             	sub    $0x18,%esp
80103eec:	8b 5d 08             	mov    0x8(%ebp),%ebx
    int r;

    acquire(&lk->lk);
80103eef:	8d 73 04             	lea    0x4(%ebx),%esi
80103ef2:	56                   	push   %esi
80103ef3:	e8 7d 01 00 00       	call   80104075 <acquire>
    r = lk->locked && (lk->pid == myproc()->pid);
80103ef8:	83 c4 10             	add    $0x10,%esp
80103efb:	bf 00 00 00 00       	mov    $0x0,%edi
80103f00:	83 3b 00             	cmpl   $0x0,(%ebx)
80103f03:	75 13                	jne    80103f18 <holdingsleep+0x35>
    release(&lk->lk);
80103f05:	83 ec 0c             	sub    $0xc,%esp
80103f08:	56                   	push   %esi
80103f09:	e8 ce 01 00 00       	call   801040dc <release>
    return r;
}
80103f0e:	89 f8                	mov    %edi,%eax
80103f10:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f13:	5b                   	pop    %ebx
80103f14:	5e                   	pop    %esi
80103f15:	5f                   	pop    %edi
80103f16:	5d                   	pop    %ebp
80103f17:	c3                   	ret    
    r = lk->locked && (lk->pid == myproc()->pid);
80103f18:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103f1b:	e8 ab f5 ff ff       	call   801034cb <myproc>
80103f20:	39 58 10             	cmp    %ebx,0x10(%eax)
80103f23:	0f 94 c0             	sete   %al
80103f26:	0f b6 c0             	movzbl %al,%eax
80103f29:	89 c7                	mov    %eax,%edi
80103f2b:	eb d8                	jmp    80103f05 <holdingsleep+0x22>

80103f2d <initlock>:
#include "mmu.h"
#include "proc.h"
#include "spinlock.h"

void initlock(struct spinlock *lk, char *name)
{
80103f2d:	55                   	push   %ebp
80103f2e:	89 e5                	mov    %esp,%ebp
80103f30:	8b 45 08             	mov    0x8(%ebp),%eax
    lk->name = name;
80103f33:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f36:	89 50 04             	mov    %edx,0x4(%eax)
    lk->locked = 0;
80103f39:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    lk->cpu = 0;
80103f3f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103f46:	5d                   	pop    %ebp
80103f47:	c3                   	ret    

80103f48 <getcallerpcs>:
    popcli();
}

// Record the current call stack in pcs[] by following the %ebp chain.
void getcallerpcs(void *v, uint pcs[])
{
80103f48:	55                   	push   %ebp
80103f49:	89 e5                	mov    %esp,%ebp
80103f4b:	53                   	push   %ebx
80103f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    uint *ebp;
    int i;

    ebp = (uint *)v - 2;
    for (i = 0; i < 10; i++) {
        if (ebp == 0 || ebp < (uint *)KERNBASE || ebp == (uint *)0xffffffff)
80103f52:	8d 90 f8 ff ff 7f    	lea    0x7ffffff8(%eax),%edx
80103f58:	81 fa fe ff ff 7f    	cmp    $0x7ffffffe,%edx
80103f5e:	77 2d                	ja     80103f8d <getcallerpcs+0x45>
            break;
        pcs[i] = ebp[1];      // saved %eip
80103f60:	8b 50 fc             	mov    -0x4(%eax),%edx
80103f63:	89 11                	mov    %edx,(%ecx)
        ebp = (uint *)ebp[0]; // saved %ebp
80103f65:	8b 50 f8             	mov    -0x8(%eax),%edx
    for (i = 0; i < 10; i++) {
80103f68:	b8 01 00 00 00       	mov    $0x1,%eax
        if (ebp == 0 || ebp < (uint *)KERNBASE || ebp == (uint *)0xffffffff)
80103f6d:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103f73:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103f79:	77 17                	ja     80103f92 <getcallerpcs+0x4a>
        pcs[i] = ebp[1];      // saved %eip
80103f7b:	8b 5a 04             	mov    0x4(%edx),%ebx
80103f7e:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
        ebp = (uint *)ebp[0]; // saved %ebp
80103f81:	8b 12                	mov    (%edx),%edx
    for (i = 0; i < 10; i++) {
80103f83:	83 c0 01             	add    $0x1,%eax
80103f86:	83 f8 0a             	cmp    $0xa,%eax
80103f89:	75 e2                	jne    80103f6d <getcallerpcs+0x25>
80103f8b:	eb 14                	jmp    80103fa1 <getcallerpcs+0x59>
80103f8d:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    for (; i < 10; i++)
        pcs[i] = 0;
80103f92:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
    for (; i < 10; i++)
80103f99:	83 c0 01             	add    $0x1,%eax
80103f9c:	83 f8 09             	cmp    $0x9,%eax
80103f9f:	7e f1                	jle    80103f92 <getcallerpcs+0x4a>
}
80103fa1:	5b                   	pop    %ebx
80103fa2:	5d                   	pop    %ebp
80103fa3:	c3                   	ret    

80103fa4 <pushcli>:
// Pushcli/popcli are like cli/sti except that they are matched:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void pushcli(void)
{
80103fa4:	55                   	push   %ebp
80103fa5:	89 e5                	mov    %esp,%ebp
80103fa7:	53                   	push   %ebx
80103fa8:	83 ec 04             	sub    $0x4,%esp
80103fab:	9c                   	pushf  
80103fac:	5b                   	pop    %ebx
    asm volatile("cli");
80103fad:	fa                   	cli    
    int eflags;

    eflags = readeflags();
    cli();
    if (mycpu()->ncli == 0)
80103fae:	e8 86 f4 ff ff       	call   80103439 <mycpu>
80103fb3:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103fba:	74 12                	je     80103fce <pushcli+0x2a>
        mycpu()->intena = eflags & FL_IF;
    mycpu()->ncli += 1;
80103fbc:	e8 78 f4 ff ff       	call   80103439 <mycpu>
80103fc1:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103fc8:	83 c4 04             	add    $0x4,%esp
80103fcb:	5b                   	pop    %ebx
80103fcc:	5d                   	pop    %ebp
80103fcd:	c3                   	ret    
        mycpu()->intena = eflags & FL_IF;
80103fce:	e8 66 f4 ff ff       	call   80103439 <mycpu>
80103fd3:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103fd9:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103fdf:	eb db                	jmp    80103fbc <pushcli+0x18>

80103fe1 <popcli>:

void popcli(void)
{
80103fe1:	55                   	push   %ebp
80103fe2:	89 e5                	mov    %esp,%ebp
80103fe4:	83 ec 08             	sub    $0x8,%esp
    asm volatile("pushfl; popl %0" : "=r"(eflags));
80103fe7:	9c                   	pushf  
80103fe8:	58                   	pop    %eax
    if (readeflags() & FL_IF)
80103fe9:	f6 c4 02             	test   $0x2,%ah
80103fec:	75 28                	jne    80104016 <popcli+0x35>
        panic("popcli - interruptible");
    if (--mycpu()->ncli < 0)
80103fee:	e8 46 f4 ff ff       	call   80103439 <mycpu>
80103ff3:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103ff9:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103ffc:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104002:	85 d2                	test   %edx,%edx
80104004:	78 1d                	js     80104023 <popcli+0x42>
        panic("popcli");
    if (mycpu()->ncli == 0 && mycpu()->intena)
80104006:	e8 2e f4 ff ff       	call   80103439 <mycpu>
8010400b:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80104012:	74 1c                	je     80104030 <popcli+0x4f>
        sti();
}
80104014:	c9                   	leave  
80104015:	c3                   	ret    
        panic("popcli - interruptible");
80104016:	83 ec 0c             	sub    $0xc,%esp
80104019:	68 83 6f 10 80       	push   $0x80106f83
8010401e:	e8 21 c3 ff ff       	call   80100344 <panic>
        panic("popcli");
80104023:	83 ec 0c             	sub    $0xc,%esp
80104026:	68 9a 6f 10 80       	push   $0x80106f9a
8010402b:	e8 14 c3 ff ff       	call   80100344 <panic>
    if (mycpu()->ncli == 0 && mycpu()->intena)
80104030:	e8 04 f4 ff ff       	call   80103439 <mycpu>
80104035:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
8010403c:	74 d6                	je     80104014 <popcli+0x33>
    asm volatile("sti");
8010403e:	fb                   	sti    
}
8010403f:	eb d3                	jmp    80104014 <popcli+0x33>

80104041 <holding>:
{
80104041:	55                   	push   %ebp
80104042:	89 e5                	mov    %esp,%ebp
80104044:	56                   	push   %esi
80104045:	53                   	push   %ebx
80104046:	8b 75 08             	mov    0x8(%ebp),%esi
    pushcli();
80104049:	e8 56 ff ff ff       	call   80103fa4 <pushcli>
    r = lock->locked && lock->cpu == mycpu();
8010404e:	bb 00 00 00 00       	mov    $0x0,%ebx
80104053:	83 3e 00             	cmpl   $0x0,(%esi)
80104056:	75 0b                	jne    80104063 <holding+0x22>
    popcli();
80104058:	e8 84 ff ff ff       	call   80103fe1 <popcli>
}
8010405d:	89 d8                	mov    %ebx,%eax
8010405f:	5b                   	pop    %ebx
80104060:	5e                   	pop    %esi
80104061:	5d                   	pop    %ebp
80104062:	c3                   	ret    
    r = lock->locked && lock->cpu == mycpu();
80104063:	8b 5e 08             	mov    0x8(%esi),%ebx
80104066:	e8 ce f3 ff ff       	call   80103439 <mycpu>
8010406b:	39 c3                	cmp    %eax,%ebx
8010406d:	0f 94 c3             	sete   %bl
80104070:	0f b6 db             	movzbl %bl,%ebx
80104073:	eb e3                	jmp    80104058 <holding+0x17>

80104075 <acquire>:
{
80104075:	55                   	push   %ebp
80104076:	89 e5                	mov    %esp,%ebp
80104078:	53                   	push   %ebx
80104079:	83 ec 04             	sub    $0x4,%esp
    pushcli(); // disable interrupts to avoid deadlock.
8010407c:	e8 23 ff ff ff       	call   80103fa4 <pushcli>
    if (holding(lk))
80104081:	83 ec 0c             	sub    $0xc,%esp
80104084:	ff 75 08             	pushl  0x8(%ebp)
80104087:	e8 b5 ff ff ff       	call   80104041 <holding>
8010408c:	83 c4 10             	add    $0x10,%esp
8010408f:	85 c0                	test   %eax,%eax
80104091:	75 3c                	jne    801040cf <acquire+0x5a>
    asm volatile("lock; xchgl %0, %1"
80104093:	b9 01 00 00 00       	mov    $0x1,%ecx
    while (xchg(&lk->locked, 1) != 0)
80104098:	8b 55 08             	mov    0x8(%ebp),%edx
8010409b:	89 c8                	mov    %ecx,%eax
8010409d:	f0 87 02             	lock xchg %eax,(%edx)
801040a0:	85 c0                	test   %eax,%eax
801040a2:	75 f4                	jne    80104098 <acquire+0x23>
    __sync_synchronize();
801040a4:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
    lk->cpu = mycpu();
801040a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
801040ac:	e8 88 f3 ff ff       	call   80103439 <mycpu>
801040b1:	89 43 08             	mov    %eax,0x8(%ebx)
    getcallerpcs(&lk, lk->pcs);
801040b4:	83 ec 08             	sub    $0x8,%esp
801040b7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ba:	83 c0 0c             	add    $0xc,%eax
801040bd:	50                   	push   %eax
801040be:	8d 45 08             	lea    0x8(%ebp),%eax
801040c1:	50                   	push   %eax
801040c2:	e8 81 fe ff ff       	call   80103f48 <getcallerpcs>
}
801040c7:	83 c4 10             	add    $0x10,%esp
801040ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801040cd:	c9                   	leave  
801040ce:	c3                   	ret    
        panic("acquire");
801040cf:	83 ec 0c             	sub    $0xc,%esp
801040d2:	68 a1 6f 10 80       	push   $0x80106fa1
801040d7:	e8 68 c2 ff ff       	call   80100344 <panic>

801040dc <release>:
{
801040dc:	55                   	push   %ebp
801040dd:	89 e5                	mov    %esp,%ebp
801040df:	53                   	push   %ebx
801040e0:	83 ec 10             	sub    $0x10,%esp
801040e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (!holding(lk))
801040e6:	53                   	push   %ebx
801040e7:	e8 55 ff ff ff       	call   80104041 <holding>
801040ec:	83 c4 10             	add    $0x10,%esp
801040ef:	85 c0                	test   %eax,%eax
801040f1:	74 23                	je     80104116 <release+0x3a>
    lk->pcs[0] = 0;
801040f3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    lk->cpu = 0;
801040fa:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    __sync_synchronize();
80104101:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
    asm volatile("movl $0, %0" : "+m"(lk->locked) :);
80104106:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    popcli();
8010410c:	e8 d0 fe ff ff       	call   80103fe1 <popcli>
}
80104111:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104114:	c9                   	leave  
80104115:	c3                   	ret    
        panic("release");
80104116:	83 ec 0c             	sub    $0xc,%esp
80104119:	68 a9 6f 10 80       	push   $0x80106fa9
8010411e:	e8 21 c2 ff ff       	call   80100344 <panic>

80104123 <memset>:
#include "types.h"
#include "x86.h"

void *memset(void *dst, int c, uint n)
{
80104123:	55                   	push   %ebp
80104124:	89 e5                	mov    %esp,%ebp
80104126:	57                   	push   %edi
80104127:	53                   	push   %ebx
80104128:	8b 55 08             	mov    0x8(%ebp),%edx
8010412b:	8b 4d 10             	mov    0x10(%ebp),%ecx
    if ((int)dst % 4 == 0 && n % 4 == 0) {
8010412e:	f6 c2 03             	test   $0x3,%dl
80104131:	75 05                	jne    80104138 <memset+0x15>
80104133:	f6 c1 03             	test   $0x3,%cl
80104136:	74 0e                	je     80104146 <memset+0x23>
    asm volatile("cld; rep stosb"
80104138:	89 d7                	mov    %edx,%edi
8010413a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010413d:	fc                   	cld    
8010413e:	f3 aa                	rep stos %al,%es:(%edi)
        c &= 0xFF;
        stosl(dst, (c << 24) | (c << 16) | (c << 8) | c, n / 4);
    } else
        stosb(dst, c, n);
    return dst;
}
80104140:	89 d0                	mov    %edx,%eax
80104142:	5b                   	pop    %ebx
80104143:	5f                   	pop    %edi
80104144:	5d                   	pop    %ebp
80104145:	c3                   	ret    
        c &= 0xFF;
80104146:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
        stosl(dst, (c << 24) | (c << 16) | (c << 8) | c, n / 4);
8010414a:	c1 e9 02             	shr    $0x2,%ecx
8010414d:	89 f8                	mov    %edi,%eax
8010414f:	c1 e0 18             	shl    $0x18,%eax
80104152:	89 fb                	mov    %edi,%ebx
80104154:	c1 e3 10             	shl    $0x10,%ebx
80104157:	09 d8                	or     %ebx,%eax
80104159:	09 f8                	or     %edi,%eax
8010415b:	c1 e7 08             	shl    $0x8,%edi
8010415e:	09 f8                	or     %edi,%eax
    asm volatile("cld; rep stosl"
80104160:	89 d7                	mov    %edx,%edi
80104162:	fc                   	cld    
80104163:	f3 ab                	rep stos %eax,%es:(%edi)
80104165:	eb d9                	jmp    80104140 <memset+0x1d>

80104167 <memcmp>:

int memcmp(const void *v1, const void *v2, uint n)
{
80104167:	55                   	push   %ebp
80104168:	89 e5                	mov    %esp,%ebp
8010416a:	57                   	push   %edi
8010416b:	56                   	push   %esi
8010416c:	53                   	push   %ebx
8010416d:	8b 75 08             	mov    0x8(%ebp),%esi
80104170:	8b 7d 0c             	mov    0xc(%ebp),%edi
80104173:	8b 5d 10             	mov    0x10(%ebp),%ebx
    const uchar *s1, *s2;

    s1 = v1;
    s2 = v2;
    while (n-- > 0) {
80104176:	85 db                	test   %ebx,%ebx
80104178:	74 37                	je     801041b1 <memcmp+0x4a>
        if (*s1 != *s2)
8010417a:	0f b6 16             	movzbl (%esi),%edx
8010417d:	0f b6 0f             	movzbl (%edi),%ecx
80104180:	38 ca                	cmp    %cl,%dl
80104182:	75 19                	jne    8010419d <memcmp+0x36>
80104184:	b8 01 00 00 00       	mov    $0x1,%eax
    while (n-- > 0) {
80104189:	39 d8                	cmp    %ebx,%eax
8010418b:	74 1d                	je     801041aa <memcmp+0x43>
        if (*s1 != *s2)
8010418d:	0f b6 14 06          	movzbl (%esi,%eax,1),%edx
80104191:	83 c0 01             	add    $0x1,%eax
80104194:	0f b6 4c 07 ff       	movzbl -0x1(%edi,%eax,1),%ecx
80104199:	38 ca                	cmp    %cl,%dl
8010419b:	74 ec                	je     80104189 <memcmp+0x22>
            return *s1 - *s2;
8010419d:	0f b6 c2             	movzbl %dl,%eax
801041a0:	0f b6 c9             	movzbl %cl,%ecx
801041a3:	29 c8                	sub    %ecx,%eax
        s1++, s2++;
    }

    return 0;
}
801041a5:	5b                   	pop    %ebx
801041a6:	5e                   	pop    %esi
801041a7:	5f                   	pop    %edi
801041a8:	5d                   	pop    %ebp
801041a9:	c3                   	ret    
    return 0;
801041aa:	b8 00 00 00 00       	mov    $0x0,%eax
801041af:	eb f4                	jmp    801041a5 <memcmp+0x3e>
801041b1:	b8 00 00 00 00       	mov    $0x0,%eax
801041b6:	eb ed                	jmp    801041a5 <memcmp+0x3e>

801041b8 <memmove>:

void *memmove(void *dst, const void *src, uint n)
{
801041b8:	55                   	push   %ebp
801041b9:	89 e5                	mov    %esp,%ebp
801041bb:	56                   	push   %esi
801041bc:	53                   	push   %ebx
801041bd:	8b 45 08             	mov    0x8(%ebp),%eax
801041c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801041c3:	8b 75 10             	mov    0x10(%ebp),%esi
    const char *s;
    char *d;

    s = src;
    d = dst;
    if (s < d && s + n > d) {
801041c6:	39 c3                	cmp    %eax,%ebx
801041c8:	72 1b                	jb     801041e5 <memmove+0x2d>
        s += n;
        d += n;
        while (n-- > 0)
            *--d = *--s;
    } else
        while (n-- > 0)
801041ca:	ba 00 00 00 00       	mov    $0x0,%edx
801041cf:	85 f6                	test   %esi,%esi
801041d1:	74 0e                	je     801041e1 <memmove+0x29>
            *d++ = *s++;
801041d3:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
801041d7:	88 0c 10             	mov    %cl,(%eax,%edx,1)
801041da:	83 c2 01             	add    $0x1,%edx
        while (n-- > 0)
801041dd:	39 d6                	cmp    %edx,%esi
801041df:	75 f2                	jne    801041d3 <memmove+0x1b>

    return dst;
}
801041e1:	5b                   	pop    %ebx
801041e2:	5e                   	pop    %esi
801041e3:	5d                   	pop    %ebp
801041e4:	c3                   	ret    
    if (s < d && s + n > d) {
801041e5:	8d 14 33             	lea    (%ebx,%esi,1),%edx
801041e8:	39 d0                	cmp    %edx,%eax
801041ea:	73 de                	jae    801041ca <memmove+0x12>
        while (n-- > 0)
801041ec:	8d 56 ff             	lea    -0x1(%esi),%edx
801041ef:	85 f6                	test   %esi,%esi
801041f1:	74 ee                	je     801041e1 <memmove+0x29>
            *--d = *--s;
801041f3:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
801041f7:	88 0c 10             	mov    %cl,(%eax,%edx,1)
        while (n-- > 0)
801041fa:	83 ea 01             	sub    $0x1,%edx
801041fd:	83 fa ff             	cmp    $0xffffffff,%edx
80104200:	75 f1                	jne    801041f3 <memmove+0x3b>
80104202:	eb dd                	jmp    801041e1 <memmove+0x29>

80104204 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *memcpy(void *dst, const void *src, uint n)
{
80104204:	55                   	push   %ebp
80104205:	89 e5                	mov    %esp,%ebp
    return memmove(dst, src, n);
80104207:	ff 75 10             	pushl  0x10(%ebp)
8010420a:	ff 75 0c             	pushl  0xc(%ebp)
8010420d:	ff 75 08             	pushl  0x8(%ebp)
80104210:	e8 a3 ff ff ff       	call   801041b8 <memmove>
}
80104215:	c9                   	leave  
80104216:	c3                   	ret    

80104217 <strncmp>:

int strncmp(const char *p, const char *q, uint n)
{
80104217:	55                   	push   %ebp
80104218:	89 e5                	mov    %esp,%ebp
8010421a:	53                   	push   %ebx
8010421b:	8b 45 08             	mov    0x8(%ebp),%eax
8010421e:	8b 55 0c             	mov    0xc(%ebp),%edx
80104221:	8b 5d 10             	mov    0x10(%ebp),%ebx
    while (n > 0 && *p && *p == *q)
80104224:	85 db                	test   %ebx,%ebx
80104226:	74 2d                	je     80104255 <strncmp+0x3e>
80104228:	0f b6 08             	movzbl (%eax),%ecx
8010422b:	84 c9                	test   %cl,%cl
8010422d:	74 1b                	je     8010424a <strncmp+0x33>
8010422f:	3a 0a                	cmp    (%edx),%cl
80104231:	75 17                	jne    8010424a <strncmp+0x33>
80104233:	01 c3                	add    %eax,%ebx
        n--, p++, q++;
80104235:	83 c0 01             	add    $0x1,%eax
80104238:	83 c2 01             	add    $0x1,%edx
    while (n > 0 && *p && *p == *q)
8010423b:	39 d8                	cmp    %ebx,%eax
8010423d:	74 1d                	je     8010425c <strncmp+0x45>
8010423f:	0f b6 08             	movzbl (%eax),%ecx
80104242:	84 c9                	test   %cl,%cl
80104244:	74 04                	je     8010424a <strncmp+0x33>
80104246:	3a 0a                	cmp    (%edx),%cl
80104248:	74 eb                	je     80104235 <strncmp+0x1e>
    if (n == 0)
        return 0;
    return (uchar)*p - (uchar)*q;
8010424a:	0f b6 00             	movzbl (%eax),%eax
8010424d:	0f b6 12             	movzbl (%edx),%edx
80104250:	29 d0                	sub    %edx,%eax
}
80104252:	5b                   	pop    %ebx
80104253:	5d                   	pop    %ebp
80104254:	c3                   	ret    
        return 0;
80104255:	b8 00 00 00 00       	mov    $0x0,%eax
8010425a:	eb f6                	jmp    80104252 <strncmp+0x3b>
8010425c:	b8 00 00 00 00       	mov    $0x0,%eax
80104261:	eb ef                	jmp    80104252 <strncmp+0x3b>

80104263 <strncpy>:

char *strncpy(char *s, const char *t, int n)
{
80104263:	55                   	push   %ebp
80104264:	89 e5                	mov    %esp,%ebp
80104266:	57                   	push   %edi
80104267:	56                   	push   %esi
80104268:	53                   	push   %ebx
80104269:	8b 7d 08             	mov    0x8(%ebp),%edi
8010426c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010426f:	8b 55 10             	mov    0x10(%ebp),%edx
    char *os;

    os = s;
    while (n-- > 0 && (*s++ = *t++) != 0)
80104272:	89 f9                	mov    %edi,%ecx
80104274:	eb 02                	jmp    80104278 <strncpy+0x15>
80104276:	89 f2                	mov    %esi,%edx
80104278:	8d 72 ff             	lea    -0x1(%edx),%esi
8010427b:	85 d2                	test   %edx,%edx
8010427d:	7e 11                	jle    80104290 <strncpy+0x2d>
8010427f:	83 c3 01             	add    $0x1,%ebx
80104282:	83 c1 01             	add    $0x1,%ecx
80104285:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
80104289:	88 41 ff             	mov    %al,-0x1(%ecx)
8010428c:	84 c0                	test   %al,%al
8010428e:	75 e6                	jne    80104276 <strncpy+0x13>
        ;
    while (n-- > 0)
80104290:	bb 00 00 00 00       	mov    $0x0,%ebx
80104295:	83 ea 01             	sub    $0x1,%edx
80104298:	85 f6                	test   %esi,%esi
8010429a:	7e 0f                	jle    801042ab <strncpy+0x48>
        *s++ = 0;
8010429c:	c6 04 19 00          	movb   $0x0,(%ecx,%ebx,1)
801042a0:	83 c3 01             	add    $0x1,%ebx
801042a3:	89 d6                	mov    %edx,%esi
801042a5:	29 de                	sub    %ebx,%esi
    while (n-- > 0)
801042a7:	85 f6                	test   %esi,%esi
801042a9:	7f f1                	jg     8010429c <strncpy+0x39>
    return os;
}
801042ab:	89 f8                	mov    %edi,%eax
801042ad:	5b                   	pop    %ebx
801042ae:	5e                   	pop    %esi
801042af:	5f                   	pop    %edi
801042b0:	5d                   	pop    %ebp
801042b1:	c3                   	ret    

801042b2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *safestrcpy(char *s, const char *t, int n)
{
801042b2:	55                   	push   %ebp
801042b3:	89 e5                	mov    %esp,%ebp
801042b5:	56                   	push   %esi
801042b6:	53                   	push   %ebx
801042b7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ba:	8b 55 0c             	mov    0xc(%ebp),%edx
801042bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
    char *os;

    os = s;
    if (n <= 0)
801042c0:	85 c9                	test   %ecx,%ecx
801042c2:	7e 1e                	jle    801042e2 <safestrcpy+0x30>
801042c4:	8d 74 0a ff          	lea    -0x1(%edx,%ecx,1),%esi
801042c8:	89 c1                	mov    %eax,%ecx
        return os;
    while (--n > 0 && (*s++ = *t++) != 0)
801042ca:	39 f2                	cmp    %esi,%edx
801042cc:	74 11                	je     801042df <safestrcpy+0x2d>
801042ce:	83 c2 01             	add    $0x1,%edx
801042d1:	83 c1 01             	add    $0x1,%ecx
801042d4:	0f b6 5a ff          	movzbl -0x1(%edx),%ebx
801042d8:	88 59 ff             	mov    %bl,-0x1(%ecx)
801042db:	84 db                	test   %bl,%bl
801042dd:	75 eb                	jne    801042ca <safestrcpy+0x18>
        ;
    *s = 0;
801042df:	c6 01 00             	movb   $0x0,(%ecx)
    return os;
}
801042e2:	5b                   	pop    %ebx
801042e3:	5e                   	pop    %esi
801042e4:	5d                   	pop    %ebp
801042e5:	c3                   	ret    

801042e6 <strlen>:

int strlen(const char *s)
{
801042e6:	55                   	push   %ebp
801042e7:	89 e5                	mov    %esp,%ebp
801042e9:	8b 55 08             	mov    0x8(%ebp),%edx
    int n;

    for (n = 0; s[n]; n++)
801042ec:	80 3a 00             	cmpb   $0x0,(%edx)
801042ef:	74 10                	je     80104301 <strlen+0x1b>
801042f1:	b8 00 00 00 00       	mov    $0x0,%eax
801042f6:	83 c0 01             	add    $0x1,%eax
801042f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
801042fd:	75 f7                	jne    801042f6 <strlen+0x10>
        ;
    return n;
}
801042ff:	5d                   	pop    %ebp
80104300:	c3                   	ret    
    for (n = 0; s[n]; n++)
80104301:	b8 00 00 00 00       	mov    $0x0,%eax
    return n;
80104306:	eb f7                	jmp    801042ff <strlen+0x19>

80104308 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104308:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010430c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104310:	55                   	push   %ebp
  pushl %ebx
80104311:	53                   	push   %ebx
  pushl %esi
80104312:	56                   	push   %esi
  pushl %edi
80104313:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104314:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104316:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80104318:	5f                   	pop    %edi
  popl %esi
80104319:	5e                   	pop    %esi
  popl %ebx
8010431a:	5b                   	pop    %ebx
  popl %ebp
8010431b:	5d                   	pop    %ebp
  ret
8010431c:	c3                   	ret    

8010431d <fetchint>:
// library system call function. The saved user %esp points
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int fetchint(uint addr, int *ip)
{
8010431d:	55                   	push   %ebp
8010431e:	89 e5                	mov    %esp,%ebp
80104320:	53                   	push   %ebx
80104321:	83 ec 04             	sub    $0x4,%esp
80104324:	8b 5d 08             	mov    0x8(%ebp),%ebx
    struct proc *curproc = myproc();
80104327:	e8 9f f1 ff ff       	call   801034cb <myproc>

    if (addr >= curproc->sz || addr + 4 > curproc->sz)
8010432c:	8b 00                	mov    (%eax),%eax
8010432e:	39 d8                	cmp    %ebx,%eax
80104330:	76 19                	jbe    8010434b <fetchint+0x2e>
80104332:	8d 53 04             	lea    0x4(%ebx),%edx
80104335:	39 d0                	cmp    %edx,%eax
80104337:	72 19                	jb     80104352 <fetchint+0x35>
        return -1;
    *ip = *(int *)(addr);
80104339:	8b 13                	mov    (%ebx),%edx
8010433b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010433e:	89 10                	mov    %edx,(%eax)
    return 0;
80104340:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104345:	83 c4 04             	add    $0x4,%esp
80104348:	5b                   	pop    %ebx
80104349:	5d                   	pop    %ebp
8010434a:	c3                   	ret    
        return -1;
8010434b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104350:	eb f3                	jmp    80104345 <fetchint+0x28>
80104352:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104357:	eb ec                	jmp    80104345 <fetchint+0x28>

80104359 <fetchstr>:

// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int fetchstr(uint addr, char **pp)
{
80104359:	55                   	push   %ebp
8010435a:	89 e5                	mov    %esp,%ebp
8010435c:	53                   	push   %ebx
8010435d:	83 ec 04             	sub    $0x4,%esp
80104360:	8b 5d 08             	mov    0x8(%ebp),%ebx
    char *s, *ep;
    struct proc *curproc = myproc();
80104363:	e8 63 f1 ff ff       	call   801034cb <myproc>

    if (addr >= curproc->sz)
80104368:	39 18                	cmp    %ebx,(%eax)
8010436a:	76 2f                	jbe    8010439b <fetchstr+0x42>
        return -1;
    *pp = (char *)addr;
8010436c:	89 da                	mov    %ebx,%edx
8010436e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104371:	89 19                	mov    %ebx,(%ecx)
    ep = (char *)curproc->sz;
80104373:	8b 00                	mov    (%eax),%eax
    for (s = *pp; s < ep; s++) {
80104375:	39 c3                	cmp    %eax,%ebx
80104377:	73 29                	jae    801043a2 <fetchstr+0x49>
        if (*s == 0)
80104379:	80 3b 00             	cmpb   $0x0,(%ebx)
8010437c:	74 0c                	je     8010438a <fetchstr+0x31>
    for (s = *pp; s < ep; s++) {
8010437e:	83 c2 01             	add    $0x1,%edx
80104381:	39 d0                	cmp    %edx,%eax
80104383:	76 0f                	jbe    80104394 <fetchstr+0x3b>
        if (*s == 0)
80104385:	80 3a 00             	cmpb   $0x0,(%edx)
80104388:	75 f4                	jne    8010437e <fetchstr+0x25>
            return s - *pp;
8010438a:	89 d0                	mov    %edx,%eax
8010438c:	29 d8                	sub    %ebx,%eax
    }
    return -1;
}
8010438e:	83 c4 04             	add    $0x4,%esp
80104391:	5b                   	pop    %ebx
80104392:	5d                   	pop    %ebp
80104393:	c3                   	ret    
    return -1;
80104394:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104399:	eb f3                	jmp    8010438e <fetchstr+0x35>
        return -1;
8010439b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043a0:	eb ec                	jmp    8010438e <fetchstr+0x35>
    return -1;
801043a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043a7:	eb e5                	jmp    8010438e <fetchstr+0x35>

801043a9 <argint>:

// Fetch the nth 32-bit system call argument.
int argint(int n, int *ip)
{
801043a9:	55                   	push   %ebp
801043aa:	89 e5                	mov    %esp,%ebp
801043ac:	83 ec 08             	sub    $0x8,%esp
    return fetchint((myproc()->tf->esp) + 4 + 4 * n, ip);
801043af:	e8 17 f1 ff ff       	call   801034cb <myproc>
801043b4:	83 ec 08             	sub    $0x8,%esp
801043b7:	ff 75 0c             	pushl  0xc(%ebp)
801043ba:	8b 40 18             	mov    0x18(%eax),%eax
801043bd:	8b 40 44             	mov    0x44(%eax),%eax
801043c0:	8b 55 08             	mov    0x8(%ebp),%edx
801043c3:	8d 44 90 04          	lea    0x4(%eax,%edx,4),%eax
801043c7:	50                   	push   %eax
801043c8:	e8 50 ff ff ff       	call   8010431d <fetchint>
}
801043cd:	c9                   	leave  
801043ce:	c3                   	ret    

801043cf <argptr>:

// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int argptr(int n, char **pp, int size)
{
801043cf:	55                   	push   %ebp
801043d0:	89 e5                	mov    %esp,%ebp
801043d2:	56                   	push   %esi
801043d3:	53                   	push   %ebx
801043d4:	83 ec 10             	sub    $0x10,%esp
801043d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
    int i;
    struct proc *curproc = myproc();
801043da:	e8 ec f0 ff ff       	call   801034cb <myproc>
801043df:	89 c6                	mov    %eax,%esi

    if (argint(n, &i) < 0)
801043e1:	83 ec 08             	sub    $0x8,%esp
801043e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801043e7:	50                   	push   %eax
801043e8:	ff 75 08             	pushl  0x8(%ebp)
801043eb:	e8 b9 ff ff ff       	call   801043a9 <argint>
        return -1;
    if (size < 0 || (uint)i >= curproc->sz || (uint)i + size > curproc->sz)
801043f0:	83 c4 10             	add    $0x10,%esp
801043f3:	85 db                	test   %ebx,%ebx
801043f5:	78 24                	js     8010441b <argptr+0x4c>
801043f7:	85 c0                	test   %eax,%eax
801043f9:	78 20                	js     8010441b <argptr+0x4c>
801043fb:	8b 16                	mov    (%esi),%edx
801043fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104400:	39 c2                	cmp    %eax,%edx
80104402:	76 1e                	jbe    80104422 <argptr+0x53>
80104404:	01 c3                	add    %eax,%ebx
80104406:	39 da                	cmp    %ebx,%edx
80104408:	72 1f                	jb     80104429 <argptr+0x5a>
        return -1;
    *pp = (char *)i;
8010440a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010440d:	89 02                	mov    %eax,(%edx)
    return 0;
8010440f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104414:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104417:	5b                   	pop    %ebx
80104418:	5e                   	pop    %esi
80104419:	5d                   	pop    %ebp
8010441a:	c3                   	ret    
        return -1;
8010441b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104420:	eb f2                	jmp    80104414 <argptr+0x45>
80104422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104427:	eb eb                	jmp    80104414 <argptr+0x45>
80104429:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010442e:	eb e4                	jmp    80104414 <argptr+0x45>

80104430 <argstr>:
// Fetch the nth word-sized system call argument as a string pointer.
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int argstr(int n, char **pp)
{
80104430:	55                   	push   %ebp
80104431:	89 e5                	mov    %esp,%ebp
80104433:	83 ec 20             	sub    $0x20,%esp
    int addr;
    if (argint(n, &addr) < 0)
80104436:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104439:	50                   	push   %eax
8010443a:	ff 75 08             	pushl  0x8(%ebp)
8010443d:	e8 67 ff ff ff       	call   801043a9 <argint>
80104442:	83 c4 10             	add    $0x10,%esp
80104445:	85 c0                	test   %eax,%eax
80104447:	78 13                	js     8010445c <argstr+0x2c>
        return -1;
    return fetchstr(addr, pp);
80104449:	83 ec 08             	sub    $0x8,%esp
8010444c:	ff 75 0c             	pushl  0xc(%ebp)
8010444f:	ff 75 f4             	pushl  -0xc(%ebp)
80104452:	e8 02 ff ff ff       	call   80104359 <fetchstr>
80104457:	83 c4 10             	add    $0x10,%esp
}
8010445a:	c9                   	leave  
8010445b:	c3                   	ret    
        return -1;
8010445c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104461:	eb f7                	jmp    8010445a <argstr+0x2a>

80104463 <syscall>:
    [SYS_link] sys_link,     [SYS_mkdir] sys_mkdir,
    [SYS_close] sys_close,   [SYS_getlevel] sys_getlevel,
};

void syscall(void)
{
80104463:	55                   	push   %ebp
80104464:	89 e5                	mov    %esp,%ebp
80104466:	53                   	push   %ebx
80104467:	83 ec 04             	sub    $0x4,%esp
    int num;
    struct proc *curproc = myproc();
8010446a:	e8 5c f0 ff ff       	call   801034cb <myproc>
8010446f:	89 c3                	mov    %eax,%ebx

    num = curproc->tf->eax;
80104471:	8b 40 18             	mov    0x18(%eax),%eax
80104474:	8b 40 1c             	mov    0x1c(%eax),%eax
    if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104477:	8d 50 ff             	lea    -0x1(%eax),%edx
8010447a:	83 fa 15             	cmp    $0x15,%edx
8010447d:	77 18                	ja     80104497 <syscall+0x34>
8010447f:	8b 14 85 e0 6f 10 80 	mov    -0x7fef9020(,%eax,4),%edx
80104486:	85 d2                	test   %edx,%edx
80104488:	74 0d                	je     80104497 <syscall+0x34>
        curproc->tf->eax = syscalls[num]();
8010448a:	ff d2                	call   *%edx
8010448c:	8b 53 18             	mov    0x18(%ebx),%edx
8010448f:	89 42 1c             	mov    %eax,0x1c(%edx)
    } else {
        cprintf("%d %s: unknown sys call %d\n", curproc->pid, curproc->name,
                num);
        curproc->tf->eax = -1;
    }
}
80104492:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104495:	c9                   	leave  
80104496:	c3                   	ret    
        cprintf("%d %s: unknown sys call %d\n", curproc->pid, curproc->name,
80104497:	50                   	push   %eax
80104498:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010449b:	50                   	push   %eax
8010449c:	ff 73 10             	pushl  0x10(%ebx)
8010449f:	68 b1 6f 10 80       	push   $0x80106fb1
801044a4:	e8 38 c1 ff ff       	call   801005e1 <cprintf>
        curproc->tf->eax = -1;
801044a9:	8b 43 18             	mov    0x18(%ebx),%eax
801044ac:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
801044b3:	83 c4 10             	add    $0x10,%esp
}
801044b6:	eb da                	jmp    80104492 <syscall+0x2f>

801044b8 <argfd>:
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int argfd(int n, int *pfd, struct file **pf)
{
801044b8:	55                   	push   %ebp
801044b9:	89 e5                	mov    %esp,%ebp
801044bb:	56                   	push   %esi
801044bc:	53                   	push   %ebx
801044bd:	83 ec 18             	sub    $0x18,%esp
801044c0:	89 d6                	mov    %edx,%esi
801044c2:	89 cb                	mov    %ecx,%ebx
    int fd;
    struct file *f;

    if (argint(n, &fd) < 0)
801044c4:	8d 55 f4             	lea    -0xc(%ebp),%edx
801044c7:	52                   	push   %edx
801044c8:	50                   	push   %eax
801044c9:	e8 db fe ff ff       	call   801043a9 <argint>
801044ce:	83 c4 10             	add    $0x10,%esp
801044d1:	85 c0                	test   %eax,%eax
801044d3:	78 2e                	js     80104503 <argfd+0x4b>
        return -1;
    if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
801044d5:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801044d9:	77 2f                	ja     8010450a <argfd+0x52>
801044db:	e8 eb ef ff ff       	call   801034cb <myproc>
801044e0:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801044e3:	8b 54 88 28          	mov    0x28(%eax,%ecx,4),%edx
801044e7:	85 d2                	test   %edx,%edx
801044e9:	74 26                	je     80104511 <argfd+0x59>
        return -1;
    if (pfd)
801044eb:	85 f6                	test   %esi,%esi
801044ed:	74 02                	je     801044f1 <argfd+0x39>
        *pfd = fd;
801044ef:	89 0e                	mov    %ecx,(%esi)
    if (pf)
        *pf = f;
    return 0;
801044f1:	b8 00 00 00 00       	mov    $0x0,%eax
    if (pf)
801044f6:	85 db                	test   %ebx,%ebx
801044f8:	74 02                	je     801044fc <argfd+0x44>
        *pf = f;
801044fa:	89 13                	mov    %edx,(%ebx)
}
801044fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801044ff:	5b                   	pop    %ebx
80104500:	5e                   	pop    %esi
80104501:	5d                   	pop    %ebp
80104502:	c3                   	ret    
        return -1;
80104503:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104508:	eb f2                	jmp    801044fc <argfd+0x44>
        return -1;
8010450a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010450f:	eb eb                	jmp    801044fc <argfd+0x44>
80104511:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104516:	eb e4                	jmp    801044fc <argfd+0x44>

80104518 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int fdalloc(struct file *f)
{
80104518:	55                   	push   %ebp
80104519:	89 e5                	mov    %esp,%ebp
8010451b:	53                   	push   %ebx
8010451c:	83 ec 04             	sub    $0x4,%esp
8010451f:	89 c3                	mov    %eax,%ebx
    int fd;
    struct proc *curproc = myproc();
80104521:	e8 a5 ef ff ff       	call   801034cb <myproc>

    for (fd = 0; fd < NOFILE; fd++) {
        if (curproc->ofile[fd] == 0) {
80104526:	83 78 28 00          	cmpl   $0x0,0x28(%eax)
8010452a:	74 1b                	je     80104547 <fdalloc+0x2f>
    for (fd = 0; fd < NOFILE; fd++) {
8010452c:	ba 01 00 00 00       	mov    $0x1,%edx
        if (curproc->ofile[fd] == 0) {
80104531:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
80104536:	74 14                	je     8010454c <fdalloc+0x34>
    for (fd = 0; fd < NOFILE; fd++) {
80104538:	83 c2 01             	add    $0x1,%edx
8010453b:	83 fa 10             	cmp    $0x10,%edx
8010453e:	75 f1                	jne    80104531 <fdalloc+0x19>
            curproc->ofile[fd] = f;
            return fd;
        }
    }
    return -1;
80104540:	ba ff ff ff ff       	mov    $0xffffffff,%edx
80104545:	eb 09                	jmp    80104550 <fdalloc+0x38>
    for (fd = 0; fd < NOFILE; fd++) {
80104547:	ba 00 00 00 00       	mov    $0x0,%edx
            curproc->ofile[fd] = f;
8010454c:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
}
80104550:	89 d0                	mov    %edx,%eax
80104552:	83 c4 04             	add    $0x4,%esp
80104555:	5b                   	pop    %ebx
80104556:	5d                   	pop    %ebp
80104557:	c3                   	ret    

80104558 <create>:
    end_op();
    return -1;
}

static struct inode *create(char *path, short type, short major, short minor)
{
80104558:	55                   	push   %ebp
80104559:	89 e5                	mov    %esp,%ebp
8010455b:	57                   	push   %edi
8010455c:	56                   	push   %esi
8010455d:	53                   	push   %ebx
8010455e:	83 ec 34             	sub    $0x34,%esp
80104561:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80104564:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104567:	8b 7d 08             	mov    0x8(%ebp),%edi
    struct inode *ip, *dp;
    char name[DIRSIZ];

    if ((dp = nameiparent(path, name)) == 0)
8010456a:	8d 55 da             	lea    -0x26(%ebp),%edx
8010456d:	52                   	push   %edx
8010456e:	50                   	push   %eax
8010456f:	e8 27 d7 ff ff       	call   80101c9b <nameiparent>
80104574:	89 c6                	mov    %eax,%esi
80104576:	83 c4 10             	add    $0x10,%esp
80104579:	85 c0                	test   %eax,%eax
8010457b:	0f 84 32 01 00 00    	je     801046b3 <create+0x15b>
        return 0;
    ilock(dp);
80104581:	83 ec 0c             	sub    $0xc,%esp
80104584:	50                   	push   %eax
80104585:	e8 5c cf ff ff       	call   801014e6 <ilock>

    if ((ip = dirlookup(dp, name, 0)) != 0) {
8010458a:	83 c4 0c             	add    $0xc,%esp
8010458d:	6a 00                	push   $0x0
8010458f:	8d 45 da             	lea    -0x26(%ebp),%eax
80104592:	50                   	push   %eax
80104593:	56                   	push   %esi
80104594:	e8 13 d4 ff ff       	call   801019ac <dirlookup>
80104599:	89 c3                	mov    %eax,%ebx
8010459b:	83 c4 10             	add    $0x10,%esp
8010459e:	85 c0                	test   %eax,%eax
801045a0:	74 3f                	je     801045e1 <create+0x89>
        iunlockput(dp);
801045a2:	83 ec 0c             	sub    $0xc,%esp
801045a5:	56                   	push   %esi
801045a6:	e8 84 d1 ff ff       	call   8010172f <iunlockput>
        ilock(ip);
801045ab:	89 1c 24             	mov    %ebx,(%esp)
801045ae:	e8 33 cf ff ff       	call   801014e6 <ilock>
        if (type == T_FILE && ip->type == T_FILE)
801045b3:	83 c4 10             	add    $0x10,%esp
801045b6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801045bb:	75 11                	jne    801045ce <create+0x76>
801045bd:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801045c2:	75 0a                	jne    801045ce <create+0x76>
        panic("create: dirlink");

    iunlockput(dp);

    return ip;
}
801045c4:	89 d8                	mov    %ebx,%eax
801045c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801045c9:	5b                   	pop    %ebx
801045ca:	5e                   	pop    %esi
801045cb:	5f                   	pop    %edi
801045cc:	5d                   	pop    %ebp
801045cd:	c3                   	ret    
        iunlockput(ip);
801045ce:	83 ec 0c             	sub    $0xc,%esp
801045d1:	53                   	push   %ebx
801045d2:	e8 58 d1 ff ff       	call   8010172f <iunlockput>
        return 0;
801045d7:	83 c4 10             	add    $0x10,%esp
801045da:	bb 00 00 00 00       	mov    $0x0,%ebx
801045df:	eb e3                	jmp    801045c4 <create+0x6c>
    if ((ip = ialloc(dp->dev, type)) == 0)
801045e1:	83 ec 08             	sub    $0x8,%esp
801045e4:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
801045e8:	50                   	push   %eax
801045e9:	ff 36                	pushl  (%esi)
801045eb:	e8 a3 cd ff ff       	call   80101393 <ialloc>
801045f0:	89 c3                	mov    %eax,%ebx
801045f2:	83 c4 10             	add    $0x10,%esp
801045f5:	85 c0                	test   %eax,%eax
801045f7:	74 55                	je     8010464e <create+0xf6>
    ilock(ip);
801045f9:	83 ec 0c             	sub    $0xc,%esp
801045fc:	50                   	push   %eax
801045fd:	e8 e4 ce ff ff       	call   801014e6 <ilock>
    ip->major = major;
80104602:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80104606:	66 89 43 52          	mov    %ax,0x52(%ebx)
    ip->minor = minor;
8010460a:	66 89 7b 54          	mov    %di,0x54(%ebx)
    ip->nlink = 1;
8010460e:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
    iupdate(ip);
80104614:	89 1c 24             	mov    %ebx,(%esp)
80104617:	e8 20 ce ff ff       	call   8010143c <iupdate>
    if (type == T_DIR) { // Create . and .. entries.
8010461c:	83 c4 10             	add    $0x10,%esp
8010461f:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80104624:	74 35                	je     8010465b <create+0x103>
    if (dirlink(dp, name, ip->inum) < 0)
80104626:	83 ec 04             	sub    $0x4,%esp
80104629:	ff 73 04             	pushl  0x4(%ebx)
8010462c:	8d 45 da             	lea    -0x26(%ebp),%eax
8010462f:	50                   	push   %eax
80104630:	56                   	push   %esi
80104631:	e8 98 d5 ff ff       	call   80101bce <dirlink>
80104636:	83 c4 10             	add    $0x10,%esp
80104639:	85 c0                	test   %eax,%eax
8010463b:	78 69                	js     801046a6 <create+0x14e>
    iunlockput(dp);
8010463d:	83 ec 0c             	sub    $0xc,%esp
80104640:	56                   	push   %esi
80104641:	e8 e9 d0 ff ff       	call   8010172f <iunlockput>
    return ip;
80104646:	83 c4 10             	add    $0x10,%esp
80104649:	e9 76 ff ff ff       	jmp    801045c4 <create+0x6c>
        panic("create: ialloc");
8010464e:	83 ec 0c             	sub    $0xc,%esp
80104651:	68 3c 70 10 80       	push   $0x8010703c
80104656:	e8 e9 bc ff ff       	call   80100344 <panic>
        dp->nlink++;     // for ".."
8010465b:	66 83 46 56 01       	addw   $0x1,0x56(%esi)
        iupdate(dp);
80104660:	83 ec 0c             	sub    $0xc,%esp
80104663:	56                   	push   %esi
80104664:	e8 d3 cd ff ff       	call   8010143c <iupdate>
        if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104669:	83 c4 0c             	add    $0xc,%esp
8010466c:	ff 73 04             	pushl  0x4(%ebx)
8010466f:	68 4c 70 10 80       	push   $0x8010704c
80104674:	53                   	push   %ebx
80104675:	e8 54 d5 ff ff       	call   80101bce <dirlink>
8010467a:	83 c4 10             	add    $0x10,%esp
8010467d:	85 c0                	test   %eax,%eax
8010467f:	78 18                	js     80104699 <create+0x141>
80104681:	83 ec 04             	sub    $0x4,%esp
80104684:	ff 76 04             	pushl  0x4(%esi)
80104687:	68 4b 70 10 80       	push   $0x8010704b
8010468c:	53                   	push   %ebx
8010468d:	e8 3c d5 ff ff       	call   80101bce <dirlink>
80104692:	83 c4 10             	add    $0x10,%esp
80104695:	85 c0                	test   %eax,%eax
80104697:	79 8d                	jns    80104626 <create+0xce>
            panic("create dots");
80104699:	83 ec 0c             	sub    $0xc,%esp
8010469c:	68 4e 70 10 80       	push   $0x8010704e
801046a1:	e8 9e bc ff ff       	call   80100344 <panic>
        panic("create: dirlink");
801046a6:	83 ec 0c             	sub    $0xc,%esp
801046a9:	68 5a 70 10 80       	push   $0x8010705a
801046ae:	e8 91 bc ff ff       	call   80100344 <panic>
        return 0;
801046b3:	89 c3                	mov    %eax,%ebx
801046b5:	e9 0a ff ff ff       	jmp    801045c4 <create+0x6c>

801046ba <sys_dup>:
{
801046ba:	55                   	push   %ebp
801046bb:	89 e5                	mov    %esp,%ebp
801046bd:	53                   	push   %ebx
801046be:	83 ec 14             	sub    $0x14,%esp
    if (argfd(0, 0, &f) < 0)
801046c1:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801046c4:	ba 00 00 00 00       	mov    $0x0,%edx
801046c9:	b8 00 00 00 00       	mov    $0x0,%eax
801046ce:	e8 e5 fd ff ff       	call   801044b8 <argfd>
801046d3:	85 c0                	test   %eax,%eax
801046d5:	78 23                	js     801046fa <sys_dup+0x40>
    if ((fd = fdalloc(f)) < 0)
801046d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046da:	e8 39 fe ff ff       	call   80104518 <fdalloc>
801046df:	89 c3                	mov    %eax,%ebx
801046e1:	85 c0                	test   %eax,%eax
801046e3:	78 1c                	js     80104701 <sys_dup+0x47>
    filedup(f);
801046e5:	83 ec 0c             	sub    $0xc,%esp
801046e8:	ff 75 f4             	pushl  -0xc(%ebp)
801046eb:	e8 f7 c5 ff ff       	call   80100ce7 <filedup>
    return fd;
801046f0:	83 c4 10             	add    $0x10,%esp
}
801046f3:	89 d8                	mov    %ebx,%eax
801046f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801046f8:	c9                   	leave  
801046f9:	c3                   	ret    
        return -1;
801046fa:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801046ff:	eb f2                	jmp    801046f3 <sys_dup+0x39>
        return -1;
80104701:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104706:	eb eb                	jmp    801046f3 <sys_dup+0x39>

80104708 <sys_read>:
{
80104708:	55                   	push   %ebp
80104709:	89 e5                	mov    %esp,%ebp
8010470b:	83 ec 18             	sub    $0x18,%esp
    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010470e:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104711:	ba 00 00 00 00       	mov    $0x0,%edx
80104716:	b8 00 00 00 00       	mov    $0x0,%eax
8010471b:	e8 98 fd ff ff       	call   801044b8 <argfd>
80104720:	85 c0                	test   %eax,%eax
80104722:	78 43                	js     80104767 <sys_read+0x5f>
80104724:	83 ec 08             	sub    $0x8,%esp
80104727:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010472a:	50                   	push   %eax
8010472b:	6a 02                	push   $0x2
8010472d:	e8 77 fc ff ff       	call   801043a9 <argint>
80104732:	83 c4 10             	add    $0x10,%esp
80104735:	85 c0                	test   %eax,%eax
80104737:	78 35                	js     8010476e <sys_read+0x66>
80104739:	83 ec 04             	sub    $0x4,%esp
8010473c:	ff 75 f0             	pushl  -0x10(%ebp)
8010473f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104742:	50                   	push   %eax
80104743:	6a 01                	push   $0x1
80104745:	e8 85 fc ff ff       	call   801043cf <argptr>
8010474a:	83 c4 10             	add    $0x10,%esp
8010474d:	85 c0                	test   %eax,%eax
8010474f:	78 24                	js     80104775 <sys_read+0x6d>
    return fileread(f, p, n);
80104751:	83 ec 04             	sub    $0x4,%esp
80104754:	ff 75 f0             	pushl  -0x10(%ebp)
80104757:	ff 75 ec             	pushl  -0x14(%ebp)
8010475a:	ff 75 f4             	pushl  -0xc(%ebp)
8010475d:	e8 c6 c6 ff ff       	call   80100e28 <fileread>
80104762:	83 c4 10             	add    $0x10,%esp
}
80104765:	c9                   	leave  
80104766:	c3                   	ret    
        return -1;
80104767:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010476c:	eb f7                	jmp    80104765 <sys_read+0x5d>
8010476e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104773:	eb f0                	jmp    80104765 <sys_read+0x5d>
80104775:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010477a:	eb e9                	jmp    80104765 <sys_read+0x5d>

8010477c <sys_write>:
{
8010477c:	55                   	push   %ebp
8010477d:	89 e5                	mov    %esp,%ebp
8010477f:	83 ec 18             	sub    $0x18,%esp
    if (argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104782:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104785:	ba 00 00 00 00       	mov    $0x0,%edx
8010478a:	b8 00 00 00 00       	mov    $0x0,%eax
8010478f:	e8 24 fd ff ff       	call   801044b8 <argfd>
80104794:	85 c0                	test   %eax,%eax
80104796:	78 43                	js     801047db <sys_write+0x5f>
80104798:	83 ec 08             	sub    $0x8,%esp
8010479b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010479e:	50                   	push   %eax
8010479f:	6a 02                	push   $0x2
801047a1:	e8 03 fc ff ff       	call   801043a9 <argint>
801047a6:	83 c4 10             	add    $0x10,%esp
801047a9:	85 c0                	test   %eax,%eax
801047ab:	78 35                	js     801047e2 <sys_write+0x66>
801047ad:	83 ec 04             	sub    $0x4,%esp
801047b0:	ff 75 f0             	pushl  -0x10(%ebp)
801047b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801047b6:	50                   	push   %eax
801047b7:	6a 01                	push   $0x1
801047b9:	e8 11 fc ff ff       	call   801043cf <argptr>
801047be:	83 c4 10             	add    $0x10,%esp
801047c1:	85 c0                	test   %eax,%eax
801047c3:	78 24                	js     801047e9 <sys_write+0x6d>
    return filewrite(f, p, n);
801047c5:	83 ec 04             	sub    $0x4,%esp
801047c8:	ff 75 f0             	pushl  -0x10(%ebp)
801047cb:	ff 75 ec             	pushl  -0x14(%ebp)
801047ce:	ff 75 f4             	pushl  -0xc(%ebp)
801047d1:	e8 d7 c6 ff ff       	call   80100ead <filewrite>
801047d6:	83 c4 10             	add    $0x10,%esp
}
801047d9:	c9                   	leave  
801047da:	c3                   	ret    
        return -1;
801047db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047e0:	eb f7                	jmp    801047d9 <sys_write+0x5d>
801047e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047e7:	eb f0                	jmp    801047d9 <sys_write+0x5d>
801047e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047ee:	eb e9                	jmp    801047d9 <sys_write+0x5d>

801047f0 <sys_close>:
{
801047f0:	55                   	push   %ebp
801047f1:	89 e5                	mov    %esp,%ebp
801047f3:	83 ec 18             	sub    $0x18,%esp
    if (argfd(0, &fd, &f) < 0)
801047f6:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801047f9:	8d 55 f4             	lea    -0xc(%ebp),%edx
801047fc:	b8 00 00 00 00       	mov    $0x0,%eax
80104801:	e8 b2 fc ff ff       	call   801044b8 <argfd>
80104806:	85 c0                	test   %eax,%eax
80104808:	78 25                	js     8010482f <sys_close+0x3f>
    myproc()->ofile[fd] = 0;
8010480a:	e8 bc ec ff ff       	call   801034cb <myproc>
8010480f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104812:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104819:	00 
    fileclose(f);
8010481a:	83 ec 0c             	sub    $0xc,%esp
8010481d:	ff 75 f0             	pushl  -0x10(%ebp)
80104820:	e8 07 c5 ff ff       	call   80100d2c <fileclose>
    return 0;
80104825:	83 c4 10             	add    $0x10,%esp
80104828:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010482d:	c9                   	leave  
8010482e:	c3                   	ret    
        return -1;
8010482f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104834:	eb f7                	jmp    8010482d <sys_close+0x3d>

80104836 <sys_fstat>:
{
80104836:	55                   	push   %ebp
80104837:	89 e5                	mov    %esp,%ebp
80104839:	83 ec 18             	sub    $0x18,%esp
    if (argfd(0, 0, &f) < 0 || argptr(1, (void *)&st, sizeof(*st)) < 0)
8010483c:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010483f:	ba 00 00 00 00       	mov    $0x0,%edx
80104844:	b8 00 00 00 00       	mov    $0x0,%eax
80104849:	e8 6a fc ff ff       	call   801044b8 <argfd>
8010484e:	85 c0                	test   %eax,%eax
80104850:	78 2a                	js     8010487c <sys_fstat+0x46>
80104852:	83 ec 04             	sub    $0x4,%esp
80104855:	6a 14                	push   $0x14
80104857:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010485a:	50                   	push   %eax
8010485b:	6a 01                	push   $0x1
8010485d:	e8 6d fb ff ff       	call   801043cf <argptr>
80104862:	83 c4 10             	add    $0x10,%esp
80104865:	85 c0                	test   %eax,%eax
80104867:	78 1a                	js     80104883 <sys_fstat+0x4d>
    return filestat(f, st);
80104869:	83 ec 08             	sub    $0x8,%esp
8010486c:	ff 75 f0             	pushl  -0x10(%ebp)
8010486f:	ff 75 f4             	pushl  -0xc(%ebp)
80104872:	e8 6a c5 ff ff       	call   80100de1 <filestat>
80104877:	83 c4 10             	add    $0x10,%esp
}
8010487a:	c9                   	leave  
8010487b:	c3                   	ret    
        return -1;
8010487c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104881:	eb f7                	jmp    8010487a <sys_fstat+0x44>
80104883:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104888:	eb f0                	jmp    8010487a <sys_fstat+0x44>

8010488a <sys_link>:
{
8010488a:	55                   	push   %ebp
8010488b:	89 e5                	mov    %esp,%ebp
8010488d:	56                   	push   %esi
8010488e:	53                   	push   %ebx
8010488f:	83 ec 28             	sub    $0x28,%esp
    if (argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104892:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104895:	50                   	push   %eax
80104896:	6a 00                	push   $0x0
80104898:	e8 93 fb ff ff       	call   80104430 <argstr>
8010489d:	83 c4 10             	add    $0x10,%esp
801048a0:	85 c0                	test   %eax,%eax
801048a2:	0f 88 26 01 00 00    	js     801049ce <sys_link+0x144>
801048a8:	83 ec 08             	sub    $0x8,%esp
801048ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801048ae:	50                   	push   %eax
801048af:	6a 01                	push   $0x1
801048b1:	e8 7a fb ff ff       	call   80104430 <argstr>
801048b6:	83 c4 10             	add    $0x10,%esp
801048b9:	85 c0                	test   %eax,%eax
801048bb:	0f 88 14 01 00 00    	js     801049d5 <sys_link+0x14b>
    begin_op();
801048c1:	e8 e7 de ff ff       	call   801027ad <begin_op>
    if ((ip = namei(old)) == 0) {
801048c6:	83 ec 0c             	sub    $0xc,%esp
801048c9:	ff 75 e0             	pushl  -0x20(%ebp)
801048cc:	e8 b2 d3 ff ff       	call   80101c83 <namei>
801048d1:	89 c3                	mov    %eax,%ebx
801048d3:	83 c4 10             	add    $0x10,%esp
801048d6:	85 c0                	test   %eax,%eax
801048d8:	0f 84 93 00 00 00    	je     80104971 <sys_link+0xe7>
    ilock(ip);
801048de:	83 ec 0c             	sub    $0xc,%esp
801048e1:	50                   	push   %eax
801048e2:	e8 ff cb ff ff       	call   801014e6 <ilock>
    if (ip->type == T_DIR) {
801048e7:	83 c4 10             	add    $0x10,%esp
801048ea:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801048ef:	0f 84 88 00 00 00    	je     8010497d <sys_link+0xf3>
    ip->nlink++;
801048f5:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(ip);
801048fa:	83 ec 0c             	sub    $0xc,%esp
801048fd:	53                   	push   %ebx
801048fe:	e8 39 cb ff ff       	call   8010143c <iupdate>
    iunlock(ip);
80104903:	89 1c 24             	mov    %ebx,(%esp)
80104906:	e8 9d cc ff ff       	call   801015a8 <iunlock>
    if ((dp = nameiparent(new, name)) == 0)
8010490b:	83 c4 08             	add    $0x8,%esp
8010490e:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104911:	50                   	push   %eax
80104912:	ff 75 e4             	pushl  -0x1c(%ebp)
80104915:	e8 81 d3 ff ff       	call   80101c9b <nameiparent>
8010491a:	89 c6                	mov    %eax,%esi
8010491c:	83 c4 10             	add    $0x10,%esp
8010491f:	85 c0                	test   %eax,%eax
80104921:	74 7e                	je     801049a1 <sys_link+0x117>
    ilock(dp);
80104923:	83 ec 0c             	sub    $0xc,%esp
80104926:	50                   	push   %eax
80104927:	e8 ba cb ff ff       	call   801014e6 <ilock>
    if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
8010492c:	83 c4 10             	add    $0x10,%esp
8010492f:	8b 03                	mov    (%ebx),%eax
80104931:	39 06                	cmp    %eax,(%esi)
80104933:	75 60                	jne    80104995 <sys_link+0x10b>
80104935:	83 ec 04             	sub    $0x4,%esp
80104938:	ff 73 04             	pushl  0x4(%ebx)
8010493b:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010493e:	50                   	push   %eax
8010493f:	56                   	push   %esi
80104940:	e8 89 d2 ff ff       	call   80101bce <dirlink>
80104945:	83 c4 10             	add    $0x10,%esp
80104948:	85 c0                	test   %eax,%eax
8010494a:	78 49                	js     80104995 <sys_link+0x10b>
    iunlockput(dp);
8010494c:	83 ec 0c             	sub    $0xc,%esp
8010494f:	56                   	push   %esi
80104950:	e8 da cd ff ff       	call   8010172f <iunlockput>
    iput(ip);
80104955:	89 1c 24             	mov    %ebx,(%esp)
80104958:	e8 90 cc ff ff       	call   801015ed <iput>
    end_op();
8010495d:	e8 c6 de ff ff       	call   80102828 <end_op>
    return 0;
80104962:	83 c4 10             	add    $0x10,%esp
80104965:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010496a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010496d:	5b                   	pop    %ebx
8010496e:	5e                   	pop    %esi
8010496f:	5d                   	pop    %ebp
80104970:	c3                   	ret    
        end_op();
80104971:	e8 b2 de ff ff       	call   80102828 <end_op>
        return -1;
80104976:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010497b:	eb ed                	jmp    8010496a <sys_link+0xe0>
        iunlockput(ip);
8010497d:	83 ec 0c             	sub    $0xc,%esp
80104980:	53                   	push   %ebx
80104981:	e8 a9 cd ff ff       	call   8010172f <iunlockput>
        end_op();
80104986:	e8 9d de ff ff       	call   80102828 <end_op>
        return -1;
8010498b:	83 c4 10             	add    $0x10,%esp
8010498e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104993:	eb d5                	jmp    8010496a <sys_link+0xe0>
        iunlockput(dp);
80104995:	83 ec 0c             	sub    $0xc,%esp
80104998:	56                   	push   %esi
80104999:	e8 91 cd ff ff       	call   8010172f <iunlockput>
        goto bad;
8010499e:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801049a1:	83 ec 0c             	sub    $0xc,%esp
801049a4:	53                   	push   %ebx
801049a5:	e8 3c cb ff ff       	call   801014e6 <ilock>
    ip->nlink--;
801049aa:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
    iupdate(ip);
801049af:	89 1c 24             	mov    %ebx,(%esp)
801049b2:	e8 85 ca ff ff       	call   8010143c <iupdate>
    iunlockput(ip);
801049b7:	89 1c 24             	mov    %ebx,(%esp)
801049ba:	e8 70 cd ff ff       	call   8010172f <iunlockput>
    end_op();
801049bf:	e8 64 de ff ff       	call   80102828 <end_op>
    return -1;
801049c4:	83 c4 10             	add    $0x10,%esp
801049c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049cc:	eb 9c                	jmp    8010496a <sys_link+0xe0>
        return -1;
801049ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049d3:	eb 95                	jmp    8010496a <sys_link+0xe0>
801049d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049da:	eb 8e                	jmp    8010496a <sys_link+0xe0>

801049dc <sys_unlink>:
{
801049dc:	55                   	push   %ebp
801049dd:	89 e5                	mov    %esp,%ebp
801049df:	57                   	push   %edi
801049e0:	56                   	push   %esi
801049e1:	53                   	push   %ebx
801049e2:	83 ec 54             	sub    $0x54,%esp
    if (argstr(0, &path) < 0)
801049e5:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801049e8:	50                   	push   %eax
801049e9:	6a 00                	push   $0x0
801049eb:	e8 40 fa ff ff       	call   80104430 <argstr>
801049f0:	83 c4 10             	add    $0x10,%esp
801049f3:	85 c0                	test   %eax,%eax
801049f5:	0f 88 81 01 00 00    	js     80104b7c <sys_unlink+0x1a0>
    begin_op();
801049fb:	e8 ad dd ff ff       	call   801027ad <begin_op>
    if ((dp = nameiparent(path, name)) == 0) {
80104a00:	83 ec 08             	sub    $0x8,%esp
80104a03:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104a06:	50                   	push   %eax
80104a07:	ff 75 c4             	pushl  -0x3c(%ebp)
80104a0a:	e8 8c d2 ff ff       	call   80101c9b <nameiparent>
80104a0f:	89 c7                	mov    %eax,%edi
80104a11:	83 c4 10             	add    $0x10,%esp
80104a14:	85 c0                	test   %eax,%eax
80104a16:	0f 84 df 00 00 00    	je     80104afb <sys_unlink+0x11f>
    ilock(dp);
80104a1c:	83 ec 0c             	sub    $0xc,%esp
80104a1f:	50                   	push   %eax
80104a20:	e8 c1 ca ff ff       	call   801014e6 <ilock>
    if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104a25:	83 c4 08             	add    $0x8,%esp
80104a28:	68 4c 70 10 80       	push   $0x8010704c
80104a2d:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104a30:	50                   	push   %eax
80104a31:	e8 61 cf ff ff       	call   80101997 <namecmp>
80104a36:	83 c4 10             	add    $0x10,%esp
80104a39:	85 c0                	test   %eax,%eax
80104a3b:	0f 84 51 01 00 00    	je     80104b92 <sys_unlink+0x1b6>
80104a41:	83 ec 08             	sub    $0x8,%esp
80104a44:	68 4b 70 10 80       	push   $0x8010704b
80104a49:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104a4c:	50                   	push   %eax
80104a4d:	e8 45 cf ff ff       	call   80101997 <namecmp>
80104a52:	83 c4 10             	add    $0x10,%esp
80104a55:	85 c0                	test   %eax,%eax
80104a57:	0f 84 35 01 00 00    	je     80104b92 <sys_unlink+0x1b6>
    if ((ip = dirlookup(dp, name, &off)) == 0)
80104a5d:	83 ec 04             	sub    $0x4,%esp
80104a60:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104a63:	50                   	push   %eax
80104a64:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104a67:	50                   	push   %eax
80104a68:	57                   	push   %edi
80104a69:	e8 3e cf ff ff       	call   801019ac <dirlookup>
80104a6e:	89 c3                	mov    %eax,%ebx
80104a70:	83 c4 10             	add    $0x10,%esp
80104a73:	85 c0                	test   %eax,%eax
80104a75:	0f 84 17 01 00 00    	je     80104b92 <sys_unlink+0x1b6>
    ilock(ip);
80104a7b:	83 ec 0c             	sub    $0xc,%esp
80104a7e:	50                   	push   %eax
80104a7f:	e8 62 ca ff ff       	call   801014e6 <ilock>
    if (ip->nlink < 1)
80104a84:	83 c4 10             	add    $0x10,%esp
80104a87:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104a8c:	7e 79                	jle    80104b07 <sys_unlink+0x12b>
    if (ip->type == T_DIR && !isdirempty(ip)) {
80104a8e:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104a93:	74 7f                	je     80104b14 <sys_unlink+0x138>
    memset(&de, 0, sizeof(de));
80104a95:	83 ec 04             	sub    $0x4,%esp
80104a98:	6a 10                	push   $0x10
80104a9a:	6a 00                	push   $0x0
80104a9c:	8d 75 d8             	lea    -0x28(%ebp),%esi
80104a9f:	56                   	push   %esi
80104aa0:	e8 7e f6 ff ff       	call   80104123 <memset>
    if (writei(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
80104aa5:	6a 10                	push   $0x10
80104aa7:	ff 75 c0             	pushl  -0x40(%ebp)
80104aaa:	56                   	push   %esi
80104aab:	57                   	push   %edi
80104aac:	e8 c5 cd ff ff       	call   80101876 <writei>
80104ab1:	83 c4 20             	add    $0x20,%esp
80104ab4:	83 f8 10             	cmp    $0x10,%eax
80104ab7:	0f 85 9c 00 00 00    	jne    80104b59 <sys_unlink+0x17d>
    if (ip->type == T_DIR) {
80104abd:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104ac2:	0f 84 9e 00 00 00    	je     80104b66 <sys_unlink+0x18a>
    iunlockput(dp);
80104ac8:	83 ec 0c             	sub    $0xc,%esp
80104acb:	57                   	push   %edi
80104acc:	e8 5e cc ff ff       	call   8010172f <iunlockput>
    ip->nlink--;
80104ad1:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
    iupdate(ip);
80104ad6:	89 1c 24             	mov    %ebx,(%esp)
80104ad9:	e8 5e c9 ff ff       	call   8010143c <iupdate>
    iunlockput(ip);
80104ade:	89 1c 24             	mov    %ebx,(%esp)
80104ae1:	e8 49 cc ff ff       	call   8010172f <iunlockput>
    end_op();
80104ae6:	e8 3d dd ff ff       	call   80102828 <end_op>
    return 0;
80104aeb:	83 c4 10             	add    $0x10,%esp
80104aee:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104af3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104af6:	5b                   	pop    %ebx
80104af7:	5e                   	pop    %esi
80104af8:	5f                   	pop    %edi
80104af9:	5d                   	pop    %ebp
80104afa:	c3                   	ret    
        end_op();
80104afb:	e8 28 dd ff ff       	call   80102828 <end_op>
        return -1;
80104b00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b05:	eb ec                	jmp    80104af3 <sys_unlink+0x117>
        panic("unlink: nlink < 1");
80104b07:	83 ec 0c             	sub    $0xc,%esp
80104b0a:	68 6a 70 10 80       	push   $0x8010706a
80104b0f:	e8 30 b8 ff ff       	call   80100344 <panic>
    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
80104b14:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
80104b18:	0f 86 77 ff ff ff    	jbe    80104a95 <sys_unlink+0xb9>
80104b1e:	be 20 00 00 00       	mov    $0x20,%esi
        if (readi(dp, (char *)&de, off, sizeof(de)) != sizeof(de))
80104b23:	6a 10                	push   $0x10
80104b25:	56                   	push   %esi
80104b26:	8d 45 b0             	lea    -0x50(%ebp),%eax
80104b29:	50                   	push   %eax
80104b2a:	53                   	push   %ebx
80104b2b:	e8 4a cc ff ff       	call   8010177a <readi>
80104b30:	83 c4 10             	add    $0x10,%esp
80104b33:	83 f8 10             	cmp    $0x10,%eax
80104b36:	75 14                	jne    80104b4c <sys_unlink+0x170>
        if (de.inum != 0)
80104b38:	66 83 7d b0 00       	cmpw   $0x0,-0x50(%ebp)
80104b3d:	75 47                	jne    80104b86 <sys_unlink+0x1aa>
    for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
80104b3f:	83 c6 10             	add    $0x10,%esi
80104b42:	3b 73 58             	cmp    0x58(%ebx),%esi
80104b45:	72 dc                	jb     80104b23 <sys_unlink+0x147>
80104b47:	e9 49 ff ff ff       	jmp    80104a95 <sys_unlink+0xb9>
            panic("isdirempty: readi");
80104b4c:	83 ec 0c             	sub    $0xc,%esp
80104b4f:	68 7c 70 10 80       	push   $0x8010707c
80104b54:	e8 eb b7 ff ff       	call   80100344 <panic>
        panic("unlink: writei");
80104b59:	83 ec 0c             	sub    $0xc,%esp
80104b5c:	68 8e 70 10 80       	push   $0x8010708e
80104b61:	e8 de b7 ff ff       	call   80100344 <panic>
        dp->nlink--;
80104b66:	66 83 6f 56 01       	subw   $0x1,0x56(%edi)
        iupdate(dp);
80104b6b:	83 ec 0c             	sub    $0xc,%esp
80104b6e:	57                   	push   %edi
80104b6f:	e8 c8 c8 ff ff       	call   8010143c <iupdate>
80104b74:	83 c4 10             	add    $0x10,%esp
80104b77:	e9 4c ff ff ff       	jmp    80104ac8 <sys_unlink+0xec>
        return -1;
80104b7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b81:	e9 6d ff ff ff       	jmp    80104af3 <sys_unlink+0x117>
        iunlockput(ip);
80104b86:	83 ec 0c             	sub    $0xc,%esp
80104b89:	53                   	push   %ebx
80104b8a:	e8 a0 cb ff ff       	call   8010172f <iunlockput>
        goto bad;
80104b8f:	83 c4 10             	add    $0x10,%esp
    iunlockput(dp);
80104b92:	83 ec 0c             	sub    $0xc,%esp
80104b95:	57                   	push   %edi
80104b96:	e8 94 cb ff ff       	call   8010172f <iunlockput>
    end_op();
80104b9b:	e8 88 dc ff ff       	call   80102828 <end_op>
    return -1;
80104ba0:	83 c4 10             	add    $0x10,%esp
80104ba3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ba8:	e9 46 ff ff ff       	jmp    80104af3 <sys_unlink+0x117>

80104bad <sys_open>:

int sys_open(void)
{
80104bad:	55                   	push   %ebp
80104bae:	89 e5                	mov    %esp,%ebp
80104bb0:	57                   	push   %edi
80104bb1:	56                   	push   %esi
80104bb2:	53                   	push   %ebx
80104bb3:	83 ec 24             	sub    $0x24,%esp
    char *path;
    int fd, omode;
    struct file *f;
    struct inode *ip;

    if (argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104bb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104bb9:	50                   	push   %eax
80104bba:	6a 00                	push   $0x0
80104bbc:	e8 6f f8 ff ff       	call   80104430 <argstr>
80104bc1:	83 c4 10             	add    $0x10,%esp
80104bc4:	85 c0                	test   %eax,%eax
80104bc6:	0f 88 0b 01 00 00    	js     80104cd7 <sys_open+0x12a>
80104bcc:	83 ec 08             	sub    $0x8,%esp
80104bcf:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104bd2:	50                   	push   %eax
80104bd3:	6a 01                	push   $0x1
80104bd5:	e8 cf f7 ff ff       	call   801043a9 <argint>
80104bda:	83 c4 10             	add    $0x10,%esp
80104bdd:	85 c0                	test   %eax,%eax
80104bdf:	0f 88 f9 00 00 00    	js     80104cde <sys_open+0x131>
        return -1;

    begin_op();
80104be5:	e8 c3 db ff ff       	call   801027ad <begin_op>

    if (omode & O_CREATE) {
80104bea:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104bee:	0f 84 8a 00 00 00    	je     80104c7e <sys_open+0xd1>
        ip = create(path, T_FILE, 0, 0);
80104bf4:	83 ec 0c             	sub    $0xc,%esp
80104bf7:	6a 00                	push   $0x0
80104bf9:	b9 00 00 00 00       	mov    $0x0,%ecx
80104bfe:	ba 02 00 00 00       	mov    $0x2,%edx
80104c03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104c06:	e8 4d f9 ff ff       	call   80104558 <create>
80104c0b:	89 c6                	mov    %eax,%esi
        if (ip == 0) {
80104c0d:	83 c4 10             	add    $0x10,%esp
80104c10:	85 c0                	test   %eax,%eax
80104c12:	74 5e                	je     80104c72 <sys_open+0xc5>
            end_op();
            return -1;
        }
    }

    if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
80104c14:	e8 61 c0 ff ff       	call   80100c7a <filealloc>
80104c19:	89 c3                	mov    %eax,%ebx
80104c1b:	85 c0                	test   %eax,%eax
80104c1d:	0f 84 ce 00 00 00    	je     80104cf1 <sys_open+0x144>
80104c23:	e8 f0 f8 ff ff       	call   80104518 <fdalloc>
80104c28:	89 c7                	mov    %eax,%edi
80104c2a:	85 c0                	test   %eax,%eax
80104c2c:	0f 88 b3 00 00 00    	js     80104ce5 <sys_open+0x138>
            fileclose(f);
        iunlockput(ip);
        end_op();
        return -1;
    }
    iunlock(ip);
80104c32:	83 ec 0c             	sub    $0xc,%esp
80104c35:	56                   	push   %esi
80104c36:	e8 6d c9 ff ff       	call   801015a8 <iunlock>
    end_op();
80104c3b:	e8 e8 db ff ff       	call   80102828 <end_op>

    f->type = FD_INODE;
80104c40:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
    f->ip = ip;
80104c46:	89 73 10             	mov    %esi,0x10(%ebx)
    f->off = 0;
80104c49:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
    f->readable = !(omode & O_WRONLY);
80104c50:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104c53:	89 d0                	mov    %edx,%eax
80104c55:	83 f0 01             	xor    $0x1,%eax
80104c58:	83 e0 01             	and    $0x1,%eax
80104c5b:	88 43 08             	mov    %al,0x8(%ebx)
    f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104c5e:	83 c4 10             	add    $0x10,%esp
80104c61:	f6 c2 03             	test   $0x3,%dl
80104c64:	0f 95 43 09          	setne  0x9(%ebx)
    return fd;
}
80104c68:	89 f8                	mov    %edi,%eax
80104c6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104c6d:	5b                   	pop    %ebx
80104c6e:	5e                   	pop    %esi
80104c6f:	5f                   	pop    %edi
80104c70:	5d                   	pop    %ebp
80104c71:	c3                   	ret    
            end_op();
80104c72:	e8 b1 db ff ff       	call   80102828 <end_op>
            return -1;
80104c77:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104c7c:	eb ea                	jmp    80104c68 <sys_open+0xbb>
        if ((ip = namei(path)) == 0) {
80104c7e:	83 ec 0c             	sub    $0xc,%esp
80104c81:	ff 75 e4             	pushl  -0x1c(%ebp)
80104c84:	e8 fa cf ff ff       	call   80101c83 <namei>
80104c89:	89 c6                	mov    %eax,%esi
80104c8b:	83 c4 10             	add    $0x10,%esp
80104c8e:	85 c0                	test   %eax,%eax
80104c90:	74 39                	je     80104ccb <sys_open+0x11e>
        ilock(ip);
80104c92:	83 ec 0c             	sub    $0xc,%esp
80104c95:	50                   	push   %eax
80104c96:	e8 4b c8 ff ff       	call   801014e6 <ilock>
        if (ip->type == T_DIR && omode != O_RDONLY) {
80104c9b:	83 c4 10             	add    $0x10,%esp
80104c9e:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104ca3:	0f 85 6b ff ff ff    	jne    80104c14 <sys_open+0x67>
80104ca9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104cad:	0f 84 61 ff ff ff    	je     80104c14 <sys_open+0x67>
            iunlockput(ip);
80104cb3:	83 ec 0c             	sub    $0xc,%esp
80104cb6:	56                   	push   %esi
80104cb7:	e8 73 ca ff ff       	call   8010172f <iunlockput>
            end_op();
80104cbc:	e8 67 db ff ff       	call   80102828 <end_op>
            return -1;
80104cc1:	83 c4 10             	add    $0x10,%esp
80104cc4:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104cc9:	eb 9d                	jmp    80104c68 <sys_open+0xbb>
            end_op();
80104ccb:	e8 58 db ff ff       	call   80102828 <end_op>
            return -1;
80104cd0:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104cd5:	eb 91                	jmp    80104c68 <sys_open+0xbb>
        return -1;
80104cd7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104cdc:	eb 8a                	jmp    80104c68 <sys_open+0xbb>
80104cde:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104ce3:	eb 83                	jmp    80104c68 <sys_open+0xbb>
            fileclose(f);
80104ce5:	83 ec 0c             	sub    $0xc,%esp
80104ce8:	53                   	push   %ebx
80104ce9:	e8 3e c0 ff ff       	call   80100d2c <fileclose>
80104cee:	83 c4 10             	add    $0x10,%esp
        iunlockput(ip);
80104cf1:	83 ec 0c             	sub    $0xc,%esp
80104cf4:	56                   	push   %esi
80104cf5:	e8 35 ca ff ff       	call   8010172f <iunlockput>
        end_op();
80104cfa:	e8 29 db ff ff       	call   80102828 <end_op>
        return -1;
80104cff:	83 c4 10             	add    $0x10,%esp
80104d02:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104d07:	e9 5c ff ff ff       	jmp    80104c68 <sys_open+0xbb>

80104d0c <sys_mkdir>:

int sys_mkdir(void)
{
80104d0c:	55                   	push   %ebp
80104d0d:	89 e5                	mov    %esp,%ebp
80104d0f:	83 ec 18             	sub    $0x18,%esp
    char *path;
    struct inode *ip;

    begin_op();
80104d12:	e8 96 da ff ff       	call   801027ad <begin_op>
    if (argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
80104d17:	83 ec 08             	sub    $0x8,%esp
80104d1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d1d:	50                   	push   %eax
80104d1e:	6a 00                	push   $0x0
80104d20:	e8 0b f7 ff ff       	call   80104430 <argstr>
80104d25:	83 c4 10             	add    $0x10,%esp
80104d28:	85 c0                	test   %eax,%eax
80104d2a:	78 36                	js     80104d62 <sys_mkdir+0x56>
80104d2c:	83 ec 0c             	sub    $0xc,%esp
80104d2f:	6a 00                	push   $0x0
80104d31:	b9 00 00 00 00       	mov    $0x0,%ecx
80104d36:	ba 01 00 00 00       	mov    $0x1,%edx
80104d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3e:	e8 15 f8 ff ff       	call   80104558 <create>
80104d43:	83 c4 10             	add    $0x10,%esp
80104d46:	85 c0                	test   %eax,%eax
80104d48:	74 18                	je     80104d62 <sys_mkdir+0x56>
        end_op();
        return -1;
    }
    iunlockput(ip);
80104d4a:	83 ec 0c             	sub    $0xc,%esp
80104d4d:	50                   	push   %eax
80104d4e:	e8 dc c9 ff ff       	call   8010172f <iunlockput>
    end_op();
80104d53:	e8 d0 da ff ff       	call   80102828 <end_op>
    return 0;
80104d58:	83 c4 10             	add    $0x10,%esp
80104d5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d60:	c9                   	leave  
80104d61:	c3                   	ret    
        end_op();
80104d62:	e8 c1 da ff ff       	call   80102828 <end_op>
        return -1;
80104d67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d6c:	eb f2                	jmp    80104d60 <sys_mkdir+0x54>

80104d6e <sys_mknod>:

int sys_mknod(void)
{
80104d6e:	55                   	push   %ebp
80104d6f:	89 e5                	mov    %esp,%ebp
80104d71:	83 ec 18             	sub    $0x18,%esp
    struct inode *ip;
    char *path;
    int major, minor;

    begin_op();
80104d74:	e8 34 da ff ff       	call   801027ad <begin_op>
    if ((argstr(0, &path)) < 0 || argint(1, &major) < 0 ||
80104d79:	83 ec 08             	sub    $0x8,%esp
80104d7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d7f:	50                   	push   %eax
80104d80:	6a 00                	push   $0x0
80104d82:	e8 a9 f6 ff ff       	call   80104430 <argstr>
80104d87:	83 c4 10             	add    $0x10,%esp
80104d8a:	85 c0                	test   %eax,%eax
80104d8c:	78 62                	js     80104df0 <sys_mknod+0x82>
80104d8e:	83 ec 08             	sub    $0x8,%esp
80104d91:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d94:	50                   	push   %eax
80104d95:	6a 01                	push   $0x1
80104d97:	e8 0d f6 ff ff       	call   801043a9 <argint>
80104d9c:	83 c4 10             	add    $0x10,%esp
80104d9f:	85 c0                	test   %eax,%eax
80104da1:	78 4d                	js     80104df0 <sys_mknod+0x82>
        argint(2, &minor) < 0 ||
80104da3:	83 ec 08             	sub    $0x8,%esp
80104da6:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104da9:	50                   	push   %eax
80104daa:	6a 02                	push   $0x2
80104dac:	e8 f8 f5 ff ff       	call   801043a9 <argint>
    if ((argstr(0, &path)) < 0 || argint(1, &major) < 0 ||
80104db1:	83 c4 10             	add    $0x10,%esp
80104db4:	85 c0                	test   %eax,%eax
80104db6:	78 38                	js     80104df0 <sys_mknod+0x82>
        (ip = create(path, T_DEV, major, minor)) == 0) {
80104db8:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
        argint(2, &minor) < 0 ||
80104dbc:	83 ec 0c             	sub    $0xc,%esp
        (ip = create(path, T_DEV, major, minor)) == 0) {
80104dbf:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
        argint(2, &minor) < 0 ||
80104dc3:	50                   	push   %eax
80104dc4:	ba 03 00 00 00       	mov    $0x3,%edx
80104dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dcc:	e8 87 f7 ff ff       	call   80104558 <create>
80104dd1:	83 c4 10             	add    $0x10,%esp
80104dd4:	85 c0                	test   %eax,%eax
80104dd6:	74 18                	je     80104df0 <sys_mknod+0x82>
        end_op();
        return -1;
    }
    iunlockput(ip);
80104dd8:	83 ec 0c             	sub    $0xc,%esp
80104ddb:	50                   	push   %eax
80104ddc:	e8 4e c9 ff ff       	call   8010172f <iunlockput>
    end_op();
80104de1:	e8 42 da ff ff       	call   80102828 <end_op>
    return 0;
80104de6:	83 c4 10             	add    $0x10,%esp
80104de9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104dee:	c9                   	leave  
80104def:	c3                   	ret    
        end_op();
80104df0:	e8 33 da ff ff       	call   80102828 <end_op>
        return -1;
80104df5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dfa:	eb f2                	jmp    80104dee <sys_mknod+0x80>

80104dfc <sys_chdir>:

int sys_chdir(void)
{
80104dfc:	55                   	push   %ebp
80104dfd:	89 e5                	mov    %esp,%ebp
80104dff:	56                   	push   %esi
80104e00:	53                   	push   %ebx
80104e01:	83 ec 10             	sub    $0x10,%esp
    char *path;
    struct inode *ip;
    struct proc *curproc = myproc();
80104e04:	e8 c2 e6 ff ff       	call   801034cb <myproc>
80104e09:	89 c6                	mov    %eax,%esi

    begin_op();
80104e0b:	e8 9d d9 ff ff       	call   801027ad <begin_op>
    if (argstr(0, &path) < 0 || (ip = namei(path)) == 0) {
80104e10:	83 ec 08             	sub    $0x8,%esp
80104e13:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e16:	50                   	push   %eax
80104e17:	6a 00                	push   $0x0
80104e19:	e8 12 f6 ff ff       	call   80104430 <argstr>
80104e1e:	83 c4 10             	add    $0x10,%esp
80104e21:	85 c0                	test   %eax,%eax
80104e23:	78 52                	js     80104e77 <sys_chdir+0x7b>
80104e25:	83 ec 0c             	sub    $0xc,%esp
80104e28:	ff 75 f4             	pushl  -0xc(%ebp)
80104e2b:	e8 53 ce ff ff       	call   80101c83 <namei>
80104e30:	89 c3                	mov    %eax,%ebx
80104e32:	83 c4 10             	add    $0x10,%esp
80104e35:	85 c0                	test   %eax,%eax
80104e37:	74 3e                	je     80104e77 <sys_chdir+0x7b>
        end_op();
        return -1;
    }
    ilock(ip);
80104e39:	83 ec 0c             	sub    $0xc,%esp
80104e3c:	50                   	push   %eax
80104e3d:	e8 a4 c6 ff ff       	call   801014e6 <ilock>
    if (ip->type != T_DIR) {
80104e42:	83 c4 10             	add    $0x10,%esp
80104e45:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104e4a:	75 37                	jne    80104e83 <sys_chdir+0x87>
        iunlockput(ip);
        end_op();
        return -1;
    }
    iunlock(ip);
80104e4c:	83 ec 0c             	sub    $0xc,%esp
80104e4f:	53                   	push   %ebx
80104e50:	e8 53 c7 ff ff       	call   801015a8 <iunlock>
    iput(curproc->cwd);
80104e55:	83 c4 04             	add    $0x4,%esp
80104e58:	ff 76 68             	pushl  0x68(%esi)
80104e5b:	e8 8d c7 ff ff       	call   801015ed <iput>
    end_op();
80104e60:	e8 c3 d9 ff ff       	call   80102828 <end_op>
    curproc->cwd = ip;
80104e65:	89 5e 68             	mov    %ebx,0x68(%esi)
    return 0;
80104e68:	83 c4 10             	add    $0x10,%esp
80104e6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e70:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104e73:	5b                   	pop    %ebx
80104e74:	5e                   	pop    %esi
80104e75:	5d                   	pop    %ebp
80104e76:	c3                   	ret    
        end_op();
80104e77:	e8 ac d9 ff ff       	call   80102828 <end_op>
        return -1;
80104e7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e81:	eb ed                	jmp    80104e70 <sys_chdir+0x74>
        iunlockput(ip);
80104e83:	83 ec 0c             	sub    $0xc,%esp
80104e86:	53                   	push   %ebx
80104e87:	e8 a3 c8 ff ff       	call   8010172f <iunlockput>
        end_op();
80104e8c:	e8 97 d9 ff ff       	call   80102828 <end_op>
        return -1;
80104e91:	83 c4 10             	add    $0x10,%esp
80104e94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e99:	eb d5                	jmp    80104e70 <sys_chdir+0x74>

80104e9b <sys_exec>:

int sys_exec(void)
{
80104e9b:	55                   	push   %ebp
80104e9c:	89 e5                	mov    %esp,%ebp
80104e9e:	57                   	push   %edi
80104e9f:	56                   	push   %esi
80104ea0:	53                   	push   %ebx
80104ea1:	81 ec a4 00 00 00    	sub    $0xa4,%esp
    char *path, *argv[MAXARG];
    int i;
    uint uargv, uarg;

    if (argstr(0, &path) < 0 || argint(1, (int *)&uargv) < 0) {
80104ea7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104eaa:	50                   	push   %eax
80104eab:	6a 00                	push   $0x0
80104ead:	e8 7e f5 ff ff       	call   80104430 <argstr>
80104eb2:	83 c4 10             	add    $0x10,%esp
80104eb5:	85 c0                	test   %eax,%eax
80104eb7:	0f 88 b4 00 00 00    	js     80104f71 <sys_exec+0xd6>
80104ebd:	83 ec 08             	sub    $0x8,%esp
80104ec0:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80104ec6:	50                   	push   %eax
80104ec7:	6a 01                	push   $0x1
80104ec9:	e8 db f4 ff ff       	call   801043a9 <argint>
80104ece:	83 c4 10             	add    $0x10,%esp
80104ed1:	85 c0                	test   %eax,%eax
80104ed3:	0f 88 9f 00 00 00    	js     80104f78 <sys_exec+0xdd>
        return -1;
    }
    memset(argv, 0, sizeof(argv));
80104ed9:	83 ec 04             	sub    $0x4,%esp
80104edc:	68 80 00 00 00       	push   $0x80
80104ee1:	6a 00                	push   $0x0
80104ee3:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80104ee9:	50                   	push   %eax
80104eea:	e8 34 f2 ff ff       	call   80104123 <memset>
80104eef:	83 c4 10             	add    $0x10,%esp
    for (i = 0;; i++) {
80104ef2:	be 00 00 00 00       	mov    $0x0,%esi
        if (i >= NELEM(argv))
            return -1;
        if (fetchint(uargv + 4 * i, (int *)&uarg) < 0)
80104ef7:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
80104efd:	8d 1c b5 00 00 00 00 	lea    0x0(,%esi,4),%ebx
80104f04:	83 ec 08             	sub    $0x8,%esp
80104f07:	57                   	push   %edi
80104f08:	89 d8                	mov    %ebx,%eax
80104f0a:	03 85 60 ff ff ff    	add    -0xa0(%ebp),%eax
80104f10:	50                   	push   %eax
80104f11:	e8 07 f4 ff ff       	call   8010431d <fetchint>
80104f16:	83 c4 10             	add    $0x10,%esp
80104f19:	85 c0                	test   %eax,%eax
80104f1b:	78 62                	js     80104f7f <sys_exec+0xe4>
            return -1;
        if (uarg == 0) {
80104f1d:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
80104f23:	85 c0                	test   %eax,%eax
80104f25:	74 28                	je     80104f4f <sys_exec+0xb4>
            argv[i] = 0;
            break;
        }
        if (fetchstr(uarg, &argv[i]) < 0)
80104f27:	83 ec 08             	sub    $0x8,%esp
80104f2a:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
80104f30:	01 d3                	add    %edx,%ebx
80104f32:	53                   	push   %ebx
80104f33:	50                   	push   %eax
80104f34:	e8 20 f4 ff ff       	call   80104359 <fetchstr>
80104f39:	83 c4 10             	add    $0x10,%esp
80104f3c:	85 c0                	test   %eax,%eax
80104f3e:	78 4c                	js     80104f8c <sys_exec+0xf1>
    for (i = 0;; i++) {
80104f40:	83 c6 01             	add    $0x1,%esi
        if (i >= NELEM(argv))
80104f43:	83 fe 20             	cmp    $0x20,%esi
80104f46:	75 b5                	jne    80104efd <sys_exec+0x62>
            return -1;
80104f48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f4d:	eb 35                	jmp    80104f84 <sys_exec+0xe9>
            argv[i] = 0;
80104f4f:	c7 84 b5 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%esi,4)
80104f56:	00 00 00 00 
            return -1;
    }
    return exec(path, argv);
80104f5a:	83 ec 08             	sub    $0x8,%esp
80104f5d:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80104f63:	50                   	push   %eax
80104f64:	ff 75 e4             	pushl  -0x1c(%ebp)
80104f67:	e8 a6 b9 ff ff       	call   80100912 <exec>
80104f6c:	83 c4 10             	add    $0x10,%esp
80104f6f:	eb 13                	jmp    80104f84 <sys_exec+0xe9>
        return -1;
80104f71:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f76:	eb 0c                	jmp    80104f84 <sys_exec+0xe9>
80104f78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f7d:	eb 05                	jmp    80104f84 <sys_exec+0xe9>
            return -1;
80104f7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f84:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f87:	5b                   	pop    %ebx
80104f88:	5e                   	pop    %esi
80104f89:	5f                   	pop    %edi
80104f8a:	5d                   	pop    %ebp
80104f8b:	c3                   	ret    
            return -1;
80104f8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f91:	eb f1                	jmp    80104f84 <sys_exec+0xe9>

80104f93 <sys_pipe>:

int sys_pipe(void)
{
80104f93:	55                   	push   %ebp
80104f94:	89 e5                	mov    %esp,%ebp
80104f96:	53                   	push   %ebx
80104f97:	83 ec 18             	sub    $0x18,%esp
    int *fd;
    struct file *rf, *wf;
    int fd0, fd1;

    if (argptr(0, (void *)&fd, 2 * sizeof(fd[0])) < 0)
80104f9a:	6a 08                	push   $0x8
80104f9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f9f:	50                   	push   %eax
80104fa0:	6a 00                	push   $0x0
80104fa2:	e8 28 f4 ff ff       	call   801043cf <argptr>
80104fa7:	83 c4 10             	add    $0x10,%esp
80104faa:	85 c0                	test   %eax,%eax
80104fac:	78 46                	js     80104ff4 <sys_pipe+0x61>
        return -1;
    if (pipealloc(&rf, &wf) < 0)
80104fae:	83 ec 08             	sub    $0x8,%esp
80104fb1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104fb4:	50                   	push   %eax
80104fb5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fb8:	50                   	push   %eax
80104fb9:	e8 5d df ff ff       	call   80102f1b <pipealloc>
80104fbe:	83 c4 10             	add    $0x10,%esp
80104fc1:	85 c0                	test   %eax,%eax
80104fc3:	78 36                	js     80104ffb <sys_pipe+0x68>
        return -1;
    fd0 = -1;
    if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
80104fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc8:	e8 4b f5 ff ff       	call   80104518 <fdalloc>
80104fcd:	89 c3                	mov    %eax,%ebx
80104fcf:	85 c0                	test   %eax,%eax
80104fd1:	78 3c                	js     8010500f <sys_pipe+0x7c>
80104fd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104fd6:	e8 3d f5 ff ff       	call   80104518 <fdalloc>
80104fdb:	85 c0                	test   %eax,%eax
80104fdd:	78 23                	js     80105002 <sys_pipe+0x6f>
            myproc()->ofile[fd0] = 0;
        fileclose(rf);
        fileclose(wf);
        return -1;
    }
    fd[0] = fd0;
80104fdf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fe2:	89 1a                	mov    %ebx,(%edx)
    fd[1] = fd1;
80104fe4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fe7:	89 42 04             	mov    %eax,0x4(%edx)
    return 0;
80104fea:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ff2:	c9                   	leave  
80104ff3:	c3                   	ret    
        return -1;
80104ff4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ff9:	eb f4                	jmp    80104fef <sys_pipe+0x5c>
        return -1;
80104ffb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105000:	eb ed                	jmp    80104fef <sys_pipe+0x5c>
            myproc()->ofile[fd0] = 0;
80105002:	e8 c4 e4 ff ff       	call   801034cb <myproc>
80105007:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
8010500e:	00 
        fileclose(rf);
8010500f:	83 ec 0c             	sub    $0xc,%esp
80105012:	ff 75 f0             	pushl  -0x10(%ebp)
80105015:	e8 12 bd ff ff       	call   80100d2c <fileclose>
        fileclose(wf);
8010501a:	83 c4 04             	add    $0x4,%esp
8010501d:	ff 75 ec             	pushl  -0x14(%ebp)
80105020:	e8 07 bd ff ff       	call   80100d2c <fileclose>
        return -1;
80105025:	83 c4 10             	add    $0x10,%esp
80105028:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010502d:	eb c0                	jmp    80104fef <sys_pipe+0x5c>

8010502f <sys_fork>:
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"

int sys_fork(void)
{
8010502f:	55                   	push   %ebp
80105030:	89 e5                	mov    %esp,%ebp
80105032:	83 ec 08             	sub    $0x8,%esp
    return fork();
80105035:	e8 9d e7 ff ff       	call   801037d7 <fork>
}
8010503a:	c9                   	leave  
8010503b:	c3                   	ret    

8010503c <sys_exit>:

int sys_exit(void)
{
8010503c:	55                   	push   %ebp
8010503d:	89 e5                	mov    %esp,%ebp
8010503f:	83 ec 08             	sub    $0x8,%esp
    exit();
80105042:	e8 fc e8 ff ff       	call   80103943 <exit>
    return 0; // not reached
}
80105047:	b8 00 00 00 00       	mov    $0x0,%eax
8010504c:	c9                   	leave  
8010504d:	c3                   	ret    

8010504e <sys_wait>:

int sys_wait(void)
{
8010504e:	55                   	push   %ebp
8010504f:	89 e5                	mov    %esp,%ebp
80105051:	83 ec 08             	sub    $0x8,%esp
    return wait();
80105054:	e8 24 eb ff ff       	call   80103b7d <wait>
}
80105059:	c9                   	leave  
8010505a:	c3                   	ret    

8010505b <sys_kill>:

int sys_kill(void)
{
8010505b:	55                   	push   %ebp
8010505c:	89 e5                	mov    %esp,%ebp
8010505e:	83 ec 20             	sub    $0x20,%esp
    int pid;

    if (argint(0, &pid) < 0)
80105061:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105064:	50                   	push   %eax
80105065:	6a 00                	push   $0x0
80105067:	e8 3d f3 ff ff       	call   801043a9 <argint>
8010506c:	83 c4 10             	add    $0x10,%esp
8010506f:	85 c0                	test   %eax,%eax
80105071:	78 10                	js     80105083 <sys_kill+0x28>
        return -1;
    return kill(pid);
80105073:	83 ec 0c             	sub    $0xc,%esp
80105076:	ff 75 f4             	pushl  -0xc(%ebp)
80105079:	e8 06 ec ff ff       	call   80103c84 <kill>
8010507e:	83 c4 10             	add    $0x10,%esp
}
80105081:	c9                   	leave  
80105082:	c3                   	ret    
        return -1;
80105083:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105088:	eb f7                	jmp    80105081 <sys_kill+0x26>

8010508a <sys_getpid>:

int sys_getpid(void)
{
8010508a:	55                   	push   %ebp
8010508b:	89 e5                	mov    %esp,%ebp
8010508d:	83 ec 08             	sub    $0x8,%esp
    return myproc()->pid;
80105090:	e8 36 e4 ff ff       	call   801034cb <myproc>
80105095:	8b 40 10             	mov    0x10(%eax),%eax
}
80105098:	c9                   	leave  
80105099:	c3                   	ret    

8010509a <sys_sbrk>:

int sys_sbrk(void)
{
8010509a:	55                   	push   %ebp
8010509b:	89 e5                	mov    %esp,%ebp
8010509d:	53                   	push   %ebx
8010509e:	83 ec 1c             	sub    $0x1c,%esp
    int addr;
    int n;

    if (argint(0, &n) < 0)
801050a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050a4:	50                   	push   %eax
801050a5:	6a 00                	push   $0x0
801050a7:	e8 fd f2 ff ff       	call   801043a9 <argint>
801050ac:	83 c4 10             	add    $0x10,%esp
801050af:	85 c0                	test   %eax,%eax
801050b1:	78 26                	js     801050d9 <sys_sbrk+0x3f>
        return -1;
    addr = myproc()->sz;
801050b3:	e8 13 e4 ff ff       	call   801034cb <myproc>
801050b8:	8b 18                	mov    (%eax),%ebx
    if (growproc(n) < 0)
801050ba:	83 ec 0c             	sub    $0xc,%esp
801050bd:	ff 75 f4             	pushl  -0xc(%ebp)
801050c0:	e8 3b e5 ff ff       	call   80103600 <growproc>
801050c5:	83 c4 10             	add    $0x10,%esp
801050c8:	85 c0                	test   %eax,%eax
        return -1;
801050ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050cf:	0f 48 d8             	cmovs  %eax,%ebx
    return addr;
}
801050d2:	89 d8                	mov    %ebx,%eax
801050d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801050d7:	c9                   	leave  
801050d8:	c3                   	ret    
        return -1;
801050d9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801050de:	eb f2                	jmp    801050d2 <sys_sbrk+0x38>

801050e0 <sys_sleep>:

int sys_sleep(void)
{
801050e0:	55                   	push   %ebp
801050e1:	89 e5                	mov    %esp,%ebp
801050e3:	53                   	push   %ebx
801050e4:	83 ec 1c             	sub    $0x1c,%esp
    int n;
    uint ticks0;

    if (argint(0, &n) < 0)
801050e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801050ea:	50                   	push   %eax
801050eb:	6a 00                	push   $0x0
801050ed:	e8 b7 f2 ff ff       	call   801043a9 <argint>
801050f2:	83 c4 10             	add    $0x10,%esp
801050f5:	85 c0                	test   %eax,%eax
801050f7:	78 79                	js     80105172 <sys_sleep+0x92>
        return -1;
    acquire(&tickslock);
801050f9:	83 ec 0c             	sub    $0xc,%esp
801050fc:	68 60 52 11 80       	push   $0x80115260
80105101:	e8 6f ef ff ff       	call   80104075 <acquire>
    ticks0 = ticks;
80105106:	8b 1d a0 5a 11 80    	mov    0x80115aa0,%ebx
    while (ticks - ticks0 < n) {
8010510c:	83 c4 10             	add    $0x10,%esp
8010510f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105113:	74 2c                	je     80105141 <sys_sleep+0x61>
        if (myproc()->killed) {
80105115:	e8 b1 e3 ff ff       	call   801034cb <myproc>
8010511a:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010511e:	75 3b                	jne    8010515b <sys_sleep+0x7b>
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
80105120:	83 ec 08             	sub    $0x8,%esp
80105123:	68 60 52 11 80       	push   $0x80115260
80105128:	68 a0 5a 11 80       	push   $0x80115aa0
8010512d:	e8 51 e9 ff ff       	call   80103a83 <sleep>
    while (ticks - ticks0 < n) {
80105132:	a1 a0 5a 11 80       	mov    0x80115aa0,%eax
80105137:	29 d8                	sub    %ebx,%eax
80105139:	83 c4 10             	add    $0x10,%esp
8010513c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010513f:	72 d4                	jb     80105115 <sys_sleep+0x35>
    }
    release(&tickslock);
80105141:	83 ec 0c             	sub    $0xc,%esp
80105144:	68 60 52 11 80       	push   $0x80115260
80105149:	e8 8e ef ff ff       	call   801040dc <release>
    return 0;
8010514e:	83 c4 10             	add    $0x10,%esp
80105151:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105156:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105159:	c9                   	leave  
8010515a:	c3                   	ret    
            release(&tickslock);
8010515b:	83 ec 0c             	sub    $0xc,%esp
8010515e:	68 60 52 11 80       	push   $0x80115260
80105163:	e8 74 ef ff ff       	call   801040dc <release>
            return -1;
80105168:	83 c4 10             	add    $0x10,%esp
8010516b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105170:	eb e4                	jmp    80105156 <sys_sleep+0x76>
        return -1;
80105172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105177:	eb dd                	jmp    80105156 <sys_sleep+0x76>

80105179 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int sys_uptime(void)
{
80105179:	55                   	push   %ebp
8010517a:	89 e5                	mov    %esp,%ebp
8010517c:	53                   	push   %ebx
8010517d:	83 ec 10             	sub    $0x10,%esp
    uint xticks;

    acquire(&tickslock);
80105180:	68 60 52 11 80       	push   $0x80115260
80105185:	e8 eb ee ff ff       	call   80104075 <acquire>
    xticks = ticks;
8010518a:	8b 1d a0 5a 11 80    	mov    0x80115aa0,%ebx
    release(&tickslock);
80105190:	c7 04 24 60 52 11 80 	movl   $0x80115260,(%esp)
80105197:	e8 40 ef ff ff       	call   801040dc <release>
    return xticks;
}
8010519c:	89 d8                	mov    %ebx,%eax
8010519e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801051a1:	c9                   	leave  
801051a2:	c3                   	ret    

801051a3 <sys_getlevel>:

int sys_getlevel(void)
{
801051a3:	55                   	push   %ebp
801051a4:	89 e5                	mov    %esp,%ebp
801051a6:	83 ec 08             	sub    $0x8,%esp
    return getlevel();
801051a9:	e8 3e ec ff ff       	call   80103dec <getlevel>
801051ae:	c9                   	leave  
801051af:	c3                   	ret    

801051b0 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801051b0:	1e                   	push   %ds
  pushl %es
801051b1:	06                   	push   %es
  pushl %fs
801051b2:	0f a0                	push   %fs
  pushl %gs
801051b4:	0f a8                	push   %gs
  pushal
801051b6:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801051b7:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801051bb:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801051bd:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801051bf:	54                   	push   %esp
  call trap
801051c0:	e8 bd 00 00 00       	call   80105282 <trap>
  addl $4, %esp
801051c5:	83 c4 04             	add    $0x4,%esp

801051c8 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801051c8:	61                   	popa   
  popl %gs
801051c9:	0f a9                	pop    %gs
  popl %fs
801051cb:	0f a1                	pop    %fs
  popl %es
801051cd:	07                   	pop    %es
  popl %ds
801051ce:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801051cf:	83 c4 08             	add    $0x8,%esp
  iret
801051d2:	cf                   	iret   

801051d3 <tvinit>:
extern uint vectors[]; // in vectors.S: array of 256 entry pointers
struct spinlock tickslock;
uint ticks;

void tvinit(void)
{
801051d3:	55                   	push   %ebp
801051d4:	89 e5                	mov    %esp,%ebp
801051d6:	83 ec 08             	sub    $0x8,%esp
    int i;

    for (i = 0; i < 256; i++)
801051d9:	b8 00 00 00 00       	mov    $0x0,%eax
        SETGATE(idt[i], 0, SEG_KCODE << 3, vectors[i], 0);
801051de:	8b 14 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%edx
801051e5:	66 89 14 c5 a0 52 11 	mov    %dx,-0x7feead60(,%eax,8)
801051ec:	80 
801051ed:	66 c7 04 c5 a2 52 11 	movw   $0x8,-0x7feead5e(,%eax,8)
801051f4:	80 08 00 
801051f7:	c6 04 c5 a4 52 11 80 	movb   $0x0,-0x7feead5c(,%eax,8)
801051fe:	00 
801051ff:	c6 04 c5 a5 52 11 80 	movb   $0x8e,-0x7feead5b(,%eax,8)
80105206:	8e 
80105207:	c1 ea 10             	shr    $0x10,%edx
8010520a:	66 89 14 c5 a6 52 11 	mov    %dx,-0x7feead5a(,%eax,8)
80105211:	80 
    for (i = 0; i < 256; i++)
80105212:	83 c0 01             	add    $0x1,%eax
80105215:	3d 00 01 00 00       	cmp    $0x100,%eax
8010521a:	75 c2                	jne    801051de <tvinit+0xb>
    SETGATE(idt[T_SYSCALL], 1, SEG_KCODE << 3, vectors[T_SYSCALL], DPL_USER);
8010521c:	a1 08 a1 10 80       	mov    0x8010a108,%eax
80105221:	66 a3 a0 54 11 80    	mov    %ax,0x801154a0
80105227:	66 c7 05 a2 54 11 80 	movw   $0x8,0x801154a2
8010522e:	08 00 
80105230:	c6 05 a4 54 11 80 00 	movb   $0x0,0x801154a4
80105237:	c6 05 a5 54 11 80 ef 	movb   $0xef,0x801154a5
8010523e:	c1 e8 10             	shr    $0x10,%eax
80105241:	66 a3 a6 54 11 80    	mov    %ax,0x801154a6

    initlock(&tickslock, "time");
80105247:	83 ec 08             	sub    $0x8,%esp
8010524a:	68 9d 70 10 80       	push   $0x8010709d
8010524f:	68 60 52 11 80       	push   $0x80115260
80105254:	e8 d4 ec ff ff       	call   80103f2d <initlock>
}
80105259:	83 c4 10             	add    $0x10,%esp
8010525c:	c9                   	leave  
8010525d:	c3                   	ret    

8010525e <idtinit>:

void idtinit(void)
{
8010525e:	55                   	push   %ebp
8010525f:	89 e5                	mov    %esp,%ebp
80105261:	83 ec 10             	sub    $0x10,%esp
    pd[0] = size - 1;
80105264:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
    pd[1] = (uint)p;
8010526a:	b8 a0 52 11 80       	mov    $0x801152a0,%eax
8010526f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    pd[2] = (uint)p >> 16;
80105273:	c1 e8 10             	shr    $0x10,%eax
80105276:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
    asm volatile("lidt (%0)" : : "r"(pd));
8010527a:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010527d:	0f 01 18             	lidtl  (%eax)
    lidt(idt, sizeof(idt));
}
80105280:	c9                   	leave  
80105281:	c3                   	ret    

80105282 <trap>:

// PAGEBREAK: 41
void trap(struct trapframe *tf)
{
80105282:	55                   	push   %ebp
80105283:	89 e5                	mov    %esp,%ebp
80105285:	57                   	push   %edi
80105286:	56                   	push   %esi
80105287:	53                   	push   %ebx
80105288:	83 ec 1c             	sub    $0x1c,%esp
8010528b:	8b 7d 08             	mov    0x8(%ebp),%edi
    if (tf->trapno == T_SYSCALL) {
8010528e:	8b 47 30             	mov    0x30(%edi),%eax
80105291:	83 f8 40             	cmp    $0x40,%eax
80105294:	74 13                	je     801052a9 <trap+0x27>
        if (myproc()->killed)
            exit();
        return;
    }

    switch (tf->trapno) {
80105296:	83 e8 20             	sub    $0x20,%eax
80105299:	83 f8 1f             	cmp    $0x1f,%eax
8010529c:	0f 87 6b 01 00 00    	ja     8010540d <trap+0x18b>
801052a2:	ff 24 85 44 71 10 80 	jmp    *-0x7fef8ebc(,%eax,4)
        if (myproc()->killed)
801052a9:	e8 1d e2 ff ff       	call   801034cb <myproc>
801052ae:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801052b2:	75 26                	jne    801052da <trap+0x58>
        myproc()->tf = tf;
801052b4:	e8 12 e2 ff ff       	call   801034cb <myproc>
801052b9:	89 78 18             	mov    %edi,0x18(%eax)
        syscall();
801052bc:	e8 a2 f1 ff ff       	call   80104463 <syscall>
        if (myproc()->killed)
801052c1:	e8 05 e2 ff ff       	call   801034cb <myproc>
801052c6:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801052ca:	0f 84 9d 00 00 00    	je     8010536d <trap+0xeb>
            exit();
801052d0:	e8 6e e6 ff ff       	call   80103943 <exit>
801052d5:	e9 93 00 00 00       	jmp    8010536d <trap+0xeb>
            exit();
801052da:	e8 64 e6 ff ff       	call   80103943 <exit>
801052df:	eb d3                	jmp    801052b4 <trap+0x32>
    case T_IRQ0 + IRQ_TIMER:
        if (cpuid() == 0) {
801052e1:	e8 ca e1 ff ff       	call   801034b0 <cpuid>
801052e6:	85 c0                	test   %eax,%eax
801052e8:	0f 84 87 00 00 00    	je     80105375 <trap+0xf3>
            ticks++;
            wakeup(&ticks);
            release(&tickslock);
        }
        
        if (myproc() && myproc()->state == RUNNING) {
801052ee:	e8 d8 e1 ff ff       	call   801034cb <myproc>
801052f3:	85 c0                	test   %eax,%eax
801052f5:	74 0f                	je     80105306 <trap+0x84>
801052f7:	e8 cf e1 ff ff       	call   801034cb <myproc>
801052fc:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105300:	0f 84 a3 00 00 00    	je     801053a9 <trap+0x127>
            myproc()->proc_tick++;
        }

        lapiceoi();
80105306:	e8 4f d1 ff ff       	call   8010245a <lapiceoi>
    }

    // Force process exit if it has been killed and is in user space.
    // (If it is still executing in the kernel, let it keep running
    // until it gets to the regular system call return.)
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
8010530b:	e8 bb e1 ff ff       	call   801034cb <myproc>
80105310:	85 c0                	test   %eax,%eax
80105312:	74 1c                	je     80105330 <trap+0xae>
80105314:	e8 b2 e1 ff ff       	call   801034cb <myproc>
80105319:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010531d:	74 11                	je     80105330 <trap+0xae>
8010531f:	0f b7 47 3c          	movzwl 0x3c(%edi),%eax
80105323:	83 e0 03             	and    $0x3,%eax
80105326:	66 83 f8 03          	cmp    $0x3,%ax
8010532a:	0f 84 71 01 00 00    	je     801054a1 <trap+0x21f>
        exit();

    // Force process to give up CPU on clock tick.
    // If interrupts were on while locks held, would need to check nlock.
    if (myproc() && myproc()->state == RUNNING &&
80105330:	e8 96 e1 ff ff       	call   801034cb <myproc>
80105335:	85 c0                	test   %eax,%eax
80105337:	74 0f                	je     80105348 <trap+0xc6>
80105339:	e8 8d e1 ff ff       	call   801034cb <myproc>
8010533e:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105342:	0f 84 63 01 00 00    	je     801054ab <trap+0x229>
            // myproc()->proc_tick = 0;



    // Check if the process has been killed since we yielded
    if (myproc() && myproc()->killed && (tf->cs & 3) == DPL_USER)
80105348:	e8 7e e1 ff ff       	call   801034cb <myproc>
8010534d:	85 c0                	test   %eax,%eax
8010534f:	74 1c                	je     8010536d <trap+0xeb>
80105351:	e8 75 e1 ff ff       	call   801034cb <myproc>
80105356:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010535a:	74 11                	je     8010536d <trap+0xeb>
8010535c:	0f b7 47 3c          	movzwl 0x3c(%edi),%eax
80105360:	83 e0 03             	and    $0x3,%eax
80105363:	66 83 f8 03          	cmp    $0x3,%ax
80105367:	0f 84 97 01 00 00    	je     80105504 <trap+0x282>
        exit();
}
8010536d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105370:	5b                   	pop    %ebx
80105371:	5e                   	pop    %esi
80105372:	5f                   	pop    %edi
80105373:	5d                   	pop    %ebp
80105374:	c3                   	ret    
            acquire(&tickslock);
80105375:	83 ec 0c             	sub    $0xc,%esp
80105378:	68 60 52 11 80       	push   $0x80115260
8010537d:	e8 f3 ec ff ff       	call   80104075 <acquire>
            ticks++;
80105382:	83 05 a0 5a 11 80 01 	addl   $0x1,0x80115aa0
            wakeup(&ticks);
80105389:	c7 04 24 a0 5a 11 80 	movl   $0x80115aa0,(%esp)
80105390:	e8 c6 e8 ff ff       	call   80103c5b <wakeup>
            release(&tickslock);
80105395:	c7 04 24 60 52 11 80 	movl   $0x80115260,(%esp)
8010539c:	e8 3b ed ff ff       	call   801040dc <release>
801053a1:	83 c4 10             	add    $0x10,%esp
801053a4:	e9 45 ff ff ff       	jmp    801052ee <trap+0x6c>
            myproc()->proc_tick++;
801053a9:	e8 1d e1 ff ff       	call   801034cb <myproc>
801053ae:	83 80 8c 00 00 00 01 	addl   $0x1,0x8c(%eax)
801053b5:	e9 4c ff ff ff       	jmp    80105306 <trap+0x84>
        ideintr();
801053ba:	e8 31 ca ff ff       	call   80101df0 <ideintr>
        lapiceoi();
801053bf:	e8 96 d0 ff ff       	call   8010245a <lapiceoi>
        break;
801053c4:	e9 42 ff ff ff       	jmp    8010530b <trap+0x89>
        kbdintr();
801053c9:	e8 c0 ce ff ff       	call   8010228e <kbdintr>
        lapiceoi();
801053ce:	e8 87 d0 ff ff       	call   8010245a <lapiceoi>
        break;
801053d3:	e9 33 ff ff ff       	jmp    8010530b <trap+0x89>
        uartintr();
801053d8:	e8 5f 02 00 00       	call   8010563c <uartintr>
        lapiceoi();
801053dd:	e8 78 d0 ff ff       	call   8010245a <lapiceoi>
        break;
801053e2:	e9 24 ff ff ff       	jmp    8010530b <trap+0x89>
        cprintf("cpu%d: spurious interrupt at %x:%x\n", cpuid(), tf->cs,
801053e7:	8b 77 38             	mov    0x38(%edi),%esi
801053ea:	0f b7 5f 3c          	movzwl 0x3c(%edi),%ebx
801053ee:	e8 bd e0 ff ff       	call   801034b0 <cpuid>
801053f3:	56                   	push   %esi
801053f4:	53                   	push   %ebx
801053f5:	50                   	push   %eax
801053f6:	68 a8 70 10 80       	push   $0x801070a8
801053fb:	e8 e1 b1 ff ff       	call   801005e1 <cprintf>
        lapiceoi();
80105400:	e8 55 d0 ff ff       	call   8010245a <lapiceoi>
        break;
80105405:	83 c4 10             	add    $0x10,%esp
80105408:	e9 fe fe ff ff       	jmp    8010530b <trap+0x89>
        if (myproc() == 0 || (tf->cs & 3) == 0) {
8010540d:	e8 b9 e0 ff ff       	call   801034cb <myproc>
80105412:	85 c0                	test   %eax,%eax
80105414:	74 60                	je     80105476 <trap+0x1f4>
80105416:	f6 47 3c 03          	testb  $0x3,0x3c(%edi)
8010541a:	74 5a                	je     80105476 <trap+0x1f4>
}

static inline uint rcr2(void)
{
    uint val;
    asm volatile("movl %%cr2,%0" : "=r"(val));
8010541c:	0f 20 d0             	mov    %cr2,%eax
8010541f:	89 45 d8             	mov    %eax,-0x28(%ebp)
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80105422:	8b 77 38             	mov    0x38(%edi),%esi
80105425:	e8 86 e0 ff ff       	call   801034b0 <cpuid>
8010542a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010542d:	8b 5f 34             	mov    0x34(%edi),%ebx
80105430:	8b 4f 30             	mov    0x30(%edi),%ecx
80105433:	89 4d e0             	mov    %ecx,-0x20(%ebp)
                myproc()->pid, myproc()->name, tf->trapno, tf->err, cpuid(),
80105436:	e8 90 e0 ff ff       	call   801034cb <myproc>
8010543b:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010543e:	e8 88 e0 ff ff       	call   801034cb <myproc>
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80105443:	ff 75 d8             	pushl  -0x28(%ebp)
80105446:	56                   	push   %esi
80105447:	ff 75 e4             	pushl  -0x1c(%ebp)
8010544a:	53                   	push   %ebx
8010544b:	ff 75 e0             	pushl  -0x20(%ebp)
                myproc()->pid, myproc()->name, tf->trapno, tf->err, cpuid(),
8010544e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105451:	83 c2 6c             	add    $0x6c,%edx
        cprintf("pid %d %s: trap %d err %d on cpu %d "
80105454:	52                   	push   %edx
80105455:	ff 70 10             	pushl  0x10(%eax)
80105458:	68 00 71 10 80       	push   $0x80107100
8010545d:	e8 7f b1 ff ff       	call   801005e1 <cprintf>
        myproc()->killed = 1;
80105462:	83 c4 20             	add    $0x20,%esp
80105465:	e8 61 e0 ff ff       	call   801034cb <myproc>
8010546a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105471:	e9 95 fe ff ff       	jmp    8010530b <trap+0x89>
80105476:	0f 20 d6             	mov    %cr2,%esi
            cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105479:	8b 5f 38             	mov    0x38(%edi),%ebx
8010547c:	e8 2f e0 ff ff       	call   801034b0 <cpuid>
80105481:	83 ec 0c             	sub    $0xc,%esp
80105484:	56                   	push   %esi
80105485:	53                   	push   %ebx
80105486:	50                   	push   %eax
80105487:	ff 77 30             	pushl  0x30(%edi)
8010548a:	68 cc 70 10 80       	push   $0x801070cc
8010548f:	e8 4d b1 ff ff       	call   801005e1 <cprintf>
            panic("trap");
80105494:	83 c4 14             	add    $0x14,%esp
80105497:	68 a2 70 10 80       	push   $0x801070a2
8010549c:	e8 a3 ae ff ff       	call   80100344 <panic>
        exit();
801054a1:	e8 9d e4 ff ff       	call   80103943 <exit>
801054a6:	e9 85 fe ff ff       	jmp    80105330 <trap+0xae>
    if (myproc() && myproc()->state == RUNNING &&
801054ab:	83 7f 30 20          	cmpl   $0x20,0x30(%edi)
801054af:	0f 85 93 fe ff ff    	jne    80105348 <trap+0xc6>
        myproc()->proc_tick >= TIMESLICE(myproc()->priority)) {
801054b5:	e8 11 e0 ff ff       	call   801034cb <myproc>
801054ba:	8b 98 8c 00 00 00    	mov    0x8c(%eax),%ebx
801054c0:	e8 06 e0 ff ff       	call   801034cb <myproc>
801054c5:	ba 64 00 00 00       	mov    $0x64,%edx
801054ca:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
801054d1:	75 12                	jne    801054e5 <trap+0x263>
        tf->trapno == T_IRQ0 + IRQ_TIMER &&
801054d3:	39 d3                	cmp    %edx,%ebx
801054d5:	0f 82 6d fe ff ff    	jb     80105348 <trap+0xc6>
        yield();
801054db:	e8 2a e5 ff ff       	call   80103a0a <yield>
801054e0:	e9 63 fe ff ff       	jmp    80105348 <trap+0xc6>
        myproc()->proc_tick >= TIMESLICE(myproc()->priority)) {
801054e5:	e8 e1 df ff ff       	call   801034cb <myproc>
801054ea:	ba c8 00 00 00       	mov    $0xc8,%edx
801054ef:	83 b8 88 00 00 00 01 	cmpl   $0x1,0x88(%eax)
801054f6:	74 db                	je     801054d3 <trap+0x251>
801054f8:	e8 ce df ff ff       	call   801034cb <myproc>
801054fd:	ba 2c 01 00 00       	mov    $0x12c,%edx
80105502:	eb cf                	jmp    801054d3 <trap+0x251>
        exit();
80105504:	e8 3a e4 ff ff       	call   80103943 <exit>
80105509:	e9 5f fe ff ff       	jmp    8010536d <trap+0xeb>

8010550e <uartgetc>:
        microdelay(10);
    outb(COM1 + 0, c);
}

static int uartgetc(void)
{
8010550e:	55                   	push   %ebp
8010550f:	89 e5                	mov    %esp,%ebp
    if (!uart)
80105511:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
80105518:	74 15                	je     8010552f <uartgetc+0x21>
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
8010551a:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010551f:	ec                   	in     (%dx),%al
        return -1;
    if (!(inb(COM1 + 5) & 0x01))
80105520:	a8 01                	test   $0x1,%al
80105522:	74 12                	je     80105536 <uartgetc+0x28>
80105524:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105529:	ec                   	in     (%dx),%al
        return -1;
    return inb(COM1 + 0);
8010552a:	0f b6 c0             	movzbl %al,%eax
}
8010552d:	5d                   	pop    %ebp
8010552e:	c3                   	ret    
        return -1;
8010552f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105534:	eb f7                	jmp    8010552d <uartgetc+0x1f>
        return -1;
80105536:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010553b:	eb f0                	jmp    8010552d <uartgetc+0x1f>

8010553d <uartputc>:
    if (!uart)
8010553d:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
80105544:	74 4f                	je     80105595 <uartputc+0x58>
{
80105546:	55                   	push   %ebp
80105547:	89 e5                	mov    %esp,%ebp
80105549:	56                   	push   %esi
8010554a:	53                   	push   %ebx
8010554b:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105550:	ec                   	in     (%dx),%al
    for (i = 0; i < 128 && !(inb(COM1 + 5) & 0x20); i++)
80105551:	a8 20                	test   $0x20,%al
80105553:	75 30                	jne    80105585 <uartputc+0x48>
        microdelay(10);
80105555:	83 ec 0c             	sub    $0xc,%esp
80105558:	6a 0a                	push   $0xa
8010555a:	e8 1a cf ff ff       	call   80102479 <microdelay>
8010555f:	83 c4 10             	add    $0x10,%esp
80105562:	bb 7f 00 00 00       	mov    $0x7f,%ebx
80105567:	be fd 03 00 00       	mov    $0x3fd,%esi
8010556c:	89 f2                	mov    %esi,%edx
8010556e:	ec                   	in     (%dx),%al
    for (i = 0; i < 128 && !(inb(COM1 + 5) & 0x20); i++)
8010556f:	a8 20                	test   $0x20,%al
80105571:	75 12                	jne    80105585 <uartputc+0x48>
        microdelay(10);
80105573:	83 ec 0c             	sub    $0xc,%esp
80105576:	6a 0a                	push   $0xa
80105578:	e8 fc ce ff ff       	call   80102479 <microdelay>
    for (i = 0; i < 128 && !(inb(COM1 + 5) & 0x20); i++)
8010557d:	83 c4 10             	add    $0x10,%esp
80105580:	83 eb 01             	sub    $0x1,%ebx
80105583:	75 e7                	jne    8010556c <uartputc+0x2f>
    asm volatile("out %0,%1" : : "a"(data), "d"(port));
80105585:	8b 45 08             	mov    0x8(%ebp),%eax
80105588:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010558d:	ee                   	out    %al,(%dx)
}
8010558e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105591:	5b                   	pop    %ebx
80105592:	5e                   	pop    %esi
80105593:	5d                   	pop    %ebp
80105594:	c3                   	ret    
80105595:	f3 c3                	repz ret 

80105597 <uartinit>:
{
80105597:	55                   	push   %ebp
80105598:	89 e5                	mov    %esp,%ebp
8010559a:	56                   	push   %esi
8010559b:	53                   	push   %ebx
8010559c:	b9 00 00 00 00       	mov    $0x0,%ecx
801055a1:	ba fa 03 00 00       	mov    $0x3fa,%edx
801055a6:	89 c8                	mov    %ecx,%eax
801055a8:	ee                   	out    %al,(%dx)
801055a9:	be fb 03 00 00       	mov    $0x3fb,%esi
801055ae:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801055b3:	89 f2                	mov    %esi,%edx
801055b5:	ee                   	out    %al,(%dx)
801055b6:	b8 0c 00 00 00       	mov    $0xc,%eax
801055bb:	ba f8 03 00 00       	mov    $0x3f8,%edx
801055c0:	ee                   	out    %al,(%dx)
801055c1:	bb f9 03 00 00       	mov    $0x3f9,%ebx
801055c6:	89 c8                	mov    %ecx,%eax
801055c8:	89 da                	mov    %ebx,%edx
801055ca:	ee                   	out    %al,(%dx)
801055cb:	b8 03 00 00 00       	mov    $0x3,%eax
801055d0:	89 f2                	mov    %esi,%edx
801055d2:	ee                   	out    %al,(%dx)
801055d3:	ba fc 03 00 00       	mov    $0x3fc,%edx
801055d8:	89 c8                	mov    %ecx,%eax
801055da:	ee                   	out    %al,(%dx)
801055db:	b8 01 00 00 00       	mov    $0x1,%eax
801055e0:	89 da                	mov    %ebx,%edx
801055e2:	ee                   	out    %al,(%dx)
    asm volatile("in %1,%0" : "=a"(data) : "d"(port));
801055e3:	ba fd 03 00 00       	mov    $0x3fd,%edx
801055e8:	ec                   	in     (%dx),%al
    if (inb(COM1 + 5) == 0xFF)
801055e9:	3c ff                	cmp    $0xff,%al
801055eb:	74 48                	je     80105635 <uartinit+0x9e>
    uart = 1;
801055ed:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
801055f4:	00 00 00 
801055f7:	ba fa 03 00 00       	mov    $0x3fa,%edx
801055fc:	ec                   	in     (%dx),%al
801055fd:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105602:	ec                   	in     (%dx),%al
    ioapicenable(IRQ_COM1, 0);
80105603:	83 ec 08             	sub    $0x8,%esp
80105606:	6a 00                	push   $0x0
80105608:	6a 04                	push   $0x4
8010560a:	e8 f7 c9 ff ff       	call   80102006 <ioapicenable>
8010560f:	83 c4 10             	add    $0x10,%esp
    for (p = "xv6...\n"; *p; p++)
80105612:	bb c4 71 10 80       	mov    $0x801071c4,%ebx
80105617:	b8 78 00 00 00       	mov    $0x78,%eax
        uartputc(*p);
8010561c:	83 ec 0c             	sub    $0xc,%esp
8010561f:	0f be c0             	movsbl %al,%eax
80105622:	50                   	push   %eax
80105623:	e8 15 ff ff ff       	call   8010553d <uartputc>
    for (p = "xv6...\n"; *p; p++)
80105628:	83 c3 01             	add    $0x1,%ebx
8010562b:	0f b6 03             	movzbl (%ebx),%eax
8010562e:	83 c4 10             	add    $0x10,%esp
80105631:	84 c0                	test   %al,%al
80105633:	75 e7                	jne    8010561c <uartinit+0x85>
}
80105635:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105638:	5b                   	pop    %ebx
80105639:	5e                   	pop    %esi
8010563a:	5d                   	pop    %ebp
8010563b:	c3                   	ret    

8010563c <uartintr>:

void uartintr(void)
{
8010563c:	55                   	push   %ebp
8010563d:	89 e5                	mov    %esp,%ebp
8010563f:	83 ec 14             	sub    $0x14,%esp
    consoleintr(uartgetc);
80105642:	68 0e 55 10 80       	push   $0x8010550e
80105647:	e8 ef b0 ff ff       	call   8010073b <consoleintr>
}
8010564c:	83 c4 10             	add    $0x10,%esp
8010564f:	c9                   	leave  
80105650:	c3                   	ret    

80105651 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105651:	6a 00                	push   $0x0
  pushl $0
80105653:	6a 00                	push   $0x0
  jmp alltraps
80105655:	e9 56 fb ff ff       	jmp    801051b0 <alltraps>

8010565a <vector1>:
.globl vector1
vector1:
  pushl $0
8010565a:	6a 00                	push   $0x0
  pushl $1
8010565c:	6a 01                	push   $0x1
  jmp alltraps
8010565e:	e9 4d fb ff ff       	jmp    801051b0 <alltraps>

80105663 <vector2>:
.globl vector2
vector2:
  pushl $0
80105663:	6a 00                	push   $0x0
  pushl $2
80105665:	6a 02                	push   $0x2
  jmp alltraps
80105667:	e9 44 fb ff ff       	jmp    801051b0 <alltraps>

8010566c <vector3>:
.globl vector3
vector3:
  pushl $0
8010566c:	6a 00                	push   $0x0
  pushl $3
8010566e:	6a 03                	push   $0x3
  jmp alltraps
80105670:	e9 3b fb ff ff       	jmp    801051b0 <alltraps>

80105675 <vector4>:
.globl vector4
vector4:
  pushl $0
80105675:	6a 00                	push   $0x0
  pushl $4
80105677:	6a 04                	push   $0x4
  jmp alltraps
80105679:	e9 32 fb ff ff       	jmp    801051b0 <alltraps>

8010567e <vector5>:
.globl vector5
vector5:
  pushl $0
8010567e:	6a 00                	push   $0x0
  pushl $5
80105680:	6a 05                	push   $0x5
  jmp alltraps
80105682:	e9 29 fb ff ff       	jmp    801051b0 <alltraps>

80105687 <vector6>:
.globl vector6
vector6:
  pushl $0
80105687:	6a 00                	push   $0x0
  pushl $6
80105689:	6a 06                	push   $0x6
  jmp alltraps
8010568b:	e9 20 fb ff ff       	jmp    801051b0 <alltraps>

80105690 <vector7>:
.globl vector7
vector7:
  pushl $0
80105690:	6a 00                	push   $0x0
  pushl $7
80105692:	6a 07                	push   $0x7
  jmp alltraps
80105694:	e9 17 fb ff ff       	jmp    801051b0 <alltraps>

80105699 <vector8>:
.globl vector8
vector8:
  pushl $8
80105699:	6a 08                	push   $0x8
  jmp alltraps
8010569b:	e9 10 fb ff ff       	jmp    801051b0 <alltraps>

801056a0 <vector9>:
.globl vector9
vector9:
  pushl $0
801056a0:	6a 00                	push   $0x0
  pushl $9
801056a2:	6a 09                	push   $0x9
  jmp alltraps
801056a4:	e9 07 fb ff ff       	jmp    801051b0 <alltraps>

801056a9 <vector10>:
.globl vector10
vector10:
  pushl $10
801056a9:	6a 0a                	push   $0xa
  jmp alltraps
801056ab:	e9 00 fb ff ff       	jmp    801051b0 <alltraps>

801056b0 <vector11>:
.globl vector11
vector11:
  pushl $11
801056b0:	6a 0b                	push   $0xb
  jmp alltraps
801056b2:	e9 f9 fa ff ff       	jmp    801051b0 <alltraps>

801056b7 <vector12>:
.globl vector12
vector12:
  pushl $12
801056b7:	6a 0c                	push   $0xc
  jmp alltraps
801056b9:	e9 f2 fa ff ff       	jmp    801051b0 <alltraps>

801056be <vector13>:
.globl vector13
vector13:
  pushl $13
801056be:	6a 0d                	push   $0xd
  jmp alltraps
801056c0:	e9 eb fa ff ff       	jmp    801051b0 <alltraps>

801056c5 <vector14>:
.globl vector14
vector14:
  pushl $14
801056c5:	6a 0e                	push   $0xe
  jmp alltraps
801056c7:	e9 e4 fa ff ff       	jmp    801051b0 <alltraps>

801056cc <vector15>:
.globl vector15
vector15:
  pushl $0
801056cc:	6a 00                	push   $0x0
  pushl $15
801056ce:	6a 0f                	push   $0xf
  jmp alltraps
801056d0:	e9 db fa ff ff       	jmp    801051b0 <alltraps>

801056d5 <vector16>:
.globl vector16
vector16:
  pushl $0
801056d5:	6a 00                	push   $0x0
  pushl $16
801056d7:	6a 10                	push   $0x10
  jmp alltraps
801056d9:	e9 d2 fa ff ff       	jmp    801051b0 <alltraps>

801056de <vector17>:
.globl vector17
vector17:
  pushl $17
801056de:	6a 11                	push   $0x11
  jmp alltraps
801056e0:	e9 cb fa ff ff       	jmp    801051b0 <alltraps>

801056e5 <vector18>:
.globl vector18
vector18:
  pushl $0
801056e5:	6a 00                	push   $0x0
  pushl $18
801056e7:	6a 12                	push   $0x12
  jmp alltraps
801056e9:	e9 c2 fa ff ff       	jmp    801051b0 <alltraps>

801056ee <vector19>:
.globl vector19
vector19:
  pushl $0
801056ee:	6a 00                	push   $0x0
  pushl $19
801056f0:	6a 13                	push   $0x13
  jmp alltraps
801056f2:	e9 b9 fa ff ff       	jmp    801051b0 <alltraps>

801056f7 <vector20>:
.globl vector20
vector20:
  pushl $0
801056f7:	6a 00                	push   $0x0
  pushl $20
801056f9:	6a 14                	push   $0x14
  jmp alltraps
801056fb:	e9 b0 fa ff ff       	jmp    801051b0 <alltraps>

80105700 <vector21>:
.globl vector21
vector21:
  pushl $0
80105700:	6a 00                	push   $0x0
  pushl $21
80105702:	6a 15                	push   $0x15
  jmp alltraps
80105704:	e9 a7 fa ff ff       	jmp    801051b0 <alltraps>

80105709 <vector22>:
.globl vector22
vector22:
  pushl $0
80105709:	6a 00                	push   $0x0
  pushl $22
8010570b:	6a 16                	push   $0x16
  jmp alltraps
8010570d:	e9 9e fa ff ff       	jmp    801051b0 <alltraps>

80105712 <vector23>:
.globl vector23
vector23:
  pushl $0
80105712:	6a 00                	push   $0x0
  pushl $23
80105714:	6a 17                	push   $0x17
  jmp alltraps
80105716:	e9 95 fa ff ff       	jmp    801051b0 <alltraps>

8010571b <vector24>:
.globl vector24
vector24:
  pushl $0
8010571b:	6a 00                	push   $0x0
  pushl $24
8010571d:	6a 18                	push   $0x18
  jmp alltraps
8010571f:	e9 8c fa ff ff       	jmp    801051b0 <alltraps>

80105724 <vector25>:
.globl vector25
vector25:
  pushl $0
80105724:	6a 00                	push   $0x0
  pushl $25
80105726:	6a 19                	push   $0x19
  jmp alltraps
80105728:	e9 83 fa ff ff       	jmp    801051b0 <alltraps>

8010572d <vector26>:
.globl vector26
vector26:
  pushl $0
8010572d:	6a 00                	push   $0x0
  pushl $26
8010572f:	6a 1a                	push   $0x1a
  jmp alltraps
80105731:	e9 7a fa ff ff       	jmp    801051b0 <alltraps>

80105736 <vector27>:
.globl vector27
vector27:
  pushl $0
80105736:	6a 00                	push   $0x0
  pushl $27
80105738:	6a 1b                	push   $0x1b
  jmp alltraps
8010573a:	e9 71 fa ff ff       	jmp    801051b0 <alltraps>

8010573f <vector28>:
.globl vector28
vector28:
  pushl $0
8010573f:	6a 00                	push   $0x0
  pushl $28
80105741:	6a 1c                	push   $0x1c
  jmp alltraps
80105743:	e9 68 fa ff ff       	jmp    801051b0 <alltraps>

80105748 <vector29>:
.globl vector29
vector29:
  pushl $0
80105748:	6a 00                	push   $0x0
  pushl $29
8010574a:	6a 1d                	push   $0x1d
  jmp alltraps
8010574c:	e9 5f fa ff ff       	jmp    801051b0 <alltraps>

80105751 <vector30>:
.globl vector30
vector30:
  pushl $0
80105751:	6a 00                	push   $0x0
  pushl $30
80105753:	6a 1e                	push   $0x1e
  jmp alltraps
80105755:	e9 56 fa ff ff       	jmp    801051b0 <alltraps>

8010575a <vector31>:
.globl vector31
vector31:
  pushl $0
8010575a:	6a 00                	push   $0x0
  pushl $31
8010575c:	6a 1f                	push   $0x1f
  jmp alltraps
8010575e:	e9 4d fa ff ff       	jmp    801051b0 <alltraps>

80105763 <vector32>:
.globl vector32
vector32:
  pushl $0
80105763:	6a 00                	push   $0x0
  pushl $32
80105765:	6a 20                	push   $0x20
  jmp alltraps
80105767:	e9 44 fa ff ff       	jmp    801051b0 <alltraps>

8010576c <vector33>:
.globl vector33
vector33:
  pushl $0
8010576c:	6a 00                	push   $0x0
  pushl $33
8010576e:	6a 21                	push   $0x21
  jmp alltraps
80105770:	e9 3b fa ff ff       	jmp    801051b0 <alltraps>

80105775 <vector34>:
.globl vector34
vector34:
  pushl $0
80105775:	6a 00                	push   $0x0
  pushl $34
80105777:	6a 22                	push   $0x22
  jmp alltraps
80105779:	e9 32 fa ff ff       	jmp    801051b0 <alltraps>

8010577e <vector35>:
.globl vector35
vector35:
  pushl $0
8010577e:	6a 00                	push   $0x0
  pushl $35
80105780:	6a 23                	push   $0x23
  jmp alltraps
80105782:	e9 29 fa ff ff       	jmp    801051b0 <alltraps>

80105787 <vector36>:
.globl vector36
vector36:
  pushl $0
80105787:	6a 00                	push   $0x0
  pushl $36
80105789:	6a 24                	push   $0x24
  jmp alltraps
8010578b:	e9 20 fa ff ff       	jmp    801051b0 <alltraps>

80105790 <vector37>:
.globl vector37
vector37:
  pushl $0
80105790:	6a 00                	push   $0x0
  pushl $37
80105792:	6a 25                	push   $0x25
  jmp alltraps
80105794:	e9 17 fa ff ff       	jmp    801051b0 <alltraps>

80105799 <vector38>:
.globl vector38
vector38:
  pushl $0
80105799:	6a 00                	push   $0x0
  pushl $38
8010579b:	6a 26                	push   $0x26
  jmp alltraps
8010579d:	e9 0e fa ff ff       	jmp    801051b0 <alltraps>

801057a2 <vector39>:
.globl vector39
vector39:
  pushl $0
801057a2:	6a 00                	push   $0x0
  pushl $39
801057a4:	6a 27                	push   $0x27
  jmp alltraps
801057a6:	e9 05 fa ff ff       	jmp    801051b0 <alltraps>

801057ab <vector40>:
.globl vector40
vector40:
  pushl $0
801057ab:	6a 00                	push   $0x0
  pushl $40
801057ad:	6a 28                	push   $0x28
  jmp alltraps
801057af:	e9 fc f9 ff ff       	jmp    801051b0 <alltraps>

801057b4 <vector41>:
.globl vector41
vector41:
  pushl $0
801057b4:	6a 00                	push   $0x0
  pushl $41
801057b6:	6a 29                	push   $0x29
  jmp alltraps
801057b8:	e9 f3 f9 ff ff       	jmp    801051b0 <alltraps>

801057bd <vector42>:
.globl vector42
vector42:
  pushl $0
801057bd:	6a 00                	push   $0x0
  pushl $42
801057bf:	6a 2a                	push   $0x2a
  jmp alltraps
801057c1:	e9 ea f9 ff ff       	jmp    801051b0 <alltraps>

801057c6 <vector43>:
.globl vector43
vector43:
  pushl $0
801057c6:	6a 00                	push   $0x0
  pushl $43
801057c8:	6a 2b                	push   $0x2b
  jmp alltraps
801057ca:	e9 e1 f9 ff ff       	jmp    801051b0 <alltraps>

801057cf <vector44>:
.globl vector44
vector44:
  pushl $0
801057cf:	6a 00                	push   $0x0
  pushl $44
801057d1:	6a 2c                	push   $0x2c
  jmp alltraps
801057d3:	e9 d8 f9 ff ff       	jmp    801051b0 <alltraps>

801057d8 <vector45>:
.globl vector45
vector45:
  pushl $0
801057d8:	6a 00                	push   $0x0
  pushl $45
801057da:	6a 2d                	push   $0x2d
  jmp alltraps
801057dc:	e9 cf f9 ff ff       	jmp    801051b0 <alltraps>

801057e1 <vector46>:
.globl vector46
vector46:
  pushl $0
801057e1:	6a 00                	push   $0x0
  pushl $46
801057e3:	6a 2e                	push   $0x2e
  jmp alltraps
801057e5:	e9 c6 f9 ff ff       	jmp    801051b0 <alltraps>

801057ea <vector47>:
.globl vector47
vector47:
  pushl $0
801057ea:	6a 00                	push   $0x0
  pushl $47
801057ec:	6a 2f                	push   $0x2f
  jmp alltraps
801057ee:	e9 bd f9 ff ff       	jmp    801051b0 <alltraps>

801057f3 <vector48>:
.globl vector48
vector48:
  pushl $0
801057f3:	6a 00                	push   $0x0
  pushl $48
801057f5:	6a 30                	push   $0x30
  jmp alltraps
801057f7:	e9 b4 f9 ff ff       	jmp    801051b0 <alltraps>

801057fc <vector49>:
.globl vector49
vector49:
  pushl $0
801057fc:	6a 00                	push   $0x0
  pushl $49
801057fe:	6a 31                	push   $0x31
  jmp alltraps
80105800:	e9 ab f9 ff ff       	jmp    801051b0 <alltraps>

80105805 <vector50>:
.globl vector50
vector50:
  pushl $0
80105805:	6a 00                	push   $0x0
  pushl $50
80105807:	6a 32                	push   $0x32
  jmp alltraps
80105809:	e9 a2 f9 ff ff       	jmp    801051b0 <alltraps>

8010580e <vector51>:
.globl vector51
vector51:
  pushl $0
8010580e:	6a 00                	push   $0x0
  pushl $51
80105810:	6a 33                	push   $0x33
  jmp alltraps
80105812:	e9 99 f9 ff ff       	jmp    801051b0 <alltraps>

80105817 <vector52>:
.globl vector52
vector52:
  pushl $0
80105817:	6a 00                	push   $0x0
  pushl $52
80105819:	6a 34                	push   $0x34
  jmp alltraps
8010581b:	e9 90 f9 ff ff       	jmp    801051b0 <alltraps>

80105820 <vector53>:
.globl vector53
vector53:
  pushl $0
80105820:	6a 00                	push   $0x0
  pushl $53
80105822:	6a 35                	push   $0x35
  jmp alltraps
80105824:	e9 87 f9 ff ff       	jmp    801051b0 <alltraps>

80105829 <vector54>:
.globl vector54
vector54:
  pushl $0
80105829:	6a 00                	push   $0x0
  pushl $54
8010582b:	6a 36                	push   $0x36
  jmp alltraps
8010582d:	e9 7e f9 ff ff       	jmp    801051b0 <alltraps>

80105832 <vector55>:
.globl vector55
vector55:
  pushl $0
80105832:	6a 00                	push   $0x0
  pushl $55
80105834:	6a 37                	push   $0x37
  jmp alltraps
80105836:	e9 75 f9 ff ff       	jmp    801051b0 <alltraps>

8010583b <vector56>:
.globl vector56
vector56:
  pushl $0
8010583b:	6a 00                	push   $0x0
  pushl $56
8010583d:	6a 38                	push   $0x38
  jmp alltraps
8010583f:	e9 6c f9 ff ff       	jmp    801051b0 <alltraps>

80105844 <vector57>:
.globl vector57
vector57:
  pushl $0
80105844:	6a 00                	push   $0x0
  pushl $57
80105846:	6a 39                	push   $0x39
  jmp alltraps
80105848:	e9 63 f9 ff ff       	jmp    801051b0 <alltraps>

8010584d <vector58>:
.globl vector58
vector58:
  pushl $0
8010584d:	6a 00                	push   $0x0
  pushl $58
8010584f:	6a 3a                	push   $0x3a
  jmp alltraps
80105851:	e9 5a f9 ff ff       	jmp    801051b0 <alltraps>

80105856 <vector59>:
.globl vector59
vector59:
  pushl $0
80105856:	6a 00                	push   $0x0
  pushl $59
80105858:	6a 3b                	push   $0x3b
  jmp alltraps
8010585a:	e9 51 f9 ff ff       	jmp    801051b0 <alltraps>

8010585f <vector60>:
.globl vector60
vector60:
  pushl $0
8010585f:	6a 00                	push   $0x0
  pushl $60
80105861:	6a 3c                	push   $0x3c
  jmp alltraps
80105863:	e9 48 f9 ff ff       	jmp    801051b0 <alltraps>

80105868 <vector61>:
.globl vector61
vector61:
  pushl $0
80105868:	6a 00                	push   $0x0
  pushl $61
8010586a:	6a 3d                	push   $0x3d
  jmp alltraps
8010586c:	e9 3f f9 ff ff       	jmp    801051b0 <alltraps>

80105871 <vector62>:
.globl vector62
vector62:
  pushl $0
80105871:	6a 00                	push   $0x0
  pushl $62
80105873:	6a 3e                	push   $0x3e
  jmp alltraps
80105875:	e9 36 f9 ff ff       	jmp    801051b0 <alltraps>

8010587a <vector63>:
.globl vector63
vector63:
  pushl $0
8010587a:	6a 00                	push   $0x0
  pushl $63
8010587c:	6a 3f                	push   $0x3f
  jmp alltraps
8010587e:	e9 2d f9 ff ff       	jmp    801051b0 <alltraps>

80105883 <vector64>:
.globl vector64
vector64:
  pushl $0
80105883:	6a 00                	push   $0x0
  pushl $64
80105885:	6a 40                	push   $0x40
  jmp alltraps
80105887:	e9 24 f9 ff ff       	jmp    801051b0 <alltraps>

8010588c <vector65>:
.globl vector65
vector65:
  pushl $0
8010588c:	6a 00                	push   $0x0
  pushl $65
8010588e:	6a 41                	push   $0x41
  jmp alltraps
80105890:	e9 1b f9 ff ff       	jmp    801051b0 <alltraps>

80105895 <vector66>:
.globl vector66
vector66:
  pushl $0
80105895:	6a 00                	push   $0x0
  pushl $66
80105897:	6a 42                	push   $0x42
  jmp alltraps
80105899:	e9 12 f9 ff ff       	jmp    801051b0 <alltraps>

8010589e <vector67>:
.globl vector67
vector67:
  pushl $0
8010589e:	6a 00                	push   $0x0
  pushl $67
801058a0:	6a 43                	push   $0x43
  jmp alltraps
801058a2:	e9 09 f9 ff ff       	jmp    801051b0 <alltraps>

801058a7 <vector68>:
.globl vector68
vector68:
  pushl $0
801058a7:	6a 00                	push   $0x0
  pushl $68
801058a9:	6a 44                	push   $0x44
  jmp alltraps
801058ab:	e9 00 f9 ff ff       	jmp    801051b0 <alltraps>

801058b0 <vector69>:
.globl vector69
vector69:
  pushl $0
801058b0:	6a 00                	push   $0x0
  pushl $69
801058b2:	6a 45                	push   $0x45
  jmp alltraps
801058b4:	e9 f7 f8 ff ff       	jmp    801051b0 <alltraps>

801058b9 <vector70>:
.globl vector70
vector70:
  pushl $0
801058b9:	6a 00                	push   $0x0
  pushl $70
801058bb:	6a 46                	push   $0x46
  jmp alltraps
801058bd:	e9 ee f8 ff ff       	jmp    801051b0 <alltraps>

801058c2 <vector71>:
.globl vector71
vector71:
  pushl $0
801058c2:	6a 00                	push   $0x0
  pushl $71
801058c4:	6a 47                	push   $0x47
  jmp alltraps
801058c6:	e9 e5 f8 ff ff       	jmp    801051b0 <alltraps>

801058cb <vector72>:
.globl vector72
vector72:
  pushl $0
801058cb:	6a 00                	push   $0x0
  pushl $72
801058cd:	6a 48                	push   $0x48
  jmp alltraps
801058cf:	e9 dc f8 ff ff       	jmp    801051b0 <alltraps>

801058d4 <vector73>:
.globl vector73
vector73:
  pushl $0
801058d4:	6a 00                	push   $0x0
  pushl $73
801058d6:	6a 49                	push   $0x49
  jmp alltraps
801058d8:	e9 d3 f8 ff ff       	jmp    801051b0 <alltraps>

801058dd <vector74>:
.globl vector74
vector74:
  pushl $0
801058dd:	6a 00                	push   $0x0
  pushl $74
801058df:	6a 4a                	push   $0x4a
  jmp alltraps
801058e1:	e9 ca f8 ff ff       	jmp    801051b0 <alltraps>

801058e6 <vector75>:
.globl vector75
vector75:
  pushl $0
801058e6:	6a 00                	push   $0x0
  pushl $75
801058e8:	6a 4b                	push   $0x4b
  jmp alltraps
801058ea:	e9 c1 f8 ff ff       	jmp    801051b0 <alltraps>

801058ef <vector76>:
.globl vector76
vector76:
  pushl $0
801058ef:	6a 00                	push   $0x0
  pushl $76
801058f1:	6a 4c                	push   $0x4c
  jmp alltraps
801058f3:	e9 b8 f8 ff ff       	jmp    801051b0 <alltraps>

801058f8 <vector77>:
.globl vector77
vector77:
  pushl $0
801058f8:	6a 00                	push   $0x0
  pushl $77
801058fa:	6a 4d                	push   $0x4d
  jmp alltraps
801058fc:	e9 af f8 ff ff       	jmp    801051b0 <alltraps>

80105901 <vector78>:
.globl vector78
vector78:
  pushl $0
80105901:	6a 00                	push   $0x0
  pushl $78
80105903:	6a 4e                	push   $0x4e
  jmp alltraps
80105905:	e9 a6 f8 ff ff       	jmp    801051b0 <alltraps>

8010590a <vector79>:
.globl vector79
vector79:
  pushl $0
8010590a:	6a 00                	push   $0x0
  pushl $79
8010590c:	6a 4f                	push   $0x4f
  jmp alltraps
8010590e:	e9 9d f8 ff ff       	jmp    801051b0 <alltraps>

80105913 <vector80>:
.globl vector80
vector80:
  pushl $0
80105913:	6a 00                	push   $0x0
  pushl $80
80105915:	6a 50                	push   $0x50
  jmp alltraps
80105917:	e9 94 f8 ff ff       	jmp    801051b0 <alltraps>

8010591c <vector81>:
.globl vector81
vector81:
  pushl $0
8010591c:	6a 00                	push   $0x0
  pushl $81
8010591e:	6a 51                	push   $0x51
  jmp alltraps
80105920:	e9 8b f8 ff ff       	jmp    801051b0 <alltraps>

80105925 <vector82>:
.globl vector82
vector82:
  pushl $0
80105925:	6a 00                	push   $0x0
  pushl $82
80105927:	6a 52                	push   $0x52
  jmp alltraps
80105929:	e9 82 f8 ff ff       	jmp    801051b0 <alltraps>

8010592e <vector83>:
.globl vector83
vector83:
  pushl $0
8010592e:	6a 00                	push   $0x0
  pushl $83
80105930:	6a 53                	push   $0x53
  jmp alltraps
80105932:	e9 79 f8 ff ff       	jmp    801051b0 <alltraps>

80105937 <vector84>:
.globl vector84
vector84:
  pushl $0
80105937:	6a 00                	push   $0x0
  pushl $84
80105939:	6a 54                	push   $0x54
  jmp alltraps
8010593b:	e9 70 f8 ff ff       	jmp    801051b0 <alltraps>

80105940 <vector85>:
.globl vector85
vector85:
  pushl $0
80105940:	6a 00                	push   $0x0
  pushl $85
80105942:	6a 55                	push   $0x55
  jmp alltraps
80105944:	e9 67 f8 ff ff       	jmp    801051b0 <alltraps>

80105949 <vector86>:
.globl vector86
vector86:
  pushl $0
80105949:	6a 00                	push   $0x0
  pushl $86
8010594b:	6a 56                	push   $0x56
  jmp alltraps
8010594d:	e9 5e f8 ff ff       	jmp    801051b0 <alltraps>

80105952 <vector87>:
.globl vector87
vector87:
  pushl $0
80105952:	6a 00                	push   $0x0
  pushl $87
80105954:	6a 57                	push   $0x57
  jmp alltraps
80105956:	e9 55 f8 ff ff       	jmp    801051b0 <alltraps>

8010595b <vector88>:
.globl vector88
vector88:
  pushl $0
8010595b:	6a 00                	push   $0x0
  pushl $88
8010595d:	6a 58                	push   $0x58
  jmp alltraps
8010595f:	e9 4c f8 ff ff       	jmp    801051b0 <alltraps>

80105964 <vector89>:
.globl vector89
vector89:
  pushl $0
80105964:	6a 00                	push   $0x0
  pushl $89
80105966:	6a 59                	push   $0x59
  jmp alltraps
80105968:	e9 43 f8 ff ff       	jmp    801051b0 <alltraps>

8010596d <vector90>:
.globl vector90
vector90:
  pushl $0
8010596d:	6a 00                	push   $0x0
  pushl $90
8010596f:	6a 5a                	push   $0x5a
  jmp alltraps
80105971:	e9 3a f8 ff ff       	jmp    801051b0 <alltraps>

80105976 <vector91>:
.globl vector91
vector91:
  pushl $0
80105976:	6a 00                	push   $0x0
  pushl $91
80105978:	6a 5b                	push   $0x5b
  jmp alltraps
8010597a:	e9 31 f8 ff ff       	jmp    801051b0 <alltraps>

8010597f <vector92>:
.globl vector92
vector92:
  pushl $0
8010597f:	6a 00                	push   $0x0
  pushl $92
80105981:	6a 5c                	push   $0x5c
  jmp alltraps
80105983:	e9 28 f8 ff ff       	jmp    801051b0 <alltraps>

80105988 <vector93>:
.globl vector93
vector93:
  pushl $0
80105988:	6a 00                	push   $0x0
  pushl $93
8010598a:	6a 5d                	push   $0x5d
  jmp alltraps
8010598c:	e9 1f f8 ff ff       	jmp    801051b0 <alltraps>

80105991 <vector94>:
.globl vector94
vector94:
  pushl $0
80105991:	6a 00                	push   $0x0
  pushl $94
80105993:	6a 5e                	push   $0x5e
  jmp alltraps
80105995:	e9 16 f8 ff ff       	jmp    801051b0 <alltraps>

8010599a <vector95>:
.globl vector95
vector95:
  pushl $0
8010599a:	6a 00                	push   $0x0
  pushl $95
8010599c:	6a 5f                	push   $0x5f
  jmp alltraps
8010599e:	e9 0d f8 ff ff       	jmp    801051b0 <alltraps>

801059a3 <vector96>:
.globl vector96
vector96:
  pushl $0
801059a3:	6a 00                	push   $0x0
  pushl $96
801059a5:	6a 60                	push   $0x60
  jmp alltraps
801059a7:	e9 04 f8 ff ff       	jmp    801051b0 <alltraps>

801059ac <vector97>:
.globl vector97
vector97:
  pushl $0
801059ac:	6a 00                	push   $0x0
  pushl $97
801059ae:	6a 61                	push   $0x61
  jmp alltraps
801059b0:	e9 fb f7 ff ff       	jmp    801051b0 <alltraps>

801059b5 <vector98>:
.globl vector98
vector98:
  pushl $0
801059b5:	6a 00                	push   $0x0
  pushl $98
801059b7:	6a 62                	push   $0x62
  jmp alltraps
801059b9:	e9 f2 f7 ff ff       	jmp    801051b0 <alltraps>

801059be <vector99>:
.globl vector99
vector99:
  pushl $0
801059be:	6a 00                	push   $0x0
  pushl $99
801059c0:	6a 63                	push   $0x63
  jmp alltraps
801059c2:	e9 e9 f7 ff ff       	jmp    801051b0 <alltraps>

801059c7 <vector100>:
.globl vector100
vector100:
  pushl $0
801059c7:	6a 00                	push   $0x0
  pushl $100
801059c9:	6a 64                	push   $0x64
  jmp alltraps
801059cb:	e9 e0 f7 ff ff       	jmp    801051b0 <alltraps>

801059d0 <vector101>:
.globl vector101
vector101:
  pushl $0
801059d0:	6a 00                	push   $0x0
  pushl $101
801059d2:	6a 65                	push   $0x65
  jmp alltraps
801059d4:	e9 d7 f7 ff ff       	jmp    801051b0 <alltraps>

801059d9 <vector102>:
.globl vector102
vector102:
  pushl $0
801059d9:	6a 00                	push   $0x0
  pushl $102
801059db:	6a 66                	push   $0x66
  jmp alltraps
801059dd:	e9 ce f7 ff ff       	jmp    801051b0 <alltraps>

801059e2 <vector103>:
.globl vector103
vector103:
  pushl $0
801059e2:	6a 00                	push   $0x0
  pushl $103
801059e4:	6a 67                	push   $0x67
  jmp alltraps
801059e6:	e9 c5 f7 ff ff       	jmp    801051b0 <alltraps>

801059eb <vector104>:
.globl vector104
vector104:
  pushl $0
801059eb:	6a 00                	push   $0x0
  pushl $104
801059ed:	6a 68                	push   $0x68
  jmp alltraps
801059ef:	e9 bc f7 ff ff       	jmp    801051b0 <alltraps>

801059f4 <vector105>:
.globl vector105
vector105:
  pushl $0
801059f4:	6a 00                	push   $0x0
  pushl $105
801059f6:	6a 69                	push   $0x69
  jmp alltraps
801059f8:	e9 b3 f7 ff ff       	jmp    801051b0 <alltraps>

801059fd <vector106>:
.globl vector106
vector106:
  pushl $0
801059fd:	6a 00                	push   $0x0
  pushl $106
801059ff:	6a 6a                	push   $0x6a
  jmp alltraps
80105a01:	e9 aa f7 ff ff       	jmp    801051b0 <alltraps>

80105a06 <vector107>:
.globl vector107
vector107:
  pushl $0
80105a06:	6a 00                	push   $0x0
  pushl $107
80105a08:	6a 6b                	push   $0x6b
  jmp alltraps
80105a0a:	e9 a1 f7 ff ff       	jmp    801051b0 <alltraps>

80105a0f <vector108>:
.globl vector108
vector108:
  pushl $0
80105a0f:	6a 00                	push   $0x0
  pushl $108
80105a11:	6a 6c                	push   $0x6c
  jmp alltraps
80105a13:	e9 98 f7 ff ff       	jmp    801051b0 <alltraps>

80105a18 <vector109>:
.globl vector109
vector109:
  pushl $0
80105a18:	6a 00                	push   $0x0
  pushl $109
80105a1a:	6a 6d                	push   $0x6d
  jmp alltraps
80105a1c:	e9 8f f7 ff ff       	jmp    801051b0 <alltraps>

80105a21 <vector110>:
.globl vector110
vector110:
  pushl $0
80105a21:	6a 00                	push   $0x0
  pushl $110
80105a23:	6a 6e                	push   $0x6e
  jmp alltraps
80105a25:	e9 86 f7 ff ff       	jmp    801051b0 <alltraps>

80105a2a <vector111>:
.globl vector111
vector111:
  pushl $0
80105a2a:	6a 00                	push   $0x0
  pushl $111
80105a2c:	6a 6f                	push   $0x6f
  jmp alltraps
80105a2e:	e9 7d f7 ff ff       	jmp    801051b0 <alltraps>

80105a33 <vector112>:
.globl vector112
vector112:
  pushl $0
80105a33:	6a 00                	push   $0x0
  pushl $112
80105a35:	6a 70                	push   $0x70
  jmp alltraps
80105a37:	e9 74 f7 ff ff       	jmp    801051b0 <alltraps>

80105a3c <vector113>:
.globl vector113
vector113:
  pushl $0
80105a3c:	6a 00                	push   $0x0
  pushl $113
80105a3e:	6a 71                	push   $0x71
  jmp alltraps
80105a40:	e9 6b f7 ff ff       	jmp    801051b0 <alltraps>

80105a45 <vector114>:
.globl vector114
vector114:
  pushl $0
80105a45:	6a 00                	push   $0x0
  pushl $114
80105a47:	6a 72                	push   $0x72
  jmp alltraps
80105a49:	e9 62 f7 ff ff       	jmp    801051b0 <alltraps>

80105a4e <vector115>:
.globl vector115
vector115:
  pushl $0
80105a4e:	6a 00                	push   $0x0
  pushl $115
80105a50:	6a 73                	push   $0x73
  jmp alltraps
80105a52:	e9 59 f7 ff ff       	jmp    801051b0 <alltraps>

80105a57 <vector116>:
.globl vector116
vector116:
  pushl $0
80105a57:	6a 00                	push   $0x0
  pushl $116
80105a59:	6a 74                	push   $0x74
  jmp alltraps
80105a5b:	e9 50 f7 ff ff       	jmp    801051b0 <alltraps>

80105a60 <vector117>:
.globl vector117
vector117:
  pushl $0
80105a60:	6a 00                	push   $0x0
  pushl $117
80105a62:	6a 75                	push   $0x75
  jmp alltraps
80105a64:	e9 47 f7 ff ff       	jmp    801051b0 <alltraps>

80105a69 <vector118>:
.globl vector118
vector118:
  pushl $0
80105a69:	6a 00                	push   $0x0
  pushl $118
80105a6b:	6a 76                	push   $0x76
  jmp alltraps
80105a6d:	e9 3e f7 ff ff       	jmp    801051b0 <alltraps>

80105a72 <vector119>:
.globl vector119
vector119:
  pushl $0
80105a72:	6a 00                	push   $0x0
  pushl $119
80105a74:	6a 77                	push   $0x77
  jmp alltraps
80105a76:	e9 35 f7 ff ff       	jmp    801051b0 <alltraps>

80105a7b <vector120>:
.globl vector120
vector120:
  pushl $0
80105a7b:	6a 00                	push   $0x0
  pushl $120
80105a7d:	6a 78                	push   $0x78
  jmp alltraps
80105a7f:	e9 2c f7 ff ff       	jmp    801051b0 <alltraps>

80105a84 <vector121>:
.globl vector121
vector121:
  pushl $0
80105a84:	6a 00                	push   $0x0
  pushl $121
80105a86:	6a 79                	push   $0x79
  jmp alltraps
80105a88:	e9 23 f7 ff ff       	jmp    801051b0 <alltraps>

80105a8d <vector122>:
.globl vector122
vector122:
  pushl $0
80105a8d:	6a 00                	push   $0x0
  pushl $122
80105a8f:	6a 7a                	push   $0x7a
  jmp alltraps
80105a91:	e9 1a f7 ff ff       	jmp    801051b0 <alltraps>

80105a96 <vector123>:
.globl vector123
vector123:
  pushl $0
80105a96:	6a 00                	push   $0x0
  pushl $123
80105a98:	6a 7b                	push   $0x7b
  jmp alltraps
80105a9a:	e9 11 f7 ff ff       	jmp    801051b0 <alltraps>

80105a9f <vector124>:
.globl vector124
vector124:
  pushl $0
80105a9f:	6a 00                	push   $0x0
  pushl $124
80105aa1:	6a 7c                	push   $0x7c
  jmp alltraps
80105aa3:	e9 08 f7 ff ff       	jmp    801051b0 <alltraps>

80105aa8 <vector125>:
.globl vector125
vector125:
  pushl $0
80105aa8:	6a 00                	push   $0x0
  pushl $125
80105aaa:	6a 7d                	push   $0x7d
  jmp alltraps
80105aac:	e9 ff f6 ff ff       	jmp    801051b0 <alltraps>

80105ab1 <vector126>:
.globl vector126
vector126:
  pushl $0
80105ab1:	6a 00                	push   $0x0
  pushl $126
80105ab3:	6a 7e                	push   $0x7e
  jmp alltraps
80105ab5:	e9 f6 f6 ff ff       	jmp    801051b0 <alltraps>

80105aba <vector127>:
.globl vector127
vector127:
  pushl $0
80105aba:	6a 00                	push   $0x0
  pushl $127
80105abc:	6a 7f                	push   $0x7f
  jmp alltraps
80105abe:	e9 ed f6 ff ff       	jmp    801051b0 <alltraps>

80105ac3 <vector128>:
.globl vector128
vector128:
  pushl $0
80105ac3:	6a 00                	push   $0x0
  pushl $128
80105ac5:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105aca:	e9 e1 f6 ff ff       	jmp    801051b0 <alltraps>

80105acf <vector129>:
.globl vector129
vector129:
  pushl $0
80105acf:	6a 00                	push   $0x0
  pushl $129
80105ad1:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105ad6:	e9 d5 f6 ff ff       	jmp    801051b0 <alltraps>

80105adb <vector130>:
.globl vector130
vector130:
  pushl $0
80105adb:	6a 00                	push   $0x0
  pushl $130
80105add:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105ae2:	e9 c9 f6 ff ff       	jmp    801051b0 <alltraps>

80105ae7 <vector131>:
.globl vector131
vector131:
  pushl $0
80105ae7:	6a 00                	push   $0x0
  pushl $131
80105ae9:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105aee:	e9 bd f6 ff ff       	jmp    801051b0 <alltraps>

80105af3 <vector132>:
.globl vector132
vector132:
  pushl $0
80105af3:	6a 00                	push   $0x0
  pushl $132
80105af5:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105afa:	e9 b1 f6 ff ff       	jmp    801051b0 <alltraps>

80105aff <vector133>:
.globl vector133
vector133:
  pushl $0
80105aff:	6a 00                	push   $0x0
  pushl $133
80105b01:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105b06:	e9 a5 f6 ff ff       	jmp    801051b0 <alltraps>

80105b0b <vector134>:
.globl vector134
vector134:
  pushl $0
80105b0b:	6a 00                	push   $0x0
  pushl $134
80105b0d:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105b12:	e9 99 f6 ff ff       	jmp    801051b0 <alltraps>

80105b17 <vector135>:
.globl vector135
vector135:
  pushl $0
80105b17:	6a 00                	push   $0x0
  pushl $135
80105b19:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105b1e:	e9 8d f6 ff ff       	jmp    801051b0 <alltraps>

80105b23 <vector136>:
.globl vector136
vector136:
  pushl $0
80105b23:	6a 00                	push   $0x0
  pushl $136
80105b25:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105b2a:	e9 81 f6 ff ff       	jmp    801051b0 <alltraps>

80105b2f <vector137>:
.globl vector137
vector137:
  pushl $0
80105b2f:	6a 00                	push   $0x0
  pushl $137
80105b31:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105b36:	e9 75 f6 ff ff       	jmp    801051b0 <alltraps>

80105b3b <vector138>:
.globl vector138
vector138:
  pushl $0
80105b3b:	6a 00                	push   $0x0
  pushl $138
80105b3d:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105b42:	e9 69 f6 ff ff       	jmp    801051b0 <alltraps>

80105b47 <vector139>:
.globl vector139
vector139:
  pushl $0
80105b47:	6a 00                	push   $0x0
  pushl $139
80105b49:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105b4e:	e9 5d f6 ff ff       	jmp    801051b0 <alltraps>

80105b53 <vector140>:
.globl vector140
vector140:
  pushl $0
80105b53:	6a 00                	push   $0x0
  pushl $140
80105b55:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105b5a:	e9 51 f6 ff ff       	jmp    801051b0 <alltraps>

80105b5f <vector141>:
.globl vector141
vector141:
  pushl $0
80105b5f:	6a 00                	push   $0x0
  pushl $141
80105b61:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105b66:	e9 45 f6 ff ff       	jmp    801051b0 <alltraps>

80105b6b <vector142>:
.globl vector142
vector142:
  pushl $0
80105b6b:	6a 00                	push   $0x0
  pushl $142
80105b6d:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105b72:	e9 39 f6 ff ff       	jmp    801051b0 <alltraps>

80105b77 <vector143>:
.globl vector143
vector143:
  pushl $0
80105b77:	6a 00                	push   $0x0
  pushl $143
80105b79:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105b7e:	e9 2d f6 ff ff       	jmp    801051b0 <alltraps>

80105b83 <vector144>:
.globl vector144
vector144:
  pushl $0
80105b83:	6a 00                	push   $0x0
  pushl $144
80105b85:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105b8a:	e9 21 f6 ff ff       	jmp    801051b0 <alltraps>

80105b8f <vector145>:
.globl vector145
vector145:
  pushl $0
80105b8f:	6a 00                	push   $0x0
  pushl $145
80105b91:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105b96:	e9 15 f6 ff ff       	jmp    801051b0 <alltraps>

80105b9b <vector146>:
.globl vector146
vector146:
  pushl $0
80105b9b:	6a 00                	push   $0x0
  pushl $146
80105b9d:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105ba2:	e9 09 f6 ff ff       	jmp    801051b0 <alltraps>

80105ba7 <vector147>:
.globl vector147
vector147:
  pushl $0
80105ba7:	6a 00                	push   $0x0
  pushl $147
80105ba9:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105bae:	e9 fd f5 ff ff       	jmp    801051b0 <alltraps>

80105bb3 <vector148>:
.globl vector148
vector148:
  pushl $0
80105bb3:	6a 00                	push   $0x0
  pushl $148
80105bb5:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105bba:	e9 f1 f5 ff ff       	jmp    801051b0 <alltraps>

80105bbf <vector149>:
.globl vector149
vector149:
  pushl $0
80105bbf:	6a 00                	push   $0x0
  pushl $149
80105bc1:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105bc6:	e9 e5 f5 ff ff       	jmp    801051b0 <alltraps>

80105bcb <vector150>:
.globl vector150
vector150:
  pushl $0
80105bcb:	6a 00                	push   $0x0
  pushl $150
80105bcd:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105bd2:	e9 d9 f5 ff ff       	jmp    801051b0 <alltraps>

80105bd7 <vector151>:
.globl vector151
vector151:
  pushl $0
80105bd7:	6a 00                	push   $0x0
  pushl $151
80105bd9:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105bde:	e9 cd f5 ff ff       	jmp    801051b0 <alltraps>

80105be3 <vector152>:
.globl vector152
vector152:
  pushl $0
80105be3:	6a 00                	push   $0x0
  pushl $152
80105be5:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105bea:	e9 c1 f5 ff ff       	jmp    801051b0 <alltraps>

80105bef <vector153>:
.globl vector153
vector153:
  pushl $0
80105bef:	6a 00                	push   $0x0
  pushl $153
80105bf1:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105bf6:	e9 b5 f5 ff ff       	jmp    801051b0 <alltraps>

80105bfb <vector154>:
.globl vector154
vector154:
  pushl $0
80105bfb:	6a 00                	push   $0x0
  pushl $154
80105bfd:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105c02:	e9 a9 f5 ff ff       	jmp    801051b0 <alltraps>

80105c07 <vector155>:
.globl vector155
vector155:
  pushl $0
80105c07:	6a 00                	push   $0x0
  pushl $155
80105c09:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105c0e:	e9 9d f5 ff ff       	jmp    801051b0 <alltraps>

80105c13 <vector156>:
.globl vector156
vector156:
  pushl $0
80105c13:	6a 00                	push   $0x0
  pushl $156
80105c15:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105c1a:	e9 91 f5 ff ff       	jmp    801051b0 <alltraps>

80105c1f <vector157>:
.globl vector157
vector157:
  pushl $0
80105c1f:	6a 00                	push   $0x0
  pushl $157
80105c21:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105c26:	e9 85 f5 ff ff       	jmp    801051b0 <alltraps>

80105c2b <vector158>:
.globl vector158
vector158:
  pushl $0
80105c2b:	6a 00                	push   $0x0
  pushl $158
80105c2d:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105c32:	e9 79 f5 ff ff       	jmp    801051b0 <alltraps>

80105c37 <vector159>:
.globl vector159
vector159:
  pushl $0
80105c37:	6a 00                	push   $0x0
  pushl $159
80105c39:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105c3e:	e9 6d f5 ff ff       	jmp    801051b0 <alltraps>

80105c43 <vector160>:
.globl vector160
vector160:
  pushl $0
80105c43:	6a 00                	push   $0x0
  pushl $160
80105c45:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105c4a:	e9 61 f5 ff ff       	jmp    801051b0 <alltraps>

80105c4f <vector161>:
.globl vector161
vector161:
  pushl $0
80105c4f:	6a 00                	push   $0x0
  pushl $161
80105c51:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105c56:	e9 55 f5 ff ff       	jmp    801051b0 <alltraps>

80105c5b <vector162>:
.globl vector162
vector162:
  pushl $0
80105c5b:	6a 00                	push   $0x0
  pushl $162
80105c5d:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105c62:	e9 49 f5 ff ff       	jmp    801051b0 <alltraps>

80105c67 <vector163>:
.globl vector163
vector163:
  pushl $0
80105c67:	6a 00                	push   $0x0
  pushl $163
80105c69:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105c6e:	e9 3d f5 ff ff       	jmp    801051b0 <alltraps>

80105c73 <vector164>:
.globl vector164
vector164:
  pushl $0
80105c73:	6a 00                	push   $0x0
  pushl $164
80105c75:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105c7a:	e9 31 f5 ff ff       	jmp    801051b0 <alltraps>

80105c7f <vector165>:
.globl vector165
vector165:
  pushl $0
80105c7f:	6a 00                	push   $0x0
  pushl $165
80105c81:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105c86:	e9 25 f5 ff ff       	jmp    801051b0 <alltraps>

80105c8b <vector166>:
.globl vector166
vector166:
  pushl $0
80105c8b:	6a 00                	push   $0x0
  pushl $166
80105c8d:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105c92:	e9 19 f5 ff ff       	jmp    801051b0 <alltraps>

80105c97 <vector167>:
.globl vector167
vector167:
  pushl $0
80105c97:	6a 00                	push   $0x0
  pushl $167
80105c99:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105c9e:	e9 0d f5 ff ff       	jmp    801051b0 <alltraps>

80105ca3 <vector168>:
.globl vector168
vector168:
  pushl $0
80105ca3:	6a 00                	push   $0x0
  pushl $168
80105ca5:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105caa:	e9 01 f5 ff ff       	jmp    801051b0 <alltraps>

80105caf <vector169>:
.globl vector169
vector169:
  pushl $0
80105caf:	6a 00                	push   $0x0
  pushl $169
80105cb1:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105cb6:	e9 f5 f4 ff ff       	jmp    801051b0 <alltraps>

80105cbb <vector170>:
.globl vector170
vector170:
  pushl $0
80105cbb:	6a 00                	push   $0x0
  pushl $170
80105cbd:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105cc2:	e9 e9 f4 ff ff       	jmp    801051b0 <alltraps>

80105cc7 <vector171>:
.globl vector171
vector171:
  pushl $0
80105cc7:	6a 00                	push   $0x0
  pushl $171
80105cc9:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105cce:	e9 dd f4 ff ff       	jmp    801051b0 <alltraps>

80105cd3 <vector172>:
.globl vector172
vector172:
  pushl $0
80105cd3:	6a 00                	push   $0x0
  pushl $172
80105cd5:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105cda:	e9 d1 f4 ff ff       	jmp    801051b0 <alltraps>

80105cdf <vector173>:
.globl vector173
vector173:
  pushl $0
80105cdf:	6a 00                	push   $0x0
  pushl $173
80105ce1:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105ce6:	e9 c5 f4 ff ff       	jmp    801051b0 <alltraps>

80105ceb <vector174>:
.globl vector174
vector174:
  pushl $0
80105ceb:	6a 00                	push   $0x0
  pushl $174
80105ced:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105cf2:	e9 b9 f4 ff ff       	jmp    801051b0 <alltraps>

80105cf7 <vector175>:
.globl vector175
vector175:
  pushl $0
80105cf7:	6a 00                	push   $0x0
  pushl $175
80105cf9:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105cfe:	e9 ad f4 ff ff       	jmp    801051b0 <alltraps>

80105d03 <vector176>:
.globl vector176
vector176:
  pushl $0
80105d03:	6a 00                	push   $0x0
  pushl $176
80105d05:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105d0a:	e9 a1 f4 ff ff       	jmp    801051b0 <alltraps>

80105d0f <vector177>:
.globl vector177
vector177:
  pushl $0
80105d0f:	6a 00                	push   $0x0
  pushl $177
80105d11:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105d16:	e9 95 f4 ff ff       	jmp    801051b0 <alltraps>

80105d1b <vector178>:
.globl vector178
vector178:
  pushl $0
80105d1b:	6a 00                	push   $0x0
  pushl $178
80105d1d:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105d22:	e9 89 f4 ff ff       	jmp    801051b0 <alltraps>

80105d27 <vector179>:
.globl vector179
vector179:
  pushl $0
80105d27:	6a 00                	push   $0x0
  pushl $179
80105d29:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105d2e:	e9 7d f4 ff ff       	jmp    801051b0 <alltraps>

80105d33 <vector180>:
.globl vector180
vector180:
  pushl $0
80105d33:	6a 00                	push   $0x0
  pushl $180
80105d35:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105d3a:	e9 71 f4 ff ff       	jmp    801051b0 <alltraps>

80105d3f <vector181>:
.globl vector181
vector181:
  pushl $0
80105d3f:	6a 00                	push   $0x0
  pushl $181
80105d41:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105d46:	e9 65 f4 ff ff       	jmp    801051b0 <alltraps>

80105d4b <vector182>:
.globl vector182
vector182:
  pushl $0
80105d4b:	6a 00                	push   $0x0
  pushl $182
80105d4d:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105d52:	e9 59 f4 ff ff       	jmp    801051b0 <alltraps>

80105d57 <vector183>:
.globl vector183
vector183:
  pushl $0
80105d57:	6a 00                	push   $0x0
  pushl $183
80105d59:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105d5e:	e9 4d f4 ff ff       	jmp    801051b0 <alltraps>

80105d63 <vector184>:
.globl vector184
vector184:
  pushl $0
80105d63:	6a 00                	push   $0x0
  pushl $184
80105d65:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105d6a:	e9 41 f4 ff ff       	jmp    801051b0 <alltraps>

80105d6f <vector185>:
.globl vector185
vector185:
  pushl $0
80105d6f:	6a 00                	push   $0x0
  pushl $185
80105d71:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105d76:	e9 35 f4 ff ff       	jmp    801051b0 <alltraps>

80105d7b <vector186>:
.globl vector186
vector186:
  pushl $0
80105d7b:	6a 00                	push   $0x0
  pushl $186
80105d7d:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105d82:	e9 29 f4 ff ff       	jmp    801051b0 <alltraps>

80105d87 <vector187>:
.globl vector187
vector187:
  pushl $0
80105d87:	6a 00                	push   $0x0
  pushl $187
80105d89:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105d8e:	e9 1d f4 ff ff       	jmp    801051b0 <alltraps>

80105d93 <vector188>:
.globl vector188
vector188:
  pushl $0
80105d93:	6a 00                	push   $0x0
  pushl $188
80105d95:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105d9a:	e9 11 f4 ff ff       	jmp    801051b0 <alltraps>

80105d9f <vector189>:
.globl vector189
vector189:
  pushl $0
80105d9f:	6a 00                	push   $0x0
  pushl $189
80105da1:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105da6:	e9 05 f4 ff ff       	jmp    801051b0 <alltraps>

80105dab <vector190>:
.globl vector190
vector190:
  pushl $0
80105dab:	6a 00                	push   $0x0
  pushl $190
80105dad:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105db2:	e9 f9 f3 ff ff       	jmp    801051b0 <alltraps>

80105db7 <vector191>:
.globl vector191
vector191:
  pushl $0
80105db7:	6a 00                	push   $0x0
  pushl $191
80105db9:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105dbe:	e9 ed f3 ff ff       	jmp    801051b0 <alltraps>

80105dc3 <vector192>:
.globl vector192
vector192:
  pushl $0
80105dc3:	6a 00                	push   $0x0
  pushl $192
80105dc5:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105dca:	e9 e1 f3 ff ff       	jmp    801051b0 <alltraps>

80105dcf <vector193>:
.globl vector193
vector193:
  pushl $0
80105dcf:	6a 00                	push   $0x0
  pushl $193
80105dd1:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105dd6:	e9 d5 f3 ff ff       	jmp    801051b0 <alltraps>

80105ddb <vector194>:
.globl vector194
vector194:
  pushl $0
80105ddb:	6a 00                	push   $0x0
  pushl $194
80105ddd:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105de2:	e9 c9 f3 ff ff       	jmp    801051b0 <alltraps>

80105de7 <vector195>:
.globl vector195
vector195:
  pushl $0
80105de7:	6a 00                	push   $0x0
  pushl $195
80105de9:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105dee:	e9 bd f3 ff ff       	jmp    801051b0 <alltraps>

80105df3 <vector196>:
.globl vector196
vector196:
  pushl $0
80105df3:	6a 00                	push   $0x0
  pushl $196
80105df5:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105dfa:	e9 b1 f3 ff ff       	jmp    801051b0 <alltraps>

80105dff <vector197>:
.globl vector197
vector197:
  pushl $0
80105dff:	6a 00                	push   $0x0
  pushl $197
80105e01:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105e06:	e9 a5 f3 ff ff       	jmp    801051b0 <alltraps>

80105e0b <vector198>:
.globl vector198
vector198:
  pushl $0
80105e0b:	6a 00                	push   $0x0
  pushl $198
80105e0d:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105e12:	e9 99 f3 ff ff       	jmp    801051b0 <alltraps>

80105e17 <vector199>:
.globl vector199
vector199:
  pushl $0
80105e17:	6a 00                	push   $0x0
  pushl $199
80105e19:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105e1e:	e9 8d f3 ff ff       	jmp    801051b0 <alltraps>

80105e23 <vector200>:
.globl vector200
vector200:
  pushl $0
80105e23:	6a 00                	push   $0x0
  pushl $200
80105e25:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105e2a:	e9 81 f3 ff ff       	jmp    801051b0 <alltraps>

80105e2f <vector201>:
.globl vector201
vector201:
  pushl $0
80105e2f:	6a 00                	push   $0x0
  pushl $201
80105e31:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105e36:	e9 75 f3 ff ff       	jmp    801051b0 <alltraps>

80105e3b <vector202>:
.globl vector202
vector202:
  pushl $0
80105e3b:	6a 00                	push   $0x0
  pushl $202
80105e3d:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105e42:	e9 69 f3 ff ff       	jmp    801051b0 <alltraps>

80105e47 <vector203>:
.globl vector203
vector203:
  pushl $0
80105e47:	6a 00                	push   $0x0
  pushl $203
80105e49:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105e4e:	e9 5d f3 ff ff       	jmp    801051b0 <alltraps>

80105e53 <vector204>:
.globl vector204
vector204:
  pushl $0
80105e53:	6a 00                	push   $0x0
  pushl $204
80105e55:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105e5a:	e9 51 f3 ff ff       	jmp    801051b0 <alltraps>

80105e5f <vector205>:
.globl vector205
vector205:
  pushl $0
80105e5f:	6a 00                	push   $0x0
  pushl $205
80105e61:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105e66:	e9 45 f3 ff ff       	jmp    801051b0 <alltraps>

80105e6b <vector206>:
.globl vector206
vector206:
  pushl $0
80105e6b:	6a 00                	push   $0x0
  pushl $206
80105e6d:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105e72:	e9 39 f3 ff ff       	jmp    801051b0 <alltraps>

80105e77 <vector207>:
.globl vector207
vector207:
  pushl $0
80105e77:	6a 00                	push   $0x0
  pushl $207
80105e79:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105e7e:	e9 2d f3 ff ff       	jmp    801051b0 <alltraps>

80105e83 <vector208>:
.globl vector208
vector208:
  pushl $0
80105e83:	6a 00                	push   $0x0
  pushl $208
80105e85:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105e8a:	e9 21 f3 ff ff       	jmp    801051b0 <alltraps>

80105e8f <vector209>:
.globl vector209
vector209:
  pushl $0
80105e8f:	6a 00                	push   $0x0
  pushl $209
80105e91:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105e96:	e9 15 f3 ff ff       	jmp    801051b0 <alltraps>

80105e9b <vector210>:
.globl vector210
vector210:
  pushl $0
80105e9b:	6a 00                	push   $0x0
  pushl $210
80105e9d:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105ea2:	e9 09 f3 ff ff       	jmp    801051b0 <alltraps>

80105ea7 <vector211>:
.globl vector211
vector211:
  pushl $0
80105ea7:	6a 00                	push   $0x0
  pushl $211
80105ea9:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105eae:	e9 fd f2 ff ff       	jmp    801051b0 <alltraps>

80105eb3 <vector212>:
.globl vector212
vector212:
  pushl $0
80105eb3:	6a 00                	push   $0x0
  pushl $212
80105eb5:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105eba:	e9 f1 f2 ff ff       	jmp    801051b0 <alltraps>

80105ebf <vector213>:
.globl vector213
vector213:
  pushl $0
80105ebf:	6a 00                	push   $0x0
  pushl $213
80105ec1:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105ec6:	e9 e5 f2 ff ff       	jmp    801051b0 <alltraps>

80105ecb <vector214>:
.globl vector214
vector214:
  pushl $0
80105ecb:	6a 00                	push   $0x0
  pushl $214
80105ecd:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105ed2:	e9 d9 f2 ff ff       	jmp    801051b0 <alltraps>

80105ed7 <vector215>:
.globl vector215
vector215:
  pushl $0
80105ed7:	6a 00                	push   $0x0
  pushl $215
80105ed9:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105ede:	e9 cd f2 ff ff       	jmp    801051b0 <alltraps>

80105ee3 <vector216>:
.globl vector216
vector216:
  pushl $0
80105ee3:	6a 00                	push   $0x0
  pushl $216
80105ee5:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105eea:	e9 c1 f2 ff ff       	jmp    801051b0 <alltraps>

80105eef <vector217>:
.globl vector217
vector217:
  pushl $0
80105eef:	6a 00                	push   $0x0
  pushl $217
80105ef1:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105ef6:	e9 b5 f2 ff ff       	jmp    801051b0 <alltraps>

80105efb <vector218>:
.globl vector218
vector218:
  pushl $0
80105efb:	6a 00                	push   $0x0
  pushl $218
80105efd:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105f02:	e9 a9 f2 ff ff       	jmp    801051b0 <alltraps>

80105f07 <vector219>:
.globl vector219
vector219:
  pushl $0
80105f07:	6a 00                	push   $0x0
  pushl $219
80105f09:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105f0e:	e9 9d f2 ff ff       	jmp    801051b0 <alltraps>

80105f13 <vector220>:
.globl vector220
vector220:
  pushl $0
80105f13:	6a 00                	push   $0x0
  pushl $220
80105f15:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105f1a:	e9 91 f2 ff ff       	jmp    801051b0 <alltraps>

80105f1f <vector221>:
.globl vector221
vector221:
  pushl $0
80105f1f:	6a 00                	push   $0x0
  pushl $221
80105f21:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105f26:	e9 85 f2 ff ff       	jmp    801051b0 <alltraps>

80105f2b <vector222>:
.globl vector222
vector222:
  pushl $0
80105f2b:	6a 00                	push   $0x0
  pushl $222
80105f2d:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105f32:	e9 79 f2 ff ff       	jmp    801051b0 <alltraps>

80105f37 <vector223>:
.globl vector223
vector223:
  pushl $0
80105f37:	6a 00                	push   $0x0
  pushl $223
80105f39:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105f3e:	e9 6d f2 ff ff       	jmp    801051b0 <alltraps>

80105f43 <vector224>:
.globl vector224
vector224:
  pushl $0
80105f43:	6a 00                	push   $0x0
  pushl $224
80105f45:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105f4a:	e9 61 f2 ff ff       	jmp    801051b0 <alltraps>

80105f4f <vector225>:
.globl vector225
vector225:
  pushl $0
80105f4f:	6a 00                	push   $0x0
  pushl $225
80105f51:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105f56:	e9 55 f2 ff ff       	jmp    801051b0 <alltraps>

80105f5b <vector226>:
.globl vector226
vector226:
  pushl $0
80105f5b:	6a 00                	push   $0x0
  pushl $226
80105f5d:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105f62:	e9 49 f2 ff ff       	jmp    801051b0 <alltraps>

80105f67 <vector227>:
.globl vector227
vector227:
  pushl $0
80105f67:	6a 00                	push   $0x0
  pushl $227
80105f69:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105f6e:	e9 3d f2 ff ff       	jmp    801051b0 <alltraps>

80105f73 <vector228>:
.globl vector228
vector228:
  pushl $0
80105f73:	6a 00                	push   $0x0
  pushl $228
80105f75:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105f7a:	e9 31 f2 ff ff       	jmp    801051b0 <alltraps>

80105f7f <vector229>:
.globl vector229
vector229:
  pushl $0
80105f7f:	6a 00                	push   $0x0
  pushl $229
80105f81:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105f86:	e9 25 f2 ff ff       	jmp    801051b0 <alltraps>

80105f8b <vector230>:
.globl vector230
vector230:
  pushl $0
80105f8b:	6a 00                	push   $0x0
  pushl $230
80105f8d:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105f92:	e9 19 f2 ff ff       	jmp    801051b0 <alltraps>

80105f97 <vector231>:
.globl vector231
vector231:
  pushl $0
80105f97:	6a 00                	push   $0x0
  pushl $231
80105f99:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105f9e:	e9 0d f2 ff ff       	jmp    801051b0 <alltraps>

80105fa3 <vector232>:
.globl vector232
vector232:
  pushl $0
80105fa3:	6a 00                	push   $0x0
  pushl $232
80105fa5:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105faa:	e9 01 f2 ff ff       	jmp    801051b0 <alltraps>

80105faf <vector233>:
.globl vector233
vector233:
  pushl $0
80105faf:	6a 00                	push   $0x0
  pushl $233
80105fb1:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105fb6:	e9 f5 f1 ff ff       	jmp    801051b0 <alltraps>

80105fbb <vector234>:
.globl vector234
vector234:
  pushl $0
80105fbb:	6a 00                	push   $0x0
  pushl $234
80105fbd:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105fc2:	e9 e9 f1 ff ff       	jmp    801051b0 <alltraps>

80105fc7 <vector235>:
.globl vector235
vector235:
  pushl $0
80105fc7:	6a 00                	push   $0x0
  pushl $235
80105fc9:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105fce:	e9 dd f1 ff ff       	jmp    801051b0 <alltraps>

80105fd3 <vector236>:
.globl vector236
vector236:
  pushl $0
80105fd3:	6a 00                	push   $0x0
  pushl $236
80105fd5:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105fda:	e9 d1 f1 ff ff       	jmp    801051b0 <alltraps>

80105fdf <vector237>:
.globl vector237
vector237:
  pushl $0
80105fdf:	6a 00                	push   $0x0
  pushl $237
80105fe1:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105fe6:	e9 c5 f1 ff ff       	jmp    801051b0 <alltraps>

80105feb <vector238>:
.globl vector238
vector238:
  pushl $0
80105feb:	6a 00                	push   $0x0
  pushl $238
80105fed:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105ff2:	e9 b9 f1 ff ff       	jmp    801051b0 <alltraps>

80105ff7 <vector239>:
.globl vector239
vector239:
  pushl $0
80105ff7:	6a 00                	push   $0x0
  pushl $239
80105ff9:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105ffe:	e9 ad f1 ff ff       	jmp    801051b0 <alltraps>

80106003 <vector240>:
.globl vector240
vector240:
  pushl $0
80106003:	6a 00                	push   $0x0
  pushl $240
80106005:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010600a:	e9 a1 f1 ff ff       	jmp    801051b0 <alltraps>

8010600f <vector241>:
.globl vector241
vector241:
  pushl $0
8010600f:	6a 00                	push   $0x0
  pushl $241
80106011:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106016:	e9 95 f1 ff ff       	jmp    801051b0 <alltraps>

8010601b <vector242>:
.globl vector242
vector242:
  pushl $0
8010601b:	6a 00                	push   $0x0
  pushl $242
8010601d:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106022:	e9 89 f1 ff ff       	jmp    801051b0 <alltraps>

80106027 <vector243>:
.globl vector243
vector243:
  pushl $0
80106027:	6a 00                	push   $0x0
  pushl $243
80106029:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010602e:	e9 7d f1 ff ff       	jmp    801051b0 <alltraps>

80106033 <vector244>:
.globl vector244
vector244:
  pushl $0
80106033:	6a 00                	push   $0x0
  pushl $244
80106035:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010603a:	e9 71 f1 ff ff       	jmp    801051b0 <alltraps>

8010603f <vector245>:
.globl vector245
vector245:
  pushl $0
8010603f:	6a 00                	push   $0x0
  pushl $245
80106041:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106046:	e9 65 f1 ff ff       	jmp    801051b0 <alltraps>

8010604b <vector246>:
.globl vector246
vector246:
  pushl $0
8010604b:	6a 00                	push   $0x0
  pushl $246
8010604d:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106052:	e9 59 f1 ff ff       	jmp    801051b0 <alltraps>

80106057 <vector247>:
.globl vector247
vector247:
  pushl $0
80106057:	6a 00                	push   $0x0
  pushl $247
80106059:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
8010605e:	e9 4d f1 ff ff       	jmp    801051b0 <alltraps>

80106063 <vector248>:
.globl vector248
vector248:
  pushl $0
80106063:	6a 00                	push   $0x0
  pushl $248
80106065:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010606a:	e9 41 f1 ff ff       	jmp    801051b0 <alltraps>

8010606f <vector249>:
.globl vector249
vector249:
  pushl $0
8010606f:	6a 00                	push   $0x0
  pushl $249
80106071:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106076:	e9 35 f1 ff ff       	jmp    801051b0 <alltraps>

8010607b <vector250>:
.globl vector250
vector250:
  pushl $0
8010607b:	6a 00                	push   $0x0
  pushl $250
8010607d:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106082:	e9 29 f1 ff ff       	jmp    801051b0 <alltraps>

80106087 <vector251>:
.globl vector251
vector251:
  pushl $0
80106087:	6a 00                	push   $0x0
  pushl $251
80106089:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
8010608e:	e9 1d f1 ff ff       	jmp    801051b0 <alltraps>

80106093 <vector252>:
.globl vector252
vector252:
  pushl $0
80106093:	6a 00                	push   $0x0
  pushl $252
80106095:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010609a:	e9 11 f1 ff ff       	jmp    801051b0 <alltraps>

8010609f <vector253>:
.globl vector253
vector253:
  pushl $0
8010609f:	6a 00                	push   $0x0
  pushl $253
801060a1:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801060a6:	e9 05 f1 ff ff       	jmp    801051b0 <alltraps>

801060ab <vector254>:
.globl vector254
vector254:
  pushl $0
801060ab:	6a 00                	push   $0x0
  pushl $254
801060ad:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801060b2:	e9 f9 f0 ff ff       	jmp    801051b0 <alltraps>

801060b7 <vector255>:
.globl vector255
vector255:
  pushl $0
801060b7:	6a 00                	push   $0x0
  pushl $255
801060b9:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801060be:	e9 ed f0 ff ff       	jmp    801051b0 <alltraps>

801060c3 <walkpgdir>:

// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801060c3:	55                   	push   %ebp
801060c4:	89 e5                	mov    %esp,%ebp
801060c6:	57                   	push   %edi
801060c7:	56                   	push   %esi
801060c8:	53                   	push   %ebx
801060c9:	83 ec 0c             	sub    $0xc,%esp
801060cc:	89 d6                	mov    %edx,%esi
    pde_t *pde;
    pte_t *pgtab;

    pde = &pgdir[PDX(va)];
801060ce:	c1 ea 16             	shr    $0x16,%edx
801060d1:	8d 3c 90             	lea    (%eax,%edx,4),%edi
    if (*pde & PTE_P) {
801060d4:	8b 1f                	mov    (%edi),%ebx
801060d6:	f6 c3 01             	test   $0x1,%bl
801060d9:	74 21                	je     801060fc <walkpgdir+0x39>
        pgtab = (pte_t *)P2V(PTE_ADDR(*pde));
801060db:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
801060e1:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
        // The permissions here are overly generous, but they can
        // be further restricted by the permissions in the page table
        // entries, if necessary.
        *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
    }
    return &pgtab[PTX(va)];
801060e7:	c1 ee 0a             	shr    $0xa,%esi
801060ea:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
801060f0:	01 f3                	add    %esi,%ebx
}
801060f2:	89 d8                	mov    %ebx,%eax
801060f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060f7:	5b                   	pop    %ebx
801060f8:	5e                   	pop    %esi
801060f9:	5f                   	pop    %edi
801060fa:	5d                   	pop    %ebp
801060fb:	c3                   	ret    
        if (!alloc || (pgtab = (pte_t *)kalloc()) == 0)
801060fc:	85 c9                	test   %ecx,%ecx
801060fe:	74 2b                	je     8010612b <walkpgdir+0x68>
80106100:	e8 59 c0 ff ff       	call   8010215e <kalloc>
80106105:	89 c3                	mov    %eax,%ebx
80106107:	85 c0                	test   %eax,%eax
80106109:	74 e7                	je     801060f2 <walkpgdir+0x2f>
        memset(pgtab, 0, PGSIZE);
8010610b:	83 ec 04             	sub    $0x4,%esp
8010610e:	68 00 10 00 00       	push   $0x1000
80106113:	6a 00                	push   $0x0
80106115:	50                   	push   %eax
80106116:	e8 08 e0 ff ff       	call   80104123 <memset>
        *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010611b:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106121:	83 c8 07             	or     $0x7,%eax
80106124:	89 07                	mov    %eax,(%edi)
80106126:	83 c4 10             	add    $0x10,%esp
80106129:	eb bc                	jmp    801060e7 <walkpgdir+0x24>
            return 0;
8010612b:	bb 00 00 00 00       	mov    $0x0,%ebx
80106130:	eb c0                	jmp    801060f2 <walkpgdir+0x2f>

80106132 <mappages>:

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106132:	55                   	push   %ebp
80106133:	89 e5                	mov    %esp,%ebp
80106135:	57                   	push   %edi
80106136:	56                   	push   %esi
80106137:	53                   	push   %ebx
80106138:	83 ec 1c             	sub    $0x1c,%esp
8010613b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    char *a, *last;
    pte_t *pte;

    a = (char *)PGROUNDDOWN((uint)va);
8010613e:	89 d0                	mov    %edx,%eax
80106140:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106145:	89 c3                	mov    %eax,%ebx
    last = (char *)PGROUNDDOWN(((uint)va) + size - 1);
80106147:	8d 54 0a ff          	lea    -0x1(%edx,%ecx,1),%edx
8010614b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80106151:	89 55 e0             	mov    %edx,-0x20(%ebp)
80106154:	8b 7d 08             	mov    0x8(%ebp),%edi
80106157:	29 c7                	sub    %eax,%edi
    for (;;) {
        if ((pte = walkpgdir(pgdir, a, 1)) == 0)
            return -1;
        if (*pte & PTE_P)
            panic("remap");
        *pte = pa | perm | PTE_P;
80106159:	8b 45 0c             	mov    0xc(%ebp),%eax
8010615c:	83 c8 01             	or     $0x1,%eax
8010615f:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106162:	8d 34 3b             	lea    (%ebx,%edi,1),%esi
        if ((pte = walkpgdir(pgdir, a, 1)) == 0)
80106165:	b9 01 00 00 00       	mov    $0x1,%ecx
8010616a:	89 da                	mov    %ebx,%edx
8010616c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010616f:	e8 4f ff ff ff       	call   801060c3 <walkpgdir>
80106174:	85 c0                	test   %eax,%eax
80106176:	74 24                	je     8010619c <mappages+0x6a>
        if (*pte & PTE_P)
80106178:	f6 00 01             	testb  $0x1,(%eax)
8010617b:	75 12                	jne    8010618f <mappages+0x5d>
        *pte = pa | perm | PTE_P;
8010617d:	0b 75 dc             	or     -0x24(%ebp),%esi
80106180:	89 30                	mov    %esi,(%eax)
        if (a == last)
80106182:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
80106185:	74 22                	je     801061a9 <mappages+0x77>
            break;
        a += PGSIZE;
80106187:	81 c3 00 10 00 00    	add    $0x1000,%ebx
        if ((pte = walkpgdir(pgdir, a, 1)) == 0)
8010618d:	eb d3                	jmp    80106162 <mappages+0x30>
            panic("remap");
8010618f:	83 ec 0c             	sub    $0xc,%esp
80106192:	68 cc 71 10 80       	push   $0x801071cc
80106197:	e8 a8 a1 ff ff       	call   80100344 <panic>
            return -1;
8010619c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
        pa += PGSIZE;
    }
    return 0;
}
801061a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061a4:	5b                   	pop    %ebx
801061a5:	5e                   	pop    %esi
801061a6:	5f                   	pop    %edi
801061a7:	5d                   	pop    %ebp
801061a8:	c3                   	ret    
    return 0;
801061a9:	b8 00 00 00 00       	mov    $0x0,%eax
801061ae:	eb f1                	jmp    801061a1 <mappages+0x6f>

801061b0 <seginit>:
{
801061b0:	55                   	push   %ebp
801061b1:	89 e5                	mov    %esp,%ebp
801061b3:	83 ec 18             	sub    $0x18,%esp
    c = &cpus[cpuid()];
801061b6:	e8 f5 d2 ff ff       	call   801034b0 <cpuid>
    c->gdt[SEG_KCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, 0);
801061bb:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801061c1:	66 c7 80 f8 27 11 80 	movw   $0xffff,-0x7feed808(%eax)
801061c8:	ff ff 
801061ca:	66 c7 80 fa 27 11 80 	movw   $0x0,-0x7feed806(%eax)
801061d1:	00 00 
801061d3:	c6 80 fc 27 11 80 00 	movb   $0x0,-0x7feed804(%eax)
801061da:	c6 80 fd 27 11 80 9a 	movb   $0x9a,-0x7feed803(%eax)
801061e1:	c6 80 fe 27 11 80 cf 	movb   $0xcf,-0x7feed802(%eax)
801061e8:	c6 80 ff 27 11 80 00 	movb   $0x0,-0x7feed801(%eax)
    c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801061ef:	66 c7 80 00 28 11 80 	movw   $0xffff,-0x7feed800(%eax)
801061f6:	ff ff 
801061f8:	66 c7 80 02 28 11 80 	movw   $0x0,-0x7feed7fe(%eax)
801061ff:	00 00 
80106201:	c6 80 04 28 11 80 00 	movb   $0x0,-0x7feed7fc(%eax)
80106208:	c6 80 05 28 11 80 92 	movb   $0x92,-0x7feed7fb(%eax)
8010620f:	c6 80 06 28 11 80 cf 	movb   $0xcf,-0x7feed7fa(%eax)
80106216:	c6 80 07 28 11 80 00 	movb   $0x0,-0x7feed7f9(%eax)
    c->gdt[SEG_UCODE] = SEG(STA_X | STA_R, 0, 0xffffffff, DPL_USER);
8010621d:	66 c7 80 08 28 11 80 	movw   $0xffff,-0x7feed7f8(%eax)
80106224:	ff ff 
80106226:	66 c7 80 0a 28 11 80 	movw   $0x0,-0x7feed7f6(%eax)
8010622d:	00 00 
8010622f:	c6 80 0c 28 11 80 00 	movb   $0x0,-0x7feed7f4(%eax)
80106236:	c6 80 0d 28 11 80 fa 	movb   $0xfa,-0x7feed7f3(%eax)
8010623d:	c6 80 0e 28 11 80 cf 	movb   $0xcf,-0x7feed7f2(%eax)
80106244:	c6 80 0f 28 11 80 00 	movb   $0x0,-0x7feed7f1(%eax)
    c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010624b:	66 c7 80 10 28 11 80 	movw   $0xffff,-0x7feed7f0(%eax)
80106252:	ff ff 
80106254:	66 c7 80 12 28 11 80 	movw   $0x0,-0x7feed7ee(%eax)
8010625b:	00 00 
8010625d:	c6 80 14 28 11 80 00 	movb   $0x0,-0x7feed7ec(%eax)
80106264:	c6 80 15 28 11 80 f2 	movb   $0xf2,-0x7feed7eb(%eax)
8010626b:	c6 80 16 28 11 80 cf 	movb   $0xcf,-0x7feed7ea(%eax)
80106272:	c6 80 17 28 11 80 00 	movb   $0x0,-0x7feed7e9(%eax)
    lgdt(c->gdt, sizeof(c->gdt));
80106279:	05 f0 27 11 80       	add    $0x801127f0,%eax
    pd[0] = size - 1;
8010627e:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
    pd[1] = (uint)p;
80106284:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
    pd[2] = (uint)p >> 16;
80106288:	c1 e8 10             	shr    $0x10,%eax
8010628b:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
    asm volatile("lgdt (%0)" : : "r"(pd));
8010628f:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106292:	0f 01 10             	lgdtl  (%eax)
}
80106295:	c9                   	leave  
80106296:	c3                   	ret    

80106297 <switchkvm>:
}

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void switchkvm(void)
{
80106297:	55                   	push   %ebp
80106298:	89 e5                	mov    %esp,%ebp
    lcr3(V2P(kpgdir)); // switch to the kernel page table
8010629a:	a1 a4 5a 11 80       	mov    0x80115aa4,%eax
8010629f:	05 00 00 00 80       	add    $0x80000000,%eax
    return val;
}

static inline void lcr3(uint val)
{
    asm volatile("movl %0,%%cr3" : : "r"(val));
801062a4:	0f 22 d8             	mov    %eax,%cr3
}
801062a7:	5d                   	pop    %ebp
801062a8:	c3                   	ret    

801062a9 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void switchuvm(struct proc *p)
{
801062a9:	55                   	push   %ebp
801062aa:	89 e5                	mov    %esp,%ebp
801062ac:	57                   	push   %edi
801062ad:	56                   	push   %esi
801062ae:	53                   	push   %ebx
801062af:	83 ec 1c             	sub    $0x1c,%esp
801062b2:	8b 75 08             	mov    0x8(%ebp),%esi
    if (p == 0)
801062b5:	85 f6                	test   %esi,%esi
801062b7:	0f 84 c3 00 00 00    	je     80106380 <switchuvm+0xd7>
        panic("switchuvm: no process");
    if (p->kstack == 0)
801062bd:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
801062c1:	0f 84 c6 00 00 00    	je     8010638d <switchuvm+0xe4>
        panic("switchuvm: no kstack");
    if (p->pgdir == 0)
801062c7:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
801062cb:	0f 84 c9 00 00 00    	je     8010639a <switchuvm+0xf1>
        panic("switchuvm: no pgdir");

    pushcli();
801062d1:	e8 ce dc ff ff       	call   80103fa4 <pushcli>
    mycpu()->gdt[SEG_TSS] =
801062d6:	e8 5e d1 ff ff       	call   80103439 <mycpu>
801062db:	89 c3                	mov    %eax,%ebx
        SEG16(STS_T32A, &mycpu()->ts, sizeof(mycpu()->ts) - 1, 0);
801062dd:	e8 57 d1 ff ff       	call   80103439 <mycpu>
801062e2:	89 c7                	mov    %eax,%edi
801062e4:	e8 50 d1 ff ff       	call   80103439 <mycpu>
801062e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801062ec:	e8 48 d1 ff ff       	call   80103439 <mycpu>
    mycpu()->gdt[SEG_TSS] =
801062f1:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801062f8:	67 00 
        SEG16(STS_T32A, &mycpu()->ts, sizeof(mycpu()->ts) - 1, 0);
801062fa:	83 c7 08             	add    $0x8,%edi
    mycpu()->gdt[SEG_TSS] =
801062fd:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
        SEG16(STS_T32A, &mycpu()->ts, sizeof(mycpu()->ts) - 1, 0);
80106304:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106307:	83 c2 08             	add    $0x8,%edx
8010630a:	c1 ea 10             	shr    $0x10,%edx
    mycpu()->gdt[SEG_TSS] =
8010630d:	88 93 9c 00 00 00    	mov    %dl,0x9c(%ebx)
80106313:	c6 83 9d 00 00 00 99 	movb   $0x99,0x9d(%ebx)
8010631a:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
        SEG16(STS_T32A, &mycpu()->ts, sizeof(mycpu()->ts) - 1, 0);
80106321:	83 c0 08             	add    $0x8,%eax
80106324:	c1 e8 18             	shr    $0x18,%eax
    mycpu()->gdt[SEG_TSS] =
80106327:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
    mycpu()->gdt[SEG_TSS].s = 0;
8010632d:	e8 07 d1 ff ff       	call   80103439 <mycpu>
80106332:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
    mycpu()->ts.ss0 = SEG_KDATA << 3;
80106339:	e8 fb d0 ff ff       	call   80103439 <mycpu>
8010633e:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
    mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106344:	8b 5e 08             	mov    0x8(%esi),%ebx
80106347:	e8 ed d0 ff ff       	call   80103439 <mycpu>
8010634c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106352:	89 58 0c             	mov    %ebx,0xc(%eax)
    // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
    // forbids I/O instructions (e.g., inb and outb) from user space
    mycpu()->ts.iomb = (ushort)0xFFFF;
80106355:	e8 df d0 ff ff       	call   80103439 <mycpu>
8010635a:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
    asm volatile("ltr %0" : : "r"(sel));
80106360:	b8 28 00 00 00       	mov    $0x28,%eax
80106365:	0f 00 d8             	ltr    %ax
    ltr(SEG_TSS << 3);
    lcr3(V2P(p->pgdir)); // switch to process's address space
80106368:	8b 46 04             	mov    0x4(%esi),%eax
8010636b:	05 00 00 00 80       	add    $0x80000000,%eax
    asm volatile("movl %0,%%cr3" : : "r"(val));
80106370:	0f 22 d8             	mov    %eax,%cr3
    popcli();
80106373:	e8 69 dc ff ff       	call   80103fe1 <popcli>
}
80106378:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010637b:	5b                   	pop    %ebx
8010637c:	5e                   	pop    %esi
8010637d:	5f                   	pop    %edi
8010637e:	5d                   	pop    %ebp
8010637f:	c3                   	ret    
        panic("switchuvm: no process");
80106380:	83 ec 0c             	sub    $0xc,%esp
80106383:	68 d2 71 10 80       	push   $0x801071d2
80106388:	e8 b7 9f ff ff       	call   80100344 <panic>
        panic("switchuvm: no kstack");
8010638d:	83 ec 0c             	sub    $0xc,%esp
80106390:	68 e8 71 10 80       	push   $0x801071e8
80106395:	e8 aa 9f ff ff       	call   80100344 <panic>
        panic("switchuvm: no pgdir");
8010639a:	83 ec 0c             	sub    $0xc,%esp
8010639d:	68 fd 71 10 80       	push   $0x801071fd
801063a2:	e8 9d 9f ff ff       	call   80100344 <panic>

801063a7 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void inituvm(pde_t *pgdir, char *init, uint sz)
{
801063a7:	55                   	push   %ebp
801063a8:	89 e5                	mov    %esp,%ebp
801063aa:	56                   	push   %esi
801063ab:	53                   	push   %ebx
801063ac:	8b 75 10             	mov    0x10(%ebp),%esi
    char *mem;

    if (sz >= PGSIZE)
801063af:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801063b5:	77 4c                	ja     80106403 <inituvm+0x5c>
        panic("inituvm: more than a page");
    mem = kalloc();
801063b7:	e8 a2 bd ff ff       	call   8010215e <kalloc>
801063bc:	89 c3                	mov    %eax,%ebx
    memset(mem, 0, PGSIZE);
801063be:	83 ec 04             	sub    $0x4,%esp
801063c1:	68 00 10 00 00       	push   $0x1000
801063c6:	6a 00                	push   $0x0
801063c8:	50                   	push   %eax
801063c9:	e8 55 dd ff ff       	call   80104123 <memset>
    mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W | PTE_U);
801063ce:	83 c4 08             	add    $0x8,%esp
801063d1:	6a 06                	push   $0x6
801063d3:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801063d9:	50                   	push   %eax
801063da:	b9 00 10 00 00       	mov    $0x1000,%ecx
801063df:	ba 00 00 00 00       	mov    $0x0,%edx
801063e4:	8b 45 08             	mov    0x8(%ebp),%eax
801063e7:	e8 46 fd ff ff       	call   80106132 <mappages>
    memmove(mem, init, sz);
801063ec:	83 c4 0c             	add    $0xc,%esp
801063ef:	56                   	push   %esi
801063f0:	ff 75 0c             	pushl  0xc(%ebp)
801063f3:	53                   	push   %ebx
801063f4:	e8 bf dd ff ff       	call   801041b8 <memmove>
}
801063f9:	83 c4 10             	add    $0x10,%esp
801063fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801063ff:	5b                   	pop    %ebx
80106400:	5e                   	pop    %esi
80106401:	5d                   	pop    %ebp
80106402:	c3                   	ret    
        panic("inituvm: more than a page");
80106403:	83 ec 0c             	sub    $0xc,%esp
80106406:	68 11 72 10 80       	push   $0x80107211
8010640b:	e8 34 9f ff ff       	call   80100344 <panic>

80106410 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106410:	55                   	push   %ebp
80106411:	89 e5                	mov    %esp,%ebp
80106413:	57                   	push   %edi
80106414:	56                   	push   %esi
80106415:	53                   	push   %ebx
80106416:	83 ec 1c             	sub    $0x1c,%esp
80106419:	8b 45 0c             	mov    0xc(%ebp),%eax
    uint i, pa, n;
    pte_t *pte;

    if ((uint)addr % PGSIZE != 0)
8010641c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010641f:	a9 ff 0f 00 00       	test   $0xfff,%eax
80106424:	75 71                	jne    80106497 <loaduvm+0x87>
        panic("loaduvm: addr must be page aligned");
    for (i = 0; i < sz; i += PGSIZE) {
80106426:	8b 75 18             	mov    0x18(%ebp),%esi
80106429:	bb 00 00 00 00       	mov    $0x0,%ebx
        else
            n = PGSIZE;
        if (readi(ip, P2V(pa), offset + i, n) != n)
            return -1;
    }
    return 0;
8010642e:	b8 00 00 00 00       	mov    $0x0,%eax
    for (i = 0; i < sz; i += PGSIZE) {
80106433:	85 f6                	test   %esi,%esi
80106435:	74 7f                	je     801064b6 <loaduvm+0xa6>
        if ((pte = walkpgdir(pgdir, addr + i, 0)) == 0)
80106437:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010643a:	8d 14 18             	lea    (%eax,%ebx,1),%edx
8010643d:	b9 00 00 00 00       	mov    $0x0,%ecx
80106442:	8b 45 08             	mov    0x8(%ebp),%eax
80106445:	e8 79 fc ff ff       	call   801060c3 <walkpgdir>
8010644a:	85 c0                	test   %eax,%eax
8010644c:	74 56                	je     801064a4 <loaduvm+0x94>
        pa = PTE_ADDR(*pte);
8010644e:	8b 00                	mov    (%eax),%eax
80106450:	25 00 f0 ff ff       	and    $0xfffff000,%eax
            n = sz - i;
80106455:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010645b:	bf 00 10 00 00       	mov    $0x1000,%edi
80106460:	0f 46 fe             	cmovbe %esi,%edi
        if (readi(ip, P2V(pa), offset + i, n) != n)
80106463:	57                   	push   %edi
80106464:	89 da                	mov    %ebx,%edx
80106466:	03 55 14             	add    0x14(%ebp),%edx
80106469:	52                   	push   %edx
8010646a:	05 00 00 00 80       	add    $0x80000000,%eax
8010646f:	50                   	push   %eax
80106470:	ff 75 10             	pushl  0x10(%ebp)
80106473:	e8 02 b3 ff ff       	call   8010177a <readi>
80106478:	83 c4 10             	add    $0x10,%esp
8010647b:	39 f8                	cmp    %edi,%eax
8010647d:	75 32                	jne    801064b1 <loaduvm+0xa1>
    for (i = 0; i < sz; i += PGSIZE) {
8010647f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106485:	81 ee 00 10 00 00    	sub    $0x1000,%esi
8010648b:	39 5d 18             	cmp    %ebx,0x18(%ebp)
8010648e:	77 a7                	ja     80106437 <loaduvm+0x27>
    return 0;
80106490:	b8 00 00 00 00       	mov    $0x0,%eax
80106495:	eb 1f                	jmp    801064b6 <loaduvm+0xa6>
        panic("loaduvm: addr must be page aligned");
80106497:	83 ec 0c             	sub    $0xc,%esp
8010649a:	68 cc 72 10 80       	push   $0x801072cc
8010649f:	e8 a0 9e ff ff       	call   80100344 <panic>
            panic("loaduvm: address should exist");
801064a4:	83 ec 0c             	sub    $0xc,%esp
801064a7:	68 2b 72 10 80       	push   $0x8010722b
801064ac:	e8 93 9e ff ff       	call   80100344 <panic>
            return -1;
801064b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801064b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064b9:	5b                   	pop    %ebx
801064ba:	5e                   	pop    %esi
801064bb:	5f                   	pop    %edi
801064bc:	5d                   	pop    %ebp
801064bd:	c3                   	ret    

801064be <deallocuvm>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801064be:	55                   	push   %ebp
801064bf:	89 e5                	mov    %esp,%ebp
801064c1:	57                   	push   %edi
801064c2:	56                   	push   %esi
801064c3:	53                   	push   %ebx
801064c4:	83 ec 0c             	sub    $0xc,%esp
801064c7:	8b 7d 0c             	mov    0xc(%ebp),%edi
    pte_t *pte;
    uint a, pa;

    if (newsz >= oldsz)
        return oldsz;
801064ca:	89 f8                	mov    %edi,%eax
    if (newsz >= oldsz)
801064cc:	39 7d 10             	cmp    %edi,0x10(%ebp)
801064cf:	73 16                	jae    801064e7 <deallocuvm+0x29>

    a = PGROUNDUP(newsz);
801064d1:	8b 45 10             	mov    0x10(%ebp),%eax
801064d4:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801064da:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    for (; a < oldsz; a += PGSIZE) {
801064e0:	39 df                	cmp    %ebx,%edi
801064e2:	77 21                	ja     80106505 <deallocuvm+0x47>
            char *v = P2V(pa);
            kfree(v);
            *pte = 0;
        }
    }
    return newsz;
801064e4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801064e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064ea:	5b                   	pop    %ebx
801064eb:	5e                   	pop    %esi
801064ec:	5f                   	pop    %edi
801064ed:	5d                   	pop    %ebp
801064ee:	c3                   	ret    
            a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801064ef:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
801064f5:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx
    for (; a < oldsz; a += PGSIZE) {
801064fb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106501:	39 df                	cmp    %ebx,%edi
80106503:	76 df                	jbe    801064e4 <deallocuvm+0x26>
        pte = walkpgdir(pgdir, (char *)a, 0);
80106505:	b9 00 00 00 00       	mov    $0x0,%ecx
8010650a:	89 da                	mov    %ebx,%edx
8010650c:	8b 45 08             	mov    0x8(%ebp),%eax
8010650f:	e8 af fb ff ff       	call   801060c3 <walkpgdir>
80106514:	89 c6                	mov    %eax,%esi
        if (!pte)
80106516:	85 c0                	test   %eax,%eax
80106518:	74 d5                	je     801064ef <deallocuvm+0x31>
        else if ((*pte & PTE_P) != 0) {
8010651a:	8b 00                	mov    (%eax),%eax
8010651c:	a8 01                	test   $0x1,%al
8010651e:	74 db                	je     801064fb <deallocuvm+0x3d>
            if (pa == 0)
80106520:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106525:	74 19                	je     80106540 <deallocuvm+0x82>
            kfree(v);
80106527:	83 ec 0c             	sub    $0xc,%esp
            char *v = P2V(pa);
8010652a:	05 00 00 00 80       	add    $0x80000000,%eax
            kfree(v);
8010652f:	50                   	push   %eax
80106530:	e8 04 bb ff ff       	call   80102039 <kfree>
            *pte = 0;
80106535:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010653b:	83 c4 10             	add    $0x10,%esp
8010653e:	eb bb                	jmp    801064fb <deallocuvm+0x3d>
                panic("kfree");
80106540:	83 ec 0c             	sub    $0xc,%esp
80106543:	68 66 6b 10 80       	push   $0x80106b66
80106548:	e8 f7 9d ff ff       	call   80100344 <panic>

8010654d <allocuvm>:
{
8010654d:	55                   	push   %ebp
8010654e:	89 e5                	mov    %esp,%ebp
80106550:	57                   	push   %edi
80106551:	56                   	push   %esi
80106552:	53                   	push   %ebx
80106553:	83 ec 1c             	sub    $0x1c,%esp
80106556:	8b 7d 10             	mov    0x10(%ebp),%edi
    if (newsz >= KERNBASE)
80106559:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010655c:	85 ff                	test   %edi,%edi
8010655e:	0f 88 c5 00 00 00    	js     80106629 <allocuvm+0xdc>
    if (newsz < oldsz)
80106564:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106567:	72 60                	jb     801065c9 <allocuvm+0x7c>
    a = PGROUNDUP(oldsz);
80106569:	8b 45 0c             	mov    0xc(%ebp),%eax
8010656c:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106572:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    for (; a < newsz; a += PGSIZE) {
80106578:	39 df                	cmp    %ebx,%edi
8010657a:	0f 86 b0 00 00 00    	jbe    80106630 <allocuvm+0xe3>
        mem = kalloc();
80106580:	e8 d9 bb ff ff       	call   8010215e <kalloc>
80106585:	89 c6                	mov    %eax,%esi
        if (mem == 0) {
80106587:	85 c0                	test   %eax,%eax
80106589:	74 46                	je     801065d1 <allocuvm+0x84>
        memset(mem, 0, PGSIZE);
8010658b:	83 ec 04             	sub    $0x4,%esp
8010658e:	68 00 10 00 00       	push   $0x1000
80106593:	6a 00                	push   $0x0
80106595:	50                   	push   %eax
80106596:	e8 88 db ff ff       	call   80104123 <memset>
        if (mappages(pgdir, (char *)a, PGSIZE, V2P(mem), PTE_W | PTE_U) < 0) {
8010659b:	83 c4 08             	add    $0x8,%esp
8010659e:	6a 06                	push   $0x6
801065a0:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801065a6:	50                   	push   %eax
801065a7:	b9 00 10 00 00       	mov    $0x1000,%ecx
801065ac:	89 da                	mov    %ebx,%edx
801065ae:	8b 45 08             	mov    0x8(%ebp),%eax
801065b1:	e8 7c fb ff ff       	call   80106132 <mappages>
801065b6:	83 c4 10             	add    $0x10,%esp
801065b9:	85 c0                	test   %eax,%eax
801065bb:	78 3c                	js     801065f9 <allocuvm+0xac>
    for (; a < newsz; a += PGSIZE) {
801065bd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801065c3:	39 df                	cmp    %ebx,%edi
801065c5:	77 b9                	ja     80106580 <allocuvm+0x33>
801065c7:	eb 67                	jmp    80106630 <allocuvm+0xe3>
        return oldsz;
801065c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801065cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801065cf:	eb 5f                	jmp    80106630 <allocuvm+0xe3>
            cprintf("allocuvm out of memory\n");
801065d1:	83 ec 0c             	sub    $0xc,%esp
801065d4:	68 49 72 10 80       	push   $0x80107249
801065d9:	e8 03 a0 ff ff       	call   801005e1 <cprintf>
            deallocuvm(pgdir, newsz, oldsz);
801065de:	83 c4 0c             	add    $0xc,%esp
801065e1:	ff 75 0c             	pushl  0xc(%ebp)
801065e4:	57                   	push   %edi
801065e5:	ff 75 08             	pushl  0x8(%ebp)
801065e8:	e8 d1 fe ff ff       	call   801064be <deallocuvm>
            return 0;
801065ed:	83 c4 10             	add    $0x10,%esp
801065f0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801065f7:	eb 37                	jmp    80106630 <allocuvm+0xe3>
            cprintf("allocuvm out of memory (2)\n");
801065f9:	83 ec 0c             	sub    $0xc,%esp
801065fc:	68 61 72 10 80       	push   $0x80107261
80106601:	e8 db 9f ff ff       	call   801005e1 <cprintf>
            deallocuvm(pgdir, newsz, oldsz);
80106606:	83 c4 0c             	add    $0xc,%esp
80106609:	ff 75 0c             	pushl  0xc(%ebp)
8010660c:	57                   	push   %edi
8010660d:	ff 75 08             	pushl  0x8(%ebp)
80106610:	e8 a9 fe ff ff       	call   801064be <deallocuvm>
            kfree(mem);
80106615:	89 34 24             	mov    %esi,(%esp)
80106618:	e8 1c ba ff ff       	call   80102039 <kfree>
            return 0;
8010661d:	83 c4 10             	add    $0x10,%esp
80106620:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106627:	eb 07                	jmp    80106630 <allocuvm+0xe3>
        return 0;
80106629:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106630:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106633:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106636:	5b                   	pop    %ebx
80106637:	5e                   	pop    %esi
80106638:	5f                   	pop    %edi
80106639:	5d                   	pop    %ebp
8010663a:	c3                   	ret    

8010663b <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void freevm(pde_t *pgdir)
{
8010663b:	55                   	push   %ebp
8010663c:	89 e5                	mov    %esp,%ebp
8010663e:	57                   	push   %edi
8010663f:	56                   	push   %esi
80106640:	53                   	push   %ebx
80106641:	83 ec 0c             	sub    $0xc,%esp
80106644:	8b 7d 08             	mov    0x8(%ebp),%edi
    uint i;

    if (pgdir == 0)
80106647:	85 ff                	test   %edi,%edi
80106649:	74 1d                	je     80106668 <freevm+0x2d>
        panic("freevm: no pgdir");
    deallocuvm(pgdir, KERNBASE, 0);
8010664b:	83 ec 04             	sub    $0x4,%esp
8010664e:	6a 00                	push   $0x0
80106650:	68 00 00 00 80       	push   $0x80000000
80106655:	57                   	push   %edi
80106656:	e8 63 fe ff ff       	call   801064be <deallocuvm>
8010665b:	89 fb                	mov    %edi,%ebx
8010665d:	8d b7 00 10 00 00    	lea    0x1000(%edi),%esi
80106663:	83 c4 10             	add    $0x10,%esp
80106666:	eb 14                	jmp    8010667c <freevm+0x41>
        panic("freevm: no pgdir");
80106668:	83 ec 0c             	sub    $0xc,%esp
8010666b:	68 7d 72 10 80       	push   $0x8010727d
80106670:	e8 cf 9c ff ff       	call   80100344 <panic>
80106675:	83 c3 04             	add    $0x4,%ebx
    for (i = 0; i < NPDENTRIES; i++) {
80106678:	39 f3                	cmp    %esi,%ebx
8010667a:	74 1e                	je     8010669a <freevm+0x5f>
        if (pgdir[i] & PTE_P) {
8010667c:	8b 03                	mov    (%ebx),%eax
8010667e:	a8 01                	test   $0x1,%al
80106680:	74 f3                	je     80106675 <freevm+0x3a>
            char *v = P2V(PTE_ADDR(pgdir[i]));
            kfree(v);
80106682:	83 ec 0c             	sub    $0xc,%esp
            char *v = P2V(PTE_ADDR(pgdir[i]));
80106685:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010668a:	05 00 00 00 80       	add    $0x80000000,%eax
            kfree(v);
8010668f:	50                   	push   %eax
80106690:	e8 a4 b9 ff ff       	call   80102039 <kfree>
80106695:	83 c4 10             	add    $0x10,%esp
80106698:	eb db                	jmp    80106675 <freevm+0x3a>
        }
    }
    kfree((char *)pgdir);
8010669a:	83 ec 0c             	sub    $0xc,%esp
8010669d:	57                   	push   %edi
8010669e:	e8 96 b9 ff ff       	call   80102039 <kfree>
}
801066a3:	83 c4 10             	add    $0x10,%esp
801066a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066a9:	5b                   	pop    %ebx
801066aa:	5e                   	pop    %esi
801066ab:	5f                   	pop    %edi
801066ac:	5d                   	pop    %ebp
801066ad:	c3                   	ret    

801066ae <setupkvm>:
{
801066ae:	55                   	push   %ebp
801066af:	89 e5                	mov    %esp,%ebp
801066b1:	56                   	push   %esi
801066b2:	53                   	push   %ebx
    if ((pgdir = (pde_t *)kalloc()) == 0)
801066b3:	e8 a6 ba ff ff       	call   8010215e <kalloc>
801066b8:	89 c6                	mov    %eax,%esi
801066ba:	85 c0                	test   %eax,%eax
801066bc:	74 42                	je     80106700 <setupkvm+0x52>
    memset(pgdir, 0, PGSIZE);
801066be:	83 ec 04             	sub    $0x4,%esp
801066c1:	68 00 10 00 00       	push   $0x1000
801066c6:	6a 00                	push   $0x0
801066c8:	50                   	push   %eax
801066c9:	e8 55 da ff ff       	call   80104123 <memset>
801066ce:	83 c4 10             	add    $0x10,%esp
    for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
801066d1:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
                     (uint)k->phys_start, k->perm) < 0) {
801066d6:	8b 43 04             	mov    0x4(%ebx),%eax
        if (mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801066d9:	8b 4b 08             	mov    0x8(%ebx),%ecx
801066dc:	29 c1                	sub    %eax,%ecx
801066de:	83 ec 08             	sub    $0x8,%esp
801066e1:	ff 73 0c             	pushl  0xc(%ebx)
801066e4:	50                   	push   %eax
801066e5:	8b 13                	mov    (%ebx),%edx
801066e7:	89 f0                	mov    %esi,%eax
801066e9:	e8 44 fa ff ff       	call   80106132 <mappages>
801066ee:	83 c4 10             	add    $0x10,%esp
801066f1:	85 c0                	test   %eax,%eax
801066f3:	78 14                	js     80106709 <setupkvm+0x5b>
    for (k = kmap; k < &kmap[NELEM(kmap)]; k++)
801066f5:	83 c3 10             	add    $0x10,%ebx
801066f8:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
801066fe:	75 d6                	jne    801066d6 <setupkvm+0x28>
}
80106700:	89 f0                	mov    %esi,%eax
80106702:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106705:	5b                   	pop    %ebx
80106706:	5e                   	pop    %esi
80106707:	5d                   	pop    %ebp
80106708:	c3                   	ret    
            freevm(pgdir);
80106709:	83 ec 0c             	sub    $0xc,%esp
8010670c:	56                   	push   %esi
8010670d:	e8 29 ff ff ff       	call   8010663b <freevm>
            return 0;
80106712:	83 c4 10             	add    $0x10,%esp
80106715:	be 00 00 00 00       	mov    $0x0,%esi
8010671a:	eb e4                	jmp    80106700 <setupkvm+0x52>

8010671c <kvmalloc>:
{
8010671c:	55                   	push   %ebp
8010671d:	89 e5                	mov    %esp,%ebp
8010671f:	83 ec 08             	sub    $0x8,%esp
    kpgdir = setupkvm();
80106722:	e8 87 ff ff ff       	call   801066ae <setupkvm>
80106727:	a3 a4 5a 11 80       	mov    %eax,0x80115aa4
    switchkvm();
8010672c:	e8 66 fb ff ff       	call   80106297 <switchkvm>
}
80106731:	c9                   	leave  
80106732:	c3                   	ret    

80106733 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void clearpteu(pde_t *pgdir, char *uva)
{
80106733:	55                   	push   %ebp
80106734:	89 e5                	mov    %esp,%ebp
80106736:	83 ec 08             	sub    $0x8,%esp
    pte_t *pte;

    pte = walkpgdir(pgdir, uva, 0);
80106739:	b9 00 00 00 00       	mov    $0x0,%ecx
8010673e:	8b 55 0c             	mov    0xc(%ebp),%edx
80106741:	8b 45 08             	mov    0x8(%ebp),%eax
80106744:	e8 7a f9 ff ff       	call   801060c3 <walkpgdir>
    if (pte == 0)
80106749:	85 c0                	test   %eax,%eax
8010674b:	74 05                	je     80106752 <clearpteu+0x1f>
        panic("clearpteu");
    *pte &= ~PTE_U;
8010674d:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106750:	c9                   	leave  
80106751:	c3                   	ret    
        panic("clearpteu");
80106752:	83 ec 0c             	sub    $0xc,%esp
80106755:	68 8e 72 10 80       	push   $0x8010728e
8010675a:	e8 e5 9b ff ff       	call   80100344 <panic>

8010675f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t *copyuvm(pde_t *pgdir, uint sz)
{
8010675f:	55                   	push   %ebp
80106760:	89 e5                	mov    %esp,%ebp
80106762:	57                   	push   %edi
80106763:	56                   	push   %esi
80106764:	53                   	push   %ebx
80106765:	83 ec 1c             	sub    $0x1c,%esp
    pde_t *d;
    pte_t *pte;
    uint pa, i, flags;
    char *mem;

    if ((d = setupkvm()) == 0)
80106768:	e8 41 ff ff ff       	call   801066ae <setupkvm>
8010676d:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106770:	85 c0                	test   %eax,%eax
80106772:	0f 84 c7 00 00 00    	je     8010683f <copyuvm+0xe0>
        return 0;
    for (i = 0; i < sz; i += PGSIZE) {
80106778:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010677c:	0f 84 bd 00 00 00    	je     8010683f <copyuvm+0xe0>
80106782:	bf 00 00 00 00       	mov    $0x0,%edi
        if ((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
80106787:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010678a:	b9 00 00 00 00       	mov    $0x0,%ecx
8010678f:	89 fa                	mov    %edi,%edx
80106791:	8b 45 08             	mov    0x8(%ebp),%eax
80106794:	e8 2a f9 ff ff       	call   801060c3 <walkpgdir>
80106799:	85 c0                	test   %eax,%eax
8010679b:	74 67                	je     80106804 <copyuvm+0xa5>
            panic("copyuvm: pte should exist");
        if (!(*pte & PTE_P))
8010679d:	8b 00                	mov    (%eax),%eax
8010679f:	a8 01                	test   $0x1,%al
801067a1:	74 6e                	je     80106811 <copyuvm+0xb2>
            panic("copyuvm: page not present");
        pa = PTE_ADDR(*pte);
801067a3:	89 c6                	mov    %eax,%esi
801067a5:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        flags = PTE_FLAGS(*pte);
801067ab:	25 ff 0f 00 00       	and    $0xfff,%eax
801067b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if ((mem = kalloc()) == 0)
801067b3:	e8 a6 b9 ff ff       	call   8010215e <kalloc>
801067b8:	89 c3                	mov    %eax,%ebx
801067ba:	85 c0                	test   %eax,%eax
801067bc:	74 6c                	je     8010682a <copyuvm+0xcb>
            goto bad;
        memmove(mem, (char *)P2V(pa), PGSIZE);
801067be:	83 ec 04             	sub    $0x4,%esp
801067c1:	68 00 10 00 00       	push   $0x1000
801067c6:	81 c6 00 00 00 80    	add    $0x80000000,%esi
801067cc:	56                   	push   %esi
801067cd:	50                   	push   %eax
801067ce:	e8 e5 d9 ff ff       	call   801041b8 <memmove>
        if (mappages(d, (void *)i, PGSIZE, V2P(mem), flags) < 0) {
801067d3:	83 c4 08             	add    $0x8,%esp
801067d6:	ff 75 e0             	pushl  -0x20(%ebp)
801067d9:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801067df:	50                   	push   %eax
801067e0:	b9 00 10 00 00       	mov    $0x1000,%ecx
801067e5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801067e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801067eb:	e8 42 f9 ff ff       	call   80106132 <mappages>
801067f0:	83 c4 10             	add    $0x10,%esp
801067f3:	85 c0                	test   %eax,%eax
801067f5:	78 27                	js     8010681e <copyuvm+0xbf>
    for (i = 0; i < sz; i += PGSIZE) {
801067f7:	81 c7 00 10 00 00    	add    $0x1000,%edi
801067fd:	39 7d 0c             	cmp    %edi,0xc(%ebp)
80106800:	77 85                	ja     80106787 <copyuvm+0x28>
80106802:	eb 3b                	jmp    8010683f <copyuvm+0xe0>
            panic("copyuvm: pte should exist");
80106804:	83 ec 0c             	sub    $0xc,%esp
80106807:	68 98 72 10 80       	push   $0x80107298
8010680c:	e8 33 9b ff ff       	call   80100344 <panic>
            panic("copyuvm: page not present");
80106811:	83 ec 0c             	sub    $0xc,%esp
80106814:	68 b2 72 10 80       	push   $0x801072b2
80106819:	e8 26 9b ff ff       	call   80100344 <panic>
            kfree(mem);
8010681e:	83 ec 0c             	sub    $0xc,%esp
80106821:	53                   	push   %ebx
80106822:	e8 12 b8 ff ff       	call   80102039 <kfree>
            goto bad;
80106827:	83 c4 10             	add    $0x10,%esp
        }
    }
    return d;

bad:
    freevm(d);
8010682a:	83 ec 0c             	sub    $0xc,%esp
8010682d:	ff 75 dc             	pushl  -0x24(%ebp)
80106830:	e8 06 fe ff ff       	call   8010663b <freevm>
    return 0;
80106835:	83 c4 10             	add    $0x10,%esp
80106838:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
8010683f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106842:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106845:	5b                   	pop    %ebx
80106846:	5e                   	pop    %esi
80106847:	5f                   	pop    %edi
80106848:	5d                   	pop    %ebp
80106849:	c3                   	ret    

8010684a <uva2ka>:

// PAGEBREAK!
//  Map user virtual address to kernel address.
char *uva2ka(pde_t *pgdir, char *uva)
{
8010684a:	55                   	push   %ebp
8010684b:	89 e5                	mov    %esp,%ebp
8010684d:	83 ec 08             	sub    $0x8,%esp
    pte_t *pte;

    pte = walkpgdir(pgdir, uva, 0);
80106850:	b9 00 00 00 00       	mov    $0x0,%ecx
80106855:	8b 55 0c             	mov    0xc(%ebp),%edx
80106858:	8b 45 08             	mov    0x8(%ebp),%eax
8010685b:	e8 63 f8 ff ff       	call   801060c3 <walkpgdir>
    if ((*pte & PTE_P) == 0)
80106860:	8b 00                	mov    (%eax),%eax
        return 0;
    if ((*pte & PTE_U) == 0)
80106862:	89 c2                	mov    %eax,%edx
80106864:	83 e2 05             	and    $0x5,%edx
        return 0;
    return (char *)P2V(PTE_ADDR(*pte));
80106867:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010686c:	05 00 00 00 80       	add    $0x80000000,%eax
80106871:	83 fa 05             	cmp    $0x5,%edx
80106874:	ba 00 00 00 00       	mov    $0x0,%edx
80106879:	0f 45 c2             	cmovne %edx,%eax
}
8010687c:	c9                   	leave  
8010687d:	c3                   	ret    

8010687e <copyout>:

// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010687e:	55                   	push   %ebp
8010687f:	89 e5                	mov    %esp,%ebp
80106881:	57                   	push   %edi
80106882:	56                   	push   %esi
80106883:	53                   	push   %ebx
80106884:	83 ec 0c             	sub    $0xc,%esp
80106887:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    char *buf, *pa0;
    uint n, va0;

    buf = (char *)p;
    while (len > 0) {
8010688a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010688e:	74 55                	je     801068e5 <copyout+0x67>
        va0 = (uint)PGROUNDDOWN(va);
80106890:	89 df                	mov    %ebx,%edi
80106892:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        pa0 = uva2ka(pgdir, (char *)va0);
80106898:	83 ec 08             	sub    $0x8,%esp
8010689b:	57                   	push   %edi
8010689c:	ff 75 08             	pushl  0x8(%ebp)
8010689f:	e8 a6 ff ff ff       	call   8010684a <uva2ka>
        if (pa0 == 0)
801068a4:	83 c4 10             	add    $0x10,%esp
801068a7:	85 c0                	test   %eax,%eax
801068a9:	74 41                	je     801068ec <copyout+0x6e>
            return -1;
        n = PGSIZE - (va - va0);
801068ab:	89 fe                	mov    %edi,%esi
801068ad:	29 de                	sub    %ebx,%esi
801068af:	81 c6 00 10 00 00    	add    $0x1000,%esi
801068b5:	3b 75 14             	cmp    0x14(%ebp),%esi
801068b8:	0f 47 75 14          	cmova  0x14(%ebp),%esi
        if (n > len)
            n = len;
        memmove(pa0 + (va - va0), buf, n);
801068bc:	83 ec 04             	sub    $0x4,%esp
801068bf:	56                   	push   %esi
801068c0:	ff 75 10             	pushl  0x10(%ebp)
801068c3:	29 fb                	sub    %edi,%ebx
801068c5:	01 d8                	add    %ebx,%eax
801068c7:	50                   	push   %eax
801068c8:	e8 eb d8 ff ff       	call   801041b8 <memmove>
        len -= n;
        buf += n;
801068cd:	01 75 10             	add    %esi,0x10(%ebp)
        va = va0 + PGSIZE;
801068d0:	8d 9f 00 10 00 00    	lea    0x1000(%edi),%ebx
    while (len > 0) {
801068d6:	83 c4 10             	add    $0x10,%esp
801068d9:	29 75 14             	sub    %esi,0x14(%ebp)
801068dc:	75 b2                	jne    80106890 <copyout+0x12>
    }
    return 0;
801068de:	b8 00 00 00 00       	mov    $0x0,%eax
801068e3:	eb 0c                	jmp    801068f1 <copyout+0x73>
801068e5:	b8 00 00 00 00       	mov    $0x0,%eax
801068ea:	eb 05                	jmp    801068f1 <copyout+0x73>
            return -1;
801068ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801068f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801068f4:	5b                   	pop    %ebx
801068f5:	5e                   	pop    %esi
801068f6:	5f                   	pop    %edi
801068f7:	5d                   	pop    %ebp
801068f8:	c3                   	ret    
