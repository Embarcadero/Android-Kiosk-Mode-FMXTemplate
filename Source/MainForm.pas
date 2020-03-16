unit MainForm;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.Edit,
  FMX.Controls.Presentation,
  {uses for KIOSK}
  KioskApplication;

type
  TDashboard = class(TForm)
    grdpnlTopButtons: TGridPanelLayout;
    btnClearOwnerState: TButton;
    btnDashboard: TButton;
    grdpnlTBottomButtons: TGridPanelLayout;
    btnStartTrip: TButton;
    btnStartTripWithoutDestination: TButton;
    Layout1: TLayout;
    Panel4: TPanel;
    btnStartEmergency: TButton;
    lblSOS: TLabel;
    lblTestInfoAboutSOS: TLabel;
    Layout2: TLayout;
    Label1: TLabel;
    lytHeader: TLayout;
    lblTitle: TLabel;
    btnExitApp: TButton;
    pnlBackground: TPanel;
    StyleBook: TStyleBook;
    procedure btnCleanOwnerStateClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnExitAppClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartEmergencyClick(Sender: TObject);
    procedure btnClearOwnerStateClick(Sender: TObject);
  private
    { Private declarations }
    FKioskApp: TKioskApplication;
    procedure GoToSettings;
  public
    { Public declarations }
  end;

resourcestring
  RS_MESS_IS_NOT_ADMIN =
    'Your application is not a device administrator. Contact your administrator for application administration.';
  RS_MESS_WANT_EXIT = 'Are you sure you want Exit?';
  RS_CLEAR_OWN_STATE = 'Are you sure you want Clear Owner State?';

var
  Dashboard: TDashboard;

implementation

uses
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Provider,
  Androidapi.Helpers,
  FMX.DialogService,
  ExitDialogFrame;

const
  C_PASS = '1482';
{$R *.fmx}

procedure TDashboard.btnCleanOwnerStateClick(Sender: TObject);
begin
  FKioskApp.CleanOwnerState;
end;

procedure TDashboard.btnExitAppClick(Sender: TObject);
begin
  TDialogService.MessageDialog(RS_MESS_WANT_EXIT, TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes,
    TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = 6 then
      begin
        ShowExitDialog(C_PASS, Self,
          procedure
          begin
            FKioskApp.StopLockTask;
            Close;
          end);
      end;
    end);
end;

procedure TDashboard.btnStartEmergencyClick(Sender: TObject);
begin
  GoToSettings;
end;

procedure TDashboard.btnClearOwnerStateClick(Sender: TObject);
begin
  TDialogService.MessageDialog(RS_CLEAR_OWN_STATE, TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes,
    TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = 6 then
      begin
        FKioskApp.CleanOwnerState;
      end;
    end);
end;

procedure TDashboard.FormCreate(Sender: TObject);
begin
  FKioskApp := TKioskApplication.Create;
end;

procedure TDashboard.FormDestroy(Sender: TObject);
begin
  FKioskApp.Free;
end;

procedure TDashboard.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkHardwareBack then
    Key := 0;
end;

procedure TDashboard.FormShow(Sender: TObject);
begin
  try
    FKioskApp.StartLockTask(['com.android.settings']);
  except
    ShowMessage(RS_MESS_IS_NOT_ADMIN);
  end;
end;

procedure TDashboard.GoToSettings;
var
  LIntent: JIntent;
begin
  FKioskApp.ActiveOtherActivity := True;
  LIntent := TJIntent.JavaClass.init(TJSettings.JavaClass.ACTION_WIFI_SETTINGS);
  LIntent.addFlags(TJIntent.JavaClass.FLAG_ACTIVITY_NEW_TASK); // <-- this might be optional
  TAndroidHelper.Context.startActivity(LIntent);
end;

end.

