unit uAriphmAlg;

interface
uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml, ucommontypes, uFFT, Ap, fft, dialogs,
  uHardwareMath,
  uSpm,
  complex,
  pluginclass,
  performanceTime,
  sysutils;

type
  // �������� ����������� �� cPhaseAlg ��� ��� �� ���������� � �������� ����������
  // ������� ����������� ������ � ���������� ��������� �������, �������������� ����� �� ������� �����
  // � ������� �� ��� �������� ������
  cAriphmAlg = class(cbasealg)
  public
    m_A: cTag;
    m_B: cTag;
    m_Out: cTag;
  protected
    m_opertype:integer;
  private
    // ��� ������� ���������� �� ������ � ������. ������ ���������� tag.readdata
    // �� ���� ����� ����������� ������
    m_EvalBlock1, m_EvalBlock2: TAlignDarray;

  protected
    function OutExists: boolean;
    function Bexists: boolean;
    function Aexists:boolean;
    procedure UpdateOutTag;
    procedure doAfterload; override;
    procedure SetProperties(str: string); override;
    function GetProperties: string; override;
    procedure doOnStart; override;
    function genTagName: string; override;
    procedure doEval(tag: cTag; time: double); override;
    procedure doGetData; override;
    // ���� ���������� ��� �������� ������ �� ����������� ��� ��������� ������, � ����� � ���
    // ���������� ��� �������� ��� ��� ��������� �������� ����
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlNode); override;
    procedure LoadTags(node: txmlNode); override;
    function ready: boolean; override;
    function getresname: string; override;
  public
    constructor create; override;
    destructor destroy; override;
    class function getdsc: string; override;
  end;

const
  c_Add =0;
  c_Dec =1;
  c_Mult =2;
  c_Div =3;
  C_AriphmOpts = 'TypeRes=0';


implementation

{ cAriphmAlg }

function cAriphmAlg.Aexists: boolean;
begin
  result:=false;
  if m_A<>nil then
  begin
    if m_A.tag<>nil then
    begin
      result:=true;
    end;
  end;
end;

function cAriphmAlg.Bexists: boolean;
begin
  result:=false;
  if m_A<>nil then
  begin
    if m_A.tag<>nil then
    begin
      result:=true;
    end;
  end;
end;

function cAriphmAlg.OutExists: boolean;
begin
  result:=false;
  if m_Out<>nil then
  begin
    if m_Out.tag<>nil then
    begin
      result:=true;
    end;
  end;
end;

constructor cAriphmAlg.create;
begin
  inherited;

end;

destructor cAriphmAlg.destroy;
begin

  inherited;
end;

procedure cAriphmAlg.doAfterload;
begin
  inherited;

end;

procedure cAriphmAlg.doEval(tag: cTag; time: double);
begin
  inherited;

end;

procedure cAriphmAlg.doGetData;
var
  i1,i2:point2d;
  b_newData:boolean;
  I: Integer;
begin
  inherited;
  // ��������� ������
  if m_A.UpdateTagData(true) then
  begin
    i1 := m_A.getPortionTime;
    if b_newData then
    begin
      if m_B.UpdateTagData(true) then
      begin
        case m_opertype of
          c_Add:
          begin
            for I := 0 to m_A.lastindex - 1 do
            begin
              m_out.m_TagData[i]:=m_A.m_ReadData[i]+m_B.m_ReadData[i];
            end;
          end;
          c_Dec:
          begin
          end;
          c_Mult:
          begin
          end;
          c_Div:
          begin
          end;
        end;
        m_out.tag.PushDataEx(pointer(m_out.m_TagData)^, m_A.lastindex, 0, time);
        m_A.ResetTagData;
        m_B.ResetTagData;
      end;
    end;
  end;
end;

procedure cAriphmAlg.doOnStart;
begin
  inherited;
  m_A.doOnStart;
  m_B.doOnStart;
  m_out.doOnStart;
end;

function cAriphmAlg.genTagName: string;
var
  tagname: string;
  str:string;
begin
  case m_opertype of
    c_Add: str:='Add';
    c_Dec: str:='Dec';
    c_Mult: str:='Mult';
    c_Div: str:='Div';
  end;
  tagname := m_A.tagname+'_'+m_b.tagname+'_' +Str;
  result := tagname;
end;

class function cAriphmAlg.getdsc: string;
begin
  result := '�����. ����.';
end;

function cAriphmAlg.GetProperties: string;
var
  pars:tstringlist;
begin
  if m_properties = '' then
    m_properties := C_AriphmOpts;
  pars := tstringlist.create;
  addParam(pars, 'TypeRes', inttostr(m_opertype));
  if Bexists then
    addParam(pars, 'Bparam', m_B.tagname);
  if Aexists then
    addParam(pars, 'Aparam', m_A.tagname);
  if OutExists then
    addParam(pars, 'OutChannel', m_Out.tagname);

  m_Properties := ParsToStr(pars);
  result := m_Properties;
  delpars(pars);
  pars.destroy;
end;

function cAriphmAlg.getresname: string;
begin
  if m_out.tag <> nil then
    result := m_out.tag.GetName
  else
    result := m_out.tagname;
end;

procedure cAriphmAlg.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
begin
  inherited;

end;

procedure cAriphmAlg.LoadTags(node: txmlNode);
begin
  inherited;
end;

function cAriphmAlg.ready: boolean;
begin
  result := false;
  if Aexists and Bexists then
  begin
    result := true;
  end;
end;

procedure cAriphmAlg.SaveObjAttributes(xmlNode: txmlNode);
begin
  inherited;
end;

procedure cAriphmAlg.SetProperties(str: string);
var
  lstr: string;
  t: itag;
  changed: boolean;
begin
  //inherited;
  m_properties:=updateParams(m_properties, str, '', ' ');
  changed := false;
  // �������� A
  lstr := GetParam(str, 'Aparam');
  if CheckStr(lstr) then
  begin
    if m_A = nil then
    begin
      m_A := cTag.create;
      t := getTagByName(lstr);
      m_a.settag(t);
    end;
    if ChangeCTag(m_A, lstr) then
      changed := true;
  end;
  // �������� B
  lstr := GetParam(str, 'Bparam');
  if CheckStr(lstr) then
  begin
    if m_B = nil then
    begin
      m_B := cTag.create;
      t := getTagByName(lstr);
      m_b.settag(t);
    end;
    if ChangeCTag(m_B, lstr) then
      changed := true;
  end;

  lstr := GetParam(str, 'OutChannel');
  if CheckStr(lstr) then
  begin
    m_out.tagname := lstr;
  end;
  if changed then
  begin
    updateOutChan;
  end;
  DoSetProperties(self);
end;

procedure cAriphmAlg.UpdateOutTag;
var
  str:pansichar;
  tagname: string;
  bl: IBlockAccess;
begin
  if m_Out=nil then // �������� ������ ����
  begin
    ecm;
    m_Out := cTag.create;
    if (m_a<>nil) and (m_b<>nil) then
    begin
      m_Out.tag := createVectorTagR8(genTagName, m_a.tag.getfreq, true, false, false);
      if not FAILED(m_Out.tag.QueryInterface(IBlockAccess, bl)) then
      begin
        m_Out.block := bl;
        bl := nil;
      end;
    end;
    lcm;
  end
  else // ���������� ������������� ����
  begin
    ecm;
    if (m_a<>nil) and (m_b<>nil) then
    begin
      str := lpcstr(StrToAnsi(genTagName));
      m_Out.tag.SetName(str);
      m_Out.tag.SetFreq(m_a.tag.getfreq);
      m_Out.block := nil;
      if not FAILED(m_Out.tag.QueryInterface(IBlockAccess, bl)) then
      begin
        m_Out.block := bl;
      end;
    end;
    lcm;
  end;
end;

end.
