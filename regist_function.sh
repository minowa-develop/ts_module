#!/bin/bash

# arg1: main記述モジュール規格[esm,cjs]
# arg2: main拡張子[.mts,.cts]
# arg3: module記述モジュール規格[esm,cjs]
# arg4: module拡張子[.mts,.cts]
# arg5: running module[module,commonjs]
# arg6: tsconfig.module[e:esnext, n:nodenext, c:commonjs]
# arg7: tsconfig.moduleresolution[n:nodenext, 0:none]
# arg8: test no
function check {
  # init
  rm -f dist/* ts/*

  # settings
  settingFile main $1 $2
  settingFile Module $3 $4
  injectionImport $2 $4

  # debug
  validate $@ >> tmp

  # compile and run
  tsc ${5} ${6} ${7} > "./test/${8}_comp_result" 2>&1 && \
  node dist/main${2//t/j} > "./test/${8}_run_result" 2>&1

  # analyze
  analize $@
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
    # tsconfigのmoduleresolutionをnodenextにしたらmoduleも同じにする
    echo "TS5110"
    return 1
  fi

  MSG=""
  if [ $6 == "n" ] && [ $1 == "esm" ] && [ $2 == ".cts" ] && [ $4 == ".mts" ]; then
    MSG="${MSG},TS1479"
  fi

  # どちらかに.ts かつ (.mts commonjs) or (.cts module) and nodejs 1479

  if [ $1 == "esm" ] && [ $3 == "cjs" ]; then
    # cjsモジュールをimport
    if [ $4 == ".ts" ] && [ $6 != "n" ]; then
      # モジュールとして認識されなかった
      echo "TS2306"
      return 1
    else
      MSG="${MSG},TS2459"
    fi
  fi

  if [ ${#MSG} -gt 1 ]; then
    echo "${MSG}"
    return 1
  fi
}

# validate検証用 (cd test;cat *_analyze|sort -h -k 8) > totalresult
function err {
  diff <(grep $1 <(cd test && cat *_analyze|sort -h -k 8) | awk '{print $8}') <(grep $1 test/*_comp_result | sed -E "s/test\/([0-9]+)_.+/\1/g" | sort -h)
}

function file2No {
  path=$1 # arg
  if [ ${#path} -eq 0 ]; then
    path=$(cat -) # pipe
  fi
  for i in ${path[@]};do
    echo "${i##*/}" |sed -E "s/^([0-9]+).*/\1/g"
  done
}

function analize {
  echo "$@ \"$(grep -E "TS[0-9]+" "./test/${8}_comp_result" -o | tr '\n' ' ')\" $(analize_js $@) \"$(grep Err ./test/${8}_run_result 2> /dev/null)\"" > "./test/${8}_analyze"
}

function analize_js {
  main=none
  if grep "import" "./dist/main${2//t/j}" > /dev/null; then
    main=esm
  elif grep "require" "./dist/main${2//t/j}" > /dev/null; then
    main=cjs
  fi
  module=none
  if grep "export class" "./dist/Module${4//t/j}" > /dev/null; then
    module=esm
  elif grep "exports.Data" "./dist/Module${4//t/j}" > /dev/null; then
    module=cjs
  fi
  echo $main $module
}