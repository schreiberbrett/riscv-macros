# riscv-macros

A Typed Racket interface for generating RISC-V assembly.


Given a list of instructions and macros, each macro expands into multiple base instructions.


## Calling Convention

Racket's lexical scope allows passing register names, immediates, even labels as variables. Types can help here so that an immediate is never passed into a function where a register is expected.

This can be taken a step further to encode the calling convention directly in the type system. It is known that, when a subroutine is performed, it reads from certain registers, writes to certain registers, and stores return values in certain registers. Each variable passed to a macro must have some combination of whether or not it is read, written to, or returned from.

Enumerating all possibilities gives 5 valid cases.

| Read from? | Written to? | Holds return value? | Analysis                                             |
|------------|-------------|---------------------|------------------------------------------------------|
| Yes        | Yes         | Yes                 | Case `ReadReturn`                                    |
| Yes        | Yes         | No                  | Case `ReadWrite`                                     |
| Yes        | No          | Yes                 | Impossible case: cannot return without writing first |
| Yes        | No          | No                  | Case `ReadOnly`                                      |
| No         | Yes         | Yes                 | Case `ReturnOnly`                                    |
| No         | Yes         | No                  | Case `Scratch`                                       |
| No         | No          | Yes                 | Impossible case: cannot return without writing first |
| No         | No          | No                  | Impossible case: must have at least one role         |

This information could be put as a comment or encoded in the type system. See also the concept of in/out parameters in Prolog and Mercury.