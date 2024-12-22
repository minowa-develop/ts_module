#!/bin/bash

# tsconfigとpackage内のモジュール設定を変更
# arg1: compiled module[esm or other]
# arg2: running module[esm or other]
function setting {
  COMPILED_MODULE="CommonJS"
  RUN_MODULE="commonjs"
  if [ "$1" == "esm" ]; then COMPILED_MODULE="ESNext"; fi
  if [ "$2" == "esm" ]; then RUN_MODULE="module"; fi
  sed -Ei "s/(\"module\": ).*/\1\"${COMPILED_MODULE}\",/" tsconfig.json
  sed -Ei "s/(\"type\": ).*/\1\"${RUN_MODULE}\",/" package.json
}
# 検証結果をファイル出力する
# arg1: source module[free]
# arg2: conpiled module[esm or other]
# arg3: running module[esm or other]
function module_test {
  src=$1
  cmp=$2
  run=$3
  setting "${cmp}" "${run}" && npx tsc
  dir="${src}-${cmp}-${run}"
  mkdir -p test
  rm -rf ./test/${dir}
  cp -r ./dist/ ./test/${dir}
  node dist/main.js > "./test/${dir}/result" 2>&1
}