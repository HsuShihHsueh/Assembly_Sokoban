;************************************
;@functions in <in_out.h>
;
;	[FUNCTIONS]			[PARAMETER]
;    print              string
;    print_char         char
;    input              string,buffer,decorder
;    getchar            char
;    scan_char          char
;
;***********************************

;----print "string"-----
print macro string 
push ax
push dx
    lea dx,string
    mov ah,09h
    int 21h
pop dx
pop ax
    endm
;----print "char"-------       
print_char macro char
push ax
push dx
    mov dl,char
    mov ah,02h
    int 21h
pop dx
pop ax
   endm  
;----buffer=input(string)----
   ;and print the text after drcord
input macro string,buffer,decorder,max
   ;=====print=====
    print string  
    mov bl,max
    call cin
    mov buffer,al
   ;===sort=class===
    lea bx,decorder
    call sort
    endm
;------getchar---------------
    ;get char and store in "char"
get_char macro char
    mov ah,07h
    int 21h
    mov char,al
    endm
;-----scan(no stop) input char---
scan_char macro char
    mov ah,06h
    mov dl,0ffh
    int 21h  
    mov char,al    ;catch char      
    endm