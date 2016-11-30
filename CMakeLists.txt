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
OPTION(RobartsVTK_USE_QT "Build with QT enabled" ON)
OPTION(RobartsVTK_USE_ITK "Use ITK in RobartsITK" ON)
OPTION(RobartsVTK_USE_PLUS "Use the PLUSToolkit for data collection." ON)
OPTION(RobartsVTK_USE_REGISTRATION "Build the vtkRobartsRegistration module" ON)
OPTION(RobartsVTK_USE_COMMON "Build the vtkRobartsCommon module" ON)
OPTION(RobartsVTK_USE_CUDA "Build the CUDA modules" ON)
IF (RobartsVTK_USE_CUDA)
  OPTION(RobartsVTK_USE_CUDA_VISUALIZATION "Build the CUDA visualization modules" ON)
ENDIF()
IF (RobartsVTK_USE_CUDA AND RobartsVTK_USE_COMMON)
  OPTION(RobartsVTK_USE_CUDA_ANALYTICS "Build the CUDA image analytics modules" ON)
ENDIF()
OPTION(RobartsVTK_USE_OpenCL "Build the OpenCL modules" ON)
OPTION(RobartsVTK_USE_VISUALIZATION  "Build the visualization modules" ON)
OPTION(RobartsVTK_BUILD_APPS "Build RobartsVTK applications." OFF)
OPTION(BUILD_SHARED_LIBS "Build shared libraries." ON)
OPTION(BUILD_TESTING "Build testing." OFF)
OPTION(BUILD_DOCUMENTATION "Build Documentation" OFF)

#-----------------------------------------------------------------------------
# PLUS device variables
#-----------------------------------------------------------------------------
OPTION(PLUS_USE_ULTRASONIX_VIDEO "Provide support for the Ultrasonix ultrasound systems" OFF)
SET(PLUS_ULTRASONIX_SDK_MAJOR_VERSION 5 CACHE STRING "Set Ultrasonix SDK major version (version: [major].[minor].[patch])")
SET(PLUS_ULTRASONIX_SDK_MINOR_VERSION 7 CACHE STRING "Set Ultrasonix SDK minor version (version: [major].[minor].[patch])")
SET(PLUS_ULTRASONIX_SDK_PATCH_VERSION 4 CACHE STRING "Set Ultrasonix SDK patch version (version: [major].[minor].[patch])")
OPTION(PLUS_USE_BKPROFOCUS_VIDEO "Provide support for BK ProFocus ultrasound systems through the OEM (TCP/IP) interface" OFF)
OPTION(PLUS_USE_ICCAPTURING_VIDEO "Provide support for the IC framegrabber device" OFF)
OPTION(PLUS_USE_VFW_VIDEO "Provide support for the Video-for-Windows video digitizer (legacy, use Microsoft Media Foundation instead)" OFF)
OPTION(PLUS_USE_MMF_VIDEO "Provide support for the Microsoft Media Foundation video digitizers (requires installation of Windows Platform SDK 7.1 or later)" OFF)
OPTION(PLUS_USE_EPIPHAN "Provide support for the Epiphan framegrabber device" OFF)
OPTION(PLUS_USE_CAPISTRANO_VIDEO "Provide support for the Capistrano Labs USB ultrasound probes" OFF)
OPTION(PLUS_USE_INTERSON_VIDEO "Provide support for the Interson USB ultrasound probes" OFF)
OPTION(PLUS_USE_INTERSONSDKCXX_VIDEO "Provide support for the Interson SDK 1.X with C++ Wrapper USB ultrasound probes" OFF)
OPTION(PLUS_USE_TELEMED_VIDEO "Provide support for the Telemed ultrasound probes" OFF)
OPTION(PLUS_USE_THORLABS_VIDEO "Provide support for the ThorLabs Compact Spectrometers" OFF)
OPTION(PLUS_USE_OPTITRACK "Provide support for the OptiTrack tracking system" OFF)
OPTION(PLUS_USE_OPTIMET_CONOPROBE "Provide support for the Optimet ConoProbe" OFF)
OPTION(PLUS_USE_NDI "Provide support for the NDI POLARIS and AURORA" OFF)
OPTION(PLUS_USE_NDI_CERTUS "Provide support for the NDI Certus" OFF)
OPTION(PLUS_USE_POLARIS "Provide support for the NDI POLARIS and AURORA" OFF)
OPTION(PLUS_USE_MICRONTRACKER "Provide support for the Claron MicronTracker" OFF)
OPTION(PLUS_USE_INTELREALSENSE "Provide support for Intel RealSense cameras" OFF)
OPTION(PLUS_USE_BRACHY_TRACKER "Provide support for the Brachy Steppers" OFF)
OPTION(PLUS_USE_USDIGITALENCODERS_TRACKER "Provide support for multiple USDigital encoders tracking device" OFF)
OPTION(PLUS_USE_Ascension3DG "Provide support for the Ascension 3DG Tracker" OFF)
OPTION(PLUS_USE_Ascension3DGm "Provide support for the Ascension MedSafe Tracker" OFF)
OPTION(PLUS_USE_PHIDGET_SPATIAL_TRACKER "Provide support for the Phidget Spatial accelerometer" OFF)
OPTION(PLUS_USE_3dConnexion_TRACKER "Provide support for the 3dConnexion 3d mouse" OFF)
OPTION(PLUS_USE_STEALTHLINK "Provide support for the Medtronick StealthLink Server" OFF)
OPTION(PLUS_USE_IntuitiveDaVinci "Provide support for the da Vinci Surgical System" OFF)
OPTION(PLUS_USE_OvrvisionPro "Provide support for the OvrvisionPro Stereo Camera" OFF)
OPTION(PLUS_USE_tesseract "Provide support for screen reading virtual device." OFF)
OPTION(PLUS_USE_PHILIPS_3D_ULTRASOUND "Provide support for the Philips ie33 3D ultrasound probe" OFF)
OPTION(PLUS_USE_NVIDIA_DVP "Provide support for the NVidia Digital Video Pipeline" OFF)
IF (PLUS_USE_NVIDIA_DVP)
  FIND_PACKAGE(QuadroSDI REQUIRED)
  FIND_PACKAGE(OpenGL REQUIRED)
ENDIF()

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
# Qt comes first so we know which version to pass to VTK
#-----------------------------------------------------------------------------
IF(RobartsVTK_USE_QT)
  FIND_PACKAGE(Qt5 REQUIRED COMPONENTS Widgets)

  SET(QT_VERSION_MAJOR ${Qt5_VERSION_MAJOR})

  SET(RobartsVTKLib_DEPENDENCIES ${RobartsVTKLib_DEPENDENCIES} Qt5::Widgets)
  SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DQt5_DIR:PATH=${Qt5_DIR})
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
  IF(${GCC_VERSION} VERSION_GREATER 4.8)
    SET(ADDITIONAL_CXX_FLAGS "-std=c++11" CACHE STRING "Additional CXX Flags")
  ELSE()
    MESSAGE(FATAL_ERROR "gcc >= 4.9 required to build RobartsVTK.")
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
INCLUDE(Superbuild/External_VTK.cmake)

IF( VTK_DIR )
  SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DVTK_DIR:PATH=${VTK_DIR})
ELSE()
  IF( RobartsVTK_USE_PLUS )
    SET(Plus_DEPENDENCIES ${Plus_DEPENDENCIES} vtk)
  ENDIF()
  SET(RobartsVTKLib_DEPENDENCIES ${RobartsVTKLib_DEPENDENCIES} vtk)
  SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DVTK_DIR:PATH=${RobartsVTK_VTK_DIR})
ENDIF()

#-----------------------------------------------------------------------------
# ITK
#-----------------------------------------------------------------------------
IF(RobartsVTK_USE_ITK)
  INCLUDE(Superbuild/External_ITK.cmake)
  
  IF( ITK_DIR )
    SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DITK_DIR:PATH=${ITK_DIR})
  ELSE()
    IF( RobartsVTK_USE_PLUS )
      SET(Plus_DEPENDENCIES ${Plus_DEPENDENCIES} itk)
    ENDIF()

    SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DITK_DIR:PATH=${RobartsVTK_ITK_DIR})
    SET(RobartsVTKLib_DEPENDENCIES ${RobartsVTKLib_DEPENDENCIES} itk)
  ENDIF()
ENDIF()

#-----------------------------------------------------------------------------
# OpenCV
#-----------------------------------------------------------------------------
IF(RobartsVTK_BUILD_APPS)
  INCLUDE(Superbuild/External_OpenCV.cmake)
  
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
    ELSE()
      SET(OpenCV_Dependency_Arg -DOpenCV_DIR:PATH=${RobartsVTK_OpenCV_DIR})
    ENDIF()
    
    IF(CUDA_FOUND)
      LIST(APPEND OpenCV_Dependency_Arg -DCUDA_TOOLKIT_ROOT_DIR:PATH=${CUDA_TOOLKIT_ROOT_DIR})
    ENDIF()
  ENDIF()
ENDIF()

#-----------------------------------------------------------------------------
# PLUS
#-----------------------------------------------------------------------------
IF(RobartsVTK_USE_PLUS)
  INCLUDE(Superbuild/External_PlusBuild.cmake)

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
  IF("${CMAKE_SIZEOF_VOID_P}" EQUAL "8")
    set(_generations "Fermi" "Kepler" "Maxwell" "Pascal")
    FIND_PACKAGE(CUDA 7.0 REQUIRED)
  ELSE()
    # Cuda support for 32bit ended with 6.5
    set(_generations "Fermi" "Kepler" "Maxwell")
    FIND_PACKAGE(CUDA 6.5 REQUIRED EXACT)
  ENDIF()

  # Allow the user to define the CUDA build architectures
  set(CUDA_GENERATION "" CACHE STRING "Build CUDA device code only for specific GPU architecture. Leave empty to build for all architectures.")
  set_property( CACHE CUDA_GENERATION PROPERTY STRINGS "" ${_generations} )

  SET(RobartsVTKLib_PROJECT_ARGS ${RobartsVTKLib_PROJECT_ARGS} -DCUDA_GENERATION:STRING=${CUDA_GENERATION} -DCUDA_TOOLKIT_ROOT_DIR:PATH=${CUDA_TOOLKIT_ROOT_DIR})
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
    INCLUDE(Superbuild/External_zlib.cmake)
    SET(ZLIB_ROOT ${RobartsVTK_zlib_DIR}/install)
  ENDIF()
  SET(libpng_DEPENDENCIES zlib)
  
  INCLUDE(Superbuild/External_PNG.cmake)
  INCLUDE(Superbuild/External_FFTW.cmake)
  
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
SET (RobartsVTK_SRC_DIR "${CMAKE_BINARY_DIR}/RVTKLib")
SET (RobartsVTK_BIN_DIR "${CMAKE_BINARY_DIR}/RVTKLib-bin" CACHE INTERNAL "Path to store RobartsVTK binaries")
ExternalProject_Add( RobartsVTKLib
  PREFIX "${CMAKE_BINARY_DIR}/RVTKLib-prefix"
  SOURCE_DIR "${RobartsVTK_SRC_DIR}"
  BINARY_DIR "${RobartsVTK_BIN_DIR}"
  #--Download step--------------
  GIT_REPOSITORY https://github.com/VASST/RobartsVTK.git
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
    -DRobartsVTK_BUILD_APPS:BOOL=${RobartsVTK_BUILD_APPS} 
    -DBUILD_SHARED_LIBS:BOOL=${BUILD_SHARED_LIBS} 
    -DBUILD_TESTING:BOOL=${BUILD_TESTING} 
    -DBUILD_DOCUMENTATION:BOOL=${BUILD_DOCUMENTATION} 
    -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
    -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
    ${RobartsVTKLib_PROJECT_ARGS}
    ${OpenCV_Dependency_Arg}
  #--Build step-----------------
  #--Install step-----------------
  INSTALL_COMMAND "" # Do not install
  DEPENDS ${RobartsVTKLib_DEPENDENCIES}
  )