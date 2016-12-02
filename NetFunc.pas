unit NetFunc;

interface
uses
  SysUtils, Windows, dialogs, winsock, Classes, ComObj, WinInet, Variants,Nb30,
  TlHelp32;

//������Ϣ����
const
  C_Err_GetLocalIp = '��ȡ����ipʧ��';
  C_Err_GetNameByIpAddr = '��ȡ������ʧ��';
  C_Err_GetSQLServerList = '��ȡSQLServer������ʧ��';
  C_Err_GetUserResource = '��ȡ������ʧ��';
  C_Err_GetGroupList = '��ȡ���й�����ʧ��';
  C_Err_GetGroupUsers = '��ȡ�����������м����ʧ��';
  C_Err_GetNetList = '��ȡ������������ʧ��';
  C_Err_CheckNet = '���粻ͨ';
  C_Err_CheckAttachNet = 'δ��������';
  C_Err_InternetConnected ='û������';

  C_Txt_CheckNetSuccess = '���糩ͨ';
  C_Txt_CheckAttachNetSuccess = '�ѵ�������';
  C_Txt_InternetConnected ='������';

//����ARP���ݰ�
Function sendarp(ipaddr:ulong; temp:dword; ulmacaddr:pointer;
  ulmacaddrleng:pointer) : DWord; StdCall; External 'Iphlpapi.dll' Name 'SendARP';

//�������Ƿ��������
function IsLogonNet: Boolean;

//�õ������ľ�����Ip��ַ
function GetLocalIP(var LocalIp:string): Boolean;

//ͨ��Ip���ػ�����
function GetNameByIPAddr(IPAddr: string; var MacName: string): Boolean ;

//��ȡ������SQLServer�б�
function GetSQLServerList(var List: Tstringlist): Boolean;

//��ȡ�����е�������������
//function GetNetList(var List: Tstringlist): Boolean;

//��ȡ�����еĹ�����
function GetGroupList(var List: TStringList): Boolean;

//��ȡ�����������м����
//function GetUsers(GroupName: string; var List: TStringList): Boolean;

//��ȡ�����е���Դ
function GetUserResource(IpAddr: string; var List: TStringList): Boolean;

//ӳ������������
//function NetAddConnection(NetPath: Pchar; PassWord: Pchar;LocalPath: Pchar): Boolean;

//�������״̬
//function CheckNet(IpAddr:string): Boolean;

//�ж�IpЭ����û�а�װ �������������
function IsIPInstalled : boolean;

//�������Ƿ�����
//function InternetConnected: Boolean;

//�ر���������
//function NetCloseAll:boolean;

//��ȡ���һ��IP
function   GetLastIP:string;

//��������ת��ΪIP��ַ
function   HostToIP(const Host:  string): string;


//IP��ַת��ΪMac��ַ
function IPToMac(const IP:AnsiString; AddStatus:Boolean=False):string;

//IP��ַת��Ϊ��������ַ
function   IPToHost(const IP   :   AnsiString):   String;


     function IsAdmin: Boolean;

     function   GetProcessIdFromName(CONST   name : string):THandle;

     function   GetHandleFromName(CONST   name : string):THandle;

implementation

/////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
/////////////////////////////////////////////////
////////////// ����ʵ�ֲ���////////////

{=================================================================
�� ��: �������Ƿ��������
�� ��: ��
����ֵ: �ɹ�: True ʧ��: False
�� ע:
�� ��:
1.0 2002/10/03 09:55:00
=================================================================}
function IsLogonNet: Boolean;
begin
Result := False;
if GetSystemMetrics(SM_NETWORK) <> 0 then
Result := True;
end;


{=================================================================
�� ��: ���ر����ľ�����Ip��ַ
�� ��: ��
����ֵ: �ɹ�: True, �����LocalIp ʧ��: False
�� ע:
�� ��:
1.0 2002/10/02 21:05:00
=================================================================}
function GetLocalIP(var LocalIp: string): Boolean;
var
  HostEnt: PHostEnt;
  IP: String;
  Addr: PAnsiChar;
  Buffer: array [0..63] of AnsiChar;
  WSData: TWSADATA;
begin
  Result := False;
  try
    WSAStartUp(2, WSData);
    GetHostName(@Buffer, SizeOf(Buffer));
    //Buffer:='ZhiDa16';
    HostEnt := GetHostByName(@Buffer);
    if HostEnt = nil then exit;
    Addr := HostEnt^.h_addr_list^;
    IP := Format( '%d.%d.%d.%d', [ Byte(Addr[0]), Byte(Addr[1]),
    Byte(Addr[2]), Byte(addr[3]) ]
    );
    LocalIp := Ip;
    Result := True;
  finally
    WSACleanup;
  end;
end;

{=================================================================
�� ��: ͨ��Ip���ػ�����
�� ��:
IpAddr: ��Ҫ�õ����ֵ�Ip
����ֵ: �ɹ�: ������ ʧ��: ''
�� ע:
inet_addr function converts a string containing an Internet
Protocol dotted address into an in_addr.
�� ��:
1.0 2002/10/02 22:09:00
=================================================================}
function GetNameByIPAddr(IPAddr : String;var MacName:String): Boolean;
var
  SockAddrIn: TSockAddrIn;
  HostEnt: PHostEnt;
  WSAData: TWSAData;
begin
  Result := False;
  if IpAddr = '' then exit;
  try
    WSAStartup(2, WSAData);
    SockAddrIn.sin_addr.s_addr := inet_addr(PAnsiChar(IPAddr));
    HostEnt := gethostbyaddr(@SockAddrIn.sin_addr.S_addr, 4, AF_INET);
    if HostEnt <> nil then
    MacName := StrPas(Hostent^.h_name);
    Result := True;
  finally
    WSACleanup;
  end;
end;

{=================================================================
�� ��: ����������SQLServer�б�
�� ��:
List: ��Ҫ����List
����ֵ: �ɹ�: True,�����List ʧ�� False
�� ע:
�� ��:
1.0 2002/10/02 22:44:00
=================================================================}
function GetSQLServerList(var List: Tstringlist): boolean;
var
  i: integer;
  //sRetValue: String;
  SQLServer: Variant;
  ServerList: Variant;
begin
  //Result := False;
  List.Clear;
  try
    SQLServer := CreateOleObject('SQLDMO.Application');
    ServerList := SQLServer.ListAvailableSQLServers;
    for i := 1 to Serverlist.Count do
    list.Add (Serverlist.item(i));
    Result := True;
  Finally
    SQLServer := NULL;
    ServerList := NULL;
  end;
end;

{=================================================================
�� ��: �ж�IPЭ����û�а�װ
�� ��: ��
����ֵ: �ɹ�: True ʧ��: False;
�� ע: �ú�����������
�� ��:
1.0 2002/10/02 21:05:00
=================================================================}
function IsIPInstalled : boolean;
var
  WSData: TWSAData;
  ProtoEnt: PProtoEnt;
begin
  Result := True;
  try
  if WSAStartup(2,WSData) = 0 then
  begin
    ProtoEnt := GetProtoByName('IP');
    if ProtoEnt = nil then
    Result := False
  end;
  finally
    WSACleanup;
  end;
end;


{=================================================================
�� ��: ���������еĹ�����Դ
�� ��:
IpAddr: ����Ip
List: ��Ҫ����List
����ֵ: �ɹ�: True,�����List ʧ��: False;
�� ע:
WNetOpenEnum function starts an enumeration of network
resources or existing connections.
WNetEnumResource function continues a network-resource
enumeration started by the WNetOpenEnum function.
�� ��:
1.0 2002/10/03 07:30:00
=================================================================}
function GetUserResource(IpAddr: string; var List: TStringList): Boolean;
type
TNetResourceArray = ^TNetResource;//�������͵�����
Var
i: Integer;
Buf: Pointer;
Temp: TNetResourceArray;
lphEnum: THandle;
NetResource: TNetResource;
Count,BufSize,Res: DWord;
Begin
Result := False;
List.Clear;
if copy(Ipaddr,0,2) <> '\\' then
IpAddr := '\\'+IpAddr; //���Ip��ַ��Ϣ
FillChar(NetResource, SizeOf(NetResource), 0);//��ʼ����������Ϣ
NetResource.lpRemoteName := @IpAddr[1];//ָ�����������
//��ȡָ���������������Դ���
Res := WNetOpenEnum( RESOURCE_GLOBALNET, RESOURCETYPE_ANY,
RESOURCEUSAGE_CONNECTABLE, @NetResource,lphEnum);
Buf:=nil;
if Res <> NO_ERROR then exit;//ִ��ʧ��
while True do//�о�ָ���������������Դ
begin
Count := $FFFFFFFF;//������Դ��Ŀ
BufSize := 8192;//��������С����Ϊ8K
GetMem(Buf, BufSize);//�����ڴ棬���ڻ�ȡ��������Ϣ
//��ȡָ���������������Դ����
Res := WNetEnumResource(lphEnum, Count, Pointer(Buf), BufSize);
if Res = ERROR_NO_MORE_ITEMS then break;//��Դ�о����
if (Res <> NO_ERROR) then Exit;//ִ��ʧ��
Temp := TNetResourceArray(Buf);
for i := 0 to Count - 1 do
begin
//��ȡָ��������еĹ�����Դ���ƣ�+2��ʾɾ��"\\"��
//��\\192.168.0.1 => 192.168.0.1
List.Add(Temp^.lpRemoteName + 2);
Inc(Temp);
end;
end;
Res := WNetCloseEnum(lphEnum);//�ر�һ���о�
if Res <> NO_ERROR then exit;//ִ��ʧ��
Result := True;
FreeMem(Buf);
End;

{=================================================================
�� ��: ���������еĹ�����
�� ��:
List: ��Ҫ����List
����ֵ: �ɹ�: True,�����List ʧ��: False;
�� ע:
�� ��:
1.0 2002/10/03 08:00:00
=================================================================}
function GetGroupList( var List : TStringList ) : Boolean;
type
TNetResourceArray = ^TNetResource;//�������͵�����
Var
NetResource: TNetResource;
Buf: Pointer;
Count,BufSize,Res: DWORD;
lphEnum: THandle;
p: TNetResourceArray;
i,j: SmallInt;
NetworkTypeList: TList;
Begin
Result := False;
NetworkTypeList := TList.Create;
List.Clear;
//��ȡ���������е��ļ���Դ�ľ����lphEnumΪ��������
Res := WNetOpenEnum( RESOURCE_GLOBALNET, RESOURCETYPE_DISK,
RESOURCEUSAGE_CONTAINER, Nil,lphEnum);
if Res <> NO_ERROR then exit;//Raise Exception(Res);//ִ��ʧ��
//��ȡ���������е�����������Ϣ
Count := $FFFFFFFF;//������Դ��Ŀ
BufSize := 8192;//��������С����Ϊ8K
GetMem(Buf, BufSize);//�����ڴ棬���ڻ�ȡ��������Ϣ
Res := WNetEnumResource(lphEnum, Count, Pointer(Buf), BufSize);
//��Դ�о���� //ִ��ʧ��
if ( Res = ERROR_NO_MORE_ITEMS ) or (Res <> NO_ERROR ) then Exit;
P := TNetResourceArray(Buf);
for i := 0 to Count - 1 do//��¼�����������͵���Ϣ
begin
NetworkTypeList.Add(p);
Inc(P);
end;
Res := WNetCloseEnum(lphEnum);//�ر�һ���о�
if Res <> NO_ERROR then exit;
for j := 0 to NetworkTypeList.Count-1 do //�г��������������е����й���������
begin//�г�һ�����������е����й���������
NetResource := TNetResource(NetworkTypeList.Items[J]^);//����������Ϣ
//��ȡĳ���������͵��ļ���Դ�ľ����NetResourceΪ����������Ϣ��lphEnumΪ��������
Res := WNetOpenEnum(RESOURCE_GLOBALNET, RESOURCETYPE_DISK,
RESOURCEUSAGE_CONTAINER, @NetResource,lphEnum);
if Res <> NO_ERROR then break;//ִ��ʧ��
while true do//�о�һ���������͵����й��������Ϣ
begin
Count := $FFFFFFFF;//������Դ��Ŀ
BufSize := 8192;//��������С����Ϊ8K
GetMem(Buf, BufSize);//�����ڴ棬���ڻ�ȡ��������Ϣ
//��ȡһ���������͵��ļ���Դ��Ϣ��
Res := WNetEnumResource(lphEnum, Count, Pointer(Buf), BufSize);
//��Դ�о���� //ִ��ʧ��
if ( Res = ERROR_NO_MORE_ITEMS ) or (Res <> NO_ERROR) then break;
P := TNetResourceArray(Buf);
for i := 0 to Count - 1 do//�оٸ������������Ϣ
begin
List.Add( StrPAS( P^.lpRemoteName ));//ȡ��һ�������������
Inc(P);
end;
end;
Res := WNetCloseEnum(lphEnum);//�ر�һ���о�
if Res <> NO_ERROR then break;//ִ��ʧ��
end;
Result := True;
FreeMem(Buf);
NetworkTypeList.Destroy;
End;


function   GetLastIP:string;
var
  WSAData:TWSAData;
  HostName:array[0..MAX_COMPUTERNAME_LENGTH]   of   Char;
  HostEnt:PHostEnt;
  LastIP:PInAddr;
  IPList:^PInAddr;
begin
  result:='''';
  if   0=WSAStartup(MAKEWORD(1,1),   WSAData)   then
  try
    if   0=gethostname(@HostName,   MAX_COMPUTERNAME_LENGTH+1)   then
    begin
      HostEnt:=gethostbyname(@HostName);
      if   HostEnt<>nil   then
      begin
        IPList:=Pointer(HostEnt^.h_addr_list);
        repeat
          LastIP:=IPList^;
          INC(IPList);
        until   IPList^=nil;
        if   LastIP<>nil   then
          result:=inet_ntoa(LastIP^);
      end;
    end;
  finally
    WSACleanup;
  end;
end;


function   HostToIP(const Host:  string): string;

var
  wsdata   :   TWSAData;
  hostName   :   array   [0..255]   of   char;
  hostEnt   :   PHostEnt;
  addr   :   PAnsiChar;
  err:Boolean;
begin
  WSAStartup   ($0101,   wsdata);
  try
    gethostname   (@hostName,   sizeof(hostName));
    StrPCopy(hostName, Host);
    hostEnt   :=   gethostbyname(@hostName);
    if   Assigned   (hostEnt)   then
      if   Assigned   (hostEnt^.h_addr_list)   then
      begin
        addr   :=   hostEnt^.h_addr_list^;
        if   Assigned   (addr)   then
        begin
          Result   :=   Format   ( '%d.%d.%d.%d ',   [byte   (addr   [0]),
          byte   (addr   [1]),   byte   (addr   [2]),   byte   (addr   [3])]);
          err   :=   True;
        end
        else
          err   :=   False;
      end
      else
        err   :=   False
    else
    begin
      err   :=   False;
    end;
  finally
    WSACleanup;
  end
end;

//IP��ַת��ΪMac��ַ
function IPToMac(const IP:AnsiString; AddStatus:Boolean=False):string;
var
  myip:ulong;
  mymac:array[0..5] of byte;
  mymaclength:ulong;
  r:integer;
begin
  myip:=inet_addr(PAnsiChar(IP));
  mymaclength:=length(mymac);
  r:=sendarp(myip,0,@mymac,@mymaclength);

  Result:=format('%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x',
    [mymac[0],mymac[1],mymac[2],mymac[3],mymac[4],mymac[5]]);
  if AddStatus then
     Result :=   Result +  format('@%d', [r]);
end;

//IP��ַת��Ϊ��������ַ
function   IPToHost(const IP   :   AnsiString):   String;
var
  SockAddrIn:   TSockAddrIn;
  HostEnt:   PHostEnt;
  WSAData:   TWSAData;
begin
  WSAStartup($101,   WSAData);
  SockAddrIn.sin_addr.s_addr:=   inet_addr(PAnsiChar(IP));
  HostEnt:=   gethostbyaddr(@SockAddrIn.sin_addr.S_addr,   4,   AF_INET);
  if   HostEnt <> nil   then
  begin
    result:=StrPas(Hostent^.h_name)
  end
  else
  begin
    result:= 'û���ҵ���';
  end;
end;

//�ж��Ƿ�Ϊ����ԱȨ��
function IsAdmin: Boolean;
const
  SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority =
    (Value: (0, 0, 0, 0, 0, 5));
  SECURITY_BUILTIN_DOMAIN_RID = $00000020;
  DOMAIN_ALIAS_RID_ADMINS = $00000220;
var
  hAccessToken: THandle;
  ptgGroups: PTokenGroups;
  dwInfoBufferSize: DWORD;
  psidAdministrators: PSID;
  x: Integer;
  bSuccess: BOOL;
begin
  Result := False;
  bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True,
    hAccessToken);
  if not bSuccess then
  begin
    if GetLastError = ERROR_NO_TOKEN then
    bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY,
      hAccessToken);
  end;
  if bSuccess then
  begin
    GetMem(ptgGroups, 1024);
    bSuccess := GetTokenInformation(hAccessToken, TokenGroups,
      ptgGroups, 1024, dwInfoBufferSize);
    CloseHandle(hAccessToken);
    if bSuccess then
    begin
      AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2,
        SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS,
        0, 0, 0, 0, 0, 0, psidAdministrators);
      {$R-}
       for x := 0 to ptgGroups.GroupCount - 1 do
        if EqualSid(psidAdministrators, ptgGroups.Groups[x].Sid) then
        begin
          Result := True;
          Break;
        end;
      {$R+ }
      FreeSid(psidAdministrators);
    end;
    FreeMem(ptgGroups);
  end;
end;

//��ȡ����ľ��
function   GetProcessIdFromName(CONST   name : string):THandle;
var
   pe: tPROCESSENTRY32 ;
   id,hSnapshot : THandle;//  DWORD =   0;
begin
  Result := 0;
  id := 0;
  hSnapshot  :=   CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  pe.dwSize   :=   sizeof(PROCESSENTRY32);
  if(   not Process32First(hSnapshot,&pe)   )then  Exit;

  while True do
  begin
    pe.dwSize   :=   sizeof(PROCESSENTRY32);
    if(   Process32Next(hSnapshot,&pe)=FALSE ) then break;
    if(CompareText(pe.szExeFile,name)=0) then
    begin
      Result   :=   pe.th32ProcessID;
      break;
    end;
  end;
  CloseHandle(hSnapshot);

end;

function  GetHandleFromName(CONST   name : string):THandle;
var
  id,hSnapshot : THandle;//  DWORD =   0;
begin
  id := GetProcessIdFromName(name);
  Result := OpenProcess(PROCESS_ALL_ACCESS,TRUE,id);
end;






end.
