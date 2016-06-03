IF(fftw_ROOT_DIR)
  # FFTW has been built already
  FIND_PACKAGE(FFTW REQUIRED)
  
  MESSAGE(STATUS "Using FFTW available at: ${fftw_ROOT_DIR}")
  
  SET(RobartsVTK_FFTW_DIR ${fftw_ROOT_DIR})
ELSE()
  SET (RobartsVTK_FFTW_DIR "${ep_dependency_DIR}/FFTW-bin" CACHE INTERNAL "Path to store FFTW binaries")

  # FFTW has not been built yet, so download and build it as an external project
  IF(MSVC)
    SET(FFTW_BUILD_COMMAND "")
    SET(FFTW_INSTALL_COMMAND "")

    # Extract VS version for use in script
    STRING(REGEX REPLACE "Visual Studio ([0-9]*) .*" "\\1" VS_IDE_VERSION ${CMAKE_GENERATOR})

    # Locate comntools variable for this VS IDE version, much easier to do this in CMake
    # then in batch script (for me!)
    IF("$ENV{VS${VS_IDE_VERSION}0COMNTOOLS}" STREQUAL "")
      MESSAGE(FATAL_ERROR "MSVC: ${CMAKE_GENERATOR} is used, but the associated VS${VS_IDE_VERSION}0COMNTOOLS} environment variable is not set. Cannot generate lib files for FFTW.")
    ENDIF()

    GET_FILENAME_COMPONENT(VS_COMMON7_DIR $ENV{VS${VS_IDE_VERSION}0COMNTOOLS} DIRECTORY)
    GET_FILENAME_COMPONENT(VS_ROOT_DIR ${VS_COMMON7_DIR} DIRECTORY)
    
    IF(${CMAKE_GENERATOR} MATCHES "Win64" )
      SET(FFTW_URL "${CMAKE_SOURCE_DIR}/Libs/FFTW/fftw-3.3.4-dll64.tar.gz")
      SET(FFTW_CONFIGURE_COMMAND ${CMAKE_SOURCE_DIR}/Libs/FFTW/msvc_lib_generation.bat "${VS_ROOT_DIR}/VC/vcvarsall.bat" x86_amd64 ${RobartsVTK_FFTW_DIR})
    ELSE()
      SET(FFTW_URL "${CMAKE_SOURCE_DIR}/Libs/FFTW/fftw-3.3.4-dll32.tar.gz")
      SET(FFTW_CONFIGURE_COMMAND ${CMAKE_SOURCE_DIR}/Libs/FFTW/msvc_lib_generation.bat "${VS_ROOT_DIR}/VC/vcvarsall.bat" x86 ${RobartsVTK_FFTW_DIR})
    ENDIF()
  ELSE()
    SET(FFTW_CONFIGURE_COMMAND ${RobartsVTK_FFTW_DIR}/configure --prefix=${RobartsVTK_FFTW_DIR})
    SET(FFTW_BUILD_COMMAND make -j 4)
    SET(FFTW_INSTALL_COMMAND make install)
    SET(FFTW_URL "${CMAKE_SOURCE_DIR}/Libs/FFTW/fftw-3.3.4.tar.gz")
  ENDIF()

  MESSAGE(STATUS "Downloading FFTW from: ${FFTW_URL}")

  ExternalProject_Add( FFTW
    PREFIX "${ep_dependency_DIR}/FFTW-prefix"
    SOURCE_DIR ${RobartsVTK_FFTW_DIR}
    BINARY_DIR ${RobartsVTK_FFTW_DIR}
    DOWNLOAD_DIR ${ep_dependency_DIR}/FFTW-download
    #--Download step--------------
    URL ${FFTW_URL}
    #--Configure step-------------
    CONFIGURE_COMMAND "${FFTW_CONFIGURE_COMMAND}"
    #--Build step-----------------
    BUILD_COMMAND "${FFTW_BUILD_COMMAND}"
    #--Install step-----------------
    INSTALL_COMMAND "${FFTW_INSTALL_COMMAND}"
    )

ENDIF()
