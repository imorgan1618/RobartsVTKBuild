IF(OpenCV_DIR)
  FIND_PACKAGE(OpenCV 3.1.0 REQUIRED NO_MODULE PATHS ${OpenCV_DIR})

  MESSAGE(STATUS "Using OpenCV available at: ${OpenCV_DIR}")
  
  SET(RobartsVTK_OpenCV_DIR ${OpenCV_DIR} CACHE Internal "Path to OpenCV contents.")
ELSE()
  MESSAGE(STATUS "Downloading and building OpenCV from: https://github.com/Itseez/opencv.git")
  
  SET(EXTRA_OPENCV_ARGS)
  FIND_PACKAGE(CUDA QUIET)
  
  IF( NOT CUDA_FOUND )
    LIST(APPEND EXTRA_OPENCV_ARGS -DWITH_CUDA:BOOL=OFF)
  ELSE()
    LIST(APPEND EXTRA_OPENCV_ARGS -DWITH_CUDA:BOOL=ON -DBUILD_opencv_cudalegacy:BOOL=OFF)
  ENDIF()

  IF( Qt5_FOUND )
    SET(QT_ARG -DWITH_QT:BOOL=ON -DQt5_DIR:PATH=${Qt5_DIR})
  ENDIF()
  
  IF( ${CMAKE_GENERATOR} MATCHES "Visual Studio 11" )
    SET(ep_common_cxx_flags "${ep_common_cxx_flags} /D_VARIADIC_MAX=10")
  ENDIF()

  SET(opencv_common_cxx_flags ${ep_common_cxx_flags})
  IF(UNIX AND NOT APPLE)
    # Remove c++11 for opencv 3.1.0 on linux as it causes build issues
    STRING(REPLACE "-std=c++11" "" opencv_common_cxx_flags ${opencv_common_cxx_flags})
  ENDIF()

  SET (RobartsVTK_OpenCV_SRC_DIR ${ep_dependency_DIR}/OpenCV CACHE INTERNAL "Path to store OpenCV contents.")
  SET (RobartsVTK_OpenCV_DIR ${ep_dependency_DIR}/OpenCV-bin CACHE INTERNAL "Path to store OpenCV contents.")
  ExternalProject_Add(OpenCV
    PREFIX "${ep_dependency_DIR}/OpenCV-prefix"
    SOURCE_DIR "${RobartsVTK_OpenCV_SRC_DIR}"
    BINARY_DIR "${RobartsVTK_OpenCV_DIR}"
    #--Download step--------------
    GIT_REPOSITORY https://github.com/opencv/opencv.git
    GIT_TAG ab3814f9b98fef0c8e165de99be3840f330806c4
    #--Configure step-------------
    CMAKE_ARGS 
      ${ep_common_args}
      -DCMAKE_C_FLAGS=${ep_common_c_flags}
      -DCMAKE_CXX_FLAGS=${opencv_common_cxx_flags}
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DBUILD_TESTS:BOOL=OFF
      -DBUILD_DOCS:BOOL=OFF
      -DVTK_DIR:PATH=${RobartsVTK_VTK_DIR} 
      -DWITH_OPENGL:BOOL=ON
      -DWITH_VFW:BOOL=OFF
      -DWITH_MSMF:BOOL=ON
      ${QT_ARG}
      ${EXTRA_OPENCV_ARGS}
    #--Install step-----------------
    INSTALL_COMMAND "" # Do not install
    DEPENDS vtk
    )
ENDIF()
