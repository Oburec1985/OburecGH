unit uRZDBase;

interface
uses
  uDBObject, ubaseobj, pathutils, uCommonMath, sysutils, uWpProc;

type
  cTestObj = class(cDBObject)

  end;

  cRZDFolder = class(cdbFolder)
  public
    constructor create;override;
  end;

  // ����� � ���������� ����������
  cCalibrFolder = class(crzdfolder)
  protected
    ftype:integer;
    fmera:string;
  protected
    function CreateDBObj(str:string):cDBobject;override;
    function testpath(str:string):integer;override;
    function getMeraFile:string;
    function getimageindex:integer;override;
  public
    constructor create;override;
  end;

  cSegmentFolder  =class(crzdfolder)
  protected
    function CreateDBObj(str:string):cDBobject;override;
    function getimageindex:integer;override;
  public
    // �������� ���� ���������� ��������� ����� ���� ����������
    function GetDate:tdatetime;
    procedure DoLincParent;override;

    function getByPref(pref:string):csrc;
    function getVC:csrc;
    function getH:csrc;
    function getHin:csrc;
    function getHOut:csrc;

    function getResByPref(pref:string):csrc;
    function getVCRes:csrc;
    function getHRes:csrc;
    function getHinRes:csrc;
    function getHOutRes:csrc;
  end;

  cRegionFolder = class(crzdfolder)
  protected
    function getimageindex:integer;override;
    function CreateDBObj(str:string):cDBobject;override;
  public
    procedure DoLincParent;override;
  end;

  cBaseCalibr = class(crzdfolder)
  protected
    // ���������� ��� ���������� ������ �������� � ���� ���������� windows
    //procedure doUpdateFolder(str:string);override;
    function CreateDBObj(str:string):cDBobject;override;
  end;

  cMatrixFolder = class(crzdfolder)
  protected
    function CreateDBObj(str:string):cDBobject;override;
    constructor create;override;
  end;

  cTestsFolder = class(cdbFolder)
  protected
    constructor create;override;
  end;


  cRZDBaseFolder = class(cdbFolder)
  public
    // ������ ������ ���������� ������
    m_CalibrFolder:cdbFolder;
    // ������ ������
    m_MatrixFolder:cMatrixFolder;
    // ������ �������
    m_TestsFolder:cTestsFolder;
  protected
    function CreateDBObj(str:string):cDBobject;override;
  public
    procedure SetMatrixPref(str:string);
    procedure SetTestsPref;
    // ���������� ���� � �������� ����������� � �������
    procedure SetMainPath(m, c, t:string);
    constructor create;override;
  end;

  cRZDbase = class(cDB)
  protected
    m_regionPref:string;
  public
    m_MeraPref,
    m_vcpref,
    m_Hpref,
    m_Hinpref,
    m_HOutpref,
    m_SegPref,
    // ����� ������� �����
    m_calibrPref,
    m_matrixPref,
    m_TestsPref:string;
    m_wpMng:cwpobjmng;
  protected
    function createBaseFolder:cDBFolder;override;
    procedure setregionpref(str:string);
  public
    function getCalibr(reg:string;cut:integer):cSegmentFolder;
    procedure UpdateDB;overload;
    procedure UpdateDB(folder:string);overload;
    property regionPref:string read m_regionPref write setregionpref;
  end;


implementation

const
  c_DBMatrix = 32;
  c_DBBlackMatrix = 33;
  c_DBMeasure = 27;
  c_DBRails = 25;
  c_RailSeg=26;

procedure cRegionFolder.DoLincParent;
begin
  inherited;
  AddPrefix(cRZDbase(getmng).m_SegPref);
end;

function cRegionFolder.CreateDBObj(str:string):cDBobject;
begin
  Result:=cSegmentFolder.create;
end;

function cRegionFolder.getimageindex:integer;
begin
  result:=c_DBRails;
end;

function cRZDBaseFolder.CreateDBObj(str:string):cDBobject;
begin
  result:=cRegionFolder.create;
end;

procedure cRZDBaseFolder.SetMatrixPref(str:string);
var
  mng:cRZDbase;
begin
  mng:=cRZDbase(getmng);
  mng.m_matrixPref:=str;
  m_MatrixFolder.AddPrefix(str);
end;

procedure cRZDBaseFolder.SetTestsPref;
var
  mng:cRZDbase;
begin
  mng:=cRZDbase(getmng);
  mng.m_TestsPref:='.mera';
  m_TestsFolder.AddPrefix('.mera');
  m_TestsFolder.AddPrefix('.usm');
end;

constructor cRZDBaseFolder.create;
begin
  inherited;
  m_CalibrFolder:=cBaseCalibr.create;
  m_CalibrFolder.imageindex:=c_DBMeasure;
  AddChild(m_CalibrFolder);

  m_MatrixFolder:=cMatrixFolder.create;
  m_MatrixFolder.ScanFolder:=false;
  m_MatrixFolder.imageindex:=c_DBMatrix;
  AddChild(m_MatrixFolder);

  m_TestsFolder:=cTestsFolder.create;
  AddChild(m_TestsFolder);
end;

procedure cRZDBaseFolder.SetMainPath(m, c, t:string);
begin
  m_MatrixFolder.path:=m;
  m_CalibrFolder.path:=c;
  m_TestsFolder.path:=t;
end;

function cRZDbase.CreateBaseFolder:cDBFolder;
begin
  result:=cRZDBaseFolder.create;
  m_MeraPref:='.mera';
end;

procedure cRZDbase.setregionpref(str:string);
begin
  m_regionPref:=str;
  cRZDBaseFolder(m_BaseFolder).m_CalibrFolder.AddPrefix(m_regionPref);
end;

procedure cRZDbase.UpdateDB;
begin
  cRZDBaseFolder(m_BaseFolder).m_CalibrFolder.update;
  cRZDBaseFolder(m_BaseFolder).m_MatrixFolder.update;
  cRZDBaseFolder(m_BaseFolder).m_TestsFolder.update;
end;

function cRZDbase.getCalibr(reg:string;cut:integer):cSegmentFolder;
var
  I: Integer;
  o:cbaseobj;
  fld, test:cdbfolder;
  num:string;
begin
  result:=nil;
  fld:=nil;
  for I := 0 to cRZDBaseFolder(m_BaseFolder).m_CalibrFolder.childCount - 1 do
  begin
    o:=cRZDBaseFolder(m_BaseFolder).m_CalibrFolder.getChild(i);
    if o.caption=reg then
    begin
      fld:=cdbfolder(o);
      break;
    end;
  end;
  if fld=nil then
    exit;
  for I := 0 to fld.childcount - 1 do
  begin
    test:=cdbfolder(fld.getChild(i));
    num:=getendnum(test.caption);
    if strtoint(num)=cut then
    begin
      result:=cSegmentFolder(test);
      break;
    end;
  end;
end;

procedure cRZDbase.UpdateDB(folder:string);
var
  o:cdbFolder;
begin
  o:=cdbFolder(getchildbypath(folder));
  o.update;
end;

{ cSegmentFolder }

function cSegmentFolder.GetDate:tdatetime;
var
  src:csrc;
  date:tdatetime;
begin
  result:=0;
  src:=getVC;
  if src<>nil then
  begin
    date:=StrToDateTime(src.merafile.Date);
    result:=date;
  end;
  src:=getH;
  if src<>nil then
  begin
    date:=StrToDateTime(src.merafile.Date);
    if result<date then
      result:=date;
  end;
  src:=getHout;
  if src<>nil then
  begin
    date:=StrToDateTime(src.merafile.Date);
    if result<date then
      result:=date;
  end;
  src:=getHin;
  if src<>nil then
  begin
    date:=StrToDateTime(src.merafile.Date);
    if result<date then
      result:=date;
  end;
end;

function cSegmentFolder.getByPref(pref:string):csrc;
var
  src:csrc;
  I: Integer;
  f:cCalibrFolder;
  path:string;
begin
  result:=nil;
  for I := 0 to childCount - 1 do
  begin
    f:=cCalibrFolder(getChild(i));
    if CheckPosSubstr(pref,f.name) then
    begin
      path:=f.getMeraFile;
      if fileexists(path) then
      begin
        result:=cRZDbase(getmng).m_wpMng.loadsrc(path);
      end;
      exit;
    end;
  end;
end;

function cSegmentFolder.getVC:csrc;
begin
  result:=getByPref(cRZDbase(getmng).m_vcpref);
end;

function cSegmentFolder.getH:csrc;
begin
  result:=getByPref(cRZDbase(getmng).m_hpref);
end;

function cSegmentFolder.getHin:csrc;
begin
  result:=getByPref(cRZDbase(getmng).m_hinpref);
end;

function cSegmentFolder.getHOut:csrc;
begin
  result:=getByPref(cRZDbase(getmng).m_houtpref);
end;

function cSegmentFolder.getResByPref(pref:string):csrc;
var
  src:csrc;
  I: Integer;
  f:cdbfolder;
  path:string;
begin
  result:=nil;
  for I := 0 to childCount - 1 do
  begin
    f:=cdbfolder(getChild(i));
    if CheckPosSubstr(pref,f.name) then
    begin
      path:=f.Absolutepath+'\RZDForce\RZDForce.mera';
      if fileexists(path) then
      begin
        result:=cRZDbase(getmng).m_wpMng.loadsrc(path);
      end;
      exit;
    end;
  end;
end;

function cSegmentFolder.getVCRes:csrc;
begin
  result:=getResByPref(cRZDbase(getmng).m_vcpref);
end;

function cSegmentFolder.getHRes:csrc;
begin
  result:=getResByPref(cRZDbase(getmng).m_hpref);
end;

function cSegmentFolder.getHinRes:csrc;
begin
  result:=getResByPref(cRZDbase(getmng).m_hinpref);
end;

function cSegmentFolder.getHOutRes:csrc;
begin
  result:=getResByPref(cRZDbase(getmng).m_houtpref);
end;

function cSegmentFolder.getimageindex:integer;
begin
  result:=c_RailSeg;
end;

function cSegmentFolder.CreateDBObj(str: string): cDBobject;
begin
  result:=cCalibrFolder.create;
  cCalibrFolder(result).ftype:=ftestresult;
  cdbFolder(result).AddPrefix(crzdbase(getmng).m_MeraPref);
  case ftestresult of
    0:;
    1:;
    2:;
    3:;
    4:;
  end;
end;

procedure cSegmentFolder.DoLincParent;
begin
  inherited;
  AddPrefix(crzdbase(getmng).m_VcPref);
  AddPrefix(crzdbase(getmng).m_HPref);
  AddPrefix(crzdbase(getmng).m_HinPref);
  AddPrefix(crzdbase(getmng).m_HOutPref);
end;

{ cCalibrFolder }

function cCalibrFolder.getimageindex:integer;
begin
  if fmera<>'' then
  begin
    case ftype of
      0:result:=c_BlueDown;
      1:result:=c_BlueUpdate;
      2:result:=c_BlueRight;
      3:result:=c_BlueLeft;
    else
      result:=c_DBMeasure;
    end;
  end
  else
    result:=c_DBPathError;
end;

function cCalibrFolder.getMeraFile:string;
begin
  result:=fmera;
end;

constructor cCalibrFolder.create;
begin
  inherited;
  fScanFolders:=false;
  fScanFiles:=true;
end;



function cCalibrFolder.testpath(str:string):integer;
begin
  result:=inherited testpath(str);
  if result=0 then
    fmera:=str;
end;

function cCalibrFolder.CreateDBObj(str:string):cDBobject;
begin
  result:=nil;
end;


function cBaseCalibr.CreateDBObj(str: string): cDBobject;
begin
  result:=cRegionFolder.create;
end;


constructor crzdfolder.create;
begin
  inherited;
  fUseNotifier:=true;
end;


{ cMatrixFolder }

function cMatrixFolder.CreateDBObj(str: string): cDBobject;
begin
  result:=inherited CreateDBObj(str);
  result.imageindex:=c_DBBlackMatrix;
end;

constructor cMatrixFolder.create;
begin
  inherited;
end;

constructor cTestsFolder.create;
begin
  inherited;
  fscanfolders:=false;
  fUseNotifier:=true;
  fdeep:=2;
end;

end.
