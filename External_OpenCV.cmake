IF(OpenCV_DIR)
  FIND_PACKAGE(OpenCV 3.1.0 REQUIRED NO_MODULE PATHS ${OpenCV_DIR})

  MESSAGE(STATUS "Using OpenCV available at: ${OpenCV_DIR}")
ELSE()
  MESSAGE(STATUS "Downloading and building OpenCV from: https://github.com/Itseez/opencv.git")
  
  SET(EXTRA_OPENCV_ARGS)
  FIND_PACKAGE(CUDA 7.5 QUIET)
  
  IF( NOT CUDA_FOUND )
    SET(EXTRA_OPENCV_ARGS -DWITH_CUDA:BOOL=OFF)
  ELSE()
    SET(EXTRA_OPENCV_ARGS -DWITH_CUDA:BOOL=ON)
  ENDIF()

  IF( QT4_FOUND )
    SET(QT_ARG -DWITH_QT:BOOL=ON -DQT_QMAKE_EXECUTABLE:FILEPATH=${QT_QMAKE_EXECUTABLE})
  ELSEIF( Qt5_FOUND )
    GET_FILENAME_COMPONENT(Qt5_PREFIX_PATH ${Qt5_DIR} DIRECTORY)
    SET(QT_ARG -DWITH_QT:BOOL=ON -DQt5_DIR:PATH=${Qt5_DIR} -DCMAKE_PREFIX_PATH:PATH=${Qt5_PREFIX_PATH})
  ELSE()
    SET(QT_ARG -DWITH_QT:BOOL=OFF)
  ENDIF()
  
  IF( ${CMAKE_GENERATOR} MATCHES "Visual Studio 11" )
    SET(ep_common_cxx_flags "${ep_common_cxx_flags} /D_VARIADIC_MAX=10")
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
      -DCMAKE_CXX_FLAGS=${ep_common_cxx_flags}
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DBUILD_TESTS:BOOL=OFF
      -DBUILD_DOCS:BOOL=OFF
      -DVTK_DIR:PATH=${PLUS_VTK_DIR} 
      ${QT_ARG}
      ${EXTRA_OPENCV_ARGS}
    #--Install step-----------------
    INSTALL_COMMAND "" # Do not install
    DEPENDS
    )
ENDIF()
