# Copyright 2011,2012 Free Software Foundation, Inc.
#
# This file is part of GNU Radio
#
# GNU Radio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# GNU Radio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with GNU Radio; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street,
# Boston, MA 02110-1301, USA.

########################################################################
# Setup library
########################################################################
include(GrPlatform) #define LIB_SUFFIX

include_directories(${Boost_INCLUDE_DIR})
link_directories(${Boost_LIBRARY_DIRS})
list(APPEND ORCA_BLOCKS_sources
    PacketDetector_impl.cc
    PacketDetector_block_ctrl_impl.cpp
    CFOC_impl.cc
    CFOC_block_ctrl_impl.cpp
    SymbolTiming_impl.cc
    SymbolTiming_block_ctrl_impl.cpp
    BoundaryDetector_impl.cc
    BoundaryDetector_block_ctrl_impl.cpp
    CIR_impl.cc
    CIR_block_ctrl_impl.cpp )


set(ORCA_BLOCKS_sources "${ORCA_BLOCKS_sources}" PARENT_SCOPE)
if(NOT ORCA_BLOCKS_sources)
	MESSAGE(STATUS "No C++ sources... skipping lib/")
	return()
endif(NOT ORCA_BLOCKS_sources)

add_library(gnuradio-ORCA_BLOCKS SHARED ${ORCA_BLOCKS_sources})
target_link_libraries(gnuradio-ORCA_BLOCKS ${Boost_LIBRARIES} ${GNURADIO_ALL_LIBRARIES} ${ETTUS_LIBRARIES})
set_target_properties(gnuradio-ORCA_BLOCKS PROPERTIES DEFINE_SYMBOL "gnuradio_ORCA_BLOCKS_EXPORTS")

if(APPLE)
    set_target_properties(gnuradio-ORCA_BLOCKS PROPERTIES
        INSTALL_NAME_DIR "${CMAKE_INSTALL_PREFIX}/lib"
    )
endif(APPLE)

########################################################################
# Install built library files
########################################################################
install(TARGETS gnuradio-ORCA_BLOCKS
    LIBRARY DESTINATION lib${LIB_SUFFIX} # .so/.dylib file
    ARCHIVE DESTINATION lib${LIB_SUFFIX} # .lib file
    RUNTIME DESTINATION bin              # .dll file
)

########################################################################
# Build and register unit test
########################################################################
include(GrTest)

include_directories(${CPPUNIT_INCLUDE_DIRS})

list(APPEND test_ORCA_BLOCKS_sources
    ${CMAKE_CURRENT_SOURCE_DIR}/test_ORCA_BLOCKS.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/qa_ORCA_BLOCKS.cc
)

add_executable(test-ORCA_BLOCKS ${test_ORCA_BLOCKS_sources})

target_link_libraries(
  test-ORCA_BLOCKS
  ${GNURADIO_RUNTIME_LIBRARIES}
  ${Boost_LIBRARIES}
  ${CPPUNIT_LIBRARIES}
  ${ETTUS_LIBRARIES}
  ${PC_ETTUS_LIBDIR}
  gnuradio-ORCA_BLOCKS
)



GR_ADD_TEST(test_ORCA_BLOCKS test-ORCA_BLOCKS)
