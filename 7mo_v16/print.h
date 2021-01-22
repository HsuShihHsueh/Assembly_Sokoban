;************************************
;@functions in <in_out.h>
;
;	[FUNCTIONS]			[PARAMETER]
;    setmode            mode
;    set_cur            col,row
;    setcolor           mode,color
;    write_pixel        col,row,color
;    read_pixel         col,row,color
;    printstr13h        string,atr,len,row,col,cursor_move
;   [define]  
;    color              black  purple                         
;                       blue   dark_gray
;                       brown  light_gray
;                       dan    light_green
;                       green  white        
;                       red      
;                                                                                           
;    mode               text_mode
;                       print_mode
;   ***********************************
;**

   
;-----setmode----------------
setmode macro mode
    mov ah,00h
    mov al,mode
    int 10h
    endm
;-----set_text_postion--------    
set_cur macro col,row  ;80x30
pusha
    mov dh,row
    mov dl,col
    mov bx,0
    mov ah,02h
    int 10h
popa
    endm     
;----setcolor--------------
setcolor macro color
    mov ah,0bh
    mov bh,00h
    mov bl,color
    int 10h
    endm
;-----write_pixel---------------
write_pixel macro col,row,color
    mov ah,0ch
    mov bh,00h   
    mov al,color
    mov cx,col
    mov dx,row
    int 10h
    endm
;-----read_pixel-------
read_pixel macro col,row,color
push ax ;color not accept ax,cx,di
push cx 
push di
    mov ah,0dh
    mov bh,00h
    mov cx,col
    mov dx,row
    int 10h   
    mov color,al
pop di
pop cx
pop ax
    endm
;-----printstr13h----------
printstr13h macro string,atr,len,row,col,cursor_move
    mov ax,ds
    mov es,ax
    mov ah,13h
    lea bp,string
    mov al,cursor_move
    mov cx,len
    mov bh,00h
    mov bl,atr
    mov dh,row
    mov dl,col
    int 10h
    endm
    

;---define-color-------
black       equ 0000b
blue        equ 0001b
green       equ 0010b
dan         equ 0011b
red         equ 0100b
purple      equ 0101b
brown       equ 0110b
light_gray  equ 0111b
dark_gray   equ 1000b
light_green equ 1011b
yellow      equ 1110b
white       equ 1111b
;---define-mode----------
text_mode   equ 03h
print_mode  equ 12h