# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.10

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build

# Utility rule file for noc_block_BoundaryDetector_tb.

# Include the progress variables for this target.
include CMakeFiles/noc_block_BoundaryDetector_tb.dir/progress.make

CMakeFiles/noc_block_BoundaryDetector_tb:
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS && source /home/imdea/rfnoc/src/uhd-fpga/usrp3/top/e300/setupenv.sh && make -C rfnoc/testbenches/noc_block_BoundaryDetector_tb xsim FPGA_TOP_DIR=/home/imdea/rfnoc/src/uhd-fpga

noc_block_BoundaryDetector_tb: CMakeFiles/noc_block_BoundaryDetector_tb
noc_block_BoundaryDetector_tb: CMakeFiles/noc_block_BoundaryDetector_tb.dir/build.make

.PHONY : noc_block_BoundaryDetector_tb

# Rule to build all files generated by this target.
CMakeFiles/noc_block_BoundaryDetector_tb.dir/build: noc_block_BoundaryDetector_tb

.PHONY : CMakeFiles/noc_block_BoundaryDetector_tb.dir/build

CMakeFiles/noc_block_BoundaryDetector_tb.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/noc_block_BoundaryDetector_tb.dir/cmake_clean.cmake
.PHONY : CMakeFiles/noc_block_BoundaryDetector_tb.dir/clean

CMakeFiles/noc_block_BoundaryDetector_tb.dir/depend:
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/CMakeFiles/noc_block_BoundaryDetector_tb.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/noc_block_BoundaryDetector_tb.dir/depend

