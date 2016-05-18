IF(OpenCV_DIR)
  FIND_PACKAGE(OpenCV 3.1.0 REQUIRED NO_MODULE PATHS ${OpenCV_DIR})

  MESSAGE(STATUS "Using OpenCV available at: ${OpenCV_DIR}")
ELSE()
  MESSAGE(STATUS "Downloading and building OpenCV from: https://github.com/Itseez/opencv.git")
  
  SET(EXTRA_OPENCV_ARGS)
  FIND_PACKAGE(CUDA 7.5 QUIET)
  
  IF( NOT CUDA_FOUND )
    SET(EXTRA_OPENCV_ARGS -DWITH_CUDA:BOOL=OFF)
  ENDIF()

  IF( QT4_FOUND OR Qt5_FOUND )
    SET(QT_ARG -DWITH_QT:BOOL=ON -DQT_QMAKE_EXECUTABLE=${QT_QMAKE_EXECUTABLE})
  ELSE()
    SET(QT_ARG -DWITH_QT:BOOL=OFF)
  ENDIF()
  
  IF( ${CMAKE_GENERATOR} MATCHES "Visual Studio 11" )
    SET(ep_common_cxx_flags "${ep_common_cxx_flags} /D_VARIADIC_MAX=10")
  ENDIF()

  IF( NOT WIN32 )
    # Remove -std=c++11 from cxx flags, as this breaks opencv 2.3.1 build on linux
    STRING(REPLACE "-std=c++11" "" opencv_common_cxx_flags ${ep_common_cxx_flags})
    # Turn off Qt build as it causes usleep compiler errors
    SET(QT_ARG -DWITH_QTL:BOOL=OFF)
  ELSE()
    SET(opencv_common_cxx_flags ${ep_common_cxx_flags})
  ENDIF()
  
  IF( "${VTK_RENDERING_BACKEND}" STREQUAL "OpenGL" )
    SET( OpenCV_VTK_ARGS -DWITH_VTK:BOOL=ON -DVTK_DIR:PATH=${RobartsVTK_VTK_DIR} )
  ELSE()
    SET( OpenCV_VTK_ARGS )
  ENDIF()

  SET (OpenCV_SRC_DIR ${ep_dependency_DIR}/OpenCV CACHE INTERNAL "Path to store OpenCV contents.")
  SET (OpenCV_BIN_DIR ${ep_dependency_DIR}/OpenCV-bin CACHE INTERNAL "Path to store OpenCV contents.")
  ExternalProject_Add(OpenCV
    PREFIX "${ep_dependency_DIR}/OpenCV-prefix"
    SOURCE_DIR "${OpenCV_SRC_DIR}"
    BINARY_DIR "${OpenCV_BIN_DIR}"
    #--Download step--------------
    GIT_REPOSITORY https://github.com/Itseez/opencv.git
    GIT_TAG 3.1.0
    #--Configure step-------------
    CMAKE_ARGS 
      ${ep_common_args}
      -DCMAKE_C_FLAGS=${ep_common_c_flags}
      -DCMAKE_CXX_FLAGS=${opencv_common_cxx_flags}
      -DBUILD_SHARED_LIBS:BOOL=${PLUSBUILD_BUILD_SHARED_LIBS}
      -DBUILD_TESTS:BOOL=OFF
      -DBUILD_DOCS:BOOL=OFF
      -DVTK_DIR:PATH=${PLUS_VTK_DIR} 
      ${QT_ARG}
      ${EXTRA_OPENCV_ARGS}
      ${OpenCV_VTK_ARGS}
    #--Install step-----------------
    INSTALL_COMMAND "" # Do not install
    DEPENDS
    )
ENDIF()
