#!/bin/bash

# properties
write_module=("esm" "cjs")
extend=(".mts" ".cts" ".ts")
run_module=("module" "commonjs")
comp_module=("e" "n" "c")
# module_resolution=("n" "0")
module_resolution=("0")

# const
OUTPUT="check.sh"

# init
cat <<< "#!/bin/bash

# read functions
. ./regist_function.sh

# init
mkdir -p ts test
rm -f ts/* test/*

# testcase" > ${OUTPUT}

# make testcase
idx=0
for main_mod in ${write_module[@]}; do
  for main_ext in ${extend[@]}; do
    for mod_mod in ${write_module[@]}; do
      for mod_ext in ${extend[@]}; do
        for run in ${run_module[@]}; do
          for comp in ${comp_module[@]}; do
            for resol in ${module_resolution[@]}; do
              idx=$((idx+1))
              echo "check ${main_mod} ${main_ext} ${mod_mod} ${mod_ext} ${run} ${comp} ${resol} ${idx}" >> ${OUTPUT}
            done
          done
        done
      done
    done
  done
done

chmod 744 ${OUTPUT}
