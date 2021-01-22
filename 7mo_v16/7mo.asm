include in_out.h
include print.h
include figure.h
.8086
.model small
.data
;-------extern---------------
extern dark_1 :byte
extern light_1 :byte
extern box :byte
extern wall:byte
extern people:byte
extern vegetable:byte
extern ground:byte
extern desti:byte
extern desti_ok:byte
extern huan:byte
;--------------------------
;Wall,Ground,People,Box,desti,null
extern level_1:byte
extern level_2:byte
extern level_3:byte
extern level_4:byte
extern level_5:byte
extern level_6:byte
extern level_7:byte
extern level_8:byte
extern level_9:byte
;-------debug use------------
m db 'm';;;;
print_x_coo equ 232
;----------------------------
x_sceen_size equ 640
y_sceen_size equ 480
_esc   equ 27
_f5    equ '?'
_backspace equ 8
_enter equ 13
_up    equ 'H'
_down  equ 'P'
_left  equ 'K'
_right equ 'M'
;--------level-------------------          
level_size equ 70
level_now db level_size dup(?)
level_choose dw 1;,'$'
level_table db 0,8,10,12,14,24,26,28,30 
;--------introduce--------------
;===page_1=====
str_select  db " to select level",'$'
str_play    db "press enter to play",'$'
;===page_2====
str_move    db " to move",'$'
str_reset   db "press backspace to reset",'$'
str_gohome  db "press enter to go home page",'$'
;===page_3=====
str_success db "!!!!!success!!!!!",'$'
;===page_all====
str_joy     db 0,18h,10,8,8,8,1bh,0,0,0,1ah,10,8,8,8,19h,'$'
str_esc     db "press esc to end",'$'
;----numwall parameter-----
b_range equ 8
;-------move parameter------
people_coo dw ?
vete_coo   dw ?
who db ?
x_delta dw ?
y_delta dw ?
count_d db ?
;------print square-------
block_range equ 50
x_tmp dw ?
x_end dw ?
y_end dw ?
tmp_col dw ?
tmp_row dw ?
amp equ 6
x_range equ 100
y_range equ 55
;-------------------------------
.code
.startup
;--initial-mouse/picture-------
  go_home:
    call page_1
    call page_2
  complete:
    call page_3 
  done:
    setmode text_mode
.exit

 page_1 proc near
 ;=====page 1========
    ;===introduce page 1===
    setmode     print_mode 
    setcolor    black
    set_cur 27,18
    print str_joy
    set_cur 33,19
    print str_select
    set_cur 27,22
    print str_play
    set_cur 27,23
    print str_esc  
     mov level_choose,1         
    ;=====load num wall=========
    print_numwall level_table[1],light_1,1
    mov di,2
   re_add:
    print_numwall level_table[di],dark_1,di
    inc di
    cmp di,9
    jne re_add 
    ;====get keyboard and select====    
  getchar_page1:
    get_char bl
    cmp bl,_up
    jne @f   
    mov ax,-4
    jmp level_limit
  @@:
    cmp bl,_down
    jne @f 
    mov ax,4
    jmp level_limit    
  @@: 
    cmp bl,_left
    jne @f    
    mov ax,-1
    jmp level_limit
  @@: 
    cmp bl,_right
    jne @f     
    mov ax,1
    jmp level_limit
  @@: 
    cmp bl,_enter
    jne @f
        call choose_level 
        jmp go_load
  @@:     
    cmp bl,_esc  
    je  done 
    jmp getchar_page1
    ;===limit 1 to 8=====      
  level_limit:  
    add ax,level_choose
    cmp ax,1
    jb getchar_page1
    cmp ax,9
    jae getchar_page1
    mov di,level_choose    
    print_numwall level_table[di],dark_1,di    
    mov level_choose,ax
    mov di,ax
    print_numwall level_table[di],light_1,di
    ;====print number==== 
    jmp getchar_page1    
 ;=======end page 1=======
 ret
 page_1 endp
 
 page_2 proc near
;=====start page 2=======    
  go_load: 
    ;====load level to level_now====
    setmode     print_mode 
    setcolor    black 
    mov count_d,0
    mov cx,ds
    mov es,cx
    mov cx,level_size
    lea di,level_now
    rep movsb
    ;====load level_now to sceen====    
    mov di,-1
   bound_gogo:
     add di,1       
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
     print_icon di,people
     mov people_coo,di
    @@:
     cmp level_now[di],'v'
     jne @f     
     print_icon di,vegetable
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
    set_cur 20,25
    print str_joy
    set_cur 25,26
    print str_move
    set_cur 40,25
    print str_reset 
    set_cur 40,26
    print str_gohome   
    set_cur 40,27
    print str_esc    
  ;=====move loop=======
  start:
    ;======get keyboard=======
    get_char bl   
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
        ;;;;;;;;;;;
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
        call choose_level             
        jmp go_load    
  @@: 
    cmp bl,_enter 
    jne @f
    jmp go_home
  @@:
    cmp bl,_esc  
    je  done     
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
            print_icon di,people
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
                je complete
                jmp mov_people
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
                print_icon di,people 
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
                print_icon di,people 
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
            print_icon di,people
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
                print_icon di,people 
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
                print_icon di,people 
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
        print_icon di,vegetable
        jmp start
      @@:
        mov people_coo,di
        print_icon di,people
        jmp start    
;=====end page 2========    
 ret
 page_2 endp
 
 page_3 proc near 
;====start page 3========
    setmode print_mode
    setcolor black
    ;=====print huan=======
    lea bp,huan
    mov cx,20
    mov dx,30
    call print_huan
    ;====introduce page 3======
    set_cur 30,23
    print str_success
    set_cur 27,25
    print str_gohome
    set_cur 27,26
    print str_esc
  getchar_page3:
    ;===get keyboard======
    get_char bl 
    cmp bl,_enter
    je go_home       
    cmp bl,_esc
    je done 
jmp getchar_page3    
  ret
 page_3 endp

 delay proc near
    mov cx,0
  L1:
    mov bp,0800h
  L2:
    dec bp
    cmp bp,0
    jnz L2
    loop L1
    ret
 delay endp
 
 print_figure_proc proc near
    mov x_tmp,cx
    mov x_end,cx 
    add x_end,block_range
    mov y_end,dx
    add y_end,block_range
  reprint_2:
    write_pixel cx,dx,[bp]
    inc bp
    inc cx
    cmp cx,x_end
    jne reprint_2
    mov cx,x_tmp 
    inc dx
    cmp dx,y_end
    jne reprint_2
    ret
 print_figure_proc endp
 
  print_huan proc near
    mov x_tmp,cx
    mov x_end,cx 
    add x_end,x_range*amp
    mov y_end,dx
    add y_end,y_range*amp
  reprint_3:
    mov al,[bp]
        push di
        push si 
        push cx
        push dx
        mov tmp_col,cx
        mov tmp_row,dx
            mov di,0
            mov si,0
            re_w:
              
            mov ah,0ch
            mov bh,00h   
            mov al,[bp]
            mov cx,tmp_col
            add cx,di
            mov dx,tmp_row
            add dx,si
            int 10h
            
            inc di
            cmp di,amp
            jb re_w
            mov di,0
            inc si
            cmp si,amp
            jb re_w
        pop dx
        pop cx    
        pop si
        pop di  
    inc bp    
    add cx,amp
    cmp cx,x_end
    jne reprint_3
    mov cx,x_tmp 
    add dx,amp
    cmp dx,y_end
    jne reprint_3
    ret
 print_huan endp
 
 choose_level proc near
    cmp level_choose,1
    jne @f
    lea si,level_1
    ret
    @@:
    cmp level_choose,2
    jne @f
    lea si,level_2
    ret    
    @@:
    cmp level_choose,2
    jne @f
    lea si,level_2
    ret    
    @@:
   cmp level_choose,3
    jne @f
    lea si,level_3
    ret    
    @@:
   cmp level_choose,4
    jne @f
    lea si,level_4
    ret    
    @@:
   cmp level_choose,5
    jne @f
    lea si,level_5
    ret    
    @@:
   cmp level_choose,6
    jne @f
    lea si,level_6
    ret    
    @@:
   cmp level_choose,7
    jne @f
    lea si,level_7
    ret    
    @@:
   cmp level_choose,8
    jne @f
    lea si,level_8
    ret    
    @@:
    lea si,level_9  ;;;;;
    ret
 choose_level endp
 
end