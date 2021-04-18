    # 313268393 Yoav Berger
    .data
    c:  .byte 5
    

    .section    .rodata
    chose:  .string "chose option\n"
    printformat: .string "%d\n"
    formatinvalid:  .string "invalid input!\n"
    
    .text
.globl pstrlen
    .type pstrlen, @function
pstrlen:
#calculating the lenght of given string using it first byte
        movq    $0,%rax
        movb    (%rdi),%al
        ret

.globl replaceChar
    .type replaceChar, @function
replaceChar:
        #replacing given char from string with another given char
        # rdi = pstring rsi = oldchar rdx = newchar
        movq    $0,%rax
        movq    $1,%r8 #counter register
    #iterating threw the chars, comparing to \0 and to old char, and increasing the counter
    .Loopreplace:
        leaq    (%rdi,%r8),%r9
        cmpb    $0,(%r9)
        je  .endreplace
        cmpb    %sil,(%r9)
        je  .replacecase
        add     $1,%r8
        jmp .Loopreplace

    #in case we want to change the old char to the new
    .replacecase:
        movb    %dl,(%r9)
        add     $1,%r8
        jmp .Loopreplace

    # return - first increse string over the lenght byte and then return
    .endreplace:
        leaq    1(%rdi),%rdi
        movq    %rdi,%rax
        ret


.globl pstrijcpy
    .type pstrijcpy, @function
pstrijcpy:
    #coping sub string from string to another string in the same indexes
    # rdi = pstring1 dst, rsi = pstring2 src, rdx = index i, rcx = index j
    movq    $0,%rax
    # keeping the pstrings before calling lenght and keeping caller to store return lenght values
    pushq   %r12 # return values store
    pushq   %r13
    pushq   %rdi
    pushq   %rsi
    
    
    call    pstrlen
    movq    %rax,%r12
    
    movq    %rsi,%rdi
    call    pstrlen
    movq    %rax,%r13

    # checking if index are out of scope, r12,r13 = lenght, rdx,rcx = indexees
    subq    $1,%r12 # in string we start from 0 so need to reduce the lenght
    subq    $1,%r13
    cmpq    %rdx,%r12
    jl  .badone
    cmpq    %rdx,%r13
    jl  .badone
    cmpq    %rcx,%r12
    jl  .badone
    cmpq    %rcx,%r13
    jl  .badone
    cmpq    %rdx,%rcx
    jl  .badone

    #set counter to be index i+1, and restore the pstrings, and incresing rcx to j+2
    movq    %rdx,%r8
    addq    $1,%r8
    addq    $2,%rcx
    popq    %rsi
    popq    %rdi

    .Looppstrij:
        #checking if counter arrived j+2 then go to end
        cmpq    %r8,%rcx
        je  .endpstrij
        #getting the char in index i from both strings
        leaq    (%rdi,%r8),%r9
        leaq    (%rsi,%r8),%r10
        # inserting the char from src string to dst string
        movq    $0,%r11
        movb    (%r10),%r11b
        movb    %r11b,(%r9)

        add    $1,%r8
        jmp .Looppstrij


    .badone:
    # invalid case we want to print invalid message and keep dst address
        pushq   %rdi
        movq    $formatinvalid,%rdi
        movq    $0,%rax
        call    printf

        popq    %rdi
        popq    %rsi# need to be poped because we jumped here before loop
        popq    %rdi# need to be poped because we jumped here before loop
        jmp .endpstrij


    .endpstrij:
    # end of loop, restore lenght values, increase string over the lenght byte
        popq    %r13
        popq    %r12
        leaq    1(%rdi),%rdi
        movq    %rdi,%rax
        ret


.globl swapCase
    .type swapCase, @function
swapCase:
    # change upper case to lower and lower to upper
    # rdi = pstring
    movq    $0,%rax
    movq    $1,%r8 #counter register after first byte

    # iterating threw the string and checking the current char type
    .Loopswap:
        leaq    (%rdi,%r8),%r9
        cmpb    $0,(%r9) # in case we arrive to end
        je  .endloop
        cmpb    $65,(%r9) #in case char smaller then 65
        jl  .incr
        cmpb    $91,(%r9) # in case smaller than 91 and bigger than 65 so BIG case
        jl  .bigcase
        cmpb    $97,(%r9) # in case smaller than 97 and bigger than 90 so next char
        jl  .incr
        cmpb    $123,(%r9) # in case smaller than 123 and bigger than 97 so small case
        jl  .smallcase
        
        add     $1,%r8
        jmp .Loopswap

    .incr:
        add     $1,%r8# increase the itreator
        jmp .Loopswap

    .bigcase:
        addb    $32,(%r9) #bigger to smaller
        add     $1,%r8
        jmp .Loopswap

    .smallcase:
        subb    $32,(%r9) #smaller to bigger
        add     $1,%r8
        jmp .Loopswap

    .endloop:
        leaq    1(%rdi),%rdi # incresing over the lenght byte and return
        movq    %rdi,%rax
        ret



.globl pstrijcmp
    .type pstrijcmp, @function
pstrijcmp:
    #compare sub strings
    # rdi = pstring1, rsi = pstring2, rdx = index i, rcx = index j
    movq    $0,%rax
    # keeping the pstrings before calling lenght and keeping caller to store return lenght values
    pushq   %r12 # return values store
    pushq   %r13
    pushq   %rdi
    pushq   %rsi


    call    pstrlen
    movq    %rax,%r12
    
    movq    %rsi,%rdi
    call    pstrlen
    movq    %rax,%r13

    # checking if index are out of scope, r12,r13 = lenght, rdx,rcx = indexes
    subq    $1,%r12 # in string we start from 0 so need to lower the lenght
    subq    $1,%r13
    cmpq    %rdx,%r12
    jl  .invalidcmp
    cmpq    %rdx,%r13
    jl  .invalidcmp
    cmpq    %rcx,%r12
    jl  .invalidcmp
    cmpq    %rcx,%r13
    jl  .invalidcmp
    cmpq    %rdx,%rcx
    jl  .invalidcmp

    #set counter to be index i+1, and restore the pstrings, and incresing rcx to j+2
    movq    %rdx,%r8
    addq    $1,%r8
    addq    $2,%rcx
    popq    %rsi
    popq    %rdi

    .Loopcmp:
        #checking if counter arrived j+2 then go to equal
        cmpq    %r8,%rcx
        je  .cmpequal
        #getting the char in index i from both strings
        leaq    (%rdi,%r8),%r9
        leaq    (%rsi,%r8),%r10
        # checking ASCII value
        movq    $0,%r11
        movb    (%r9),%r11b
        cmpb    (%r10),%r11b
        ja  .cmp1bigger
        cmpb    (%r10),%r11b
        jl  .cmp2bigger

        add    $1,%r8
        jmp .Loopcmp
    

    #in case arrived end of loop and everything was equal
    .cmpequal:
        movq    $0,%rax
        jmp .endcmp

    #in case char of pstring 1 was bigger than chacr of pstring 2
    .cmp1bigger:
        movq    $1,%rax
        jmp .endcmp

    #in case char of pstring 1 was bigger than chacr of pstring 2
    .cmp2bigger:
        movq    $-1,%rax
        jmp .endcmp
    
    #in case indexes were invalid
    .invalidcmp:
        movq    $formatinvalid,%rdi
        movq    $0,%rax
        call    printf

        #pop what we missed because of the conditions
        popq    %rsi
        popq    %rdi
        
        #value in case of invalid
        movq    $-2,%rax
        jmp .endcmp

    .endcmp:
    #pop the stored registers
        popq    %r13
        popq    %r12
        ret

