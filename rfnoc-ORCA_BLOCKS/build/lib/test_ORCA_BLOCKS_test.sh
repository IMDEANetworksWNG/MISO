#!/bin/sh
export VOLK_GENERIC=1
export GR_DONT_LOAD_PREFS=1
export srcdir=/home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/lib
export PATH=/home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/lib:$PATH
export LD_LIBRARY_PATH=/home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$PYTHONPATH
test-ORCA_BLOCKS 
