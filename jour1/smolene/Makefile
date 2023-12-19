chal : f.nasm
	nasm -f elf32 f.nasm -o f.o
	ld --omagic -m elf_i386 f.o -o chal

run : chal
	cat lips - | ./chal 3< 1_input

