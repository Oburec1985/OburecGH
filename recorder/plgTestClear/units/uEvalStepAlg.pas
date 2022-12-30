unit uEvalStepAlg;

interface
uses
  classes, Windows, tags, uBaseObj, uBaseObjMng, activeX, nativexml, uRCFunc,
  pluginclass, blaccess, sysutils, uCommonTypes, uFFT,
  urecorderevents,
  uCommonMath,
  uMyMath,
  mathfunction,
  math,
  uHardwareMath,
  complex,
  uRegClassesList,   u2dmath;

type
  cEvalStepAlg = class
  public
    name:string;
  public
    // ������ ����� FFT
    m_fftCount,
    // �������� ����� FFT
    m_fftShift:integer;
    // ������������ FFT ������
    m_fftFlt:boolean;
    // ����� ����������� ��������
    m_Threshold:double;
    // �������� � �������� �� ������ ������������ ��������
    m_TrigOffset:double;
    m_tag: cTag;
    m_outTag: cTag;
  protected

    FFTProp:TFFTProp;
    // ����� ����� fft, ����� ������ �� ������� ���� ������ ��������,
    m_blockcount,
    // ���������� ������ m_overflowP=(1/ 2^m_overflow)
    m_overflow, m_overflowP: integer;
    // ���������� �������
    m_spmdx: double;
    // ������ ������ �� ������� ���� ������ (dt*fs)
    m_portionsize:integer;
    // ���������� ����������� ������ �������
    m_ReadyBlockCount: integer;
    // ������ ���������� �������� � m_BlockTime
    m_BlockTimeInd: integer;
  protected
    procedure doOnStart;
    procedure doEval(intag: cTag; time: double);
    procedure doGetData;
    function ready:boolean;
  public
    constructor create;
    destructor destroy;
  end;

  cAlgList = class(tstringlist)
  private
  public
    procedure doSave(sender:tobject);
    procedure doLoad(sender:tobject);
    function getobj(i:integer):cEvalStepAlg;overload;
    function getobj(str:string):cEvalStepAlg;overload;
    function addAlg(name:string):cEvalStepAlg;
    procedure delAlg(a:cEvalStepAlg);
    procedure doUpdateTags(sender: tobject);
    procedure doGetData;
    procedure doChangeCfg(sender: tobject);
    procedure doChangeRState(sender: tobject);
    procedure createEvents;
    procedure DestroyEvents;
    // ���������� ��� �������� � ��������/������
    procedure doStart;
    procedure doStopRecord;
    constructor create;
    destructor destroy;
  end;

var
  g_AlgList:cAlgList;

implementation
uses
  uCreateComponents;

{ cEvalStepAlg }
constructor cEvalStepAlg.create;
begin
  m_tag:=cTag.create;
  m_outTag:=cTag.create;
end;

destructor cEvalStepAlg.destroy;
begin
  m_tag.destroy;
  m_tag:=nil;

  m_outTag.destroy;
  m_outTag:=nil;
end;

procedure cEvalStepAlg.doEval(intag: cTag; time: double);
var
  ar:tdoublearray;
  // ����� ��������������� ����� � ������� �������� ������
  procBlock,
  // ���������� ������� ������
  bCount,
  len, startind, endind: integer;
  v, dt: double;
  // ����� ����������� ��� ���������� ������
  NCopy, copycount: integer;
  // ��������� ������ ��� ���������� �������� ������ ������ �����
  copyBlocks: boolean;
  knorm, k: double;
  i,j: integer;
begin
  // ���� ������ ����� ��� ������� ������ ��� ���-�� ������� �������������� ������
  procBlock := 0;
end;

procedure cEvalStepAlg.doGetData;
var
  i, BufCount, newBlockCount, blCount, readyBlockCount, blSize, blInd,
    writeBlockSize: integer;
  tare: boolean;
  timeinterval: double;
begin
  if m_tag.block = nil then
    exit;

  if m_tag <> nil then
  begin
    if m_tag.UpdateTagData(true) then
    begin
      doEval(m_tag, m_tag.m_ReadDataTime);
      m_tag.ResetTagData(m_portionsize);
    end;
  end;
end;

procedure cEvalStepAlg.doOnStart;
var
  i: integer;
  t: cTag;
begin
  if m_tag <> nil then
  begin
    m_tag.doOnStart;
  end
  else
  begin

  end;
  if m_outTag <> nil then
  begin
    m_outTag.doOnStart;
  end;
  //ZeroMemory(m_EvalBlock.p, fOutSize * sizeof(double));
  //ZeroMemory(m_rms.p, (m_fftCount shr 1)* sizeof(double));
  m_ReadyBlockCount := 0;
  m_BlockTimeInd := 0;
end;

function cEvalStepAlg.ready: boolean;
begin
  result:=False;
  if m_tag<>nil then
  begin
    if m_outTag<>nil then
      result:=True;
  end;
end;

{ cAlgList }
function cAlgList.addAlg(name: string): cEvalStepAlg;
var
  I: Integer;
begin
  result:=cEvalStepAlg.create;
  for I := 0 to Count - 1 do
  begin
    while getobj(name)<>nil do
    begin
      name:=ModName(name, false);
    end;
  end;
  result.name:=name;
end;



procedure cAlgList.createEvents;
begin
  AddPlgEvent('cAlgList_doUpdateTags', c_RUpdateData, doUpdateTags);
  AddPlgEvent('cAlgList_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
  AddPlgEvent('cAlgList_doChangeCfg', c_RC_LeaveCfg, doChangeCfg);
end;

procedure cAlgList.delAlg(a: cEvalStepAlg);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Objects[i]=a then
    begin
      a.destroy;
      Delete(i);
    end;
  end;
end;

constructor cAlgList.create;
begin
  createEvents;
end;

destructor cAlgList.destroy;
begin
  DestroyEvents;
end;

procedure cAlgList.DestroyEvents;
begin
  RemovePlgEvent(doUpdateTags, c_RUpdateData);
  RemovePlgEvent(doChangeRState, c_RC_DoChangeRCState);
  RemovePlgEvent(doChangeCfg, c_RC_LeaveCfg);
end;

procedure cAlgList.doChangeCfg(sender: tobject);
begin

end;

procedure cAlgList.doChangeRState(sender: tobject);
begin
  case GetRCStateChange of
    RSt_Init:
      begin

      end;
    RSt_StopToView:
      begin
        doStart;
      end;
    RSt_StopToRec:
      begin
        doStart;
      end;
    RSt_ViewToStop:
      begin

      end;
    RSt_ViewToRec:
      begin
        doStart;
      end;
    RSt_initToRec:
      begin
        doStart;
      end;
    RSt_initToView:
      begin
        doStart;
      end;
    RSt_RecToStop:
      begin
        doStopRecord;
      end;
    RSt_RecToView:
      begin
        doStopRecord;
        doStart;
      end;
  end;
end;

procedure cAlgList.doGetData;
begin

end;

procedure cAlgList.doLoad(sender: tobject);
var
  dir, name, newpath:string;
begin
  dir:=extractfiledir(g_cfgpath);
  name:=trimext(extractfilename(g_cfgpath));
  newpath:=dir+'\'+name+'.xml';
end;

procedure cAlgList.doSave(sender: tobject);
var
  dir, name, newpath:string;

  doc:TNativeXml;
  node, child, tagnode:txmlnode;
  I: Integer;
  a:cEvalStepAlg;
begin
  dir:=extractfiledir(g_cfgpath);
  name:=trimext(extractfilename(g_cfgpath));

  newpath:=dir+'\'+name+'.xml';
  doc:=TNativeXml.Create(nil);
  node:=doc.Root;
  node:=node.NodeNew('Algs');
  node.WriteAttributeInteger('AlgCount',g_AlgList.Count,0);
  for I := 0 to g_AlgList.Count - 1 do
  begin
    a:=getobj(i);
    child:=node.NodeNew(a.name);
    child.WriteAttributeInteger('numFFT',a.m_fftCount, 32);
    child.WriteAttributeInteger('OffsetFFT',a.m_fftShift, 32);
    child.WriteAttributeBool('UseFFTflt',a.m_fftFlt, false);
    child.WriteAttributeFloat('TrigThreshold',a.m_Threshold, 0);
    child.WriteAttributeFloat('TrigThreshold',a.m_TrigOffset, 0);
    tagnode := child.NodeNew('inTag');
    saveTag(a.m_tag, tagnode);
    tagnode := child.NodeNew('OutTag');
    saveTag(a.m_outTag, tagnode);

  end;
  Doc.XmlFormat := xfReadable;
  doc.SaveToFile(newpath);
  doc.destroy;

end;

procedure cAlgList.doStart;
var
  i: integer;
  a: cEvalStepAlg;
begin
  for i := 0 to Count - 1 do
  begin
    a := getobj(i);
    if a.ready then
        a.doOnStart;
  end;
end;

procedure cAlgList.doStopRecord;
begin

end;

procedure cAlgList.doUpdateTags(sender: tobject);
var
  a: cEvalStepAlg;
  i: integer;
begin
  // ����������
  for i := 0 to Count - 1 do
  begin
    a:= getobj(i);
    if a.ready then
    begin
        continue;
    end;
    a.doGetData;
  end;
end;

function cAlgList.getobj(i: integer): cEvalStepAlg;
begin
  result:=cEvalStepAlg(objects[i]);
end;

function cAlgList.getobj(str:string):cEvalStepAlg;
var
  I: Integer;
  o:cEvalStepAlg;
begin
  result:=nil;
  for I := 0 to Count - 1 do
  begin
    o:=getobj(i);
    if getobj(i).name=str then
    begin
      result:=o;
      exit;
    end;
  end;
end;

end.
