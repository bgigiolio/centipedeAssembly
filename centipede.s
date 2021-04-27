################################################################
#
# CSC258H Winter 2021 Assembly Final Project
# University of Toronto, St. George
#  
# Student: Blake Gigiolio, 1005777134
# 
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for display: 0x10008000 ($gp)
#
# Milestone 3 reached
###############################################################
.data
##############VVVVV Change these based on preference VVVVV######################
	mushroomArray: .word 0:9 #this decides amount of mushrooms
	dontChange: .word 600 #DO NOT CHANGE THIS ONE!!!
	mushroomCount: .word 10 #mushroom array end point + 1
	gameSpeed: .word 10000 #The larger the value, the slower the game
	fleaGenOdds: .word 30 #chance flea spawns on each tick is (1/fleaGenOdds)
####################VVVVV Dont change these!! VVVVV#############################
	bulletColor: .word 0xb0b0b0 #bullet color (grey)
	mushroomColor: .word 0xf7f37c #mushroom color (yellow)
	blasterColor: .word 0x7afffd #blaster body (blue)
	centipedeColor: .word 0x8a543f #centipede (dark brown)
	centipedeColorPlaceHolder: .word 0x8a543f #centipede (dark brown)
	backgroundColor: .word 0x64d64b #background (green)
	centipedeHeadColor: .word 0xf7bc4d #centipede head (light brown / orange)
	fleaColor: .word 0xededed #flea color (white)
	twoLifeColor: .word 0xba5027
	oneLifeColor: .word 0xe34407
###################^^^^^Colors^^^^^###############################################
	displayAddress: .word 0x10008000
	blasterLocation: .word 814
	centLocation: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	centDirection: .word 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	lastCentLocation: .word 0
	annoyArray: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	bulletLocation: .word 814
	bulletActive: .word 0
	centipedeLives: .word 3
	drawCent: .word 1
	recentMushroom: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	fleaPosition: .word -1
	gameOverText: .word 35, 36, 37, 41, 42, 46, 50, 53, 54, 55, 56, 66, 72, 75, 78, 79, 81, 82, 85, 98, 100, 101, 104, 105, 106, 107, 110, 112, 114, 117, 118, 119, 130, 133, 136, 139, 142, 146, 149, 163, 164, 165, 168, 171, 174, 178, 181, 182, 183, 184, 260, 261, 265, 267, 270, 271, 272, 273, 276, 277, 278, 291, 294, 297, 299, 302, 308, 311, 323, 326, 327, 331, 334, 335, 336, 340, 341, 342, 355, 358, 361, 363, 366, 372, 374, 388, 389, 394, 398, 399, 400, 401, 404, 407, 462, 464, 526, 527, 528, 557, 561, 1028
	retryText: .word 609, 610, 611, 615, 616, 617, 618, 621, 622, 623, 626, 627, 628, 632, 634, 637, 638, 641, 644, 647, 654, 658, 661, 664, 666, 671, 673, 674, 675, 679, 680, 681, 686, 690, 691, 691, 696, 697, 698, 701, 702, 705, 707, 711, 718, 722, 724, 729, 737, 740, 743, 744, 745, 746, 750, 754, 757, 761, 765, 779, 780, 781, 782, 783, 784, 785, 786, 811, 818, 843, 846, 847, 848, 850, 875, 877, 882, 907, 910, 911, 914, 939, 944, 946, 971, 973, 974, 975, 978, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1028
#################^^^^^Positions^^^^^################################################
.text 
run: #resets values
	addi $t0, $zero, 814
	sw $t0, blasterLocation
	sw $zero, lastCentLocation
	sw $t0, bulletLocation
	sw $zero, bulletActive
	addi $t0, $zero, 3
	sw $t0, centipedeLives
	addi $t0, $zero, 1
	sw $t0, drawCent
	addi $t0, $zero, -1
	sw $t0, fleaPosition
	lw $t0, centipedeColorPlaceHolder
	sw $t0, centipedeColor
	 
	add $t1, $zero, $zero #centLoop counter
	addi $t3, $zero, 1
	
buildCentLoop:
	beq $t1, 10, endBuildLoop
	sll $t2, $t1, 2
	sw $t1, centLocation($t2)
	sw $t3, centDirection($t2)
	sw $zero, annoyArray($t2)
	sw $zero, recentMushroom($t2)
	addi $t1, $t1, 1
	j buildCentLoop
	
endBuildLoop:
	
	
	li	$v0, 30		# get time in milliseconds
	syscall

	move	$t0, $a0	#gets time

	li	$a0, 1		# random generator (was a0)
	move 	$a1, $t0	# update time (was a1)
	li	$v0, 40		# load seed (was v0)
	syscall
	
	#sw $t1, 0($t0) #paint top left pixel red
	#sw $t2, 4($t0) #paint next pixel on top row green
	#sw $t3, 128($t0) # paint first pixel on row 2 blue
drawBackground:
	lw $t0, displayAddress #top left corner
	addi $t1, $t0, 4096 #bottom right corner (also end condition of loop)
	lw $t2, backgroundColor #load dirt color
	lw $t3, blasterColor
	addi $t4, $t0, 3256
STARTBACKGROUND: 
	sw $t2, 0($t0) #set current pixel to the background color
	addi $t0, $t0, 4 #iterates to next position
	blt $t0, $t1, STARTBACKGROUND
	sw $t3, 0($t4)
	

########################################

generateMushrooms:
	lw $s0, mushroomCount
	add $t1, $zero, $s0 #max value of mushrooms
	lw $t0, displayAddress 
	add $t2, $zero, $zero #t2 is our loop counter
	add $t3, $zero, $zero #t3 is our index counter
	lw $t4, mushroomColor
	addi $t6, $zero, 4
	
mushLoop:
	beq $t1, $t2, mushEnd #if loop counter == 32, end loop
	jal generateRandomPosition #store random position in v0
	slti $t5, $a0, 10 #Checks if in first few spots
	beq $t5, 1, mushLoop#if in first 10 spots, try again
	sge $t5, $a0, 960
	beq $t5, 1, mushLoop#if on bottom 2 rows, try again
	div $a0, $t1
	mfhi $t5
	beq $t5, 0, mushLoop #if on left edge, try again
	sw $a0, mushroomArray($t3)#store position
	mult $a0, $t6
	mflo $a0
	add $a0, $a0, $t0
	sw $t4, 0($a0) #set the mushroom's position to mushroom color
	
mushIterate:
	addi $t2, $t2, 1 #iterate loop counter
	addi $t3, $t3, 4 #iterate index counter
	j mushLoop
	
mushEnd:		
				
########################################				
						
							
									
Loop:
	jal displayCent
	jal input
	jal centCollide
	jal bulletMove
	jal centMove
	jal fleaTime
	jal fleaUpdate
	jal refreshMushrooms
	jal delay
	
	j Loop
	
Exit: 
	jal drawEnd
	jal paintGameOver
	jal paintRetry

exitLoop:
	jal input
	j exitLoop

endGame:
	li $v0, 10
	syscall
	
#########################################

drawEnd:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $t0, displayAddress #top left corner
	addi $t1, $t0, 4096 #bottom right corner (also end condition of loop)
	lw $t2, backgroundColor #load end color
	addi $t4, $t0, 3256
STARTDRAW: 
	sw $t2, 0($t0) #set current pixel to the end screen color
	addi $t0, $t0, 4 #iterates to next position
	blt $t0, $t1, STARTDRAW
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

########################################

paintGameOver:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, displayAddress
	lw $t1, centipedeHeadColor
	add $t3, $zero, $zero #index counter
	
paintGameOverLoop:
	lw $t2, gameOverText($t3)
	bge $t2, 1024, paintGameOverEnd #Arbitrary largest value
	sll $t2, $t2, 2 #switch to word alligned
	add $t2, $t2, $t0 #shift to display address
	sw $t1, 0($t2) #paint position as centipedeHeadColor (our text color)
	addi $t3, $t3, 4
	j paintGameOverLoop
	
paintGameOverEnd:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
########################################

paintRetry:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, displayAddress
	lw $t1, centipedeHeadColor
	add $t3, $zero, $zero #index counter
	
paintRetryLoop:
	lw $t2, retryText($t3)
	bge $t2, 1024, paintRetryEnd #Arbitrary largest value
	sll $t2, $t2, 2 #switch to word alligned
	add $t2, $t2, $t0 #shift to display address
	sw $t1, 0($t2) #paint position as centipedeHeadColor (our text color)
	addi $t3, $t3, 4
	j paintRetryLoop
	
paintRetryEnd:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

########################################

refreshMushrooms:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	add $t3, $zero, $zero #loop counter t3
	lw $t1, mushroomColor
refreshLoop:
	lw $t0, mushroomCount
	addi $t0, $t0, -1
	sll $t0, $t0, 2
	bge $t3, $t0, endRefresh
	lw $t0, displayAddress
	lw $t2, mushroomArray($t3)
	sll $t2, $t2, 2
	add $t2, $t2, $t0
	sw $t1, 0($t2)
	addi $t3, $t3, 4
	j refreshLoop
	
endRefresh:	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	

#########################################

fleaTime:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0 fleaPosition
	bne $t0, -1, fleaTimeEnd
	jal fleaGen #get flea odds in a0
	bne $a0, 1, fleaTimeEnd #if we didn't generate 1, we dont get to spawn the flea
	jal generateRandomFlea #get the flea's position
	sw $a0, fleaPosition
	
fleaTimeEnd:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

#########################################

fleaUpdate:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t4, backgroundColor
	lw $t0, displayAddress
	lw $t1, fleaPosition
	beq $t1, -1, fleaUpdateEnd #if flea not alive yet, dont draw it (duh)
	lw $t2, fleaColor
	sll $t3, $t1, 2 #t3 is the position translated into display address pixels (x4)
	add $t3, $t3, $t0 #t3 is now a position in the display
	sw $t2, 0($t3) #draw flea
	addi $t3, $t3, -128 #last position
	sw $t4, 0($t3) #draw last position as background color
	lw $t5, blasterLocation
	beq $t5, $t1, fleaBlasterCollision
	sge $t6, $t1, 1024
	beq $t6, 1, fleaKill
	addi $t1, $t1, 32
	sw $t1, fleaPosition
	j fleaUpdateEnd
	
fleaKill:
	sll $t9, $t1, 2
	add $t9, $t9, $t0
	sw $t4, 0($t9)
	addi $t8, $zero, -1
	sw $t8, fleaPosition
	j fleaUpdateEnd
	
fleaBlasterCollision:
	j Exit
	
fleaUpdateEnd:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	

#########################################	
	
displayCent:
	#moves stack pointer 1 word and pushed the return address onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	addi $a3, $zero, 10 #10 is the size of the centipede, a3 is the loop variable
	lw $t3 centipedeColor #t3 stores centipede color
	lw $t0 displayAddress #t0 stores display location
	la $a1, centLocation
	la $a2, centDirection
	lw $t7 backgroundColor
	sw $t7, 0($t0)
segmentLoop:
	lw $t1, 0($a1) #t1 stores current centLocation
	lw $t2, 0($a2) #t2 stores current centDirection
	

	jal decideColor
	
	sll $t4, $t1, 2 #shift the bug location one pixel
	add $t4, $t0, $t4 #t4 is now the address of the old bug location
	
	sw $t3, 0($t4) #paint w/ centipede color
	
	addi $a1, $a1, 4 #switch to next body piece location
	addi $a2, $a2, 4 #switch to next body piece direction
	addi $a3, $a3, -1 #decrement loop counter
	bne $a3, $zero, segmentLoop
	
	lw $t6, lastCentLocation
	
	sll $t4, $t6, 2 #shift the bug location one pixel
	add $t4, $t0, $t4 #t4 is now the address of the old bug location
	sw $t7, 0($t4) #paint w/ background color
	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
decideColor:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	beq $a3, 1, headColor
	j headEnd

	
headColor:
	lw $t3 centipedeHeadColor

headEnd:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
#########################################

input:
	addi $sp, $sp -4
	sw $ra, 0($sp)
	
	lw $t8, 0xffff0000
	beq $t8, 1, parseInput
	addi $sp, $sp, 4
	
	jr $ra
	
parseInput: 
	addi $sp, $sp -4
	sw $ra, 0($sp)
	
	lw $t2, 0xffff0004
	addi $v0, $zero, 0
	beq $t2, 0x6A, j_press
	beq $t2, 0x6B, k_press
	beq $t2, 0x78, x_press
	beq $t2, 0x73, s_press
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
#########################################	
	
j_press:
	addi $sp, $sp -4
	sw $ra, 0($sp)
	
	la $t2 blasterLocation #load blaster location from memory
	lw $t1, 0($t2) #store the location in t1
	
	lw $t0, displayAddress #t0 stores display location
	lw $t3, backgroundColor #replace background color
	
	sll $t4, $t1, 2 
	add $t4, $t0, $t4 #t4 is the old bug location
	sw $t3, 0($t4) #paint a placeholder (top right) the blaster color
	
	beq $t1, 800, hitWall
	addi $t1, $t1, -1 #blaster moves 1 to the left
hitWall: 
	sw $t1, 0($t2) #save bugs location
	
	lw $t3, blasterColor
	
	sll $t4, $t1, 2
	add $t4, $t0, $t4
	sw $t3, 0($t4)
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
#########################################		
	
k_press:
	addi $sp, $sp -4
	sw $ra, 0($sp)
	
	la $t2 blasterLocation #load blaster location from memory
	lw $t1, 0($t2) #store the location in t1
	
	lw $t0, displayAddress #t0 stores display location
	lw $t3, backgroundColor #replace background color
	
	sll $t4, $t1, 2 
	add $t4, $t0, $t4 #t4 is the old bug location
	sw $t3, 0($t4) #paint blaster in original position
	
	beq $t1, 831, hitWall2
	addi $t1, $t1, 1 #blaster moves 1 to the right
hitWall2: 
	sw $t1, 0($t2) #save bugs location
	
	lw $t3, blasterColor
	
	sll $t4, $t1, 2
	add $t4, $t0, $t4
	sw $t3, 0($t4)
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
#########################################	
	
x_press:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $t6, bulletActive
	beq $t6, 1, x_pressEnd
	addi $t5, $zero, 1
	sw $t5, bulletActive
	
	lw $t4, blasterLocation
	addi $t4, $t4, -32
	sw $t4, bulletLocation
	
x_pressEnd:

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
#########################################	

s_press:
	addi $v0, $zero, 4
	j run

#########################################

centMove:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $t0, centipedeLives
	beqz $t0, centiEnd
	addi $a3, $zero, 10 #10 is the size of the centipede, a3 is the loop variable
	#la $a1, centLocation #a1 stores location vector
	#la $a2, centDirection #a2 stores direction vector
	add $t3, $zero, $zero #counter i = 0
	addi $t4, $zero, 10 #cap of 9
	addi $t5, $zero, 0 #t5 is location index
	lw $t8, centLocation($t5)
	sw $t8, lastCentLocation
	
centiLoop:
	beq $t3, $t4, centiEnd
	
	lw $t6, centLocation($t5) #get value of centLocation at t5
	lw $t9, centDirection($t5) #get value of centDirecction at t5
	add $t6, $t6, $t9 #add 1 to it (one pixel)
	sw $t6, centLocation($t5) #re-store it at inxed t5
	addi $t5, $t5, 4 #move to next index
	
	addi $t3, $t3, 1
	
	j centiLoop
centiEnd:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

#########################################

centCollide:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	add $t2, $zero, $zero #t2 is our loop counter here
	addi $t3, $zero, 10 #t3 is our end condition
	add $t5, $zero, $zero #t5 is our index counter here
	addi $t4, $zero, 1 #first if condition (moving left)
	addi $t6, $zero, 31 #t6 is our condition to turn if on right
	addi $t7, $zero, 32 #t7 is our condition to turn if on left
	addi $t8, $zero, -1 #t8 is our condition for left direction
	add $s2, $zero, $zero #1 if we have experienced an annoyance
	
centCollideLoop: #we have 5 possible cases: left and left edge || down and left edge || right and right edge || down and right edge || not edge
	beq $t2, $t3, centCollideEnd #loop condition
	lw $a0, centLocation($t5) #get value of centLocation at t5
	lw $a1, centDirection($t5) #get value of centDirecction at t5
	lw $a2, annoyArray($t5) #check annoyance value
	lw $t9, blasterLocation
	beq $t9, $a0, Exit
	addi $t9, $a0, 1
	div $t9, $t7
	mfhi $t0 # t0 = position + 1 % 32
	bne $a2, 0, annoyLength
	jal updateAnnoyCounter
	beq $a0, $zero, iterateCollideLoop #if at first position, dont do anything
	bne $t0, $zero notEnd #if position + 1 % 32 != 0 move to notEnd
	bne $a1, $t4, notRight #if direction != 1, move to notRight
	#case here: right and right edge
	sge $t0, $a0, 992
	beq $t0, 1, bottomRight
	addi $a1, $zero 32 #a1 is new value of centDirection at t5
	sw $a1, centDirection($t5) #update centDirection
	j iterateCollideLoop
	 
bottomRight:
	addi $a1, $zero -32 #a1 is new value of centDirection at t5
	sw $a1, centDirection($t5) #update centDirection
	j iterateCollideLoop

notRight: #Includes: down and right edge
	addi $a1, $zero, -1
	sw $a1, centDirection($t5)
	j iterateCollideLoop

notEnd: #left and left edge || down and left edge || not an edge || up and left edge (annoyance)
	bne $t0, 1, notEdge #Past here: left and left edge || down and left edge || up and left edge
	bne $a1, $t8, leftDown #past here: left and left edge
	addi $a1, $zero 32 #a1 is new value of centDirection at t5
	sw $a1, centDirection($t5) #update centDirection
	j iterateCollideLoop
	
leftDown: #down and left edge || up and left edge
	slti $s0, $a0, 992
	beq $s0, $zero, annoyance #if on last row, go to annoyance
	bne $a1, $t7, leftUp
	addi $a1, $zero, 1
	sw $a1, centDirection($t5)
	j iterateCollideLoop
	
leftUp:
	addi $a1, $zero, 1
	sw $a1, centDirection($t5)
	j iterateCollideLoop
	
annoyance: #a3 counts how long we annoy for 
	addi $a1, $zero, -32
	sw $a1, centDirection($t5)
	addi $s4, $zero, 36 ######################
	lw $s7, centLocation($s4)
	bne $a0, $s7, annoyEnd
	jal generateRandomAnnoyance
	
annoyEnd:
	sw $s6, annoyArray($t5)
	addi $s2, $s2, 1
	j iterateCollideLoop

notEdge:
	jal mushroomCollision
	j iterateCollideLoop
	
iterateCollideLoop:
	addi $t2, $t2, 1 #iterate loop counter
	addi $t5, $t5, 4 #iterate index counter
	j centCollideLoop
	
annoyLength:
	addi $a2, $a2, -1
	sw $a2, annoyArray($t5)
	j iterateCollideLoop
	
updateAnnoyCounter:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
 
	lw $s7, annoyArray($zero)
	bne $s7, $zero, updateAnnoyEnd
	add $s2, $zero, $zero

updateAnnoyEnd:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
centCollideEnd:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

#########################################
   
mushroomCollision:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	add $t6, $zero, $zero #t6 is our loop counter
	lw $t8, mushroomArray($t6)
	lw $t9, recentMushroom($t5)
	jal finishShroom
	  
mushroomCollisionLoop:
	lw $s7, mushroomCount
	addi $s7, $s7, -1
	sll $s7, $s7, 2
	beq $t6, $s7, mushroomCollisionEnd
	lw $t8, mushroomArray($t6)
	lw $t9, recentMushroom($t5)
	add $s5, $a0, $a1 #a5 is now the position in one loop
	bne $t8, $s5, mushroomCollisionIterate #if thats not a mushroom, go next
	beq $a1, 1 mushRight
	beq $a1, -1 mushLeft
	beq $a1, 32, mushDown
	addi $s0, $zero, 1
	sw $s0, centDirection($t5)
	j mushroomCollisionIterate
	 
mushRight:
	addi $s0, $zero, 32
	sw $s0, centDirection($t5)
	addi $s0, $zero, 1 #1 is the case for going from right to left
	sw $s0, recentMushroom($t5)
	#j mushroomCollisionIterate
	j mushroomCollisionEnd

mushLeft:
	addi $s0, $zero, 32
	sw $s0, centDirection($t5)
	addi $s0, $zero, 2 #2 is the case for going from right to left
	sw $s0, recentMushroom($t5)
	#j mushroomCollisionIterate
	j mushroomCollisionEnd

mushDown:
	addi $s0, $zero, -1
	sw $s0, centDirection($t5)
	add $s0, $zero, $zero
	sw $zero, recentMushroom($t5)
	#j mushroomCollisionIterate
	j mushroomCollisionEnd
	
	
mushroomCollisionIterate:
	addi $t6, $t6, 4
	j mushroomCollisionLoop
	
	
mushroomCollisionEnd:
	#####Reload values#####
	addi $t6, $zero, 31 #t6 is our condition to turn if on right
	addi $t7, $zero, 32 #t7 is our condition to turn if on left
	addi $t8, $zero, -1 #t8 is our condition for left direction
	#####Values Reloaded###
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	 
########################################

finishShroom:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	beq $t9, 0, shroomEnd
	beq $t9, 2, shroomOnLeft
	
	addi $s0, $zero, -1
	sw $s0, centDirection($t5)
	add $s0, $zero, $zero #reset value
	sw $s0, recentMushroom($t5)
	j shroomEnd
	
shroomOnLeft:
	addi $s0, $zero, 1
	sw $s0, centDirection($t5)
	add $s0, $zero, $zero #reset value
	sw $s0, recentMushroom($t5)
	j shroomEnd
	
shroomEnd:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
#########################################

bulletMove:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $t5, bulletColor  
	lw $t6, backgroundColor
	lw $t0, displayAddress
	lw $t3, bulletActive # if t0 == 1, bullet is active, else, it is inactive
	bne $t3, 1, bulletMoveEnd #if bullet isn't active, don't do anything
	lw $t1, bulletLocation
	sll $t4, $t1, 2 #convert to proper size (pixels)
	add $t0, $t0, $t4 #move to last bullet position
	sw $t6, 0($t0) #color old location w/ background
	lw $t0, displayAddress #reload displayAddress
	lw $t1, bulletLocation #reload bulletLocation
	jal bulletMushroomCollision
	jal bulletCentipedeCollision
	jal bulletFleaCollision
	blt $t1, 32, bulletDeactivate
	
	addi $t1, $t1, -32
	j drawBullet
	
bulletDeactivate:
	sw $zero, bulletActive
	addi $t1, $zero, -1

drawBullet:
	sw $t1, bulletLocation
	sll $t4, $t1, 2
	add $t0, $t0, $t4
	sw $t5, 0($t0)
	
bulletMoveEnd:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
###################################################
	
bulletMushroomCollision:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	add $t7, $zero, $zero #t7 will be our loop counter

bulletMushroomCollisionLoop:
	lw $t9, mushroomCount
	addi $t9, $t9, -1
	sll $t9, $t9, 2
	beq $t7, $t9, bulletMushroomCollisionEnd #124 is the last position in the array
	lw $t8, mushroomArray($t7) #t8 stores the current mushroom's position
	bne $t1, $t8 bulletMushroomCollisionIterate #if bullet doesn't hit a mushroom, go next
	addi $t1, $zero, -1
	sw $t1, mushroomArray($t7) #This mushroom is now deleted
	add $t1, $zero, $zero
	j bulletMushroomCollisionEnd
	
bulletMushroomCollisionIterate:
	addi $t7, $t7, 4
	j bulletMushroomCollisionLoop
	

bulletMushroomCollisionEnd:	

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
#########################################
 
bulletCentipedeCollision:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	add $t7, $zero, $zero #t7 will be our loop counter

bulletCentipedeCollisionLoop:
	beq $t7, 40, bulletCentipedeCollisionEnd #40 is the last position in the array
	lw $t8, centLocation($t7) #t8 stores the current centipede segment location
	bne $t1, $t8 bulletCentipedeCollisionIterate #if bullet doesn't hit a centipede, go next
	lw $t9, centipedeLives
	addi $t9, $t9, -1
	beq $t9, 2, centipedeTwoLife
	beq $t9, 1, centipedeOneLife
	beq $t9, 0, centipedeDead
	
afterDeadCheck:
	sw $t9, centipedeLives
	add $t1, $zero, $zero
	j bulletCentipedeCollisionEnd
	
bulletCentipedeCollisionIterate:
	addi $t7, $t7, 4
	j bulletCentipedeCollisionLoop
	
bulletCentipedeCollisionEnd:	

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
centipedeTwoLife:
	lw $s0, twoLifeColor
	sw $s0, centipedeColor
	j afterDeadCheck

centipedeOneLife:
	lw $s0, oneLifeColor
	sw $s0, centipedeColor
	j afterDeadCheck

centipedeDead:
	jal killCentipede
	j afterDeadCheck
	
########################################

bulletFleaCollision:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	lw $t7, fleaPosition #t7 holds the flea's position
	bne $t1, $t7, bulletFleaCollisionEnd #if flea hasn't collided with bullet, skip
	lw $t8, backgroundColor
	sll $t7, $t7, 2
	add $t7, $t7, $t0
	sw $t8, 0($t7) #paint flea position to background
	addi $t7, $t7, 128
	sw $t8, 0($t7) #paint flea position to background
	addi $t7, $t7, -256
	sw $t8, 0($t7) #paint flea position to background
	addi $t7, $zero, -1
	sw $t7, fleaPosition #kill flea
	add $t1, $zero, $zero #kill bullet
	
bulletFleaCollisionEnd:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra	

########################################

killCentipede:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	add $t1, $zero, $zero #our loop/index counter
	addi $t2, $zero, -1
	lw $t5, backgroundColor
	
killCentipedeLoop:
	beq $t1, 40, killCentipedeEnd #40 is the last position in the array
	lw $t0, displayAddress
	lw $t3, centLocation($t1)
	sll $t4, $t3, 2
	add $t4, $t4, $t0
	sw $t5, 0($t4)
	sw $t2, centLocation($t1)
	addi $t1, $t1, 4
	j killCentipedeLoop
	
killCentipedeEnd:

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	

##################~~~THE RANDOM ZONE~~~######################
#results are stored in $a0
generateRandomAnnoyance: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $a0, 1
	li $a1, 9  #a1 is max bound
	li $v0, 42  #generates the random number.
	syscall
	add $s6, $a0, $zero
	ble, $s6, 1, forgeTheNumbers
	#Try setting it to 3 when its 0 or 1
	j endRandAnnoy
	
forgeTheNumbers:
	addi $s6, $zero, 3
endRandAnnoy:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
###########################################

generateRandomPosition:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $a0, 1
	li $a1, 1024  #a1 is max bound
	li $v0, 42  #generates the random number.
	syscall
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
####################################

generateRandomFlea:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $a0, 1
	li $a1, 31  #a1 is max bound
	li $v0, 42  #generates the random number.
	syscall
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
####################################
	
fleaGen:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t0, fleaGenOdds
	li $a0, 1
	la $a1, ($t0)  #a1 is max bound
	li $v0, 42  #generates the random number.
	syscall
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
##################~~~END RANDOM ZONE~~~######################

delay:
	# move stack pointer a work and push ra onto it
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $a2, gameSpeed
	
delayLoop:
	addi $a2, $a2, -1
	bgtz $a2, delayLoop
	
	# pop a word off the stack and move the stack pointer
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

