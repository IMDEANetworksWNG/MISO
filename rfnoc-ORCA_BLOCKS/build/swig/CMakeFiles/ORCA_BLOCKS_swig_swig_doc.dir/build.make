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

# Utility rule file for ORCA_BLOCKS_swig_swig_doc.

# Include the progress variables for this target.
include swig/CMakeFiles/ORCA_BLOCKS_swig_swig_doc.dir/progress.make

swig/CMakeFiles/ORCA_BLOCKS_swig_swig_doc: swig/ORCA_BLOCKS_swig_doc.i


swig/ORCA_BLOCKS_swig_doc.i: swig/ORCA_BLOCKS_swig_doc_swig_docs/xml/index.xml
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Generating python docstrings for ORCA_BLOCKS_swig_doc"
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/docs/doxygen && /usr/bin/python2 -B /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/docs/doxygen/swig_doc.py /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/swig/ORCA_BLOCKS_swig_doc_swig_docs/xml /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/swig/ORCA_BLOCKS_swig_doc.i

swig/ORCA_BLOCKS_swig_doc_swig_docs/xml/index.xml: swig/_ORCA_BLOCKS_swig_doc_tag
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Generating doxygen xml for ORCA_BLOCKS_swig_doc docs"
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/swig && ./_ORCA_BLOCKS_swig_doc_tag
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/swig && /usr/bin/doxygen /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/swig/ORCA_BLOCKS_swig_doc_swig_docs/Doxyfile

ORCA_BLOCKS_swig_swig_doc: swig/CMakeFiles/ORCA_BLOCKS_swig_swig_doc
ORCA_BLOCKS_swig_swig_doc: swig/ORCA_BLOCKS_swig_doc.i
ORCA_BLOCKS_swig_swig_doc: swig/ORCA_BLOCKS_swig_doc_swig_docs/xml/index.xml
ORCA_BLOCKS_swig_swig_doc: swig/CMakeFiles/ORCA_BLOCKS_swig_swig_doc.dir/build.make

.PHONY : ORCA_BLOCKS_swig_swig_doc

# Rule to build all files generated by this target.
swig/CMakeFiles/ORCA_BLOCKS_swig_swig_doc.dir/build: ORCA_BLOCKS_swig_swig_doc

.PHONY : swig/CMakeFiles/ORCA_BLOCKS_swig_swig_doc.dir/build

swig/CMakeFiles/ORCA_BLOCKS_swig_swig_doc.dir/clean:
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/swig && $(CMAKE_COMMAND) -P CMakeFiles/ORCA_BLOCKS_swig_swig_doc.dir/cmake_clean.cmake
.PHONY : swig/CMakeFiles/ORCA_BLOCKS_swig_swig_doc.dir/clean

swig/CMakeFiles/ORCA_BLOCKS_swig_swig_doc.dir/depend:
	cd /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/swig /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/swig /home/imdea/rfnoc/src/rfnoc-ORCA_BLOCKS/build/swig/CMakeFiles/ORCA_BLOCKS_swig_swig_doc.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : swig/CMakeFiles/ORCA_BLOCKS_swig_swig_doc.dir/depend

