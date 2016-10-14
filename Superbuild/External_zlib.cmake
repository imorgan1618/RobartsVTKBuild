IF(zlib_DIR)
  # zlib has been built already
  FIND_PACKAGE(zlib 6.3.0 REQUIRED NO_MODULE PATHS ${zlib_DIR} NO_DEFAULT_PATH)
  
  MESSAGE(STATUS "Using zlib available at: ${zlib_DIR}")
  
  SET(RobartsVTK_zlib_DIR ${zlib_DIR})
ELSE(zlib_DIR)
  # zlib has not been built yet, so download and build it as an external project

  SET(zlib_GIT_REPOSITORY "github.com/madler/zlib.git")
  SET(zlib_GIT_TAG "v1.2.8")

  MESSAGE(STATUS "Downloading and building zlib from: ${GIT_PROTOCOL}://${zlib_GIT_REPOSITORY}")

  SET (RobartsVTK_zlib_SRC_DIR "${ep_dependency_DIR}/zlib")
  SET (RobartsVTK_zlib_DIR "${ep_dependency_DIR}/zlib-bin" CACHE INTERNAL "Path to store zlib binaries")
  ExternalProject_Add( zlib
    PREFIX "${ep_dependency_DIR}/zlib-prefix"
    SOURCE_DIR "${RobartsVTK_zlib_SRC_DIR}"
    BINARY_DIR "${RobartsVTK_zlib_DIR}"
    #--Download step--------------
    GIT_REPOSITORY "${GIT_PROTOCOL}://${zlib_GIT_REPOSITORY}"
    GIT_TAG ${zlib_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS 
        ${ep_common_args}
        -DCMAKE_INSTALL_PREFIX:PATH=${RobartsVTK_zlib_DIR}/install
    #--Build step-----------------
    #--Install step-----------------
    DEPENDS ${zlib_DEPENDENCIES}
    )

ENDIF(zlib_DIR)