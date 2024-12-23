#!/bin/bash

function initfile {
  rm -f ts/* dist/*
}

# arg1: main記述モジュール規格[esm,cjs]
# arg2: main拡張子[.mts,.cts]
# arg3: module記述モジュール規格[esm,cjs]
# arg4: module拡張子[.mts,.cts]
function settingmodules {
  settingModule main $1 $2
  settingModule Module $3 $4
}

# arg1: ファイル名[main,Module]
# arg2: 記述モジュール規格[esm,cjs]
# arg3: 拡張子[.mts,.cts]
function settingModule {
  FILE=$1
  MODULE=$2
  EXTEND=$3
  ORG_EXTEND=".cjs"
  if [ $MODULE == "esm" ]; then
    ORG_EXTEND=".mts"
  fi
  cp org/${FILE}${ORG_EXTEND} ts/${FILE}${EXTEND}

  #main
  if [ $FILE == "main" ]; then
    sed -Ei "s/module/Module${EXTEND//t/j}/" ts/${FILE}${EXTEND}
  fi
}

# arg1: running module[module,commonjs]
# arg2: tsconfig.module[e:esnext, n:nodenext, c:commonjs]
# arg3: tsconfig.moduleresolution[n:nodenext, :none]
function tsc {
  RUN_MODULE=$1
  MODULE=$2
  MODULE_RESOL=$3
  sed -Ei "s/(\"type\": ).*/\1\"${RUN_MODULE}\",/" package.json
  npm run "tsc:${MODULE}${MODULE_RESOL}"
}
