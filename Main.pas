unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids,ShellAPI, IdBaseComponent,
  IdComponent, IdUDPBase, IdUDPServer,IdSocketHandle,ParaSetting;

type
  TfrmMain = class(TForm)
    pnlBottom: TPanel;
    pnlTop: TPanel;
    lblTime: TLabel;
    tmrMain: TTimer;
    strrdMain: TStringGrid;
    pnlMyComputer: TPanel;
    pnlTerminate: TPanel;
    mmoMsg: TMemo;
    idpsrvrMain: TIdUDPServer;
    pnl1: TPanel;
    pnlSettings: TPanel;
    idpsrvrOPC: TIdUDPServer;
    lblGPSstatus: TLabel;

    procedure FormCreate(Sender: TObject);
//    procedure chkTaskBarVisibelClick(Sender: TObject);
    procedure tmrMainTimer(Sender: TObject);
    procedure strrdMainDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure pnlTerminateClick(Sender: TObject);
    procedure pnlMyComputerClick(Sender: TObject);
    procedure pnlSettingsClick(Sender: TObject);
    procedure idpsrvrMainUDPRead(AThread: TIdUDPListenerThread; AData: TBytes;
      ABinding: TIdSocketHandle);
    procedure idpsrvrOPCUDPRead(AThread: TIdUDPListenerThread; AData: TBytes;
      ABinding: TIdSocketHandle);

  private
    { Private declarations }
    procedure ShowVirtualData;
    procedure UpdateDisplay(const ActSens:THTsensors);
    procedure ShowSystemMenu(const LPt: TPoint);
  public
    { Public declarations }
  end;

const
  ColUnit:array[0..4] of string = ('','℃','%','℃','%');
var
  frmMain: TfrmMain;
  LocalIP:string;

implementation

{$R *.dfm}

uses NetFunc;

procedure TfrmMain.ShowVirtualData;

var
  ir,ic:integer;
begin
  for ic := 1 to strrdMain.ColCount - 1 do
    for ir := 1 to strrdMain.RowCount - 1 do
    begin
      strrdMain.Cells[ic,ir] := Format('%-3.1f%s',[Random()*50+((ic+1) mod 2 )*50,ColUnit[ic]]);
    end;
end;

procedure TfrmMain.strrdMainDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
const
  ColClr:array[0..4] of Tcolor = (clGrayText,clGrayText,clGrayText,clGrayText,clGrayText);
var
  s: String;
  R: TRect;
  w,h:integer;
begin
  with Sender as TStringGrid do
  begin
    Canvas.font.Color := clWhite;
    Canvas.Brush.Color := clBlack; //底色

    Canvas.FillRect(Rect);  //绘底色
    canvas.textout(rect.Left,rect.Top,cells[Acol,ARow]); //output text


    Canvas.FillRect(Rect);
    S := Cells[ACol,ARow];

    //根据文本调整字体
    Canvas.Font.Size := pnlTop.Font.Size;
    while True do
    begin
      w := Canvas.TextWidth(S);
      h := Canvas.TextHeight(S);
      if (W<DefaultColWidth-20)and(h<DefaultRowHeight-20) then break;

      Canvas.Font.Size := Canvas.Font.Size - 1;
    end;

    R := Rect;
    DrawText(Canvas.Handle,PChar(s),Length(s),r,DT_CENTER or DT_SINGLELINE or DT_VCENTER); //文字居中

  end;
end;


procedure TfrmMain.ShowSystemMenu(const LPt: TPoint);

var
  LMenu: HMENU;
  LFlags: Cardinal;
  LCommand: LongWord;
begin
  LMenu := GetSystemMenu(Self.Handle, False);
  LFlags := TPM_RETURNCMD or GetSystemMetrics(SM_MENUDROPALIGNMENT);
  LCommand := LongWord(TrackPopupMenu(LMenu, LFlags, LPt.X, LPt.Y, 0, Self.Handle, nil));
  PostMessage(Self.Handle, WM_SYSCOMMAND, LCommand, 0);
end;

procedure TfrmMain.UpdateDisplay(const ActSens:THTsensors);
const
  GPSlbl: array[BOOLean] of string = ('Pc','Gp');
var
  sNCol,i,j,ic,ir,NSen,Nrow,Ncol:integer;

begin

  NSen    := Length(ActSens);

  if NSen=0 then exit;


  if NSen<=configdat.NSenARow then
  begin
    sNCol := NSen
  end
  else
  begin
    sNCol := configdat.NSenARow
  end;
  lblGPSstatus.Caption := GPSlbl[configdat.GPSOnline];





  Nrow    := NSen div sNCol;
  if (NSen mod sNCol)>0 then Inc(Nrow);

  strrdMain.RowCount := Nrow + 1;
  strrdMain.ColCount := sNCol*3;
//  strrdMain.FixedCols:= strrdMain.ColCount;
//  strrdMain.FixedRows:= strrdMain.RowCount;

  strrdMain.Font.Size := 90;
  strrdMain.Canvas.Font := strrdMain.Font;

  strrdMain.DefaultColWidth :=  Screen.Width div strrdMain.ColCount - strrdMain.GridLineWidth; //  Round(strrdMain.Canvas.TextWidth('99.9')*1.2);
  strrdMain.DefaultRowHeight:= (Screen.Height - pnlTop.Height - pnlBottom.Height) div strrdMain.RowCount - strrdMain.GridLineWidth;;

  for j:= 0 to sNCol - 1 do
  begin
    strrdMain.Cells[j*3+0,0] := '位置';// '温度()';
    strrdMain.Cells[j*3+1,0] := '温度';// '温度()';
    strrdMain.Cells[j*3+2,0] := '湿度';// '温度(℃)';
  end;

  for i := 0 to NSen - 1 do with ActSens[i] do
  begin
    ic := (i mod sNCol)*3;
    ir := i div sNCol;
    strrdMain.Cells[ic,  ir+1] := Location;// Format('位置%d',[ir]);
    strrdMain.Cells[ic+1,ir+1] := Format('%.1f℃',[Temp]);// Format('位置%d',[ir]);
    strrdMain.Cells[ic+2,ir+1] := Format('%.1f%%',[Humi]);// Format('位置%d',[ir]);
  end;


end;


procedure TfrmMain.FormCreate(Sender: TObject);
var
  ic,ir:integer;
begin
  CfgFulFNam := ChangeFileExt(Application.ExeName,CfgFileExt);
  if not FileExists(CfgFulFNam) then
    mmoMsg.Lines.SaveToFile(CfgFulFNam);
  mmoMsg.Lines.Clear;


  GetLocalIP(LocalIP);
  frmParaSetting := TfrmParaSetting.Create(self);

  idpsrvrOPC.DefaultPort := ConfigDat.OPCPort;
  idpsrvrMain.DefaultPort:= ConfigDat.DefPort;



  pnlTop.Caption := Format('%s温湿度时间系统',[ConfigDat.SysLoaction]);
  with self do
  begin
  // Position form
    Top := 0 ;
    Left := 0 ;
  // Go full screen}
    BorderStyle := bsNone ;     //     bsNone
//    ShowWindow(FindWindow(PChar('Shell_TrayWnd'),nil), SW_HIDE);  //隐藏Windows任务栏
    WindowState := wsmaximized;
    ClientWidth := Screen.Width ;
    ClientHeight := Screen.Height;
    Refresh;
    SetForegroundWindow(Handle) ;
    SetActiveWindow(Application.Handle) ;

    pnlTop.Height := Round(Screen.Height * 0.2);
    pnlBottom.Height := Round(Screen.Height * 0.15);
    pnlSettings.Height := pnlBottom.Height div 3;
    pnlTerminate.Height := pnlSettings.Height;

//    UpdateDisplay();

//    strrdMain.Font.Size := 90;
//    strrdMain.Canvas.Font := strrdMain.Font;
//
//
//    strrdMain.RowCount := 1+ConfigDat.ModNum;
//    strrdMain.ColCount := 6;
//
//    strrdMain.DefaultColWidth :=  Screen.Width div strrdMain.ColCount - strrdMain.GridLineWidth; //  Round(strrdMain.Canvas.TextWidth('99.9')*1.2);
//    strrdMain.DefaultRowHeight:= (Screen.Height - pnlTop.Height - pnlBottom.Height) div strrdMain.RowCount - strrdMain.GridLineWidth;;
//
//    for Ir := 0 to ConfigDat.ModNum - 1 do
//      strrdMain.Cells[0,ir+1] := ConfigDat.Moduls[ir].ShowLabel;// Format('位置%d',[ir]);
//

    tmrMainTimer(tmrMain);

    mmoMsg.Font.Color := RGB(20,20,20);
    //将程序设置为自动运行。
    SetAutorun(Application.Title,application.ExeName,false,True);
  end;

  idpsrvrOPC.Active := True;

  //在日任务栏隐藏
  SetWindowLong(Application.Handle,GWL_EXSTYLE,WS_EX_TOOLWINDOW);

  lblTime.Font.Size := 200;
  while True do
  begin
    ic := lblTime.Canvas.TextWidth(pnlTop.Caption);
    if ic< (Screen.Width*0.9) then Break;
    lblTime.Font.Size := lblTime.Font.Size -1;
  end;
  pnlTop.Font.Size :=   lblTime.Font.Size;

  lblTime.Font.Size := 200;
  while True do
  begin
    ic := lblTime.Canvas.TextWidth(lblTime.Caption);
    if ic< (Screen.Width*0.6) then Break;
    lblTime.Font.Size := lblTime.Font.Size -1;
  end;

end;




procedure TfrmMain.idpsrvrMainUDPRead(AThread: TIdUDPListenerThread;
  AData: TBytes; ABinding: TIdSocketHandle);
var
  RevStr:string;
  i,mID:integer;
begin
  if LocalIP<>ABinding.PeerIP then //忽略自己的应答
  begin
    RevStr := stringof(AData);
    //


    mID := ConfigDat.RegThisdata(RevStr);   //  ,ABinding.PeerIP

    mmoMsg.Lines.Add(
       Format('%s 自 %s:%d',[RevStr,ABinding.PeerIP,ABinding.PeerPort])
      );
  end;
end;

procedure TfrmMain.idpsrvrOPCUDPRead(AThread: TIdUDPListenerThread;
  AData: TBytes; ABinding: TIdSocketHandle);
var
  RevStr:string;
  i,mID:integer;
begin
  if LocalIP<>ABinding.PeerIP then //忽略自己的应答
  begin
    RevStr := stringof(AData);
    if RevStr=ConfigDat.cmdOPCReadStatus then
    begin
      idpsrvrOPC.Send(ABinding.PeerIP,ABinding.PeerPort,ConfigDat.GetRecordStr());   // ,TEncoding.UTF8
    end
    else if RevStr=ConfigDat.cmdOPCReadStatusWithInfo then
    begin
      idpsrvrOPC.Send(ABinding.PeerIP,ABinding.PeerPort,ConfigDat.GetRecordStr(True));   // ,TEncoding.UTF8
    end;
    mmoMsg.Lines.Add(
       Format('%s 自 %s:%d',[RevStr,ABinding.PeerIP,ABinding.PeerPort])
      );
  end;

end;

procedure TfrmMain.pnlMyComputerClick(Sender: TObject);
begin
  ShellExecute(Handle,'open','Explorer.exe',PChar(ConfigDat.RecDatPath),nil,SW_SHOWNORMAL);   //   '{20D04FE0-3AEA-1069-A2D8-08002B30309D}'
end;

procedure TfrmMain.pnlSettingsClick(Sender: TObject);
begin
  frmParaSetting.Show;
end;

procedure TfrmMain.pnlTerminateClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmMain.tmrMainTimer(Sender: TObject);
var
  En:TEncoding;
  actSens : THTsensors;
begin

  ActSens := ConfigDat.ActiveSensors;
  if (ConfigDat.changed)or(Length(ActSens)<>ConfigDat.LastAct) then
  begin
    ConfigDat.SaveRecord(ActSens,Length(ActSens)<>ConfigDat.LastAct);
    UpdateDisplay(ActSens);
    ConfigDat.Changed := false;
    ConfigDat.LastAct := Length(ActSens);
  end;
  //广播收取数据
  mmoMsg.Lines.Clear;
  idpsrvrMain.Broadcast('ReadData65535',1503);          //    ,'255.255.255.255',En.ASCII

  //动态显示数据
  lblTime.Caption := FormatDateTime(ConfigDat.dfFormat,(Now));
end;

end.
