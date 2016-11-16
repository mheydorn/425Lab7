#####################################################################
# ECEn 425 Lab 3 Makefile

lab4.bin:	lab4final.s
		nasm lab4final.s -o lab4.bin -l lab4.lst

lab4final.s:	clib.s myisr.s myinth.s lab4_app.s yaksc.s
		cat clib.s myisr.s myinth.s lab4_app.s yaksc.s yaks.s > lab4final.s

myinth.s:	myinth.c
		cpp myinth.c myinth.i
		c86 -g myinth.i myinth.s

lab4_app.s:	lab4_app.c
		cpp lab4_app.c lab4_app.i
		c86 -g lab4_app.i lab4_app.s

yaksc.s:	yakc.c 
		cpp yakc.c yak.i
		c86 -g yak.i yaksc.s

clean:
		rm lab4.bin lab4.lst lab4final.s myinth.s myinth.i yak.i yaksc.s \
		lab4_app.s lab4_app.i
