#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "openvino::genai" for configuration "Release"
set_property(TARGET openvino::genai APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(openvino::genai PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/runtime/lib/intel64/Release/openvino_genai.lib"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/runtime/bin/intel64/Release/openvino_genai.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS openvino::genai )
list(APPEND _IMPORT_CHECK_FILES_FOR_openvino::genai "${_IMPORT_PREFIX}/runtime/lib/intel64/Release/openvino_genai.lib" "${_IMPORT_PREFIX}/runtime/bin/intel64/Release/openvino_genai.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
