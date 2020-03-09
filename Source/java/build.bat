@echo off
echo.
echo Compiles your Java code into classes.dex
echo Verified to work for Delphi XE10.3.1
echo.
echo Place this batch in a java folder below your project (project\java)
echo Place the source in project\java\src\com\dannywind\delphi
echo If your source file location or name is different, please modify it below.
echo This assumes a Win64 system with the 64-bit Java installed by the Delphi XE10.3.1 
echo installer in C:\Program Files (x86)\Java\jdk1.8.0_181

setlocal
 
if x%ANDROID% == x set ANDROID=C:\Users\Public\Documents\Embarcadero\Studio\20.0\PlatformSDKs\android-sdk-windows
set ANDROID_PLATFORM=%ANDROID%\platforms\android-28
set PROJ_DIR=%CD%
set VERBOSE=0
 
echo.
echo Compiling the Java service activity source files
echo.
mkdir output 2> nul
mkdir output\classes 2> nul
if x%VERBOSE% == x1 SET VERBOSE_FLAG=-verbose
"C:\Program Files (x86)\Java\jdk1.8.0_181\bin\javac" -source 1.7 -target 1.7 %VERBOSE_FLAG% -Xlint:deprecation -cp %ANDROID_PLATFORM%\android.jar -d output\classes src\com\kiosk\app\BootReceiver.java
 
echo.
echo Creating jar containing the new classes
echo.
mkdir output\jar 2> nul
if x%VERBOSE% == x1 SET VERBOSE_FLAG=v
"C:\Program Files (x86)\Java\jdk1.8.0_181\bin\jar" c%VERBOSE_FLAG%f output\jar\BootReceiver_classes.jar -C output\classes com
 
echo.
echo Now we have the end result, which is output\jar\BootReceiver_classes.jar
 
:Exit
 
pause
 
endlocal
