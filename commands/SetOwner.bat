@echo off
echo.
echo Making the app the owner of the device
echo To start the kiosk mode without questions
echo.

"adb.exe" shell dpm set-device-owner com.mycompany.kioskapp/com.kiosk.admin.AdminReceiver

pause
