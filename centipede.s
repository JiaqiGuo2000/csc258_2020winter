#####################################################################
#
# CSC258H Winter 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Jiaqi Guo, 1005882127
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# - Milestone 1-4
#
# Which approved additional features have been implemented?
# 1. Milestone 4.b (reducted version) score counted as tokens
# 2. Milestone 4.c (reducted version) lives counted as tokens
#
# Any additional information that the TA needs to know:
# - This project is written based on the provided beginner code. Great thanks to our TA Mohamed Elgammal! 
#
#####################################################################

.data
	displayAddress:	.word 0x10008000
	bugLocation: .word 814
	centipedLocation: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	centipedDirection: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
	centipedLength: .word 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
	centipedMoveDelay: .word 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
	mushroomLocation: .word -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	mushroomCount: .word 0
	dartLocation: .word -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dartCount: .word 0
	hitCount: .word 0
	fleaLocation: .word -1
	score: .word 0
	lives: .word 0
.text 


	jal init
Loop:
	jal disp_bug
	jal disp_centiped
	jal disp_mushroom
	jal disp_stats
	jal delay
	jal check_keystroke
	jal update_centiped
	jal update_dart
	jal update_flea
	jal check_hit
	jal check_hit_mushroom
	jal check_alive
	j Loop	

Exit:
	li $v0, 10		# terminate the program gracefully
	syscall
	
init:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal init_mushroom
	jal respawn_centiped
	jal init_flea
	jal reset_dart
	la $a0, score
	la $a1, lives		# load address
	li $t0, 0
	li $t1, 5		# reset values
	sw $t0, 0($a0)
	sw $t1, 0($a1)		# save score and lives
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

disp_stats:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a0, score
	lw $t0, 0($a0)
	li $a0, 0
	beq $a0, $t0, disp_score_end
disp_score_loop:
	lw $t2, displayAddress  
	li $t3, 0xffffff	
	addi $t1, $a0, 864
	sll $t4,$t1, 2		
	add $t4, $t2, $t4	
	sw $t3, 0($t4)		
	addi $a0, $a0, 1
	bne $a0, $t0, disp_score_loop
disp_score_end:
	la $a0, lives
	lw $t0, 0($a0)
	li $a0, 0
	beq $a0, $t0, disp_lives_end
disp_lives_loop:
	lw $t2, displayAddress  
	li $t3, 0xff0000	
	addi $t1, $a0, 928
	sll $t4,$t1, 2		
	add $t4, $t2, $t4	
	sw $t3, 0($t4)
	li $t3, 0x000000	
	addi $t1, $a0, 929
	sll $t4,$t1, 2		
	add $t4, $t2, $t4	
	sw $t3, 0($t4)
	addi $a0, $a0, 1
	bne $a0, $t0, disp_lives_loop
disp_lives_end:
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


disp_bug:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, bugLocation	# load the address of buglocation from memory
	lw $t1, 0($t0)		# load the bug location itself in t1
	
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0xffffff	# $t3 stores the black colour code
	
	sll $t4,$t1, 2		# $t4 the bias of the old buglocation
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)		# paint the block with black
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
refresh:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x000000	# $t3 stores the black colour code
	li $t0, 0
refresh_loop:
	sll $t4,$t0, 2		# $t4 is the bias of the old body location in memory (offset*4)
	add $t4, $t2, $t4	
	sw $t3, 0($t4)
	addi $t0, $t0, 1
	bne $t0, 1024, refresh_loop
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


# function to display a static centiped	
disp_centiped:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $a3, $zero, 10	 # load a3 with the loop count (10)
	la $a1, centipedLocation # load the address of the array into $a1
	la $a2, centipedDirection # load the address of the array into $a2

arr_loop:	#iterate over the loops elements to draw each body in the centiped
	lw $t1, 0($a1)		 # load a word from the centipedLocation array into $t1
	lw $t5, 0($a2)		 # load a word from the centipedDirection  array into $t5
	#####
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0xff0000	# $t3 stores the red colour code
	
	
	sll $t4,$t1, 2		# $t4 is the bias of the old body location in memory (offset*4)
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	
	bne $t5, 0, paint_head
	sw $t3, 0($t4)		# paint the body with red
	j arr_loop_cont
	
paint_head:	#paint head
	li $t3, 0x00ff00
	sw $t3, 0($t4)		# paint the body with red
arr_loop_cont:
	addi $a1, $a1, 4	 # increment $a1 by one, to point to the next element in the array
	addi $a2, $a2, 4
	addi $a3, $a3, -1	 # decrement $a3 by 1
	bne $a3, $zero, arr_loop
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

respawn_centiped:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, centipedLocation
	#lw $t0, 36($a0)
	#lw $t2, displayAddress  # $t2 stores the base address for display
	#li $t3, 0x000000	# $t3 stores the black colour code
	#sll $t4,$t0, 2		# $t4 is the bias of the old body location in memory (offset*4)
	#add $t4, $t2, $t4	
	#sw $t3, 0($t4)
	
	li $t0, 0
respawn_centiped_loop:
	sw $t0, 0($a0)
	addi $t0, $t0, 1
	addi $a0, $a0, 4
	bne $t0, 10, respawn_centiped_loop
	
	la $a1, centipedDirection
	li $t1, 1
	sw $t1, 36($a1)
	
	
	li $t0, 0
	la $a0, hitCount
	sw $t0, 0($a0)
	
	jal refresh
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


check_alive:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a0, bugLocation
	la $a1, fleaLocation
	la $a2, centipedLocation
	
	lw $t0, 0($a0)
	lw $t1, 0($a1)
	lw $t2, 0($a2)
	
	beq $t0, $t1, lose	#hit by flea
	bge $t2, 800, hitCentiped	#hit by centiped 
	j alive
hitCentiped:
	jal lose
	jal respawn_centiped
alive:
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

lose:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, lives
	lw $t1, 0($t0)
	addi $t1, $t1, -1
	sw $t1, 0($t0)
	beq $t1, 0, lose_game
	j lose_life
lose_game:
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0xff0000	# $t3 stores the black colour code
	li $t0, 0
lose_loop:
	sll $t4,$t0, 2		# $t4 is the bias of the old body location in memory (offset*4)
	add $t4, $t2, $t4	
	sw $t3, 0($t4)
	addi $t0, $t0, 1
	bne $t0, 1024, lose_loop
	
	
	lw $t8, 0xffff0000
	beq $t8, 1, ready_for_retry # if key is pressed, jump to get this key
	addi $t8, $zero, 0
	
ready_for_retry:
	lw $t2, 0xffff0004
	addi $v0, $zero, 0	#default case
	beq $t2, 0x73, init
	beq $t2, 0x73, Loop
	j ready_for_retry
	
lose_life:
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	

check_hit:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a0, centipedLocation
	la $a2, hitCount
	lw $t2, 0($a2)		#total hit count
	li $t3, 10		#segment count
	
check_hit_centiped_loop:
	lw $t0, 0($a0)		#current centiped segment location
	li $t4, 20		#dart count
	la $a1, dartLocation
	
check_hit_dart_loop:
	lw $t1, 0($a1)		#current dart location
	beq $t1, $t0, hit
	j check_hit_dart_loop_cont
hit:
	li $t5, -1
	sw $t5, 0($a1)
	addi $t2, $t2, 1
	sw $t2, 0($a2)
	la $t7, score
	lw $t8, 0($t7)
	addi, $t8, $t8, 1
	sw $t8, 0($t7)
	#beq $t2, 3, jal respawn_centiped
	#lw $t6, displayAddress  # $t2 stores the base address for display
	#li $t7, 0x000000	# $t3 stores the black colour code
	#sll $t8,$t0, 2		# $t4 is the bias of the old body location in memory (offset*4)
	#add $t8, $t6, $t8	
	#sw $t7, 0($t8)
	
	
check_hit_dart_loop_cont:
	
	addi $a1, $a1, 4
	addi $t4, $t4, -1
	bnez $t4, check_hit_dart_loop
	
	addi $a0, $a0, 4
	addi $t3, $t3, -1
	bnez $t3, check_hit_centiped_loop
	
	lw $t2, 0($a2)
	bne $t2, 3, check_hit_end
	jal respawn_centiped
check_hit_end:
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
check_hit_mushroom:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a0, mushroomLocation
	lw $t2, 0($a2)		#total hit count
	li $t3, 20		#mushroom count
	
check_hit_mushroom_loop:
	lw $t0, 0($a0)		#current centiped segment location
	li $t4, 20		#dart count
	la $a1, dartLocation
	
check_hit_mushroom_dart_loop:
	lw $t1, 0($a1)		#current dart location
	beq $t1, $t0, hit_mushroom
	j check_hit_mushroom_dart_loop_cont
hit_mushroom:
	li $t1, -1
	sw $t1, 0($a1)
	
check_hit_mushroom_dart_loop_cont:
	
	addi $a1, $a1, 4
	addi $t4, $t4, -1
	bnez $t4, check_hit_mushroom_dart_loop
	
	addi $a0, $a0, 4
	addi $t3, $t3, -1
	bnez $t3, check_hit_mushroom_loop
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

init_mushroom:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t1, mushroomLocation
	la $t2, mushroomCount
	lw $t3, 0($t1)
	lw $t4, 0($t2)
	li $t5, 20
	li $v0, 42
	li $a0, 0
	li $a1, 799
init_mushroom_loop:
	syscall
	sw $a0, 0($t1)
	addi $t1, $t1, 4
	addi $t4, $t4, 1
	addi $t5, $t5, -1
	bnez $t5, init_mushroom_loop
	
	sw $t4, 0($t2)
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

disp_mushroom:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a1, mushroomLocation # load the address of the array into $a1
	#la $a2, mushroomCount
	#lw $a2, 0($a2)
	li $a2, 20

disp_mushroom_loop:	#iterate over the loops elements to draw each mushroom
	lw $t1, 0($a1)		 # load a word from the mushroomLocation array into $t1
	#####
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0xffff00	# $t3 stores the red colour code
	
	sll $t4,$t1, 2		# $t4 is the bias of the old body location in memory (offset*4)
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	
	sw $t3, 0($t4)		# paint the mushroom
	addi $a1, $a1, 4	 # increment $a1 by one, to point to the next element in the array
	addi $a2, $a2, -1	 # decrement $a3 by 1
	bne $a2, $zero, disp_mushroom_loop
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	

init_flea:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a1, fleaLocation
	lw $t0, 0($a1)
	lw $t5, displayAddress  # $t2 stores the base address for display
	li $t6, 0x000000	# $t3 stores the red colour code
	
	sll $t7,$t0, 2		# $t4 is the bias of the old body location in memory (offset*4)
	add $t7, $t5, $t7	# $t4 is the address of the flea location
	
	sw $t6, 0($t7)	
	
	li $v0, 42
	li $a0, 0
	li $a1, 31
	syscall
	add $t0, $a0, $zero
	la $a1, fleaLocation
	sw $a0, 0($a1)
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	

update_flea:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a2, fleaLocation
	lw $t0, 0($a2)
	bne $t0, -1, move_flea
	jal init_flea
	add $t0, $zero, $a0
	sw $t0, 0($a2)
	j update_flea_end
move_flea:
	lw $t5, displayAddress  # $t2 stores the base address for display
	li $t6, 0x000000	# $t3 stores the red colour code
	
	sll $t7,$t0, 2		# $t4 is the bias of the old body location in memory (offset*4)
	add $t7, $t5, $t7	# $t4 is the address of the flea location
	
	sw $t6, 0($t7)		
	addi $t0, $t0, 32
	
	sw $t0, 0($a2)
	
	li $t6, 0xff00ff	
	
	sll $t9,$t0, 2		
	add $t9, $t5, $t9	
	sw $t6, 0($t9)
	bge $t0, 863 init_flea
	
update_flea_end:
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


update_centiped:		#update cetipede location
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $a3, $zero, 10	 # load a3 with the loop count (10)
	la $a1, centipedLocation # load the address of the array into $a1
	la $a2, centipedDirection # load the address of the array into $a2
update_centiped_loop:
	lw $t1, 0($a1)		 # load a word from the centipedLocation array into $t1
	lw $t5, 0($a2)		 # load a word from the centipedDirection  array into $t5
	
	beq $t1, -1, update_centiped_loop_cont		# skip deleted segment
	beq $t5, 0, follow_next				# a non-head segment follows the next
	# a head segment moves according to the direction
	add $t2, $t1, $zero
	slti $t3, $t2, 32	# t3 is the indicator whether t1 is less than 32
	bgtz $t3, lt_32_end
lt_32:	# want to reduce the range of t1
	addi $t2, $t2, -32
	slti $t3, $t2, 32
	bgtz $t3, lt_32_end
	j lt_32
lt_32_end:
	add $t2, $t2, $t5	# direction 1 means right & -1 means left
	beq $t2, -1, turn_direction_right
	beq $t2, 32, turn_direction_left	# hits the border
	
	add $t1, $t1, $t5
	
	la $t8, mushroomLocation # load the address of the array into $a1
	la $t6, mushroomCount
	lw $t6, 0($t6)
	beq $t6, 0, check_mushroom_completed

check_mushroom_loop:	#iterate over the loops elements to draw each mushroom
	lw $t7, 0($t8)		 # load a word from the mushroomLocation array into $t7
	
	beq $t7, $t1, going_into_mushroom
	addi $t8, $t8, 4	 # increment $a1 by one, to point to the next element in the array
	addi $t6, $t6, -1	 # decrement $t6 by 1
	bne $t6, $zero, check_mushroom_loop

check_mushroom_completed:
	sw $t1, 0($a1)
	j update_centiped_loop_cont

going_into_mushroom:
	sub $t1, $t1, $t5
	beq $t5, 1, turn_direction_left
	beq $t5, -1, turn_direction_right

	#j update_centiped_loop_cont
	
turn_direction_right:
	addi $t5, $zero, 1
	sw $t5, 0($a2)
	j go_down

turn_direction_left:
	addi $t5, $zero, -1
	sw $t5, 0($a2)
	j go_down
	
go_down:
	beq $t1, 832, skip_go_down
	beq $t1, 863, skip_go_down
	addi $t1, $t1, 32
	sw $t1, 0($a1)
	j update_centiped_loop_cont
skip_go_down:
	add $t1, $t1, $t5
	sw $t1, 0($a1)
	j update_centiped_loop_cont
follow_next:
	addi $t5, $a1, 4
	lw $t5, 0($t5)
	sw $t5, 0($a1)
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x000000	# $t3 stores the black colour code
	
	sll $t4,$t1, 2		# $t4 the bias of the old location
	add $t4, $t2, $t4	# $t4 is the address of the old location
	sw $t3, 0($t4)		# paint the first (top-left) unit back.
update_centiped_loop_cont:
	addi $a1, $a1, 4	 # increment $a1 by one, to point to the next element in the array
	addi $a2, $a2, 4
	addi $a3, $a3, -1	 # decrement $a3 by 1
	bne $a3, $zero, update_centiped_loop
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


reset_dart:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a0, dartLocation
	li $t1, 20
	li $t0, -1
reset_dart_loop:
	sw $t0, 0($a0)
	addi $t1, $t1, -1
	addi $a0, $a0, 4
	bnez $t1, reset_dart_loop
	
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

update_dart:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a0, dartLocation
	#la $a1, dartCount
	#lw $t1, 0($a1)		#store the dart count in $t1
	li $t1, 20
	#beq $t1, 0, update_dart_end
	
update_dart_loop:
	
	lw $t0, 0($a0)		#store the current dart location in $t0
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x000000	# $t3 stores the colour code
	sll $t4, $t0, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)		# paint the block
	addi $t0, $t0, -32
	
	bgez $t0, update_dart_loop_cont # if $t0<0, reset the dart
	li $t0, -1
	sw $t0, 0($a0)
#	addi $t5, $t1, -1
#	addi $a2, $a0, 0
#	beqz $t5, got_last_dart
#to_last_dart:
#	addi $a2, $a2, 4
#	addi $t5, $5, -1
#	beqz $t5, to_last_dart
#got_last_dart:
#	lw $t6, 0($a2)		# location of last dart in $t6
#	addi $t6, $zero, -1
#	sw $t6, 0($a2)		# put the last dart into the current dart and remove the new last dart
#	lw $t6, 0($a1)
#	addi $t6, $t6, -1
#	sw $t6, 0($a1)		# dartCount -= 1
#	addi $t1, $t1, -1
#	bnez $t6, update_dart_loop
#	j update_dart_end
	
update_dart_loop_cont:
	li $t3, 0x00ffff	# $t3 stores the colour code
	sll $t4,$t0, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)		# paint the block
	sw $t0, 0($a0)
	addi $t1, $t1, -1
	addi $a0, $a0, 4
	bne $t1, 0, update_dart_loop
	
	
update_dart_end:
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	
# function to detect any keystroke
check_keystroke:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t8, 0xffff0000
	beq $t8, 1, get_keyboard_input # if key is pressed, jump to get this key
	addi $t8, $zero, 0
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
# function to get the input key
get_keyboard_input:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t2, 0xffff0004
	addi $v0, $zero, 0	#default case
	beq $t2, 0x6A, respond_to_j
	beq $t2, 0x6B, respond_to_k
	beq $t2, 0x78, respond_to_x
	beq $t2, 0x73, respond_to_s
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
# Call back function of j key
respond_to_j:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, bugLocation	# load the address of buglocation from memory
	lw $t1, 0($t0)		# load the bug location itself in t1
	
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x000000	# $t3 stores the black colour code
	
	sll $t4,$t1, 2		# $t4 the bias of the old buglocation
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)		# paint the first (top-left) unit white.
	
	beq $t1, 800, skip_movement # prevent the bug from getting out of the canvas
	addi $t1, $t1, -1	# move the bug one location to the left
skip_movement:
	sw $t1, 0($t0)		# save the bug location

	li $t3, 0xffffff	# $t3 stores the white colour code
	
	sll $t4,$t1, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)		# paint the first (top-left) unit white.
	
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

# Call back function of k key
respond_to_k:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $t0, bugLocation	# load the address of buglocation from memory
	lw $t1, 0($t0)		# load the bug location itself in t1
	
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x000000	# $t3 stores the black colour code
	
	sll $t4,$t1, 2		# $t4 the bias of the old buglocation
	add $t4, $t2, $t4	# $t4 is the address of the old bug location
	sw $t3, 0($t4)		# paint the block with black
	
	beq $t1, 831, skip_movement2 #prevent the bug from getting out of the canvas
	addi $t1, $t1, 1	# move the bug one location to the right
skip_movement2:
	sw $t1, 0($t0)		# save the bug location

	li $t3, 0xffffff	# $t3 stores the white colour code
	
	sll $t4,$t1, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)		# paint the block with white
	
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
respond_to_x:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	la $a0, bugLocation
	la $a1, dartLocation
	la $a2, dartCount
	lw $t0, 0($a0)		#$t1 stores bugLocation
	lw $t1, 0($a1)		#$t1 stores the new dart's location
	lw $t2, 0($a2)		#$t2 stores dartCount
	bne $t2, 19, respond_to_x_no_reset_count	#reaches the maximum index of darts
	li $t2, 0
respond_to_x_no_reset_count:
	addi $t2, $t2, 1
	sw $t2, 0($a2)		#update dartCount
	beq $t2, 1, respond_to_x_loop_end
respond_to_x_loop:
	addi $a1, $a1, 4
	addi $t2, $t2, -1
	bne $t2, 0, respond_to_x_loop
	
respond_to_x_loop_end:
	addi $t1, $t0, 0
	sw $t1, 0($a1)
	
	lw $t2, displayAddress  # $t2 stores the base address for display
	li $t3, 0x00ffff	# $t3 stores the black colour code
	sll $t4,$t1, 2
	add $t4, $t2, $t4
	sw $t3, 0($t4)		# paint the block

respond_to_x_end:
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
respond_to_s:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal init
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

delay:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $t2, 50000
delay_loop:
	addi $t2, $t2, -1
	bgtz $t2, delay_loop
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
