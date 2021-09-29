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
  // алгоритм отличяается от cPhaseAlg тем что не использует в качестве источников
  // готовый расчитанный спектр а использует временные сигналы, синхронизирует общие по времени блоки
  // и считает по ним взаимный спектр
  cAriphmAlg = class(cbasealg)
  public
    m_A: cTag;
    m_B: cTag;
    m_Out: cTag;
  protected
    m_opertype:integer;
  private
    // лок который передается на расчет в спектр. нельзя передавать tag.readdata
    // тк блок может дополняться нулями
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

    // если поменялось имя входного канала то пересоздаем имя выходного канала, а может и тип
    // вызывается при загрузке или при установке входного тега
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure SaveObjAttributes(xmlNode: txmlNode); override;
    procedure LoadTags(node: txmlNode); override;
    function ready: boolean; override;
    function getresname: string; override;
  public
    procedure updateOutChan; override;
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
  m_A := cTag.create;
  // addInputTag(m_InTag);
  m_B := cTag.create;
  m_Out := cTag.create;
end;

destructor cAriphmAlg.destroy;
begin
  m_A.destroy;
  m_A:=nil;
  m_B.destroy;
  m_B:=nil;
  m_Out.destroy;
  m_Out:=nil;
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
  // Получение данных
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
  result := 'Арифм. опер.';
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
  // параметр A
  lstr := GetParam(str, 'Aparam');
  if CheckStr(lstr) then
  begin
    t := getTagByName(lstr);
    m_a.settag(t);
    if ChangeCTag(m_A, lstr) then
      changed := true;
  end;
  // параметр B
  lstr := GetParam(str, 'Bparam');
  if CheckStr(lstr) then
  begin
    t := getTagByName(lstr);
    m_b.settag(t);
    if ChangeCTag(m_B, lstr) then
      changed := true;
  end;

  lstr := GetParam(str, 'OutChannel');
  if CheckStr(lstr) then
  begin
    m_out.tagname := lstr;
    changed := true;
  end;
  if changed then
  begin
    updateOutChan;
  end;
  DoSetProperties(self);
end;

procedure cAriphmAlg.updateOutChan;
begin
  UpdateOutTag;
end;

procedure cAriphmAlg.UpdateOutTag;
var
  str:pansichar;
  tagname: string;
  bl: IBlockAccess;
begin
  if m_Out.tag=nil then // создание нового тега
  begin
    ecm;
    if Aexists and Bexists then
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
  else // обновление существующего тега
  begin
    ecm;
    if Aexists and Bexists then
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
