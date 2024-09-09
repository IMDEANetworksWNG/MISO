/* -*- c++ -*- */
/* 
 * Copyright 2019 <+YOU OR YOUR COMPANY+>.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */


#ifndef INCLUDED_ORCA_BLOCKS_SYMBOLTIMING_H
#define INCLUDED_ORCA_BLOCKS_SYMBOLTIMING_H

#include <ORCA_BLOCKS/api.h>
#include <ettus/device3.h>
#include <ettus/rfnoc_block.h>
#include <uhd/stream.hpp>

namespace gr {
  namespace ORCA_BLOCKS {

    /*!
     * \brief <+description of block+>
     * \ingroup ORCA_BLOCKS
     *
     */
    class ORCA_BLOCKS_API SymbolTiming : virtual public gr::ettus::rfnoc_block
    {
     public:
      typedef boost::shared_ptr<SymbolTiming> sptr;

      /*!
       * \brief Return a shared_ptr to a new instance of ORCA_BLOCKS::SymbolTiming.
       *
       * To avoid accidental use of raw pointers, ORCA_BLOCKS::SymbolTiming's
       * constructor is in a private implementation
       * class. ORCA_BLOCKS::SymbolTiming::make is the public interface for
       * creating new instances.
       */
      static sptr make(
        const gr::ettus::device3::sptr &dev,
        const ::uhd::stream_args_t &tx_stream_args,
        const ::uhd::stream_args_t &rx_stream_args,
        const int block_select=-1,
        const int device_select=-1,
        const bool enable_eob_on_stop=true
        );
    };
  } // namespace ORCA_BLOCKS
} // namespace gr

#endif /* INCLUDED_ORCA_BLOCKS_SYMBOLTIMING_H */

