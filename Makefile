all: output.s

output.s: riscv-macros.rkt
	racket riscv-macros.rkt > output.s