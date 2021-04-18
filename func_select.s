    # 313268393 Yoav Berger
    .section    .rodata
    wrong_input:    .string "invalid option!\n"
    chose:  .string "chose option\n"
    scanformat: .string "%d"
    printformat: .string "%d\n"
    formatpstrlen: .string "first pstring length: %d, second pstring length: %d\n"
    charscanformat: .string " %c\n"
    formatprintreplacechar: .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
    formatscanreplacechar: .string " %c"
    formatswapCase: .string "length: %d, string: %s\n"
    formatscanpstrij: .string "%hhu"
    formatprintpstrij: .string "length: %d, string: %s\n"
    formatscanpstrcmp: .string "%hhu"
    formatprintpstrcmp: .string "compare result: %d\n"
    .align 8
    .switch:
        .quad .C1 #case 50 or 60
        .quad .C9 #case 51 or default - default
        .quad .C3 #case 52
        .quad .C4 #case 53
        .quad .C5 #case 54
        .quad .C6 #case 55
    
    .text
.globl run_func
    .type run_func, @function
run_func:
        #save the pointers of the stack and make room for scanf
        pushq	%rbp
	    movq	%rsp,	%rbp
        subq    $24,%rsp 
        
        #saves the registers of the strings and case
        pushq   %rdi
        pushq   %rsi
        pushq   %rdx
        
        #rdi = cases, rsi = pstring1, rdx = pstring2
        leaq    -50(%rdi),%r8 #compute xi=x-50
        cmpq    $10,%r8 #compare xi:10
        je .C1          #if = 60, go to C1
        cmpq    $5,%r8
        ja .C9          #if >, go to default case
        jmp *.switch(,%r8,8) #go to jump table[xi]

        #case 50
        .C1:
        # rdi = option , rsi= pstr1 , rdx= pstr2
        # getting the lenght of the strings
        movq    %rsi,%rdi
        call    pstrlen
        movq    %rax,%r9

        movq    %rdx,%rdi
        call    pstrlen
        movq    %rax,%r10

        # print the lenght
        movq    $formatpstrlen,%rdi
        movq    %r9,%rsi
        movq    %r10,%rdx
        movq	$0,%rax
        call	printf		#calling to printf AFTER we passed its parameters.

        jmp .end #go to done

        #case 51 or default
        .C9:
        #print invalid option
        movq    $wrong_input,%rdi
        movq	$0,%rax
        call	printf
        jmp .end # go to done

        #case 52
        .C3:
        # rdi = option , rsi= pstr1 , rdx= pstr2
        # pushing register for further use and to store strings ptr
        pushq   %r15
        pushq   %r14# to align the stack
        pushq   %rdx
        pushq   %rsi

        #scaning the chars from user to the stack
        movq    $formatscanreplacechar,%rdi
        leaq	-1(%rbp),%rsi
	    movq	$0,%rax
	    call	scanf

        movq    $formatscanreplacechar,%rdi
        leaq	-2(%rbp),%rsi
	    movq	$0,%rax
	    call	scanf

        #prepare to func call - insert the string and the indexes
        popq    %rsi
        movq    %rsi,%rdi
        movq    $0,%rsi
        movq    $0,%rdx
        movb    -1(%rbp),%sil
        movb    -2(%rbp),%dl

        #calling the func and store the result
        call    replaceChar
        movq    %rax,%r14

        #prepare to second func call - insert the string and the indexes
        popq    %rdx
        movq    %rdx,%rdi
        movq    $0,%rsi
        movq    $0,%rdx
        movb    -1(%rbp),%sil
        movb    -2(%rbp),%dl

        #calling the func and store the result
        call    replaceChar
        movq    %rax,%r15

        #prepare printf call - format, indexes and strings
        movq    $formatprintreplacechar,%rdi
        movq    $0,%rsi
        movq    $0,%rdx
        movb    -1(%rbp),%sil
        movb    -2(%rbp),%dl
        movq    %r14,%rcx
        movq    %r15,%r8
        movq    $0,%rax
        call    printf

        #poping the pushed registers
        popq    %r14
        popq    %r15

        jmp .end # go to done

        #case 53
        .C4:
        # rdi = option , rsi= pstr1 , rdx= pstr2
        # storing the strings addresses and registers for further use
        pushq   %r14# to align the stack
        pushq   %r13
        pushq   %rsi
        pushq   %rdx

        #scanning the indexes and store them in stack
        movq    $formatscanpstrij,%rdi
        leaq    -1(%rbp),%rsi
        movq    $0,%rax
        call    scanf

        movq    $formatscanpstrij,%rdi
        leaq    -2(%rbp),%rsi
        movq    $0,%rax
        call    scanf

        #prepering to call the func, restore the strings, set rdi and rsi, store the strings before call the func
        popq    %rdx
        popq    %rsi
        movq    %rsi,%rdi # rdi = pstr1, rsi = pstr2
        movq    %rdx,%rsi
        pushq   %rsi
        movq    $0,%rdx #clear and insert index
        movb    -1(%rbp),%dl
        movq    $0,%rcx #clear and insert index
        movb    -2(%rbp),%cl

        call    pstrijcpy
        movq    %rax,%r13 #new string

        #prepare to printing the dst
        movq    $formatprintpstrij,%rdi
        movq    $0,%rsi
        leaq    -1(%r13),%r14 #got the string back without lenght char, so bring it back
        movb    (%r14),%sil #getting the lenght by the first char of the string
        movq    %r13,%rdx
        movq    $0,%rax
        call    printf

        #prepare printing the src, restore src from stack
        popq    %rsi
        movq    %rsi,%rdx
        movq    $0,%rsi
        movb    (%rdx),%sil # getting lenght
        leaq    1(%rdx),%rdx # increasing the string by 1 so we wont print the lenght char
        movq    $formatprintpstrij,%rdi
        movq    $0,%rax
        call    printf

        # poping the pushed registers
        popq    %r13
        popq    %r14

        jmp .end # go to done

        #case 54
        .C5:
        # rdi = option , rsi= pstr1 , rdx= pstr2
        # storing the pointers
        movq    %rsi,%r10 
        movq    %rdx,%r11

        #calculate the length of both strings
        movq    %r10,%rdi
        call    pstrlen
        movq    %rax,%rdx

        movq    %r11,%rdi
        call    pstrlen
        movq    %rax,%rcx

        #calling the swapcase func on the stored strings
        movq    %r10,%rdi
        call    swapCase
        movq    %rax,%r10

        movq    %r11,%rdi
        call    swapCase
        movq    %rax,%r11
        
        #printing according to format, entering lenght and string
        #keeping rcx and r11 before first printf so wont delete
        pushq   %rcx
        pushq   %r11

        movq    $formatswapCase,%rdi
        movq    %rdx,%rsi
        movq    %r10,%rdx
        movq    $0,%rax
        call    printf

        popq    %r11
        popq    %rcx
        movq    $formatswapCase,%rdi
        movq    %rcx,%rsi
        movq    %r11,%rdx
        movq    $0,%rax
        call    printf

        jmp .end # go to done

        #case 55
        .C6:
        # rdi = option , rsi= pstr1 , rdx= pstr2
        # storing the strings addresses, and registers for further use
        pushq   %r15
        pushq   %r14# to align the stack
        pushq   %rsi
        pushq   %rdx

        # scanning the indexes
        movq    $formatscanpstrcmp,%rdi
        leaq    -1(%rbp),%rsi
        movq    $0,%rax
        call    scanf

        movq    $formatscanpstrcmp,%rdi
        leaq    -2(%rbp),%rsi
        movq    $0,%rax
        call    scanf

        #getting back the pstrings adrresses
        popq    %rdx
        popq    %rsi

        # prepare to call func by putting the strings and indexes
        movq    %rsi,%rdi # rdi = pstr1, rsi = pstr2
        movq    %rdx,%rsi
        movq    $0,%rdx #clear and insert index
        movb    -1(%rbp),%dl
        movq    $0,%rcx #clear and insert index
        movb    -2(%rbp),%cl

        call    pstrijcmp
        movq    %rax,%rsi

        #prepare printf
        movq    $formatprintpstrcmp,%rdi
        movq    $0,%rax
        call    printf

        # poping the pushed registers
        popq    %r14
        popq    %r15

        jmp .end # go to done

        .end: #done
        # poping the strings, option, and restoring the stack frame
        popq    %rdx
        popq    %rsi
        popq    %rdi
        movq	%rbp, %rsp	#restore the old stack pointer - release all used memory.
	    popq	%rbp		#restore old frame pointer (the caller function frame)

        ret


