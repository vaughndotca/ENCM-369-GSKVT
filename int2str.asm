# int2str.asm
# ENCM 369 Winter 2025 Lab 6 Exercise G

# BEGINNING of start-up & clean-up code.  Do NOT edit this code.
	.data
exit_msg_1:
	.asciz	"***About to exit. main returned "
exit_msg_2:
	.asciz	".***\n"
main_rv:
	.word	0
	
	.text
	# adjust sp, then call main
	andi	sp, sp, -32		# round sp down to multiple of 32
	jal	main
	
	# when main is done, print its return value, then halt the program
	sw	a0, main_rv, t0	
	la	a0, exit_msg_1
	li      a7, 4
	ecall
	lw	a0, main_rv
	li	a7, 1
	ecall
	la	a0, exit_msg_2
	li	a7, 4
	ecall
        lw      a0, main_rv
	addi	a7, zero, 93	# call for program exit with exit status that is in a0
	ecall
# END of start-up & clean-up code.

	.data
	.globl	digits
digits: .asciz	"0123456789"		# char digits[] = "0123456789"
			
			
# void int2str(char *dest, int str)
#     arg/var	   	GPR
#       dest		 a0
#	src		 a1
#       unsigned abs_src t0
#	unsigned ten	 t1
#	unsigned rem	 t2
#	unsigned temp 	 t3
#	char *p		 t4
#       char *q		 t5
#
# Remark: We have used up all but one of the t-registers.
# However, a2-a7 can also be used for intermediate results.
#
	.text
	.globl	int2str
int2str:
	# Handle zero case
	bnez a1, check_neg
	li t4, '0'
	sb t4, (a0)
	addi a0, a0, 1
	sb zero, (a0)
	jr ra

check_neg:
	# Handle -2147483648 case
	li t5, -2147483648
	bne a1, t5, normal_neg_check
	li t3, 1  # Negative flag
	li t0, 0x80000000
	j convert

normal_neg_check:
	bltz a1, make_positive
	mv t0, a1
	j convert

make_positive:
	li t3, 1
	neg t0, a1

convert:
	li t1, 10  # Base 10
	mv t4, a0  # Pointer to destination

extract_digits:
	remu t2, t0, t1  # abs_src % 10
	divu t0, t0, t1  # abs_src / 10
	li t6, 48
	add t2, t2, t6
	sb t2, (t4)
	addi t4, t4, 1
	bnez t0, extract_digits

	# Add '-' if negative
	beqz t3, terminate
	li t2, '-'
	sb t2, (t4)
	addi t4, t4, 1

terminate:
	sb zero, (t4)  # Null terminate
	addi t4, t4, -1  # Move before null terminator
	mv t5, a0  # Start of string

reverse:
	bge t5, t4, done_reverse
	lb t2, (t5)
	lb t3, (t4)
	sb t3, (t5)
	sb t2, (t4)
	addi t5, t5, 1
	addi t4, t4, -1
	j reverse

done_reverse:
	jr	ra
	

	.data
	.globl	buf
buf:	.space	12			# char buf[12]; 
	.globl	finish
finish: .asciz 	"\"\n"			# char finish[] = "\"\n"


# void try_it(const char *msg, int src) 
#
	.text
	.globl	try_it
try_it:
	addi	sp, sp, -32
	sw	ra, 4(sp)
	sw	s0, 0(sp)
	mv	s0, a0			# save msg to s0
	
	la	a0, buf			# a0 = buf
	jal	int2str			# note a1 = src already
	
	mv	a0, s0			# a0 = msg
	li	a7, 4			# service = PrintString
	ecall
	la	a0, buf			# a0 = buf
	li	a7, 4
	ecall
	la	a0, finish		# a0 = finish
	li	a7, 4
	ecall
	
	lw	s0, 0(sp)
	lw	ra, 4(sp)
	addi	sp, sp, 32
	jr	ra	

		
	.data
try1:	.asciz 	"try #1: \""
try2:	.asciz 	"try #2: \""
try3:	.asciz 	"try #3: \""
try4:	.asciz 	"try #4: \""
try5:	.asciz 	"try #5: \""
try6:	.asciz 	"try #6: \""
try7:	.asciz 	"try #7: \""
try8:	.asciz 	"try #8: \""
		
# int main(void)
# 
	.text
	.globl	main
main:
	addi	sp, sp, -32
	sw	ra, 0(sp)
	
	la	a0, try1
	li	a1, 0
	jal	try_it

	la	a0, try2
	li	a1, 1
	jal	try_it

	la	a0, try3
	li	a1, -1
	jal	try_it

	la	a0, try4
	li	a1, -2147483648
	jal	try_it

 	la	a0, try5
	li	a1, -2147483647
	jal	try_it

	la	a0, try6
	li	a1, 2147483647
	jal	try_it

	la	a0, try7
	li	a1, 123
	jal	try_it

	la	a0, try8
	li	a1, -456789
	jal	try_it

	mv	a0, zero	# r.v. = 0

	lw	ra, 0(sp)
	addi	sp, sp, 32
	jr	ra


