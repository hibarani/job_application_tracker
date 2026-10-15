@echo off
setlocal

echo Starting Job Application Tracker on Flutter Web...

set "CHROME_PROFILE=C:\Users\Public\JobApplicationTracker\chrome_profile"

if not exist "%CHROME_PROFILE%" (
    mkdir "%CHROME_PROFILE%"
)

echo Using persistent Chrome profile: %CHROME_PROFILE%
echo Using fixed origin: http://localhost:7357

flutter run -d chrome --web-hostname=localhost --web-port=7357 --web-browser-flag=--user-data-dir=%CHROME_PROFILE%
