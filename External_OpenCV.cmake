IF(OpenCV_DIR)
  FIND_PACKAGE(OpenCV 2.3.1 REQUIRED NO_MODULE PATHS ${OpenCV_DIR})

  MESSAGE(STATUS "Using OpenCV available at: ${OpenCV_DIR}")
ELSE()
  MESSAGE(STATUS "Downloading and building OpenCV from: https://github.com/Itseez/opencv.git")

  IF( QT4_FOUND OR Qt5_FOUND )
    SET(QT_ARG -DWITH_QT:BOOL=ON -DQT_QMAKE_EXECUTABLE=${QT_QMAKE_EXECUTABLE})
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
    GIT_TAG 2.3.1
    #--Configure step-------------
    CMAKE_ARGS 
      ${ep_common_args}
      -DCMAKE_C_FLAGS=${ep_common_c_flags}
      -DCMAKE_CXX_FLAGS=${ep_common_cxx_flags}
      ${QT_ARG}
      -DWITH_CUDA:BOOL=OFF
      -DBUILD_TESTS:BOOL=OFF
    #--Install step-----------------
    INSTALL_COMMAND "" # Do not install
    DEPENDS
    )
ENDIF()