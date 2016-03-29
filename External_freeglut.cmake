IF(freeglut_DIR)
  FIND_PACKAGE(freeglut 3.0.0 REQUIRED NO_MODULE PATHS ${freeglut_DIR})

  MESSAGE(STATUS "Using freeglut available at: ${freeglut_DIR}")
ELSE()
  MESSAGE(STATUS "Downloading and building freeglut from: https://github.com/VASST/FreeGLUT.git")

  SET (freeglut_SRC_DIR ${ep_dependency_DIR}/freeglut CACHE INTERNAL "Path to store freeglut contents.")
  SET (freeglut_BIN_DIR ${ep_dependency_DIR}/freeglut-bin CACHE INTERNAL "Path to store freeglut contents.")
  ExternalProject_Add(freeglut
    PREFIX "${ep_dependency_DIR}/freeglut-prefix"
    SOURCE_DIR "${freeglut_SRC_DIR}"
    BINARY_DIR "${freeglut_BIN_DIR}"
    #--Download step-------------
    GIT_REPOSITORY https://github.com/VASST/FreeGLUT.git
    GIT_TAG git_master
    #--Configure step-------------
    CMAKE_ARGS 
      ${ep_common_args}
      -DCMAKE_INSTALL_PREFIX=${freeglut_BIN_DIR}/install
      -DFREEGLUT_BUILD_DEMOS:BOOL=OFF
      -DINSTALL_PDB:BOOL=OFF
    #--Install step-----------------
    INSTALL_COMMAND "" # Do not install
    DEPENDS
    )
ENDIF()