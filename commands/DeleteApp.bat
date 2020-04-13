@echo off
echo.
echo DELETE APPLICATION
echo.

adb.exe shell dpm remove-active-admin com.mycompany.kioskapp/com.kiosk.admin.AdminReceiver
adb.exe shell pm uninstall -k com.mycompany.kioskapp

echo.
echo If you don't see "Success" above, then adb.exe might not be on your path.
echo   Check your path or update this batch file if necessary.
pause
