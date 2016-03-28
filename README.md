# Robarts VTKBuild

RobartsVTKBuild is a CMake project that downloads dependencies for the RobartsVTKLib project and builds everything.

## Download RobartsVTKBuild

Using a [git](https://en.wikipedia.org/wiki/Git_(software)) client, clone the repo link above.
* Windows? Try [TortoiseGit](https://tortoisegit.org/download/)
* Ubuntu? Try [RabbitVCS](http://rabbitvcs.org/), [SmartGit](http://www.syntevo.com/smartgit/) or [git-cola](http://git-cola.github.io/downloads.html)
* Mac? Try [GitHub](https://desktop.github.com/)

### Known Configurations
RobartsVTK has been built on the following configurations:
* Windows 10 x64, Visual Studio 2012, 32/64bit builds
* Ubuntu 15.10, Unix Makefiles/Eclipse CDT (see [Ubuntu build tips](ubuntu.md))
* Ubuntu 15.04, Unix Makefiles/Eclipse CDT

### Dependencies
The superbuild will download and build needed dependencies. Only two items must be installed and one built:
* [CMake 3.4](https://cmake.org/download/)
* [CUDA 7](https://developer.nvidia.com/cuda-downloads) (optional)
* [Qt](http://download.qt.io/archive/qt/) - built (optional, please follow Qt build instructions)
* [Python 2.7 x64](https://www.python.org/downloads/release/python-2711/) - installed (optional)

### CMake Configuration
The following variables should be set when configuring RobartsVTK
* RobartsVTK_Include_Outdated_Registration:BOOL = `OFF`
* ITK_DIR:PATH = `<path/to/your/itk-bin/dir>` (optional, if built elsewhere)
* PlusLib_DIR:PATH = `<path/to/your/plus-bin/dir>` (optional, if built elsewhere)
* QT4 - QT_QMAKE_EXECUTABLE:FILEPATH = `<path/to/your/qt-buildOrInstall>/bin/qmake.exe`
* QT5 - as above OR - Qt5_DIR:PATH = `<path/to/your/qt-buildOrInstall>/lib/cmake/Qt5`
* VTK_DIR:PATH = `<path/to/your/vtk-bin/dir>` (optional, if built elsewhere)
    * If you're wrapping with python:
        * PYTHON_INCLUDE_DIR:PATH = `<path/to/python-install>/include`
        * PYTHON_LIBRARY:PATH = `<path/to/python-install>/libs/python27.lib`

## License
Please see the [license](LICENSE.md) file.

## Acknowledgments
The Robarts Research Institute VASST Lab would like to thank the creator and maintainers of [GitLab](https://about.gitlab.com/).