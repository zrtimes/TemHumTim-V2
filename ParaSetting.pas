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

  //У�����Ե�
  TCalPoint = record
    Real,Mea:Real;
  end;

  //��������������������
  TCorPar= record
    CalPar: Tvreal;       //��������������
    CalPoints:array[0..NCalPar-1] of TCalPoint; // ��ʪ�Ȳο��������
    function GetCalPar():Tvreal;
  end;

//  THTData = record
//    ID:integer;  //��¼ģ��
//    Humi,
//    Temp:array[0..1] of Real;      //��ʪ��,����ͨ��
//    function CorrectHumi(const Paras: Tvreal;const ChiD:byte=0):Real;
//    function CorrectTemp(const Paras: Tvreal;const ChiD:byte=0):Real;
//  end;

  //��������Ϣ
  TpHTsensor = ^THTsensor;
  THTsensor = record

    SeqNum:Cardinal;   //˳���
    SerNum,            //���к�
    Location:string;   //λ����Ϣ

    ModID,             //ģ����
    ChID:integer;      //�˿ڱ��

    FHumi,            //ʪ��
    FTemp: Real;      //�¶�

    Active:Boolean;

    CorParH,           //ʪ������ϵ��
    CorParT:TCorPar;   //�¶�����ϵ��
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
    ShowLabel:string;    //��ʾ����=
    ModID,               //ģ����=1
    Port:integer;         //�˿ں�
    IP:string;           //IP��ַ=10.90.200.101
    SenLabel:array[0..NSenAMod-1] of String;    //���������
    pHTsensors:array[0..NSenAMod-1] of TpHTsensor;//���������
  end;
  TModuls = array of  TModul;

  TConfig = record
    RecDatPath:string; //���ݱ���·��
    SysLoaction,       //ϵͳλ��=ɢ�����
//OPC��״̬=ReadData
//OPC��״̬��������Ϣ=ReadDataWithInfo
    cmdOPCReadStatus:string; //OPC��ָ��=ReadData
    cmdOPCReadStatusWithInfo:string;
    dfFormat:string;   //ʱ����ʾ��ʽ
    NSenARow,          //ÿ����ʾ��������Ŀ
    ModNum,            //ģ����=4
    SenNum,            //��������=8
    DefPort,           //Ĭ�϶˿ں�=1503
    OPCPort:Integer;   //OPC�˿ں�=9209

    UpDateTime:TDateTime;
    HTsensors: THTsensors;
    Moduls: TModuls;

    Changed:Boolean;
    LastAct:Integer;  //��¼ǰ�εĻ��������Ŀ

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
//ö��COM
procedure ListCom(ComShower : TStrings);

var
  frmParaSetting: TfrmParaSetting;
  ConfigDat:TConfig;
  CfgFulFNam:string;
  Strs:TStringList;


implementation

{$R *.dfm}

uses Main;

//��ѯ�Ƿ����øó�����ע�����
function  Registered(aProgTitle,aCmdLine: string):boolean;
var
  hReg: Tregistry;
  str0:string;
begin     //�������ƣ�����Ϊ�Զ���ֵ
  hReg:=TRegistry.Create;
  hReg.RootKey:=RgTootkey;
  result:=False;
  if   hReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run',false) then//���λ�ô��ڲųɹ�
      if   hReg.ValueExists(aProgTitle)   then
      begin  //˵��������
          str0:=hReg.ReadString(aProgTitle);
             result:= str0=aCmdLine; //�����ֵ
      end;

end;

procedure SetAutorun(aProgTitle,aCmdLine: string; aRunOnce,Enable: boolean);
var
  hKey: string;
  hReg: TRegIniFile;
begin
  if aRunOnce then
  //����ֻ�Զ�����һ��
    hKey := 'Once'
  else
    hKey := '';
  hReg := TRegIniFile.Create('');
  //TregIniFile��Ķ�����Ҫ����
  hReg.RootKey := RgTootkey;
  if Enable then
    hReg.WriteString('Software\Microsoft\Windows\CurrentVersion\Run'     //���ø���
                  + hKey + #0,
                  aProgTitle,
                  //�������ƣ�����Ϊ�Զ���ֵ
                  aCmdLine )
                  //���������ݣ�����Ϊ�ó���ľ���·����������������
  else
     hReg.DeleteKey('Software\Microsoft\Windows\CurrentVersion\Run'     //���ø���
                  + hKey + #0,aProgTitle); //�������ƣ�����Ϊ�Զ���ֵ
  hReg.destroy;
  //�ͷŴ�����hReg
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

//ö��COM
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
          ComShower.Add(sComName); //Ҫ�ҵ�COM������,������Ϣ���Լ�������.

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

//�����������¸�ʽ��ģ�鷵������
//'ID=%d;hum1=%.1f%%;tem1=%.1fC;hum2=%.1f%%;tem2=%.1fC;'
function DeCodeModulAnswer(const Code:string):TvReal;
var
  ss:string;
  i,ps:Integer;
begin
  ss := StringReplace(Code,'%','',[rfReplaceAll]); //ɾ��ʪ�ȵ�λ��
  ss := StringReplace(ss,';;',';',[rfReplaceAll]);   //ɾ���¶ȵ�λ��
  ss := StringReplace(ss,'C','',[rfReplaceAll]);   //ɾ���¶ȵ�λ��
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
  //���Ҷ�Ӧ��ģ��
  UpDateTime := Now();


  RevPar := DeCodeModulAnswer(RevStr);


  Im := -1;
  if IP<>'' then  //����IP����
  begin
    for Im := 0 to ModNum - 1 do
    begin
      if CompareText(Moduls[im].IP,IP)=0 then
      begin
        Break;
      end;
    end;
  end;

  //û���ҵ�ģ�飬����ģ��ID���ҡ�
  if (im<0)or(im>=ModNum) then
  begin
    id := Round(RevPar[0]);  //ģ��ID
    for Im := 0 to ModNum - 1 do
    begin
      if Moduls[im].ModID = id then
      begin
        Break;
      end;
    end;
  end;

  if im<0 then
    ShowMessage('Modul ID<0��');

  Result := im; //���ؽ��յ�ģ��ID

  with Moduls[im] do
  begin
    Online := True;
    for i := 0 to NSenAMod - 1 do with pHTsensors[i]^ do
    begin
      Active := (RevPar[2+i*NSenAMod]<>UndefineValue)and(RevPar[1+i*NSenAMod]<>UndefineValue);
      Changed := AssignVal(FTemp,RevPar[2+i*NSenAMod])or Changed;     //�������¶�
      Changed := AssignVal(FHumi,RevPar[1+i*NSenAMod])or Changed;    //������ʪ��
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
  Note := '# TemperatureUnit=��'+slinebreak+'# HumidityUnit=%';

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
  //��ȡ�仯������ 2016/8/31 20:59:14

  Fnam := FormatDateTime('yyyy-mm-dd',UpDateTime);
  Note := '# �¶ȵ�λ:��'+slinebreak+'# ʪ�ȵ�λ:%';

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
    ShowMessage(Format('�ļ���%s�������ڣ���ȡ�����ļ���ֹ��',[iniFnam]));
  end;

  InF:= TIniFile.Create(iniFnam);
  ss := TStringList.Create;
  //��ȡϵͳ����
  RecDatPath := InF.ReadString('ϵͳ����','HTt��־����',ExtractFilePath(Application.ExeName)+'HTtLogData\'); //ϵͳλ��=ɢ�����
  if not DirectoryExists(RecDatPath) then
  begin
    if not ForceDirectories(RecDatPath) then
    begin
      ShowMessage(Format('�����ļ�·��ʧ�ܣ�%s',[RecDatPath]));
    end;
  end;
    ComPort := InF.ReadString('GPS���ڲ���','���ں�','COM5');
    BaudRate:= InF.ReadInteger('GPS���ڲ���','������',9600);
    DataBit:= InF.ReadInteger('GPS���ڲ���','����λ',8);
    StopBit:= InF.ReadInteger('GPS���ڲ���','ֹͣλ',1);
    BuffSize:= InF.ReadInteger('GPS���ڲ���','�����С',1024);
//OPC��״̬=ReadData
//OPC��״̬��������Ϣ=ReadDataWithInfo


    NSenARow   := InF.ReadInteger('ϵͳ����','ÿ����ʾ��������',2);     //Ĭ�϶˿ں�=1503
    dfFormat   := InF.ReadString('ϵͳ����','ʱ����ʾ��ʽ','YYYY-MM-DD HH:mm:ss');     //Ĭ�϶˿ں�=1503
    DefPort    := InF.ReadInteger('ϵͳ����','Ĭ�϶˿ں�',1503);     //Ĭ�϶˿ں�=1503
    OPCPort    := InF.ReadInteger('ϵͳ����','OPC�˿ں�',9209); //OPC�˿ں�=9209
    cmdOPCReadStatus := InF.ReadString('ϵͳ����','OPC��״̬','ReadData');         //OPC��ָ��=ReadData
    cmdOPCReadStatusWithInfo := InF.ReadString('ϵͳ����','OPC��״̬��������Ϣ','ReadDataWithInfo');         //OPC��ָ��=ReadData
    SysLoaction:= InF.ReadString('ϵͳ����','ϵͳλ��',''); //ϵͳλ��=ɢ�����
    s0         := InF.ReadString('ϵͳ����','������ģ��',''); //HRND,RSND,HPND,CTAS,TPNR,SANS
    s0         := StringReplace(s0,' ','',[rfReplaceAll]);
    s0         := StringReplace(s0,' ','',[rfReplaceAll]);
    s0         := StringReplace(s0,'��',';',[rfReplaceAll]);
    s0         := StringReplace(s0,'��',';',[rfReplaceAll]);
    strs.Delimiter := ',';
    strs.DelimitedText := s0;

    ModNum := strs.Count;
    setlength(Moduls,ModNum);
    ModNum := 0;
    ss.Delimiter := ',';
    for I := 0 to strs.Count - 1 do with Moduls[ModNum]  do
    begin
      //ģ������
      SecNam := TrimLeft(Trim(Strs.Strings[i]));

      //���ģ�鲻���ڣ������
      if not InF.SectionExists(SecNam) then Continue;

      //��ȡģ��
      ModID     := InF.ReadInteger(SecNam,'ģ����',ModNum+1);      // ģ����=8
      Port      := InF.ReadInteger(SecNam,'�˿ں�',DefPort);      //�˿ں�=1503
      ShowLabel := InF.ReadString(SecNam,'��ʾ����',SecNam);      //��ʾ����=ģ��1
      IP := InF.ReadString(SecNam,'IP��ַ','');      //IP��ַ=0.90.200.101

      s0 := InF.ReadString(SecNam,'������','');      //IP��ַ=10.90.200.101
      s0 := StringReplace(s0,' ','',[rfReplaceAll]);
      s0 := StringReplace(s0,' ','',[rfReplaceAll]);
      s0 := StringReplace(s0,'��',';',[rfReplaceAll]);
      s0 := StringReplace(s0,'��',';',[rfReplaceAll]);
      ss.DelimitedText := s0;
      k := 0;
      for j := 0 to ss.Count - 1 do
      begin
        s0 := TrimLeft(Trim(ss.Strings[j]));
        //��鴫�����ֶ��Ƿ����
        if not InF.SectionExists(s0) then  s0 := '';   //��ʾδ���øô�����

        //���ش�����
        SenLabel[k] := s0;
        Inc(k);
        if k=Length(SenLabel) then break;
      end;
      Inc(ModNum);
    end;
    //����ģ�����
    setlength(Moduls,ModNum);

    //��ȡ����������
    SenNum := ModNum*NSenAMod;
    setlength(HTsensors,SenNum);//: THTsensors;
    SenNum := 0;
    for I := 0 to ModNum - 1 do  with Moduls[i]  do
    begin
      for k := 0 to NSenAMod - 1 do
      begin
        SecNam := SenLabel[k];
        //������������
        if not InF.SectionExists(SecNam) then
        begin
          pHTsensors[k] := nil;
          if SenLabel[k] = '' then  //û��
            ShowMessage(Format('��ʾ:������[%s]û�����ò�����',[SenLabel[k]]));
          Continue;
        end;

        with HTsensors[SenNum]  do
        begin
          SeqNum := InF.ReadInteger(SecNam,'HT���',SenNum+1);            //HT���=2
          SerNum := InF.ReadString(SecNam,'ʶ����',IntToStr(SenNum+1));   //HT SN=2
          Location := InF.ReadString(SecNam,'HTλ��',Format('λ��%d',[SenNum+1]));      //HTλ��=λ��2
          for j := 0 to NCalPar - 1 do
          begin
            with CorParH.CalPoints[j] do
            begin
              Real := InF.ReadInteger(SecNam,Format('ʵ��ʪ��%d',[j+1]),j*50);      //ʵ��ʪ��1=0
              Mea := InF.ReadInteger(SecNam,Format('����ʪ��%d',[j+1]),j*50);      //����ʪ��1=0
            end;
            with CorParT.CalPoints[j] do
            begin
              Real := InF.ReadInteger(SecNam,Format('ʵ���¶�%d',[j+1]),j*50);      //ʵ���¶�1=0
              Mea := InF.ReadInteger(SecNam,Format('�����¶�%d',[j+1]),j*50);      //�����¶�1=0
            end;
          end;
          FTemp := UndefineValue;  //��ʼ���������ж��Ƿ����ߵ����ݡ�
          FHumi := UndefineValue;  //��ʼ��
          CorParH.GetCalPar;  //����ʪ��ϵ��
          CorParT.GetCalPar;  //�����¶�ϵ��
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
      if mscmCOM.InputMode = comInputModeText then //�ַ���ʽ��ȡ
        str := mscmCOM.Input//��������Զ�������ջ�����,str[1]~str[32]
      else //�����Ʒ�ʽ��ȡ
      begin
        buffer := mscmCOM.Input;//��������Զ�������ջ�����,buffer[0]~buffer[31]
        RevBytes := TBytes(buffer);
        str := stringof(RevBytes);
      end;
      frmMain.mmoMsg.Lines.Add(Format('%s S %s',[FormatDatetime('hh:mm:ss zzz',Now()),str]));//����һ����ʾ
    end;

  comEvReceive: //���н����¼�����
    begin
      if mscmCOM.InputMode = comInputModeText then //�ַ���ʽ��ȡ
        str := mscmCOM.Input//��������Զ�������ջ�����,str[1]~str[32]
      else //�����Ʒ�ʽ��ȡ
      begin
        mscmCOM.InBufferCount;
        buffer := mscmCOM.Input;//��������Զ�������ջ�����,buffer[0]~buffer[31]

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


          GetlocalTime(dt_sys); //��ȡ��ǰϵͳʱ��
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
              frmMain.mmoMsg.Lines.Add(Format('@mscmCOMComm Failed to SetLocalTime',[]));//����һ����ʾ
          end;

        end;
      end;
      frmMain.mmoMsg.Lines.Add(Format('%-2d:%-2d:%-2d %-3d R %s',[HH,MM,SS,ZZ,str]));//����һ����ʾ;

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
//  Result := Humi[ChiD];   //��������
//end;
//
//function THTData.CorrectTemp(const Paras: Tvreal;const ChiD:byte=0):Real;
//begin
//  Result := Temp[ChiD];   //��������
//end;

procedure TfrmParaSetting.OpenGPSCOM();
var
  s0 :string;
begin
  s0 := rzcbbComName.Text;;
  Delete(s0,1,3);

  //����Ѿ����˶˿ڣ���رն˿�
  if mscmCOM.PortOpen then
    mscmCOM.PortOpen := False;

  if Length(s0)>0 then
  begin
    mscmCOM.CommPort :=  StrToInt(s0);
    //    mscmCOM.CommPort := 2;//���ö˿�2
    mscmCOM.InBufferSize := StrToIntDef(rzcbbBuffSize.Text,1024);//���ý��ջ�����Ϊ256���ֽ�
    mscmCOM.OutBufferSize := StrToIntDef(rzcbbBuffSize.Text,1024);//���÷��ͻ�����Ϊ256���ֽ�
    mscmCOM.Settings := Format('%s,n,%s,1',[rzcbbBaudRate.Text,rzcbbByteSize.Text]);//9600�����ʣ���У�飬8λ����λ��1λֹͣλ   // '9600,n,8,1'
    mscmCOM.InputLen := 0;       //��ȡ������ȫ������(32���ֽ�)
    mscmCOM.InBufferCount := 0;  // ������ջ�����
    mscmCOM.OutBufferCount:=0;   // ������ͻ�����
    mscmCOM.RThreshold := Length(GPSExStr); //StrToIntdef(cbbRThreshold.Text,20);    //���ý���10���ֽڲ���OnComm �¼�

//     mscmCOM.InputMode := comInputModeText; //�ı���ʽ
    mscmCOM.InputMode := comInputModeBinary;  //�����Ʒ�ʽ


    mscmCOM.PortOpen := true;//�򿪶˿�;
    mmoMsg.Lines.Add(Format('COM%d port openned. RThreshold = %d bytes',[mscmCOM.CommPort,Length(GPSExStr)]));
    if mscmCOM.PortOpen then
    begin
//      with ReadThisPar(rzcbbAIAddr.ItemIndex,$0C,False) do
//      begin
//        FdPt := Val;
//        rzchckbxState.Caption := Format('��ǰPV=%.1f��,SV=%.1f��',
//          [rPv*DotFact[FdPt],rSV*DotFact[FdPt]]);
//        rzstspn2.Caption := rzchckbxState.Caption;
//      end;
//      rzstspn1.Caption := Format('COM%d�Ѵ򿪣�',[mscmCOM.CommPort]);

    end;

//    rzbtbtnOpenCOM.Enabled := not mscmCOM.PortOpen;
//    rzbtbtnCloseCOM.Enabled := mscmCOM.PortOpen;
//    rzchckbxState.Enabled := mscmCOM.PortOpen;
  end;

end;

procedure TfrmParaSetting.btnOpenClick(Sender: TObject);
begin
  //����Ѿ����˶˿ڣ���رն˿�
  if not mscmCOM.PortOpen then
  begin
     OpenGPSCOM();
     btnOpen.Caption:= '�رմ���';
  end
  else
  begin
     mscmCOM.PortOpen := False;
     btnOpen.Caption:= '�򿪴���';
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
begin              //��������
  cmd := format('SetParameter1:ID=%s&IP=%s&Port=%s&Restart',[
    strgrdCommunication.Cells[2,1],
    strgrdCommunication.Cells[2,2],
    strgrdCommunication.Cells[2,3]
  ]);// + NewID.Text + "" + NewIP.Text + "" + NewPort.Text + "";//������Ҫ�޸ĵ�����-----------------------------
end;

procedure TfrmParaSetting.btnSetCorClick(Sender: TObject);
var
  i,j,k,ps:Integer;
  SecNam,s0,s1:string;
  InF:TIniFile;
begin
  if not FileExists(CfgFulFNam)  then
  begin
    ShowMessage(Format('�ļ���%s�������ڣ���ȡ�����ļ���ֹ��',[CfgFulFNam]));
  end;

  InF:= TIniFile.Create(CfgFulFNam);
 {
 HT���=1
ʶ����=1
HTλ��=λ��1
ʵ���¶�1=0
�����¶�1=0
ʵ���¶�2=50
�����¶�2=50
ʵ��ʪ��1=0
����ʪ��1=0
ʵ��ʪ��2=80
����ʪ��2=80
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
    Cells[0,1] := '���';     Cells[1,1] :=  IntToStr(ModID);
    Cells[0,2] := 'IP��ַ';   Cells[1,2] :=  IP;
    Cells[0,3] := '�˿ں�';   Cells[1,3] :=  IntToStr(Port);
    for I := 0 to NSenAMod - 1 do
    begin
      Cells[0,4+i] := format('������%d',[i+1]);
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
    //��ʾ������Ϣ
    strgrdSenAdd.Cells[1,1] := IntToStr(seqNum);
    strgrdSenAdd.Cells[1,2] := SerNum;
    strgrdSenAdd.Cells[1,3] := Location;

    for I := 0 to NCalPar - 1 do
    begin
        strgrdCorrect.Cells[0,1+i] := Format('�¶�%d',[i+1]);
        strgrdCorrect.Cells[1,1+i] := FloatToStr(CorParT.CalPoints[i].Mea);
        strgrdCorrect.Cells[2,1+i] := FloatToStr(CorParT.CalPoints[i].Real);

        strgrdCorrect.Cells[0,1+i+NCalPar] := Format('ʪ��%d',[i+1]);
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
    Cells[1,0] := '��ǰֵ';  Cells[2,0] := '���ֵ';

    Cells[0,1] := '���';
    Cells[0,2] := 'IP��ַ';
    Cells[0,3] := '�˿ں�';
    Cells[0,4] := 'λ��';
    ColWidths[0] := Canvas.TextWidth('������10');
    ColWidths[1] := (Width - ColWidths[0] - GridLineWidth)div 2 - GridLineWidth*5;
    ColWidths[2] := ColWidths[1];
    RowCount := 5+NsenAMod;
  end;

  with strgrdSenAdd do
  begin
    DefaultColWidth := (Width div RowCount) -  GridLineWidth*5;
    Cells[1,0] := '��ǰֵ';  Cells[2,0] := '���ֵ';

    Cells[0,1] := '���';
    Cells[0,2] := 'ʶ����';
    Cells[0,3] := 'λ��';
    RowCount := 4;
  end;

  with strgrdCorrect do
  begin
    DefaultColWidth := (Width div RowCount) -  GridLineWidth*5;
    Cells[1,0] := '��ȡֵ';  Cells[2,0] := 'ʵ��ֵ';
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
//  //�㲥����
//  idpsrvrMain.Broadcast('ReadData65535',1503,'255.255.255.255',En.ASCII);
end;

end.
