.text

.align 1

.global main

main:                   

    li x9,0x10000000    # BOX_INFO_BASE_ADDR
    li x28,0x10000438   # MAX_BOX_BASE_ADDR
    li x30,0x10000460   # RES_BASE_ADDR      # 栈指针用来存放基地址

    /* constants */
    li x5,0x11                  /* NUM_BOX=17*/
    li x6,0x3                  /* NUM_CLASS=3*/
    #li x5,0xe                  /* NUM_BOX=14*/
    #li x6,0x2                  /* NUM_CLASS=2*/
    li x27,0x2b67             /* 11111 */
    li x31,0x50               /* 80 */

    # find_max
BEGIN:
    add x25,x0,x0        # flag=0
    add x7,x0,x0         # i=0    for(i=0;i<NUM_CLASS;i++)

BACK2:     
    addrtwo x18,x28,x7   # max_box[i]的绝对地址
    sw x27,0x0(x18)      # max_box[i]=-1
    # addi x7,x7,1         # i++
    # blt x7,x6,BACK2      # if i < NUM_CLASS, for loop continues
    plusonelt x7,x6,BACK2
# ====================================================================== #

# 否则一个 loop 循环结束，进行下一个 loop 循环
    add x7,x0,x0         # i=0    for(i=0;i<NUM_BOX;i++)
BACK3:  
    addrfive x18,x9,x7
    lw x20,0x1c(x18)     # 偏移量为28(dec)   x20 存 box_info[i].valid_bit
    lw x22,0x0(x18)      # x22 有box_info[i].id
    flw f18,0x04(x18)    # f18=box_info[i].score
    beq x20,x0,MARK3     # 若 box_info[i].valid_bit 为0，则跳转到 loop 最尾部
    addi x25,x0,1        # flag=1
    lw x21,0x18(x18)     # 偏移量为24(dec)   x21 存 box_info[i].class_
    addrtwo x18,x28,x21  # x18存的是 max_box[box_info[i].class_] 的绝对地址
    lw x23,0x0(x18)      # 最大box id
    beq x23,x27,MARK51   # if max_box[box_info[i].class_]==-1
    nop     
    addrfive x18,x9,x23  # box_info[max_box[box_info[i].class_]] 绝对地址
    flw f19,0x04(x18)    # f19=box_info[max_box[box_info[i].class_]].score
    flt.s x24,f19,f18    # if box_info[max_box[box_info[i].class_]].score<box_info[i].score,x24=1
    bne x24,x0,MARK52    # if x24=1,jump
MARK3:
    # addi x7,x7,1         # i++
    # blt x7,x5,BACK3      # if i < NUM_BOX, for loop continues
    plusonelt x7,x5,BACK3
# ======================================================================= #

    beq x25,x0,MARK61    # if flag=0, jump  
# 第一次結束是16000

    add x7,x0,x0         # i=0    for(i=0;i<NUM_CLASS;i++)
BACK4:
    addrtwo x18,x28,x7   # max_box[i]的绝对地址
    lw x23,0x0(x18)      # max_box[i]的值
    beq x23,x27,FORWORD1 # if max_box[i]==-1,jump

    addrfive x18,x9,x23  # x18 里装的是 box_info[i].id 的绝对地址
    sw x0,0x1c(x18)      # box_info[max_box[i]].valid_bit=false
    sw x23,0x0(x30)       # 存到输出区
# ERROR!
    addi x30,x30,4         # 栈指针向后移一位

FORWORD1:
    # addi x7,x7,1         # i++
    # blt x7,x6,BACK4      # if i < NUM_CLASS, for loop continues
    plusonelt x7,x6,BACK4

    addi x29,x0,1        # find_max() return 1
BACK61:
    beq x29,x0,OVER          # if find_max() return 0
# ======================================================================= #


# delete_overlap
    fadd.s f1,f0,f0        # son=0.0
    fadd.s f2,f0,f0        # mother=0.0
    fadd.s f3,f0,f0        # IoU=0.0
    addi x7,x0,0         # in while loop,  init i=0
# 第一次開始是17300
BACK1:               # for(i=0;i<NUM_BOX;i++)
    addrfive x18,x9,x7   # x18 里装的是 box_info[i].id 的绝对地址
    lw x20,0x1c(x18)     # 偏移量为28(dec)   x20 存 box_info[i].valid_bit
    beq x20,x0,MARK2     # 若 box_info[i].valid_bit 为0，则跳转到 loop 最尾部
 
    flw f18,0x08(x18)    # x1=box_info[i].x1
    flw f19,0x0c(x18)    # y1=box_info[i].y1
    flw f20,0x10(x18)    # x2=box_info[i].x2
    flw f21,0x14(x18)    # y2=box_info[i].y2

    lw x21,0x18(x18)     # box_info[i].class_
    addrtwo x18,x28,x21  # x18 里装的是 max_box 的绝对地址
    lw x23,0x0(x18)      # max_box[box_info[i].class_] 内容

    addrfive x18,x9,x23  # x18 里装的是最大 box 的绝对地址

    flw f22,0x08(x18)    # a1=box_info[max_box[box_info[i].class_]].x1
    flw f23,0x0c(x18)    # b1=box_info[max_box[box_info[i].class_]].y1
    flw f24,0x10(x18)    # a2=box_info[max_box[box_info[i].class_]].x2
    flw f25,0x14(x18)    # b2=box_info[max_box[box_info[i].class_]].y2

    fmax.s f28,f18,f22   # xx1
    fmin.s f29,f20,f24   # xx2
    fmax.s f30,f19,f23   # yy1
    fmin.s f31,f21,f25   # yy2

# 计算 mother
    
    fsubabs.s f4,f18,f20  # delta_x1=|x1-x2|
    fsubabs.s f5,f19,f21  # delta_y1=|y1-y2|
    fsubabs.s f6,f22,f24  # delta_x2=|a1-a2|
    fsubabs.s f7,f23,f25  # delta_y2=|b1-b2|

    fmul.s f2,f4,f5         # mother=delta_x1*delta_y1
    fmadd.s f2,f6,f7,f2     # mother=delta_x1*delta_y1+delta_x2*delta_y2 

# 计算 son
    fadd.s f4,f18,f20      # xmid1=x1+x2
    fadd.s f5,f22,f24      # xmid2=a1+a2
    fadd.s f6,f19,f21      # ymid1=y1+y2
    fadd.s f7,f23,f25      # ymid2=b1+b2

    fsubabs.s f22,f4,f5       # |xmid1-xmid2|
    fsubabs.s f23,f6,f7       # |ymid2-ymid1|

    fsub.s f4,f20,f18         # x2-x1
    fsub.s f5,f24,f22         # a2-a1
    fadd.s f26,f4,f5          # x_delta=(x2-x1+a2-a1)

    fsub.s f6,f21,f19         # y2-y1
    fsub.s f7,f25,f23         # b2-b1
    fadd.s f27,f6,f7          # y_delta=(y2-y1+b2-b1)

# 四个条件一个满足x24就为1
    add x24,x0,x0        # 初始化x24为0
    flt.s x24,f26,f22      # |xmid1-xmid2|>x_delta则x24=1
    bne x24,x0,MARK31    # 若x24是1，则跳转MARK31
    flt.s x24,f27,f23      # |ymid2-ymid1|>y_delta则x24=1
    bne x24,x0,MARK31    # 若x24是1，则跳转MARK31
   
# 否则计算son
    fsubabs.s f26,f28,f29  # w=|xx1-xx2|
    fsubabs.s f27,f30,f31  # h=|yy1-yy2|
    fmul.s f1,f26,f27      # son=h*w

    fsub.s f2,f2,f1        # mother=mother-son

# 计算 IoU 
BACK31:
    fdiv.s f3,f1,f2        # IoU=son/mother
    flt.s x24,f9,f3        # if IoU>THRESHOLD, x24=1
    bne x24,x0,MARK41    # if x24=1,jump

MARK2:                                      
    # addi x7,x7,1         # i++
    # blt x7,x5,BACK1      # if i < NUM_BOX, for loop continues
    plusonelt x7,x5,BACK1
    j BEGIN            # loop 结束后，无条件跳转到 while 开始，check find_max 函数

#######################################################  
MARK31:
    fadd.s f1,f0,f0       # son=0
    j BACK31

MARK41:    
    addrfive x18,x9,x7   # box_info[i] 绝对地址
    sw x0,0x1c(x18)      # box_info[i].valid_bit=false
    j MARK2

    
MARK51:
    sw x22,0x0(x18)      # box_info[i].id 存到 max_box[box_info[i].class_]里去
    j MARK3
    
MARK52:
    addrtwo x18,x28,x21
    # mul x18,x21,x26      # box_info[i]*4
    # add x18,x28,x18      # +max_box_base_addr  x18存的是 max_box[box_info[i].class_] 的绝对地址
    sw x22,0x0(x18)      # max_box[box_info[i].class_]=box_info[i].id
    j MARK3

    
MARK61:
    add x29,x0,x0        # find_max() 返回 0
    j BACK61

    
OVER:
    li x30,0x10000460    # RES_BASE_ADDR      # 栈指针用来存放基地址
    flw f4,0x0(x30)
    flw f5,0x4(x30)
    flw f6,0x8(x30)
    flw f7,0xc(x30)
    flw f18,0x10(x30)
    flw f19,0x14(x30)
    flw f20,0x18(x30)
    
    li x19,0x40013000   # GPIO_BASE_ADDR
    fsw f4,0x0(x19)
    fsw f5,0x4(x19)
    fsw f6,0x8(x19)
    fsw f7,0xc(x19)
    fsw f18,0x10(x19)
    fsw f19,0x14(x19)
    fsw f20,0x18(x19)
    


