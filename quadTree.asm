main	START 	0

	LDA	#gap
	JSUB	stinit
	LDA	#gap_n
	JSUB	stinitn
	LDA	#gap_x
	JSUB	stinitx

loop1	LDA	#0
	TD	INDEV
	JEQ	loop1	.check
	RD	INDEV	.A <- keboard input
	SUB	#48	.ASCII	
	STA	num
	MUL	num	.A = num*num
	STA	n	.n = A
	RD	INDEV

rdarr	LDS	Esize	.3
	LDX	#0
	LDA	n
	MUL	Esize
	RMO	A,T	.T = n*3 
loop2	LDA	#0
	TD	INDEV
	JEQ	loop2
	RD	INDEV
	COMP	#10	.enter
	JEQ	loop2
	SUB	#48	
	STA	arr, X	.indexed address
	ADDR	S,X	.X = X+S
	COMPR	X,T
	JLT	loop2
	JSUB	quad
	J	ENDD


stinit	STA	stackp
	RSUB

push    STA @stackp   . @stackp value <- A
	LDA stackp
	ADD #3
	STA stackp	. address + 3
	RSUB
	
pop     LDA stackp    
	SUB #3
	STA stackp	. address - 3
	LDA @stackp	. A <- @stackp value
	RSUB

stinitn	STA	stack_n
	RSUB

push_n  STA @stack_n   
	LDA stack_n
	ADD #3
	STA stack_n	
	RSUB
	
pop_n   LDA stack_n    
	SUB #3
	STA stack_n	
	LDA @stack_n	
	RSUB

stinitx	STA	stack_x
	RSUB

push_x  STA @stack_x   
	LDA stack_x
	ADD #3
	STA stack_x	
	RSUB
	
pop_x   LDA stack_x    
	SUB #3
	STA stack_x	
	LDA @stack_x	
	RSUB


quad	LDX	#0
	LDA	num
	STA	chnum

check	STL 	tmpL    . tmpL = L
	LDA	tmpL
	JSUB 	push   	. push L
	LDA	chnum
	COMP	#1
	JEQ	PRINT	.if chnum == 1 then exit
	LDA	arr,X
	COMP	#1
	JEQ	check_1

check_0	LDA	#0
	STA	cnt
	STA	cnt2
	STA	j1	
	STA	j2	.cnt,cnt2,j1,j2 = 0
in_0	LDA	arr, X	.indexed address
	COMP	#1	.different
	JEQ	recur	
	ADDR	S,X	
	LDA	cnt
	ADD	#1	.cnt++
	STA	cnt	
	LDA	j1
	ADD	#1	.j1++
	STA	j1
	COMP	chnum
	JLT	in_0	.inner loop in_0
	LDA	#0
	STA	j1	.init j1
	LDA	num
	SUB	chnum
	MUL	Esize
	STA	nnn
	ADDR	A,X	.X = X+(num-chnum)*3
	LDA	cnt2
	ADD	#1	.cnt2++
	STA	cnt2	
	LDA	j2
	ADD	#1	.j2++
	STA	j2
	COMP	chnum
	JLT	in_0
PRINT_0	TD	OUTDEV
	JEQ	PRINT_0
	LDA	#0
	ADD	#48
	WD	OUTDEV	.0
	JSUB 	pop    	. pop L
	STA 	tmpL    
	LDL	tmpL
	RSUB


check_1	LDA	#0
	STA	cnt
	STA	cnt2
	STA	j1	
	STA	j2	.cnt,cnt2,j1,j2 = 0
in_1	LDA	arr, X	.indexed address
	COMP	#0	.different
	JEQ	recur	
	ADDR	S,X	
	LDA	cnt
	ADD	#1	.cnt++
	STA	cnt
	LDA	j1
	ADD	#1	.j1++
	STA	j1
	COMP	chnum
	JLT	in_1	.inner loop
	LDA	#0
	STA	j1
	LDA	num
	SUB	chnum
	MUL	Esize
	STA	nnn
	ADDR	A,X	.X = X+(num-chnum)*3
	LDA	cnt2
	ADD	#1	.cnt2++
	STA	cnt2
	LDA	j2
	ADD	#1	.j2++
	STA	j2
	COMP	chnum
	JLT	in_1
PRINT_1	TD	OUTDEV
	JEQ	PRINT_1
	LDA	#1
	ADD	#48
	WD	OUTDEV	. 1
	JSUB 	pop    	. pop L
	STA 	tmpL    
	LDL	tmpL
	RSUB

PRINT	LDA	arr, X	.indexed address
	COMP	#1	
	JEQ	PRINT11
	TD	OUTDEV
	JEQ	PRINT
	LDA	#0
	ADD	#48
	WD	OUTDEV	. 0
	JSUB 	pop    	. pop L
	STA 	tmpL    
	LDL	tmpL
	J	exit

PRINT11	TD	OUTDEV
	JEQ	PRINT11
	LDA	#1
	ADD	#48
	WD	OUTDEV	. 1
	JSUB 	pop    	. pop L
	STA 	tmpL    
	LDL	tmpL
	J	exit

recur	TD	OUTDEV
	JEQ	recur
	LDA	#40
	WD	OUTDEV	.(	
	LDA	chnum
	JSUB 	push_n  .push chnum
	LDA	chnum
	DIV	#2		
	STA	chnum	.chnum = chnum/2     
	COMP	#1
	JEQ	recur1
	LDA	cnt	......................................
	MUL	Esize
	SUBR	A,X	
	LDA	nnn
	MUL	cnt2
	SUBR	A,X	.X = X-cnt*3-cnt2*nnn
	STX	xval2
	LDA	xval2
	JSUB	push_x	.push xvals(X register value).........
	LDX	xval2	
	JSUB	check	.left,up..............................
	LDX	xval2
	LDA	num
	SUB	chnum
	STA	imm2
	LDA	num
	SUB	imm2
	MUL	Esize
	ADDR	A,X	.X = X+(num-(num-chnum))*3
	JSUB	check	.right,up .............................
	LDX	xval2
	LDA	num
	SUB	chnum
	STA	imm2
	LDA	num
	SUB	imm2
	MUL	Esize
	MUL	num	.(num-(num-chnum))*3*num
	ADDR	A,X	.X = X +((num-(num-chnum))*3*num
	JSUB	check	.left,down ............................
	LDX	xval2
	LDA	num
	SUB	chnum
	STA	imm2
	LDA	num
	SUB	imm2
	MUL	Esize
	STA	imm	.(num-(num-chnum))*3
	MUL	num	.(num-(num-chnum))*3*num
	ADD	imm
	ADDR	A,X	.X = X +(num-(num-chnum))*3 +(num-(num-chnum))*3*num
	JSUB	check	.right,down............................
return	TD	OUTDEV
	JEQ	return
	LDA	#41
	WD	OUTDEV	.)
	JSUB	pop_n	.pop chnum
	STA	chnum
	JSUB	pop_x	
	STA	xval2
	JSUB	pop_x	.pop x
	STA	xval2
	JSUB 	pop    	.pop L
	STA 	tmpL    
	LDL	tmpL
	J	exit

recur1	LDA	cnt
	MUL	Esize
	SUBR	A,X	
	LDA	nnn
	MUL	cnt2
	SUBR	A,X	.X = X-cnt*3-cnt2*nnn
	STX	xval	.............................
	LDX	xval	
	JSUB	check	.left,up.....................
	LDX	xval
	LDA	Esize	 
	ADDR	A,X	.X = X+3
	JSUB	check	.right,up....................
	LDX	xval
	LDA	Esize	
	MUL	num
	ADDR	A,X	.X = X+3*num
	JSUB	check	.left,down...................
	LDX	xval
	LDA	Esize	
	MUL	num
	ADDR	X,A	
	ADD	Esize	.A = X+3*num+3
	STA	vv
	LDX	vv	.X = X+3*num+3
	JSUB	check	.right,down..................
return1	TD	OUTDEV
	JEQ	return1
	LDA	#41
	WD	OUTDEV	.)
	JSUB	pop_n	.pop chnum
	STA	chnum
	JSUB 	pop    	.pop L
	STA 	tmpL    
	LDL	tmpL
	J	exit

exit	RSUB

ENDD  	J	ENDD	


j1    	RESW	1
j2 	RESW	1
imm2	RESW	1
tmpL    RESW 	1
vv 	RESW	1
cnt 	RESW	1
cnt2	RESW	1
nnn	RESW	1
xval2	RESW	1
xval	RESW	1
imm 	RESW	1
chnum 	RESW	1
num	RESW	1
n	RESW	1	.n
Esize	WORD	3	.element size

INDEV	BYTE	0
OUTDEV	BYTE	1

stackp 	RESW 	1 
stack_n RESW 	1 
stack_x RESW 	1 

gap	RESW	100
gap_n	RESW	100
gap_x	RESW	100
arr	RESW	1