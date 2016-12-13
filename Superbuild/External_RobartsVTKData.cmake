#--------------------------------------------------------------------------
# RobartsVTKData

SET (RobartsVTK_Data_DIR ${CMAKE_BINARY_DIR}/RVTKData CACHE INTERNAL "Path to store RobartsVTK data.")
ExternalProject_Add(RobartsVTKData
  PREFIX "${CMAKE_BINARY_DIR}/RVTKData-prefix"
  SOURCE_DIR "${RobartsVTK_Data_DIR}" 
  #--Download step--------------
  GIT_REPOSITORY https://github.com/VASST/RobartsVTKData.git
  GIT_TAG master
  #--Configure step-------------
  CONFIGURE_COMMAND ""
  #--Build step-----------------
  BUILD_COMMAND ""
  #--Install step-----------------
  INSTALL_COMMAND ""
  )