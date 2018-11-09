#!/bin/bash
# trush@yandex.ru

# Patched and compiled tool from MAME project
JEDUTIL=$PWD/jedutil

# 105 variants
for device in N82S100 PAL16L8 PAL16R4 PAL16R6
do
  for f in $(find ./$device -iname *.jed -type f)
  do
    DIR=$(dirname $f)
    BASE=$(basename $f .jed)
    pushd $DIR >/dev/null
    echo $BASE
    $JEDUTIL -view $BASE.jed $device &>$BASE.eqn
    ln -s $BASE.jed $(md5sum $BASE.jed| cut -c1-8).jed
    ln -s $BASE.eqn $(md5sum $BASE.jed| cut -c1-8).eqn
#    $JEDUTIL -convert $BASE.jed $BASE.bin &>$BASE.bin.txt
    popd >/dev/null
  done
done