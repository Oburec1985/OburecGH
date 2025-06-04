unit uGrmsAlg;

interface
uses
  classes, windows, activex, ubasealg, uCommonMath, uRCFunc, tags, recorder,
  blaccess, nativexml, ucommontypes, uFFT,
  pluginclass, sysutils, uQueue;


type
  cPeakHoldAlg = class(cbasealg)
  protected
    // шаг по времени
    fdX:double;
  public
    InTag, OutTag: cTag;
    m_data:cQueue<double>;
  protected
    procedure createOutChan;
    procedure SetProperties(str: string); override;
    function GetProperties: string; override;
    procedure doOnStart; override;
    procedure doEval(tag: cTag; time: double); override;
    procedure doGetData; override;
    procedure LoadObjAttributes(xmlNode: txmlNode; mng: tobject); override;
    procedure LoadTags(node: txmlNode);override;
    function ready: boolean;override;
  public
    constructor create; override;
    class function getdsc: string; override;
  end;

const
  sqrt2=1.4142135623730950488016887242097;
  C_PeakHoldOpts = 'dX=1';

implementation

{ cPeakHoldAlg }

constructor cPeakHoldAlg.create;
begin
  inherited;
  InTag:=ctag.create;
  OutTag:=ctag.create;
end;

procedure cPeakHoldAlg.doEval(tag: cTag; time: double);
begin
  inherited;

end;

procedure cPeakHoldAlg.doGetData;
begin
  inherited;

end;

procedure cPeakHoldAlg.doOnStart;
begin
  inherited;

end;

class function cPeakHoldAlg.getdsc: string;
begin

end;

function cPeakHoldAlg.GetProperties: string;
begin

end;

procedure cPeakHoldAlg.LoadObjAttributes(xmlNode: txmlNode; mng: tobject);
begin
  inherited;

end;

procedure cPeakHoldAlg.LoadTags(node: txmlNode);
begin
  inherited;

end;

function cPeakHoldAlg.ready: boolean;
begin

end;

procedure cPeakHoldAlg.createOutChan;
var
  str, tagname: string;
  bl: IBlockAccess;
begin
  if InTag <> nil then
  begin
    if InTag.tag <> nil then
    begin
      str:=OutTag.tagname;
      if OutTag.tag=nil then
      begin
        ecm;
        OutTag.tag := createScalar(str, true);
        lcm;
      end;
    end;
  end;
end;

procedure cPeakHoldAlg.SetProperties(str: string);
var
  lstr: string;
  t: itag;
begin
  if str = '' then
    exit;
  m_properties:=updateParams(m_properties, str, '', ' ');
  lstr := GetParam(str, 'dX');
  if lstr <> '' then
  begin
    fdx := strtoFloatExt(lstr);
  end;



  lstr := GetParam(str, 'Channel');
  if lstr <> '' then
  begin
    if InTag = nil then
    begin
      InTag := cTag.create;
      t := getTagByName(lstr);
      if t<>nil then
      begin
        intag.tagname:=lstr;
        OutTag.tagname:=lstr+'_ph';
        if OutTag.tag = nil then
          createOutChan
        else
        begin
          updateOutChan;
        end;
      end
      else
      begin
        OutTag.tagname:=lstr+'_ph';
      end;
    end;
    ChangeCTag(InTag, lstr);
  end;
end;

end.
