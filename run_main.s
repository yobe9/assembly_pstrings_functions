   # 313268393 Yoav Berger
    .section    .rodata
    #formatscanchar: .string " %c"
    formatscanchar: .string "%hhu"
    formatscanstring:   .string "%s"
    formatscanoption:   .string "%d"

    .text
.globl run_main
    .type run_main, @function
run_main:
    pushq	%rbp		#save the old frame pointer
	movq	%rsp,%rbp	#create the new frame pointer
    subq    $528,%rsp #making room for the scanf

    #prepare to scanf the first string lenght
    movq    $formatscanchar,%rdi
    leaq    -520(%rbp),%rsi
    movq    $0,%rax
    call    scanf

    #scan the first string
    movq    $formatscanstring,%rdi
    leaq    -519(%rbp),%rsi
    movq    $0,%rax
    call    scanf

    #prepare to scanf the second string lenght
    movq    $formatscanchar,%rdi
    leaq    -263(%rbp),%rsi
    movq    $0,%rax
    call    scanf

    #scan the second string
    movq    $formatscanstring,%rdi
    leaq    -262(%rbp),%rsi
    movq    $0,%rax
    call    scanf

    #scan the user's option
    movq    $formatscanoption,%rdi
    leaq    -4(%rbp),%rsi
    movq    $0,%rax
    call    scanf

    #prepare to call func select, move user's choice to rdi, ptr of first string to rsi, ptr of second string to rdx
    movl    -4(%rbp),%edi
    leaq    -520(%rbp),%rsi
    leaq    -263(%rbp),%rdx

    movq    $0,%rax
    call    run_func

    #restoring the stack frame
    movq	%rbp, %rsp	#restore the old stack pointer - release all used memory.
    popq	%rbp		#restore old frame pointer (the caller function frame)

    ret


