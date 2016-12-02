program TemHumTim;

uses
  windows,
  Dialogs,
  Forms,
  Main in 'Main.pas' {frmMain},
  ParaSetting in 'ParaSetting.pas' {frmParaSetting},
  NetFunc in 'NetFunc.pas';

{$R *.res}

var
  mymutex: THandle;
begin
  mymutex:=CreateMutex(nil,True,'我的互斥对象');
  if GetLastError<>ERROR_ALREADY_EXISTS then
  begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TfrmMain, frmMain);
    Application.Run;
  end
  else
    ShowMessage('已经有一个实例在运行');
end.
