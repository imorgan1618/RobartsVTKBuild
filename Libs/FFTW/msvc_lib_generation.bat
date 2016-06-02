@echo off

REM %1 contains vcvarsall.bat file path
REM %2 contains architecture to run, amd64, x86_amd64, x86, ...
REM %3 contains the folder with the .def files

REM Load all of the VS environment configuration for the given architecture
@call %1 %2

REM Change to the given folder so that .lib files are generated in the correct place
@cd /d %3

REM Generate the .lib files for future linking
if not %3 == "x86" (
	@lib /machine:x86 /def:%3/libfftw3-3.def
	@lib /machine:x86 /def:%3/libfftw3f-3.def
	@lib /machine:x86 /def:%3/libfftw3l-3.def
) else (
	@lib /machine:x64 /def:%3/libfftw3-3.def
	@lib /machine:x64 /def:%3/libfftw3f-3.def
	@lib /machine:x64 /def:%3/libfftw3l-3.def
)