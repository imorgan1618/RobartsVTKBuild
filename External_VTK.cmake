IF(VTK_DIR)
  # VTK has been built already
  FIND_PACKAGE(VTK ${RobartsVTK_VTK_VERSION} REQUIRED NO_MODULE PATHS ${VTK_DIR} NO_DEFAULT_PATH)
  
  IF( NOT VTK_WRAP_PYTHON AND RobartsVTK_WRAP_PYTHON )
    MESSAGE(FATAL_ERROR "Python wrapping requested but VTK located at \"${VTK_DIR}\" was not built with python wrapping enabled.")
  ENDIF()
  
  IF( ${VTK_RENDERING_BACKEND} STREQUAL "OpenGL" )
    MESSAGE(FATAL_ERROR "RobartsVTK requires OpenGL2 backend enabled in VTK build. The VTK at ${VTK_DIR} does not have this enabled.")
    SET(VTK_DIR "VTK_DIR-NOTFOUND")
    return()
  ENDIF()

  MESSAGE(STATUS "Using VTK available at: ${VTK_DIR}")
  
  SET(RobartsVTK_VTK_DIR ${VTK_DIR})
ELSE(VTK_DIR)
  # VTK has not been built yet, so download and build it as an external project

  IF(${RobartsVTK_VTK_VERSION} VERSION_EQUAL "6.3.0")
    SET(VTK_GIT_REPOSITORY "github.com/Slicer/VTK.git")
    SET(VTK_GIT_TAG "fe92273888219edca422f3a308761ddcd2882e2b")
    SET(VTK_GIT_PROTOCOL ${GIT_PROTOCOL})
  ELSE
    SET(VTK_GIT_REPOSITORY "gitlab.kitware.com/vtk/vtk.git")
    SET(VTK_GIT_TAG "master")
    SET(VTK_GIT_PROTOCOL "https")
  ENDIF()

  MESSAGE(STATUS "Downloading and building VTK from: ${VTK_GIT_PROTOCOL}://${VTK_GIT_REPOSITORY}")

  IF( RobartsVTK_USE_QT )
    SET(VTK_VERSION_SPECIFIC_ARGS ${VTK_VERSION_SPECIFIC_ARGS}
      -DVTK_Group_Qt:BOOL=ON
      )
  ENDIF( RobartsVTK_USE_QT )
  SET(VTK_VERSION_SPECIFIC_ARGS ${VTK_VERSION_SPECIFIC_ARGS}
    -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:STRING=${RobartsVTK_EXECUTABLE_OUTPUT_PATH}
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:STRING=${RobartsVTK_EXECUTABLE_OUTPUT_PATH}
    )
  IF(APPLE)
    SET(VTK_QT_ARGS ${VTK_QT_ARGS}
      -DVTK_USE_CARBON:BOOL=OFF
      -DVTK_USE_COCOA:BOOL=ON # Default to Cocoa, VTK/CMakeLists.txt will enable Carbon and disable cocoa if needed
      -DVTK_USE_X:BOOL=OFF
      )
  ENDIF(APPLE)

  SET (RobartsVTK_VTK_SRC_DIR "${ep_dependency_DIR}/vtk")
  SET (RobartsVTK_VTK_DIR "${ep_dependency_DIR}/vtk-bin" CACHE INTERNAL "Path to store vtk binaries")
  ExternalProject_Add( vtk
    PREFIX "${ep_dependency_DIR}/vtk-prefix"
    SOURCE_DIR "${RobartsVTK_VTK_SRC_DIR}"
    BINARY_DIR "${RobartsVTK_VTK_DIR}"
    #--Download step--------------
    GIT_REPOSITORY "${VTK_GIT_PROTOCOL}://${VTK_GIT_REPOSITORY}"
    GIT_TAG ${VTK_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS 
        ${ep_common_args}
        ${VTK_VERSION_SPECIFIC_ARGS}
        ${RobartsVTK_VTK_PYTHON_ARGS}
        -DBUILD_SHARED_LIBS:BOOL=ON 
        -DBUILD_TESTING:BOOL=OFF 
        -DBUILD_EXAMPLES:BOOL=OFF
        -DVTK_RENDERING_BACKEND:STRING=OpenGL2
        -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
        -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE}
        -DVTK_QT_VERSION:STRING=${QT_VERSION_MAJOR}
        -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
        -DVTK_WRAP_PYTHON:BOOL=${RobartsVTK_WRAP_PYTHON}
        -DVTK_SMP_IMPLEMENTATION_TYPE:STRING=OpenMP
        -DCMAKE_PREFIX_PATH:STRING=${CMAKE_PREFIX_PATH}
    #--Build step-----------------
    #--Install step-----------------
    INSTALL_COMMAND ""
    DEPENDS ${VTK_DEPENDENCIES}
    )

ENDIF(VTK_DIR)