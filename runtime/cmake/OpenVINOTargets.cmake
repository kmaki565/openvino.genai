# Generated by CMake

if("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" LESS 2.5)
   message(FATAL_ERROR "CMake >= 2.6.0 required")
endif()
cmake_policy(PUSH)
cmake_policy(VERSION 2.6...3.18)
#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Protect against multiple inclusion, which would fail when already imported targets are added once more.
set(_targetsDefined)
set(_targetsNotDefined)
set(_expectedTargets)
foreach(_expectedTarget openvino::frontend::onnx openvino::frontend::pytorch openvino::frontend::tensorflow openvino::frontend::tensorflow_lite openvino::frontend::paddle openvino::runtime openvino::runtime::c)
  list(APPEND _expectedTargets ${_expectedTarget})
  if(NOT TARGET ${_expectedTarget})
    list(APPEND _targetsNotDefined ${_expectedTarget})
  endif()
  if(TARGET ${_expectedTarget})
    list(APPEND _targetsDefined ${_expectedTarget})
  endif()
endforeach()
if("${_targetsDefined}" STREQUAL "${_expectedTargets}")
  unset(_targetsDefined)
  unset(_targetsNotDefined)
  unset(_expectedTargets)
  set(CMAKE_IMPORT_FILE_VERSION)
  cmake_policy(POP)
  return()
endif()
if(NOT "${_targetsDefined}" STREQUAL "")
  message(FATAL_ERROR "Some (but not all) targets in this export set were already defined.\nTargets Defined: ${_targetsDefined}\nTargets not yet defined: ${_targetsNotDefined}\n")
endif()
unset(_targetsDefined)
unset(_targetsNotDefined)
unset(_expectedTargets)


# Compute the installation prefix relative to this file.
get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
if(_IMPORT_PREFIX STREQUAL "/")
  set(_IMPORT_PREFIX "")
endif()

# Create imported target openvino::frontend::onnx
add_library(openvino::frontend::onnx SHARED IMPORTED)

set_target_properties(openvino::frontend::onnx PROPERTIES
  INTERFACE_LINK_LIBRARIES "openvino::runtime"
)

# Create imported target openvino::frontend::pytorch
add_library(openvino::frontend::pytorch SHARED IMPORTED)

set_target_properties(openvino::frontend::pytorch PROPERTIES
  INTERFACE_LINK_LIBRARIES "openvino::runtime"
)

# Create imported target openvino::frontend::tensorflow
add_library(openvino::frontend::tensorflow SHARED IMPORTED)

set_target_properties(openvino::frontend::tensorflow PROPERTIES
  INTERFACE_LINK_LIBRARIES "openvino::runtime"
)

# Create imported target openvino::frontend::tensorflow_lite
add_library(openvino::frontend::tensorflow_lite SHARED IMPORTED)

set_target_properties(openvino::frontend::tensorflow_lite PROPERTIES
  INTERFACE_LINK_LIBRARIES "openvino::runtime"
)

# Create imported target openvino::frontend::paddle
add_library(openvino::frontend::paddle SHARED IMPORTED)

set_target_properties(openvino::frontend::paddle PROPERTIES
  INTERFACE_LINK_LIBRARIES "openvino::runtime"
)

# Create imported target openvino::runtime
add_library(openvino::runtime SHARED IMPORTED)

set_target_properties(openvino::runtime PROPERTIES
  INTERFACE_COMPILE_DEFINITIONS "OV_THREAD=OV_THREAD_TBB"
  INTERFACE_COMPILE_FEATURES "cxx_std_11"
  INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/runtime/include"
)

# Create imported target openvino::runtime::c
add_library(openvino::runtime::c SHARED IMPORTED)

set_target_properties(openvino::runtime::c PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/runtime/include"
)

if(CMAKE_VERSION VERSION_LESS 2.8.12)
  message(FATAL_ERROR "This file relies on consumers using CMake 2.8.12 or greater.")
endif()

# Load information for each installed configuration.
get_filename_component(_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
file(GLOB CONFIG_FILES "${_DIR}/OpenVINOTargets-*.cmake")
foreach(f ${CONFIG_FILES})
  include(${f})
endforeach()

# Cleanup temporary variables.
set(_IMPORT_PREFIX)

# Loop over all imported files and verify that they actually exist
foreach(target ${_IMPORT_CHECK_TARGETS} )
  foreach(file ${_IMPORT_CHECK_FILES_FOR_${target}} )
    if(NOT EXISTS "${file}" )
      message(FATAL_ERROR "The imported target \"${target}\" references the file
   \"${file}\"
but this file does not exist.  Possible reasons include:
* The file was deleted, renamed, or moved to another location.
* An install or uninstall procedure did not complete successfully.
* The installation package was faulty and contained
   \"${CMAKE_CURRENT_LIST_FILE}\"
but not all the files it references.
")
    endif()
  endforeach()
  unset(_IMPORT_CHECK_FILES_FOR_${target})
endforeach()
unset(_IMPORT_CHECK_TARGETS)

# This file does not depend on other imported targets which have
# been exported from the same project but in a separate export set.

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)
