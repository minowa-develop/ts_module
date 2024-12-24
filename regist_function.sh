#!/bin/bash

function initfile {
  rm -f ts/* dist/* test/*
}

# arg1: main記述モジュール規格[esm,cjs]
# arg2: main拡張子[.mts,.cts]
# arg3: module記述モジュール規格[esm,cjs]
# arg4: module拡張子[.mts,.cts]
# arg5: running module[module,commonjs]
# arg6: tsconfig.module[e:esnext, n:nodenext, c:commonjs]
# arg7: tsconfig.moduleresolution[n:nodenext, 0:none]
# arg8: test no
function check {
  rm -f dist/* ts/*
  settingFile main $1 $2
  settingFile Module $3 $4
  injectionImport $2 $4
  # validate $@; # debug
  if ! validate $@; then return 1; fi
  tsc ${5} ${6} ${7}  > "./test/${8}_comp_result" 2>&1 && \
  node dist/main${2//t/j} > "./test/${8}_run_result" 2>&1
  # grep -H err "./test/${8}_comp_result" # debug 漏れ確認
}

# arg1: ファイル名[main,Module]
# arg2: 記述モジュール規格[esm,cjs]
# arg3: 拡張子[.mts,.cts]
function settingFile {
  FILE=$1
  MODULE=$2
  EXTEND=$3

  ORG_EXTEND=".cts"
  if [ $MODULE == "esm" ]; then
    ORG_EXTEND=".mts"
  fi
  cp org/${FILE}${ORG_EXTEND} ts/${FILE}${EXTEND}
}
# arg1: main拡張子[.mts,.cts]
# arg1: module拡張子[.mts,.cts]
function injectionImport {
  sed -Ei "s/module/Module${2//t/j}/" ts/main${1}
}

# arg1: running module[module,commonjs]
# arg2: tsconfig.module[e:esnext, n:nodenext, c:commonjs]
# arg3: tsconfig.moduleresolution[n:nodenext, 0:none]
function tsc {
  RUN_MODULE=$1
  MODULE=$2
  MODULE_RESOL=$3
  if [ ${MODULE_RESOL} == "0" ]; then
    MODULE_RESOL=""
  fi
  sed -Ei "s/(\"type\": ).*/\1\"${RUN_MODULE}\",/" package.json
  npm run "tsc:${MODULE}${MODULE_RESOL}"
}


function validate {
  #  echo $@ # debug
  # validate for ts
  if [ $7 == "n" ] && [ $6 != "n" ]; then
    echo "${8} TS5110"
    return 1
  fi
  if [ $6 == "n" ] && [ $1 == "esm" ] && [ $2 == ".cts" ] && [ $4 == ".mts" ]; then
    echo "${8} TS1479"
    return 1
  fi
  if [ $1 == "esm" ] && [ $3 == "cjs" ]; then
    echo "${8} TS2459"
    return 1
  fi
}