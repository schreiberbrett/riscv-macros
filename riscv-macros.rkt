#lang typed/racket
(define zero "zero")
(define a0 "a0")
(define a1 "a1")
(define t0 "t0")
(define t1 "t1")

(define-type IntRegister String)
(define-type Register String)
(define-type Immediate Integer)

(struct Label ([n : Integer]))

(struct LabelDecl ([l : Label]))
(struct J ([l : Label]))
(struct Rem ([r0 : IntRegister] [r1 : IntRegister] [r2 : IntRegister]))
(struct Bne ([x : Register] [y : Register] [l : Label]))
(struct Add ([r0 : Register] [r1 : Register] [r2 : Register]))
(struct Addi ([r0 : Register] [r1 : Register] [imm : Immediate]))
(struct Ecall ())

(define-type Instruction (U LabelDecl
                            J
                            Rem
                            Bne
                            Add
                            Addi
                            Ecall))

(: L (-> Label (Listof Instruction)))
(define (L l)
  (list (LabelDecl l)))

(: j (-> Label (Listof Instruction)))
(define (j l)
  (list (J l)))

(: rem (-> IntRegister IntRegister IntRegister (Listof Instruction)))
(define (rem x y z)
  (list (Rem x y z)))

(: bne (-> Register Register Label (Listof Instruction)))
(define (bne x y L)
  (list (Bne x y L)))

(: add (-> Register Register Register (Listof Instruction)))
(define (add x y z)
  (list (Add x y z)))

(: addi (-> Register Register Immediate (Listof Instruction)))
(define (addi x y i)
  (list (Addi x y i)))

(: ecall (-> (Listof Instruction)))
(define (ecall)
  (list (Ecall)))

(: gen-label (-> Label))
(define n -1)
(define (gen-label)
  (set! n (+ 1 n))
  (Label n))

(: mv (-> Register Register (Listof Instruction)))
(define (mv x y)
  (append (add  x zero y)))

(: mvi (-> Register Immediate (Listof Instruction)))
(define (mvi x i)
  (append (addi x zero i)))

;; Clobbers t0
;; Reads: a, b (to compute GCD from
;; Clobbers: a, b, tmp
;; Returns in: a

;; ReadReturn: a
;; ReadClobber: b
;; Clobber: tmp
(: gcd (-> Register Register Register (Listof Instruction)))
(define (gcd a b tmp)
  (let ((TOP (gen-label))
        (ENTRY (gen-label)))
    
    (append (j ENTRY)

            (L TOP)
            (mv tmp a)
            (mv a b)
            (rem b tmp b)
                  
            (L ENTRY)
            (bne b zero TOP))))


(: print-int (-> Register (Listof Instruction)))
(define (print-int x)
  (append (mv a1 x)
          (addi a0 zero 1)
          (ecall)))

(: print-string (-> Register (Listof Instruction)))
(define (print-string x)
  (append (mv a1 x)
          (addi a0 zero 4)
          (ecall)))

(: main (-> (Listof Instruction)))
(define (main)
  (append (mvi a0 50)
          (mvi a1 40)
          (gcd a0 a1 t0)
          (print-int a0)

          (mvi a0 500)
          (mvi a1 400)
          (gcd a0 a1 t0)
          (print-int a0)))

(: compile (-> (Listof Instruction) String))
(define (compile instructions)
  (string-join
   (map (lambda (instruction)
          (match instruction
            ((Rem x y z) (string-append "\trem " x " " y " " z))
            ((Add x y z) (string-append "\tadd " x " " y " " z))
            ((Addi x y i) (string-append "\taddi " x " " y " " (number->string i)))
            ((Bne x y (Label n)) (string-append "\tbne " x " " y " L" (number->string n)))
            ((J (Label n)) (string-append "\tj L" (number->string n)))
            ((Ecall) "\tecall")
            ((LabelDecl (Label n)) (string-append "L" (number->string n) ":")))) instructions)
   "\n"))


(displayln (compile (main)))