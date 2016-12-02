unit ParaSetting;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls,IniFiles, IdBaseComponent,
  IdComponent, IdUDPBase, IdUDPServer,IdSocketHandle,Math,Registry, OleCtrls,
  MSCommLib_TLB, RzCmboBx;
const
//  THNum = 8;
  NCalPar = 2;
  NSenAMod= 2;
  CfgFileExt = '.cfg';
  UndefineValue = 9999;
  GPSExStr='$GNRMC,023100.000,A,3132.396407,N,10447.834636,E,0.009,188.740,140816,,E,A*32';
  RgTootkey=HKEY_CURRENT_USER;
type
  Tvreal = array of Real;

  //校正测试点
  TCalPoint = record
    Real,Mea:Real;
  end;

  //修正参数及修正点数据
  TCorPar= record
    CalPar: Tvreal;       //用于修正的数据
    CalPoints:array[0..NCalPar-1] of TCalPoint; // 温湿度参考点的数据
    function GetCalPar():Tvreal;
  end;

//  THTData = record
//    ID:integer;  //记录模块
//    Humi,
//    Temp:array[0..1] of Real;      //温湿度,两个通道
//    function CorrectHumi(const Paras: Tvreal;const ChiD:byte=0):Real;
//    function CorrectTemp(const Paras: Tvreal;const ChiD:byte=0):Real;
//  end;

  //传感器信息
  TpHTsensor = ^THTsensor;
  THTsensor = record

    SeqNum:Cardinal;   //顺序号
    SerNum,            //序列号
    Location:string;   //位置信息

    ModID,             //模块编号
    ChID:integer;      //端口编号

    FHumi,            //湿度
    FTemp: Real;      //温度

    Active:Boolean;

    CorParH,           //湿度修正系数
    CorParT:TCorPar;   //温度修正系数
  private
    function FGetTemp:Real;
    function FGetHumi:Real;
  public
    property Temp:Real  read FGetTemp;
    property Humi:Real  read FGetHumi;
  end;
  THTsensors = array of THTsensor;



  TModul = record
    Online:Boolean;
    ShowLabel:string;    //显示名称=
    ModID,               //模块编号=1
    Port:integer;         //端口号
    IP:string;           //IP地址=10.90.200.101
    SenLabel:array[0..NSenAMod-1] of String;    //传感器编号
    pHTsensors:array[0..NSenAMod-1] of TpHTsensor;//传感器编号
  end;
  TModuls = array of  TModul;

  TConfig = record
    RecDatPath:string; //数据保存路径
    SysLoaction,       //系统位置=散射大厅
//OPC读状态=ReadData
//OPC读状态及附加信息=ReadDataWithInfo
    cmdOPCReadStatus:string; //OPC读指令=ReadData
    cmdOPCReadStatusWithInfo:string;
    dfFormat:string;   //时间显示格式
    NSenARow,          //每行显示传感器数目
    ModNum,            //模块数=4
    SenNum,            //传感器数=8
    DefPort,           //默认端口号=1503
    OPCPort:Integer;   //OPC端口号=9209

    UpDateTime:TDateTime;
    HTsensors: THTsensors;
    Moduls: TModuls;

    Changed:Boolean;
    LastAct:Integer;  //记录前次的活动传感器数目

    ComPort:string;
    BaudRate,
    DataBit,
    StopBit,
    BuffSize:Cardinal;
    GPSOnline:Boolean;

    function ActiveSensors:THTsensors;
    Function RegThisdata(const RevStr:string;const IP:string=''):Integer;
    procedure LoadfromInifile(const iniFnam:string);
    procedure SaveRecord(const ActSens:THTsensors;const ForceInfOut:Boolean=False);
    function GetRecordStr(const IncludeInf:Boolean=False):string;
  end;
type
  TfrmParaSetting = class(TForm)
    grp1: TGroupBox;
    pnl1: TPanel;
    lbl1: TLabel;
    cbbModu: TComboBox;
    btnSetComm: TBitBtn;
    grp2: TGroupBox;
    strgrdCommunication: TStringGrid;
    grp4: TGroupBox;
    btnOpen: TBitBtn;
    btnRefreshCom: TBitBtn;
    chkCorrectSysTime: TCheckBox;
    pnl4: TPanel;
    lbl7: TLabel;
    lbl8: TLabel;
    lbl9: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    rzcbbComName: TRzComboBox;
    rzcbbBaudRate: TRzComboBox;
    rzcbbByteSize: TRzComboBox;
    rzcbbStopBits: TRzComboBox;
    rzcbbParity: TRzComboBox;
    rzcbbBuffSize: TRzComboBox;
    grp7: TGroupBox;
    pnl3: TPanel;
    lbl3: TLabel;
    cbbSensor: TComboBox;
    btnSetCor: TBitBtn;
    grp3: TGroupBox;
    strgrdCorrect: TStringGrid;
    grp8: TGroupBox;
    strgrdSenAdd: TStringGrid;
    mscmCOM: TMSComm;
    tmr1: TTimer;
    idpsrvrMain: TIdUDPServer;
    mmoMsg: TMemo;
    procedure btnSetCommClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure idpsrvrMainUDPRead(AThread: TIdUDPListenerThread; AData: TBytes;
      ABinding: TIdSocketHandle);
    procedure tmr1Timer(Sender: TObject);
    procedure cbbModuChange(Sender: TObject);
    procedure cbbSensorChange(Sender: TObject);
    procedure btnSetCorClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnRefreshComClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure mscmCOMComm(Sender: TObject);
  private
    { Private declarations }
    procedure LoadfromInifile(const iniFnam:string);
    procedure UpdateGUI;
    procedure OpenGPSCOM();
  public
    { Public declarations }
  end;

procedure SetAutorun(aProgTitle,aCmdLine: string; aRunOnce,Enable: boolean);
//枚举COM
procedure ListCom(ComShower : TStrings);

var
  frmParaSetting: TfrmParaSetting;
  ConfigDat:TConfig;
  CfgFulFNam:string;
  Strs:TStringList;


implementation

{$R *.dfm}

uses Main;

//查询是否设置该程序在注册表中
function  Registered(aProgTitle,aCmdLine: string):boolean;
var
  hReg: Tregistry;
  str0:string;
begin     //程序名称，可以为自定义值
  hReg:=TRegistry.Create;
  hReg.RootKey:=RgTootkey;
  result:=False;
  if   hReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run',false) then//如果位置存在才成功
      if   hReg.ValueExists(aProgTitle)   then
      begin  //说明键存在
          str0:=hReg.ReadString(aProgTitle);
             result:= str0=aCmdLine; //是你的值
      end;

end;

procedure SetAutorun(aProgTitle,aCmdLine: string; aRunOnce,Enable: boolean);
var
  hKey: string;
  hReg: TRegIniFile;
begin
  if aRunOnce then
  //程序只自动运行一次
    hKey := 'Once'
  else
    hKey := '';
  hReg := TRegIniFile.Create('');
  //TregIniFile类的对象需要创建
  hReg.RootKey := RgTootkey;
  if Enable then
    hReg.WriteString('Software\Microsoft\Windows\CurrentVersion\Run'     //设置根键
                  + hKey + #0,
                  aProgTitle,
                  //程序名称，可以为自定义值
                  aCmdLine )
                  //命令行数据，必须为该程序的绝对路径＋程序完整名称
  else
     hReg.DeleteKey('Software\Microsoft\Windows\CurrentVersion\Run'     //设置根键
                  + hKey + #0,aProgTitle); //程序名称，可以为自定义值
  hReg.destroy;
  //释放创建的hReg
end;

function AssignVal(var OldVal:real;const NewVal:real) :Boolean;
begin
  Result := abs(OldVal-NewVal)>0.1;
  OldVal := NewVal;
end;

Function BytesToHex(const ABytes:TBytes;const NbyteAline:Integer=16):string;
var
  i,j:integer;
begin
  Result := '';
  i := 0;
  while i<Length(ABytes) do
  begin
//    if idOffset>=0 then
//      Result:= Result + Format('%.4xh: ',[idOffset + i]);
    for j := i to i+Min(NbyteAline,length(ABytes)) - 1 do
    begin
      Result  := Result + Format('%.2x ',[ABytes[j]]);
    end;
//    Result := Result+ slinebreak;  //          +s1
    Inc(i,NbyteAline);
  end;
end;

//枚举COM
procedure ListCom(ComShower : TStrings);
var
  rCom : TRegistry;
  lCom : TStrings;
  sComName :string;
  i:Integer;
begin
  rCom := TRegistry.Create;
  lCom := TStringlist.Create;
  ComShower.Clear;
  try
    rCom.RootKey := HKEY_LOCAL_MACHINE;
    if rCom.OpenKey('HARDWARE\DEVICEMAP\SERIALCOMM', false) then
    begin
      //rCom.GetKeyNames(lCom);
      rCom.GetValueNames(lCom);
      for I := 0 to lCom.Count - 1 do
      begin
        sComName := rCom.ReadString(lCom.Strings[I]);
        if (sComName[1]  = 'C') and (sComName[2]  = 'O') and (sComName[3]  = 'M') then
          ComShower.Add(sComName); //要找的COM口名字,其他信息你自己分析吧.

      end;
     end;
  finally
    lCom.Free;
    rCom.Free;
  end;
end;

function THTsensor.FGetTemp:Real;
begin
  Result := CorParT.CalPar[0]  +  CorParT.CalPar[1] * FTemp;
end;

function THTsensor.FGetHumi:Real;
begin
  Result := CorParH.CalPar[0]  +  CorParH.CalPar[1] * FHumi;
end;

function TCorPar.GetCalPar():Tvreal;
begin
  SetLength(CalPar,2);
  CalPar[0] := 0.0;
  CalPar[1] := 1.0;

  result:=CalPar;
end;

//解析形如以下格式的模块返回数据
//'ID=%d;hum1=%.1f%%;tem1=%.1fC;hum2=%.1f%%;tem2=%.1fC;'
function DeCodeModulAnswer(const Code:string):TvReal;
var
  ss:string;
  i,ps:Integer;
begin
  ss := StringReplace(Code,'%','',[rfReplaceAll]); //删除湿度单位；
  ss := StringReplace(ss,';;',';',[rfReplaceAll]);   //删除温度单位；
  ss := StringReplace(ss,'C','',[rfReplaceAll]);   //删除温度单位；
  Strs.Delimiter := ';';
  Strs.DelimitedText := ss;
  SetLength(Result,Strs.Count);
  for I := 0 to Strs.Count - 1 do
  begin
    ss := Strs.Strings[i];
    ps := Pos('=',ss);
    if ps>0 then Delete(ss,1,ps);

    ps := Pos('ee',ss);
    if ((length(ss)>0) and (ps<1)) then
      Result[i] := StrToFloat(ss)
    else
      Result[i] := UndefineValue;
  end;
end;

Function TConfig.RegThisdata(const RevStr:string;const IP:string=''):Integer;
var
  im,id,i:integer;
  RevPar:TvReal;
begin
  //'ID=%d;Hum1=%.1f%%;Yem1=%.1fC;Hum2=%.1f%%;Tem2=%.1fC;'
  if (Pos('ID=',RevStr)<1) or (Pos('Hum',RevStr)<1)or(Pos('Tem',RevStr)<1) then Exit(-1);
  //查找对应的模块
  UpDateTime := Now();


  RevPar := DeCodeModulAnswer(RevStr);


  Im := -1;
  if IP<>'' then  //按照IP查找
  begin
    for Im := 0 to ModNum - 1 do
    begin
      if CompareText(Moduls[im].IP,IP)=0 then
      begin
        Break;
      end;
    end;
  end;

  //没有找到模块，则用模块ID查找。
  if (im<0)or(im>=ModNum) then
  begin
    id := Round(RevPar[0]);  //模块ID
    for Im := 0 to ModNum - 1 do
    begin
      if Moduls[im].ModID = id then
      begin
        Break;
      end;
    end;
  end;

  if im<0 then
    ShowMessage('Modul ID<0！');

  Result := im; //返回接收的模块ID

  with Moduls[im] do
  begin
    Online := True;
    for i := 0 to NSenAMod - 1 do with pHTsensors[i]^ do
    begin
      Active := (RevPar[2+i*NSenAMod]<>UndefineValue)and(RevPar[1+i*NSenAMod]<>UndefineValue);
      Changed := AssignVal(FTemp,RevPar[2+i*NSenAMod])or Changed;     //解析出温度
      Changed := AssignVal(FHumi,RevPar[1+i*NSenAMod])or Changed;    //解析出湿度
    end;
  end;

end;

function TConfig.GetRecordStr(const IncludeInf:Boolean=False):string;
var
  iSen:integer;
  Recs,Caps,Note:string;
  OutF:TextFile;
  Fnam:string;
begin
  Fnam := FormatDateTime('yyyy-dd-mm',UpDateTime);
  Note := '# TemperatureUnit=℃'+slinebreak+'# HumidityUnit=%';

  Recs := Format('t=%s;',[FormatDateTime('yyyy-mm-dd hh:mm:ss zzz',UpDateTime)]);
  for iSen := 0 to SenNum - 1 do with HTsensors[isen] do
  if Active then
  begin
    Note := Note + Format(slinebreak+'# HT%d: Location=%s,SerNum=%s,seqNum=%d',[iSen+1,Location,SerNum,SeqNum]);
    Recs := Recs +Format('T%d=%.1f;H%d=%.1f;',[iSen+1,Temp,iSen+1,Humi]);  //  % C   %
  end;
  Note := Note + slinebreak +'# Date='+Fnam;

  if IncludeInf then
  begin
    Result := Note+ slinebreak+ Recs;
  end
  else
    Result := Recs;

end;

function TConfig.ActiveSensors:THTsensors;
var
  i,n:integer;
begin
  SetLength(Result,SenNum);
  n := 0;
  for I := 0 to SenNum - 1 do
  begin
    if (HTsensors[i].Active) then
    begin
      Result[N] := HTsensors[i];
      HTsensors[i].Active := False;
      Inc(N);
    end;
  end;
  SetLength(Result,N);
  changed := changed or (N<>LastAct);
end;

procedure TConfig.SaveRecord(const ActSens:THTsensors;const ForceInfOut:Boolean=False);
var
  iSen:integer;
  Recs,Caps,Note:string;
  OutF:TextFile;
  Fnam:string;

  i,n:integer;
begin
  //提取变化的内容 2016/8/31 20:59:14

  Fnam := FormatDateTime('yyyy-mm-dd',UpDateTime);
  Note := '# 温度单位:℃'+slinebreak+'# 湿度单位:%';

  Caps := 'time';
  Recs := FormatDateTime('hh:mm:ss',UpDateTime);
  for iSen := 0 to Length(ActSens) - 1 do with ActSens[isen] do
  begin
    Note := Note + Format(slinebreak+'# HT%d: Loc=%s,SerNum=%s,seqNum=%d',[iSen+1,Location,SerNum,SeqNum]);
    Caps := Caps +Format(#9'T%d'#9'H%d',[iSen+1,iSen+1]);
    Recs := Recs +Format(#9'%.1f'#9'%.1f',[Temp,Humi]);
  end;
  Note := Note + slinebreak +'# Date='+Fnam;

  Fnam := RecDatPath + Fnam+'.log';
  AssignFile(OutF,Fnam);
  if FileExists(Fnam) then
  begin
    Append(OutF);
    if ForceInfOut then
    begin
      Writeln(OutF,Note);
      Writeln(OutF,Caps);
    end;
  end
  else
  begin
    ReWrite(OutF);
    Writeln(OutF,Note);
    Writeln(OutF,Caps);
  end;
  Writeln(OutF,Recs);

  Flush(OutF);

  CloseFile(OutF);
end;

procedure TConfig.LoadfromInifile(const iniFnam:string);
var
  i,j,k,ps:Integer;
  SecNam,s0,s1:string;
  InF:TIniFile;
  ss:TStringList;
begin
  if not FileExists(iniFnam)  then
  begin
    ShowMessage(Format('文件【%s】不存在，读取配置文件终止！',[iniFnam]));
  end;

  InF:= TIniFile.Create(iniFnam);
  ss := TStringList.Create;
  //读取系统配置
  RecDatPath := InF.ReadString('系统配置','HTt日志数据',ExtractFilePath(Application.ExeName)+'HTtLogData\'); //系统位置=散射大厅
  if not DirectoryExists(RecDatPath) then
  begin
    if not ForceDirectories(RecDatPath) then
    begin
      ShowMessage(Format('创建文件路径失败：%s',[RecDatPath]));
    end;
  end;
    ComPort := InF.ReadString('GPS串口参数','串口号','COM5');
    BaudRate:= InF.ReadInteger('GPS串口参数','波特率',9600);
    DataBit:= InF.ReadInteger('GPS串口参数','数据位',8);
    StopBit:= InF.ReadInteger('GPS串口参数','停止位',1);
    BuffSize:= InF.ReadInteger('GPS串口参数','缓存大小',1024);
//OPC读状态=ReadData
//OPC读状态及附加信息=ReadDataWithInfo


    NSenARow   := InF.ReadInteger('系统配置','每行显示传感器数',2);     //默认端口号=1503
    dfFormat   := InF.ReadString('系统配置','时间显示格式','YYYY-MM-DD HH:mm:ss');     //默认端口号=1503
    DefPort    := InF.ReadInteger('系统配置','默认端口号',1503);     //默认端口号=1503
    OPCPort    := InF.ReadInteger('系统配置','OPC端口号',9209); //OPC端口号=9209
    cmdOPCReadStatus := InF.ReadString('系统配置','OPC读状态','ReadData');         //OPC读指令=ReadData
    cmdOPCReadStatusWithInfo := InF.ReadString('系统配置','OPC读状态及附加信息','ReadDataWithInfo');         //OPC读指令=ReadData
    SysLoaction:= InF.ReadString('系统配置','系统位置',''); //系统位置=散射大厅
    s0         := InF.ReadString('系统配置','传感器模块',''); //HRND,RSND,HPND,CTAS,TPNR,SANS
    s0         := StringReplace(s0,' ','',[rfReplaceAll]);
    s0         := StringReplace(s0,' ','',[rfReplaceAll]);
    s0         := StringReplace(s0,'；',';',[rfReplaceAll]);
    s0         := StringReplace(s0,'；',';',[rfReplaceAll]);
    strs.Delimiter := ',';
    strs.DelimitedText := s0;

    ModNum := strs.Count;
    setlength(Moduls,ModNum);
    ModNum := 0;
    ss.Delimiter := ',';
    for I := 0 to strs.Count - 1 do with Moduls[ModNum]  do
    begin
      //模块名称
      SecNam := TrimLeft(Trim(Strs.Strings[i]));

      //如果模块不存在，则忽略
      if not InF.SectionExists(SecNam) then Continue;

      //读取模块
      ModID     := InF.ReadInteger(SecNam,'模块编号',ModNum+1);      // 模块编号=8
      Port      := InF.ReadInteger(SecNam,'端口号',DefPort);      //端口号=1503
      ShowLabel := InF.ReadString(SecNam,'显示名称',SecNam);      //显示名称=模块1
      IP := InF.ReadString(SecNam,'IP地址','');      //IP地址=0.90.200.101

      s0 := InF.ReadString(SecNam,'传感器','');      //IP地址=10.90.200.101
      s0 := StringReplace(s0,' ','',[rfReplaceAll]);
      s0 := StringReplace(s0,' ','',[rfReplaceAll]);
      s0 := StringReplace(s0,'；',';',[rfReplaceAll]);
      s0 := StringReplace(s0,'；',';',[rfReplaceAll]);
      ss.DelimitedText := s0;
      k := 0;
      for j := 0 to ss.Count - 1 do
      begin
        s0 := TrimLeft(Trim(ss.Strings[j]));
        //检查传感器字段是否存在
        if not InF.SectionExists(s0) then  s0 := '';   //表示未配置该传感器

        //记载传感器
        SenLabel[k] := s0;
        Inc(k);
        if k=Length(SenLabel) then break;
      end;
      Inc(ModNum);
    end;
    //更新模块个数
    setlength(Moduls,ModNum);

    //读取传感器配置
    SenNum := ModNum*NSenAMod;
    setlength(HTsensors,SenNum);//: THTsensors;
    SenNum := 0;
    for I := 0 to ModNum - 1 do  with Moduls[i]  do
    begin
      for k := 0 to NSenAMod - 1 do
      begin
        SecNam := SenLabel[k];
        //传感器不存在
        if not InF.SectionExists(SecNam) then
        begin
          pHTsensors[k] := nil;
          if SenLabel[k] = '' then  //没有
            ShowMessage(Format('提示:传感器[%s]没有配置参数！',[SenLabel[k]]));
          Continue;
        end;

        with HTsensors[SenNum]  do
        begin
          SeqNum := InF.ReadInteger(SecNam,'HT序号',SenNum+1);            //HT编号=2
          SerNum := InF.ReadString(SecNam,'识别码',IntToStr(SenNum+1));   //HT SN=2
          Location := InF.ReadString(SecNam,'HT位置',Format('位置%d',[SenNum+1]));      //HT位置=位置2
          for j := 0 to NCalPar - 1 do
          begin
            with CorParH.CalPoints[j] do
            begin
              Real := InF.ReadInteger(SecNam,Format('实际湿度%d',[j+1]),j*50);      //实际湿度1=0
              Mea := InF.ReadInteger(SecNam,Format('测试湿度%d',[j+1]),j*50);      //测试湿度1=0
            end;
            with CorParT.CalPoints[j] do
            begin
              Real := InF.ReadInteger(SecNam,Format('实际温度%d',[j+1]),j*50);      //实际温度1=0
              Mea := InF.ReadInteger(SecNam,Format('测试温度%d',[j+1]),j*50);      //测试温度1=0
            end;
          end;
          FTemp := UndefineValue;  //初始化，后续判断是否在线的依据。
          FHumi := UndefineValue;  //初始化
          CorParH.GetCalPar;  //计算湿度系数
          CorParT.GetCalPar;  //计算温度系数
        end;
        pHTsensors[k] := @HTsensors[SenNum];
        Inc(SenNum);
      end;
    end;
  inF.Free;
  ss.Free;
  UpDateTime := Now();
end;



procedure TfrmParaSetting.LoadfromInifile(const iniFnam:string);
begin

end;

procedure TfrmParaSetting.mscmCOMComm(Sender: TObject);
var
  buffer: Olevariant;//MSComm1.InputMode = comInputModeBinary
  str,s0,RevStr: string;//MSComm1.InputMode = comInputModeText
  i: integer;
  RevBytes:TBytes;
  PV,SV,MV,Val,CRC,HH,MM,SS,ZZ :Word;
  dt:TDateTime;
  dt_sys:TSystemTime;
begin
  case mscmCOM.CommEvent of
  comEvSend:
    begin
      if mscmCOM.InputMode = comInputModeText then //字符方式读取
        str := mscmCOM.Input//读出后会自动清除接收缓冲区,str[1]~str[32]
      else //二进制方式读取
      begin
        buffer := mscmCOM.Input;//读出后会自动清除接收缓冲区,buffer[0]~buffer[31]
        RevBytes := TBytes(buffer);
        str := stringof(RevBytes);
      end;
      frmMain.mmoMsg.Lines.Add(Format('%s S %s',[FormatDatetime('hh:mm:ss zzz',Now()),str]));//加入一行显示
    end;

  comEvReceive: //串行接收事件处理
    begin
      if mscmCOM.InputMode = comInputModeText then //字符方式读取
        str := mscmCOM.Input//读出后会自动清除接收缓冲区,str[1]~str[32]
      else //二进制方式读取
      begin
        mscmCOM.InBufferCount;
        buffer := mscmCOM.Input;//读出后会自动清除接收缓冲区,buffer[0]~buffer[31]

        RevBytes := TBytes(buffer);

        s0 := BytesToHex(RevBytes);
        str := stringof(RevBytes);
        //'$GNRMC,023100.000,A,3132.396407,N,10447.834636,E,0.009,188.740,140816,,E,A*32';
        Strs.Delimiter := ',';
        Strs.DelimitedText := str;
        if Strs.Strings[0]='$GNRMC' then
        begin
          s0 := Strs.Strings[1];
          HH := StrToInt(Copy(s0,1,2));
          HH :=  (HH+8 mod 24);
          MM := StrToInt(Copy(s0,3,2));
          SS := StrToInt(Copy(s0,5,2));
          ZZ := StrToInt(Copy(s0,8,3));


          GetlocalTime(dt_sys); //获取当前系统时间
            with dt_sys do
            begin
              wHour  := HH;
              wMinute:= MM;
              wSecond:= SS;
            end;

          ConfigDat.GPSOnline := True;
          if chkCorrectSysTime.Checked then
          begin
            if not SetLocalTime(dt_sys) then
              frmMain.mmoMsg.Lines.Add(Format('@mscmCOMComm Failed to SetLocalTime',[]));//加入一行显示
          end;

        end;
      end;
      frmMain.mmoMsg.Lines.Add(Format('%-2d:%-2d:%-2d %-3d R %s',[HH,MM,SS,ZZ,str]));//加入一行显示;

    end;
  end;

end;

procedure TfrmParaSetting.UpdateGUI;
var
  i,curId:integer;
begin
  curId := cbbModu.ItemIndex;
  cbbModu.Items.Clear;
  for I := 0 to ConfigDat.ModNum - 1 do
    cbbModu.Items.Add(Format('%s',[ConfigDat.Moduls[i].ShowLabel]));
  cbbModu.ItemIndex := Max(0, Min(cbbModu.Items.Count,curId));

  cbbModuChange(cbbModu);

  curId := cbbSensor.ItemIndex;
  cbbSensor.Items.Clear;
  for I := 0 to ConfigDat.SenNum - 1 do
    cbbSensor.Items.Add(Format('%s',[ConfigDat.HTsensors[i].Location]));
  cbbSensor.ItemIndex := Max(0, Min(cbbSensor.Items.Count,curId));

  cbbSensorChange(cbbSensor);

end;
//
//function THTData.CorrectHumi(const Paras: Tvreal;const ChiD:byte=0):Real;
//begin
//  Result := Humi[ChiD];   //后续修正
//end;
//
//function THTData.CorrectTemp(const Paras: Tvreal;const ChiD:byte=0):Real;
//begin
//  Result := Temp[ChiD];   //后续修正
//end;

procedure TfrmParaSetting.OpenGPSCOM();
var
  s0 :string;
begin
  s0 := rzcbbComName.Text;;
  Delete(s0,1,3);

  //如果已经打开了端口，则关闭端口
  if mscmCOM.PortOpen then
    mscmCOM.PortOpen := False;

  if Length(s0)>0 then
  begin
    mscmCOM.CommPort :=  StrToInt(s0);
    //    mscmCOM.CommPort := 2;//设置端口2
    mscmCOM.InBufferSize := StrToIntDef(rzcbbBuffSize.Text,1024);//设置接收缓冲区为256个字节
    mscmCOM.OutBufferSize := StrToIntDef(rzcbbBuffSize.Text,1024);//设置发送缓冲区为256个字节
    mscmCOM.Settings := Format('%s,n,%s,1',[rzcbbBaudRate.Text,rzcbbByteSize.Text]);//9600波特率，无校验，8位数据位，1位停止位   // '9600,n,8,1'
    mscmCOM.InputLen := 0;       //读取缓冲区全部内容(32个字节)
    mscmCOM.InBufferCount := 0;  // 清除接收缓冲区
    mscmCOM.OutBufferCount:=0;   // 清除发送缓冲区
    mscmCOM.RThreshold := Length(GPSExStr); //StrToIntdef(cbbRThreshold.Text,20);    //设置接收10个字节产生OnComm 事件

//     mscmCOM.InputMode := comInputModeText; //文本方式
    mscmCOM.InputMode := comInputModeBinary;  //二进制方式


    mscmCOM.PortOpen := true;//打开端口;
    mmoMsg.Lines.Add(Format('COM%d port openned. RThreshold = %d bytes',[mscmCOM.CommPort,Length(GPSExStr)]));
    if mscmCOM.PortOpen then
    begin
//      with ReadThisPar(rzcbbAIAddr.ItemIndex,$0C,False) do
//      begin
//        FdPt := Val;
//        rzchckbxState.Caption := Format('当前PV=%.1f℃,SV=%.1f℃',
//          [rPv*DotFact[FdPt],rSV*DotFact[FdPt]]);
//        rzstspn2.Caption := rzchckbxState.Caption;
//      end;
//      rzstspn1.Caption := Format('COM%d已打开！',[mscmCOM.CommPort]);

    end;

//    rzbtbtnOpenCOM.Enabled := not mscmCOM.PortOpen;
//    rzbtbtnCloseCOM.Enabled := mscmCOM.PortOpen;
//    rzchckbxState.Enabled := mscmCOM.PortOpen;
  end;

end;

procedure TfrmParaSetting.btnOpenClick(Sender: TObject);
begin
  //如果已经打开了端口，则关闭端口
  if not mscmCOM.PortOpen then
  begin
     OpenGPSCOM();
     btnOpen.Caption:= '关闭串口';
  end
  else
  begin
     mscmCOM.PortOpen := False;
     btnOpen.Caption:= '打开串口';
  end;
end;

procedure TfrmParaSetting.btnRefreshComClick(Sender: TObject);
var
  COM0:string;
begin
  COM0 := rzcbbCOMName.Text;
  ListCom(rzcbbCOMName.Items);
  if COM0<>'' then
  begin
    rzcbbCOMName.ItemIndex := rzcbbCOMName.IndexOf(COM0);
  end
  else
    rzcbbCOMName.ItemIndex := rzcbbCOMName.Items.Count -1;

end;

procedure TfrmParaSetting.btnSetCommClick(Sender: TObject);
var
  cmd:string;
begin              //发送数据
  cmd := format('SetParameter1:ID=%s&IP=%s&Port=%s&Restart',[
    strgrdCommunication.Cells[2,1],
    strgrdCommunication.Cells[2,2],
    strgrdCommunication.Cells[2,3]
  ]);// + NewID.Text + "" + NewIP.Text + "" + NewPort.Text + "";//发送需要修改的数据-----------------------------
end;

procedure TfrmParaSetting.btnSetCorClick(Sender: TObject);
var
  i,j,k,ps:Integer;
  SecNam,s0,s1:string;
  InF:TIniFile;
begin
  if not FileExists(CfgFulFNam)  then
  begin
    ShowMessage(Format('文件【%s】不存在，读取配置文件终止！',[CfgFulFNam]));
  end;

  InF:= TIniFile.Create(CfgFulFNam);
 {
 HT序号=1
识别码=1
HT位置=位置1
实际温度1=0
测试温度1=0
实际温度2=50
测试温度2=50
实际湿度1=0
测试湿度1=0
实际湿度2=80
测试湿度2=80
 }
//  SecNam := Format('',[ConfigDat.SenPre,cbbSensor.ItemIndex]);
//  InF.WriteString(SecNam,);


  inF.Free;

end;

procedure TfrmParaSetting.cbbModuChange(Sender: TObject);
var
  i,ID:Integer;
begin
  ID := cbbModu.ItemIndex;
  if ID<0 then Exit;

  with ConfigDat.Moduls[id],strgrdCommunication do
  begin
    Cells[0,1] := '编号';     Cells[1,1] :=  IntToStr(ModID);
    Cells[0,2] := 'IP地址';   Cells[1,2] :=  IP;
    Cells[0,3] := '端口号';   Cells[1,3] :=  IntToStr(Port);
    for I := 0 to NSenAMod - 1 do
    begin
      Cells[0,4+i] := format('传感器%d',[i+1]);
      with ConfigDat.Moduls[id].pHTsensors[i]^ do
      Cells[1,4+i] := Format('%d@%s',[i,Location]);
    end;
    RowCount := NSenAMod+4;

  end;


end;

procedure TfrmParaSetting.cbbSensorChange(Sender: TObject);
var
  i,j,ID:Integer;
begin
  ID := cbbSensor.ItemIndex;
  if ID<0 then exit;

  with ConfigDat.HTsensors[id] do
  begin
    //显示附加信息
    strgrdSenAdd.Cells[1,1] := IntToStr(seqNum);
    strgrdSenAdd.Cells[1,2] := SerNum;
    strgrdSenAdd.Cells[1,3] := Location;

    for I := 0 to NCalPar - 1 do
    begin
        strgrdCorrect.Cells[0,1+i] := Format('温度%d',[i+1]);
        strgrdCorrect.Cells[1,1+i] := FloatToStr(CorParT.CalPoints[i].Mea);
        strgrdCorrect.Cells[2,1+i] := FloatToStr(CorParT.CalPoints[i].Real);

        strgrdCorrect.Cells[0,1+i+NCalPar] := Format('湿度%d',[i+1]);
        strgrdCorrect.Cells[1,1+i+NCalPar] := FloatToStr(CorParH.CalPoints[i].Mea);
        strgrdCorrect.Cells[2,1+i+NCalPar] := FloatToStr(CorParH.CalPoints[i].Real);
    end;
  end;
end;

procedure TfrmParaSetting.FormCreate(Sender: TObject);
begin
  Strs := TStringList.Create;
  CfgFulFNam := ChangeFileExt(Application.ExeName,CfgFileExt);
  ConfigDat.LoadfromInifile(CfgFulFNam);

  with strgrdCommunication do
  begin
    DefaultColWidth := (Width div colCount) -  GridLineWidth;
    Cells[1,0] := '当前值';  Cells[2,0] := '拟改值';

    Cells[0,1] := '编号';
    Cells[0,2] := 'IP地址';
    Cells[0,3] := '端口号';
    Cells[0,4] := '位置';
    ColWidths[0] := Canvas.TextWidth('传感器10');
    ColWidths[1] := (Width - ColWidths[0] - GridLineWidth)div 2 - GridLineWidth*5;
    ColWidths[2] := ColWidths[1];
    RowCount := 5+NsenAMod;
  end;

  with strgrdSenAdd do
  begin
    DefaultColWidth := (Width div RowCount) -  GridLineWidth*5;
    Cells[1,0] := '当前值';  Cells[2,0] := '拟改值';

    Cells[0,1] := '序号';
    Cells[0,2] := '识别码';
    Cells[0,3] := '位置';
    RowCount := 4;
  end;

  with strgrdCorrect do
  begin
    DefaultColWidth := (Width div RowCount) -  GridLineWidth*5;
    Cells[1,0] := '读取值';  Cells[2,0] := '实际值';
    RowCount := 1+NCalPar*2;
  end;


  UpdateGUI;

  btnRefreshComClick(btnRefreshCom);
  rzcbbComName.ItemIndex := rzcbbComName.Items.IndexOf(ConfigDat.ComPort);

  btnOpenClick(btnOpen);

  UpdateGUI;

end;

procedure TfrmParaSetting.FormDestroy(Sender: TObject);
var
  ActSens:THTsensors;
begin
  ActSens := ConfigDat.ActiveSensors;
  ConfigDat.SaveRecord(ActSens);
  Strs.Free;
end;

procedure TfrmParaSetting.idpsrvrMainUDPRead(AThread: TIdUDPListenerThread;
  AData: TBytes; ABinding: TIdSocketHandle);
var
  RevStr:string;
begin

end;

procedure TfrmParaSetting.tmr1Timer(Sender: TObject);
var
  En:TEncoding;
begin
//  //广播数据
//  idpsrvrMain.Broadcast('ReadData65535',1503,'255.255.255.255',En.ASCII);
end;

end.
