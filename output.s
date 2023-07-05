	addi a0 zero 50
	addi a1 zero 40
	j L1
L0:
	add t0 zero a0
	add a0 zero a1
	rem a1 t0 a1
L1:
	bne a1 zero L0
	add a1 zero a0
	addi a0 zero 1
	ecall
	addi a0 zero 500
	addi a1 zero 400
	j L3
L2:
	add t0 zero a0
	add a0 zero a1
	rem a1 t0 a1
L3:
	bne a1 zero L2
	add a1 zero a0
	addi a0 zero 1
	ecall
