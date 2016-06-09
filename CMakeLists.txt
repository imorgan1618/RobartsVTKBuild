PROJECT(RobartsVTKSuperBuild)

# CMake version requirements
CMAKE_MINIMUM_REQUIRED(VERSION 3.2)
cmake_policy(SET CMP0003 NEW)

IF(WIN32)
  SET(PKG_CONFIG_EXECUTABLE ${CMAKE_SOURCE_DIR}/Libs/pkg-config/pkg-config.exe)
ENDIF()
find_package(PkgConfig QUIET)

SET(RobartsVTKLib_PROJECT_ARGS)
SET(RobartsVTKLib_DEPENDENCIES)

# RobartsVTK Options
OPTION(RobartsVTK_USE_QT "Build with QT enabled" OFF)
OPTION(RobartsVTK_USE_ITK "Use ITK in RobartsITK" OFF)
OPTION(RobartsVTK_USE_PLUS "Use the PLUSToolkit for data collection." OFF)
OPTION(RobartsVTK_USE_REGISTRATION "Build the vtkRobartsRegistration module" OFF)
OPTION(RobartsVTK_USE_COMMON "Build the vtkRobartsCommon module" ON)
OPTION(RobartsVTK_USE_CUDA "Build the CUDA modules" OFF)
IF (RobartsVTK_USE_CUDA)
  OPTION(RobartsVTK_USE_CUDA_VISUALIZATION "Build the CUDA visualization modules" ON)
ENDIF()
OPTION(RobartsVTK_USE_OpenCL "Build the OpenCL modules" OFF)
OPTION(RobartsVTK_USE_VISUALIZATION  "Build the visualization modules" ON)
IF (RobartsVTK_USE_CUDA AND RobartsVTK_USE_COMMON)
  OPTION(RobartsVTK_USE_CUDA_ANALYTICS "Build the CUDA image analytics modules" ON)
ENDIF()
OPTION(RobartsVTK_BUILD_APPS "Build RobartsVTK applications." OFF)
OPTION(RobartsVTK_WRAP_PYTHON "Wrap the RobartsVTK libs in Python." ON)
OPTION(BUILD_SHARED_LIBS "Build shared libraries." ON)
OPTION(BUILD_TESTING "Build testing." OFF)
OPTION(BUILD_DOCUMENTATION "Build Documentation" OFF)
IF( RobartsVTK_USE_QT )
  OPTION(RobartsVTK_USE_QT5_ONLY "Only search for Qt5." OFF)
ENDIF()

SET(RobartsVTK_VTK_VERSION 6.3.0 CACHE STRING "The requested version of VTK to use")
set_property(CACHE RobartsVTK_VTK_VERSION PROPERTY STRINGS "6.3.0" "7.1.0")

#-----------------------------------------------------------------------------
# Preparatory setup
#-----------------------------------------------------------------------------
SET(Plus_DEPENDENCIES)
INCLUDE(ExternalProject)

#-----------------------------------------------------------------------------
# SVN - Let's check if a valid version of SVN is available
#-----------------------------------------------------------------------------
# Need subversion for the automatic update of the repository
MARK_AS_ADVANCED(CLEAR Subversion_SVN_EXECUTABLE)
FIND_FILE(Subversion_SVN_EXECUTABLE svn${CMAKE_EXECUTABLE_SUFFIX} 
  PATHS 
  "c:/Program Files/TortoiseSVN/bin/"
  "c:/Program Files/SlikSvn/bin/"
  )
FIND_PACKAGE(Subversion REQUIRED)

#-----------------------------------------------------------------------------
# ASSEMBLA - Set username and password for checking out Plus 
# Anonymous user name for Plus assembla server: https://subversion.assembla.com/svn/plus/
#-----------------------------------------------------------------------------
SET(PLUS_ASSEMBLA_USERNAME "perklab_anonymous" )
SET(PLUS_ASSEMBLA_PASSWORD "anonymous" )

#-----------------------------------------------------------------------------
# If Slicer_DIR is present, use it to load a number of dependency information
#-----------------------------------------------------------------------------
IF( Slicer_DIR )
  # The Slicer4 config file complains if these are set.
  UNSET (QT_QMAKE_EXECUTABLE CACHE)
  UNSET (QT_BINARY_DIR CACHE)
  UNSET (VTK_DIR CACHE)
  UNSET (ITK_DIR CACHE)
  UNSET (PYTHON_LIBRARY CACHE)
  UNSET (PYTHON_DEBUG_LIBRARY CACHE)

  FIND_PACKAGE(Slicer)
  
  IF( Slicer_FOUND )
    INCLUDE(${Slicer_USE_FILE})
  ENDIF()
  
  IF( ${QT_VERSION_MAJOR} EQUAL 4 )
    SET(RobartsVTK_USE_QT5_ONLY OFF)
  ENDIF()
  
  # Do not use the openigtlink provided by slicer, we are using igtl v3 in plus
  UNSET(OpenIGTLink_DIR CACHE)
  
  IF( VTK_WRAP_PYTHON )
    SET(RobartsVTK_WRAP_PYTHON ON)
  ENDIF()
ENDIF()

#-----------------------------------------------------------------------------
# GIT - Let's check if a valid version of GIT is available
#-----------------------------------------------------------------------------
SET(GIT_PROTOCOL "git")

IF( NOT GIT_EXECUTABLE)
  MARK_AS_ADVANCED(CLEAR GIT_EXECUTABLE)
  FIND_FILE(GIT_EXECUTABLE git${CMAKE_EXECUTABLE_SUFFIX} 
    PATHS 
      "c:/Program Files/Git/bin/"
      "c:/Program Files (x86)/Git/bin/"
    )
  FIND_PACKAGE(Git)
  IF(NOT GIT_FOUND)
    MESSAGE(FATAL_ERROR "ERROR: Install Git and try to re-configure")
  ENDIF()
ENDIF()

#-----------------------------------------------------------------------------
# Set up python choices to pass to VTK
#-----------------------------------------------------------------------------
SET(RobartsVTK_VTK_PYTHON_ARGS)
IF( RobartsVTK_WRAP_PYTHON )
  FIND_PACKAGE(PythonLibs REQUIRED)
  
  MARK_AS_ADVANCED(CLEAR PYTHON_INCLUDE_DIR)
  MARK_AS_ADVANCED(CLEAR PYTHON_LIBRARY)
  IF( PythonLibs_FOUND )
    MARK_AS_ADVANCED(CLEAR PYTHON_INCLUDE_DIR)
    MARK_AS_ADVANCED(CLEAR PYTHON_LIBRARY)
    GET_FILENAME_COMPONENT(PYTHON_DIR ${PYTHON_INCLUDE_DIR} DIRECTORY)
    FIND_FILE(PYTHON_EXECUTABLE python${CMAKE_EXECUTABLE_SUFFIX} 
      PATHS
      ${PYTHON_DIR}
      NO_SYSTEM_ENVIRONMENT_PATH
    )

    SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DPYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR} -DPYTHON_LIBRARY:FILEPATH=${PYTHON_LIBRARY} -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON_EXECUTABLE})
  ENDIF()
ENDIF()

#-----------------------------------------------------------------------------
# Qt comes first so we know which version to pass to VTK
#-----------------------------------------------------------------------------
IF(RobartsVTK_USE_QT)
  IF( NOT QT_QMAKE_EXECUTABLE )
    FIND_FILE(QT_QMAKE_EXECUTABLE qmake${CMAKE_EXECUTABLE_SUFFIX} 
      PATH
        $ENV{QTDIR}
        "C:/Qt/4.7.4/bin"
        "../Qt/4.7.4/bin"
        "../../Qt/4.7.4/bin"
        "C:/Qt/4.8.7/bin"
        "../Qt/4.8.7/bin"
        "../../Qt/4.8.7/bin"
      )
  ENDIF()

  IF(NOT RobartsVTK_USE_QT5_ONLY)
      FIND_PACKAGE(Qt4 QUIET)
  ENDIF()

  IF ( NOT QT4_FOUND )
    IF(WIN32 AND EXISTS ${QT_QMAKE_EXECUTABLE} AND "${Qt5_DIR}" STREQUAL "Qt5_DIR-NOTFOUND")
      # In Windows, support the QT_QMAKE_EXECUTABLE way for Qt5
      GET_FILENAME_COMPONENT(ROBARTS_QT_BIN_DIR ${QT_QMAKE_EXECUTABLE} DIRECTORY)
      GET_FILENAME_COMPONENT(ROBARTS_QT_TOP_DIR ${ROBARTS_QT_BIN_DIR} DIRECTORY)
      GET_FILENAME_COMPONENT(CMAKE_PREFIX_PATH ${ROBARTS_QT_BIN_DIR} DIRECTORY)
      SET(Qt5_DIR ${ROBARTS_QT_TOP_DIR}/lib/cmake/Qt5 FORCE)
    ELSEIF(WIN32 AND EXISTS ${QT_QMAKE_EXECUTABLE})
      GET_FILENAME_COMPONENT(ROBARTS_QT_BIN_DIR ${QT_QMAKE_EXECUTABLE} DIRECTORY)
      GET_FILENAME_COMPONENT(ROBARTS_QT_TOP_DIR ${ROBARTS_QT_BIN_DIR} DIRECTORY)
      GET_FILENAME_COMPONENT(CMAKE_PREFIX_PATH ${ROBARTS_QT_BIN_DIR} DIRECTORY)
    ENDIF()

    FIND_PACKAGE(Qt5 QUIET COMPONENTS Widgets NO_MODULE)

    IF ( NOT Qt5_FOUND )
      MESSAGE( FATAL_ERROR "This project requires Qt4 or Qt5 for building RobartsVTK. These components are missing. Please verify configuration by selecting QT_QMAKE_EXECUTABLE (Qt4) or Qt5_DIR (Qt5) or turn off RobartsVTK_USE_QT option.")
    ENDIF()

    IF(UNIX AND "${Qt5_DIR}" MATCHES "cmake")
      GET_FILENAME_COMPONENT(CMAKE_PREFIX_PATH ${Qt5_DIR} DIRECTORY)
    ENDIF()

    IF( WIN32 AND "${QT_QMAKE_EXECUTABLE}" STREQUAL "NOTFOUND" )
      GET_FILENAME_COMPONENT(ROBARTS_QT_CMAKE_DIR ${Qt5_DIR} DIRECTORY)
      GET_FILENAME_COMPONENT(ROBARTS_QT_LIB_DIR ${ROBARTS_QT_CMAKE_DIR} DIRECTORY)
      GET_FILENAME_COMPONENT(ROBARTS_QT_TOP_DIR ${ROBARTS_QT_LIB_DIR} DIRECTORY)
      SET(QT_QMAKE_EXECUTABLE ${ROBARTS_QT_TOP_DIR}/bin/qmake${CMAKE_EXECUTABLE_SUFFIX} CACHE FILEPATH "Location of Qt qmake executable." FORCE)
    ENDIF()

    SET(QT_VERSION_MAJOR ${Qt5_VERSION_MAJOR})
  ENDIF()

  SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE})
  IF( QT4_FOUND )
    SET(RobartsVTKLib_DEPENDENCIES ${RobartsVTKLib_DEPENDENCIES} Qt4::QtCore)
  ELSE()
    SET(RobartsVTKLib_DEPENDENCIES ${RobartsVTKLib_DEPENDENCIES} Qt5::Widgets)
    SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DQt5_DIR:PATH=${Qt5_DIR})
  ENDIF()
ENDIF()

#-----------------------------------------------------------------------------
# External project build flags
#-----------------------------------------------------------------------------
SET(ADDITIONAL_C_FLAGS "" CACHE STRING "Additional C Flags")
MARK_AS_ADVANCED(ADDITIONAL_C_FLAGS)

IF(UNIX AND NOT APPLE)
  EXECUTE_PROCESS(COMMAND ${CMAKE_C_COMPILER} -dumpversion
                  OUTPUT_VARIABLE GCC_VERSION)
  STRING(REGEX MATCHALL "[0-9]+" GCC_VERSION_COMPONENTS ${GCC_VERSION})
  LIST(GET GCC_VERSION_COMPONENTS 0 GCC_MAJOR)
  LIST(GET GCC_VERSION_COMPONENTS 1 GCC_MINOR)

  # Allow inline namespacing to enable Qt::Orientation:: etc..
  IF(${GCC_VERSION} VERSION_GREATER 4.6)
    SET(ADDITIONAL_CXX_FLAGS "-std=c++11" CACHE STRING "Additional CXX Flags")
  ELSE()
    MESSAGE(FATAL_ERROR "gcc >= 4.7 required to build RobartsVTK. gcc >= 4.9 recommended.")
  ENDIF()
ENDIF()
MARK_AS_ADVANCED(ADDITIONAL_CXX_FLAGS)

SET(ep_common_args)

IF(NOT ${CMAKE_GENERATOR} MATCHES "Visual Studio")
  SET(ep_common_args
    ${ep_common_args}
    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
    )
ENDIF()

SET(ep_common_c_flags "${CMAKE_C_FLAGS} ${ADDITIONAL_C_FLAGS}")
SET(ep_common_cxx_flags "${CMAKE_CXX_FLAGS} ${ADDITIONAL_CXX_FLAGS}")

SET(ep_dependency_DIR ${CMAKE_BINARY_DIR}/Deps)

#-----------------------------------------------------------------------------
# VTK
#-----------------------------------------------------------------------------
INCLUDE(External_VTK.cmake)

IF( VTK_DIR )
  SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DVTK_DIR:PATH=${VTK_DIR})
ELSE()
  IF( RobartsVTK_USE_PLUS )
    SET(Plus_DEPENDENCIES ${Plus_DEPENDENCIES} vtk)
    SET(VTK_DIR ${RobartsVTK_VTK_DIR}) # to send to PLUS
  ENDIF()
  SET(RobartsVTKLib_DEPENDENCIES ${RobartsVTKLib_DEPENDENCIES} vtk)
  SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DVTK_DIR:PATH=${RobartsVTK_VTK_DIR})
ENDIF()

#-----------------------------------------------------------------------------
# ITK
#-----------------------------------------------------------------------------
IF(RobartsVTK_USE_ITK)
  INCLUDE(External_ITK.cmake)
  
  IF( ITK_DIR )
    SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DITK_DIR:PATH=${ITK_DIR})
  ELSE()
    IF( RobartsVTK_USE_PLUS )
      SET(Plus_DEPENDENCIES ${Plus_DEPENDENCIES} itk)
      SET(ITK_DIR ${RobartsVTK_ITK_DIR}) # to send to PLUS
    ENDIF()

    SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DITK_DIR:PATH=${RobartsVTK_ITK_DIR})
    SET(RobartsVTKLib_DEPENDENCIES ${RobartsVTKLib_DEPENDENCIES} itk)
  ENDIF()
ENDIF()

#-----------------------------------------------------------------------------
# OpenCV
#-----------------------------------------------------------------------------
IF(RobartsVTK_BUILD_APPS)
  INCLUDE(External_OpenCV.cmake)
  
  IF( OpenCV_DIR )
    SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DOpenCV_DIR:PATH=${OpenCV_DIR})
  ELSE()
    SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DOpenCV_DIR:PATH=${RobartsVTK_OpenCV_DIR})
  ENDIF()

  SET(RobartsVTKLib_DEPENDENCIES ${RobartsVTKLib_DEPENDENCIES} OpenCV)
  
  IF(RobartsVTK_USE_PLUS)
    SET(Plus_DEPENDENCIES ${Plus_DEPENDENCIES} OpenCV)
    IF( OpenCV_DIR )
      SET(OpenCV_Dependency_Arg -DOpenCV_DIR:PATH=${OpenCV_DIR})
    ELSE
      SET(OpenCV_Dependency_Arg -DOpenCV_DIR:PATH=${RobartsVTK_OpenCV_DIR})
    ENDIF()
  ENDIF()
ENDIF()

#-----------------------------------------------------------------------------
# PLUS
#-----------------------------------------------------------------------------
IF(RobartsVTK_USE_PLUS)
  INCLUDE(External_PlusBuild.cmake)

  SET(RobartsVTK_PlusLib_BIN_DIR ${PLUS_BIN_DIR}/PlusLib-bin)
  SET(RobartsVTK_PlusApp_BIN_DIR ${PLUS_BIN_DIR}/PlusApp-bin)

  SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DPlusLib_DIR:PATH=${RobartsVTK_PlusLib_BIN_DIR})
  SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DPlusApp_DIR:PATH=${RobartsVTK_PlusApp_BIN_DIR})

  IF(PlusLib_DIR)
    SET(RobartsVTKLib_DEPENDENCIES ${RobartsVTKLib_DEPENDENCIES} PlusLib)
  ELSE()
    SET(RobartsVTKLib_DEPENDENCIES ${RobartsVTKLib_DEPENDENCIES} Plus)
  ENDIF()
  
  IF( PlusApp_DIR )
    SET(RobartsVTKLib_DEPENDENCIES ${RobartsVTKLib_DEPENDENCIES} PlusApp)
  ELSE()
    SET(RobartsVTKLib_DEPENDENCIES ${RobartsVTKLib_DEPENDENCIES} Plus)
  ENDIF()
ENDIF()

IF (RobartsVTK_USE_CUDA)
  FIND_PACKAGE(CUDA REQUIRED)

  SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DCUDA_TOOLKIT_ROOT_DIR:PATH=${CUDA_TOOLKIT_ROOT_DIR})
ENDIF()

#-----------------------------------------------------------------------------
# CUDA
#-----------------------------------------------------------------------------
IF (RobartsVTK_USE_CUDA)
  FIND_PACKAGE(CUDA REQUIRED)

  SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DCUDA_TOOLKIT_ROOT_DIR:PATH=${CUDA_TOOLKIT_ROOT_DIR})
ENDIF()

IF(RobartsVTK_USE_VISUALIZATION)
  IF(PKG_CONFIG_FOUND)
    pkg_check_modules(ZLIB zlib QUIET)
    IF(ZLIB_FOUND AND NOT TARGET zlib)
      ADD_LIBRARY(zlib IMPORTED SHARED)
      SET_PROPERTY(TARGET zlib PROPERTY IMPORTED_LOCATION ${ZLIB_LIBRARY_DIRS}/lib${ZLIB_LIBRARIES}${CMAKE_SHARED_LIBRARY_SUFFIX})
      SET_PROPERTY(TARGET zlib PROPERTY IMPORTED_IMPLIB ${ZLIB_LIBRARY_DIRS}/lib${ZLIB_LIBRARIES}${CMAKE_STATIC_LIBRARY_SUFFIX})
    ENDIF()
  ELSE()
    FIND_PACKAGE(zlib QUIET)
  ENDIF()

  IF(NOT ZLIB_FOUND)
    INCLUDE(External_zlib.cmake)
    SET(ZLIB_ROOT ${RobartsVTK_zlib_DIR}/install)
  ENDIF()
  SET(libpng_DEPENDENCIES zlib)
  
  INCLUDE(External_PNG.cmake)
  INCLUDE(External_FFTW.cmake)
  
  LIST(APPEND RobartsVTKLib_DEPENDENCIES FFTW libpng zlib)
  
  SET(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} ${RobartsVTK_PNG_DIR}/install)
  SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DZLIB_ROOT:PATH=${ZLIB_ROOT} -DFFTW_ROOT_DIR:PATH=${RobartsVTK_FFTW_DIR} -DPNG_CMAKE_FILE:FILEPATH=${RobartsVTK_PNG_DIR}/install/lib/libpng/libpng16.cmake)
ENDIF()

IF (RobartsVTK_USE_OpenCL)
  FIND_PACKAGE(OpenCL REQUIRED)
  OPTION(RobartsVTK_USE_CL_VOLUMERECONSTRUCTION "Build the OpenCL Volume Reconstruction modules" ON)
ENDIF()

#-----------------------------------------------------------------------------
# RobartsVTKLib download
#-----------------------------------------------------------------------------
  SET (RobartsVTK_SRC_DIR "${CMAKE_BINARY_DIR}/RobartsVTKLib")
  SET (RobartsVTK_BIN_DIR "${CMAKE_BINARY_DIR}/RobartsVTKLib-bin" CACHE INTERNAL "Path to store RobartsVTK binaries")
  ExternalProject_Add( RobartsVTKLib
    PREFIX "${CMAKE_BINARY_DIR}/RobartsVTKLib-prefix"
    SOURCE_DIR "${RobartsVTK_SRC_DIR}"
    BINARY_DIR "${RobartsVTK_BIN_DIR}"
    #--Download step--------------
    GIT_REPOSITORY http://Git.imaging.robarts.ca/vasst/RobartsVTK.git
    GIT_TAG master
    #--Configure step-------------
    CMAKE_ARGS 
      -DRobartsVTK_USE_QT:BOOL=${RobartsVTK_USE_QT} 
      -DRobartsVTK_USE_ITK:BOOL=${RobartsVTK_USE_ITK} 
      -DRobartsVTK_USE_PLUS:BOOL=${RobartsVTK_USE_PLUS} 
      -DRobartsVTK_USE_REGISTRATION:BOOL=${RobartsVTK_USE_REGISTRATION} 
      -DRobartsVTK_USE_COMMON:BOOL=${RobartsVTK_USE_COMMON} 
      -DRobartsVTK_USE_CUDA:BOOL=${RobartsVTK_USE_CUDA} 
      -DRobartsVTK_USE_CUDA_VISUALIZATION:BOOL=${RobartsVTK_USE_CUDA_VISUALIZATION} 
      -DRobartsVTK_USE_VISUALIZATION:BOOL=${RobartsVTK_USE_VISUALIZATION} 
      -DRobartsVTK_USE_OpenCL:BOOL=${RobartsVTK_USE_OpenCL}
      -DRobartsVTK_USE_CL_VOLUMERECONSTRUCTION:BOOL=${RobartsVTK_USE_CL_VOLUMERECONSTRUCTION}
      -DRobartsVTK_USE_CUDA_ANALYTICS:BOOL=${RobartsVTK_USE_CUDA_ANALYTICS} 
      -DRobartsVTK_USE_QT5_ONLY:BOOL=${RobartsVTK_USE_QT5_ONLY}
      -DRobartsVTK_BUILD_APPS:BOOL=${RobartsVTK_BUILD_APPS} 
      -DRobartsVTK_WRAP_PYTHON:BOOL=${RobartsVTK_WRAP_PYTHON} 
      -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS} 
      -DBUILD_TESTING:BOOL=${BUILD_TESTING} 
      -DBUILD_DOCUMENTATION:BOOL=${BUILD_DOCUMENTATION} 
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DRobartsVTK_VTK_VERSION:STRING=${RobartsVTK_VTK_VERSION}
      ${RobartsVTKLib_PROJECT_ARGS}
    #--Build step-----------------
    #--Install step-----------------
    INSTALL_COMMAND "" # Do not install
    DEPENDS ${RobartsVTKLib_DEPENDENCIES}
    )
