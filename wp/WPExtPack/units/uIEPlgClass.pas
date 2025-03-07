unit uIEPlgClass;

interface

uses
  ComObj, ActiveX, StdVcl, SysUtils, Classes, Winpos_ole_TLB, WPExtPack_TLB, inifiles, uWPProc,
  controls, uSaveSimpleMeraFrm, uWPNameFilterFrame, uIEManchester2087;


type
// ������� �������� ��������
// 1) ������� ���� .ridl � IDE. � ������ �������� �������� CoClass
// 2) �� ������� implements �������� ��������� IWPExtOper
// 3) ������� ������� ���� � ���������� ������� � ����������� ���� ����� ������� �� ������� (������ ���������� ��� safecall)
// 4) �������� ������ initialization ��� � ���� �����
// 5) ��������� � DllRegisterServer reg.writestring(string(buffer), 'WPExtPack.IEMeraPlg');
// ��� WPExtPack - ���������� ����� (���� ridll)  IEMeraPlg - ��� CoClass �� ����������

  TMeraExtPlg = class(TAutoObject, IWPImport, IWPExport)
  protected
    // ������������ ��� ��������
    m:IWPUSML;
    // ����������
    node:iwpnode;
    SigArray:tSignalArray;
  public
    // IWPPlugin
    function Connect(const app: IDispatch): Integer; safecall;
    function Disconnect: Integer; safecall;
    function NotifyPlugin(what: Integer; var param: OleVariant): Integer;safecall;
    // IWPImport
    function Open(const path: WideString; out count: Integer): HResult;safecall;
    procedure Close; safecall;
    function GetSignal(n: Integer): IDispatch; safecall;
    function GetPreviewText(const path: WideString): WideString; safecall;
    // IWPExport
    procedure AddSignal(const sig: IDispatch); safecall;
    function Save(const path: WideString): HResult; safecall;
  end;

  var
    Ieplg:TMeraExtPlg;

implementation
  uses ComServ, POSBase, Variants, Windows, StrUtils, Dialogs;

{TMeraExtPlg}
procedure TMeraExtPlg.AddSignal(const sig: IDispatch);
begin
  SetLength(SigArray, length(SigArray) + 1);
  SigArray[length(SigArray) - 1] := sig as IWPSignal;
end;

procedure TMeraExtPlg.Close;
begin
  m:=nil;
end;

function TMeraExtPlg.Connect(const app: IDispatch): Integer;
begin
  WINPOS:=app as IWinPOS;
  WINPOS.RegisterImpExp(self, self, '����� mera ��� ��', '*.mera');
 end;

function TMeraExtPlg.Disconnect: Integer;
begin
  //
end;

function TMeraExtPlg.GetPreviewText(const path: WideString): WideString;
var
  mera: tinifile;
  AnsiPath: String;
  txt, str: String;
begin
  // ��������� ����
  AnsiPath := WideCharToString(PWideChar(path));
  if FileExists(AnsiPath) then
  begin
    mera:=TIniFile.Create(ansipath);

    txt := '���� ������� mera' + #13#10;
    str:=mera.ReadString('Main','Date','_');
    txt := txt + '����: ' + str+ #13#10;
  end
end;

function TMeraExtPlg.GetSignal(n: Integer): IDispatch;
begin
  if (n >= 0) and (n < m.ParamCount) then
    Result := m.Parameter(n)
  else
    Result := Nil;
end;

function TMeraExtPlg.NotifyPlugin(what: Integer; var param: OleVariant): Integer;
begin

end;

function ExtractNamefromPath(name:string):string;
var
  I: Integer;
begin
  result:=extractfilename(name);
  for I := length(result) downto 1 do
  begin
    if result[i]='.' then
    begin
      result:=Copy(result,1,i-1);
      break;
    end;
  end;
end;

function TMeraExtPlg.Open(const path: WideString; out count: Integer): HResult;
begin
  m:=WP.LoadUSML(path) as iwpusml;
end;

function TMeraExtPlg.Save(const path: WideString): HResult;
var
  s, saveSignal:iwpsignal;
  sX,
  sY: OleVariant;

  I, count: Integer;
  folder:string;

  name:string;

  ifile:tinifile;
begin
  SaveSimpleMeraFrm.Save;
  if SaveSimpleMeraFrm.Showmodal(SigArray)=mrCancel then exit;

  sigArray:=SaveSimpleMeraFrm.WPNameFltFrame1.getNames;
  for I := 0 to length(SigArray)-1 do
  begin
    s:=SigArray[i];
    //sX := VarArrayCreate([0, s.size - 1], varDouble);
    sY := VarArrayCreate([0, s.size - 1], varDouble);
    sX:= VarArrayCreate([0, s.size - 1], varDouble);
    count:=s.size;
    s.GetArray(0, count, sY, sX, true);

    saveSignal:=s.Clone(0, s.size) as iwpsignal;
    saveSignal.k1:=1;
    saveSignal.k0:=0;
    //saveSignal:=wp.CreateSignal(VT_R8) as iwpsignal;
    //saveSignal.size:=s.size;
    //saveSignal.sname:=s.sname;
    //saveSignal.comment:=s.comment;
    //saveSignal.StartX:=s.StartX;

    saveSignal.setarray(0, count, sY,sX, false);
    saveSignal.SetArray(0, count, sY, sX, false);

    winpos.Link('Signals/IEMeraPlgNode', s.sname, saveSignal);
  end;
  node:=iwpnode((winpos.Get('Signals/IEMeraPlgNode')));
  name:=node.AbsolutePath;
  //folder:='c:\temp\1.mera';
  folder:='';
  i:=1;
  while path[i]<>char(0) do
  begin
    folder:=folder+char(path[i]);
    inc(i);
  end;
  WP.SaveUSML(name, folder);
  // ���������� ��� ��
  if not fileexists(folder) then
  begin
    name:=ExtractNamefromPath(folder);
    name:=extractfiledir(folder)+'\'+name+'\'+name+'.mera';
  end;
  ifile:=TIniFile.Create(name);
  for I := 0 to length(SigArray)-1 do
  begin
    name:=sigarray[i].sname;
    ifile.WriteInteger(name,'function', 0);
  end;
  ifile.Destroy;
  wp.Unlink(node);
  setlength(SigArray, 0);
  node._Release;
end;

initialization

TAutoObjectFactory.Create(ComServer, TMeraExtPlg, CLASS_IEMeraPlg, ciSingleInstance, tmApartment);

end.
