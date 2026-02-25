@echo off
set SRC=build\app\outputs\flutter-apk\app-release.apk
set DST=web\apk\likita-event.apk
if not exist "%SRC%" (
  echo APK non trouve. Lancez d'abord: flutter build apk --release
  exit /b 1
)
if not exist "web\apk" mkdir web\apk
copy /Y "%SRC%" "%DST%"
echo Copie OK: %DST%
