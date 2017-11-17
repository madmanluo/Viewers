@echo off

REM Create LesionTracker Installer
REM 1. Install Node.js
REM 2. Install Meteor
REM 3. Run 'npm install -g windows-build-tools' in Node.js command prompt
REM 4. Put all prerequisites under 'Prerequisites' folder
REM 5. Run this script

set VERSIONNUMBER="1.0.0"
set SRCDIR="C:\Workspace\Viewers\LesionTracker"

REM Build Meteor Server
cd %SRCDIR%
rmdir /s /q ..\Installer\build & mkdir ..\Installer\build
call meteor npm install --production
set METEOR_PACKAGE_DIRS=..\Packages
call meteor build --directory ..\Installer\build
cd ..\Installer\build\bundle\programs\server
call npm install --production
cd ..\..\..\..\

REM Copy Node Windows Service to run Lesion Tracker Server as a windows service
cd NodeWindowsService
call npm install --production
cd ..
mkdir build\NodeWindowsService
xcopy /y /s /e NodeWindowsService build\NodeWindowsService

REM Copy Lesion tracker startup and settings file
xcopy /y orthancDICOMWeb.json build
xcopy /y mongod.cfg build

REM Copy LICENSE and Logo files
xcopy /y LICENSE.rtf build
xcopy /y logo.ico build
xcopy /y wix-dialog.bmp build
xcopy /y wix-top-banner.bmp build

REM Create Installer Folders
rmdir /s /q output & mkdir output
rmdir /s /q output\LTSingle & mkdir output\LTSingle
rmdir /s /q output\LTComplete & mkdir output\LTComplete

REM Create Lesion Tracker Installer (Single)
del /q LesionTrackerWXS\BuildDir.wxs
call "%WIX%\bin\heat.exe" dir build -dr INSTALLDIR -cg MainComponentGroup -var var.SourceDir -out LesionTrackerWXS\BuildDir.wxs -srd -ke -sfrag -gg -sreg -scom
call "%WIX%\bin\candle.exe" -dSourceDir="build" -dVersionNumber="%VERSIONNUMBER%" LesionTrackerWXS\*.wxs -o output\LTSingle\ -arch x64 -ext WiXUtilExtension
call "%WIX%\bin\light.exe" -o output\LTSingle\LTInstaller-Single-%VERSIONNUMBER%.msi output\LTSingle\*.wixobj -cultures:en-US -ext WixUIExtension.dll -ext WiXUtilExtension

REM Create Leasion Tracker Bundle Installer with prerequisites (Complete)
call "%WIX%\bin\candle.exe" -dSourceDir="build" -dPreqDir="Prerequisites" -dLTInstallerPath="output\LTSingle\LTInstaller-Single-%VERSIONNUMBER%.msi" BundleWXS\*.wxs -o output\LTComplete\ -ext WiXUtilExtension -ext WixBalExtension
call "%WIX%\bin\light.exe" -o output\LTComplete\LTInstaller-Complete-%VERSIONNUMBER%.exe output\LTComplete\*.wixobj -cultures:en-US -ext WixUIExtension.dll -ext WiXUtilExtension -ext WixBalExtension