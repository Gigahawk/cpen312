CSEG AT 0000h
	MOV DPTR, #0003h
	CLR C
	SUBB A, #20h
	MOV B, #6h
	MUL AB
	ADD A, DPL
	MOV DPL, A
	MOV A, B
	ADDC A, DPH
	MOV DPH, A
END