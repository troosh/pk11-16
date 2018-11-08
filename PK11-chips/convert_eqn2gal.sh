#!/bin/bash
# trush@yandex.ru


EQN2GALasm=$PWD/eqn2gal.pl
# Compiled tool from https://github.com/daveho/GALasm.git
GALasmUTIL=$PWD/galasm

RESDIR=_GAL16V8
mkdir -p $RESDIR
for device in PAL16L8 PAL16R4 PAL16R6
do
  for f in $(find ./$device -iname *.jed -type f)
  do
    DIR=$(dirname $f)
    BASE=$(basename $f .jed)
    echo $device/$(basename $DIR)/$BASE
    mkdir -p $RESDIR/$device/$(basename $DIR)
    md5=$(md5sum $f| cut -c1-4)
    pushd $RESDIR/$device/$(basename $DIR) >/dev/null
    ln -sf ../../.$DIR/$BASE.jed $BASE.orig.jed
    ln -sf ../../.$DIR/$BASE.eqn $BASE.eqn
    $EQN2GALasm $BASE.eqn $device $(basename $DIR)-$md5 > $BASE.pld
    $GALasmUTIL $BASE.pld 2>&1 >$BASE.log
    popd >/dev/null
  done
done

#for device in N82S100
