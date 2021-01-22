;----figure.h---



;------print_triangle--------
print_icon macro coordinate,object
pusha
push coordinate
    mov ax,coordinate 
    mov cl,3            ;yyyxxx->yyy
    clc                 ;yyyxxx->yyy
    shr al,cl           ;yyyxxx->yyy
    mov bl,block_range         ;x40
    mul bl              ;x40
    mov dx,ax           ;store dx
    add dx,30
    pop ax
    and ax,111b         ;yyyxxx->xxx
    mul bl              ;x40
    mov cx,ax           ;store cx
    add cx,120 
    
    lea bp,object    
    
    call print_figure_proc   
popa
    endm
    
;------print_triangle--------
print_numwall macro coordinate,object,number
pusha
    lea bp,object
    mov ax,number
    dec ax
    mov bx,block_range*block_range
    mul bx
    add bp,ax

    mov al,coordinate 
    mov ah,0
    mov cl,3            ;yyyxxx->yyy
    clc                 ;yyyxxx->yyy
    shr al,cl           ;yyyxxx->yyy
    mov bl,block_range         ;x40
    mul bl              ;x40
    mov dx,ax           ;store dx
    add dx,30
    mov al,coordinate
    mov ah,0
    and ax,111b         ;yyyxxx->xxx
    mul bl              ;x40
    mov cx,ax           ;store cx
    add cx,120    
    
    call print_figure_proc
popa
    endm
    
;------------------------------------
set_4band macro num,color
    
    endm
    