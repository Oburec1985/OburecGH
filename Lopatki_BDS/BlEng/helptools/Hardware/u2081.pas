unit u2081;

interface
uses
  MxxxxAPI, MxxxxTypes, Types4Bld, inifiles, SysUtils, classes, uBaseObjMng,
  uBaseObj, uBldObj, uBaseObjTypes, controls, ubldeng, uplat;

type

  cM2081 = class(cPlat)
  protected
    Bios, flex:PByteArray;
    // ������������� ����������. ����������� ��� ������ CreateDevice
    IdScan, handle:Cardinal;
  protected
    procedure init(inipath:ansistring; devinfo:TDevice);override;
  public
    constructor create;override;
    destructor destroy;override;
    procedure Stop;override;
  end;

  function Handler2081(Device:Pointer;Event:PIRQEvent;Data:Pointer):Integer;cdecl;

implementation

Function Handler2081(Device:Pointer;Event:PIRQEvent;Data:Pointer):Integer;cdecl;
var
  BSize:Word;
  plat:cM2081;
begin
  plat:=cm2081(data);
  //ReadBuf(IdDevice2081,IdScan,@Bf.Buf[Bf.BSIndx*Bf.AcqIndex],@BSize);
  //Bf.AcqIndex:=(Bf.AcqIndex+1)mod cSafetyfactor;
  //Read2081Buf(plat.handle,plat.handle,@plat.Bf.Buf[plat.Bf.BSIndx*plat.Bf.AcqIndex],@BSize);
  //plat.Bf.AcqIndex:=(plat.Bf.AcqIndex+1)mod cSafetyfactor;
  result:=0;
end;

destructor cM2081.destroy;
begin
  inherited;
  Close2081Device(handle);
end;

procedure cM2081.init(inipath:ansistring; devinfo:TDevice);
var
  inifile:tinifile;
  res:cardinal;
  v:variant;
  freq:double;
  // ����� �����
  number:cardinal;
  sizebios, sizeflex:cardinal;
  // ����� �������
  InSize:LongWord;
  // ������ �������
  Channels:array of word;
  i:integer;
begin
  // loadfromfile(bios)
  // loadfromfile(flex)
  // createM2081Device(...)
  // LoadBios(���������)

  Close2081Device(handle);
  //BaseTime:=BsTimeM2081; 1/40 MHz
  inifile:=tinifile.Create(inipath);
  LoadFromFile(IniFile.ReadString('directives','BIOSFileName',FileNameBios),
                                  sizebios,Bios);
  LoadFromFile(IniFile.ReadString('directives','FlexFileName',FileNameFlex),
                                  sizeFlex,Flex);
  Res:=CreateM2081Device(@handle, cMera, Types4bld.cM2081, Number,
                         SizeBios, Bios, SizeFlex, Flex,
                         c_BuffSize,c_FrameCount,cPartFifo,Nil,Nil);
  if Res = 0 then
  begin
    Res:=Load2081Bios(handle,0);
    if Res = 0 then
      Res:=LoadFlexM2081(handle);
  end;
  // ������� callback �� ����������� �������
  Res:=CreateScan(handle,@IdScan, 0,0, Handler2081,self);
  if Res = 0 then
  begin //������.����� � �������� �����
    InSize:=16;//����.������ ������� ��� �����
    setlength(Channels,InSize);
    for i:=0 to 15 do
    begin
      channels[i]:=i;
    end;
    // ������ ������
    Config_Blade(handle, InSize, @channels[1], BufferSize);
    StopScanMain(handle);
    StartScanMain(handle);
  end;
  if assigned(Bios) then FreeMem(Bios,SizeBios);
  if assigned(Flex) then FreeMem(Flex,SizeFlex);
end;

procedure cM2081.Stop;
begin

end;

constructor cM2081.create;
begin
  inherited;
  objtype:=c_2081;
end;

end.
