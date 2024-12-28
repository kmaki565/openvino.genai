# Copyright (C) 2018-2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0
#
# FindOpenVINO
# ------
#
# Provides OpenVINO runtime for model creation and inference, frontend libraries
# to convert models from framework specific formats.
#
# The following components are supported:
#
#  * `Runtime`: OpenVINO C++ and C Core & Inference Runtime, frontend common
#  * `Threading`: OpenVINO threading backend for parallel.hpp
#  * `ONNX`: OpenVINO ONNX frontend
#  * `Paddle`: OpenVINO Paddle frontend
#  * `PyTorch`: OpenVINO PyTorch frontend
#  * `TensorFlow`: OpenVINO TensorFlow frontend
#  * `TensorFlowLite`: OpenVINO TensorFlow Lite frontend
#
# If no components are specified, `Runtime` component is provided:
#
#   find_package(OpenVINO REQUIRED) # only Runtime component
#
# If specific components are required:
#
#   find_package(OpenVINO REQUIRED COMPONENTS Runtime ONNX)
#
# If OpenVINO's openvino/core/parallel.hpp is required:
#
#   find_package(OpenVINO REQUIRED COMPONENTS Runtime Threading)
#
# Imported Targets:
# ------
#
#  Runtime targets:
#
#   `openvino::runtime`
#   The OpenVINO C++ Core & Inference Runtime
#
#   `openvino::runtime::c`
#   The OpenVINO C Inference Runtime
#
#   `openvino::threading`
#   The OpenVINO Threading backend
#
#  Frontend specific targets:
#
#   `openvino::frontend::onnx`
#   ONNX FrontEnd target (optional)
#
#   `openvino::frontend::paddle`
#   Paddle FrontEnd target (optional)
#
#   `openvino::frontend::pytorch`
#   PyTorch FrontEnd target (optional)
#
#   `openvino::frontend::tensorflow`
#   TensorFlow FrontEnd target (optional)
#
#   `openvino::frontend::tensorflow_lite`
#   TensorFlow Lite FrontEnd target (optional)
#
# Result variables:
# ------
#
# The module sets the following variables in your project:
#
#   `OpenVINO_FOUND`
#   System has OpenVINO Runtime installed
#
#   `OpenVINO_Runtime_FOUND`
#   OpenVINO C++ Core & Inference Runtime is available
#
#   `OpenVINO_Frontend_ONNX_FOUND`
#   OpenVINO ONNX frontend is available
#
#   `OpenVINO_Frontend_Paddle_FOUND`
#   OpenVINO Paddle frontend is available
#
#   `OpenVINO_Frontend_PyTorch_FOUND`
#   OpenVINO PyTorch frontend is available
#
#   `OpenVINO_Frontend_TensorFlow_FOUND`
#   OpenVINO TensorFlow frontend is available
#
#   `OpenVINO_Frontend_TensorFlowLite_FOUND`
#   OpenVINO TensorFlow Lite frontend is available
#
#   `OpenVINO_Frontend_IR_FOUND`
#   OpenVINO IR frontend is available
#
#  OpenVINO version variables:
#
#   `OpenVINO_VERSION_MAJOR`
#   Major version component
#
#   `OpenVINO_VERSION_MINOR`
#   Minor version component
#
#   `OpenVINO_VERSION_PATCH`
#   Patch version component
#
#  OpenVINO build configuration variables:
#
#   `OpenVINO_GLIBCXX_USE_CXX11_ABI`
#   Linux only: defines _GLIBCXX_USE_CXX11_ABI value used to compiled OpenVINO
#


####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was OpenVINOConfig.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

set(OpenVINO_GLIBCXX_USE_CXX11_ABI "")

#
# Common functions
#

if(NOT DEFINED CMAKE_FIND_PACKAGE_NAME)
    set(CMAKE_FIND_PACKAGE_NAME OpenVINO)
    set(_need_package_name_reset ON)
endif()

# we have to use our own version of find_dependency because of support cmake 3.7
macro(_ov_find_dependency dep)
    set(cmake_fd_quiet_arg)
    if(${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
        set(cmake_fd_quiet_arg QUIET)
    endif()
    set(cmake_fd_required_arg)
    if(${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED)
        set(cmake_fd_required_arg REQUIRED)
    endif()

    get_property(cmake_fd_alreadyTransitive GLOBAL PROPERTY
        _CMAKE_${dep}_TRANSITIVE_DEPENDENCY)

    find_package(${dep} ${ARGN}
        ${cmake_fd_quiet_arg}
        ${cmake_fd_required_arg})

    if(NOT DEFINED cmake_fd_alreadyTransitive OR cmake_fd_alreadyTransitive)
        set_property(GLOBAL PROPERTY _CMAKE_${dep}_TRANSITIVE_DEPENDENCY TRUE)
    endif()

    if(NOT ${dep}_FOUND)
        set(${CMAKE_FIND_PACKAGE_NAME}_NOT_FOUND_MESSAGE "${CMAKE_FIND_PACKAGE_NAME} could not be found because dependency ${dep} could not be found.")
        set(${CMAKE_FIND_PACKAGE_NAME}_FOUND False)
        return()
    endif()

    unset(cmake_fd_required_arg)
    unset(cmake_fd_quiet_arg)
endmacro()

macro(_ov_find_openmp)
    set(_ov_threading "TBB")
    set(_ov_enable_intel_omp "OFF")

    if(_ov_threading STREQUAL "OMP")
        if(_ov_enable_intel_omp)
            # TODO: write code to import iomp libraries
        else()
            _ov_find_dependency(OpenMP)
        endif()
    endif()

    unset(_ov_enable_intel_omp)
    unset(_ov_threading)
endmacro()

macro(_ov_find_tbb)
    set(_ov_threading "TBB")
    if(_ov_threading STREQUAL "TBB" OR _ov_threading STREQUAL "TBB_AUTO")
        set(enable_pkgconfig_tbb "")

        # try tbb.pc
        if(enable_pkgconfig_tbb AND NOT ANDROID)
            _ov_find_dependency(PkgConfig)
            if(PkgConfig_FOUND)
                if(${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
                    set(pkg_config_quiet_arg QUIET)
                endif()
                if(${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED)
                    set(pkg_config_required_arg REQUIRED)
                endif()

                pkg_search_module(tbb
                                  ${pkg_config_quiet_arg}
                                  ${pkg_config_required_arg}
                                  IMPORTED_TARGET
                                  tbb)
                unset(pkg_config_quiet_arg)
                unset(pkg_config_required_arg)

                if(tbb_FOUND)
                    if(TARGET PkgConfig::tbb)
                        set(TBB_VERSION ${tbb_VERSION})
                        set(TBB_FOUND ${tbb_FOUND})
                        unset(tbb_FOUND)
                        unset(tbb_VERSION)
                    elseif(${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED)
                        message(FATAL_ERROR "cmake v${CMAKE_VERSION} contains bug in function 'pkg_search_module', need to update to at least v3.16.0 version")
                    endif()
                endif()
            endif()
        else()
            # try cmake TBB interface

            set(enable_system_tbb "OFF")
            if(NOT enable_system_tbb)
                set_and_check(_tbb_dir "${PACKAGE_PREFIX_DIR}/runtime/3rdparty/tbb")

                # see https://stackoverflow.com/questions/28070810/cmake-generate-error-on-windows-as-it-uses-as-escape-seq
                if(DEFINED ENV{TBBROOT})
                    file(TO_CMAKE_PATH $ENV{TBBROOT} ENV_TBBROOT)
                endif()
                if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.24)
                    set(_no_cmake_install_prefix NO_CMAKE_INSTALL_PREFIX)
                endif()

                set(find_package_tbb_extra_args
                    CONFIG
                    PATHS
                        # oneTBB case exposed via export TBBROOT=<custom TBB root>
                        "${ENV_TBBROOT}/lib64/cmake/TBB"
                        "${ENV_TBBROOT}/lib/cmake/TBB"
                        "${ENV_TBBROOT}/lib/cmake/tbb"
                        # for custom TBB exposed via cmake -DTBBROOT=<custom TBB root>
                        "${TBBROOT}/cmake"
                        # _tbb_dir points to TBB_DIR (custom | temp | system) used to build OpenVINO
                        ${_tbb_dir}
                    CMAKE_FIND_ROOT_PATH_BOTH
                    NO_PACKAGE_ROOT_PATH
                    NO_SYSTEM_ENVIRONMENT_PATH
                    NO_CMAKE_PACKAGE_REGISTRY
                    NO_CMAKE_SYSTEM_PATH
                    ${_no_cmake_install_prefix}
                    NO_CMAKE_SYSTEM_PACKAGE_REGISTRY)
                unset(_tbb_dir)
                unset(_no_cmake_install_prefix)
            endif()
            unset(enable_system_tbb)

            _ov_find_dependency(TBB
                                # we need to find at least the same version as we compiled with
                                2021.2.5
                                COMPONENTS tbb tbbmalloc
                                ${find_package_tbb_extra_args})
            unset(find_package_tbb_extra_args)
        endif()
        unset(enable_pkgconfig_tbb)

        set(install_tbbbind "")
        if(install_tbbbind)
            set_and_check(_tbb_bind_dir "")
            _ov_find_dependency(TBBBIND_2_5
                                PATHS ${_tbb_bind_dir}
                                NO_CMAKE_FIND_ROOT_PATH
                                NO_DEFAULT_PATH)
            if(TARGET TBBbind::tbbbind_2_5)
                # To solve https://cmake.org/cmake/help/latest/policy/CMP0111.html warnings
                set_property(TARGET TBBbind::tbbbind_2_5 PROPERTY IMPORTED_CONFIGURATIONS RELEASE DEBUG)
            endif()
            unset(_tbb_bind_dir)
        endif()
        unset(install_tbbbind)
    endif()

    unset(_ov_threading)
endmacro()

macro(_ov_find_pugixml)
    set(_OV_ENABLE_SYSTEM_PUGIXML "OFF")
    if(_OV_ENABLE_SYSTEM_PUGIXML)
        set(_ov_pugixml_pkgconfig_interface "")
        set(_ov_pugixml_cmake_interface "")

        if(_ov_pugixml_pkgconfig_interface AND NOT ANDROID)
            _ov_find_dependency(PkgConfig)
        elseif(_ov_pugixml_cmake_interface)
            _ov_find_dependency(PugiXML NAMES PugiXML pugixml)
        endif()

        # see https://cmake.org/cmake/help/latest/command/add_library.html#alias-libraries
        # cmake older than 3.18 cannot create an alias for imported non-GLOBAL targets
        # so, we have to use 'GLOBAL' property for cases when we call from OpenVINODeveloperPackage
        # because the alias openvino::pugixml is created later
        if(CMAKE_VERSION VERSION_LESS 3.18 AND OpenVINODeveloperPackage_DIR)
            set(_ov_pugixml_visibility GLOBAL)
        endif()

        if(PugiXML_FOUND)
            if(TARGET pugixml)
                set(_ov_pugixml_target pugixml)
            elseif(TARGET pugixml::pugixml)
                set(_ov_pugixml_target pugixml::pugixml)
            endif()
            if(OpenVINODeveloperPackage_DIR)
                # align with build tree and create alias
                if(_ov_pugixml_visibility STREQUAL "GLOBAL")
                    set_target_properties(${_ov_pugixml_target} PROPERTIES IMPORTED_GLOBAL TRUE)
                endif()
                # check whether openvino::pugixml is already defined in case of
                # OpenVINODeveloperPackageConfig.cmake is found multiple times
                if(NOT TARGET openvino::pugixml)
                    add_library(openvino::pugixml ALIAS ${_ov_pugixml_target})
                endif()
            endif()
            unset(_ov_pugixml_target)
        elseif(PkgConfig_FOUND)
            if(${CMAKE_FIND_PACKAGE_NAME}_FIND_QUIETLY)
                set(pkg_config_quiet_arg QUIET)
            endif()
            if(${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED)
                set(pkg_config_required_arg REQUIRED)
            endif()

            pkg_search_module(pugixml
                              ${pkg_config_quiet_arg}
                              ${pkg_config_required_arg}
                              IMPORTED_TARGET
                              ${_ov_pugixml_visibility}
                              pugixml)

            unset(pkg_config_quiet_arg)
            unset(pkg_config_required_arg)

            if(pugixml_FOUND)
                if(OpenVINODeveloperPackage_DIR)
                    # check whether openvino::pugixml is already defined in case of
                    # OpenVINODeveloperPackageConfig.cmake is found multiple times
                    if(NOT TARGET openvino::pugixml)
                        add_library(openvino::pugixml ALIAS PkgConfig::pugixml)
                    endif()
                endif()

                # PATCH: on Ubuntu 18.04 pugixml.pc contains incorrect include directories
                get_target_property(interface_include_dir PkgConfig::pugixml INTERFACE_INCLUDE_DIRECTORIES)
                if(interface_include_dir AND NOT EXISTS "${interface_include_dir}")
                    set_target_properties(PkgConfig::pugixml PROPERTIES
                        INTERFACE_INCLUDE_DIRECTORIES "")
                endif()
            endif()
        endif()

        # debian 9 case: no cmake, no pkg-config files
        if(NOT TARGET openvino::pugixml)
            find_library(PUGIXML_LIBRARY NAMES pugixml DOC "Path to pugixml library")
            if(PUGIXML_LIBRARY)
                add_library(openvino::pugixml INTERFACE IMPORTED)
                set_target_properties(openvino::pugixml PROPERTIES INTERFACE_LINK_LIBRARIES "${PUGIXML_LIBRARY}")
            else()
                message(FATAL_ERROR "Failed to find system pugixml in OpenVINO Developer Package")
            endif()
        endif()

        unset(_ov_pugixml_visibility)
    endif()
endmacro()

macro(_ov_find_itt)
    set(_ENABLE_PROFILING_ITT "OFF")
    # whether 'ittapi' is found via find_package
    set(_ENABLE_SYSTEM_ITTAPI "")
    if(_ENABLE_PROFILING_ITT AND _ENABLE_SYSTEM_ITTAPI)
        _ov_find_dependency(ittapi)
    endif()
    unset(_ENABLE_PROFILING_ITT)
    unset(_ENABLE_SYSTEM_ITTAPI)
endmacro()

macro(_ov_find_intel_cpu_dependencies)
    set(_OV_ENABLE_CPU_ACL "OFF")
    if(_OV_ENABLE_CPU_ACL)
        set(_ov_in_install_tree "${PACKAGE_PREFIX_DIR}/runtime/lib/intel64/Release")
        if(_ov_in_install_tree)
            set_and_check(ARM_COMPUTE_LIB_DIR "${PACKAGE_PREFIX_DIR}/runtime/lib/intel64/Release")
            set(ACL_DIR "${CMAKE_CURRENT_LIST_DIR}")
        else()
            if(NOT TARGET arm_compute::arm_compute)
                # for case when build tree is used separately, e.g. OpenVINODeveloperPackageConfig.cmake
                set_and_check(ARM_COMPUTE_LIB_DIR "")
            endif()
            set_and_check(ACL_DIR "")
        endif()

        _ov_find_dependency(ACL)

        unset(_ov_in_install_tree)
        unset(ARM_COMPUTE_LIB_DIR)
    endif()
    unset(_OV_ENABLE_CPU_ACL)
endmacro()

macro(_ov_find_intel_gpu_dependencies)
    set(_OV_ENABLE_INTEL_GPU "ON")
    set(_OV_ENABLE_SYSTEM_OPENCL "OFF")
    if(_OV_ENABLE_INTEL_GPU AND _OV_ENABLE_SYSTEM_OPENCL)
        _ov_find_dependency(OpenCL)
    endif()
    unset(_OV_ENABLE_INTEL_GPU)
    unset(_OV_ENABLE_SYSTEM_OPENCL)

    set(_OV_ENABLE_ONEDNN_FOR_GPU "ON")
    if(_OV_ENABLE_ONEDNN_FOR_GPU AND NOT TARGET onednn_gpu_tgt)
        set(_OV_DNNL_GPU_LIBRARY_NAME "openvino_onednn_gpu")

        set(_ov_in_install_tree "${PACKAGE_PREFIX_DIR}/runtime/lib/intel64/Release")
        if(_ov_in_install_tree)
            set(onednn_gpu_lib "${CMAKE_STATIC_LIBRARY_PREFIX}${_OV_DNNL_GPU_LIBRARY_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}")
            set_and_check(onednn_gpu_lib_root "${PACKAGE_PREFIX_DIR}/runtime/lib/intel64/Release")
            if(WIN32)
                if(OV_GENERATOR_MULTI_CONFIG)
                    set(extra_args PATH_SUFFIXES ${CMAKE_CONFIGURATION_TYPES})
                else()
                    set(extra_args PATH_SUFFIXES ${CMAKE_BUILD_TYPE})
                endif()
            endif()

            find_library(onednn_gpu_lib_path
                         NAMES ${_OV_DNNL_GPU_LIBRARY_NAME}
                         PATHS ${onednn_gpu_lib_root}
                         ${extra_args})

            if(NOT onednn_gpu_lib_path)
                message(FATAL_ERROR "Internal error: failed to find '${_OV_DNNL_GPU_LIBRARY_NAME}' in '${onednn_gpu_lib_root}'")
            endif()

            unset(extra_args)
            unset(onednn_gpu_lib)
        else()
            set_and_check(onednn_gpu_lib_path "")
        endif()

        set_target_properties(openvino::onednn_gpu_tgt PROPERTIES
            INTERFACE_LINK_LIBRARIES "${onednn_gpu_lib_path}")

        unset(onednn_gpu_lib_path)
        unset(_ov_in_install_tree)
        unset(_OV_DNNL_GPU_LIBRARY_NAME)
    endif()
    unset(_OV_ENABLE_ONEDNN_FOR_GPU)
endmacro()

macro(_ov_find_protobuf_frontend_dependency)
    set(_OV_ENABLE_SYSTEM_PROTOBUF "OFF")
    set(_OV_PROTOBUF_PACKAGE_CONFIG "")
    if(_OV_ENABLE_SYSTEM_PROTOBUF)
        _ov_find_dependency(Protobuf  EXACT ${_OV_PROTOBUF_PACKAGE_CONFIG})
    endif()
    unset(_OV_PROTOBUF_PACKAGE_CONFIG)
    unset(_OV_ENABLE_SYSTEM_PROTOBUF)
endmacro()

macro(_ov_find_tensorflow_frontend_dependencies)
    set(_OV_ENABLE_SYSTEM_SNAPPY "OFF")
    set(_ov_snappy_lib "")
    if(_OV_ENABLE_SYSTEM_SNAPPY)
        _ov_find_dependency(Snappy  EXACT)
    endif()
    unset(_OV_ENABLE_SYSTEM_SNAPPY)
    unset(_ov_snappy_lib)
    set(PACKAGE_PREFIX_DIR ${_ov_package_prefix_dir})
endmacro()

macro(_ov_find_onnx_frontend_dependencies)
    set(_OV_ENABLE_SYSTEM_ONNX "0")
    if(_OV_ENABLE_SYSTEM_ONNX)
        _ov_find_dependency(ONNX  EXACT)
    endif()
    unset(_OV_ENABLE_SYSTEM_ONNX)
endmacro()

function(_ov_target_no_deprecation_error)
    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        # older macOS x86_64 does not support this linker option
        if(CMAKE_CROSSCOMPILING AND NOT APPLE)
            set_target_properties(${ARGV} PROPERTIES
                                  INTERFACE_LINK_OPTIONS "-Wl,--allow-shlib-undefined")
        endif()

        if(CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
            set(flags "-diag-warning=1786")
        else()
            set(flags "-Wno-error=deprecated-declarations")
        endif()

        set_target_properties(${ARGV} PROPERTIES INTERFACE_COMPILE_OPTIONS $<$<NOT:$<BOOL:$<TARGET_PROPERTY:TREAT_DEPRECATED_DECLARATIONS_AS_ERRORS>>>:${flags}>)
    endif()
endfunction()

#
# OpenVINO config
#

cmake_policy(PUSH)
# we need CMP0057 to allow IN_LIST in if() command
if(POLICY CMP0057)
    cmake_policy(SET CMP0057 NEW)
else()
    message(FATAL_ERROR "OpenVINO requires CMake 3.3 or newer")
endif()

# need to store current PACKAGE_PREFIX_DIR, because it's overwritten by sub-package one
set(_ov_package_prefix_dir "${PACKAGE_PREFIX_DIR}")

set(_OV_ENABLE_OPENVINO_BUILD_SHARED "ON")

if(NOT TARGET openvino)
    set(_ov_as_external_package ON)
    include("${CMAKE_CURRENT_LIST_DIR}/OpenVINOTargets.cmake")

    # since OpenVINO is compiled with _GLIBCXX_USE_CXX11_ABI=0
    if(NOT OpenVINO_GLIBCXX_USE_CXX11_ABI STREQUAL "")
        add_definitions(-D_GLIBCXX_USE_CXX11_ABI=${OpenVINO_GLIBCXX_USE_CXX11_ABI})
    endif()
endif()

macro(_ov_enable_threading_interface)
    _ov_find_tbb()
    _ov_find_openmp()
endmacro()

if(NOT _OV_ENABLE_OPENVINO_BUILD_SHARED)
    # common openvino dependencies
    _ov_enable_threading_interface()

    _ov_find_itt()
    _ov_find_pugixml()

    # frontend dependencies
    _ov_find_protobuf_frontend_dependency()
    _ov_find_tensorflow_frontend_dependencies()
    _ov_find_onnx_frontend_dependencies()

    # plugin dependencies
    _ov_find_intel_cpu_dependencies()
    _ov_find_intel_gpu_dependencies()
endif()

_ov_find_dependency(Threads)

unset(_OV_ENABLE_OPENVINO_BUILD_SHARED)

set(_ov_imported_libs openvino::runtime openvino::runtime::c
   openvino::frontend::onnx openvino::frontend::paddle openvino::frontend::tensorflow
   openvino::frontend::pytorch openvino::frontend::tensorflow_lite)

if(_ov_as_external_package)
    foreach(target IN LISTS _ov_imported_libs)
        if(TARGET ${target})
            get_target_property(imported_configs ${target} IMPORTED_CONFIGURATIONS)
            if(NOT RELWITHDEBINFO IN_LIST imported_configs)
                set_property(TARGET ${target} PROPERTY MAP_IMPORTED_CONFIG_RELWITHDEBINFO RELEASE)
            endif()
            unset(imported_configs)
        endif()
    endforeach()

    # WA for cmake version < 3.16 which does not export
    # IMPORTED_LINK_DEPENDENT_LIBRARIES_** properties if no PUBLIC dependencies for the library
    if(THREADING STREQUAL "TBB" OR THREADING STREQUAL "TBB_AUTO")
        foreach(type RELEASE DEBUG RELWITHDEBINFO MINSIZEREL)
            foreach(tbb_target TBB::tbb TBB::tbbmalloc PkgConfig::tbb)
                if(TARGET ${tbb_target})
                    set_property(TARGET openvino::runtime APPEND PROPERTY IMPORTED_LINK_DEPENDENT_LIBRARIES_${type} "${tbb_target}")
                endif()
            endforeach()
        endforeach()
    endif()
    unset(THREADING)
endif()

#
# Components
#

set(${CMAKE_FIND_PACKAGE_NAME}_Runtime_FOUND ON)
set(${CMAKE_FIND_PACKAGE_NAME}_Threading_FOUND ON)

set(${CMAKE_FIND_PACKAGE_NAME}_ONNX_FOUND ON)
set(${CMAKE_FIND_PACKAGE_NAME}_Paddle_FOUND ON)
set(${CMAKE_FIND_PACKAGE_NAME}_TensorFlow_FOUND ON)
set(${CMAKE_FIND_PACKAGE_NAME}_TensorFlowLite_FOUND ON)
set(${CMAKE_FIND_PACKAGE_NAME}_IR_FOUND ON)
set(${CMAKE_FIND_PACKAGE_NAME}_PyTorch_FOUND ON)

set(${CMAKE_FIND_PACKAGE_NAME}_Frontend_ONNX_FOUND ${${CMAKE_FIND_PACKAGE_NAME}_ONNX_FOUND})
set(${CMAKE_FIND_PACKAGE_NAME}_Frontend_Paddle_FOUND ${${CMAKE_FIND_PACKAGE_NAME}_Paddle_FOUND})
set(${CMAKE_FIND_PACKAGE_NAME}_Frontend_TensorFlow_FOUND ${${CMAKE_FIND_PACKAGE_NAME}_TensorFlow_FOUND})
set(${CMAKE_FIND_PACKAGE_NAME}_Frontend_TensorFlowLite_FOUND ${${CMAKE_FIND_PACKAGE_NAME}_TensorFlowLite_FOUND})
set(${CMAKE_FIND_PACKAGE_NAME}_Frontend_IR_FOUND ${${CMAKE_FIND_PACKAGE_NAME}_IR_FOUND})
set(${CMAKE_FIND_PACKAGE_NAME}_Frontend_PyTorch_FOUND ${${CMAKE_FIND_PACKAGE_NAME}_PyTorch_FOUND})

# if no components specified, only Runtime is provided
if(NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
    set(${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS Runtime)
endif()

if(Threading IN_LIST ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS AND NOT TARGET openvino::threading)
    add_library(openvino::threading INTERFACE IMPORTED)

    _ov_enable_threading_interface()

    if(TARGET TBB::tbb)
        set(_ov_threading_lib TBB::tbb)
    elseif(TARGET IntelOpenMP::OpenMP_CXX)
        set(_ov_threading_lib IntelOpenMP::OpenMP_CXX)
    elseif(TARGET OpenMP::OpenMP_CXX)
        set(_ov_threading_lib OpenMP::OpenMP_CXX)
    endif()

    if(_ov_threading_lib)
        set_target_properties(openvino::threading PROPERTIES INTERFACE_LINK_LIBRARIES ${_ov_threading_lib})
        unset(_ov_threading_lib)
    endif()
endif()

#
# Apply common functions
#

foreach(target IN LISTS _ov_imported_libs)
    if(TARGET ${target} AND _ov_as_external_package)
        _ov_target_no_deprecation_error(${target})
    endif()
endforeach()
unset(_ov_imported_libs)
unset(_ov_as_external_package)

# restore PACKAGE_PREFIX_DIR
set(PACKAGE_PREFIX_DIR ${_ov_package_prefix_dir})
unset(_ov_package_prefix_dir)

check_required_components(${CMAKE_FIND_PACKAGE_NAME})

if(_need_package_name_reset)
    unset(CMAKE_FIND_PACKAGE_NAME)
    unset(_need_package_name_reset)
endif()

unset(${CMAKE_FIND_PACKAGE_NAME}_IR_FOUND)
unset(${CMAKE_FIND_PACKAGE_NAME}_Paddle_FOUND)
unset(${CMAKE_FIND_PACKAGE_NAME}_ONNX_FOUND)
unset(${CMAKE_FIND_PACKAGE_NAME}_TensorFlow_FOUND)
unset(${CMAKE_FIND_PACKAGE_NAME}_TensorFlowLite_FOUND)
unset(${CMAKE_FIND_PACKAGE_NAME}_PyTorch_FOUND)

cmake_policy(POP)
