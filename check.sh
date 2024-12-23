#!/bin/bash

# arg1: main記述モジュール規格[esm,cjs]
# arg2: main拡張子[.mts,.cts]
# arg3: module記述モジュール規格[esm,cjs]
# arg4: module拡張子[.mts,.cts]
# arg5: running module[module,commonjs]
# arg6: tsconfig.module[e:esnext, n:nodenext, c:commonjs]
# arg7: tsconfig.moduleresolution[n:nodenext, 0:none]
# arg8: test no

# no1
check esm .mts esm .mts module e n 1
