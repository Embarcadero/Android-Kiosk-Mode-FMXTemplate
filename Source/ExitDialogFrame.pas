unit ExitDialogFrame;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Layouts,
  FMX.Objects;

type
  TExitDialog = class(TFrame)
    Rectangle1: TRectangle;
    Layout1: TLayout;
    edtPass: TEdit;
    lblEnterPass: TLabel;
    EXIT: TButton;
    Cancel: TButton;
    procedure EXITClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
  private
    { Private declarations }
    FProcExit: TProc;
    FPassword: string;
    procedure CloseDialog;
  public
    { Public declarations }
  end;

resourcestring
  RS_INVALID_PASS = 'Invalid password.';

procedure ShowExitDialog(APassword: string; AParent: TFmxObject; AProcExit: TProc);

implementation
 {$R *.fmx}

var
  LExitDialog: TExitDialog;

procedure ShowExitDialog(APassword: string; AParent: TFmxObject; AProcExit: TProc);
begin
  LExitDialog := TExitDialog.Create(nil);
  LExitDialog.FProcExit := AProcExit;
  LExitDialog.FPassword := APassword;
  LExitDialog.Parent := AParent;
  LExitDialog.Visible := True;
end;

{ TExitDialog }

procedure TExitDialog.CancelClick(Sender: TObject);
begin
  CloseDialog;
end;

procedure TExitDialog.CloseDialog;
begin
  LExitDialog.Visible := False;
  LExitDialog.Parent := nil;
  LExitDialog.Free;
end;

procedure TExitDialog.EXITClick(Sender: TObject);
begin
  if edtPass.Text.Equals(FPassword) then
  begin
    if Assigned(FProcExit) then
      FProcExit;
    CloseDialog;
  end
  else
    ShowMessage(RS_INVALID_PASS);
end;

end.

