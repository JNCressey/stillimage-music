@echo off
REM Run inside a folder that contains image and audio pairs with identical names.
REM This creates stillimage music videos as mp4s.
REM Images can have extension png, jpg or jpeg.
REM Audio can have extension mp3 or mpeg.
REM Console stays open if need to warn mp4s already exist with a name,
REM or any unpaired jpgs or mp3s.
REM Requires FFMPEG installed and available in Windows PATH.

setlocal EnableExtensions DisableDelayedExpansion

set "skipped="
set "unmatchedImages="
set "unmatchedAudio="

for %%F in (*.png) do if exist "%%F" call :processImage "%%~nF" "png"
for %%F in (*.jpg) do if exist "%%F" call :processImage "%%~nF" "jpg"
for %%F in (*.jpeg) do if exist "%%F" call :processImage "%%~nF" "jpeg"

for %%F in (*.mp3) do if exist "%%F" call :checkAudio "%%~nF" "mp3"
for %%F in (*.mpeg) do if exist "%%F" call :checkAudio "%%~nF" "mpeg"


if defined skipped goto :pause
if defined unmatchedImages goto :pause
if defined unmatchedAudio goto :pause
exit /b

:pause
echo.
echo Usage instructions:
echo   Run inside a folder that contains image and audio pairs with identical names.
echo   This creates stillimage music videos as mp4s.
echo   Images can have extension png, jpg or jpeg.
echo   Audio can have extension mp3 or mpeg.

if defined skipped (
    echo.
    echo Skipped because an MP4 already exists:
    echo %skipped%
)

if defined unmatchedImages (
    echo.
    echo Image files with no matching audio file:
    echo %unmatchedImages%
)

if defined unmatchedAudio (
    echo.
    echo Audio files with no matching image file:
    echo %unmatchedAudio%
)

echo.
pause
exit /b

:processImage
rem If both image types exist, process the PNG only.
if /i "%~2"=="jpg" if exist "%~1.png" exit /b
if /i "%~2"=="jpeg" if exist "%~1.png" exit /b
if /i "%~2"=="jpeg" if exist "%~1.jpg" exit /b

if exist "%~1.mp3" (
    set "audio=%~1.mp3"
) else if exist "%~1.mpeg" (
    set "audio=%~1.mpeg"
) else (
    set "unmatchedImages=%unmatchedImages%  "%~1.%~2""
    exit /b
)

if exist "%~1.mp4" (
    set "skipped=%skipped%  "%~1.mp4""
    exit /b
)

echo Creating %~1.mp4
echo PLEASE WAIT FOR THIS TO FINISH
ffmpeg -hide_banner -loglevel error -stats -y -loop 1 -i "%~1.%~2" -i "%audio%" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "%~1.mp4"
echo.
exit /b

:checkAudio
if exist "%~1.jpg" exit /b
if exist "%~1.jpeg" exit /b
set "unmatchedAudio=%unmatchedAudio%  "%~1.%~2""
exit /b
