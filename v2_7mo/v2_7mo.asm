PrintStr macro string
    push ax
    push dx           
    mov ah,09h
    lea dx,string
    int 21h
    pop dx
    pop ax            
endm

Print macro char
    push ax
    push dx
    mov ah,02h
    mov dl,char
    int 21h
    pop dx
    pop ax
endm            

GetChar macro Char
    mov ah,07h
    int 21h
    mov Char,al            
endm
            
SetMode macro mode
    mov ah,00h
    mov al,mode
    int 10h
endm

SetColor macro mode,color
    mov ah,0bh
    mov bh,mode
    mov bl,color
    int 10h
endm

WrPixel macro row,col,color
    pusha
    mov ah,0ch
    mov bh,00h
    mov al,color
    mov cx,col
    mov dx,row
    int 10h
    popa
endm
   
SetText macro col,row,string  
    pusha
    mov dh,row
    mov dl,col
    mov bx,0
    mov ah,02h
    int 10h
    PrintStr string
    popa
endm     

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
    ;=====print setting======
    mov bp,object
    mov pic_transparent_color,7
    mov pic_amp,maze_amp
    mov pic_x_range,maze_x_range
    mov pic_y_range,maze_y_range
    mov pic_x_start,cx
    mov pic_y_start,dx
    call PrintPicture 
    popa
endm

_add macro destination, source
    push ax
    push dx
    mov ax,destination
    mov dx,source
    add ax,dx
    mov destination,ax
    pop dx
    pop ax
endm

_mov macro destination, source
    push ax
    mov ax,source
    mov destination,ax
    pop ax
endm

_mul macro destination, source
    push ax
    push dx
    mov ax,destination
    mov dx,source
    mul dx
    mov destination,ax
    pop dx
    pop ax
endm
        
_lea macro destination, i, source
    push bp
    push bx      
    lea bx,destination
    lea bp,source
    add bx,i
    add bx,i
    mov [bx],bp
    pop bx
    pop bp
endm

_index macro destination, source, index
    push di
    mov di,index
    add di,di
    mov di, source[di]
    mov destination,di
    pop di
endm
        
.8086
.model small
.stack 1024
.data
       
;----------maze variable--------------
b_range     equ 8
block_range equ 50
people_coo dw ?
vete_coo   dw ?
who        db ?
x_delta    dw ?
y_delta    dw ?
count_d    db ?
level_size equ 70
level_now  db level_size dup(0)
;---------picture-variable------------
pic_cx_tmp  dw ?
pic_row_end dw ?
pic_col_end dw ?
pic_r_count db ?
pic_amp     dw ?
pic_x_start dw ?
pic_y_start dw ?
pic_x_range dw ?
pic_y_range dw ?
pic_x_end   dw ?
pic_y_end   dw ?
pic_choose  db ?
pic_transparent_color db ?
;---------keyboard-parameter-----------
_esc         equ 27
_f5          equ '?'
_backspace   equ 8
_enter       equ 13
_up          equ 'H'
_down        equ 'P'
_left        equ 'K'
_right       equ 'M'
;-------introduction-word---------
;===page_1=====
str_select_level  db 1bh,' ',1ah," to select level",'$'
str_select_player db 18h,' ',19h," to select player",'$'
str_play    db "press enter to play",'$'
;===page_2====
str_joy     db 0,18h,10,8,8,8,1bh,0,0,0,1ah,10,8,8,8,19h,'$'
str_move    db " to move",'$'
str_reset   db "press backspace to reset",'$'
str_gohome  db "press enter to go home page",'$'
;===page_3=====
str_success db "!!!!!success!!!!!",'$'
;===page_all====
str_esc     db "press esc to end",'$'
;------------brick-parameter-----------
brick_x_start equ 100
brick_y_start equ 50
brick_x_range equ 50
brick_y_range equ 50
brick_x_space equ 80+brick_x_range
brick_y_space equ 80+brick_y_range
brick_amp     equ 1
brick_list    dw 9 dup(0) 
level_choose  dw 1
;-----------player-parameter-------------
player_x_start equ 140
player_y_start equ 280
player_x_range equ 50
player_y_range equ 50
player_x_space equ 50+player_x_range
player_amp     equ 3
player_list    dw  0, 0,0,0 
player_choose  dw  1
;---------maze-parameter------------
maze_x_range equ 50
maze_y_range equ 50
maze_amp     equ 1
maze_list    dw  9 dup(0)
wall         dw  ?
ground       dw  ?
box          dw  ?
desti        dw  ?
desti_ok     dw  ?
P1           dw  ?
P2           dw  ?
;-------success-picture-parameter-------
success_picture_x_start equ 20
success_picture_y_start equ 40
success_picture_x_range equ 200
success_picture_y_range equ 110
success_picture_amp     equ 3
success_picture_list    dw  4 dup(0)
;-------------maze-data---------------
level_1 db 'w','w','w','w','w','w','w','c'
        db 'w','g','g','b','g','d','w','c'
        db 'w','g','g','w','w','w','w','c'
        db 'w','g','p','w','n','n','n','c'
        db 'w','w','w','w','n','n','n','$'

level_2 db 'w','w','w','w','w','w','w','c'
        db 'w','d','g','p','g','g','w','c'
        db 'w','b','g','g','g','g','w','c'
        db 'w','g','g','g','b','d','w','c'
        db 'w','g','g','g','g','g','w','c'
        db 'w','w','w','w','w','w','w','$'
 
level_3 db 'n','n','w','w','w','w','n','c'
        db 'w','w','w','g','g','w','n','c'
        db 'w','p','g','d','b','w','w','c'
        db 'w','g','g','g','b','g','w','c'
        db 'w','g','w','d','g','g','w','c'
        db 'w','g','g','g','g','g','w','c'           
        db 'w','w','w','w','w','w','w','$' 
  
level_4 db 'n','w','w','w','w','w','n','c'
        db 'w','w','p','g','d','w','w','c'
        db 'w','g','g','w','g','g','w','c'
        db 'w','g','b','b','b','g','w','c'
        db 'w','d','g','g','g','g','w','c'
        db 'w','w','g','d','g','w','w','c'
        db 'n','w','w','w','w','w','n','$' 
         
level_5 db 'w','w','w','w','w','w','n','n'
        db 'w','g','g','g','g','w','w','w'
        db 'w','g','g','g','d','d','g','w'
        db 'w','g','b','b','b','p','g','w'
        db 'w','g','g','w','g','d','w','w'
        db 'w','w','w','w','w','w','w','$'
        
level_6 db 'n','w','w','w','w','w','n','n'
        db 'w','w','d','g','g','w','w','w'
        db 'w','g','g','w','g','b','p','w'
        db 'w','g','g','w','g','w','g','w'
        db 'w','g','b','d','g','b','d','w'
        db 'w','g','g','g','g','w','w','w'
        db 'w','w','w','w','w','w','n','$'

level_7 db 'w','w','w','w','w','w','n','c'
        db 'w','p','d','b','g','w','w','c'
        db 'w','g','b','w','g','g','w','c'
        db 'w','g','b','g','d','g','w','c'
        db 'w','d','g','g','g','w','w','c'           
        db 'w','w','w','w','w','w','n','$'        

level_8 db 'w','w','w','w','w','w','w','c'
        db 'w','d','g','w','g','d','w','c'
        db 'w','g','g','w','g','g','w','c'
        db 'w','v','g','b','g','p','w','c'
        db 'w','g','b','w','b','g','w','c' 
        db 'w','d','g','w','g','g','w','c'            
        db 'w','w','w','w','w','w','w','$' 
        
level_9 db 'n','w','w','w','w','w','n','c'
        db 'w','w','p','g','g','w','w','c'
        db 'w','g','g','w','g','g','w','c'
        db 'w','g','b','d','b','g','w','c'
        db 'w','g','g','d','b','g','w','c'
        db 'w','w','g','d','g','w','w','c'
        db 'n','w','w','w','w','w','n','$'  
;----------brick-data------------------
brick_1 \
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 64h, 7fh,0f4h, 54h, 27h,0f4h, 54h,09fh,0f4h
db   44h, 27h,0f4h, 44h, 2fh, 60h, 2fh,0f4h, 44h, 27h
db  0f4h, 34h, 2fh, 70h, 2fh,0f4h, 44h, 27h,0f4h, 24h
db   2fh, 80h, 2fh,0f4h, 44h, 27h,0f4h, 14h, 2fh,090h
db   2fh,0f4h, 44h,0f7h, 27h, 2fh,0a0h, 2fh,0f7h,0f7h
db   67h, 2fh,0a0h, 2fh,0f7h, 67h,0c4h, 27h, 14h, 6fh
db   60h, 2fh, 84h, 27h,0f4h, 84h, 27h, 24h, 5fh, 60h
db   2fh, 84h, 27h,0f4h, 84h, 27h, 54h, 2fh, 60h, 2fh
db   84h, 27h,0f4h, 84h, 27h, 54h, 2fh, 60h, 2fh, 84h
db   27h,0f4h, 84h, 27h, 54h, 2fh, 60h, 2fh, 84h, 27h
db  0f4h, 84h, 27h, 54h, 2fh, 60h, 2fh, 84h, 27h,0f4h
db   84h, 27h, 54h, 2fh, 60h, 2fh, 84h, 27h,0f4h, 84h
db   27h, 54h, 2fh, 60h, 2fh, 84h, 27h,0f4h, 84h, 27h
db   54h, 2fh, 60h, 2fh, 84h, 27h,0f4h, 84h, 27h, 54h
db   2fh, 60h, 2fh, 84h, 27h,0b4h,0f7h, 47h, 2fh, 60h
db   2fh,0f7h,0f7h,0a7h, 2fh, 60h, 2fh,0f7h, 67h,0f4h
db   44h, 2fh, 60h, 2fh,0f4h, 44h, 27h,0f4h, 44h, 2fh
db   60h, 2fh,0f4h, 44h, 27h,0f4h, 44h, 2fh, 60h, 2fh
db  0f4h, 44h, 27h,0f4h, 44h, 2fh, 60h, 2fh,0f4h, 44h
db   27h,0f4h, 44h, 2fh, 60h, 2fh,0f4h, 44h, 27h,0f4h
db   44h, 2fh, 60h, 2fh,0f4h, 44h, 27h,0f4h, 44h, 2fh
db   60h, 2fh,0f4h, 44h, 27h,0f4h, 6fh, 60h, 6fh,0f4h
db   27h,0f4h, 6fh, 60h, 6fh,0f4h, 27h,0f4h, 2fh,0e0h
db   2fh,0f4h, 27h,0f4h, 2fh,0e0h, 2fh,0f4h,0f7h, 27h
db   2fh,0e0h, 2fh,0f7h,0f7h, 27h, 2fh,0e0h, 2fh,0f7h
db   27h,0c4h, 27h, 14h, 2fh,0e0h, 2fh, 44h, 27h,0f4h
db   84h, 27h, 14h,0ffh, 3fh, 44h, 27h,0f4h, 84h, 27h
db   34h,0ffh, 54h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0b4h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0a7h
brick_2 \
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 54h
db   8fh,0f4h, 54h, 27h,0f4h, 44h,0cfh,0f4h, 24h, 27h
db  0f4h, 34h, 2fh, 80h, 4fh,0f4h, 14h,0f7h, 37h, 3fh
db  0c0h, 2fh,0f7h,0f7h, 27h, 2fh,0f0h, 2fh,0f7h, 17h
db  0c4h, 27h, 2fh,0f0h, 20h, 2fh, 24h, 27h,0f4h, 84h
db   17h, 2fh,0f0h, 40h, 2fh, 14h, 27h,0f4h, 84h, 3fh
db   60h, 7fh, 70h, 2fh, 27h,0f4h, 84h, 2fh, 60h,09fh
db   70h, 2fh, 17h,0f4h, 84h, 2fh, 50h, 2fh, 74h, 1fh
db   70h, 2fh, 17h,0f4h, 84h, 2fh, 50h, 2fh, 74h, 2fh
db   60h, 2fh, 17h,0f4h, 84h, 8fh, 84h, 2fh, 60h, 2fh
db   17h,0f4h, 84h, 17h, 6fh,094h, 2fh, 60h, 2fh, 17h
db  0f4h, 84h, 27h,0d4h, 3fh, 60h, 2fh, 17h,0f4h, 84h
db   27h,0c4h, 3fh, 70h, 2fh, 17h,0b4h,0f7h,097h, 3fh
db  090h, 2fh,0f7h,0f7h, 47h, 4fh,090h, 3fh,0c7h,0f4h
db   54h, 4fh,0b0h, 2fh,0b4h, 27h,0f4h, 44h, 4fh,0b0h
db   2fh,0c4h, 27h,0f4h, 24h, 4fh,0b0h, 3fh,0d4h, 27h
db  0f4h, 5fh,0a0h, 4fh,0e4h, 27h,0f4h, 3fh,0a0h, 4fh
db  0f4h, 14h, 27h,0e4h, 2fh,0b0h, 3fh,0f4h, 34h, 27h
db  0d4h, 3fh,090h, 3fh,0f4h, 54h, 27h,0d4h, 2fh,090h
db   3fh,0f4h, 64h, 27h,0d4h, 2fh, 70h,0ffh,0b4h, 27h
db  0d4h, 2fh, 60h,0ffh, 2fh,0a4h, 27h,0d4h, 2fh,0f0h
db   60h, 2fh,0a4h,0f7h, 2fh,0f0h, 60h, 2fh,0f7h,0a7h
db   2fh,0f0h, 60h, 2fh,0c7h,0c4h, 17h, 2fh,0f0h, 60h
db   2fh, 17h,0f4h, 84h, 17h, 2fh,0f0h, 60h, 2fh, 17h
db  0f4h, 84h, 17h,0ffh,0afh, 17h,0f4h, 84h, 27h,0ffh
db   8fh, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0b4h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0a7h
brick_3 \
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 54h,0bfh,0f4h, 24h, 27h,0f4h, 34h,0ffh,0f4h
db   27h,0f4h, 24h, 4fh,090h, 4fh,0e4h, 27h,0f4h, 14h
db   3fh,0d0h, 3fh,0d4h, 27h,0f4h, 3fh,0f0h, 3fh,0c4h
db   27h,0e4h, 3fh,0f0h, 20h, 3fh,0b4h,0f7h, 17h, 2fh
db  0f0h, 40h, 2fh,0f7h,0b7h, 3fh, 70h, 5fh, 70h, 3fh
db  0c7h,0c4h, 17h, 2fh, 60h,09fh, 60h, 2fh, 17h,0f4h
db   84h, 17h, 2fh, 60h, 3fh, 34h, 3fh, 60h, 2fh, 17h
db  0f4h, 84h, 17h, 2fh, 50h, 3fh, 54h, 3fh, 50h, 2fh
db   17h,0f4h, 84h, 17h, 2fh, 50h, 2fh, 74h, 2fh, 50h
db   2fh, 17h,0f4h, 84h, 17h,09fh, 64h, 3fh, 50h, 2fh
db   17h,0f4h, 84h, 27h, 7fh, 64h, 3fh, 60h, 2fh, 17h
db  0f4h, 84h, 27h, 84h, 8fh, 60h, 2fh, 17h,0f4h, 84h
db   27h, 74h, 7fh, 70h, 3fh, 17h,0f4h, 84h, 27h, 74h
db   2fh,0c0h, 2fh, 27h,0f4h, 84h, 27h, 74h, 2fh,0b0h
db   2fh, 14h, 27h,0b4h,0f7h, 67h, 2fh,0b0h, 3fh,0f7h
db  0f7h, 47h, 2fh,0c0h, 3fh,0c7h,0f4h, 64h, 7fh, 80h
db   2fh,0a4h, 27h,0f4h, 74h, 8fh, 60h, 3fh,094h, 27h
db  0f4h, 84h, 27h, 24h, 4fh, 60h, 2fh,094h, 27h,0f4h
db   84h, 27h, 44h, 2fh, 60h, 2fh,094h, 27h,0d4h, 7fh
db   34h, 27h, 44h, 3fh, 50h, 2fh,094h, 27h,0c4h,09fh
db   24h, 27h, 54h, 2fh, 50h, 2fh,094h, 27h,0c4h, 2fh
db   50h, 2fh, 24h, 27h, 54h, 2fh, 50h, 2fh,094h, 27h
db  0c4h, 2fh, 50h, 2fh, 24h, 27h, 54h, 2fh, 50h, 2fh
db  094h, 27h,0c4h, 2fh, 50h, 3fh, 14h, 27h, 44h, 3fh
db   50h, 2fh,094h, 27h,0c4h, 2fh, 60h, 2fh, 14h, 27h
db   44h, 2fh, 60h, 2fh,094h, 27h,0c4h, 2fh, 60h, 4fh
db   17h, 24h, 4fh, 60h, 2fh,094h,0e7h, 3fh, 60h,09fh
db   60h, 3fh,0f7h,097h, 2fh, 80h, 5fh, 80h, 2fh,0c7h
db  0c4h, 17h, 3fh,0f0h, 40h, 3fh, 17h,0f4h, 84h, 27h
db   3fh,0f0h, 20h, 3fh, 27h,0f4h, 84h, 27h, 14h, 3fh
db  0f0h, 3fh, 14h, 27h,0f4h, 84h, 27h, 24h, 3fh,0d0h
db   3fh, 24h, 27h,0f4h, 84h, 27h, 34h, 4fh,090h, 4fh
db   34h, 27h,0f4h, 84h, 27h, 44h,0ffh, 44h, 27h,0f4h
db   84h, 27h, 64h,0bfh, 64h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0b4h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0a7h
brick_4 \
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 34h, 4fh, 14h
db   27h, 24h, 4fh,0f4h, 24h, 27h,0f4h, 24h, 6fh, 27h
db   14h, 6fh,0f4h, 14h, 27h,0f4h, 14h, 2fh, 40h, 2fh
db   17h, 2fh, 40h, 2fh,0f4h, 27h,0f4h, 14h, 2fh, 40h
db   2fh, 17h, 2fh, 40h, 2fh,0f4h, 27h,0f4h, 14h, 2fh
db   40h, 2fh, 17h, 2fh, 40h, 2fh,0f4h,0f7h, 27h, 2fh
db   50h, 2fh, 17h, 2fh, 40h, 2fh,0f7h,0f7h, 27h, 2fh
db   50h, 2fh, 17h, 2fh, 40h, 2fh,0f7h, 27h,0c4h, 27h
db   14h, 2fh, 50h, 2fh, 14h, 2fh, 40h, 2fh, 44h, 27h
db  0f4h, 84h, 27h, 14h, 2fh, 40h, 2fh, 24h, 2fh, 40h
db   2fh, 44h, 27h,0f4h, 84h, 27h, 2fh, 50h, 2fh, 24h
db   2fh, 40h, 2fh, 44h, 27h,0f4h, 84h, 27h, 2fh, 50h
db   2fh, 24h, 2fh, 40h, 2fh, 44h, 27h,0f4h, 84h, 27h
db   2fh, 50h, 2fh, 24h, 2fh, 40h, 2fh, 44h, 27h,0f4h
db   84h, 27h, 2fh, 40h, 2fh, 34h, 2fh, 40h, 2fh, 44h
db   27h,0f4h, 84h, 27h, 2fh, 40h, 2fh, 34h, 2fh, 40h
db   2fh, 44h, 27h,0f4h, 84h, 17h, 2fh, 50h, 2fh, 34h
db   2fh, 40h, 2fh, 44h, 27h,0f4h, 84h, 17h, 2fh, 50h
db   2fh, 34h, 2fh, 40h, 2fh, 44h, 27h,0f4h, 84h, 17h
db   2fh, 50h, 2fh, 34h, 2fh, 40h, 2fh, 44h, 27h,0b4h
db  0d7h, 2fh, 40h, 2fh, 47h, 2fh, 40h, 2fh,0f7h,0e7h
db   2fh, 50h, 8fh, 40h, 6fh,0d7h,0c4h, 2fh, 50h, 8fh
db   40h, 7fh,0a4h, 27h,0c4h, 2fh,0f0h, 80h, 2fh,094h
db   27h,0c4h, 2fh,0f0h, 80h, 2fh,094h, 27h,0c4h, 2fh
db  0f0h, 80h, 2fh,094h, 27h,0c4h, 2fh,0f0h, 80h, 2fh
db  094h, 27h,0d4h,0efh, 40h, 7fh,0a4h, 27h,0e4h,0dfh
db   40h, 6fh,0b4h, 27h,0f4h, 84h, 27h, 2fh, 40h, 2fh
db  0f4h, 27h,0f4h, 84h, 27h, 2fh, 40h, 2fh,0f4h, 27h
db  0f4h, 84h, 27h, 2fh, 40h, 2fh,0f4h, 27h,0f4h, 84h
db   27h, 2fh, 40h, 2fh,0f4h,0f7h,0c7h, 2fh, 40h, 2fh
db  0f7h,0f7h,0c7h, 2fh, 40h, 2fh,0f7h, 27h,0c4h, 27h
db  0b4h, 2fh, 40h, 2fh, 44h, 27h,0f4h, 84h, 27h,0b4h
db   2fh, 40h, 2fh, 44h, 27h,0f4h, 84h, 27h,0b4h, 2fh
db   40h, 2fh, 44h, 27h,0f4h, 84h, 27h,0b4h, 2fh, 40h
db   2fh, 44h, 27h,0f4h, 84h, 27h,0c4h, 6fh, 54h, 27h
db  0f4h, 84h, 27h,0d4h, 4fh, 64h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0b4h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0a7h
brick_5 \
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h,0ffh, 5fh,0d4h, 27h,0e4h,0ffh, 7fh,0c4h, 27h
db  0e4h, 2fh,0f0h, 30h, 2fh,0c4h, 27h,0e4h, 2fh,0f0h
db   30h, 2fh,0c4h, 27h,0d4h, 3fh,0f0h, 30h, 2fh,0c4h
db   27h,0d4h, 2fh,0f0h, 40h, 2fh,0c4h,0f7h, 2fh,0f0h
db   40h, 2fh,0f7h,0c7h, 2fh, 60h,0ffh,0e7h,0c4h, 17h
db   2fh, 60h,0ffh, 14h, 27h,0f4h, 84h, 3fh, 50h, 3fh
db  0e4h, 27h,0f4h, 84h, 2fh, 60h, 2fh,0f4h, 27h,0f4h
db   84h, 2fh, 60h,09fh, 84h, 27h,0f4h, 84h, 2fh, 60h
db  0afh, 74h, 27h,0f4h, 84h, 2fh,0e0h, 4fh, 54h, 27h
db  0f4h, 74h, 3fh,0f0h, 10h, 3fh, 44h, 27h,0f4h, 74h
db   2fh,0f0h, 40h, 2fh, 34h, 27h,0f4h, 74h, 2fh,0f0h
db   50h, 2fh, 24h, 27h,0f4h, 74h, 2fh,0f0h, 60h, 2fh
db   14h, 27h,0b4h,0b7h, 2fh, 70h, 6fh, 80h, 3fh,0f7h
db  097h,0ffh, 1fh, 80h, 2fh,0d7h,0c4h,09fh, 24h, 27h
db   14h, 2fh, 70h, 3fh,0a4h, 27h,0f4h, 84h, 27h, 24h
db   2fh, 70h, 2fh,0a4h, 27h,0f4h, 84h, 27h, 34h, 2fh
db   60h, 2fh,0a4h, 27h,0f4h, 84h, 27h, 34h, 2fh, 60h
db   2fh,0a4h, 27h,0f4h, 84h, 27h, 34h, 2fh, 60h, 2fh
db  0a4h, 27h,0f4h, 84h, 27h, 34h, 2fh, 60h, 2fh,0a4h
db   27h,0d4h, 5fh, 54h, 27h, 34h, 2fh, 60h, 2fh,0a4h
db   27h,0c4h, 7fh, 44h, 27h, 34h, 2fh, 60h, 2fh,0a4h
db   27h,0b4h, 3fh, 30h, 3fh, 34h, 27h, 24h, 2fh, 70h
db   2fh,0a4h, 27h,0b4h, 2fh, 50h, 3fh, 24h, 27h, 14h
db   2fh, 80h, 2fh,0a4h, 27h,0b4h, 2fh, 70h, 7fh, 80h
db   2fh,0b4h,0d7h, 2fh, 80h, 5fh,090h, 2fh,0f7h,0a7h
db   2fh,0f0h, 50h, 3fh,0d7h,0c4h, 17h, 2fh,0f0h, 30h
db   3fh, 14h, 27h,0f4h, 84h, 27h, 2fh,0f0h, 4fh, 24h
db   27h,0f4h, 84h, 27h, 14h, 2fh,0d0h, 4fh, 34h, 27h
db  0f4h, 84h, 27h, 24h, 3fh,090h, 4fh, 54h, 27h,0f4h
db   84h, 27h, 34h,0efh, 64h, 27h,0f4h, 84h, 27h, 44h
db  0bfh, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0b4h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0a7h
brick_6 \
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 17h, 8fh
db  0f4h, 14h, 27h,0f4h, 84h,0bfh,0e4h, 27h,0f4h, 74h
db   4fh, 60h, 2fh,0e4h, 27h,0f4h, 64h, 3fh, 80h, 3fh
db  0d4h, 27h,0f4h, 44h, 4fh,0a0h, 2fh,0d4h,0f7h, 57h
db   4fh,0b0h, 2fh,0f7h,0f7h, 27h, 3fh,0a0h, 5fh,0f7h
db  0c4h, 27h, 24h, 3fh,090h, 6fh, 34h, 27h,0f4h, 84h
db   27h, 14h, 3fh,090h, 5fh, 54h, 27h,0f4h, 84h, 27h
db   4fh, 70h, 4fh, 84h, 27h,0f4h, 84h, 27h, 3fh, 70h
db   4fh,094h, 27h,0f4h, 84h, 17h, 3fh, 70h, 4fh,0a4h
db   27h,0f4h, 84h, 3fh, 70h,09fh, 64h, 27h,0f4h, 84h
db   3fh, 60h,0cfh, 44h, 27h,0f4h, 84h, 2fh, 60h, 2fh
db   70h, 6fh, 24h, 27h,0f4h, 84h, 2fh,0f0h, 30h, 4fh
db   14h, 27h,0f4h, 74h, 3fh,0f0h, 40h, 4fh, 27h,0b4h
db  0b7h, 3fh,0f0h, 60h, 3fh,0f7h, 87h, 2fh,0f0h, 70h
db   3fh,0c7h,0b4h, 2fh,0b0h, 2fh,0a0h, 3fh,094h, 27h
db  0b4h, 2fh,090h, 6fh,090h, 2fh,094h, 27h,0b4h, 2fh
db   80h, 2fh, 27h, 24h, 2fh, 80h, 3fh, 84h, 27h,0b4h
db   2fh, 70h, 2fh, 14h, 27h, 34h, 2fh, 80h, 2fh, 84h
db   27h,0b4h, 2fh, 70h, 1fh, 24h, 27h, 44h, 1fh, 80h
db   2fh, 84h, 27h,0b4h, 2fh, 60h, 2fh, 24h, 27h, 44h
db   2fh, 70h, 2fh, 84h, 27h,0b4h, 2fh, 60h, 1fh, 34h
db   27h, 54h, 1fh, 70h, 2fh, 84h, 27h,0b4h, 2fh, 60h
db   2fh, 24h, 27h, 44h, 2fh, 70h, 2fh, 84h, 27h,0b4h
db   2fh, 70h, 1fh, 24h, 27h, 44h, 1fh, 80h, 2fh, 84h
db   27h,0b4h, 2fh, 70h, 2fh, 14h, 27h, 34h, 2fh, 80h
db   2fh, 84h, 27h,0b4h, 3fh, 70h, 3fh, 17h, 24h, 2fh
db   80h, 3fh, 84h,0d7h, 3fh,090h, 5fh,090h, 3fh,0f7h
db   77h, 3fh,0f0h, 60h, 3fh,0b7h,0c4h, 17h, 3fh,0f0h
db   40h, 4fh,0f4h, 84h, 27h, 3fh,0f0h, 20h, 4fh, 17h
db  0f4h, 84h, 27h, 14h, 3fh,0f0h, 4fh, 27h,0f4h, 84h
db   27h, 14h, 4fh,0d0h, 4fh, 14h, 27h,0f4h, 84h, 27h
db   24h, 6fh, 70h, 5fh, 34h, 27h,0f4h, 84h, 27h, 34h
db  0ffh, 54h, 27h,0f4h, 84h, 27h, 74h,0afh, 64h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0b4h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0a7h
brick_7 \
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0e4h,0ffh,09fh,0a4h, 27h,0d4h
db  0ffh,0bfh,094h, 27h,0d4h, 2fh,0f0h, 70h, 2fh,094h
db   27h,0d4h, 2fh,0f0h, 70h, 2fh,094h, 27h,0d4h, 2fh
db  0f0h, 70h, 2fh,094h, 27h,0d4h, 2fh,0f0h, 70h, 2fh
db  094h, 27h,0d4h,0ffh, 2fh, 60h, 3fh,094h,0f7h, 17h
db  0ffh, 60h, 3fh,0f7h,0f7h, 87h, 2fh, 60h, 3fh,0d7h
db  0c4h, 27h,0b4h, 2fh, 60h, 3fh, 14h, 27h,0f4h, 84h
db   27h,0a4h, 3fh, 50h, 3fh, 24h, 27h,0f4h, 84h, 27h
db  0a4h, 2fh, 60h, 2fh, 34h, 27h,0f4h, 84h, 27h,094h
db   3fh, 50h, 3fh, 34h, 27h,0f4h, 84h, 27h,094h, 2fh
db   60h, 2fh, 44h, 27h,0f4h, 84h, 27h,094h, 2fh, 50h
db   3fh, 44h, 27h,0f4h, 84h, 27h, 84h, 3fh, 50h, 2fh
db   54h, 27h,0f4h, 84h, 27h, 84h, 2fh, 50h, 3fh, 54h
db   27h,0f4h, 84h, 27h, 84h, 2fh, 50h, 2fh, 64h, 27h
db  0f4h, 84h, 27h, 84h, 2fh, 50h, 2fh, 64h, 27h,0b4h
db  0f7h, 67h, 3fh, 50h, 2fh,0f7h,0f7h,0a7h, 2fh, 50h
db   2fh,0f7h, 57h,0f4h, 64h, 2fh, 50h, 2fh,0f4h, 34h
db   27h,0f4h, 64h, 2fh, 50h, 2fh,0f4h, 34h, 27h,0f4h
db   64h, 2fh, 50h, 2fh,0f4h, 34h, 27h,0f4h, 64h, 2fh
db   50h, 2fh,0f4h, 34h, 27h,0f4h, 64h, 2fh, 50h, 2fh
db  0f4h, 34h, 27h,0f4h, 64h, 2fh, 50h, 2fh,0f4h, 34h
db   27h,0f4h, 64h, 2fh, 50h, 2fh,0f4h, 34h, 27h,0f4h
db   64h, 2fh, 50h, 2fh,0f4h, 34h, 27h,0f4h, 64h, 2fh
db   50h, 2fh,0f4h, 34h, 27h,0f4h, 64h, 2fh, 50h, 2fh
db  0f4h, 34h, 27h,0f4h, 64h, 2fh, 50h, 2fh,0f4h, 34h
db  0f7h, 87h, 2fh, 50h, 2fh,0f7h,0f7h,0b7h, 2fh, 50h
db   2fh,0f7h, 57h,0c4h, 27h, 74h, 2fh, 50h, 2fh, 74h
db   27h,0f4h, 84h, 27h, 74h, 2fh, 50h, 2fh, 74h, 27h
db  0f4h, 84h, 27h, 74h, 2fh, 50h, 2fh, 74h, 27h,0f4h
db   84h, 27h, 74h,09fh, 74h, 27h,0f4h, 84h, 27h, 84h
db   7fh, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0b4h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0a7h
brick_8 \
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 54h,0afh,0f4h, 34h, 27h,0f4h, 24h,0ffh,0f4h
db   14h, 27h,0f4h, 14h, 5fh, 80h, 4fh,0f4h, 27h,0f4h
db   4fh,0c0h, 3fh,0e4h, 27h,0f4h, 3fh,0e0h, 3fh,0d4h
db   27h,0e4h, 3fh,0f0h, 10h, 2fh,0d4h,0f7h, 17h, 3fh
db  0f0h, 10h, 3fh,0f7h,0d7h, 2fh, 70h, 4fh, 70h, 2fh
db  0e7h,0c4h, 27h, 2fh, 60h, 2fh, 24h, 2fh, 60h, 2fh
db   14h, 27h,0f4h, 84h, 27h, 2fh, 50h, 2fh, 44h, 2fh
db   50h, 2fh, 14h, 27h,0f4h, 84h, 27h, 2fh, 50h, 2fh
db   44h, 2fh, 50h, 2fh, 14h, 27h,0f4h, 84h, 27h, 2fh
db   60h, 2fh, 24h, 2fh, 60h, 2fh, 14h, 27h,0f4h, 84h
db   27h, 2fh, 70h, 4fh, 70h, 2fh, 14h, 27h,0f4h, 84h
db   27h, 3fh,0f0h, 10h, 3fh, 14h, 27h,0f4h, 84h, 27h
db   14h, 2fh,0f0h, 10h, 2fh, 24h, 27h,0f4h, 84h, 27h
db   14h, 3fh,0e0h, 2fh, 34h, 27h,0f4h, 84h, 27h, 24h
db   3fh,0c0h, 3fh, 34h, 27h,0f4h, 84h, 27h, 14h, 3fh
db  0e0h, 3fh, 24h, 27h,0b4h,0e7h, 3fh,0f0h, 10h, 3fh
db   14h,0f7h,0b7h, 3fh,0f0h, 30h, 3fh,0d7h,0c4h, 17h
db   2fh, 80h, 4fh, 80h, 2fh, 17h,0a4h, 27h,0c4h, 3fh
db   60h, 3fh, 17h, 14h, 3fh, 60h, 3fh,0a4h, 27h,0c4h
db   2fh, 60h, 2fh, 14h, 27h, 34h, 2fh, 60h, 2fh,0a4h
db   27h,0c4h, 2fh, 60h, 1fh, 24h, 27h, 44h, 1fh, 60h
db   2fh,0a4h, 27h,0c4h, 2fh, 50h, 2fh, 24h, 27h, 44h
db   2fh, 50h, 2fh,0a4h, 27h,0c4h, 2fh, 50h, 1fh, 34h
db   27h, 54h, 1fh, 50h, 2fh,0a4h, 27h,0c4h, 2fh, 50h
db   1fh, 34h, 27h, 54h, 1fh, 50h, 2fh,0a4h, 27h,0c4h
db   2fh, 50h, 2fh, 24h, 27h, 44h, 2fh, 50h, 2fh,0a4h
db   27h,0c4h, 2fh, 60h, 1fh, 24h, 27h, 44h, 1fh, 60h
db   2fh,0a4h, 27h,0c4h, 2fh, 60h, 2fh, 14h, 27h, 34h
db   2fh, 60h, 2fh,0a4h, 27h,0c4h, 3fh, 60h, 3fh, 17h
db   14h, 3fh, 60h, 3fh,0a4h,0f7h, 2fh, 80h, 4fh, 80h
db   2fh,0f7h,0b7h, 3fh,0f0h, 30h, 3fh,0d7h,0c4h, 27h
db   3fh,0f0h, 10h, 4fh, 27h,0f4h, 84h, 27h, 14h, 3fh
db  0e0h, 3fh, 24h, 27h,0f4h, 84h, 27h, 24h, 3fh,0c0h
db   3fh, 34h, 27h,0f4h, 84h, 27h, 34h, 4fh, 80h, 4fh
db   44h, 27h,0f4h, 84h, 27h, 44h,0efh, 54h, 27h,0f4h
db   84h, 27h, 64h,0afh, 74h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0b4h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0a7h
;=====block=data=======
block_wall \
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0c7h,0c4h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0b4h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0a7h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0c7h,0c4h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h
db   84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h
db   27h,0f4h, 84h, 27h,0f4h, 84h, 27h,0f4h, 84h, 27h
db  0b4h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0a7h
block_ground \
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0a7h
block_box \ 
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h, 67h, 70h,0f7h,0f7h, 67h, 70h, 78h, 60h,0f7h
db  0c7h, 30h,0f8h, 58h, 40h,0f7h, 67h, 20h,0f8h,0c8h
db   20h,0f7h, 27h, 20h,0f8h,0f8h, 18h, 20h,0e7h, 10h
db  0e8h, 70h,0e8h, 10h,0c7h, 10h,0e8h, 10h, 68h, 20h
db  0e8h, 10h,0a7h, 10h,0e8h, 10h,098h, 10h,0e8h, 10h
db   87h, 10h,0f8h, 20h, 78h, 30h,0e8h, 10h, 67h, 10h
db  0f8h, 10h, 28h, 80h, 28h, 10h,0e8h, 10h, 57h, 10h
db  0f8h, 10h,0c8h, 10h,0e8h, 10h, 57h, 10h,0f8h, 10h
db  0c8h, 10h,0e8h, 10h, 57h, 10h,0f8h, 18h, 10h,0a8h
db   10h,0f8h, 10h, 57h, 10h,0f8h, 18h, 30h, 38h, 50h
db  0f8h, 18h, 10h, 67h, 10h,0f8h, 38h, 30h,0f8h, 58h
db   10h, 77h, 20h,0f8h,0f8h,098h, 20h, 77h, 10h, 18h
db   10h,0f8h,0f8h, 78h, 30h, 77h, 10h, 28h, 10h,0f8h
db  0f8h, 58h, 10h, 28h, 10h, 87h, 10h, 28h, 20h,0f8h
db  0f8h, 18h, 20h, 38h, 10h, 87h, 10h, 48h, 30h,0f8h
db  0b8h, 20h, 48h, 10h,0a7h, 10h, 68h, 30h,0f8h, 68h
db   30h, 58h, 10h,0a7h, 10h,098h,0f0h, 60h, 78h, 10h
db  0b7h, 10h,0f8h,0f8h, 78h, 10h,0c7h, 10h,0f8h,0f8h
db   58h, 10h,0d7h, 10h,0f8h,0f8h, 58h, 10h,0e7h, 10h
db  0f8h,0f8h, 38h, 10h,0f7h, 10h,0f8h,0f8h, 38h, 10h
db  0f7h, 17h, 10h,0f8h,0f8h, 18h, 10h,0f7h, 37h, 10h
db  0f8h,0f8h, 10h,0f7h, 47h, 30h,0f8h, 88h, 40h,0f7h
db   87h, 30h,0f8h, 28h, 30h,0f7h,0f7h,0f0h, 20h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db   27h
block_desti \
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h, 17h,0f0h,0f0h
db   80h,0a7h,0f0h,0f0h,0c0h, 67h, 40h,0fbh,0fbh, 8bh
db   40h, 47h, 20h,0fbh, 4bh, 1fh, 7bh, 1fh, 8bh, 1fh
db   5bh, 20h, 47h, 20h, 3bh, 1fh,0abh, 1fh,0fbh,0cbh
db   20h, 37h, 20h,0fbh,0fbh, 1bh, 1fh,0cbh, 20h, 27h
db   20h, 8bh, 1fh, 4bh, 1fh,0abh, 1fh,0cbh, 1fh, 6bh
db   20h, 27h, 20h,0fbh, 5bh, 1fh,0fbh, 8bh, 20h, 27h
db   20h,0fbh,0dbh, 1fh,0fbh, 20h, 27h, 20h,0fbh, 1bh
db   1fh,0fbh, 2bh, 1fh, 4bh, 1fh, 4bh, 20h, 27h, 20h
db   4bh, 1fh, 6bh, 1fh,0bbh, 1fh,0fbh, 5bh, 20h, 37h
db   20h,0fbh,0fbh, 1bh, 1fh,0abh, 20h, 47h, 30h,0fbh
db  0fbh,0abh, 30h, 47h, 40h,0fbh,0fbh, 8bh, 40h, 57h
db  0f0h,0f0h,0e0h, 67h, 20h, 1fh,0f0h,0f0h, 80h, 1fh
db   20h, 67h, 20h,0ffh,0ffh,0afh, 20h, 67h, 20h,0ffh
db  0ffh,0afh, 20h, 67h, 20h,0ffh,0ffh,0afh, 20h, 67h
db   20h,0ffh,0ffh,0afh, 20h, 77h, 20h,0ffh,0ffh, 8fh
db   20h, 87h, 20h, 5fh, 50h,0ffh,0dfh, 20h, 87h, 20h
db   4fh, 10h, 5bh, 10h,0ffh,0cfh, 20h, 87h, 20h, 4fh
db   10h, 5bh, 10h,0ffh,0cfh, 20h, 87h, 20h, 4fh, 10h
db   5bh, 10h,0ffh,0cfh, 20h, 87h, 40h, 2fh, 10h, 5bh
db   10h,0ffh,0afh, 40h,097h, 60h, 5bh,0f0h,0e0h,0d7h
db   40h, 5bh,0f0h,0a0h,0f7h, 47h, 1fh, 8bh, 1fh,0f7h
db  0f7h,0a7h, 1fh, 8bh, 1fh,0f7h,0f7h,0a7h, 1fh, 8bh
db   1fh,0f7h,0f7h,097h, 2fh, 8bh, 1fh,0f7h,0f7h,097h
db   1fh,09bh, 2fh,0f7h,0f7h, 87h, 1fh,0abh, 2fh,0f7h
db  0f7h, 77h, 3fh,09bh, 1fh,0f7h,0f7h,097h, 2fh, 8bh
db   1fh,0f7h,0f7h,0a7h,0afh,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h, 77h
block_desti_ok \
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h, 17h,0f0h,0f0h
db   80h,0a7h,0f0h,0f0h,0c0h, 67h, 40h,0fbh,0fbh, 8bh
db   40h, 47h, 20h, 8bh, 2fh,09bh, 1fh, 2bh, 2fh, 3bh
db   1fh, 8bh, 1fh, 5bh, 20h, 47h, 20h, 3bh, 1fh, 4bh
db   2fh, 4bh, 1fh, 7bh, 2fh, 8bh, 2fh, 8bh, 20h, 37h
db   20h, 2bh, 2fh,0fbh,0cbh, 1fh, 1bh, 2fh, 5bh, 2fh
db   2bh, 20h, 27h, 20h, 2bh, 2fh, 4bh, 1fh, 4bh, 1fh
db   2bh, 2fh, 6bh, 1fh,0cbh, 1fh, 2bh, 2fh, 2bh, 20h
db   27h, 20h,0fbh, 1bh, 2fh, 2bh, 1fh,0fbh, 8bh, 20h
db   27h, 20h, 7bh, 2fh,0fbh, 4bh, 1fh, 1bh, 2fh,0cbh
db   20h, 27h, 20h, 7bh, 2fh, 7bh, 1fh,0dbh, 2fh, 2bh
db   1fh, 4bh, 1fh, 4bh, 20h, 27h, 20h, 4bh, 1fh, 6bh
db   1fh, 8bh, 2fh, 1bh, 1fh,0cbh, 2fh, 6bh, 20h, 37h
db   20h,0dbh, 2fh, 4bh, 2fh, 5bh, 2fh, 3bh, 1fh, 3bh
db   2fh, 5bh, 20h, 47h, 30h, 4bh, 2fh, 6bh, 2fh,0bbh
db   2fh,0dbh, 30h, 47h, 40h, 3bh, 2fh,0fbh,0fbh, 3bh
db   40h, 57h,0f0h,0f0h,0e0h, 67h, 20h, 1fh,0f0h,0f0h
db   80h, 1fh, 20h, 67h, 20h,0ffh,0ffh,0afh, 20h, 67h
db   20h,0ffh,09fh, 22h,0efh, 20h, 67h, 20h,0ffh, 8fh
db   32h,0efh, 20h, 67h, 20h,0ffh, 7fh, 32h,0ffh, 20h
db   77h, 20h,0ffh, 22h, 3fh, 32h,0ffh, 20h, 87h, 20h
db  0ffh, 32h, 1fh, 32h,0ffh, 1fh, 20h, 87h, 20h,0ffh
db   1fh, 52h,0ffh, 2fh, 20h, 87h, 20h,0ffh, 1fh, 42h
db  0ffh, 3fh, 20h, 87h, 20h,0ffh, 2fh, 22h,0ffh, 4fh
db   20h, 87h, 40h,0ffh,0ffh, 4fh, 40h,097h,0f0h,0f0h
db  0a0h,0d7h,0f0h,0f0h, 40h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h,0f7h
db  0f7h,0f7h, 37h
;====player=data=======
player_1 \
db  097h, 5fh, 17h, 1fh, 47h, 1fh,0f7h,0f7h, 77h, 7fh
db   67h, 10h, 2fh, 40h, 3fh,0f7h,0b7h,0efh,0b0h, 2fh
db  0f7h, 87h,0cfh,0d0h, 2fh, 10h,0f7h, 67h, 7fh, 14h
db   1fh, 10h,0ffh, 1fh, 20h, 1fh, 10h,0f7h, 57h, 7fh
db   1eh,0f0h, 80h,0f7h, 47h, 7fh, 1ch,0f0h, 80h, 1fh
db  0f7h, 37h, 7fh,0f0h,0a0h,0f7h, 17h, 1fh, 17h, 6fh
db   14h,0b0h, 1fh, 30h, 1fh, 30h, 1fh, 60h,0f7h, 27h
db   4fh, 14h, 50h, 1fh, 30h, 14h, 1fh, 10h, 14h, 2fh
db   20h, 2fh, 20h, 2fh, 50h, 1fh,0f7h, 6fh, 40h, 2fh
db   30h, 2fh, 10h, 3fh, 20h, 3fh, 10h, 3fh, 50h, 1fh
db  0e7h, 5fh, 40h, 3fh, 20h, 3fh, 10h, 4fh, 1eh, 10h
db   3fh, 14h, 3fh, 30h, 1fh,0e7h, 4fh, 1eh, 1fh, 20h
db   1fh, 10h, 3fh, 10h, 4fh, 10h, 1eh,0cfh, 40h,0e7h
db   20h, 1eh, 3fh, 20h, 1fh, 14h, 3fh, 10h, 5fh, 10h
db  0cfh, 1eh, 30h,0d7h, 1fh, 50h, 1fh, 20h,0ffh,0afh
db   30h,0d7h, 1fh, 50h, 2fh, 10h,0ffh,0afh, 30h,0d7h
db   1fh, 50h, 1fh, 17h, 10h,0ffh,0afh, 20h, 2fh,0c7h
db   1fh, 50h, 1fh, 17h,0ffh, 1fh, 1eh, 1fh, 1eh, 7fh
db   10h, 1ch, 2fh,0c7h, 1fh, 50h, 1fh, 17h, 1fh, 14h
db   8fh, 1eh,0dfh, 10h, 14h, 2fh, 1eh, 1fh,0c7h, 1fh
db   50h, 1fh, 17h, 1fh, 10h,0dfh, 1ch, 2eh, 1ch, 14h
db   1eh, 1fh, 1eh, 14h, 4fh, 1eh, 1fh,0c7h, 1fh, 50h
db   1fh, 17h, 3fh, 10h, 1fh, 14h, 5fh, 10h, 24h, 10h
db   6fh, 10h, 8fh,0c7h, 1fh, 50h, 1fh, 17h, 4fh, 10h
db   4fh, 10h, 2fh, 1eh, 3fh, 10h, 1fh, 10h, 2fh, 1eh
db   8fh,0c7h, 1fh, 50h, 1fh, 17h,0ffh, 6fh, 14h, 7fh
db  0d7h, 1fh, 50h, 1fh, 27h, 3fh, 10h,09fh, 1eh,0dfh
db  0e7h, 1fh, 50h, 1fh, 37h, 3fh, 14h, 4fh, 1eh, 5fh
db   10h,0bfh,0e7h, 1fh, 60h, 37h,0ffh, 1ch,09fh,0f7h
db   17h, 70h, 37h,0efh, 14h,09fh,0f7h, 17h, 1fh, 70h
db   1fh, 27h, 5fh, 14h, 1ch, 14h, 1ch, 1fh, 3ch, 2fh
db   1eh, 1ch, 5fh,0f7h, 37h,090h,0ffh, 8fh, 17h, 1fh
db  0f7h, 27h,0b0h,0cfh, 14h, 6fh,0f7h, 67h, 1fh,0a0h
db   4fh, 1ch, 10h, 14h, 1fh, 34h, 5fh, 20h, 1fh,0f7h
db   77h, 1fh, 80h, 14h, 5fh, 1ch, 14h, 1ch, 6fh, 60h
db   1fh,0f7h, 67h, 1fh, 80h, 3fh, 14h, 3fh, 14h, 4fh
db   80h, 1fh,0f7h, 77h, 1fh, 70h, 14h, 3fh, 1ch, 1eh
db   3fh, 1eh,0a0h,0f7h,097h, 70h, 16h, 10h, 5fh, 10h
db   1fh,0a0h,0f7h,097h, 70h, 1fh, 1ch, 14h, 3fh, 14h
db   2fh,0a0h,0f7h,097h, 70h,09fh,0a0h,0f7h,097h, 70h
db   16h, 3fh, 1eh, 3fh, 16h,0a0h, 1fh,0f7h, 87h, 70h
db   3fh, 10h, 1fh, 10h, 1fh, 1eh, 1fh,0a0h, 1fh,0f7h
db   87h, 70h, 1fh, 16h, 14h, 10h, 1fh, 1eh, 10h, 1eh
db   1fh,0a0h, 1fh,0f7h, 77h, 1fh, 70h,09fh,0b0h,0f7h
db   87h, 70h, 3fh, 10h, 5fh,0b0h,0f7h, 77h, 1fh, 70h
db  09fh,0b0h,0f7h, 77h, 1fh, 70h,09fh,0b0h,0f7h, 77h
db   1fh, 70h,09fh,0b0h,0f7h, 77h, 1fh, 70h,09fh, 16h
db  0a0h, 1fh,0f7h, 67h, 1fh, 70h,09fh,0b0h, 1fh,0f7h
db   67h, 1fh, 70h,09fh,0b0h, 1fh,0f7h, 67h, 1fh, 70h
db  09fh,0b0h, 1fh,0f7h, 67h, 1fh, 70h,09fh,0b0h, 1fh
db   77h
player_2 \
db  0f7h, 47h,0efh,0f7h,0f7h, 47h, 2fh,0e0h, 1fh,0f7h
db  0f7h, 27h, 1fh, 30h,0cfh, 20h, 2fh,0f7h,0d7h, 2fh
db   20h,0ffh, 30h, 1fh,0f7h,0b7h, 1fh, 20h,0ffh, 4fh
db   20h, 1fh,0f7h,097h, 1fh, 20h,0ffh, 6fh, 20h, 1fh
db  0f7h, 77h, 1fh, 20h,0ffh, 8fh, 20h, 1fh,0f7h, 57h
db   1fh, 20h,0ffh,0afh, 20h, 1fh,0f7h, 47h, 1fh, 10h
db  0ffh,0cfh, 10h, 1fh,0f7h, 37h, 1fh, 20h,0ffh,0cfh
db   20h, 1fh,0f7h, 27h, 1fh, 10h,0ffh,0efh, 10h, 1fh
db  0f7h, 17h, 1fh, 20h,0ffh,0efh, 20h, 1fh,0f7h, 1fh
db   10h,0ffh,0ffh, 1fh, 10h, 1fh,0e7h, 1fh, 20h,0ffh
db  0ffh, 1fh, 20h, 1fh,0d7h, 1fh, 20h,0ffh,0ffh, 1fh
db   20h, 1fh,0d7h, 1fh, 30h,0ffh,0efh, 30h, 1fh,0c7h
db   1fh, 40h,0ffh,0efh, 30h, 1fh,0c7h, 1fh, 40h,0ffh
db  0efh, 40h, 1fh,0b7h, 1fh, 40h,0ffh,0efh, 40h, 1fh
db  0b7h, 1fh, 40h,0ffh,0efh, 40h, 1fh,0b7h, 1fh, 40h
db  0ffh,0efh, 40h, 1fh,0b7h, 1fh, 40h,0ffh,0efh, 40h
db   1fh,0b7h, 1fh, 40h, 5fh, 40h,0bfh, 40h, 5fh, 30h
db   1fh,0d7h, 1fh, 30h, 4fh, 20h, 2fh, 20h,09fh, 20h
db   2fh, 20h, 4fh, 30h, 3fh,097h, 3fh, 30h,0ffh,0efh
db   60h, 1fh, 77h, 1fh, 40h,0ffh,0ffh, 3fh, 10h, 3fh
db   10h, 1fh, 57h, 1fh, 10h, 3fh, 10h, 8fh, 20h,0dfh
db   20h, 8fh, 10h, 3fh, 10h, 1fh, 57h, 1fh, 10h, 3fh
db   10h, 7fh, 40h,0bfh, 40h, 7fh, 20h, 2fh, 10h, 1fh
db   57h, 1fh, 10h, 2fh, 20h, 7fh, 40h,0bfh, 40h, 7fh
db   20h, 2fh, 10h, 1fh, 57h, 1fh, 10h, 2fh, 20h, 8fh
db   20h,0dfh, 20h, 7fh, 20h, 3fh, 10h, 1fh, 57h, 1fh
db   10h, 3fh, 20h,0efh, 10h, 1fh, 10h,0efh, 10h, 3fh
db   20h, 1fh, 57h, 1fh, 20h, 3fh, 10h,0efh, 30h,0efh
db   10h, 2fh, 20h, 1fh, 77h, 1fh, 20h, 2fh, 10h,0ffh
db  0ffh, 1fh, 40h, 1fh,097h, 1fh, 40h, 2fh, 34h,0ffh
db   5fh, 34h, 2fh, 20h, 3fh,0b7h, 3fh, 10h, 1fh, 54h
db   4fh, 20h, 7fh, 20h, 3fh, 54h, 1fh, 10h, 1fh,0f7h
db   27h, 1fh, 10h, 1fh, 34h, 6fh, 30h, 3fh, 30h, 5fh
db   34h, 1fh, 20h, 1fh,0f7h, 27h, 1fh, 10h,0cfh, 50h
db  0bfh, 10h, 1fh,0f7h, 37h, 1fh, 20h,0ffh,0bfh, 20h
db   1fh,0f7h, 10h, 37h, 1fh, 20h,0ffh,0afh, 10h, 1fh
db   47h, 10h,0b7h, 20h, 37h, 1fh, 20h,0ffh, 8fh, 20h
db   1fh, 37h, 20h,0c7h, 20h, 37h, 1fh, 20h,0ffh, 6fh
db   20h, 1fh, 37h, 20h,0e7h, 20h, 37h, 1fh, 30h,0ffh
db   2fh, 30h, 1fh, 37h, 20h,0f7h, 17h, 20h, 37h, 2fh
db   40h,0cfh, 30h, 2fh, 37h, 20h,0f7h, 37h, 20h, 47h
db   3fh, 40h, 5fh, 50h, 1fh, 57h, 20h,0f7h, 67h, 20h
db   57h, 3fh, 70h, 3fh, 57h, 20h,0f7h,0a7h,0a0h, 31h
db  0a0h,0f7h,0f7h, 57h, 1fh, 10h, 31h, 10h, 1fh,0f7h
db  0f7h,0d7h, 1fh, 50h, 1fh,0f7h,0f7h,0d7h, 1fh, 10h
db   3fh, 10h, 1fh,0f7h,0f7h,0d7h, 20h, 1fh, 10h, 1fh
db   20h,0f7h, 67h
player_3 \
db  0f7h,0f7h,0f7h,0f7h,0c7h,09fh,0f7h,0f7h,097h, 2fh
db  090h, 2fh,0f7h,0f7h, 67h, 1fh,0d0h, 1fh,0f7h,0f7h
db   47h, 1fh,0f0h, 1fh,0f7h,0f7h, 27h, 1fh,0f0h, 20h
db   1fh,0f7h,0f7h, 1fh,0f0h, 40h, 1fh,0f7h,0d7h, 1fh
db  0f0h, 60h, 1fh,0f7h,0b7h, 1fh,0f0h, 80h, 1fh,0f7h
db  097h, 1fh,0a0h, 6fh, 80h, 1fh,0f7h, 87h, 1fh,0a0h
db   8fh, 80h, 1fh,0f7h, 67h, 1fh,0a0h,0afh, 70h, 1fh
db  0f7h, 67h, 1fh,090h,0cfh, 70h, 1fh,0f7h, 47h, 1fh
db  090h,0efh, 60h, 1fh,0f7h, 47h, 1fh, 80h,0ffh, 1fh
db   60h, 1fh,0f7h, 27h, 1fh, 80h,0ffh, 3fh, 50h, 1fh
db  0f7h, 27h, 1fh, 70h,0ffh, 4fh, 60h, 1fh,0f7h, 17h
db   1fh, 60h,0ffh, 6fh, 50h, 1fh,0f7h, 1fh, 70h, 2fh
db   40h, 8fh, 40h, 3fh, 50h, 1fh,0f7h, 1fh, 60h, 2fh
db   20h, 2fh, 20h, 6fh, 20h, 2fh, 20h, 2fh, 60h, 1fh
db  0d7h, 1fh, 60h,0ffh,09fh, 50h, 1fh,0d7h, 1fh, 60h
db   2fh, 80h, 4fh, 80h, 2fh, 50h, 1fh,0d7h, 1fh, 80h
db   8fh, 40h, 8fh, 80h, 1fh,0b7h, 1fh, 60h, 2fh, 10h
db   3fh, 20h, 3fh, 10h, 2fh, 10h, 3fh, 20h, 3fh, 10h
db   2fh, 50h, 1fh,0b7h, 1fh, 60h, 2fh, 10h, 3fh, 20h
db   3fh, 10h, 2fh, 10h, 3fh, 20h, 3fh, 10h, 2fh, 50h
db   1fh,0b7h, 1fh, 60h, 2fh, 10h, 8fh, 10h, 2fh, 10h
db   8fh, 10h, 2fh, 60h, 1fh,0a7h, 1fh, 60h, 3fh, 80h
db   4fh, 80h, 3fh, 60h, 1fh,0a7h, 1fh, 60h,0ffh,0bfh
db   70h, 1fh,097h, 1fh, 60h,0ffh,0bfh, 70h, 1fh,097h
db   1fh, 60h,0bfh, 10h, 2fh, 10h,0bfh, 70h, 1fh,097h
db   1fh, 70h,0afh, 40h,0afh, 80h, 1fh,0a7h, 1fh, 60h
db  0ffh,09fh, 80h, 1fh,0a7h, 1fh, 60h,0ffh,09fh, 70h
db   1fh,0b7h, 1fh, 60h, 2fh, 24h,0ffh, 1fh, 24h, 2fh
db   70h, 1fh,0b7h, 1fh, 60h, 1fh, 44h, 2fh, 10h, 8fh
db   10h, 2fh, 44h, 1fh, 60h, 1fh,0a7h, 10h, 27h, 1fh
db   60h, 1fh, 24h, 4fh, 10h, 6fh, 10h, 4fh, 24h, 1fh
db   70h, 1fh,0a7h, 10h, 27h, 1fh, 70h, 7fh, 60h, 7fh
db   80h, 1fh, 17h, 10h, 87h, 10h, 27h, 1fh, 70h,0ffh
db   5fh, 70h, 1fh, 27h, 10h, 87h, 10h, 37h, 1fh, 70h
db  0ffh, 3fh, 70h, 1fh, 37h, 10h, 87h, 20h, 37h, 1fh
db   70h,0ffh, 1fh, 70h, 1fh, 37h, 20h,097h, 20h, 37h
db   1fh, 70h,0efh, 70h, 1fh, 37h, 20h,0b7h, 20h, 37h
db   2fh, 30h, 2fh, 30h, 8fh, 30h, 2fh, 30h, 2fh, 37h
db   20h,0d7h, 20h, 47h, 3fh, 27h, 3fh, 80h, 3fh, 27h
db   2fh, 57h, 20h,0f7h,0f0h, 42h,0f0h,0f7h,0e7h, 1fh
db   10h, 42h, 10h, 1fh,0f7h,0f7h,0c7h, 1fh, 10h, 42h
db   10h, 1fh,0f7h,0f7h,0c7h, 1fh, 10h, 42h, 10h, 1fh
db  0f7h,0f7h,0c7h, 1fh, 60h, 1fh,0f7h,0f7h,0c7h, 1fh
db   10h, 4fh, 10h, 1fh,0f7h,0f7h,0b7h, 30h, 1fh, 27h
db   1fh, 20h,0f7h, 57h
;-------success pictiure-----------
CoP \
db  0fbh,0fbh,0fbh,0fbh,0fbh,0fbh,0fbh,0fbh,0fbh, 5bh
db   2fh, 20h, 3fh, 1bh, 20h, 3fh, 30h, 2fh, 20h, 2fh
db   60h, 19h,0f0h,0d0h, 14h, 1ch, 1eh,0fbh,0fbh,0fbh
db  0fbh,0fbh,0fbh,0fbh,0fbh,0fbh, 5bh, 2fh, 20h, 3fh
db  090h, 2fh, 20h, 2fh, 30h, 2fh,0f0h,0e0h, 24h, 2eh
db  0fbh,0fbh,0fbh,0fbh,0fbh,0fbh, 2bh, 23h, 21h, 10h
db   11h, 23h,0fbh,0fbh,0abh, 2fh, 20h, 2fh,0a0h, 2fh
db   20h, 2fh, 30h, 1fh, 1bh,0f0h,0c0h, 14h, 1ch, 3fh
db   1eh,0fbh,0fbh,0fbh,0fbh,0fbh,09bh, 23h, 41h,0a0h
db   13h,0fbh,0fbh,09bh, 2fh, 20h, 2fh, 20h, 6fh, 20h
db   2fh, 20h, 2fh, 30h, 1fh,0f0h,0b0h, 24h, 5fh, 1eh
db  0bbh, 23h, 7bh, 43h,0fbh,0fbh,0fbh, 6bh, 13h, 5bh
db   13h,0f0h, 70h, 13h,0fbh,0fbh, 5bh, 2fh, 20h, 2fh
db   20h, 2fh, 3bh, 1fh, 30h, 1fh, 20h, 2fh, 30h, 2fh
db  0f0h, 80h, 14h, 1eh, 4fh, 2eh, 2ch,0bbh, 23h, 7bh
db   43h, 8bh, 13h,0abh, 13h,0abh, 13h,0fbh, 5bh, 13h
db   4bh,0f0h,0a0h, 11h,0fbh,0fbh, 5bh, 8fh, 11h, 4bh
db  0dfh,0f0h, 80h, 6fh, 1eh, 2ch, 14h, 3bh, 33h,0fbh
db   1bh, 23h,0fbh,0fbh,0fbh, 5bh, 13h, 2bh, 13h,0f0h
db  0e0h, 13h,0fbh,0fbh,0bbh, 13h, 6bh, 4fh, 3bh, 3fh
db  0f0h, 50h, 14h, 5fh, 2eh, 2ch, 34h, 1ch, 3bh, 33h
db  0fbh, 1bh, 13h,0fbh,0fbh,0fbh, 8bh, 13h,0f0h,0f0h
db   20h, 13h,0fbh,0fbh,0fbh, 3bh, 2fh, 1bh, 13h, 4bh
db  0f0h, 50h, 4fh, 3eh, 2ch, 24h, 10h, 14h, 1ch, 4bh
db   23h,0fbh,0fbh,0fbh,0fbh, 8bh, 13h,0f0h,0f0h, 50h
db   13h,0fbh,0fbh,0fbh, 2bh, 2fh, 5bh, 13h,0f0h, 40h
db   6fh, 2eh, 1ch, 24h, 20h, 14h, 1ch, 4bh, 33h,0fbh
db   4bh, 13h,0fbh,0fbh,0fbh, 2bh,0f0h,0f0h, 70h,0fbh
db  0fbh,0fbh, 2bh, 2fh, 5bh, 11h,0f0h, 30h, 8fh, 2eh
db   54h, 1eh, 5bh, 33h,0fbh, 2bh, 23h,0fbh,0fbh, 2bh
db   13h,0cbh, 13h,0f0h,0f0h,090h,0fbh, 6bh, 13h,0fbh
db  0fbh, 13h,0f0h, 30h,0ffh, 2fh,09bh, 23h, 5bh, 33h
db  0fbh,0fbh,0abh, 33h,0abh,0f0h,0f0h,0a0h,0fbh,0fbh
db  0fbh, 7bh,0f0h, 30h, 1eh,0ffh, 2fh,0fbh, 1bh, 33h
db  0fbh,0fbh,0abh, 13h,0abh, 11h,0f0h,0f0h,0b0h, 2bh
db   13h, 2bh, 13h,0fbh,0fbh,0fbh, 1bh,0f0h, 10h, 1ch
db   5fh, 2eh, 6ch, 1eh, 1ch, 2eh, 2ch,0fbh,0fbh,0fbh
db  0fbh, 4bh, 13h, 5bh,0f0h,0f0h,0d0h, 1bh, 13h, 1bh
db   23h,0fbh,0fbh,0fbh, 1bh,0f0h, 10h, 5fh, 3eh, 1ch
db   84h, 1ch, 24h,0bbh, 23h, 7bh, 33h,0fbh,0fbh,0abh
db   23h, 3bh, 13h,0f0h,0f0h,0f0h,0fbh,0fbh, 3bh, 13h
db  0fbh, 1bh,0e0h, 6fh, 2eh, 2fh, 1eh, 1ch,0a4h, 13h
db  0abh, 33h, 6bh, 33h,0fbh, 5bh, 13h,0abh, 13h, 8bh
db   23h, 3bh,0f0h,0f0h,0f0h, 10h,0dbh, 13h,0fbh,0fbh
db   6bh,0d0h, 14h, 6fh, 2eh, 3fh, 1eh, 1ch,094h, 2bh
db   43h, 5bh, 53h, 6bh, 53h,09bh, 23h, 7bh, 33h,0abh
db   13h, 7bh, 13h, 1bh,0f0h,0f0h,0f0h, 10h, 13h, 2bh
db   13h,0abh, 13h,0fbh,0fbh, 5bh,0c0h, 4fh, 6eh, 1ch
db   1eh, 4ch, 24h, 2eh, 34h, 10h, 3bh, 33h, 5bh, 53h
db   6bh, 53h,09bh, 23h, 8bh, 23h,0abh, 13h, 7bh, 13h
db   1bh,0f0h,0f0h,0f0h, 20h, 2bh, 13h,0fbh,0fbh,0cbh
db   13h, 2bh, 11h,0b0h, 14h, 4fh, 4eh, 8ch, 14h, 1ch
db   1eh, 1ch, 24h, 20h, 3bh, 33h, 6bh, 63h, 6bh, 33h
db  0fbh, 4bh, 23h,0fbh, 2bh, 23h, 11h,0f0h,0f0h,0f0h
db   20h,0fbh,0fbh,0fbh, 2bh,0c0h, 1ch, 5fh, 2eh, 6ch
db  0c4h, 4bh, 43h, 6bh, 63h,0fbh, 3bh, 13h, 8bh, 13h
db  0fbh, 4bh,0f0h,0f0h,0f0h, 30h, 7bh, 13h,09bh, 23h
db  09bh, 13h,0bbh, 13h, 6bh,0c0h, 4fh, 2eh, 8ch, 14h
db   3ch, 84h, 4bh, 43h, 7bh, 53h, 7bh, 13h,0abh, 23h
db   8bh, 13h,0fbh, 3bh,0f0h,0f0h,0f0h, 30h, 7bh, 13h
db  09bh, 23h,09bh, 13h,0bbh, 13h, 5bh, 13h,0b0h, 1eh
db   3fh, 3eh, 1ch, 34h, 4ch, 14h, 1ch, 2eh, 84h, 7bh
db   43h, 7bh, 43h, 6bh, 43h,09bh, 23h, 7bh, 43h,09bh
db   13h, 2bh, 13h,0d0h, 54h, 70h, 34h, 40h, 44h,0c0h
db  0cbh, 13h,0fbh,0bbh, 33h, 5bh,0a0h, 2fh, 4eh, 1ch
db  0b4h, 1fh, 1eh, 44h, 4ch, 7bh, 43h, 7bh, 43h, 7bh
db   33h,09bh, 23h, 7bh, 43h,09bh, 13h, 2bh, 11h,0c0h
db   74h, 60h, 44h, 20h, 64h,0b0h, 13h,0bbh, 13h,0fbh
db  0cbh, 23h, 4bh, 11h,0a0h, 6eh, 1ch,0a4h, 2eh,094h
db   23h, 6bh, 53h, 5bh, 63h, 6bh, 23h,0abh, 13h,09bh
db   23h,09bh, 13h, 2bh,0b0h,0a4h, 10h,0f4h, 14h,0b0h
db   11h, 13h,0fbh,0fbh, 8bh, 13h, 5bh,0a0h, 1ch, 3eh
db   1ch,094h, 30h, 1eh, 1ch,0a0h, 33h, 5bh, 63h, 5bh
db   53h, 7bh, 33h, 8bh, 33h, 8bh, 13h,09bh, 23h, 1bh
db  0b0h,0f4h,0d4h,0a0h, 11h,0fbh,0fbh,0ebh, 13h,0a0h
db   1fh, 1eh, 3ch, 64h, 60h, 2fh,0a0h, 43h, 5bh, 63h
db   5bh, 63h, 6bh, 33h, 8bh, 43h, 7bh, 23h, 7bh, 23h
db   1bh,090h, 54h, 6ch, 34h, 1ch, 14h,09ch, 64h,0a0h
db   1bh, 13h,0abh, 23h,09bh, 13h,0fbh, 5bh,0a0h, 1fh
db   2eh, 1ch, 64h,0f0h, 50h, 53h, 4bh, 73h, 4bh, 63h
db   6bh, 43h, 7bh, 53h, 6bh, 33h, 6bh, 23h, 1bh, 70h
db   54h,0fch, 3ch, 34h, 1ch, 64h,0a0h, 23h,0abh, 23h
db  09bh, 23h,0fbh, 4bh,0a0h, 1fh, 3ch, 64h,0f0h, 50h
db   73h, 4bh, 73h, 4bh, 53h, 7bh, 43h, 5bh, 63h, 6bh
db   43h, 5bh, 33h, 50h, 64h, 3ch, 34h, 4ch, 34h, 1ch
db  0f4h,090h, 1bh, 13h, 3bh, 23h,09bh, 23h, 5bh, 13h
db  0fbh, 4bh,090h, 14h, 2fh, 3ch, 64h, 80h, 1fh,0b0h
db   83h, 3bh, 73h, 4bh, 63h, 7bh, 33h, 6bh, 63h, 6bh
db   33h, 7bh, 13h, 11h, 40h,0f4h,094h, 20h,0a4h, 60h
db   14h, 2fh, 4bh, 23h,09bh, 23h,0fbh,0abh,090h, 2fh
db   1eh, 3ch, 64h,0f0h, 50h, 2bh, 73h, 3bh, 83h, 4bh
db   63h, 6bh, 33h, 7bh, 43h, 6bh, 33h, 7bh, 23h, 40h
db   74h, 30h,0f4h,0b4h, 50h, 24h, 10h, 1eh, 1fh, 4bh
db   13h,09bh, 23h,0fbh,09bh,090h, 2eh, 3ch, 74h,0f0h
db   60h, 2bh, 83h, 3bh, 83h, 3bh, 63h, 8bh, 23h, 6bh
db   53h, 5bh, 53h, 6bh, 13h, 40h, 64h, 40h,0f4h, 14h
db   1ch, 84h, 50h, 24h, 20h, 1ch, 1eh,0ebh, 33h, 7bh
db   43h,0cbh, 80h, 3fh, 2eh, 1ch, 74h,0f0h, 60h, 3bh
db   83h, 3bh, 83h, 4bh, 63h, 6bh, 23h, 8bh, 43h, 5bh
db   53h, 6bh, 40h,0f4h, 84h, 1ch, 1eh, 2fh, 1ch, 64h
db   10h,0a4h, 1fh,0ebh, 43h, 6bh, 43h, 4bh, 13h, 7bh
db   70h, 3fh, 2ch, 14h, 1ch, 64h,0f0h, 70h,0f3h, 1bh
db   83h, 3bh, 73h, 4bh, 63h, 4bh, 83h, 3bh, 53h, 1bh
db   13h, 2bh, 2fh, 20h,0c4h, 20h,0a4h, 1ch, 1eh, 4ch
db  0c4h, 1ch, 24h, 1fh, 6bh, 43h, 4bh, 23h, 4bh, 13h
db   4bh, 53h, 2bh, 13h, 7bh, 60h, 3fh, 2eh, 1ch, 84h
db  0f0h, 70h,0f3h,0a3h, 2bh, 83h, 3bh, 73h, 3bh, 83h
db   3bh, 63h, 2bh, 13h, 1bh, 20h, 14h, 20h, 44h, 3ch
db   34h, 30h, 34h, 10h, 14h, 80h, 54h, 1ch,0b4h, 1fh
db   7bh, 33h,0abh, 13h, 5bh, 73h, 3bh, 13h, 3bh, 50h
db   1ch, 2fh, 2eh, 2ch, 84h,0f0h, 70h,0f3h,0b3h, 1bh
db   83h, 4bh, 73h, 4bh, 73h, 3bh, 63h, 1bh, 23h, 20h
db   14h, 20h, 84h, 40h, 54h,0a0h, 34h, 3ch,0a4h, 8bh
db   33h,0abh, 13h, 7bh, 53h, 3bh, 13h, 3bh, 40h, 1ch
db   2fh, 3eh, 2ch, 84h,0f0h, 70h,0f3h, 13h, 2bh,0f3h
db   33h, 4bh, 73h, 3bh,093h, 2bh, 83h, 20h, 24h, 10h
db   44h, 80h, 24h, 2ch, 14h, 30h, 64h, 4ch, 2eh,0b4h
db   1bh, 23h, 6bh, 43h, 8bh, 33h, 6bh, 43h, 3bh, 23h
db   2bh, 30h, 14h, 2fh, 2eh, 3ch, 84h,0f0h, 80h,0f3h
db   13h, 2bh,0f3h, 33h, 5bh, 73h, 2bh,093h, 2bh, 33h
db   1bh, 33h, 1bh, 20h, 74h,090h, 14h, 2ch, 40h, 64h
db   4ch, 2eh,0a4h, 16h, 33h, 6bh, 53h, 7bh, 43h, 5bh
db   43h, 3bh, 23h, 1bh, 11h, 30h, 2fh, 2eh, 3ch,094h
db  0f0h, 80h,0f3h, 53h, 2bh,093h, 1bh, 83h, 3bh, 83h
db   3bh, 63h, 4bh, 63h, 20h,0e4h, 20h, 3fh, 34h, 10h
db   44h, 1ch, 24h, 1ch, 34h, 2ch, 84h, 4bh, 33h, 7bh
db   43h, 3bh, 63h, 5bh, 23h, 1bh, 23h, 1bh, 13h, 1bh
db   40h, 1fh, 1eh, 4ch,0a4h,0f0h,090h,0f3h,0f3h,0b3h
db   2bh,093h, 2bh, 83h, 2bh, 43h, 1bh, 23h, 20h, 14h
db   2ch, 74h, 10h, 14h,0ffh, 8fh, 74h, 1eh, 4bh, 33h
db   7bh, 43h, 4bh, 63h, 5bh, 53h, 2bh, 40h, 5ch,0b4h
db  0f0h,090h,0f3h,0f3h,0c3h, 2bh,0a3h, 1bh,0b3h, 4bh
db   23h, 10h, 14h, 4ch, 44h,0ffh,0bfh, 44h, 1ch, 14h
db   1ch, 1fh, 4bh, 33h, 7bh, 43h, 6bh, 63h, 4bh, 43h
db   1bh, 11h, 40h, 4ch,0c4h,0f0h,090h,0f3h,0f3h, 23h
db   2bh,093h, 2bh,093h, 2bh, 83h, 1bh, 13h, 4bh, 23h
db   10h, 54h, 1ch,0ffh,0efh, 44h, 2ch, 2eh, 4bh, 73h
db   3bh, 63h, 6bh, 53h, 4bh, 33h, 60h, 2ch,0d4h,0f0h
db  0a0h,0f3h,0f3h, 23h, 4bh, 73h, 2bh,093h, 2bh,093h
db   5bh, 13h, 1bh, 11h, 1fh, 2ch,0ffh,0ffh, 1fh, 1eh
db   44h, 2ch, 1eh, 12h, 23h, 2bh, 83h, 2bh, 63h, 6bh
db   53h, 7bh, 60h, 2ch,0d4h,0f0h,0a0h,0f3h,0f3h,0f3h
db  0b3h, 3bh, 73h, 4bh, 13h, 1bh, 11h,0ffh,0ffh, 5fh
db   44h, 1eh, 1fh, 1eh, 2bh, 13h, 5bh, 53h, 4bh, 73h
db   3bh, 63h, 6bh, 60h, 1ch,0d4h,0f0h,0b0h,0f3h,0f3h
db  0f3h,0c3h, 2bh, 73h, 5bh, 13h, 11h,0ffh,0ffh, 5fh
db   44h, 2eh, 1bh, 12h, 13h, 6bh, 53h, 4bh, 73h, 3bh
db   83h, 4bh, 60h,0d4h,0f0h,0c0h,0f3h,0f3h,0f3h,0f3h
db   73h, 4bh, 13h, 11h, 10h,0ffh,0cfh, 14h, 6fh, 54h
db   10h, 12h, 23h, 1bh, 23h, 4bh, 73h, 3bh, 83h, 2bh
db   73h, 3bh, 60h,0d4h,0f0h,0c0h,0f3h,0f3h,0f3h,0f3h
db   83h, 2bh, 13h, 1bh, 23h,0ffh,0ffh, 4fh, 24h, 50h
db   73h, 1bh,093h, 2bh, 83h, 4bh, 53h, 3bh, 60h,0d4h
db  0f0h,0c0h,0f3h,0f3h, 83h, 1bh,093h, 2bh,093h, 1bh
db  0b3h, 3bh,0ffh,0ffh, 4fh, 24h, 60h, 1bh, 63h, 1bh
db   83h, 2bh, 83h, 5bh, 43h, 3bh, 60h,0c4h,0f0h,0d0h
db  0f3h,0f3h, 83h, 2bh, 83h, 2bh,093h, 1bh,0a3h, 1bh
db   13h, 1bh, 13h,0ffh,0ffh, 4fh, 24h, 60h, 2bh, 53h
db   1bh, 83h, 2bh, 83h, 5bh, 43h, 3bh, 60h,0b4h,0f0h
db  0e0h,0f3h,0f3h,0c3h, 1bh,0f3h, 43h, 2bh, 73h, 3bh
db   13h,0afh, 1dh,0ffh, 7fh, 24h, 60h, 11h, 2bh, 43h
db   1bh, 33h, 1bh, 63h, 2bh, 83h, 3bh, 63h, 1bh, 60h
db  0b4h,0f0h,0e0h,0f3h,0f3h,0c3h, 1bh,0f3h, 53h, 1bh
db   83h, 3bh,0ffh,0ffh, 3fh,090h, 11h, 3bh, 23h, 4bh
db   73h, 2bh, 83h, 3bh, 63h, 1bh, 60h,0b4h,0f0h,0e0h
db  0f3h,0f3h,0f3h,0f3h,0e3h, 10h,0bfh, 20h, 1ch,0ffh
db   4fh,0c0h, 13h, 1bh, 13h, 5bh,0a3h, 1bh,093h, 2bh
db   43h, 1bh, 11h, 40h,0a4h,0f0h,0f0h,0f3h,0f3h,0f3h
db  0f3h,0c3h, 3bh, 7fh, 14h, 70h,0ffh, 3fh, 14h,0f0h
db   13h, 4bh,093h, 1bh,093h, 2bh, 43h, 2bh, 50h,094h
db  0f0h,0f0h,0f3h,0f3h,0f3h,0f3h, 43h, 5bh, 33h, 40h
db   4fh,0c0h,0ffh, 3fh,0f0h, 30h, 2bh, 73h, 2bh,093h
db   2bh, 13h, 1bh, 13h, 1bh, 23h, 60h, 64h,0f0h,0f0h
db   20h,0f3h,0f3h,0f3h, 23h, 1bh,0f3h, 33h, 4bh, 13h
db   50h, 3fh,0d0h,0ffh, 2fh, 1ch,0f0h, 40h, 13h, 1bh
db   53h, 1bh,0d3h, 5bh, 23h, 70h, 14h,0f0h,0f0h, 50h
db  0f3h,0f3h,0f3h,0f3h, 43h, 1bh, 23h, 1bh, 80h, 1fh
db  0f0h, 20h,0dfh, 14h, 60h, 3fh, 14h,0c0h, 13h, 3bh
db   43h, 1bh,0b3h, 6bh, 23h,0f0h,0f0h,0c0h,0f3h,0f3h
db  0f3h,0e3h, 1bh, 63h,0f0h,0d0h,0cfh, 80h, 2fh, 1ch
db   1eh,0f0h, 13h, 2bh, 63h, 1bh,0c3h, 1bh, 43h,0a0h
db   2bh,0f0h,0d0h,0f3h,0f3h,0f3h,0e3h, 1bh, 43h, 1bh
db   13h,0f0h,0d0h,0cfh, 80h, 1fh, 3ch, 14h,0f0h, 13h
db   3bh, 43h, 2bh,0b3h, 3bh, 23h, 1bh, 80h, 1bh, 13h
db   1bh,0f0h,0d0h,0f3h,0c3h, 2bh,093h, 1bh,093h, 2bh
db  093h, 3bh, 23h,0f0h,0f0h, 10h,0afh, 14h, 80h, 14h
db   1fh, 14h, 1eh, 1fh, 14h,0f0h, 30h, 1bh, 23h, 3bh
db  0f3h, 1bh, 13h, 1bh, 50h, 13h, 2bh, 23h,0f0h,0d0h
db  0f3h,0f3h, 13h, 1bh,0a3h, 1bh, 73h, 3bh, 43h, 11h
db   13h, 2bh,0f0h,0f0h, 40h,09fh, 1ch,0a0h, 3ch, 2fh
db  0f0h, 50h, 2bh, 33h, 2bh, 83h, 3bh, 53h, 3bh, 23h
db   3bh, 13h,0f0h,0d0h,0f3h,0f3h,0f3h,0c3h, 60h, 1dh
db   4fh, 80h, 11h,0f0h, 30h,09fh,0c0h, 2ch, 1eh, 1fh
db   1eh,0f0h, 60h, 21h, 33h, 1bh, 73h, 3bh, 63h, 2bh
db   23h, 4bh,0f0h,0d0h,0f3h,0f3h,0f3h, 73h, 4bh, 60h
db   6fh,0f0h,0c0h, 8fh, 14h,0c0h, 2ch, 2eh, 1fh,0f0h
db   70h, 11h, 2bh, 33h, 1bh,0e3h, 2bh, 23h, 4bh,0f0h
db  0d0h,0f3h,0f3h, 23h, 1bh,0f3h, 43h, 2bh, 40h, 1dh
db  0afh, 30h, 24h,0f0h, 50h, 4fh, 3eh, 1ch,0e0h, 3ch
db   1eh, 2fh, 50h, 24h,0d0h, 31h, 13h, 1bh, 23h, 1bh
db   83h, 2bh,0a3h, 2bh,0f0h,0d0h,0f3h,0f3h, 23h, 2bh
db  0f3h, 33h,0dfh, 1eh, 3fh, 1eh, 14h, 1ch, 2fh,0f0h
db   50h, 5fh, 1ch,0f0h, 20h, 3ch, 2fh, 40h, 4fh,0b0h
db   4fh, 1bh,0c3h, 3bh,093h, 2bh,0f0h,0d0h,0f3h,0f3h
db  0f3h, 43h, 1bh,0cfh, 4eh, 1ch, 1eh, 2fh, 1ch, 3fh
db  0f0h, 50h, 1ch, 2eh, 14h,0f0h, 40h, 14h, 1ch, 14h
db   1ch, 1eh, 1fh, 14h, 10h, 14h,09fh, 1ch, 40h, 6fh
db   1bh, 21h, 1bh, 33h, 2bh, 53h, 2bh, 83h, 1bh, 11h
db  0f0h,0d0h,0f3h,0f3h,0d3h, 10h, 43h, 1bh,0dfh, 6eh
db   2fh, 1ch, 2eh, 1ch,0f0h, 40h, 2ch, 14h,0f0h, 70h
db   3eh, 1ch, 1eh, 1fh, 10h, 14h,0afh, 40h, 7fh, 1bh
db   13h, 1bh, 33h, 2bh, 53h, 2bh, 83h, 1bh, 11h,0f0h
db  0d0h,0f3h,0f3h,0f3h, 23h, 1bh, 8fh, 2eh, 2fh, 4eh
db   1fh, 2eh, 14h, 1eh, 1ch, 24h, 2ch, 14h,0f0h,0f0h
db  0d0h, 1ch, 1eh, 24h, 2eh, 24h, 2eh, 1fh, 2eh, 1fh
db   1eh, 14h, 1eh, 1fh, 1eh, 20h,09fh,0f3h, 73h, 1bh
db  0f0h,0e0h,0f3h,0f3h,0f3h, 23h, 1bh, 8fh, 5eh, 1ch
db   5eh, 14h, 2ch, 24h, 2ch, 1fh, 14h,0f0h,0f0h,0c0h
db   14h, 1ch, 24h, 2ch, 1fh, 1ch, 1fh, 7eh, 14h, 1eh
db   1fh, 24h,09fh,0f3h, 23h, 2bh, 43h,0f0h,0e0h,0f3h
db  0f3h, 83h, 1bh,093h,09fh, 1eh, 1ch, 8eh, 3ch, 44h
db   1ch, 1fh,0f0h,0f0h,0b0h, 14h, 2fh, 1ch, 14h, 2ch
db   1fh, 2eh, 1fh, 4eh, 2fh, 14h, 1ch,0cfh, 1bh, 63h
db   2bh, 73h, 6bh,0f0h,0f0h,0f3h,0f3h, 83h, 2bh, 53h
db   11h, 23h, 4fh, 7eh, 14h, 4eh, 1ch, 2eh, 3ch, 34h
db   2ch, 14h,0f0h,0f0h,0b0h, 3fh, 1eh, 3ch, 2eh, 1ch
db   1fh, 6eh, 24h, 1eh,0bfh, 1bh, 63h, 2bh, 73h, 6bh
db  0f0h,0f0h,0f3h,0f3h,0f3h, 13h, 11h, 3fh, 1eh, 1ch
db   3eh, 1fh, 1eh, 1ch, 1eh, 1ch, 4eh, 14h, 1ch, 34h
db   2eh, 34h, 1eh, 14h, 70h, 1dh, 1fh,0f0h,0f0h, 10h
db   1ch, 4fh, 2ch, 14h, 2ch, 2eh, 1fh, 6eh, 1ch, 1eh
db  0cfh, 1bh,093h, 1bh,093h, 1bh,0f0h,0f0h,0f3h,0f3h
db  0d3h, 1bh, 33h, 3fh, 1eh, 1ch, 7eh, 2ch, 3eh, 14h
db   2ch, 64h, 2ch, 14h, 80h, 11h,0f0h,0f0h, 10h, 1ch
db   1fh, 1eh, 2fh, 1eh, 1ch, 14h, 1ch, 14h, 4fh, 7eh
db  0dfh,0f3h, 23h, 3bh,0f0h,0f0h,0f3h,0f3h,0d3h, 3bh
db   5fh, 24h, 10h, 24h, 1eh, 1ch, 2eh, 4ch, 14h, 1ch
db   24h, 10h, 34h, 1ch, 1eh, 1ch,0f0h,0f0h,0b0h, 1ch
db   1fh, 2eh, 1ch, 14h, 5ch,09eh,0efh, 1bh,0f3h, 13h
db   2bh, 11h,0f0h,0f0h,0f3h,0f3h,0d3h, 3bh, 4fh, 14h
db   50h, 4eh, 4ch, 74h, 2ch, 1eh, 1ch,0f0h, 40h, 24h
db  0f0h, 50h, 14h, 1fh, 2eh, 24h,09ch, 3eh, 2ch, 3fh
db   1eh,0afh, 1bh,0f3h, 13h, 1bh, 11h,0f0h,0f0h, 10h
db  0f3h,0f3h, 23h, 2bh,0a3h, 2bh, 3fh, 1ch, 40h, 1eh
db   14h, 10h, 14h, 2eh, 1ch, 14h, 6ch, 14h, 2ch, 1eh
db   14h, 1ch, 14h,0e0h, 14h, 40h, 34h,0f0h, 40h, 1ch
db   1fh, 4ch, 34h, 5ch, 24h, 1ch, 24h, 2ch, 4eh,0afh
db   1bh,0f3h, 1bh,0f0h,0f0h, 20h,0f3h,0f3h,0f3h, 3fh
db   60h, 14h, 1ch, 10h, 14h, 1fh, 1ch, 24h, 2ch, 24h
db   3ch, 3eh, 1ch, 1eh,0f0h, 50h, 24h,0f0h, 50h, 2fh
db   5ch,0d4h, 2ch, 2eh,0bfh, 1bh,093h, 2bh, 13h, 2bh
db   13h, 1bh,0f0h,0f0h, 20h,0f3h,0f3h,0d3h, 11h, 1bh
db   2fh, 70h, 24h, 10h, 14h, 1eh, 1ch, 14h, 2ch, 34h
db   2ch, 5eh, 1ch,0f0h, 50h, 24h,0f0h, 50h, 2fh, 5ch
db  0e4h, 1ch, 1eh, 1ch,0bfh, 1bh, 23h, 1bh,093h, 3bh
db   13h,0f0h,0f0h, 20h,0f3h,0f3h,0d3h, 1bh, 2fh, 80h
db   14h, 1ch, 64h, 2ch, 7eh, 1ch, 14h,0f0h,0f0h,0d0h
db   2fh, 1eh, 2ch, 14h, 1ch,0e4h, 3ch,0bfh, 1bh, 13h
db   2bh,093h, 3bh,0f0h,0f0h, 30h,0f3h, 13h, 2bh,0f3h
db  0b3h, 2fh, 60h, 24h, 2eh, 1ch, 64h, 1ch, 7eh, 14h
db  0f0h,0f0h,0e0h, 2fh, 1eh, 3ch,0f4h, 14h, 2ch,0bfh
db   1bh, 13h, 2bh,0c3h,0f0h,0f0h, 30h,0f3h, 13h, 3bh
db  0f3h,093h, 1bh, 20h, 2fh, 2ch, 24h, 4eh, 2ch, 24h
db   1ch, 1eh, 1ch, 6eh, 1ch, 14h,0f0h, 60h, 25h,0f0h
db   70h, 2fh, 2eh, 1ch,0f4h, 34h, 1eh,0bfh, 1bh, 13h
db   2bh,0b3h,0f0h,0f0h, 40h,0a3h, 1bh,0f3h,0e3h, 3bh
db   11h, 10h, 11h, 4fh, 1ch, 5eh, 4ch, 5eh, 1ch, 3eh
db   1ch,0f0h,090h, 1dh,0f0h, 60h, 2fh, 2ch, 44h, 1ch
db   54h, 6ch, 34h, 1eh,0cfh, 2bh, 33h, 3bh, 23h, 1bh
db   33h,0f0h,0f0h, 40h,0f3h,0f3h,0b3h, 1bh, 20h, 6fh
db   1ch, 1eh, 2ch, 5eh, 1ch, 6eh, 1ch, 1eh, 14h,0f0h
db  0a0h, 1fh, 15h,0f0h, 50h, 14h, 1fh, 2ch, 34h, 6ch
db   14h, 6ch, 34h,0dfh, 2bh, 43h, 2bh, 43h, 2bh,0f0h
db  0f0h, 40h,0f3h,0f3h,093h, 11h, 1bh, 11h, 10h, 11h
db   6fh, 1ch, 1eh, 2ch, 5eh, 1ch, 5eh, 1ch, 2eh,0f0h
db  0b0h, 1fh, 11h,0f0h, 60h, 1fh, 2ch, 34h,0ech, 24h
db  0dfh, 73h, 3bh, 23h, 1bh, 13h,0f0h,0f0h, 40h,0f3h
db  0f3h,0a3h, 11h, 10h, 11h, 7fh,0feh, 1eh, 14h,0f0h
db  0f0h,0f0h, 50h, 14h,0fch, 6ch,0dfh, 1bh, 83h, 1bh
db   13h, 1bh, 11h,0f0h,0f0h, 50h,0f3h, 73h, 1bh,093h
db   1bh, 63h, 1bh, 20h, 1bh, 7fh,0feh, 1ch,0f0h,0f0h
db  0f0h, 60h, 14h,0fch, 6ch,0dfh, 1bh, 83h, 1bh, 13h
db   1bh,0f0h,0f0h, 60h,0f3h,0f3h, 63h, 2bh, 13h, 11h
db   10h, 11h, 3fh, 1dh, 4fh,09eh, 1ch, 2eh, 1fh, 1ch
db  0f0h,0f0h,0f0h,090h, 1ch, 2fh, 1eh, 1ch, 6eh, 8ch
db   2eh,0efh, 2bh, 53h, 2bh, 13h, 1bh,0f0h,0f0h, 60h
db  0f3h,0f3h, 63h, 3bh, 20h, 11h, 8fh,0ceh, 1ch,0f0h
db  0f0h,0f0h,0b0h,0beh, 6ch, 3eh,0efh, 2bh, 53h, 4bh
db  0f0h,0f0h, 60h,0f3h,0f3h, 83h, 20h, 2bh, 8fh,09eh
db   1ch, 2eh,0f0h,0f0h,0f0h,0d0h, 1fh, 1ch, 8eh, 3ch
db   1eh, 2ch, 3eh,0efh, 2bh, 53h, 1bh, 13h, 2bh,0f0h
db  0f0h, 60h,0f3h,0f3h, 83h, 20h, 2bh, 7fh,0aeh, 1ch
db   1eh, 14h,0f0h,0f0h,0f0h,0d0h, 2fh, 8eh, 2ch, 2eh
db   2ch, 3eh,0ffh, 2bh, 63h, 1bh,0f0h,0f0h, 70h,0f3h
db  0f3h, 83h, 20h, 1bh, 7fh, 2ch,0aeh, 1ch,0f0h,0f0h
db  0f0h,0f0h, 14h,0ceh, 2ch, 4eh,0efh, 3bh, 33h, 1bh
db   13h, 11h,0f0h,0f0h, 70h,0f3h,0f3h, 83h, 10h, 11h
db   1bh, 7fh, 2ch,0aeh, 14h,0f0h,0f0h,0f0h,0f0h, 10h
db   2fh,0aeh, 1ch, 5eh,0efh, 13h, 3bh, 23h, 1bh, 13h
db  0f0h,0f0h, 80h, 1bh,0f3h,0f3h, 63h, 20h, 11h, 8fh
db   1ch,0aeh, 1ch,0f0h,0f0h,0f0h,0f0h, 40h,0feh, 1eh
db  0efh, 1bh, 13h, 6bh,0f0h,0f0h, 80h,0f3h,0f3h, 33h
db   1bh, 33h, 20h, 1bh, 8fh, 1ch,0beh,0f0h,0f0h,0f0h
db  0f0h, 40h, 14h,0feh,0efh, 23h, 6bh,0f0h,0f0h, 80h
db  0f3h,0f3h, 63h, 20h, 11h, 2bh, 6fh, 1ch,0beh, 1ch
db  0f0h,0f0h,0f0h,0f0h, 50h, 14h, 1fh,0eeh,0dfh, 43h
db   3bh, 11h,0f0h,0f0h, 80h, 53h, 1bh,0f3h, 13h, 1bh
db  093h, 1bh, 13h, 2bh, 20h, 1bh, 11h, 8fh,0beh, 14h
db  0f0h,0f0h,0f0h,0f0h, 60h, 2fh,0deh,0dfh, 1bh, 33h
db   3bh,0f0h,0f0h,090h, 43h, 2bh,0f3h, 13h, 1bh,093h
db   1bh, 13h, 2bh, 20h, 1fh, 11h, 7fh,0ceh, 14h,0f0h
db  0f0h,0f0h,0f0h, 60h, 2fh,0eeh,0dfh, 33h, 2bh, 13h
db  0f0h,0f0h,090h,0f3h, 1bh,093h, 2bh,093h, 20h, 23h
db   6fh,0ceh, 24h,0f0h,0f0h,0f0h,0f0h, 60h, 3fh,0deh
db  0dfh, 1bh, 23h, 1bh, 13h,0f0h,0f0h,0a0h,0f3h,0b3h
db   1bh,093h, 20h, 1bh, 13h, 6fh,0ceh, 24h,0f0h,0f0h
db  0f0h,0f0h, 60h, 1ch, 2fh,0deh,0efh, 13h, 2bh, 13h
db  0f0h,0f0h,0a0h,0f3h, 13h, 2bh,0f3h, 33h, 20h, 2bh
db   5fh, 2eh, 1ch,0aeh, 14h,0f0h,0f0h,0f0h,0f0h, 80h
db   2fh,0eeh,0dfh, 13h, 1bh, 13h, 11h,0f0h,0f0h,0a0h
db  0f3h, 13h, 3bh, 83h, 1bh, 83h, 20h, 13h, 1bh, 4fh
db   1ch,0deh, 14h,0f0h,0f0h,0f0h,0f0h, 80h, 1dh, 1fh
db  0eeh,0dfh, 1bh, 23h, 11h,0f0h,0f0h,0a0h,0f3h, 13h
db   4bh, 23h, 1bh, 43h, 2bh, 43h, 1bh, 13h, 11h, 10h
db   13h, 10h, 1bh, 4fh, 2ch,0ceh,0f0h,0f0h,0f0h,0f0h
db  0a0h, 2fh,0aeh, 2ch, 2eh,0cfh, 4bh, 23h,0f0h,0f0h
db   80h,0a3h, 4bh, 63h, 2bh,0c3h, 1bh, 20h, 1bh, 11h
db   5fh, 2ch,0ceh, 14h,0f0h,0f0h,0f0h,0f0h,090h, 1fh
db   1eh, 1fh,0deh,0dfh, 7bh,0f0h,0f0h, 60h,0b3h, 3bh
db   63h, 2bh,0c3h, 1bh, 20h, 2bh, 4fh, 1eh, 2ch,0ceh
db   14h,0f0h,0f0h,0f0h,0f0h,090h, 4fh,0deh,0cfh, 3bh
db   43h, 2bh,0f0h,0f0h, 40h,0b3h, 3bh, 63h, 2bh,0c3h
db   1bh, 20h, 1bh, 5fh, 1eh, 1ch,0deh,0f0h,0f0h,0f0h
db  0f0h,0a0h, 2fh, 1eh, 1fh,0eeh,0bfh, 5bh, 33h, 1bh
db  0f0h,0f0h, 40h,0c3h, 4bh, 63h, 5bh, 63h, 1bh, 13h
db   10h, 11h, 1bh, 4fh, 1eh, 1ch,0eeh,0f0h,0f0h,0f0h
db  0f0h,0a0h, 14h, 4fh,0deh,0cfh, 2bh, 13h, 4bh, 13h
db  0f0h,0f0h, 40h,0c3h, 6bh, 43h, 5bh, 63h, 1bh, 13h
db   10h, 11h, 5fh, 1eh, 1ch,0eeh,0f0h,0f0h,0f0h,0f0h
db  0b0h, 4fh,0deh,0cfh, 1bh, 23h, 5bh,0f0h,0f0h, 40h
db   63h, 1bh, 83h, 1bh,093h, 5bh, 23h, 3bh, 10h, 2bh
db   3fh, 2eh, 1ch,0deh, 1ch,0f0h,0f0h,0f0h,0f0h,0b0h
db   14h, 4fh,0deh,0bfh, 23h, 6bh,0f0h,0f0h, 40h, 63h
db   1bh, 83h, 1bh,093h, 5bh, 23h, 2bh, 13h, 10h, 2bh
db   2fh, 1ch, 2eh, 1ch,0deh, 1ch,0f0h,0f0h,0f0h,0f0h
db  0c0h, 4fh,0eeh,0afh, 23h, 6bh,0f0h,0f0h, 40h,0f3h
db   13h, 2bh,093h, 3bh, 33h, 1bh, 20h, 1bh, 3fh, 3ch
db  0eeh, 1ch,0f0h,0f0h,0f0h,0f0h,0c0h, 4fh,0feh,09fh
db   8bh,0f0h,0f0h, 40h,0f3h, 13h, 3bh, 83h, 5bh, 13h
db   1bh, 20h, 1bh, 3fh, 1eh, 2ch,0eeh, 1ch,0f0h,0f0h
db  0f0h,0f0h,0c0h, 4fh,0feh, 1eh, 8fh, 3bh, 13h, 4bh
db  0f0h,0f0h, 40h, 83h, 3bh, 53h, 6bh, 63h, 6bh, 20h
db   3fh, 1ch, 1eh, 2ch,0eeh, 1ch, 14h,0f0h,0f0h,0f0h
db  0f0h,0b0h, 2eh, 2fh,0feh, 1eh,09fh, 1bh, 23h, 4bh
db  0f0h,0f0h, 40h
Fish \
db   6bh, 4fh, 1bh, 2fh, 1bh, 2fh, 2bh, 89h, 3bh,0ffh
db  0ffh,0ffh, 1fh, 2bh,0ffh,0ffh,0ffh,0efh, 29h,0e1h
db   1bh,0ffh,0ffh, 4fh, 1bh, 2fh, 1bh, 2fh, 1bh, 7fh
db   2bh, 1fh, 1bh,0bfh, 3bh, 79h, 2bh,0ffh,0ffh,0ffh
db   1fh, 1bh, 29h,0ffh,0ffh,0ffh,0efh, 19h, 71h, 59h
db   31h, 19h,0ffh,0ffh,0ffh, 3fh, 1bh,0efh, 3bh, 39h
db   11h, 29h, 3bh,0ffh,0ffh,0ffh, 1fh, 1bh, 29h,0ffh
db  0ffh,0ffh,0efh, 2dh, 29h, 31h, 29h, 2dh, 39h, 21h
db   19h,0ffh,0ffh,0ffh, 3fh, 2bh, 4fh, 1bh, 8fh, 1bh
db   39h, 31h, 39h, 3bh,0ffh,0ffh,0ffh, 1bh, 19h, 1bh
db  0ffh,0ffh,0ffh,0ffh, 2fh, 7dh, 39h, 31h, 19h, 1bh
db  0ffh,0ffh,09fh, 1bh, 2fh, 1bh, 2fh, 1bh,0ffh, 1fh
db   39h, 41h, 29h, 3bh,0ffh,0ffh,0ffh, 1fh, 3bh,0ffh
db  0ffh,0ffh,0ffh, 2fh, 5dh, 19h, 11h, 29h, 41h, 19h
db   2bh,0ffh,0ffh, 5fh, 1bh, 2fh, 1bh, 2fh, 1bh, 2fh
db   7bh, 1fh, 4bh, 2fh, 2bh, 29h, 71h, 29h, 2bh,0ffh
db  0ffh,0ffh, 2fh, 1bh,0ffh,0ffh,0ffh,0ffh, 2fh, 4dh
db   19h, 31h, 19h, 51h, 19h, 2bh,0ffh, 8fh, 1bh, 2fh
db   1bh, 2fh,0bbh, 1fh, 1bh, 2fh, 1bh, 2fh, 1bh, 1fh
db   1bh, 8fh, 3bh, 71h, 39h, 2bh,0ffh,0ffh,0ffh, 2fh
db   2bh,0ffh,0ffh,0ffh,0ffh, 7dh, 49h, 51h, 2bh,0ffh
db   5fh, 1bh, 2fh, 1bh, 2fh, 2bh, 1fh, 1bh, 2fh, 1bh
db   5fh, 1bh, 2fh, 1bh, 2fh, 1bh, 1fh, 2bh, 4fh, 1bh
db   2fh, 4bh, 29h, 81h, 29h, 2bh,0dfh, 1bh, 1fh, 1bh
db   8fh, 2bh, 1fh, 2bh,0ffh, 2fh, 3bh,0ffh, 6fh, 1dh
db  0ffh,0cfh, 4dh, 6fh, 3dh, 4fh, 3dh, 29h, 41h, 19h
db   2bh,0ffh,0ffh, 5fh, 1bh, 2fh, 1bh, 2fh, 1bh, 2fh
db   4bh, 1fh, 2bh, 1fh, 6bh, 19h,0b1h, 29h, 6bh, 1fh
db   2bh, 1fh, 8bh, 1fh, 1bh, 1fh, 1bh, 2fh, 8bh,0ffh
db  0ffh,0ffh,0ffh,0ffh, 3fh, 3dh, 5fh, 1dh, 29h, 41h
db   19h, 2bh,0ffh,0ffh, 5fh, 1bh, 2fh, 1bh, 2fh, 1bh
db   2fh, 4bh, 1fh, 2bh, 1fh, 6bh, 19h,091h, 39h, 3bh
db   5fh, 1bh,0ffh, 2fh, 2bh, 1fh, 1bh,0ffh,0ffh,0ffh
db  0ffh,0ffh, 7fh, 2dh, 7fh, 1dh, 19h, 11h, 29h, 1bh
db  0ffh,0ffh,0ffh, 2fh,0abh, 29h,0c1h, 29h, 3bh,0ffh
db  0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0efh, 49h, 1bh,0ffh
db  0ffh,0ffh, 3fh, 2bh, 1fh, 1bh, 1fh, 5bh, 29h,0a1h
db   29h, 3bh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
db   49h, 1bh,0ffh,0ffh,0ffh, 8fh, 4bh, 29h,0a1h, 39h
db   2bh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh, 1fh
db   59h, 1bh,0ffh,0ffh,0ffh, 3fh, 1bh, 1fh, 3bh, 39h
db  0d1h, 29h, 2bh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
db  0ffh, 1fh, 59h, 1bh,0ffh,0ffh,0ffh, 2fh, 6bh, 19h
db  0e1h, 29h, 2bh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
db  0ffh, 2fh, 1dh, 49h, 1dh,0ffh,0ffh,0ffh, 2fh, 3bh
db   39h,0f1h, 29h, 2bh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
db  0ffh,0ffh, 2fh, 1dh, 39h, 1dh,0ffh,0ffh,0ffh, 3fh
db   3bh, 29h,0f1h, 11h, 29h, 2bh,0ffh,0ffh,0ffh,0ffh
db  0ffh,0ffh,0ffh,0ffh, 2fh, 5dh,0ffh,0ffh,0dfh, 1bh
db   2fh, 4bh, 29h,0f1h, 21h, 29h, 2bh,0ffh,0ffh,0ffh
db  0ffh,0ffh,0ffh,0ffh,0ffh, 2fh, 2dh, 1fh, 2dh,0ffh
db  0ffh,0afh, 1bh, 2fh, 2bh, 1fh, 2bh, 29h,0f1h, 51h
db   29h, 3bh,0ffh,0ffh,0ffh,0ffh,09fh, 50h,0ffh,0ffh
db  0ffh, 1fh, 1dh,0ffh,0ffh,0bfh, 1bh, 2fh, 2bh, 1fh
db   2bh, 1fh, 1bh, 19h,0f1h, 71h, 29h, 4bh,0ffh,0cfh
db   1bh, 1fh, 2bh,0ffh,0ffh, 3fh, 40h, 14h, 80h,0ffh
db  0ffh,0ffh,0ffh,0ffh,0ffh, 3fh, 1bh, 71h, 10h, 21h
db   10h, 21h, 10h, 21h, 10h, 61h, 39h, 3bh, 8fh, 1bh
db   2fh, 1bh,0dfh, 6bh,0ffh,0ffh, 1fh, 40h, 64h, 10h
db   14h, 60h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh, 1fh,0f1h
db   81h, 29h, 3bh,0ffh,0ffh,0ffh,0ffh, 1fh, 30h,0e4h
db   50h,0ffh,0ffh,0ffh,0ffh,0ffh,0efh,0f1h, 71h, 29h
db   3bh,0ffh,0ffh,0ffh,0ffh, 10h,0f4h, 44h, 50h,0ffh
db  0ffh,0ffh,0ffh,0ffh,0dfh,0f1h, 61h, 29h, 3bh,0ffh
db  0ffh,0ffh,0ffh, 20h, 54h, 1ch, 1eh, 14h, 4ch,094h
db   50h,0ffh,0ffh,0ffh,0ffh,0ffh,0bfh,0f1h, 51h, 39h
db   2bh,0ffh,0ffh,0ffh,0ffh, 10h, 44h, 1ch,0beh, 3ch
db   44h, 50h, 11h,0ffh,0ffh,0ffh,0ffh,0ffh,0afh,0f1h
db   51h, 39h, 2bh,0ffh,0ffh,0ffh,0efh, 20h, 34h, 1ch
db   5eh, 1ch, 4eh, 1ch, 1eh, 1ch, 74h, 50h, 11h,0ffh
db  0ffh,0ffh,0ffh,0ffh,09fh,0f1h, 51h, 29h, 3bh,0ffh
db  0ffh,0ffh,0cfh, 10h, 14h, 10h, 34h, 1ch, 1eh, 1ch
db   1eh, 64h, 1eh, 14h, 2eh, 84h, 60h, 11h,0ffh,0ffh
db   8fh, 1dh,0ffh,0ffh,0efh,0f1h, 51h, 29h, 2bh,0ffh
db  0ffh,0ffh,0cfh, 10h, 54h, 2ch, 1eh, 14h, 1ch, 64h
db   1eh, 14h, 1eh, 2ch, 54h, 10h, 14h, 80h,0ffh,0ffh
db   5fh, 2dh,0ffh,0ffh,0ffh,0f1h, 51h, 29h, 3bh,0ffh
db  0ffh,0ffh,0afh, 30h, 34h, 1eh, 24h, 4eh, 16h, 44h
db   1eh, 1ch, 4eh, 24h, 10h, 24h,090h,0ffh,0ffh, 4fh
db   4dh,0ffh,0ffh,0efh,0f1h, 41h, 39h, 2bh,0ffh,0ffh
db  0ffh,0bfh, 20h, 54h, 10h, 1ch, 14h, 30h, 44h, 1ch
db   4eh, 24h, 50h, 14h,090h,0ffh,0ffh, 4fh, 1dh,0ffh
db  0ffh,0afh, 1bh, 5fh, 41h, 10h, 21h, 10h, 11h, 20h
db  091h, 19h, 4bh,0ffh,0ffh,0ffh,09fh, 20h, 44h, 20h
db   24h, 10h, 44h, 20h, 34h, 1eh, 34h,0f0h, 10h,0ffh
db  0ffh,0ffh,0ffh,0ffh, 6fh, 11h, 20h, 11h, 20h, 11h
db   10h, 21h, 10h, 81h, 39h, 3bh,0ffh,0ffh,0ffh,09fh
db   20h, 34h, 10h, 44h, 1eh, 1ch, 2eh, 44h, 3eh, 20h
db   14h, 10h, 14h, 4eh, 14h,0a0h,0ffh,0ffh,0ffh,0ffh
db  0ffh, 5fh, 20h, 11h, 50h,0b1h, 29h, 5bh,0ffh,0ffh
db  0ffh, 8fh, 10h, 74h, 4eh, 64h, 4eh, 24h, 3eh, 14h
db   2eh, 1ch, 1eh, 14h, 80h,0ffh,0ffh,0ffh,0ffh,0ffh
db   5fh,0f1h, 31h, 39h, 4bh,0ffh,0ffh,0ffh, 8fh, 20h
db   24h, 1ch, 14h, 1eh, 1ch, 1eh, 1ch, 60h, 34h, 3eh
db   14h, 20h, 1eh, 24h,0e0h,0ffh,0ffh,0ffh,0ffh,0ffh
db   5fh,0f1h, 21h, 39h, 3bh,0ffh,0ffh,0ffh,0afh, 20h
db   34h, 2eh, 24h, 50h, 14h, 20h, 14h, 4eh, 14h, 20h
db   1eh, 20h, 1eh,0d0h,0ffh,0ffh,0ffh,0ffh,0ffh, 5fh
db  0f1h, 11h, 39h, 2bh,0ffh,0ffh,0ffh,0cfh, 20h, 34h
db   1ch, 1eh, 10h, 5eh, 24h, 1ch, 5eh, 24h, 20h, 3eh
db   14h, 1eh, 1ch, 34h, 80h, 1dh,0ffh,0efh, 2dh, 19h
db   1bh,0ffh,0ffh,0ffh, 1fh,0f1h, 39h, 2bh,0ffh,0ffh
db  0ffh,0dfh, 20h, 1ch, 14h, 3eh, 14h,0ceh, 34h, 20h
db   14h, 4eh, 44h, 60h, 11h, 10h, 1dh,0ffh,0bfh, 1dh
db   19h, 41h, 19h, 1bh,0ffh,0ffh,0ffh,0f1h, 11h, 29h
db   2bh,0ffh,0ffh,0ffh,0dfh, 20h, 1ch, 14h, 3eh, 14h
db  0beh, 14h, 1eh, 1ch, 14h, 30h, 14h, 1eh, 14h, 5eh
db   14h, 50h, 11h, 20h,0ffh,0afh, 1dh, 61h, 19h, 1bh
db  0ffh,0ffh,0ffh,0f1h, 11h, 19h, 3bh,0ffh,0ffh,0ffh
db  0dfh, 20h, 14h, 1ch, 1eh, 1ch,09eh, 14h, 3eh, 1ch
db   1eh, 1ch, 24h, 30h, 4eh, 1ch, 24h, 1ch, 14h, 40h
db   11h, 20h,0ffh,0afh, 19h, 21h, 20h, 21h, 19h, 1bh
db  0ffh,0ffh,0ffh,0f1h, 29h, 2bh,0ffh,0ffh,0ffh,0efh
db   20h, 1ch, 14h,0beh, 14h, 1eh, 1ch, 1eh, 1fh, 3eh
db   14h, 30h, 14h, 7eh, 24h, 30h, 11h, 20h,0ffh,0afh
db   19h, 11h, 30h, 21h, 19h, 1bh,0ffh,0ffh,0ffh,0f1h
db   29h, 3bh,0ffh,0ffh,0ffh,0dfh, 20h, 2ch,0aeh, 1ch
db   10h, 1eh, 54h, 60h, 6eh, 24h, 40h, 11h, 20h,0ffh
db  09fh, 19h, 21h, 30h, 21h, 19h, 2bh,0ffh,0ffh,0efh
db  0f1h, 29h, 3bh,0ffh,0ffh,0ffh,0dfh, 19h, 10h, 2ch
db  09eh, 14h, 10h, 24h,0c0h, 2eh, 44h, 50h, 11h, 10h
db   1dh,0ffh,09fh, 19h, 11h, 40h, 21h, 19h, 2bh,0ffh
db  0ffh,0efh,0f1h, 11h, 29h, 3bh,0ffh,0ffh,0ffh,0afh
db   14h, 1ch, 14h, 10h, 2ch,09eh, 14h, 2eh, 24h, 2ch
db   14h,090h, 1eh, 34h, 60h, 11h, 10h,0ffh,09fh, 1dh
db   19h, 11h, 50h, 21h, 19h, 3bh,0ffh,0ffh,0cfh,0f1h
db   29h, 3bh,0ffh,0ffh,0ffh,0bfh, 20h, 1eh, 14h, 2ch
db   4eh, 14h, 3eh, 1ch, 14h, 1eh, 1ch, 1eh, 2ch, 1eh
db   14h, 1eh, 34h, 60h, 24h, 70h, 11h, 30h,0ffh, 8fh
db   19h, 11h, 60h, 21h, 19h, 3bh,0ffh,0ffh,0bfh,0e1h
db   39h, 2bh,0ffh,0ffh,0ffh,0bfh, 1ch, 10h, 14h, 2eh
db   14h, 1ch,0beh, 1ch, 1eh, 84h,0b0h, 14h, 30h, 11h
db   40h,0ffh, 7fh, 1dh, 21h, 70h, 41h, 19h, 3bh,0ffh
db  0ffh, 7fh,0e1h, 39h, 4bh, 1fh, 2bh, 1fh, 1bh,0ffh
db  0ffh,0ffh, 4fh, 4eh, 14h, 1ch,0beh, 44h,0c0h, 14h
db  090h, 19h, 40h,0ffh, 7fh, 1dh, 19h, 11h, 80h, 41h
db   3bh,0ffh,0ffh, 7fh,0e1h, 29h, 3bh,0ffh,0ffh,0ffh
db  0bfh, 14h, 3eh, 10h, 2ch,0beh, 14h,0f0h, 40h, 24h
db   30h, 11h, 40h,0ffh, 7fh, 1dh, 19h, 31h, 80h, 31h
db   29h, 1bh,0ffh,0ffh, 6fh,0e1h, 19h, 2bh,0ffh,0ffh
db  0ffh,0dfh, 1eh, 14h, 1eh, 14h, 1eh, 2ch, 14h,09eh
db   14h,0f0h, 30h, 44h, 30h, 11h, 10h, 14h, 20h,0ffh
db   7fh, 2dh, 41h, 80h, 31h, 19h, 2bh,0ffh,0ffh, 5fh
db  0c1h, 39h, 2bh,0ffh,0ffh,0ffh,0dfh, 1ch, 14h, 3eh
db   34h,09eh, 14h,0f0h, 10h, 34h, 10h, 14h, 40h, 11h
db   20h, 14h, 10h,0ffh, 8fh, 2dh, 19h, 31h, 80h, 31h
db   19h, 2bh,0ffh,0ffh, 4fh,0b1h, 39h, 2bh,0ffh,0ffh
db  0ffh,0ffh, 34h, 1fh, 2ch, 14h,09eh, 24h,0a0h, 14h
db   50h, 14h, 70h, 11h, 40h,0ffh, 7fh, 3dh, 19h, 31h
db  0b0h, 21h, 19h, 1bh,0ffh,0ffh, 3fh,0c1h, 29h, 2bh
db  0ffh,0ffh,0ffh,0ffh, 2ch, 2eh, 14h, 1ch, 14h,09eh
db   14h,0f0h, 10h, 34h, 70h, 14h, 30h,0ffh, 6fh, 3dh
db   41h,0d0h, 11h, 19h, 2bh,0ffh,0ffh, 2fh,0c1h, 29h
db   2bh,0afh, 1ch, 24h, 1fh, 1eh, 1ch, 19h,0ffh,0ffh
db  0dfh, 1dh, 14h, 2eh, 24h, 1ch, 14h, 8eh, 14h, 1eh
db  0a0h, 14h, 40h, 34h,0b0h,0ffh, 4fh, 2dh, 29h, 41h
db  0f0h, 11h, 3bh,0ffh,0efh, 1bh, 1fh,0c1h, 29h, 2bh
db   6fh, 24h, 2ch, 34h, 10h, 1eh, 1ch, 14h,0ffh,0ffh
db  0efh, 10h, 3eh, 24h, 16h,0aeh, 24h, 60h, 34h, 50h
db   24h, 70h, 14h, 20h,0ffh, 4fh, 1dh, 29h, 51h,0f0h
db   10h, 21h, 19h, 1bh,0ffh,0bfh, 1bh, 4fh,0c1h, 29h
db   2bh, 2fh, 1dh, 14h, 1eh, 74h, 1eh, 40h, 11h,0ffh
db  0ffh,0ffh, 1fh, 54h, 8eh, 74h,0a0h, 24h, 80h,0ffh
db   5fh, 1dh, 29h, 31h, 29h, 21h,0f0h, 10h, 21h, 1bh
db  0ffh,0afh, 1bh, 2fh, 1bh, 2fh, 11h, 10h,0a1h, 29h
db   24h, 1eh, 1ch, 3eh, 2ch, 3eh, 2ch, 14h, 50h,0ffh
db  0ffh,0ffh, 1fh, 1bh, 34h, 16h, 7eh, 14h,0f0h, 10h
db   34h, 50h,0ffh, 8fh, 1dh, 51h, 39h, 21h,0f0h, 21h
db   2bh,0ffh,0ffh,0b1h, 29h, 14h, 1ch, 7eh, 14h, 3eh
db   1ch, 14h, 70h,0ffh,0ffh,0ffh, 1bh, 11h, 14h,09eh
db  0f0h, 30h, 24h, 50h,0ffh, 8fh, 1dh, 11h, 20h, 21h
db   49h, 11h,0f0h, 21h, 2bh,0ffh,0ffh, 11h, 10h,091h
db   29h, 24h, 8eh, 10h, 14h,0b0h,0ffh,0ffh,0ffh, 19h
db   24h, 1eh, 16h, 6eh, 30h, 1ch,0e0h, 14h, 60h,0ffh
db   8fh, 1dh, 11h, 20h, 21h, 59h, 11h,0e0h, 21h, 1bh
db  0ffh,0ffh, 1fh,0b1h, 29h, 34h, 1ch, 1eh, 14h, 1eh
db   34h, 30h, 14h, 80h, 11h,0ffh,0ffh,0ffh, 1bh, 10h
db   14h, 16h, 14h, 4eh, 14h, 1eh, 30h, 14h,0f0h, 60h
db  0ffh,09fh, 11h, 20h, 21h, 19h, 2bh, 2fh, 19h, 31h
db  0b0h, 21h, 2bh,0ffh,0ffh,0a1h, 29h, 1bh, 1fh, 24h
db   1ch, 4eh, 24h, 20h, 14h, 1eh, 14h, 50h, 14h, 10h
db  0ffh,0ffh,0ffh, 1fh, 1bh, 19h, 24h, 7eh, 14h, 20h
db   1ch,0f0h, 50h, 19h, 1bh,0ffh, 7fh, 1dh, 11h, 20h
db   21h, 19h, 1bh, 4fh, 19h, 31h,0a0h, 21h, 2bh,0ffh
db  0ffh,0a1h, 19h, 2bh, 1fh, 24h, 1ch, 4eh, 2ch, 20h
db   24h, 60h, 14h, 10h,0ffh,0ffh,0ffh, 1fh, 1bh, 19h
db   34h, 8eh,0f0h, 60h, 11h, 29h,0ffh, 7fh, 1dh, 11h
db   30h, 11h, 19h, 1bh, 4fh, 19h, 31h,0a0h, 11h, 1eh
db   1ch, 14h,0ffh,0ffh,091h, 29h, 2bh, 1fh, 24h, 1ch
db   4eh, 2ch, 14h,0b0h,0ffh,0ffh,0ffh, 1fh, 1bh, 19h
db   14h, 1eh, 24h,09eh,0f0h, 40h, 11h, 19h, 1bh,0ffh
db   7fh, 11h, 40h, 11h, 19h, 2bh, 3fh, 19h, 21h,0a0h
db   21h, 1eh, 24h, 10h,0ffh,0efh,0a1h, 19h, 2bh, 1fh
db   24h, 1ch, 4eh, 44h, 50h, 34h, 10h,0ffh,0ffh,0ffh
db   2fh, 1bh, 11h, 1ch, 2eh, 10h, 24h, 2eh, 24h, 16h
db   1eh, 60h, 14h,0d0h, 29h,0ffh, 7fh, 1dh, 11h, 30h
db   11h, 29h, 1bh, 4fh, 1bh, 19h, 21h,090h, 21h, 34h
db   20h, 2fh, 24h,0ffh,09fh,0a1h, 19h, 2bh, 2fh, 14h
db   4eh, 1ch, 64h, 40h, 14h, 20h,0ffh,0ffh,0ffh, 2fh
db   1bh, 19h, 14h, 3eh, 20h, 24h, 1eh, 14h,0f0h, 60h
db   29h,0ffh, 8fh, 1dh, 11h, 30h, 11h, 19h, 2bh, 4fh
db   1bh, 19h, 21h,090h, 11h, 1dh, 2ch,094h,0ffh, 7fh
db  091h, 29h, 1bh, 3fh, 14h, 1ch, 2eh, 84h, 40h, 24h
db   10h,0ffh,0ffh,0ffh, 3fh, 1bh, 14h, 4eh, 70h, 14h
db  0f0h, 30h, 11h, 19h,0ffh, 7fh, 1dh, 11h, 30h, 21h
db   19h, 2bh, 4fh, 1bh, 29h, 21h, 80h, 11h, 1dh, 24h
db   5eh, 34h, 30h,0ffh, 5fh, 81h, 39h, 1bh, 3fh, 14h
db   1eh, 1ch, 34h, 1ch, 54h, 40h, 14h, 10h,0ffh,0ffh
db  0ffh, 4fh, 1bh, 14h, 4eh, 14h,0f0h,0a0h, 29h,0ffh
db   7fh, 1dh, 11h, 30h, 11h, 19h, 2bh, 4fh, 2bh, 29h
db   41h, 70h, 19h, 14h, 3eh, 14h, 1eh, 84h, 1ch, 14h
db   10h, 14h,0ffh,091h, 29h, 2bh, 2fh, 44h, 10h, 24h
db   30h, 14h, 40h, 14h, 20h,0ffh,0ffh,0ffh, 4fh, 1bh
db   1ch, 4eh, 14h, 30h, 14h,0f0h, 70h, 11h,0ffh, 7fh
db   11h, 30h, 21h, 19h, 2bh, 4fh, 3bh, 39h, 61h, 20h
db   21h, 14h, 7eh, 1ch, 4eh, 14h, 10h, 24h, 10h, 14h
db   10h,0dfh, 11h, 10h, 71h, 29h, 2bh, 2fh, 10h, 64h
db   2eh, 1ch, 14h, 20h, 14h, 10h, 14h, 20h,0ffh,0ffh
db  0ffh, 6fh, 3eh, 30h, 14h, 1ch, 34h,0b0h, 14h,0a0h
db  0ffh, 5fh, 1dh, 11h, 20h, 21h, 19h, 2bh, 6fh, 3bh
db   49h, 71h, 19h, 14h, 1ch, 3eh, 1fh, 14h, 4eh, 34h
db   20h, 14h, 30h,0dfh, 20h, 71h, 29h, 2bh, 3fh, 14h
db   3eh, 1ch, 14h, 1ch, 24h, 20h, 14h, 40h, 1bh,0ffh
db  0ffh,0ffh, 3fh, 20h, 14h, 1eh, 30h, 14h, 2eh, 24h
db   1eh, 34h,0f0h, 70h,0ffh, 3fh, 1dh, 41h, 19h, 1bh
db  0afh, 5bh, 69h, 2bh, 14h, 1ch, 34h, 7eh, 14h, 70h
db  0dfh, 20h, 71h, 29h, 1bh, 4fh, 14h, 5eh, 14h,090h
db  0ffh,0ffh,0ffh, 4fh, 20h, 14h, 30h, 4eh, 64h,0b0h
db   14h,0c0h,0ffh, 1fh, 1dh, 21h, 29h, 1bh,0efh,09bh
db   1fh, 1dh, 1ch, 14h, 20h, 14h, 3eh, 24h,090h,0dfh
db   81h, 29h, 1bh, 5fh, 14h, 4eh,0a0h,0ffh,0ffh,0ffh
db   5fh, 40h, 14h, 6eh, 10h, 1eh, 14h,0f0h, 70h, 11h
db   1fh, 30h, 11h,0efh, 1dh, 39h, 2bh,0ffh, 2fh, 1bh
db   2fh, 2bh, 3fh, 1ch, 14h, 10h, 24h, 2eh, 44h, 80h
db  0dfh, 81h, 19h, 2bh, 4fh, 14h, 5eh,090h,0ffh,0ffh
db  0ffh, 5fh, 11h, 30h, 8eh, 14h, 2eh,0f0h, 60h, 21h
db   3fh, 30h,0cfh, 1dh, 39h, 2bh,0ffh,0bfh, 14h, 30h
db   4eh, 1ch, 24h, 70h,0efh, 71h, 19h, 3bh, 4fh, 5eh
db   1ch, 14h, 70h,0ffh,0ffh,0ffh, 5fh, 30h, 1dh, 1fh
db  0aeh, 14h,0f0h, 60h, 21h, 10h, 4fh, 30h,09fh, 1dh
db   49h, 2bh,0ffh,0bfh, 2eh, 14h, 5eh, 1ch, 14h, 70h
db  0ffh, 71h, 19h, 2bh, 5fh, 6eh, 14h, 60h, 11h,0ffh
db  0ffh,0ffh, 4fh, 30h, 2fh, 20h, 1fh, 7eh, 24h, 40h
db   64h,0d0h, 21h, 5fh, 30h, 8fh, 39h, 4bh,0ffh,09fh
db   1ch, 7eh, 1ch, 24h, 70h,0ffh, 61h, 29h, 2bh, 4fh
db   14h, 6eh, 14h, 60h,0ffh,0ffh,0ffh, 2fh, 1dh, 30h
db   2fh, 50h, 1dh, 7eh, 14h, 1ch, 14h, 20h, 24h, 1eh
db   44h,0c0h, 11h, 20h, 6fh, 30h, 1dh, 4fh,0abh,0ffh
db   7fh, 7eh, 2ch, 24h, 60h,0ffh, 1fh, 61h, 29h, 2bh
db   4fh, 14h, 6eh, 14h, 50h,0ffh,0ffh,0efh, 19h, 1dh
db   1fh, 30h, 11h, 1fh, 60h, 2fh, 10h, 1fh, 5eh, 44h
db   10h, 4eh, 34h, 20h, 1dh,0f0h, 5fh, 30h, 19h, 2fh
db   7bh, 39h, 3bh,0ffh, 4fh, 5eh, 1ch, 1eh, 24h, 80h
db  0ffh, 1fh, 51h, 39h, 2bh, 4fh, 14h, 6eh, 14h, 50h
db  0ffh,0ffh,0ffh, 1fh, 30h, 11h,090h, 1dh, 30h, 4eh
db   34h, 20h, 3eh, 54h,0e0h, 11h, 10h, 11h, 30h, 3fh
db   11h, 30h, 19h, 5bh, 29h, 31h, 39h, 2bh,0ffh, 1bh
db   1fh, 4eh, 2ch, 34h, 70h,0ffh, 2fh, 61h, 29h, 2bh
db   4fh, 14h, 6eh, 14h, 40h, 11h,0ffh,0ffh,0bfh, 1dh
db   11h, 1fh,0f0h, 1dh, 20h, 1fh, 10h, 15h, 2eh, 44h
db   10h, 5eh, 14h,0f0h, 20h, 21h, 60h, 2fh, 19h, 20h
db   11h, 19h, 2bh, 29h, 51h, 29h, 3bh,0afh, 1bh, 5fh
db   1ch, 1eh, 2ch, 14h, 10h, 24h, 80h, 5bh,0afh, 1bh
db   1fh, 71h, 19h, 3bh, 3fh, 14h, 6eh, 14h, 40h,0ffh
db  0ffh, 6fh, 11h,0a0h, 1fh,090h, 2fh, 1dh, 1fh, 15h
db   3fh, 11h, 10h, 1ch, 44h, 5eh, 14h,0f0h,0d0h, 19h
db   1fh, 19h, 20h, 11h, 39h, 61h, 19h, 2bh, 1fh, 1bh
db   6fh, 1bh, 5fh, 2bh, 1fh, 1eh, 1ch, 14h, 1eh, 24h
db   1ch, 24h, 70h, 4bh, 5fh, 1bh, 5fh, 1bh, 1fh, 61h
db   29h, 2bh, 4fh, 1ch, 6eh, 14h, 40h,0ffh,0dfh, 1bh
db  0f0h, 10h, 11h, 2fh, 20h, 11h, 2fh, 1dh, 7fh, 2dh
db   20h, 15h, 1dh, 20h, 24h, 1ch, 4eh, 14h,0f0h, 60h
db   11h,0a0h, 21h, 20h, 21h, 89h, 4bh, 8fh, 6bh, 64h
db   1eh, 34h, 50h, 1bh, 19h, 3bh, 2fh, 1bh, 2fh, 1bh
db   2fh, 2bh, 3fh, 51h, 39h, 1bh, 5fh, 14h, 6eh, 14h
db   40h,0ffh, 7fh,0f0h, 70h, 11h,0cfh, 1dh, 6fh, 1dh
db   50h, 24h, 3eh,0f0h,0f0h,0a0h, 11h, 79h, 5bh, 7fh
db   6bh, 24h, 10h, 14h, 10h, 14h, 3ch, 24h, 40h, 4bh
db   3fh, 1bh, 1fh, 2bh, 7fh, 51h, 29h, 2bh, 5fh, 14h
db   6eh, 14h, 40h,0bfh, 1bh, 8fh,0f0h, 80h, 1fh, 15h
db  0ffh, 2fh, 1dh, 3fh, 1dh, 11h, 30h, 1fh, 2eh,0e0h
db   11h, 3fh, 1dh,0f0h,0a0h, 29h, 2bh, 19h, 5bh,0afh
db   4bh, 14h, 20h, 14h, 1eh, 14h, 2eh, 1ch, 24h, 20h
db   8fh, 4bh, 7fh, 51h, 29h, 1bh, 5fh, 1dh, 7eh, 14h
db   40h,0bfh, 4bh, 2fh, 1bh, 1fh,0f0h, 80h, 21h,0ffh
db  0bfh, 11h,0c0h, 21h, 1fh, 1dh, 5fh, 11h, 19h, 20h
db   21h,0f0h, 70h, 19h,09bh,0dfh, 14h, 1ch, 5eh, 24h
db   1ch, 14h, 10h, 8fh, 8bh, 1fh, 1bh, 1fh, 41h, 39h
db   1bh, 5fh, 14h, 6eh, 1ch, 14h, 40h,0bfh, 5bh, 3fh
db  090h, 11h,0c0h, 11h, 2dh,0ffh, 5fh, 1dh, 3fh, 1dh
db   1fh, 1dh, 21h, 1fh, 14h, 60h, 2dh, 11h, 1dh, 7fh
db   11h, 1dh, 19h, 11h, 2dh, 21h,0f0h, 80h, 11h, 1bh
db   29h, 3bh,0dfh, 11h, 24h, 1ch, 4eh, 1ch, 24h, 10h
db   7fh,0cbh, 41h, 29h, 2bh, 5fh, 14h, 6eh, 1ch, 14h
db   40h, 6fh, 5bh, 59h, 1fh, 10h, 11h,0b0h, 31h, 80h
db   21h,0ffh, 2fh, 1dh,0afh, 1dh, 10h, 24h, 40h, 2fh
db   2dh, 1fh, 1dh, 6fh, 1dh, 11h, 1dh, 11h, 1dh, 29h
db   1fh, 1dh, 19h, 21h,0d0h, 15h, 80h, 5bh,0efh, 1ch
db   6eh, 1ch, 24h, 20h, 6fh,0cbh, 41h, 29h, 1bh, 6fh
db   14h, 6eh, 24h, 40h, 2fh, 8bh, 59h, 2fh,0e0h, 11h
db  090h, 11h,0ffh,0ffh, 10h, 11h, 20h, 2fh, 10h, 8fh
db   1dh, 1fh, 1dh, 1fh, 1dh, 2fh, 1dh, 1fh, 1dh, 8fh
db   2dh, 20h, 2dh, 2fh, 1dh, 10h, 15h, 20h, 11h, 1fh
db   60h, 11h, 4bh,0dfh, 14h, 4eh, 2ch, 34h, 10h, 19h
db   5fh,0dbh, 21h, 39h, 2bh, 6fh, 14h, 6eh, 24h, 40h
db   6bh, 19h, 4bh, 19h, 2bh, 1dh, 2fh,0f0h, 80h, 1dh
db  0ffh,0efh, 15h, 1dh, 30h, 3fh, 10h,09fh, 19h, 1fh
db   1dh, 3fh, 1dh,0ffh, 3fh, 50h, 2fh, 80h, 3bh,0dfh
db   1ch, 4eh, 24h, 1ch, 14h, 20h, 11h, 4fh, 3bh, 19h
db  0abh, 21h, 19h, 11h, 19h, 3bh, 5fh, 14h, 5eh, 34h
db   40h,0dbh, 1fh, 1dh, 1fh, 1dh,0f0h, 40h, 11h, 1dh
db  0ffh,0ffh, 2fh, 1dh, 11h, 10h, 11h, 4fh, 10h,0ffh
db  0ffh, 1fh, 2dh, 50h, 1fh, 1dh, 50h, 1fh, 40h, 11h
db   1bh,0dfh, 14h, 4eh, 14h, 1eh, 1ch, 24h, 10h, 11h
db   1fh, 4bh, 49h, 5bh, 19h, 3bh, 41h, 19h, 2bh, 6fh
db   6eh, 34h, 40h,0cbh, 4fh, 11h,0f0h, 20h, 1dh, 21h
db   1dh,0ffh,0ffh, 3fh, 11h, 10h, 11h, 4fh, 10h,0ffh
db  0ffh, 2fh, 40h, 1dh, 2fh, 50h, 1fh, 1dh, 60h, 11h
db  0cfh, 1dh, 1ch, 3eh, 1ch, 1eh, 24h, 20h, 11h, 4bh
db   69h, 1bh, 19h, 1bh, 29h, 3bh, 51h, 19h, 1bh, 5fh
db   24h, 4eh, 2ch, 24h, 40h,0bbh, 5fh,0f0h, 40h,0ffh
db  0ffh, 4fh, 5dh,0ffh,0ffh, 3fh, 1dh, 1fh, 1dh, 1fh
db   20h, 11h, 1fh, 15h, 1dh, 80h, 15h, 60h, 11h, 19h
db  0bfh, 6eh, 1ch, 14h, 30h, 3bh, 39h, 11h, 89h, 2bh
db   19h, 51h, 19h, 1bh, 5fh, 14h, 1ch, 5eh, 2ch, 14h
db   40h, 6bh, 49h, 5fh, 11h,0d0h, 51h, 15h,0ffh,0ffh
db   1dh, 3fh, 1dh, 1fh, 10h, 1fh, 11h,0bfh, 1dh,0ffh
db   3fh, 3dh, 1fh, 1dh, 1fh, 1dh, 11h, 10h, 1dh, 1fh
db   1dh,0f0h, 10h, 11h, 10h, 11h, 1bh,09fh, 7eh, 14h
db   30h, 2bh,0d9h, 1bh, 29h, 41h, 19h, 2bh, 5fh, 14h
db   7eh, 24h, 40h,09bh, 3fh, 2dh,0e0h, 4fh, 2dh,0ffh
db  0ffh, 6fh, 1dh, 2fh, 2dh,0ffh, 3fh, 1dh,0cfh, 2dh
db   1fh, 2dh, 11h, 2fh, 1dh, 1fh, 11h,0f0h, 10h, 1bh
db   20h, 11h, 8fh, 6eh, 24h, 30h, 3bh,0a9h, 5bh, 21h
db   29h, 3bh, 4fh, 1dh, 14h, 7eh, 1ch, 14h, 40h, 2bh
db   1fh, 6bh, 15h, 1fh,0f0h, 20h, 2fh, 2dh, 1fh, 11h
db  0ffh,0ffh, 6fh, 11h, 1dh, 1fh, 21h, 3fh, 1dh,0ffh
db  0cfh, 1dh, 2fh, 1dh, 11h, 5fh, 1dh,0f0h, 20h, 2fh
db   11h, 10h, 11h, 5fh, 1ch, 6eh, 24h, 30h, 2fh,0fbh
db   1bh, 21h, 29h, 1bh, 6fh, 24h, 6eh, 1ch, 1eh, 1ch
db   40h, 1bh, 8fh, 1dh,0e0h, 11h, 20h, 15h, 4fh, 1dh
db  0ffh,0ffh,09fh, 2dh, 11h,0ffh, 5fh, 1dh,09fh, 1dh
db   2fh, 1dh, 19h, 7fh,0f0h, 30h, 3fh, 11h, 10h, 19h
db   3fh, 7eh, 24h, 30h, 7fh, 8bh, 3fh, 21h, 19h, 2bh
db   6fh, 24h, 8eh, 14h, 40h, 8fh, 11h,0f0h, 21h, 20h
db   4fh, 1dh,0ffh,0ffh, 7fh, 1dh, 3fh, 11h, 2fh, 1dh
db  0ffh, 1dh,0cfh, 3dh, 1fh, 1dh, 6fh, 30h, 11h,0d0h
db   11h, 10h, 3fh, 1bh, 11h, 10h, 19h, 1fh, 14h, 6eh
db   34h, 20h, 8fh, 5bh, 5fh, 11h, 19h, 1bh, 8fh, 24h
db   5eh, 1ch, 2eh, 1ch, 14h, 30h, 19h, 5fh, 1dh,0f0h
db   10h, 11h, 10h, 11h, 20h, 3fh, 2dh, 1fh, 1dh,0ffh
db  0ffh, 5fh, 1dh, 3fh, 11h, 2fh, 1dh,0cfh, 1dh, 3fh
db   1dh,0cfh, 11h, 8fh, 1dh, 30h, 1fh, 1dh, 11h,0e0h
db   4fh, 1bh, 40h, 5eh, 34h, 20h, 8fh, 3bh, 7fh, 19h
db   1bh, 8fh, 10h, 24h, 5eh, 1ch, 2eh, 1ch, 14h, 40h
db   3fh, 1dh, 20h, 11h, 3fh,0d0h, 21h, 1dh, 10h, 4fh
db   1dh,0cfh, 1dh,0bfh, 1dh,0cfh, 10h, 1dh, 2fh, 11h
db   2fh, 1dh,0ffh, 1fh, 11h, 2fh, 1dh,09fh, 1dh, 1fh
db   1dh, 6fh, 11h, 30h, 1dh, 11h,0e0h, 21h, 5fh, 19h
db   30h, 14h, 3eh, 24h, 30h,0ffh, 3fh, 2bh, 8fh, 34h
db   8eh, 24h, 40h, 2fh, 1dh, 15h, 4fh,0e0h, 21h, 19h
db   1fh, 10h, 4fh, 1dh,0ffh,0ffh, 6fh, 1dh, 11h, 2dh
db   21h,0efh, 1dh, 4fh, 2dh,0bfh, 1dh, 4fh, 1dh, 3fh
db  0f0h, 70h, 11h, 5fh, 14h, 40h, 3eh, 14h, 30h,0ffh
db   2fh, 2bh,09fh, 34h, 8eh, 1ch, 14h, 40h, 1fh, 2dh
db   2fh, 15h, 1dh, 11h,0d0h, 11h, 20h, 2fh, 10h, 7fh
db   1dh, 2fh, 2dh,0ffh,0ffh, 10h, 2fh, 11h, 1dh,0dfh
db   1dh, 2fh, 1dh, 3fh, 1dh, 2fh, 2dh, 7fh, 1dh, 6fh
db   2dh,0f0h, 80h, 11h, 3fh, 1dh, 2eh, 14h, 30h, 14h
db   1eh, 14h, 40h, 7fh, 3bh, 5fh, 1bh, 19h,0afh, 34h
db   8eh, 1ch, 14h, 40h, 14h, 15h, 1dh, 15h, 2fh,0b0h
db   11h, 40h, 11h, 10h, 11h, 1dh, 10h, 1dh, 10h, 2fh
db   2dh, 1fh, 1dh,0ffh,0ffh, 1fh, 4dh,0ffh, 2fh, 1dh
db   6fh, 21h, 1dh, 7fh, 1dh, 1fh, 2dh, 11h, 1fh, 31h
db   10h, 11h,0b0h, 21h,0b0h, 19h, 2fh, 14h, 4eh, 30h
db   34h, 30h, 7fh, 3bh, 4fh, 1bh, 19h, 11h,0afh, 34h
db   4eh, 1ch, 3eh, 44h, 30h, 3fh,0d0h, 11h, 1dh, 5fh
db   10h, 1dh, 10h, 1fh, 10h, 4fh, 2dh,0ffh,0ffh, 1fh
db   1dh, 2fh, 1dh, 4fh, 10h,0cfh, 11h, 6fh, 2dh,09fh
db   4dh, 1fh, 1dh, 1fh, 11h,0b0h, 2dh, 1fh, 11h, 1dh
db   11h, 1dh,090h, 19h, 1fh, 14h, 5eh, 80h, 6fh, 4bh
db   2fh, 2bh, 19h, 21h,09fh, 19h, 34h, 8eh, 44h, 30h
db   2dh,0f0h, 10h, 1dh, 11h, 50h, 2fh, 10h, 5fh, 11h
db  0ffh,0ffh, 4fh, 15h, 1fh, 2dh, 2fh, 1dh,0bfh, 1dh
db   7fh, 1dh,0bfh, 1dh, 1fh, 1dh, 1fh, 11h,0b0h, 1dh
db   1fh, 10h, 15h, 2dh, 1fh, 11h, 15h, 11h, 80h, 1fh
db   14h, 6eh, 14h, 60h, 5fh, 8bh, 19h, 31h,09fh, 10h
db   34h,09eh, 44h,0d0h, 11h, 10h, 11h,0c0h, 1dh, 10h
db   15h, 4fh, 11h, 1dh,0efh, 1dh,0dfh, 2dh, 4fh, 1dh
db   2fh, 1dh, 2fh, 1dh,0ffh, 1fh, 1dh,09fh, 1dh, 2fh
db   3dh, 1fh, 11h, 30h, 11h, 80h, 2fh, 11h, 3dh, 1fh
db   10h, 1dh, 15h, 1fh, 80h, 24h, 6eh, 60h, 4fh, 8bh
db   19h, 41h,09fh, 44h, 1eh, 1ch, 6eh, 54h,0e0h, 11h
db  0d0h, 11h, 20h, 4fh, 2dh,0ffh,0cfh, 1dh, 1fh, 1dh
db   7fh, 11h,0dfh, 11h, 8fh, 11h, 1fh, 1dh, 6fh, 11h
db   1fh, 1dh, 11h, 10h, 11h,0c0h, 1fh, 1dh, 1fh, 3dh
db   3fh, 1dh, 15h, 80h, 24h, 2eh, 14h, 4eh, 60h, 2fh
db   4bh, 3fh, 2bh, 29h, 31h,09fh, 34h, 1ch, 8eh, 1ch
db   44h,0f0h, 11h, 10h, 11h, 40h, 11h, 40h, 1dh, 11h
db   20h, 4fh, 2dh,0ffh,0afh, 1dh, 11h, 1dh, 1fh, 11h
db  0ffh,0dfh, 1dh, 11h, 1fh, 1dh,0afh, 21h,0d0h, 2fh
db   1dh, 1fh, 1dh, 3fh,0a0h, 34h, 3ch, 4eh, 14h, 50h
db   2fh, 3bh, 5fh, 1bh, 49h, 11h,09fh, 10h, 34h, 8eh
db   1ch, 44h,0d0h, 11h,0d0h, 1dh, 30h, 1dh, 4fh, 19h
db   1dh,0ffh,09fh, 21h, 1fh, 11h,0bfh, 1dh, 2fh, 1dh
db  0ffh,0afh, 1dh, 2fh, 11h, 1dh,0c0h, 15h, 3fh, 1dh
db   1fh, 1dh, 2fh,0a0h, 14h, 1eh, 44h, 1eh, 1ch, 34h
db   50h, 3bh, 6fh, 1bh, 69h,09fh, 10h, 34h, 1ch, 6eh
db   1ch, 44h,0f0h, 30h, 11h,090h, 1fh, 30h, 1dh, 4fh
db   19h, 3dh,0ffh, 6fh, 1dh, 11h, 1dh, 5fh, 1dh, 2fh
db   2dh, 3fh, 1dh, 2fh, 3dh, 3fh, 1dh,0afh, 1dh, 6fh
db   1dh, 3fh, 11h, 20h, 11h,0b0h, 3fh, 1dh, 4fh, 11h
db  0a0h, 4eh, 74h, 50h,09fh, 1bh, 69h,09fh, 34h, 1ch
db   6eh, 1ch, 14h, 1ch, 24h, 10h, 24h,0f0h, 30h, 11h
db   70h, 1dh, 20h, 1dh, 10h, 5fh, 11h, 1fh, 1dh,0ffh
db   6fh, 11h, 1fh, 1dh, 8fh, 1dh, 11h, 3fh, 1dh, 2fh
db   1dh, 3fh, 11h, 2dh, 8fh, 3dh,0afh, 11h,0c0h, 21h
db   3fh, 1dh, 1fh, 1dh, 1fh, 1dh, 21h,090h, 6eh, 1ch
db   44h, 50h, 1bh, 7fh, 1bh, 79h,09fh, 44h, 6eh, 2ch
db   64h,0f0h, 60h, 11h, 40h, 11h, 10h, 11h, 10h, 15h
db   2fh, 1dh, 2fh, 2dh,09fh, 1dh,0cfh, 11h, 2dh, 5fh
db   1dh, 1fh, 10h, 8fh, 1dh,0ffh,0cfh,0c0h, 21h, 5fh
db   11h, 15h, 1dh, 20h, 11h, 60h, 1fh, 10h, 14h, 8eh
db   34h, 50h, 1bh, 7fh, 1bh, 79h,09fh, 44h, 1ch, 5eh
db   1ch, 84h,0f0h,0a0h, 1fh, 1dh, 11h, 20h, 1dh, 4fh
db   21h,0ffh, 5fh, 1dh, 11h, 2dh, 6fh, 1dh, 1fh, 1dh
db   4fh, 1dh, 2fh, 10h, 1dh, 5fh, 1dh,0ffh, 3fh, 2dh
db   11h,0c0h, 11h, 6fh, 1dh, 11h, 30h, 11h, 30h, 2dh
db   30h, 14h, 8eh, 24h, 60h, 1bh, 7fh, 1bh, 79h,09fh
db   10h, 34h, 2ch, 2eh,0b4h,0f0h,0a0h, 11h, 1dh, 20h
db   2dh, 4fh, 3dh, 11h, 2fh, 1dh,0ffh, 11h, 1dh,09fh
db   11h, 1dh, 7fh, 11h, 6fh, 11h,09fh, 1dh, 8fh, 19h
db   1dh, 11h,0c0h, 1dh, 7fh, 1dh, 30h, 21h, 1dh, 1fh
db   1dh, 11h, 30h,0aeh, 14h, 60h, 11h, 6fh, 2bh, 19h
db   51h, 19h
Veg \
db  0fdh, 3dh, 1fh,0cdh,0ffh,0dfh, 1dh, 3fh, 1dh, 1fh
db  0fdh,0fdh, 1dh, 25h, 1dh, 15h, 1dh, 45h, 21h,0f0h
db  0e0h, 14h, 15h, 3dh,0f0h,0f0h,0f0h,0e0h, 1dh, 2fh
db  0fdh, 1fh, 1dh, 4fh, 1dh, 1fh, 3dh,0ffh,0ffh,0ffh
db   4fh, 1dh,0ffh, 3fh, 1dh, 1fh,0adh, 25h, 21h,0b0h
db   11h, 45h, 11h, 50h, 15h, 1dh, 4fh, 1dh,0f0h,0f0h
db  0f0h,0d0h,0fdh,0fdh,0ffh,0ffh, 1fh, 1dh,0ffh,0ffh
db  0bfh, 8dh, 15h, 31h, 80h, 21h, 6dh, 35h, 2dh, 6fh
db  0f0h,0f0h,0f0h, 50h, 85h, 1fh,0fdh,0cdh, 4fh, 1dh
db   4fh, 3dh,0ffh,0ffh,0ffh,0ffh, 3fh,0adh, 15h, 11h
db  090h, 11h, 6dh, 35h, 2dh, 6fh,0f0h,0f0h,0f0h, 50h
db   5dh, 3fh, 3dh, 1fh,0fdh, 8dh,0ffh,0ffh, 3fh, 1dh
db  0ffh,0ffh,0bfh,0bdh, 15h, 11h,090h, 21h, 5dh, 35h
db   2dh, 5fh, 1dh,0f0h,0f0h,0f0h, 50h, 15h, 1dh, 6fh
db   2dh, 2fh,0fdh,0adh, 1fh, 1dh,0ffh,0efh, 1dh,0ffh
db  0ffh,0cfh, 1dh, 2fh, 7dh, 15h, 11h,0a0h, 21h, 4dh
db   15h, 21h, 2dh, 5fh, 11h,0f0h,0f0h,0f0h, 50h, 15h
db   1dh, 1fh, 1dh, 4fh,0fdh,0fdh, 2dh, 8fh, 1dh,0ffh
db  0ffh,0ffh,0ffh, 2fh, 3dh, 1fh, 2dh, 1fh, 4dh, 11h
db  0b0h, 11h, 15h, 3dh, 15h, 21h, 15h, 1dh, 5fh,0f0h
db  0f0h,0f0h, 60h, 11h, 1dh, 6fh,0fdh,0fdh, 5dh,0ffh
db  0ffh,0bfh, 1dh,0ffh, 4fh,0fdh, 4dh,0d0h, 21h, 15h
db   31h, 15h, 1dh, 4fh, 1dh,0f0h,0f0h,0f0h, 60h, 11h
db   7fh, 4dh, 1fh, 2dh, 1fh,0fdh,09dh,0ffh,0ffh,0efh
db   1dh, 3fh, 3dh,0cfh, 11h,0c0h, 2dh, 1fh, 4dh,0e0h
db   41h, 25h, 1dh, 4fh,0f0h,0f0h,0f0h, 80h, 2dh, 5fh
db  0fdh,0ddh, 2fh, 2dh,0ffh,0ffh,09fh, 1dh, 3fh, 1dh
db   1fh, 1dh, 3fh, 2dh, 11h, 20h, 6fh, 1dh, 11h,0f0h
db   10h, 1fh, 4dh,0f0h, 10h, 41h, 1dh, 3fh, 1dh,0f0h
db  0f0h,0f0h, 80h, 2dh, 5fh,0fdh,0ddh, 2fh, 2dh,0ffh
db  0ffh,0efh, 2dh,090h, 2dh, 2fh, 15h,0f0h, 40h, 1dh
db   21h,0f0h, 30h, 41h, 3fh, 11h,0f0h,0f0h,0f0h, 80h
db   2dh, 5fh,0fdh,0fdh, 2dh,0ffh,0ffh,0efh, 15h,0a0h
db   2dh, 11h,0f0h,0f0h,0e0h, 11h, 2dh, 1fh, 11h,0f0h
db  0f0h,0f0h,090h, 2dh, 5fh,0fdh,0fdh, 3dh, 2fh, 1dh
db  0ffh,0ffh,0afh, 11h,0a0h, 1dh,0f0h,0f0h,0f0h, 20h
db   11h, 1dh, 15h,0f0h,0f0h,0f0h,0a0h, 1dh, 6fh,0fdh
db  0fdh, 4dh, 1fh, 1dh,0ffh,0ffh,0afh, 1dh,0f0h,0f0h
db  0f0h,0e0h, 11h,0f0h,0f0h,0f0h,0b0h, 11h, 2dh, 4fh
db  0fdh,0fdh, 1dh,0ffh,0ffh,0dfh, 3dh,0f0h,0f0h,0f0h
db  0f0h,0f0h,0f0h,0f0h,0c0h, 1dh, 1fh, 1dh, 3fh,0fdh
db  0fdh, 2fh, 4dh,0ffh,0ffh, 8fh, 3dh,0f0h,0f0h,0f0h
db  0f0h,0f0h,0f0h,0f0h,0d0h, 2dh, 3fh, 1dh, 2fh,0fdh
db   2dh, 2fh, 5dh, 1fh, 1dh, 5fh, 2dh,0ffh,0ffh, 8fh
db   1dh, 1fh, 1dh,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
db  0e0h, 1dh, 3fh,0fdh, 7dh,0ffh,0ffh,0ffh, 7fh, 3dh
db  0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h, 1dh, 2fh
db  0fdh, 1dh, 1fh, 6dh,0ffh,0ffh,0ffh, 6fh, 3dh,0f0h
db  0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h, 1dh, 2fh, 4dh
db   1fh, 8dh, 1fh, 1dh, 2fh, 7dh, 6fh, 2dh,0ffh,0ffh
db  0cfh, 1dh, 1fh, 2dh,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
db  0f0h,0e0h, 11h, 1dh, 1fh, 8dh, 1fh,0ddh, 6fh, 4dh
db  0ffh,0ffh, 2fh, 1dh,0afh, 3dh,0f0h,0d0h, 54h,0f0h
db  0f0h,0f0h,0f0h,0f0h,0b0h, 11h, 2fh, 8dh, 1fh, 1dh
db   2fh,0adh, 6fh, 3dh,0ffh,0cfh, 3dh, 1fh, 3dh,0afh
db   3dh, 11h,0f0h,090h, 14h, 6fh, 1ch, 24h,0f0h,0f0h
db  0f0h,0f0h,0f0h,090h, 1dh, 2fh,0adh, 2fh, 4dh, 1fh
db   3dh, 2fh, 5dh,0ffh,0ffh, 1fh,09dh, 3fh, 1dh, 3fh
db   3dh, 11h,0f0h, 30h, 1eh,0ffh, 1ch, 24h,0f0h,0f0h
db  0f0h,0f0h,0f0h, 50h, 11h, 2dh, 2fh,0cdh, 1fh,0ddh
db  0ffh, 6fh, 1dh,0afh, 5dh, 11h, 15h, 2dh, 15h, 6fh
db   2dh,0f0h, 30h,0ffh, 3fh, 1ch, 24h,0f0h,0f0h,0f0h
db  0f0h,0d0h, 11h, 2dh, 15h, 21h, 15h, 4dh, 1fh,0fdh
db   6dh, 2fh, 3dh,0ffh,0ffh, 2fh, 5dh, 40h, 11h, 15h
db   5dh, 11h,0f0h, 30h, 14h,0ffh, 3fh, 1ch, 34h,0f0h
db  0f0h,0f0h,0f0h,0d0h,0fdh, 4dh, 1fh, 2dh, 1fh,09dh
db   3fh, 1dh,0ffh,0ffh, 3fh, 2dh, 15h,090h, 11h, 1dh
db   15h, 11h,0f0h, 30h, 1ch,0ffh, 4fh, 2ch, 24h,0f0h
db  0f0h,0f0h,0f0h, 40h, 11h, 10h, 15h, 60h, 11h,0fdh
db   3dh, 1fh, 3dh, 2fh, 5dh,0ffh,0ffh,09fh, 2dh, 50h
db   11h,0f0h,0a0h, 14h,0ffh, 5fh, 2ch, 44h,0f0h,0f0h
db  0f0h,0f0h, 10h, 25h, 11h, 15h, 70h,0ddh, 1fh,0fdh
db  09fh, 1dh,0ffh, 4fh, 1dh, 6fh, 2dh, 1fh, 1dh,0f0h
db  0f0h, 10h, 14h,0ffh, 6fh, 1eh, 1ch, 44h,0f0h,0f0h
db  0f0h,090h, 61h, 15h, 21h, 15h, 11h, 70h, 11h, 8dh
db   1fh,0cdh, 4fh, 3dh, 1fh, 3dh,0ffh,0ffh, 1dh, 1fh
db   4dh, 45h,0f0h,0c0h,0ffh, 7fh, 1eh, 3ch, 24h,0f0h
db  0f0h,0f0h, 80h, 51h, 55h, 21h, 15h, 70h,0fdh, 6dh
db  09fh, 1dh,0ffh,0ffh, 2dh, 1fh, 8dh, 15h, 1dh,0f0h
db  090h,0ffh,09fh, 3ch, 34h,0f0h,0f0h,0f0h, 70h, 51h
db   85h, 70h, 11h,0fdh,09dh, 1fh, 2dh, 3fh, 1dh,0ffh
db  0ffh, 4fh, 7dh,0f0h,0a0h,0ffh,09fh, 1ch, 1eh, 2ch
db   24h,0f0h,0f0h,0c0h, 61h, 40h, 51h, 65h, 1dh, 25h
db   70h,0adh, 1fh,0fdh, 4dh, 1fh, 2dh,0ffh,0ffh, 1dh
db   1fh, 1dh, 1fh, 2dh, 1fh, 1dh,0f0h,0b0h,0ffh,0bfh
db   1eh, 34h,0f0h,0f0h, 50h,0d1h, 50h, 51h, 35h, 2dh
db   35h, 80h,0fdh,0edh, 1fh, 2dh,0ffh,0ffh, 3fh, 2dh
db   1fh, 1dh,0f0h,0c0h,0ffh,0bfh, 1eh, 1ch, 34h,0f0h
db  0f0h, 20h, 31h, 65h,0f1h, 11h, 35h, 1dh, 55h, 70h
db   15h,0fdh,0cdh, 3fh, 1dh,0ffh,0ffh, 2fh, 4dh,0f0h
db  0d0h,0ffh, 7fh, 54h, 1ch, 44h,0f0h,0f0h, 20h, 21h
db   15h, 7dh, 55h,0a1h, 25h, 3dh, 45h, 70h,0fdh,0cdh
db   2fh, 2dh,0ffh,0ffh, 2fh, 2dh, 1fh,0f0h,0e0h,0ffh
db   4fh, 24h, 70h, 44h,0f0h,0f0h, 30h, 21h,09dh, 35h
db   2dh, 15h, 71h, 25h, 5dh, 25h, 11h, 70h,0fdh,09dh
db   1fh, 1dh,0ffh,0ffh, 6fh, 2dh, 11h,0f0h,0d0h, 1ch
db   8fh, 34h, 1ch, 2eh, 4fh, 2ch, 4fh, 1ch, 14h, 30h
db   44h,0f0h,0f0h, 30h, 11h, 15h,0ddh, 15h, 81h, 15h
db   6dh, 25h, 70h, 15h,0fdh, 7dh, 2fh, 4dh,0ffh,0ffh
db   2fh, 1dh, 1fh, 1dh, 11h, 25h,0f0h,0b0h,0afh, 1ch
db   24h, 1ch,0bfh, 1eh, 24h, 30h, 14h,0f0h,0a0h, 31h
db   80h, 11h, 15h,0cdh, 35h, 71h, 15h, 6dh, 25h, 70h
db  0fdh, 7dh, 2fh, 2dh,0ffh,0ffh, 4fh, 5dh,0f0h,0b0h
db   14h,0afh, 1eh, 24h, 1ch, 3fh, 1eh, 2ch, 2fh, 1ch
db   1fh, 1ch, 44h,0f0h,0a0h, 1dh, 11h, 1dh, 41h, 70h
db   21h, 15h,0adh, 45h, 81h, 15h, 7dh, 11h, 60h, 15h
db  0fdh, 5dh,0ffh,0ffh,0afh, 1dh, 1fh, 1dh, 21h,0f0h
db  0a0h,0afh, 1ch, 34h, 1ch, 3fh, 14h, 10h, 1ch,0a0h
db   44h,0f0h, 50h, 1dh, 2fh, 1dh, 15h, 31h, 80h, 11h
db  0bdh, 35h,091h, 15h, 7dh, 11h, 60h, 2dh, 1fh,0fdh
db   7dh, 1fh, 1dh,0ffh,0ffh, 2dh, 2fh, 5dh,0f0h,090h
db   2fh, 14h, 3fh, 1ch, 14h, 50h, 14h, 10h, 1eh, 2fh
db   14h, 10h, 14h,0a0h, 44h,0f0h, 20h, 2fh, 10h, 4fh
db   1dh, 41h, 70h, 21h,09dh, 65h, 71h, 25h, 6dh, 15h
db   11h, 50h, 11h,0fdh,09dh, 1fh, 2dh,0ffh,0ffh, 1dh
db   1fh, 6dh, 15h,0f0h, 70h, 6fh, 14h, 70h, 14h, 10h
db   14h, 2fh, 14h, 20h, 2fh, 84h, 1eh, 44h,0e0h, 1dh
db   8fh, 2dh, 41h, 70h, 21h,0bdh, 35h, 81h, 15h, 7dh
db   15h, 60h,0fdh,09dh, 1fh, 1dh,0ffh, 7fh, 1dh, 8fh
db   1dh, 2fh, 2dh, 1fh, 3dh,0f0h, 70h,0afh, 5ch, 4fh
db   1eh, 24h, 5fh, 2ch, 24h, 2ch, 44h, 80h, 2dh,0dfh
db   3dh, 41h, 70h, 21h,0adh, 55h, 61h, 25h, 6dh, 15h
db   11h, 50h, 11h,0fdh, 8dh, 1fh, 1dh, 8fh, 4dh, 4fh
db   1dh, 5fh, 1dh,0bfh, 6dh,0f0h, 70h,0ffh, 4fh, 2eh
db   1ch, 6fh, 2ch, 1eh, 2ch, 34h,090h,0ffh, 1fh, 3dh
db   41h, 70h, 21h,09dh, 65h, 61h, 25h, 6dh, 11h, 60h
db  0fdh, 6dh, 1fh, 4dh, 6fh, 1dh, 6fh, 2dh,0ffh, 5fh
db   4dh,0f0h, 70h,0ffh, 5fh, 1eh, 5fh, 1eh, 6ch, 34h
db  090h,0ffh, 1fh, 3dh, 15h, 41h, 70h, 21h, 15h,0adh
db   15h, 11h, 25h, 71h, 15h, 6dh, 60h, 11h,0fdh, 7dh
db   1fh, 2dh,0ffh,0efh, 1dh, 5fh, 4dh,0f0h, 70h, 14h
db  0ffh, 3fh, 1eh, 24h, 7fh, 1eh, 1ch, 44h,0a0h,0ffh
db   2fh, 4dh, 41h, 70h, 21h, 7dh,095h, 71h, 15h, 4dh
db   11h, 60h,0fdh,0adh,0ffh,0ffh, 5fh, 4dh, 15h,0f0h
db   70h,0ffh, 4fh, 34h, 7fh, 1ch, 44h,0a0h,0ffh, 3fh
db   4dh, 61h, 60h, 21h, 5dh, 25h, 1dh, 65h, 71h, 25h
db   1dh, 35h, 60h, 8dh, 1fh,0cdh, 1fh, 3dh,0ffh,0ffh
db   5fh, 6dh, 11h,0f0h, 50h,0ffh, 3fh, 1eh, 1ch, 1fh
db   24h, 5fh, 1eh, 1ch, 44h,090h, 1dh,0ffh, 4fh, 4dh
db   15h, 41h, 60h, 31h, 7dh, 25h, 1dh, 35h, 11h, 15h
db   71h, 35h, 11h, 60h,0ddh, 1fh,0bdh,0ffh,0ffh, 6fh
db   3dh, 1fh, 2dh, 25h, 1dh,0f0h, 10h, 14h,0cfh, 1eh
db   3fh, 1eh, 34h, 1eh, 24h, 1eh, 5fh, 1ch, 44h, 70h
db   2dh,0ffh, 5fh, 5dh, 41h, 70h, 21h, 15h,09dh, 55h
db  0c1h, 50h,0fdh, 6dh, 3fh, 1dh,0ffh,0ffh, 7fh, 1dh
db   1fh, 2dh, 1fh, 5dh, 40h, 11h,090h,0dfh, 1ch, 1fh
db   20h, 24h, 20h, 34h, 1ch, 4fh, 1eh, 1ch, 44h, 80h
db   1dh,0ffh, 6fh, 4dh, 15h, 41h, 70h, 21h, 6dh, 15h
db   5dh, 35h,0b1h, 50h,0fdh, 6dh,0ffh,0ffh,0ffh, 1fh
db   5dh, 1fh, 10h, 1dh, 15h, 1dh, 40h, 1dh, 2fh, 2dh
db  0efh, 1eh, 20h, 24h, 10h, 24h, 10h, 14h, 1ch, 1eh
db   3fh, 1ch, 54h, 80h, 1dh,0ffh, 7fh, 4dh, 15h, 41h
db   70h, 31h,0adh, 55h,0a1h, 40h,0fdh,0adh, 1fh, 1dh
db  0ffh,0ffh,0ffh, 3fh, 1dh, 1fh, 1dh, 10h, 1dh, 4fh
db   2dh, 1ch,0efh, 1ch, 5fh, 4ch, 4eh, 1ch, 54h,090h
db   1dh,0ffh, 7fh, 4dh, 15h, 41h, 70h, 21h,0adh, 65h
db   81h, 50h,0fdh,0adh,0ffh,0ffh,0ffh, 8fh, 2dh, 4fh
db   2dh, 10h,0ffh, 7fh, 1eh, 2ch, 2eh, 1ch, 54h,090h
db   15h, 1dh,0ffh, 7fh, 5dh, 15h, 41h, 70h, 21h,09dh
db   85h, 61h, 50h,0fdh, 7dh, 2fh, 1dh,0ffh,0ffh,0ffh
db  0efh, 11h, 30h,0ffh, 5fh, 1eh, 1ch, 14h, 4ch, 54h
db  090h, 15h,0ffh,09fh, 5dh, 15h, 41h, 70h, 21h,0adh
db   25h, 2dh, 25h, 61h, 50h,0fdh, 5dh,0ffh,0ffh,0ffh
db   5fh, 1dh,0cfh, 11h, 50h, 7fh, 1eh,0afh, 1eh, 1ch
db  0b4h,0a0h,0ffh,0afh, 5dh, 15h, 31h, 80h, 21h,0adh
db   15h, 3dh, 15h, 31h, 40h, 21h, 20h, 3dh, 1fh,0bdh
db   1fh, 4dh,0ffh,0ffh, 5fh, 5dh,0afh, 1dh,0bfh, 1dh
db   11h, 50h, 7fh, 1ch, 6fh, 1ch, 1fh, 14h, 20h, 14h
db   20h, 84h,0b0h,0ffh,0bfh, 5dh, 15h, 31h, 80h, 21h
db  0ddh, 15h, 31h, 30h, 31h, 20h,0fdh, 1dh,0ffh,0ffh
db  0ffh,0ffh, 6fh, 1dh, 70h, 5fh, 2eh, 1fh, 24h,0d0h
db   64h,0b0h,0ffh,0cfh, 5dh, 15h, 41h, 70h, 21h,0bdh
db   25h, 31h, 30h, 41h, 10h,0cdh, 1fh, 3dh,0ffh,0ffh
db  0ffh,0ffh, 5fh, 11h, 80h, 7fh, 1ch,0d0h, 14h, 10h
db   14h, 1ch, 34h,0c0h, 15h,0ffh,0cfh, 5dh, 15h, 41h
db   70h, 21h,0adh, 25h, 31h, 30h, 41h, 10h,0cdh, 2fh
db   2dh,0ffh,0ffh,09fh, 4dh,0ffh, 8fh, 1dh, 80h, 6fh
db   1ch, 14h, 1ch, 1dh, 1fh, 74h, 10h, 44h, 1ch, 24h
db  0d0h, 11h,0ffh,0efh, 4dh, 15h, 41h, 70h, 21h,09dh
db   25h, 41h, 20h, 51h,0adh, 1fh, 1dh, 4fh, 1dh,0ffh
db  0ffh,0ffh,0ffh, 5fh, 1dh, 80h, 3fh, 1eh, 2fh, 1ch
db   14h, 3fh, 1dh, 1fh, 1dh, 1ch,0b4h,0d0h, 11h,0ffh
db  0ffh, 4dh, 41h, 80h, 11h,09dh, 25h, 81h, 15h, 21h
db   1dh, 1fh, 1dh, 1fh, 3dh,0ffh,0ffh,0ffh,0ffh,0ffh
db   11h, 10h, 1dh, 70h, 2fh, 1eh, 2fh, 14h, 1eh, 3fh
db   1ch, 84h, 1ch, 44h,0e0h, 1dh,0ffh,0ffh, 5dh, 15h
db   41h, 70h, 11h, 15h, 7dh, 25h, 71h, 2dh, 21h, 1dh
db   2fh, 2dh, 4fh, 1dh,0ffh,0ffh,0ffh,0ffh,0cfh, 1dh
db   1fh, 1dh, 70h, 14h, 3fh, 1eh, 14h, 1eh, 3fh, 1ch
db   14h, 20h, 24h, 1ch, 1eh, 1fh, 1eh, 14h, 2ch, 14h
db  0e0h, 15h,0ffh,0ffh, 1fh, 5dh, 15h, 31h, 70h, 21h
db   7dh, 25h, 61h, 15h, 2dh, 15h, 11h,0fdh, 3dh, 1fh
db   3dh,0ffh,0efh, 1dh, 5fh, 1dh,0ffh,0bfh, 1dh, 11h
db   70h, 3fh, 1eh, 1ch,0efh, 2ch, 14h,0f0h,0ffh,0ffh
db   4fh, 4dh, 15h, 31h, 70h, 21h, 15h, 5dh, 55h, 11h
db   25h, 4dh, 11h,0b0h,0b4h, 35h, 1dh, 15h,0fdh,0fdh
db  0fdh, 1fh, 1dh,0afh, 2dh, 80h, 1fh, 2eh,0efh, 1eh
db   24h,0f0h, 11h,0ffh,0ffh, 5fh, 4dh, 41h, 70h, 21h
db   7dh, 15h, 1dh, 15h, 11h, 25h, 2dh, 15h, 21h,0f0h
db  0f0h,0f0h,0f0h, 60h,0c4h, 75h, 14h,090h, 24h, 1eh
db  0dfh, 24h,0f0h, 20h,0afh,0fdh, 2dh, 1fh,09dh, 35h
db   11h,0c0h, 31h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
db   60h, 14h, 1ch,09fh, 3ch, 14h,0f0h, 40h, 4dh, 1ch
db  0d4h, 10h, 24h, 10h,094h,0f0h,0f0h,0f0h,0f0h,0f0h
db  0f0h,0f0h,0f0h,0f0h, 1fh, 24h, 4fh, 4ch, 34h,0f0h
db   60h, 74h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
db  0f0h,0f0h, 80h, 14h, 1fh, 1eh, 84h,0f0h,0f0h,0f0h
db  0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0a0h
db   2fh, 1eh, 1ch, 54h,0b0h, 14h,0f0h,0f0h,0f0h,0f0h
db  0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0e0h, 3fh, 1eh
db   1ch, 54h,090h, 24h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
db  0f0h,0f0h,0f0h,0f0h,0f0h,0e0h, 5fh, 1eh, 24h,090h
db   44h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
db  0f0h,0f0h,0e0h, 6fh, 24h, 20h,0a4h,0f0h,0f0h,0f0h
db  0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h, 14h
db   5fh, 14h, 10h,0c4h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
db  0f0h,0f0h,0f0h,0f0h,0f0h,0c0h, 11h, 20h, 6fh,0d4h
db  0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
db  0f0h,0c0h, 21h, 20h, 6fh, 1ch, 34h, 1ch, 84h,0f0h
db  0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
db  0a0h, 31h, 30h, 6fh, 1eh, 24h, 3ch, 2eh, 1ch, 44h
db  0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
db  0f0h,090h, 41h, 20h, 14h, 7fh, 2ch, 3eh, 1fh, 1eh
db   1ch, 34h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
db  0f0h,0f0h,0f0h, 70h, 71h, 20h, 1eh,0dfh, 1eh, 1ch
db   24h, 1ch,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h
db  0f0h,0f0h,0f0h, 40h,091h, 30h, 5fh, 50h, 4fh, 1eh
db   3ch, 14h,0f0h, 70h, 31h, 40h, 11h,0f0h,0f0h,0f0h
db  0f0h,0f0h,0f0h,0f0h,0f0h,0f0h, 20h,0b1h, 30h, 4fh
db   70h, 14h, 2fh, 2eh, 2fh,0f0h,0f0h,0f0h,0f0h,0f0h
db  0f0h,0f0h,0f0h,0f0h,0f0h,0f0h, 10h,0d1h, 30h, 3fh
db  090h, 14h, 5fh,0f0h, 60h, 11h,0f0h,0f0h,0f0h,0f0h
db  0f0h,0f0h,0f0h,0f0h,0f0h, 70h,0e1h, 20h, 1fh, 10h
db   2fh, 1dh,0a0h, 5fh,0f0h, 50h, 21h, 20h, 11h,0f0h
db  0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h, 30h,0f1h
db   20h, 4fh,0b0h, 14h, 3fh,0a0h, 11h,0a0h, 11h, 80h
db   11h,0f0h,0f0h,0f0h,0b0h,0d4h, 60h, 14h,0f0h,0f0h
db  0f0h,0a0h,0f1h, 21h, 20h, 4fh,0c0h, 3fh,0b0h, 11h
db   60h, 81h, 40h, 11h,0f0h,0f0h,0f0h,0a0h,0fdh, 1dh
db  0c5h,0a4h, 30h,0e4h,0e0h, 34h, 10h, 11h, 10h,0f1h
db   21h, 30h, 3fh, 19h, 11h,0b0h, 2fh, 11h, 10h, 11h
db   70h, 31h, 60h, 81h,0f0h, 50h, 34h,0f0h,0f0h, 70h
db  0fdh,0fdh, 6dh, 45h, 1dh, 25h, 4dh, 35h, 5dh, 15h
db   21h,0b0h, 11h, 25h, 21h, 10h,0f1h, 21h, 20h, 19h
db   3fh, 21h,0b0h, 2fh, 10h, 11h, 30h, 11h, 40h, 31h
db   80h, 61h,0f0h, 60h, 35h,0e4h, 35h, 70h, 11h,0b0h
db  0fdh,0fdh,0fdh,0adh, 19h, 11h,0d0h, 2dh, 19h,0f1h
db   41h, 20h, 4fh, 11h,0b0h, 3fh, 50h, 11h, 10h, 21h
db   10h, 21h, 10h, 11h, 80h, 41h,0f0h, 70h,0fdh, 6dh
db   15h,091h, 10h, 11h, 10h, 21h, 40h, 11h, 15h, 31h
db   55h, 21h, 25h, 61h, 25h, 21h, 15h,0adh, 15h, 8dh
db   35h, 2dh, 25h, 1dh, 15h, 1dh, 11h,0e0h, 1dh, 19h
db  0f1h, 51h, 20h, 5fh,0b0h, 2fh, 50h, 31h, 10h, 51h
db   40h,091h, 30h, 21h,0f0h, 20h,0fdh, 1dh, 35h,0f1h
db   11h, 10h, 31h, 30h, 61h, 35h, 11h, 15h, 81h, 15h
db   61h, 45h, 71h, 55h, 11h, 35h, 31h, 15h, 29h, 11h
db  0e0h, 31h, 10h,0f1h, 21h, 30h, 5fh,0b0h, 2fh, 11h
db   20h, 11h, 10h, 21h, 20h, 61h, 60h, 51h, 30h, 31h
db  0f0h, 30h, 1dh, 25h, 61h, 15h,0f1h,0c1h, 70h,091h
db   15h, 1dh, 15h, 21h, 15h, 1dh, 15h, 1dh, 15h, 2dh
db   25h, 11h, 19h, 81h, 35h, 21h, 19h, 41h, 1dh, 51h
db  0f0h, 11h, 19h, 11h, 10h,0f1h, 21h, 20h, 19h, 5fh
db   30h, 19h, 60h, 2fh, 21h, 10h, 11h, 2fh, 20h, 2fh
db   10h, 41h, 60h, 51h, 40h, 11h,0f0h, 50h, 19h,0a1h
db   25h, 81h, 5dh, 7fh, 1dh,0f0h, 50h, 11h, 15h, 1dh
db   6fh, 15h, 11h, 10h, 81h, 10h,0f1h, 11h, 1dh,0f0h
db   41h, 10h,0f1h, 21h, 20h, 7fh, 10h, 2fh, 50h, 3fh
db   11h, 30h, 2fh, 20h, 2fh, 10h, 41h, 60h, 51h, 40h
db   11h,0f0h, 60h,0b1h, 3dh,0ffh, 4fh, 15h, 30h, 11h
db  0f0h, 14h, 15h, 8fh, 1dh, 70h, 11h,0f0h, 30h, 11h
db  0f0h, 41h, 10h,0f1h, 11h, 20h, 11h, 7fh, 80h, 2fh
db   30h,09fh, 10h, 21h, 20h, 21h, 30h, 51h, 30h, 11h
db  0f0h, 70h, 6dh, 11h, 1dh, 11h, 1dh,0ffh, 8fh, 1dh
db   30h, 2fh, 11h,0d0h, 14h, 1dh,09fh, 11h,0f0h,0f0h
db  0d0h, 21h, 10h,0f1h, 11h, 20h, 11h, 7fh, 70h, 3fh
db   11h, 20h,09fh, 10h, 11h, 20h, 31h, 20h, 61h, 30h
db   11h,0f0h, 70h,0ffh,0ffh, 4fh, 14h, 20h, 1fh, 21h
db  0e0h, 1dh,09fh, 11h,0f0h,0f0h,0d0h, 11h, 20h,0f1h
db   11h, 20h, 19h,0afh, 20h, 4fh, 31h, 30h, 2fh, 10h
db   2fh, 10h, 31h, 20h, 21h, 30h, 51h, 30h, 21h,0f0h
db   70h,0ffh,0ffh, 4fh, 1dh, 14h,0f0h, 50h, 15h, 1dh
db   4fh, 11h,0f0h,0c0h, 1fh,0f0h, 20h, 11h, 20h,0f1h
db   11h, 20h,0bfh, 10h, 5fh, 21h, 20h, 21h, 1fh, 11h
db   10h, 2fh, 10h, 21h, 20h, 11h, 50h, 51h,0f0h,0d0h
db  0ffh,0ffh, 4fh, 1ch, 14h,0f0h,0f0h,0f0h, 70h, 1fh
db  0f0h, 30h, 11h, 20h,0f1h, 11h, 20h,0afh, 10h, 1fh
db   10h, 4fh, 40h, 21h, 10h, 61h, 20h, 21h, 50h, 51h
db  0f0h,0d0h,0ffh,0ffh, 5fh, 1ch,0f0h,0f0h,0f0h,0f0h
db  0b0h, 11h, 20h,0f1h, 11h, 20h,09fh, 30h, 11h, 19h
db   1dh, 1fh, 19h, 11h, 40h, 11h, 10h, 61h, 20h, 21h
db   30h, 71h,0f0h,0d0h,0ffh,0ffh, 6fh,0f0h,0f0h,0f0h
db  0f0h,0b0h, 11h, 20h,0f1h, 11h, 10h, 11h,09fh, 30h
db   2fh, 20h, 11h, 19h, 2fh, 19h, 21h, 30h, 31h, 20h
db   31h, 30h, 61h,0f0h,0e0h, 11h,0ffh,0ffh, 5fh,0f0h
db  0f0h,0f0h, 30h, 2fh,0f0h, 60h, 11h, 20h,0f1h, 20h
db   11h,0afh, 10h, 4fh, 11h, 40h, 11h, 19h, 2fh, 1bh
db   21h, 40h, 21h, 50h, 51h,0f0h,0f0h,0ffh, 6fh, 1dh
db   3fh, 20h, 11h, 7fh,0f0h,0f0h,0f0h, 20h, 3fh,0f0h
db   60h, 21h, 10h,0f1h, 20h, 11h,0ffh, 31h, 60h, 21h
db   19h, 2fh, 19h, 21h, 40h, 71h,0f0h,0f0h,0ffh, 3fh
db   11h, 30h, 19h, 11h, 50h, 1dh, 1fh, 4dh,0f0h,0f0h
db  0d0h, 19h, 1fh, 11h,0f0h,0a0h, 11h, 20h,0f1h, 20h
db   11h,0ffh,0a1h, 50h, 21h, 1bh, 2fh, 19h, 61h,0d0h
db   11h,0f0h, 30h, 11h, 15h, 1dh, 11h,0f0h,0f0h,0f0h
db  0f0h,090h, 1fh, 19h, 11h,0f0h,0e0h, 11h, 20h,0f1h
db   20h, 11h,0efh,0c1h, 20h, 21h, 40h, 21h, 3fh, 1bh
db   19h, 11h,0b0h, 11h, 10h, 11h,0f0h,0f0h,0f0h,0f0h
db  0f0h,0b0h, 11h, 1fh, 1dh, 11h,0f0h,0f0h, 30h, 11h
db   20h,0f1h, 20h, 19h,0efh,0b1h, 20h, 41h, 70h, 21h
db   19h, 2fh, 11h,0b0h, 11h,0f0h,0f0h,0f0h, 70h, 3fh
db   15h,0f0h,0b0h, 2fh, 11h,0f0h,0f0h, 80h, 11h, 20h
db  0f1h, 20h, 19h,0dfh, 1bh,0b1h, 10h, 51h, 50h, 31h
db  0f0h,0f0h,0f0h,0f0h,090h, 6fh, 14h,0f0h, 30h, 11h
db   2fh,0f0h,0f0h,0d0h, 11h, 20h,0f1h, 20h, 19h,0dfh
db  0b1h, 20h, 41h, 50h, 41h, 60h, 11h,0f0h,0f0h,0f0h
db  0f0h, 20h, 7fh, 14h,0d0h, 11h, 1fh, 1bh,0f0h,0f0h
db  0f0h, 20h, 11h, 10h,0f1h, 11h, 20h, 19h,0dfh,0a1h
db   20h, 41h, 60h, 41h,0f0h,0f0h,0f0h,0f0h,090h, 7fh
db   1dh,090h, 1dh, 1fh, 11h,0f0h,0f0h,0b0h, 11h,090h
db   11h, 10h,0f1h, 11h, 20h, 19h,0cfh, 19h,0a1h, 10h
db   61h, 50h, 41h,0f0h,0f0h, 20h, 3fh, 60h, 1fh, 80h
db   4fh, 30h, 1fh,0b0h, 7fh, 1dh, 50h, 2dh,0f0h,0f0h
db  0f0h,0b0h,0f1h, 31h, 20h, 19h,0cfh,0a1h, 20h, 41h
db   50h, 61h,0f0h, 20h, 11h,0e0h, 4fh, 20h, 2fh, 10h
db   7fh, 20h, 5fh, 10h, 17h, 1fh, 20h, 2fh, 10h, 2fh
db   10h, 2fh, 10h, 7fh, 1dh, 1fh, 1dh, 11h,0f0h,0f0h
db  0f0h,0e0h, 21h, 10h,0f1h, 11h, 20h, 19h,0cfh,0a1h
db   10h, 51h, 50h, 61h,0f0h, 31h,0e0h, 1fh, 10h, 2fh
db   20h, 2fh, 10h, 2fh, 10h, 1fh, 10h, 2fh, 20h, 1fh
db   20h, 5fh, 10h, 3fh, 10h, 2fh, 10h, 2fh, 10h, 5fh
db   11h,0f0h,0f0h,0f0h,0f0h, 40h, 21h, 10h,0f1h, 11h
db   20h, 1bh,0cfh,091h, 10h, 61h, 50h, 51h, 20h, 11h
db  0d0h, 31h,0f0h,0f0h,0f0h, 60h, 11h,0f0h,090h, 2fh
db  0f0h,0f0h,0d0h, 21h, 10h,0f1h, 11h, 20h, 1bh,0bfh
db  091h, 20h, 61h, 50h, 51h,0f0h, 10h, 21h,0f0h,0f0h
db  0f0h, 70h


.code
.startup
    call PictiureList
code_head:    
    call Page1
    call Page2
    call Page3
code_end:    
    SetMode 03h
.exit

Page1 proc near
;=====page 1========
    SetMode 12h
    ;===introduce page 1===
    SetText 44,21,str_select_level
    SetText 44,22,str_select_player
    SetText 44,24,str_play
    SetText 44,25,str_esc
    ;=====load brick & player=======
    call LoadBrick
    call LoadPlayer
    ;====get keyboard and select====
    call ChooseLevel
ret
Page1 endp

Page2 proc near
;=====start page 2=======    
  go_load: 
    SetMode  12h
    mov count_d,0    
    ;====load level to level_now==== 
    _index si,maze_list,level_choose
    mov cx,ds
    mov es,cx
    mov cx,level_size
    lea di,level_now
    rep movsb          
    ;====load level_now to sceen====    
    mov di,-1
   bound_gogo:
     inc di       
     cmp level_now[di],'w'
     jne @f
     print_icon di,wall
    @@:
     cmp level_now[di],'g'
     jne @f
     print_icon di,ground
    @@:
     cmp level_now[di],'p'
     jne @f     
     print_icon di,P1
     mov people_coo,di
    @@:
     cmp level_now[di],'v'
     jne @f     
     print_icon di,P2
     mov vete_coo,di
    @@:    
     cmp level_now[di],'b'
     jne @f     
     print_icon di,box
    @@:     
     cmp level_now[di],'d'
     jne @f     
     inc count_d
     print_icon di,desti
    @@:    
     cmp level_now[di],'$'
     jne bound_gogo
    ;===introduce page 2===
    SetText 20,25,str_joy
    SetText 25,26,str_move 
    SetText 40,25,str_reset  
    SetText 40,26,str_gohome    
    SetText 40,27,str_esc     
  ;=====move loop=======
  start:
    ;======get keyboard=======
    GetChar bl   
        cmp level_choose,8
        jne skip_level_8
        ;=====level8 only========
            cmp bl,'w'
            jne @f   
            mov y_delta,-b_range
            jmp vete_cal
          @@:
            cmp bl,'s'
            jne @f 
            mov y_delta,b_range
            jmp vete_cal    
          @@: 
            cmp bl,'a'
            jne @f    
            mov y_delta,-1
            jmp vete_cal
          @@: 
            cmp bl,'d'
            jne @f     
            mov y_delta,1
            jmp vete_cal
          @@:
        ;====end level8 only======
        skip_level_8:
    cmp bl,_up
    jne @f   
    mov x_delta,-b_range
    jmp cal
  @@:
    cmp bl,_down
    jne @f 
    mov x_delta,b_range
    jmp cal    
  @@: 
    cmp bl,_left
    jne @f    
    mov x_delta,-1
    jmp cal
  @@: 
    cmp bl,_right
    jne @f     
    mov x_delta,1
    jmp cal
  @@:
    cmp bl,_backspace  
    jne @f         
        jmp go_load    
  @@: 
    cmp bl,_enter 
    jne @f
    jmp code_head
  @@:
    cmp bl,_esc  
    je  code_end    
    jmp start
    ;===calculate how to move======
  vete_cal: 
    mov who,1
    mov bx,vete_coo    ;bx=people
    mov di,bx
    add di,y_delta     ;di=people+delta
    mov si,di
    add si,y_delta     ;si=people+2delta  
    jmp cal_start 
  cal:  
    mov who,0
    mov bx,people_coo  ;bx=people
    mov di,bx
    add di,x_delta     ;di=people+delta
    mov si,di
    add si,x_delta     ;si=people+2delta  
   cal_start:
    ;=========p==========
    cmp level_now[bx],'v'
    je @f
    cmp level_now[bx],'p'
    je @f    
    jmp no_p  
    @@:
        ;------p->w----------
        cmp level_now[di],'w'
            je start
        ;------p->g----------
        cmp level_now[di],'g'   
        jne no_p_g           
            mov level_now[bx],'g'
            print_icon bx,ground
            .if who==0           
            mov level_now[di],'p'  
            .else
            mov level_now[di],'v'          
            .endif
            jmp mov_people
        no_p_g:
        ;------p->d----------
        cmp level_now[di],'d'
        jne no_p_d
            mov level_now[bx],'g'
            print_icon bx,ground        
            mov level_now[di],'n'
            print_icon di,P1
            jmp mov_people
        no_p_d:
        ;-------p->b---------- 
        cmp level_now[di],'b'
        jne no_p_b
            ;----p->b->g---------
            cmp level_now[si],'g'
            jne no_p_b_g   
                mov level_now[bx],'g'
                print_icon bx,ground
                .if who==0           
                mov level_now[di],'p'
                .else
                mov level_now[di],'v'         
                .endif 
                mov level_now[si],'b'                
                print_icon si,box
                jmp mov_people
            no_p_b_g:
            ;----p->b->g---------
            cmp level_now[si],'d'
            jne no_p_b_d   
                mov level_now[bx],'g'
                print_icon bx,ground
                .if who==0           
                mov level_now[di],'p'
                .else
                mov level_now[di],'v'          
                .endif  
                mov level_now[si],'u'                
                print_icon si,desti_ok
                dec count_d
                cmp count_d,0
                ; je complete               
                ; jmp mov_people
                ;;;
                jne mov_people
                ret
                ;;;
            no_p_b_d:
            ;----p->b->b/w/u(b+d)/p/d---------
            jmp start              
        no_p_b:       
        ;-------p->u(b+d)---------- 
        cmp level_now[di],'u'
        jne no_p_u
            ;----p->u->g---------
            cmp level_now[si],'g'
            jne no_p_u_g   
                mov level_now[bx],'g'
                print_icon bx,ground
                mov level_now[di],'n'
                print_icon di,P1 
                mov level_now[si],'b'                
                print_icon si,box
                inc count_d
                jmp mov_people
            no_p_u_g:
            ;----p->u->g---------
            cmp level_now[si],'d'
            jne no_p_u_d   
                mov level_now[bx],'g'
                print_icon bx,ground
                mov level_now[di],'n'
                print_icon di,P1 
                mov level_now[si],'u'                
                print_icon si,desti_ok
                jmp mov_people
            no_p_u_d:            
            ;----p->u->b/w/u(b+d)---------
            jmp start ;;;          
        no_p_u:
        ;----p/v->p/v
        jmp start ;;;  
    no_p:  
    ;========n(p+d)===========
    cmp level_now[bx],'n'
    jne no_n
        ;------n->w----------
        cmp level_now[di],'w'
            je start
        ;------n->g----------
        cmp level_now[di],'g'   
        jne no_n_g
            mov level_now[bx],'d'
            print_icon bx,desti
            .if who==0           
            mov level_now[di],'p'
            .else
            mov level_now[di],'v'        
            .endif
            jmp mov_people
        no_n_g:
        ;------n->d----------
        cmp level_now[di],'d'
        jne no_n_d
            mov level_now[bx],'d'
            print_icon bx,desti
            mov level_now[di],'n'
            print_icon di,P1
            jmp mov_people
        no_n_d:
        ;-------n->b---------- 
        cmp level_now[di],'b'
        jne no_n_b
            ;----n->b->g---------
            cmp level_now[si],'g'
            jne no_n_b_g   
                mov level_now[bx],'d'
                print_icon bx,desti
                .if who==0           
                mov level_now[di],'p'
                .else
                mov level_now[di],'v'         
                .endif 
                mov level_now[si],'b'                
                print_icon si,box
                jmp mov_people
            no_n_b_g:
            ;----n->b->d---------
            cmp level_now[si],'d'
            jne no_n_b_d   
                mov level_now[bx],'d'
                print_icon bx,desti
                .if who==0           
                mov level_now[di],'p'
                .else
                mov level_now[di],'v'            
                .endif 
                mov level_now[si],'u'                
                print_icon si,desti_ok
                dec count_d
                jmp mov_people
            no_n_b_d:            
            ;----n->b->b/w/u(b+d)---------
            jmp start           
        no_n_b:
        ;-------n->u(b+d)---------- 
        cmp level_now[di],'u'
        jne no_n_u
            ;----n->u->g---------
            cmp level_now[si],'g'
            jne no_n_u_g   
                mov level_now[bx],'d'
                print_icon bx,desti
                mov level_now[di],'n'
                print_icon di,P1 
                mov level_now[si],'b'                
                print_icon si,box
                inc count_d
                jmp mov_people
            no_n_u_g:
            ;----n->u->g---------
            cmp level_now[si],'d'
            jne no_n_u_d   
                mov level_now[bx],'d'
                print_icon bx,desti
                mov level_now[di],'n'
                print_icon di,P1 
                mov level_now[si],'u'                
                print_icon si,desti_ok
                jmp mov_people
            no_n_u_d:            
            ;----n->u->b/w/u(b+d)---------
            jmp start           
        no_n_u:      
    no_n: 
    mov_people:
        cmp who,1
        jne @f
        mov vete_coo,di
        print_icon di,P2
        jmp start
      @@:
        mov people_coo,di
        print_icon di,P1
        jmp start    
;=====end page 2========    
ret
Page2 endp

Page3 proc near
    SetMode 12h
    ;=====set success picture===========
    _index bp,success_picture_list,player_choose
    mov pic_amp,success_picture_amp
    mov pic_x_range,success_picture_x_range
    mov pic_y_range,success_picture_y_range
    mov pic_x_start,success_picture_x_start
    mov pic_y_start,success_picture_y_start     
    call PrintPicture   
    ;====set page3 introduction========
    SetText 30,24,str_success
    SetText 27,26,str_gohome
    SetText 27,27,str_esc   
    ;===keyboard event=============
Page3_keyboard_event:   
    GetChar al
    cmp al,_enter
    jnz @f
    jmp code_head
@@:
    cmp al,_esc
    jnz @f
    jmp code_end
@@:    
    jmp Page3_keyboard_event
ret
Page3 endp

PictiureList proc near
    ;;;---create brick list---  
    _lea brick_list,1,brick_1
    _lea brick_list,2,brick_2
    _lea brick_list,3,brick_3
    _lea brick_list,4,brick_4
    _lea brick_list,5,brick_5
    _lea brick_list,6,brick_6
    _lea brick_list,7,brick_7
    _lea brick_list,8,brick_8  
    ;;;---create player list---- 
    _lea player_list,1,player_1
    _lea player_list,2,player_2
    _lea player_list,3,player_3
    ;;;---create success picture list---
    _lea success_picture_list,1,CoP
    _lea success_picture_list,2,Fish
    _lea success_picture_list,3,Veg
    ;;;---create maze list------
    _lea maze_list,1,level_1
    _lea maze_list,2,level_2
    _lea maze_list,3,level_3
    _lea maze_list,4,level_4
    _lea maze_list,5,level_5
    _lea maze_list,6,level_6
    _lea maze_list,7,level_7
    _lea maze_list,8,level_8  
    ;;;----create block -------
    _lea wall    ,0,block_wall
    _lea ground  ,0,block_ground
    _lea box     ,0,block_box
    _lea desti   ,0,block_desti
    _lea desti_ok,0,block_desti_ok
ret
PictiureList endp

ChooseLevel proc near
chooselevel_step:
    GetChar al
    cmp al,_up
    jne @f
        mov al,-1
        call PlayerCal
@@:
    cmp al,_down
    jne @f
        mov al,1
        call PlayerCal
@@:
    cmp al,_left
    jne @f
        mov ax,-1
        call LevelCal
@@:
    cmp al,_right
    jne @f
        mov ax,1
        call LevelCal
@@:
    cmp al,_esc
    jne @f
        jmp code_end
@@:
    cmp al,_enter
    jne chooselevel_step
    ;----set P1,P2------
    cmp player_choose,1
    jnz @f
    _lea P1,0,player_1
    _lea P2,0,player_2
@@:
    cmp player_choose,2
    jnz @f
    _lea P1,0,player_2
    _lea P2,0,player_3
@@:
    cmp player_choose,3
    jnz @f
    _lea P1,0,player_3
    _lea P2,0,player_1
@@:
ret
ChooseLevel endp

LevelCal proc near
    ;------check-limit----------
    add ax,level_choose
    cmp ax,1
    jb chooselevel_step
    cmp ax,8
    ja chooselevel_step    
    ;;-------reset-last-brick---------
    push ax
    mov pic_transparent_color,7
    call PrintBrick
    ;;;------highlight-this-brick---------
    pop ax
    mov level_choose,ax
    mov pic_transparent_color,11
    call PrintBrick
ret
LevelCal endp

PlayerCal proc near
    ;------check-limit----------
    add ax,player_choose   
    cmp al,1
    jb chooselevel_step
    cmp al,3
    ja chooselevel_step
    ;-----print-new-pointer---------(al=13al+14) 
    mov player_choose,ax   
    and player_choose,03h
    call LoadPlayer
    jmp chooselevel_step    
ret
PlayerCal endp

LoadBrick proc near
    push level_choose
    _mov brick_list[0],level_choose
    mov level_choose,1
next_brick:  
    mov pic_transparent_color,7 
    mov ax,brick_list[0]
    cmp level_choose,ax
    jnz @f
    mov pic_transparent_color,11
@@:
    call PrintBrick
    inc level_choose
    cmp level_choose,9
    jnz next_brick
    pop level_choose
ret
LoadBrick endp

LoadPlayer proc near 
    _index bp,player_list,player_choose
    mov pic_amp,player_amp
    mov pic_x_range,player_x_range
    mov pic_y_range,player_y_range
    mov pic_x_start,player_x_start
    mov pic_y_start,player_y_start   
    mov pic_transparent_color,0 
    call PrintPicture    
ret
LoadPlayer endp

PrintBrick proc near 
    push level_choose
    _index bp,brick_list,level_choose
    mov pic_x_start,brick_x_start
    mov pic_amp,brick_amp
    mov pic_x_range,brick_x_range
    mov pic_y_range,brick_y_range
    mov pic_x_start,brick_x_start
    mov pic_y_start,brick_y_start   
    ;;;==============
    cmp level_choose,4
    jbe PrintBrick_add_x_start
        sub level_choose,4
        add pic_y_start,brick_y_space
PrintBrick_add_x_start:
    cmp level_choose,1
    jz PrintBrick_end_add_x_start
        add pic_x_start,brick_x_space
        dec level_choose    
    jmp PrintBrick_add_x_start
PrintBrick_end_add_x_start:    
    ;;====================           
    call PrintPicture ;main function
    ; mov level_choose,2
    pop level_choose
ret
PrintBrick endp

PrintPicture proc near     
    ;========calculate_x/y_end========
    _mov pic_x_end,pic_amp
    _mul pic_x_end,pic_x_range
    _add pic_x_end,pic_x_start
    _mov pic_y_end,pic_amp
    _mul pic_y_end,pic_y_range
    _add pic_y_end,pic_y_start      
    ;====end=setting========
    mov cx,pic_x_start
    mov dx,pic_y_start   
pic_next_byte:    
    mov al,[bp]
    mov pic_r_count,al
    shr pic_r_count,1 
    shr pic_r_count,1 
    shr pic_r_count,1 
    shr pic_r_count,1    
    and al,0fh
    cmp al,7
    jne pic_repeat
    mov al,pic_transparent_color
pic_repeat:   
    ;;;=====print====
    call WrPixelAmp
    add cx,pic_amp
    cmp cx,pic_x_end
    jnz pic_skip_change_line
    mov cx,pic_x_start
    add dx,pic_amp
pic_skip_change_line:    
    ;;;====end print=====
    dec pic_r_count
    cmp pic_r_count,0
    jnz pic_repeat
    inc bp
    cmp dx,pic_y_end
    jnz pic_next_byte
ret
PrintPicture endp

WrPixelAmp proc near
    push cx
    push dx
    mov pic_cx_tmp,cx
    mov pic_row_end,cx
    mov pic_col_end,dx
    _add pic_row_end,pic_amp
    _add pic_col_end,pic_amp
WrPixelAmp_repeat:
    WrPixel dx,cx,al
    inc cx
    cmp cx,pic_row_end
    jnz WrPixelAmp_repeat
    mov cx,pic_cx_tmp
    inc dx
    cmp dx,pic_col_end
    jnz WrPixelAmp_repeat
    pop dx
    pop cx
ret
WrPixelAmp endp

end