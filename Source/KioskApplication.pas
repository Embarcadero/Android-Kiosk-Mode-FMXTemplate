unit KioskApplication;

interface

uses
  FMX.platform,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.GraphicsContentViewText,
  android.app.admin.DevicePolicyManager,
  android.content.ComponentName,
  System.Classes,
  System.SysUtils;

type
  TArrayOfStrings = array of string;

  TArrayOfJStrings = array of JString;

  TKioskApplication = class
  private
    FActiveThread: Boolean;
    FThreadCloseSystemDialog: TThread;
    FAdmin: JComponentName;
    FActiveOtherActivity: Boolean;
    function GetRestrictions: TArrayOfJStrings;
    function GetDevicePolicyManager: JDevicePolicyManager;
    procedure StartThreadCloseSystemDialogs;
    procedure StopThreadCloseSystemDialogs;
    procedure hideSystemUI;
    procedure DoCloseSystemDialog;
    function ApplicationEventChanged(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
  public
    procedure StopLockTask;
    procedure StartLockTask(AOtherAppPackages: TArrayOfStrings = []);
  public
    procedure CleanOwnerState;
    constructor Create();
    property ActiveOtherActivity: Boolean read FActiveOtherActivity write FActiveOtherActivity;
  end;

implementation

uses
  Androidapi.Helpers,
  Androidapi.JNIBridge,
  android.os.UserManager,
  android.app.ActivityManager;

{ TKioskApplication }

function TKioskApplication.ApplicationEventChanged(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
begin
  if AAppEvent = TApplicationEvent.BecameActive then
  begin
    ActiveOtherActivity := False;
  end;
end;

procedure TKioskApplication.CleanOwnerState;
begin
  GetDevicePolicyManager.clearDeviceOwnerApp(TAndroidHelper.Context.getPackageName);
end;

constructor TKioskApplication.Create;
var
  ApplicationService: IFMXApplicationEventService;
begin
  FActiveThread := False;
  TPlatformServices.Current.SupportsPlatformService(IFMXApplicationEventService, ApplicationService);
  if ApplicationService <> nil then
    ApplicationService.SetApplicationEventHandler(ApplicationEventChanged);

  FAdmin := TJComponentName.JavaClass.createRelative(TAndroidHelper.Context.getPackageName,
    StringToJString('com.kiosk.admin.AdminReceiver'));
end;

procedure TKioskApplication.DoCloseSystemDialog;
var
  ActivityManager: JActivityManager;
  CloseDialogIntent: JIntent;
begin
  CloseDialogIntent := TJIntent.Create;
  CloseDialogIntent.setAction(TJIntent.JavaClass.ACTION_CLOSE_SYSTEM_DIALOGS);
  TAndroidHelper.Context.sendBroadcast(CloseDialogIntent);
  TThread.Synchronize(TThread.Current,
    procedure
    begin
      TAndroidHelper.Activity.getWindow.getDecorView.setSystemUiVisibility(8);
    end);

  if not ActiveOtherActivity then
  begin
    ActivityManager := TJActivityManager.Wrap(TAndroidHelper.Context.getSystemService
      (TJContext.JavaClass.ACTIVITY_SERVICE));
    ActivityManager.moveTaskToFront(TAndroidHelper.Activity.getTaskId(), 0);
  end;
end;

function TKioskApplication.GetDevicePolicyManager: JDevicePolicyManager;
var
  jobj: JObject;
begin
  jobj := tAndroidHelper.Activity.getSystemService(TJContext.JavaClass.DEVICE_POLICY_SERVICE);
  Result := TJDevicePolicyManager.Wrap(jobj);
end;

function TKioskApplication.GetRestrictions: TArrayOfJStrings;
begin
  SetLength(Result, 6);
  Result[0] := StringToJString(TJUserManagerDISALLOW_FACTORY_RESET);
  Result[1] := StringToJString(TJUserManagerDISALLOW_SAFE_BOOT);
  Result[2] := StringToJString(TJUserManagerDISALLOW_MOUNT_PHYSICAL_MEDIA);
  Result[3] := StringToJString(TJUserManagerDISALLOW_ADJUST_VOLUME);
  Result[4] := StringToJString(TJUserManagerDISALLOW_ADD_USER);
  Result[5] := StringToJString(TJUserManagerDISALLOW_CREATE_WINDOWS);
end;

procedure TKioskApplication.hideSystemUI;
var
  DecorView: JView;
begin

  DecorView := TAndroidHelper.Activity.getWindow.getDecorView;
  DecorView.setSystemUiVisibility(TJView.JavaClass.SYSTEM_UI_FLAG_IMMERSIVE or
    TJView.JavaClass.SYSTEM_UI_FLAG_LAYOUT_STABLE or TJView.JavaClass.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
    or TJView.JavaClass.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or TJView.JavaClass.SYSTEM_UI_FLAG_HIDE_NAVIGATION
    or TJView.JavaClass.SYSTEM_UI_FLAG_FULLSCREEN);
end;

procedure TKioskApplication.StartLockTask(AOtherAppPackages: TArrayOfStrings = []);
var
  LArrayOfOtherApp: TJavaObjectArray<JString>;
  LLen: Integer;
  I: Integer;
  LOffset: Integer;
  LRestrictions: TArrayOfJStrings;
  IntentFilter: JIntentFilter;
begin
  LLen := Length(AOtherAppPackages);
  LOffset := 1;
  LArrayOfOtherApp := TJavaObjectArray<JString>.Create(LLen + LOffset);
  LArrayOfOtherApp.Items[0] := TAndroidHelper.Context.getPackageName;
  for I := 0 to LLen - 1 do
    LArrayOfOtherApp.Items[I + LOffset] := StringToJString(AOtherAppPackages[I]);

  GetDevicePolicyManager.setLockTaskPackages(FAdmin, LArrayOfOtherApp);

  TAndroidHelper.Activity.startLockTask;

  LRestrictions := GetRestrictions;
  for I := Low(LRestrictions) to High(LRestrictions) do
    GetDevicePolicyManager.addUserRestriction(FAdmin, LRestrictions[I]);

  IntentFilter := TJIntentFilter.JavaClass.init;
  IntentFilter.addAction(TJIntent.JavaClass.ACTION_MAIN);
  IntentFilter.addCategory(TJIntent.JavaClass.CATEGORY_HOME);
  IntentFilter.addAction(TJIntent.JavaClass.CATEGORY_DEFAULT);

  GetDevicePolicyManager.addPersistentPreferredActivity(FAdmin, IntentFilter, FAdmin);

  StartThreadCloseSystemDialogs;
  hideSystemUI;
end;

procedure TKioskApplication.StartThreadCloseSystemDialogs;
begin
  FActiveThread := True;
  FThreadCloseSystemDialog := TThread.CreateAnonymousThread(
    procedure
    begin
      while FActiveThread do
      begin
        try
          try
            DoCloseSystemDialog;
          except
          end;
        finally
          Sleep(50);
        end;
      end;
    end);
  FThreadCloseSystemDialog.Start;
end;

procedure TKioskApplication.StopLockTask;
var
  I: Integer;
  LRestrictions: TArrayOfJStrings;
begin
  TAndroidHelper.Activity.stopLockTask;

  LRestrictions := GetRestrictions;
  for I := Low(LRestrictions) to High(LRestrictions) do
    GetDevicePolicyManager.clearUserRestriction(FAdmin, LRestrictions[I]);

  GetDevicePolicyManager.clearPackagePersistentPreferredActivities(FAdmin,
    TAndroidHelper.Activity.getPackageName);

  StopThreadCloseSystemDialogs;
end;

procedure TKioskApplication.StopThreadCloseSystemDialogs;
begin
  FActiveThread := False;
end;

end.

