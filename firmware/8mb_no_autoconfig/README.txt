8mb NON-autoconfiguring version.

It is practically useless except for testing memory chips. If normal versions
fail to start, try this, then run in debugger simple code sequence like this:

	lea	$200000,a0

	moveq	#0,d0
	moveq	#1,d1
	move.l	a0,a1

label1:
	move.l	d1,(a1)+
	rol.l	#1,d1
	subq.b	#1,d0
	bne.s	label1


	move.l	a0,a1
label2:
	move.l	(a1)+,d1

	subq.b	#1,d0
	bne.s	label2


	rts

Manually examine read value in label2 loop. If it not
1-2-4-...-$80000000-1-2-... etc. sequence or machine fails during reading
(this was my case once), you have bad memory chip (provided you checked all
signals going to board with oscilloscope or logic probe). Try a0 with $200000,
$400000,$600000 and $800000 values thus checking all the chips.

The addressing of memory chips in 8Mb mode is from left to right: most left
chip occupies $200000-#3fffff, next $400000-$5fffff and so on. In 4Mb mode,
most right chip is at $400000-$5fffff, adjacent is at $200000-$3fffff.


NOTE: if the memory chip doesn't drive data bus at all or is absent, you will
see in d1 the opcode of next command. This is because 68000 does PREfetching
before starting to execute command just fetched (and this is not fully
documented). After a prefetch, 68000 starts reading of $20xxxx address, where
databus is not driven by anything, and therefore holds previous value for
some time. Try movem.l (a0),d0-d7/a1-a6 to see how databus decays.


