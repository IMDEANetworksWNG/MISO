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

# Include any dependencies generated for this target.
include lib/CMakeFiles/test-ORCA_BLOCKS.dir/depend.make

# Include the progress variables for this target.
include lib/CMakeFiles/test-ORCA_BLOCKS.dir/progress.make

# Include the compile flags for this target's objects.
include lib/CMakeFiles/test-ORCA_BLOCKS.dir/flags.make

lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o: lib/CMakeFiles/test-ORCA_BLOCKS.dir/flags.make
lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o: ../lib/test_ORCA_BLOCKS.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o"
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/lib && /usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o -c /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/lib/test_ORCA_BLOCKS.cc

lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.i"
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/lib && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/lib/test_ORCA_BLOCKS.cc > CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.i

lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.s"
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/lib && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/lib/test_ORCA_BLOCKS.cc -o CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.s

lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o.requires:

.PHONY : lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o.requires

lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o.provides: lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o.requires
	$(MAKE) -f lib/CMakeFiles/test-ORCA_BLOCKS.dir/build.make lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o.provides.build
.PHONY : lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o.provides

lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o.provides.build: lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o


lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o: lib/CMakeFiles/test-ORCA_BLOCKS.dir/flags.make
lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o: ../lib/qa_ORCA_BLOCKS.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building CXX object lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o"
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/lib && /usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o -c /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/lib/qa_ORCA_BLOCKS.cc

lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.i"
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/lib && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/lib/qa_ORCA_BLOCKS.cc > CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.i

lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.s"
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/lib && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/lib/qa_ORCA_BLOCKS.cc -o CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.s

lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o.requires:

.PHONY : lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o.requires

lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o.provides: lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o.requires
	$(MAKE) -f lib/CMakeFiles/test-ORCA_BLOCKS.dir/build.make lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o.provides.build
.PHONY : lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o.provides

lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o.provides.build: lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o


# Object files for target test-ORCA_BLOCKS
test__ORCA_BLOCKS_OBJECTS = \
"CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o" \
"CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o"

# External object files for target test-ORCA_BLOCKS
test__ORCA_BLOCKS_EXTERNAL_OBJECTS =

lib/test-ORCA_BLOCKS: lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o
lib/test-ORCA_BLOCKS: lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o
lib/test-ORCA_BLOCKS: lib/CMakeFiles/test-ORCA_BLOCKS.dir/build.make
lib/test-ORCA_BLOCKS: /home/imdea/rfnoc/lib/libgnuradio-runtime.so
lib/test-ORCA_BLOCKS: /home/imdea/rfnoc/lib/libgnuradio-pmt.so
lib/test-ORCA_BLOCKS: /usr/lib/x86_64-linux-gnu/liblog4cpp.so
lib/test-ORCA_BLOCKS: /usr/lib/x86_64-linux-gnu/libboost_filesystem.so
lib/test-ORCA_BLOCKS: /usr/lib/x86_64-linux-gnu/libboost_system.so
lib/test-ORCA_BLOCKS: /usr/lib/x86_64-linux-gnu/libcppunit.so
lib/test-ORCA_BLOCKS: /home/imdea/rfnoc/lib/libgnuradio-ettus.so
lib/test-ORCA_BLOCKS: lib/libgnuradio-ORCA_BLOCKS.so
lib/test-ORCA_BLOCKS: /home/imdea/rfnoc/lib/libgnuradio-runtime.so
lib/test-ORCA_BLOCKS: /home/imdea/rfnoc/lib/libgnuradio-pmt.so
lib/test-ORCA_BLOCKS: /usr/lib/x86_64-linux-gnu/liblog4cpp.so
lib/test-ORCA_BLOCKS: /usr/lib/x86_64-linux-gnu/libboost_filesystem.so
lib/test-ORCA_BLOCKS: /usr/lib/x86_64-linux-gnu/libboost_system.so
lib/test-ORCA_BLOCKS: /home/imdea/rfnoc/lib/libgnuradio-ettus.so
lib/test-ORCA_BLOCKS: lib/CMakeFiles/test-ORCA_BLOCKS.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Linking CXX executable test-ORCA_BLOCKS"
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/lib && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/test-ORCA_BLOCKS.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
lib/CMakeFiles/test-ORCA_BLOCKS.dir/build: lib/test-ORCA_BLOCKS

.PHONY : lib/CMakeFiles/test-ORCA_BLOCKS.dir/build

lib/CMakeFiles/test-ORCA_BLOCKS.dir/requires: lib/CMakeFiles/test-ORCA_BLOCKS.dir/test_ORCA_BLOCKS.cc.o.requires
lib/CMakeFiles/test-ORCA_BLOCKS.dir/requires: lib/CMakeFiles/test-ORCA_BLOCKS.dir/qa_ORCA_BLOCKS.cc.o.requires

.PHONY : lib/CMakeFiles/test-ORCA_BLOCKS.dir/requires

lib/CMakeFiles/test-ORCA_BLOCKS.dir/clean:
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/lib && $(CMAKE_COMMAND) -P CMakeFiles/test-ORCA_BLOCKS.dir/cmake_clean.cmake
.PHONY : lib/CMakeFiles/test-ORCA_BLOCKS.dir/clean

lib/CMakeFiles/test-ORCA_BLOCKS.dir/depend:
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/lib /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/lib /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/lib/CMakeFiles/test-ORCA_BLOCKS.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : lib/CMakeFiles/test-ORCA_BLOCKS.dir/depend

