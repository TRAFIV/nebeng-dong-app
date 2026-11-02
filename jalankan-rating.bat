@echo off
setlocal
rem Demo Android: tidak memerlukan plugin desktop Windows/Linux.
set FLUTTER_WINDOWS=false
set FLUTTER_LINUX=false
cd /d "%~dp0"
call flutter pub get
if errorlevel 1 goto selesai
call flutter run -t lib/main_rating.dart
:selesai
pause
