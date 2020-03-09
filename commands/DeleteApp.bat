@echo off
echo.
echo DELETE APPLICATION
echo.

"C:\Users\Public\Documents\Embarcadero\Studio\20.0\PlatformSDKs\android-sdk-windows\platform-tools\adb.exe" shell dpm remove-active-admin com.mycompany.kioskapp/com.kiosk.admin.AdminReceiver
"C:\Users\Public\Documents\Embarcadero\Studio\20.0\PlatformSDKs\android-sdk-windows\platform-tools\adb.exe" shell pm uninstall -k com.mycompany.kioskapp

pause
