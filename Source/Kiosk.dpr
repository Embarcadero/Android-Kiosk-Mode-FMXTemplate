program Kiosk;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainForm in 'MainForm.pas' {Dashboard},
  KioskApplication in 'KioskApplication.pas',
  android.app.admin.DevicePolicyManager in 'source\android.app.admin.DevicePolicyManager.pas',
  android.content.ComponentName in 'source\android.content.ComponentName.pas',
  ExitDialogFrame in 'ExitDialogFrame.pas' {ExitDialog: TFrame},
  android.os.UserManager in 'source\android.os.UserManager.pas',
  android.app.ActivityManager in 'source\android.app.ActivityManager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDashboard, Dashboard);
  Application.Run;
end.
