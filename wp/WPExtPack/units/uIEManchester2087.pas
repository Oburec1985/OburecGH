unit uIEManchester2087;

interface
uses
  ComObj, ActiveX, StdVcl, SysUtils, Classes, Winpos_ole_TLB, WPExtPack_TLB, inifiles, uWPProc,
  controls, uSaveSimpleMeraFrm, uWPNameFilterFrame, posbase, Windows, uBinFile;


type
// ������� �������� ��������
// 1) ������� ���� .ridl � IDE. � ������ �������� �������� CoClass
// 2) �� ������� implements �������� ��������� IWPExtOper
// 3) ������� ������� ���� � ���������� ������� � ����������� ���� ����� ������� �� ������� (������ ���������� ��� safecall)
// 4) �������� ������ initialization ��� � ���� �����

// ������ �� ����� ������� � ����� connect �������� ������ .Connect( 5 ����� �� �����!)
// 5) ��������� � DllRegisterServer reg.writestring(string(buffer), 'WPExtPack.IEMeraPlg'); ��� WPExtPack - ���������� ����� (���� ridll)  IEMeraPlg - ��� CoClass �� ����������
  TDataBlock = record
    marker:ulong;
    reserved:ushort;
    datacount:ushort;
    UTS:double;
    data:array of word;
    data632:array of cardinal;
  end;

  TIEManchester2087 = class(TAutoObject, IWPImport, IWPExport)
  protected
    SigArray:tSignalArray;
  public
    // IWPPlugin
    function Connect(const app: IDispatch): Integer; safecall;
    function Disconnect: Integer; safecall;
    function NotifyPlugin(what: Integer; var param: OleVariant): Integer;safecall;
    // IWPImport
    function Open(const path: widestring; out count: Integer): HResult;safecall;
    procedure Close; safecall;
    function GetSignal(n: Integer): IDispatch; safecall;
    function GetPreviewText(const path: WideString): WideString; safecall;
    // IWPExport
    procedure AddSignal(const sig: IDispatch); safecall;
    function Save(const path: WideString): HResult; safecall;
  end;

var
  Ie2087:TIEManchester2087;

const
 c_bSize = 100;

implementation
  uses ComServ,  Variants, StrUtils, Dialogs;

{TMeraExtPlg}
procedure TIEManchester2087.AddSignal(const sig: IDispatch);
begin
  SetLength(SigArray, length(SigArray) + 1);
  SigArray[length(SigArray) - 1] := sig as IWPSignal;
end;

procedure TIEManchester2087.Close;
begin

end;

function TIEManchester2087.Connect(const app: IDispatch): Integer;
begin
  WINPOS:=app as IWinPOS;
  WINPOS.RegisterImpExp(self, self, '����� ������ MB2087', '*.dat');
 end;

function TIEManchester2087.Disconnect: Integer;
begin
  //
end;

function TIEManchester2087.GetPreviewText(const path: WideString): WideString;
begin
  result:='����� 2087';
end;

function TIEManchester2087.GetSignal(n: Integer): IDispatch;
begin
  if (n >= 0) and (n < length(sigarray)) then
    Result := sigarray[n]
  else
    Result := Nil;
end;

function TIEManchester2087.NotifyPlugin(what: Integer; var param: OleVariant): Integer;
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

function TIEManchester2087.Open(const path: widestring; out count: Integer): HResult;
var
  f:file;
  sname, fpath, fname:string;
  readed, ind:integer;
  s:iwpsignal;
  fsize,fpos:integer;
  bres:boolean;
  block:TDataBlock;
  hex:string;
  b632:boolean;
  function readBlock(var block:TDataBlock):boolean;
  begin
    block.marker:=ReadInt(f);
    // 4 ����������� �����
    hex:=IntToHex(block.marker,4);
    block.reserved:=ReadUShort(f);
    block.datacount:=ReadUShort(f);
    setlength(block.data,block.datacount);
    block.UTS:=Readdouble(f);
    fpos:=filepos(f);
    if fsize>fpos+(block.datacount*2) then
    begin
      result:=true;
      BlockRead(f,block.data[0],block.datacount*(sizeof(word)),readed);
    end
    else
    begin
      result:=false;
    end;
  end;
  function readBlock632(var block:TDataBlock):boolean;
  var
    datasize:integer;
  begin
    datasize:=2;
    block.marker:=ReadInt(f);
    // 4 ����������� �����
    hex:=IntToHex(block.marker,4);
    block.reserved:=ReadUShort(f);
    block.datacount:=ReadUShort(f);
    setlength(block.data632,block.datacount);
    block.UTS:=Readdouble(f);
    fpos:=filepos(f);
    if fsize>fpos+(block.datacount*datasize) then
    begin
      result:=true;
      BlockRead(f,block.data632[0],block.datacount*datasize,readed);
    end
    else
    begin
      result:=false;
    end;
  end;
begin
  setlength(sigArray,0);
  count:=0;
  ind:=1;
  fpath:='';
  while path[ind]<>char(0) do
  begin
    fpath:=fpath+path[ind];
    inc(ind);
  end;
  AssignFile(f, fpath);
  // ��������, ��� ���� ����������
  if Assigned(@f) then
  begin
    inc(count);
    Reset(F,1); // ���������� ����� �������� ������ � ������
    s:=WINPOS.CreateSignalXY(VT_R4, VT_I1) as iwpsignal;
    //s.sname:=sname;
    fname:=ExtractFileName(fpath);
    sname:=ExtractNamefromPath(fpath);
    //winpos.Link('/Signals/'+fname, sname, S as IDispatch);
    s.sname:=sname;
    fsize:=FileSize(f);
    s.size:=c_bSize;
    bres:=true;
    ind:=0;
    b632:=pos('632',sname)>0;
    while bres do
    begin
      if b632 then
      begin
        bres:=readBlock632(block);
      end
      else
      begin
        bres:=readBlock(block);
      end;
      if bres then
      begin
        s.SetY(ind,1);
        s.SetX(ind,block.uts);
        inc(ind);
        if ind>s.size then
        begin
          s.size:=s.size+c_bSize;
        end;
      end;
    end;
    s.size:=ind;
    // ������� ����
    CloseFile(f);
    AddSignal(s);
  end;
  result:=0;
end;

function TIEManchester2087.Save(const path: WideString): HResult;
begin

end;

initialization

TAutoObjectFactory.Create(ComServer, TIEManchester2087, CLASS_IEMeraPlg, ciSingleInstance, tmApartment);

end.
