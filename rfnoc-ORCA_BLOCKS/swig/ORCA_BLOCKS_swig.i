/* -*- c++ -*- */

#define ORCA_BLOCKS_API
#define ETTUS_API

%include "gnuradio.i"/*			*/// the common stuff

//load generated python docstrings
%include "ORCA_BLOCKS_swig_doc.i"
//Header from gr-ettus
%include "ettus/device3.h"
%include "ettus/rfnoc_block.h"
%include "ettus/rfnoc_block_impl.h"

%{
#include "ettus/device3.h"
#include "ettus/rfnoc_block_impl.h"
#include "ORCA_BLOCKS/PacketDetector.h"
#include "ORCA_BLOCKS/CFOC.h"
#include "ORCA_BLOCKS/SymbolTiming.h"
#include "ORCA_BLOCKS/BoundaryDetector.h"
#include "ORCA_BLOCKS/CIR.h"
%}

%include "ORCA_BLOCKS/PacketDetector.h"
GR_SWIG_BLOCK_MAGIC2(ORCA_BLOCKS, PacketDetector);

%include "ORCA_BLOCKS/CFOC.h"
GR_SWIG_BLOCK_MAGIC2(ORCA_BLOCKS, CFOC);
%include "ORCA_BLOCKS/SymbolTiming.h"
GR_SWIG_BLOCK_MAGIC2(ORCA_BLOCKS, SymbolTiming);
%include "ORCA_BLOCKS/BoundaryDetector.h"
GR_SWIG_BLOCK_MAGIC2(ORCA_BLOCKS, BoundaryDetector);
%include "ORCA_BLOCKS/CIR.h"
GR_SWIG_BLOCK_MAGIC2(ORCA_BLOCKS, CIR);
