# out-of-order-processor-for-riscv
This is a two-issue out-of-order processor for TinyRV2. It contains ten stages, as descripted as follow:
1. instruction fetch: TODO
2. instruction decode
3. register renaming: we use unified physical register file for register renaming. It contains a renaming table and a freelist. Plus there is an architecture renaming table which are only updated when instructions are retired, so the the contents are always correct.
4. instruction dispatch
5. issue queue: there are three issue queues: alu, jmp and lsq. instructions in alu queue can be issued out-of-order; those in jmp and only be issued if the previous one is dealt correctly (in execution stage if prefict right or in commit stage if mispredict)
6. register file read stage
7. executinon stage
8. memory stage: TODO
9. write back stage
10. commit stage
