IF(fftw_ROOT_DIR)
  # FFTW has been built already
  FIND_PACKAGE(FFTW REQUIRED)
  
  MESSAGE(STATUS "Using FFTW available at: ${fftw_ROOT_DIR}")
  
  SET(RobartsVTK_FFTW_DIR ${fftw_ROOT_DIR})
ELSE()
  # FFTW has not been built yet, so download and build it as an external project
  IF(MSVC AND ${CMAKE_GENERATOR} MATCHES "Win64" )
    GET_FILENAME_COMPONENT(COMPILER_BIN_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)
    GET_FILENAME_COMPONENT(COMPILER_VC_DIR ${COMPILER_BIN_DIR} DIRECTORY)
    GET_FILENAME_COMPONENT(COMPILER_DIR ${COMPILER_VC_DIR} DIRECTORY)
    SET(FFTW_URL "${CMAKE_SOURCE_DIR}/Libs/fftw-3.3.4-dll64.tar.gz")
    SET(FFTW_CONFIGURE_COMMAND "$ENV{comspec} /k \"\"${COMPILER_DIR}/vcvarsall.bat\"\" amd64")
    message(${FFTW_CONFIGURE_COMMAND})
  ELSEIF(MSVC AND NOT ${CMAKE_GENERATOR} MATCHES "Win64" )
    SET(FFTW_URL "${CMAKE_SOURCE_DIR}/Libs/fftw-3.3.4-dll32.tar.gz")
    SET(FFTW_BUILD_COMMAND)
  ELSE()
    SET(FFTW_URL "${CMAKE_SOURCE_DIR}/Libs/fftw-3.3.4.tar.gz")
  ENDIF()

  MESSAGE(STATUS "Downloading FFTW from: ${FFTW_URL}")

  SET (RobartsVTK_FFTW_DIR "${ep_dependency_DIR}/FFTW-bin" CACHE INTERNAL "Path to store FFTW binaries")
  ExternalProject_Add( FFTW
    PREFIX "${ep_dependency_DIR}/FFTW-prefix"
    SOURCE_DIR ${RobartsVTK_FFTW_DIR}
    DOWNLOAD_DIR ${ep_dependency_DIR}/FFTW-download
    #--Download step--------------
    URL ${FFTW_URL}
    #--Configure step-------------
    CONFIGURE_COMMAND ${FFTW_CONFIGURE_COMMAND}
    #--Build step-----------------
    BUILD_COMMAND ""
    #--Install step-----------------
    INSTALL_COMMAND ""
    )

ENDIF()