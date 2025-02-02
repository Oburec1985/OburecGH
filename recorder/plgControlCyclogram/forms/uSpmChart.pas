unit uSpmChart;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, ExtCtrls, uRecBasicFactory, inifiles,
  uControlObj, uEventList, udrawobj,
  uComponentservises, uEventTypes, ComCtrls, uBtnListView, recorder,
  ucommonmath, uDoubleCursor,uChartEvents, uLabel,
  uRecorderEvents, ubaseObj, uCommonTypes, uEditProfileFrm, uControlWarnFrm,
  uRTrig, uRCFunc, ubasealg, uBuffTrend1d, upage, utextlabel, uaxis, utrend,
  PluginClass, ImgList, uChart, uGrmsSrcAlg, uPhaseAlg, usetlist, ufreqband,
  uHardwareMath,
  tags,
  uBaseAlgBands,
  uSpm;

type
  tSpmBand = class
  public
    // ��������� ������ ���������� ������
    m_freqband:cFreqBand;
    // ��� ������ (�������� ������ ���� ������� � �� ������������)
    m_b:tBand;
    // ������ �������� ��� ������� ����������� ��������
    m_trends:tstringlist;
  protected
    function getname:string;
  public
    function getObj(s:string):tobject;
    property name:string read getname;
    constructor create;
    destructor destroy;
  end;


  TSpmTagInfo = class
  private
    // ctextlabel; ���������� ��������� TSpmChart.UpdateLabels;
    flags: tlist;
  public
    m_spm: cSpm;
    m_algname: string;

    // ��� Spm
    m_spmtrend: cBuffTrend1d;

    m_lastblock: double;
    m_lastblockind: integer;
    m_initGraph: boolean;
  protected
    procedure setAlg(a: cBaseAlgContainer);
    function GetAlg:cBaseAlgContainer;
    procedure DoUpdateSpm;
    procedure setShowLabels(b:boolean);
  public
    property alg: cbasealgcontainer reAD GetAlg write setalg;
    function update: boolean;
    constructor create;
    destructor destroy;
  end;

  TSpmChart = class(TRecFrm)
    procedure SpmChartRBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    spmChart:cchart;
    m_profile, m_hihi, m_lolo, m_lo, m_hi: ctrend;
    // ������� �������� �� x, y
    aX, aY: point2d;
    lgX, lgY: boolean;
    // ������ ��������� ����� ��� ���������� �� X
    m_labList: tlist;
    fprofile: tprofile;
    // ������ ����� ��� ����������� (cFreqBand)
    m_bands:tlist;
    // ���������� ������� ������ �� ���������
    fShowLabels:boolean;
  protected
    fShowProfile, fShowWarnings, fShowAlarms, fShowRms, fShowPhase: boolean;
  public
    procedure SpmChartInit(Sender: TObject);
  public
    // ������ ����� ����������� � �����
    m_tagslist: tstringlist;
  protected
    procedure initProfile;
    procedure setProfile(p: tprofile);
    procedure WndProc(var Message: TMessage); override;
    // ��������� ����������
    procedure UpdateSpm;
    procedure UpdateView;
    procedure UpdateLabels;
    // ������������ � ��� �� ������, ��� � ���������� �����!!! (UpdateTagData!!!)
    // ������ ����� �� �������� ���� ��������
    // ��������� ������ ��������� � ����������� ����, �� �������
    procedure UpdateBands;

    procedure doStart;
    procedure InitGraphs(ti: TSpmTagInfo);

    // �� ������ ��������
    procedure lincAlgsByNames;
    // �������/ ������������������� ������ �����
    procedure ApplyBands;

    procedure testAddScale(up, ctrl:boolean);

    function  getBand(bandname:string):tSpmBand;overload;
    function  getBand(i:integer)      :tSpmBand;overload;
    procedure clearbands;

    procedure DblClick(Sender: TObject);
    procedure doCursorMove(sender:tobject);
    procedure doOnZoom(sender:tobject);
    procedure doKeyDown(sender:tobject; var Key: Word;  Shift: TShiftState);
    procedure FormClick(Sender: TObject);
    function  DblCursor: cDoubleCursor;
    procedure createEvents;
    procedure destroyEvents;
  public
    property profile: tprofile read fprofile write setProfile;
    // ��������� ��� ���������
    procedure UpdateOpts;
    procedure clearTagsInfo;

    function TagInfo(i: integer): TSpmTagInfo;

    function addAlg(a: cbasealgcontainer):TSpmTagInfo; overload;
    function addAlg(str: string):TSpmTagInfo; overload;

    // ��������� ��������� �������
    procedure TestInit;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
  private
    function getShowLabels: boolean;
    procedure setShowLabels(const Value: boolean);
  protected
    procedure setShowProfile(b: boolean);
    function getShowProfile: boolean;
    procedure setShowWarnings(b: boolean);
    function getShowWarnings: boolean;
    procedure setShowAlarms(b: boolean);
    function getShowAlarms: boolean;
  public
    property ShowLabels: boolean read getShowLabels write setShowLabels;
    property ShowProfile: boolean read getShowProfile write setShowProfile;
    property ShowWarnings: boolean read getShowWarnings write setShowWarnings;
    property ShowAlarms: boolean read getShowAlarms write setShowAlarms;
  end;

  ISpmFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cSpmFactory = class(cRecBasicFactory)
  public
    eList:ceventlist;
    initevents:boolean;
  private
    factivechart:tSpmChart;
    m_counter: integer;
  private
  protected
    procedure doDestroyForms; override;
    procedure CreateEvents;
    procedure DestroyEvents;
    procedure doChangeCfg(sender:tobject);
    procedure doChangeRState(Sender: TObject);
    procedure doChangeAlgProps(Sender: TObject);
    procedure doStart;
    procedure SetActiveChart(c:TSpmChart);
    function GetActiveChart:TSpmChart;
  public
    procedure doAfterLoad;override;

    procedure doCursorMove(Sender: TObject);
  public
    property actchart:TSpmChart read GetActiveChart write SetActiveChart;
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var pSize: SIZE); override;
  end;

var
  g_SpmFactory:cSpmFactory;

const
  // ���������� ��� ����� ����� �������
  E_CURSMOVE = $00000001;
  E_SETACTSPMCHART = $00000002;

const
  c_Pic = 'SPMFRM';
  c_Name = '����������� �������';
  c_SpmChart_defXSize = 400;
  c_SpmChart_defYSize = 400;
  c_graphtype_spm = 0;

  // ctrl+shift+G
  // ['{EFED70A7-68F8-48A4-8AF2-E0B2E222BD6F}']
  IID_CHARTSPM: TGuid = (D1: $EFED70A7; D2: $68F8; D3: $48A4;
    D4: ($8A, $F2, $E0, $B2, $E2, $22, $BD, $6F));

implementation

uses
  uSpmChartEdit;
{$R *.dfm}
{ TSpmChart }

function TextLabelsComparator(p1, p2: pointer): integer;
begin
  if cTextLabel(p1).Position.x > cTextLabel(p2).Position.x then
    result := 1
  else
  begin
    if cTextLabel(p1).Position.x < cTextLabel(p2).Position.x then
      result := -1
    else
      result := 0;
  end;
end;

function LabelsComparator(p1, p2: pointer): integer;
begin
  if cLabel(p1).Position.x > cLabel(p2).Position.x then
    result := 1
  else
  begin
    if cLabel(p1).Position.x < cLabel(p2).Position.x then
      result := -1
    else
      result := 0;
  end;
end;

procedure TSpmChart.doCursorMove(sender: tobject);
begin
  g_SpmFactory.doCursorMove(self);
end;

procedure TSpmChart.doKeyDown(sender:tobject; var Key: Word;  Shift: TShiftState);
var
  p: cpage;
begin
  if GetKeyState(VK_CONTROL)<0 then
  begin
    if GetKeyState(Ord('3'))<0 then
    begin
      p := cpage(spmChart.activePage);
      p.cursor.visible:=not p.cursor.visible;
    end;
    if GetKeyState(VK_UP)<0 then
    begin
      testAddScale(true, true);
    end;
    if GetKeyState(VK_down)<0 then
    begin
      testAddScale(false, true);
    end;
  end;
  if GetKeyState(VK_UP)<0 then
  begin
    testAddScale(true, false);
  end;
  if GetKeyState(VK_down)<0 then
  begin
    testAddScale(false, false);
  end;
end;


procedure TSpmChart.DblClick(Sender: TObject);
var
  r: frect;
  a: caxis;
  p: cpage;
begin
  p := cpage(spmChart.activePage);
  a := p.activeAxis;
  r.BottomLeft := p2(aX.x, aY.x);
  r.TopRight := p2(aX.y, aY.y);
  p.ZoomfRect(r);
end;


function TSpmChart.DblCursor: cDoubleCursor;
var
  p:cpage;
begin
  p:=cpage(spmChart.activePage);
  result:=p.cursor;
end;

procedure TSpmChart.InitGraphs(ti: TSpmTagInfo);
var
  l: cTextLabel;
  colorind:integer;
  I: Integer;
begin
  lincAlgsByNames;
  ApplyBands;
  if ti.m_spm <> nil then
  begin
    if ti.m_spm.m_tag=nil then exit;
    ti.m_spmtrend := cBuffTrend1d.create;
    ti.m_spmtrend.layer:=1;
    ti.m_spmtrend.chart := spmChart;

    for I := 0 to m_tagslist.Count - 1 do
    begin
      if ti=TagInfo(I) then
      Begin
        colorind:=i;
        break;
      End;
    end;
    if colorind>length(ColorArray)-1 then
    begin
      colorind:=colorind-trunc(colorind/length(ColorArray))*length(ColorArray);
    end;
    ti.m_spmtrend.color := ColorArray[colorind];
    ti.m_spmtrend.datatype := c_real;
    ti.m_spmtrend.dx := ti.m_spm.SpmDx;
    ti.m_spmtrend.name := ti.m_spm.name;
    if cpage(spmChart.activePage)<>nil then
    begin
      cpage(spmChart.activePage).activeAxis.AddChild(ti.m_spmtrend);
      l := cTextLabel.create;
      ti.flags.Add(l);
      ti.m_spmtrend.AddChild(l);
      l.color := blue;
      l.name := 'Lmax_' + ti.m_spm.resname;
      l.drawline := true;
      ti.m_initGraph := true;
      l.visible:=fShowLabels;
    end;
  end;
end;

procedure TSpmChart.lincAlgsByNames;
var
  i: integer;
  ti: TSpmTagInfo;
  a: cbasealgcontainer;
begin
  for i := 0 to m_tagslist.Count - 1 do
  begin
    ti := TagInfo(i);
    if (ti.alg = nil) then
    begin
      if g_algMng <> nil then
      begin
        a := cbasealgcontainer(g_algMng.getobj(ti.m_algname));
        if a <> nil then
        begin
          ti.alg:=a;
        end
        else
        begin
          ti.alg:=g_algMng.getSpm(ti.m_algname);
          if ti.m_spm<>nil then
          begin
            if ti.m_spmtrend<>nil then
            begin
              ti.m_spmtrend.dx := ti.m_spm.SpmDx;
            end;
          end;
        end;
      end;
    end;
  end;
end;

function TSpmChart.addAlg(a: cbasealgcontainer):TSpmTagInfo;
var
  ti: TSpmTagInfo;
  l: cTextLabel;
  i: integer;
begin
  for i := 0 to m_tagslist.Count - 1 do
  begin
    ti := TagInfo(i);
    if (ti.m_spm = a) then
    begin
      result:=ti;
      exit;
    end;
  end;
  ti := TSpmTagInfo.create;
  ti.alg:=a;

  m_tagslist.AddObject(a.name, ti);
  if spmChart.initGl then
    InitGraphs(ti);
  result:=ti;
end;

function TSpmChart.addAlg(str: string):TSpmTagInfo;
var
  ti: TSpmTagInfo;
  l: cTextLabel;
  i: integer;
begin
  for i := 0 to m_tagslist.Count - 1 do
  begin
    ti := TagInfo(i);
    if m_tagslist.strings[i] = str then
    begin
      result:=ti;
      exit;
    end;
  end;
  ti := TSpmTagInfo.create;
  ti.m_algname := str;
  m_tagslist.AddObject(ti.m_algname, ti);
  if spmChart.initGl then
    InitGraphs(ti);
  result:=ti;
end;

procedure TSpmChart.ApplyBands;
var
  I,j,k,n: Integer;
  ti: TSpmTagInfo;
  bandtagPair:TTagBandPair;
  band:tBand;
  b:tSpmBand;
  place:tplace;
  page:cpage;
  tl:ctextlabel;
  findBand:boolean;
begin
  for I := 0 to m_tagslist.Count - 1 do
  begin
    ti:=TSpmTagInfo(m_tagslist.Objects[i]);
    bandtagPair:=g_algMng.m_TagBandPairList.getPair(ti.m_algname);
    if bandtagPair=nil then
    begin
      if ti.m_spm<>nil then
      begin
        if ti.m_spm.m_tag<>nil then
          bandtagPair:=g_algMng.m_TagBandPairList.getPair(ti.m_spm.m_tag.tagname);
      end;
    end;
    if bandtagPair<>nil then
    begin
      for j := 0 to bandtagPair.placeCount - 1 do
      begin
        place:=bandtagPair.getplace(j);
        for k := 0 to place.Bandcount - 1 do
        begin
          band:=place.getBand(k);
          b:=getBand(band.name);
          if b=nil then // �������� ������� ������
          begin
            b:=tSpmBand.Create;
            b.m_b:=band;
            b.m_freqband:=cFreqBand.create;
            b.m_freqband.m_fullname:=true;
            b.m_freqband.m_LineLabel.Visible:=false;
            b.m_freqband.layer:=2;
            b.m_freqband.m_LineLabel.layer:=0;
            b.m_freqband.m_LineLabel.m_addscaleX:=1.1;
            b.m_freqband.name:=band.name;
            b.m_freqband.m_names:=b.m_trends;
            page:=cpage(spmChart.activePage);
            page.AddChild(b.m_freqband);
            m_bands.Add(b);
          end;
          if b.getObj(ti.m_spm.m_tag.tagname)=nil then
          begin
            b.m_trends.AddObject(ti.m_spm.m_tag.tagname, ti);
            b.m_freqband.length:=b.m_freqband.length+1;
          end;
          findband:=false;
          for n := 0 to ti.flags.count - 1 do
          begin
            if cTextLabel(ti.flags[n]).data=b then
            begin
              findband:=true;
              break;
            end;
          end;
          // ���� ����� ��� ����� ������ ��� �� ����������
          if not findband then
          begin
            if ti.m_spmtrend<>nil then
            begin
              tl:=cTextLabel.create;
              tl.data:=b;
              ti.flags.Add(tl);
              ti.m_spmtrend.AddChild(tl);
              tl.color := blue;
              tl.name := 'Bmax_' + b.name;
              tl.drawline := true;
            end;
          end;
        end;
      end;
    end;
  end;
  //b.m_freqband.inittrendlabels;
  UpdateBands;
end;

procedure TSpmChart.clearTagsInfo;
var
  i: integer;
  ti: TSpmTagInfo;
begin
  for i := 0 to m_tagslist.Count - 1 do
  begin
    ti := TSpmTagInfo(m_tagslist.Objects[i]);
    ti.destroy;
  end;
  m_tagslist.Clear;
end;

constructor TSpmChart.create(Aowner: tcomponent);
begin
  inherited;
  m_bands:=TList.Create;

  spmChart := cchart.create(self);
  spmChart.Align := alClient;
  spmChart.showTV := false;
  spmChart.showLegend := false;
  spmChart.OnClick:=FormClick;
  spmChart.OnRBtnClick := SpmChartRBtnClick;
  spmChart.OnDblClick := DblClick;
  spmChart.OnInit := SpmChartInit;
  spmChart.OnKeyDown:=doKeyDown;
  spmChart.OnCursorMove:=doCursorMove;

  m_labList := tlist.create;

  fShowWarnings := true;
  fShowProfile := true;
  fShowAlarms := true;

  m_tagslist := tstringlist.create;
  createEvents;
end;



destructor TSpmChart.destroy;
begin
  destroyEvents;
  clearTagsInfo;
  m_tagslist.destroy;
  m_labList.destroy;

  clearbands;
  m_bands.Destroy;

  // SpmChart.Destroy;
  // SpmChart:=nil;
  inherited;
end;


procedure TSpmChart.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  alg: cbasealgcontainer;
  i, Count: integer;
  lstr: string;
  ti:TSpmTagInfo;
  p:tprofile;
begin
  inherited;
  Count := a_pIni.ReadInteger(str, 'SpmCount', 0);
  for i := 0 to Count - 1 do
  begin
    lstr := a_pIni.ReadString(str, 'algname_' + inttostr(i), '');
    alg := nil;
    if (lstr <> '') then
    begin
      if (g_algMng <> nil) then
      begin
        alg := g_algMng.getAlg(lstr);
        if alg <> nil then
        begin
          ti:=addalg(alg);
        end;
      end;
      if alg = nil then
      begin
        ti:=addalg(lstr);
      end
      else
      begin

      end;
    end;
  end;

  lstr := a_pIni.ReadString(str, 'Profile', '');
  p := g_CtrlWrnFactory.m_pList.getprof(lstr, i);
  profile := p;

  aX.x := IniReadFloatEx(a_pIni,str, 'X_min', 0);
  aX.y := IniReadFloatEx(a_pIni,str, 'X_max', 10);
  aY.x := IniReadFloatEx(a_pIni,str, 'Y_min', 0);
  aY.y := IniReadFloatEx(a_pIni,str, 'Y_max', 10);
  lgX := a_pIni.ReadBool(str, 'X_Lg', false);
  lgY := a_pIni.ReadBool(str, 'Y_Lg', false);
  ShowLabels:=a_pIni.ReadBool(str, 'ShowLabels', true);

  ShowProfile := a_pIni.ReadBool(str, 'ShowProfile', false);
  ShowWarnings := a_pIni.ReadBool(str, 'ShowWarnings', false);
  ShowAlarms := a_pIni.ReadBool(str, 'ShowAlarms', false);

  fShowRms := a_pIni.ReadBool(str, 'ShowAH', true);
  fShowPhase := a_pIni.ReadBool(str, 'ShowPH', true);
end;

procedure TSpmChart.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  ti: TSpmTagInfo;
begin
  inherited;
  a_pIni.WriteInteger(str, 'SpmCount', m_tagslist.Count);
  for i := 0 to m_tagslist.Count - 1 do
  begin
    ti := TagInfo(i);
    if ti.m_spm<>nil then
      a_pIni.WriteString(str, 'algname_' + inttostr(i), ti.m_spm.resname)
  end;
  if profile <> nil then
    a_pIni.WriteString(str, 'Profile', profile.name);
  a_pIni.WriteFloat(str, 'X_min', aX.x);
  a_pIni.WriteFloat(str, 'X_max', aX.y);
  a_pIni.WriteFloat(str, 'Y_min', aY.x);
  a_pIni.WriteFloat(str, 'Y_max', aY.y);
  a_pIni.WriteBool(str, 'ShowLabels', ShowLabels);
  a_pIni.WriteBool(str, 'X_Lg', lgX);
  a_pIni.WriteBool(str, 'Y_Lg', lgY);
  a_pIni.WriteBool(str, 'ShowProfile', ShowProfile);
  a_pIni.WriteBool(str, 'ShowWarnings', ShowWarnings);
  a_pIni.WriteBool(str, 'ShowAlarms', ShowAlarms);
end;


procedure TSpmChart.SpmChartInit(Sender: TObject);
var
  i: integer;
  ti: TSpmTagInfo;
  p: cpage;
  d: cDoubleCursor;
  ax:cdrawobj;
begin
  initProfile;

  for i := 0 to m_tagslist.Count - 1 do
  begin
    ti := TagInfo(i);
    if not ti.m_initGraph then
    begin
      InitGraphs(ti);
    end;
  end;
  p := cpage(spmChart.activePage);
  p.Caption:='������';
  // ��� ��������� ����� ��������� ����� �����
  ax:=cdrawobj(p.getChild('Axises'));
  ax.layer:=1;
  d := p.cursor;
  d.visible := false;
  UpdateOpts;
end;

procedure TSpmChart.SpmChartRBtnClick(Sender: TObject);
begin
  if SpmChartEditFrm <> nil then
  begin
    SpmChartEditFrm.updateTagsList;
    SpmChartEditFrm.EditChart(self);
  end;
end;

function TSpmChart.TagInfo(i: integer): TSpmTagInfo;
begin
  if i < m_tagslist.Count then
    result := TSpmTagInfo(m_tagslist.Objects[i])
  else
    result := nil;
end;

procedure TSpmChart.testAddScale(up, ctrl: boolean);
var
  I,j,k: Integer;
  ti: TSpmTagInfo;
  bandtagPair:TTagBandPair;
  band:tBand;
  b:tSpmBand;
  place:tplace;
  page:cpage;
begin
  for I := 0 to m_tagslist.Count - 1 do
  begin
    ti:=TSpmTagInfo(m_tagslist.Objects[i]);
    bandtagPair:=g_algMng.m_TagBandPairList.getPair(ti.m_algname);
    if bandtagPair<>nil then
    begin
      for j := 0 to bandtagPair.placeCount - 1 do
      begin
        place:=bandtagPair.getplace(j);
        for k := 0 to place.Bandcount - 1 do
        begin
          band:=place.getBand(k);
          b:=getBand(band.name);
          if b<>nil then
          begin
            if up then
              b.m_freqband.m_LineLabel.m_addscaleX:=b.m_freqband.m_LineLabel.m_addscaleX+0.025
            else
              b.m_freqband.m_LineLabel.m_addscaleX:=b.m_freqband.m_LineLabel.m_addscaleX-0.025;
          end;
        end;
      end;
      spmChart.needRedraw:=true;
      spmChart.Invalidate;
    end;
  end;
end;

procedure TSpmChart.TestInit;
var
  spm: cBaseObj;
  i: integer;
begin
  for i := 0 to g_algMng.Count - 1 do
  begin
    spm := g_algMng.getobj(i);
    if spm is cSpm then
    begin
      addalg(cSpm(spm));
      break;
    end;
  end;
end;

procedure TSpmChart.doStart;
var
  i, j: integer;
  ti: TSpmTagInfo;
  t:itag;
  l:ctextlabel;
  spm:cspm;
begin
  for i := 0 to m_tagslist.Count - 1 do
  begin
    ti := TagInfo(i);
    ti.m_lastblock := 0;
    ti.m_lastblockind := 0;
    t:=getTagByName(ti.m_spm.m_tag.tagname);
    if t=nil then
    begin
      ti.m_spmtrend.visible:=false;
    end
    else
    begin
      if ti.m_spmtrend.dx=0 then
      begin
         ti.m_spmtrend.dx:= ti.m_spm.SpmDx;
      end;
    end;
  end;
  // ���������� ������
  for i := 0 to m_tagslist.Count - 1 do
  begin
    ti := TagInfo(i);
    spm := ti.m_spm;
    if spm=nil then continue;
    for j := 0 to ti.flags.Count - 1 do
    begin
      l := cTextLabel(ti.flags.Items[j]);
      l.initfont;
    end;
  end;
end;

procedure TSpmChart.FormClick(Sender: TObject);
begin
  g_SpmFactory.actchart:=self;
end;

procedure TSpmChart.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  p:cpage;
begin
  if GetKeyState(VK_CONTROL)<0 then
  begin
    if GetKeyState(Ord('3'))<0 then
    begin
      p := cpage(spmChart.activePage);
      p.cursor.visible:=not p.cursor.visible;
    end;
    if GetKeyState(VK_UP)<0 then
    begin
      testAddScale(true, true);
    end;
    if GetKeyState(VK_down)<0 then
    begin
      testAddScale(false, true);
    end;
  end;
  if GetKeyState(VK_UP)<0 then
  begin
    testAddScale(true, false);
  end;
  if GetKeyState(VK_down)<0 then
  begin
    testAddScale(false, false);
  end;
end;

procedure TSpmChart.setShowAlarms(b: boolean);
begin
  fShowAlarms := b;
  if m_hihi <> nil then
  begin
    m_hihi.visible := b;
    m_lolo.visible := b;
  end;
end;

procedure TSpmChart.setShowProfile(b: boolean);
begin
  fShowProfile := b;
  if m_profile <> nil then
    m_profile.visible := b;
end;

procedure TSpmChart.setShowWarnings(b: boolean);
begin
  fShowWarnings := b;
  if m_hi <> nil then
  begin
    m_hi.visible := b;
    m_lo.visible := b;
  end;
end;

function TSpmChart.getBand(bandname: string): tSpmBand;
var
  I: Integer;
  b:tSpmBand;
begin
  result:=nil;
  for I := 0 to m_bands.Count - 1 do
  begin
    b:=getBand(i);
    if b.m_b.name=bandname then
    begin
      result:=b;
      exit;
    end;
  end;
end;

function TSpmChart.getBand(i: integer): tSpmBand;
begin
  result:=tSpmBand(m_bands.Items[i]);
end;

procedure TSpmChart.clearbands;
var
  i:integer;
  b:tSpmBand;
begin
  for I := 0 to m_bands.Count - 1 do
  begin
    b:=getBand(i);
    b.Destroy;
  end;
  m_bands.Clear;
end;

function TSpmChart.getShowAlarms: boolean;
begin
  result := fShowAlarms;
end;

procedure TSpmChart.setShowLabels(const Value: boolean);
var
  I: Integer;
  ti:TSpmTagInfo;
begin
  fShowLabels:=value;
  for I := 0 to m_tagslist.Count - 1 do
  begin
    ti:=TagInfo(i);
    ti.setShowLabels(value);
  end;
end;

function TSpmChart.getShowLabels: boolean;
begin
  result:=fShowLabels;
end;

function TSpmChart.getShowProfile: boolean;
begin
  result := fShowProfile;
end;

function TSpmChart.getShowWarnings: boolean;
begin
  result := fShowWarnings;
end;

function correctPosX(page: cpage; x: double; var error:boolean): double;
var
  min, max: double;
begin
  error:=false;
  if page.lgX then
  begin
    min:=page.MinX;
    max:=page.MaxX;
    if (min < x) and (x < max) then
    begin
      result := LogValToLinearScale(x, p2d(min, max));
    end
    else
      error:=true;
  end
  else
  begin
    result := x;
  end;
end;

function correctPosY(aX: caxis; page: cpage; p: point2d): double;
var
  y: double;
begin
  if aX.lg then
  begin
    if (aX.min.y < p.y) and (p.y < aX.max.y) then
    begin
      y := LogValToLinearScale(p.y, p2d(aX.min.y, aX.max.y));
    end;
  end
  else
  begin
    y := p.y;
  end;
  result:=y;
end;

function correctPos(aX: caxis; page: cpage; p: point2d): point2d;
var
  x, y: double;
begin
  if page.lgX then
  begin
    if (aX.min.x < p.x) and (p.x < aX.max.x) then
    begin
      x := LogValToLinearScale(p.x, p2d(aX.min.x, aX.max.x));
    end;
  end
  else
  begin
    x := p.x;
  end;
  if aX.lg then
  begin
    if (aX.min.y < p.y) and (p.y < aX.max.y) then
    begin
      y := LogValToLinearScale(p.y, p2d(aX.min.y, aX.max.y));
    end;
  end
  else
  begin
    y := p.y;
  end;
  result := p2d(x, y);
end;

function corrcetBound(r: frect): frect;
var
  b: boolean;
begin
  result.BottomLeft.x := min(r.BottomLeft.x, r.TopRight.x, b);
  result.BottomLeft.y := min(r.BottomLeft.y, r.TopRight.y, b);
  result.TopRight.x := max(r.BottomLeft.x, r.TopRight.x, b);
  result.TopRight.y := max(r.BottomLeft.y, r.TopRight.y, b);
end;

function intersectlabel(i: integer; a: caxis; flags: tlist; l: cTextLabel;
  shift: point2d): boolean;
var
  j: integer;
  l2: cTextLabel;
  r2, r: frect;
begin
  result := false;
  r := l.boundrect;
  r.BottomLeft := SummP2(r.BottomLeft, p2(shift.x, shift.y));
  r.TopRight := SummP2(r.TopRight, p2(shift.x, shift.y));
  r := corrcetBound(r);
  for j := i - 1 downto 0 do
  begin
    l2 := cTextLabel(flags.Items[j]);
    if not l2.visible then continue;
    r2 := l2.boundrect;
    r2 := corrcetBound(r2);
    // �� ���� �� ������ �������
    if r.BottomLeft.x <= r2.TopRight.x then
    begin
      // �� ���� �� ������ �������
      if r.TopRight.y >= r2.BottomLeft.y then
      begin
        // �� ���� �� ����� �������
        if r.TopRight.x >= r2.BottomLeft.x then
        begin
          // �� ���� �� ������� �������
          if r.BottomLeft.y <= r2.TopRight.y then
            result := true;
        end;
      end;
    end;
    // ���� ���� �����������
    if result then
      exit;
  end;
end;

procedure TSpmChart.doOnZoom(sender: tobject);
begin
  UpdateLabels;
  UpdateBands;
end;


procedure TSpmChart.UpdateBands;
var
  I: Integer;
  b:tSpmBand;
  p: cpage;
  // �������� �� �������� ��������� � ���������� -1,1
  lx,lx1,lx2:double;
  r,min, max: double;
  er:boolean;
begin
  for I := 0 to m_bands.Count - 1 do
  begin
    b:=getBand(i);
    p := cpage(b.m_freqband.GetParentByClassName('cPage'));
    min:=p.MinX;
    max:=p.MaxX;
    r:=max-min;

    er:=false;
    lx:=correctPosX(p,b.m_b.m_MainFreq, er);
    if r<>0 then
    begin
      if not er then
      begin
        lx1:=correctPosX(p,b.m_b.m_resultBand.x,er);
        lx2:=correctPosX(p,b.m_b.m_resultBand.y,er);
        lx:=(2*(lx-min)/r)-1;
        lx1:=(2*(lx1-min)/r)-1;
        lx2:=(2*(lx2-min)/r)-1;

        b.m_freqband.x:=lx;
        b.m_freqband.x1:=lx-lx1;
        b.m_freqband.x2:=lx2-lx;
        if (lx>-1) and (lx<1) then
        begin
          b.m_freqband.m_LineLabel.visible:=true;
          b.m_freqband.visible:=true;
        end
        else
        begin
          b.m_freqband.m_LineLabel.visible:=false;
          b.m_freqband.visible:=false;
        end;
      end
      else
      begin
        b.m_freqband.m_LineLabel.visible:=false;
        b.m_freqband.visible:=false;
      end;
    end;
    // ������ ������ �� �������
    b.m_freqband.m_realX:=b.m_b.m_MainFreq;
    b.m_freqband.name:=b.name;
  end;
end;

function getSpmMax(spm:cspm):point2d;
begin
  case spm.m_I of
    0:result:=spm.max;
    1:result:=p2d(spm.max.x,spm.m_magI1[spm.minmax_i.y]);
    2:result:=p2d(spm.max.x,spm.m_magI2[spm.minmax_i.y]);
  end;
end;

// �������� �������� �����.
procedure TSpmChart.UpdateLabels;
var
  i, j, k, ind: integer;
  ti: TSpmTagInfo;
  l: cTextLabel;
  spm: cSpm;
  p: cpage;
  a: caxis;
  x, y, max, maxX: double;
  spmMax,pos: point2d;
  // �������� ��������� ����� ��� �������������
  percentSize: point2;
  r: frect;
  // ���������� ������ �����
  intersect: boolean;
  l_main:ctextlabel;
begin
  m_labList.Clear;
  for i := 0 to m_tagslist.Count - 1 do
  begin
    ti := TagInfo(i);
    spm := ti.m_spm;
    if spm=nil then continue;
    for j := 0 to ti.flags.Count - 1 do // ���� �� ������
    begin
      l := cTextLabel(ti.flags.Items[j]);
      a := caxis(l.GetParentByClassName('cAxis'));
      p := cpage(a.GetParentByClassName('cPage'));
      if l.data=nil then
      begin
        l_main:=l;
        spmMax:=getSpmMax(spm);
        pos := correctPos(a, p, spmMax);
        maxx:=spmmax.x;
        max:=spmmax.y;
      end
      else
      begin
        l.visible:=true;
        x:=tspmband(l.data).m_b.m_resultBand.x;
        ind:=ti.m_spm.getIndByX(x);
        if (ind<ti.m_spmtrend.count) and (ind>0) then
        begin
          max:=ti.m_spmtrend.GetYByInd(ind);
          maxx:=x;
        end
        else
        begin
          continue;
        end;
        while x<tspmband(l.data).m_b.m_resultBand.y do
        begin
          inc(ind);
          x:=ti.m_spmtrend.GetXByInd(ind);
          y:=ti.m_spmtrend.GetYByInd(ind);
          if y>max then
          begin
            max:=y;
            maxX:=x;
          end;
        end;
        pos := correctPos(a, p, p2d(maxX, max));
        for k := 0 to tspmband(l.data).m_trends.Count - 1 do
        begin
          if ti=tspmband(l.data).m_trends.Objects[k] then
          begin
            tspmband(l.data).m_freqband.setY(max, k);
            break;
          end;
        end;
      end;
      l.Position := p2(pos.x, pos.y);
      l.line := l.Position;
      l.text := format('F:%.3g', [maxx]) + format(' V:%.3g', [max]);
      m_labList.Add(l);
    end;
  end;
  m_labList.Sort(TextLabelsComparator);
  // ������������� ��������� �����
  for i := 0 to m_labList.Count - 1 do
  begin
    l := cTextLabel(m_labList.Items[i]);
    // ������� �����
    r := l.boundrect;
    percentSize.x := r.TopRight.x - r.BottomLeft.x;
    percentSize.x := percentSize.x / a.getdx;
    percentSize.y := r.TopRight.y - r.BottomLeft.y;
    percentSize.y := percentSize.y / a.getdy;
    // �������� ���������� �����
    intersect := true;
    pos := p2d(l.Position.x, l.Position.y);
    j := 1; // ����� ��������
    while intersect do
    begin
      // pos.x:=pos.x+percentSize.x*a.getdx;
      pos.y := pos.y + percentSize.y * a.getdy;
      // intersectlabel(i:integer;a:caxis;flags:tlist;l:ctextlabel;pos:point2d)
      intersect := intersectlabel(i, a, m_labList, l, p2d(0, percentSize.y * a.getdy * j));
      inc(j);
    end;
    l.Position := p2(pos.x, pos.y);
  end;
end;

procedure TSpmChart.UpdateOpts;
var
  r: frect;
  a: caxis;
  p: cpage;
begin
  p := cpage(spmChart.activePage);
  a := p.activeAxis;

  r.BottomLeft := p2(aX.x, aY.x);
  r.TopRight := p2(aX.y, aY.y);

  a.lg := lgY;
  p.lgX := lgX;

  p.ZoomfRect(r);
end;

procedure TSpmChart.UpdateSpm;
var
  ti: TSpmTagInfo;
  i: integer;
begin
  for i := 0 to m_tagslist.Count - 1 do
  begin
    ti := TagInfo(i);
    if ti = nil then
      continue;
    if ti.m_spm = nil then
      continue;
    if ti.update then
    begin
      case ti.m_spm.m_I of
        0:ti.m_spmtrend.AddPoints(tdoublearray(ti.m_spm.m_rms.p));
        1:ti.m_spmtrend.AddPoints(tdoublearray(ti.m_spm.m_magI1));
        2:ti.m_spmtrend.AddPoints(tdoublearray(ti.m_spm.m_magI2));
      end;
    end;
  end;
  UpdateLabels;
  UpdateBands;
end;

procedure TSpmChart.UpdateView;
var
  ti: TSpmTagInfo;
  i: integer;
begin
  // spmChart.activePage.caption := modname(spmChart.activePage.caption, false);
  if RStatePlay then
  begin
    UpdateSpm;
    spmChart.redraw;
  end;
end;

procedure TSpmChart.WndProc(var Message: TMessage);
begin
  inherited;
end;


procedure TSpmChart.initProfile;
var
  p: cpage;
  aX: caxis;
begin
  p:=cpage(spmChart.activePage);
  if p=nil then exit;
  
  aX := p.activeAxis;

  if m_profile = nil then
  begin
    m_profile := ctrend.create;
    m_profile.fHelper:=true;
    m_profile.layer:=1;
    aX.AddChild(m_profile);
    m_profile.enabled := false;
    m_profile.name := 'Profile';
    m_profile.color := p3(0, 1, 0);
  end;
  if m_lolo = nil then
  begin
    m_lolo := ctrend.create;
    m_lolo.fHelper:=true;
    m_lolo.layer:=1;
    m_lolo.selectable := false;
    m_lolo.name := 'LoLo';
    m_lolo.color := p3(1, 0, 0);
    aX.AddChild(m_lolo);
  end;
  if m_lo = nil then
  begin
    m_lo := ctrend.create;
    m_lo.fHelper:=true;
    m_lo.layer:=1;
    m_lo.selectable := false;
    m_lo.name := 'Lo';
    m_lo.color := Orange; // p3(1,1,0);
    aX.AddChild(m_lo);
  end;
  if m_hi = nil then
  begin
    m_hi := ctrend.create;
    m_hi.fHelper:=true;
    m_hi.layer:=1;
    m_hi.selectable := false;
    m_hi.name := 'Hi';
    m_hi.color := Orange;
    aX.AddChild(m_hi);
  end;
  if m_hihi = nil then
  begin
    m_hihi := ctrend.create;
    m_hihi.layer:=1;
    aX.AddChild(m_hihi);
    m_hihi.selectable := false;
    m_hihi.name := 'HiHi';
    m_hihi.color := p3(1, 0, 0);
  end;
  if fprofile <> nil then
    profile := fprofile;
end;


procedure TSpmChart.setProfile(p: tprofile);
var
  i: integer;
  tr: ctrend;
begin
  fprofile := p;
  if p = nil then
    exit;
  p.evalData;
  if m_profile <> nil then
  begin
    for i := 0 to p.Count - 1 do
    begin
      tr := m_profile;
      tr.fHelper:=true;
      addPointsToProfile(p.x, p.m_data, 0, tr);
      tr := m_hihi;
      tr.fHelper:=true;
      addPointsToProfile(p.x, p.m_data, 1, tr);
      tr := m_hi;
      tr.fHelper:=true;
      addPointsToProfile(p.x, p.m_data, 2, tr);
      tr := m_lo;
      tr.fHelper:=true;
      addPointsToProfile(p.x, p.m_data, 3, tr);
      tr := m_lolo;
      tr.fHelper:=true;
      addPointsToProfile(p.x, p.m_data, 4, tr);
    end;
  end;
end;

{ cControlFactory }


constructor cSpmFactory.create;
begin
  initevents:=false;
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_CHARTSPM;
  elist:=cEventList.create(self, true);
  CreateEvents;
end;

procedure TSpmChart.createEvents;
begin
  spmChart.OBJmNG.Events.AddEvent('SpmChart_OnZoom', E_OnZoom, doOnZoom);
  g_SpmFactory.CreateEvents;
end;


procedure TSpmChart.destroyEvents;
begin
  spmChart.OBJmNG.Events.removeEvent(doOnZoom, E_OnZoom);
end;

procedure cSpmFactory.CreateEvents;
begin
  if not initevents then
  begin
    if g_algMng<>nil then
    begin
      initevents:=true;
      addplgevent('cSpmFactory_doChangeRState', c_RC_DoChangeRCState, doChangeRState);
      g_algMng.Events.AddEvent('SpmChart_SpmSetProps',e_OnSetAlgProperties,doChangeAlgProps);
      addplgevent('SpmChart_OnLeaveCfg', c_RC_LeaveCfg, doChangeCfg);
    end;
  end;
end;

procedure cSpmFactory.DestroyEvents;
begin
  removeplgEvent(doChangeRState, c_RC_DoChangeRCState);
  if g_algMng<>nil then
  begin
    g_algMng.Events.removeEvent(doChangeRState, e_OnSetAlgProperties);
    removeplgEvent(doChangeCfg, c_RC_LeaveCfg);
  end;
end;

destructor cSpmFactory.destroy;
begin
  eList.destroy;
  DestroyEvents;
  g_spmfactory:=nil;
  inherited;
end;

procedure cSpmFactory.doAfterload;
begin
  CreateEvents;
end;

procedure cSpmFactory.doChangeAlgProps(Sender: TObject);
var
  I: Integer;
  sChart:TSpmChart;
  j: Integer;
  ti:TSpmTagInfo;
begin
  for I := 0 to Count - 1 do
  begin
    sChart:=TSpmChart(getfrm(i));
    for j := 0 to sChart.m_tagslist.Count - 1 do
    begin
      ti:=schart.TagInfo(j);
      if ti.m_spm=sender then
      begin
        ti.DoUpdateSpm;
      end;
    end;
  end;
end;


procedure cSpmFactory.doChangeCfg(sender:tobject);
var
  i, k: integer;
  ti: TSpmTagInfo;
  p: cpage;
  d: cDoubleCursor;
  ax:cdrawobj;
  a:cbaseobj;
  j: Integer;
  b:boolean;

  sChart:TSpmChart;
begin
  for I := 0 to Count - 1 do
  begin
    sChart:=TSpmChart(getfrm(i));
    for k := 0 to sChart.m_tagslist.Count - 1 do
    begin
      ti := sChart.TagInfo(k);
      b:=false;
      for j := 0 to g_algMng.Count - 1 do
      begin
        a:=g_algMng.getobj(j);
        if ti.m_spm=a then
        begin
          b:=true;
          break;
        end;
      end;
      if not b then
      begin
        // ������������ �� ���������
        ti.m_spm:=nil;
      end;
    end;
    for k := 0 to sChart.m_tagslist.Count - 1 do
    begin
      ti := sChart.TagInfo(k);
      if not ti.m_initGraph then
      begin
        sChart.InitGraphs(ti);
      end;
    end;
    //for k := sChart.m_tagslist.Count - 1 downto 0 do
    //begin
      //ti := sChart.TagInfo(k);
      //if ti.m_spm=nil then
      //begin
      //  ti.destroy;
      //  sChart.m_tagslist.Delete(k);
      //end;
    //end;
    sChart.ApplyBands;
  end;
end;

procedure cSpmFactory.doChangeRState(Sender: TObject);
begin
  case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
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
      end;
    RSt_RecToView:
      begin
        doStart;
      end;
  end;
end;

function cSpmFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  if m_counter < 1 then
  begin
    result := ISpmFrm.create();
  end;
end;

procedure cSpmFactory.doDestroyForms;
begin
  inherited;

end;

procedure cSpmFactory.doSetDefSize(var pSize: SIZE);
begin
  pSize.cx := c_SpmChart_defXSize;
  pSize.cy := c_SpmChart_defYSize;
end;

procedure cSpmFactory.doStart;
var
  i: integer;
  Frm: TRecFrm;
begin
  for i := 0 to m_CompList.Count - 1 do
  begin
    Frm := GetFrm(i);
    TSpmChart(Frm).doStart;
  end;
end;

function cSpmFactory.GetActiveChart: TSPMChart;
begin
  result:=factivechart;
end;

procedure cSpmFactory.doCursorMove(Sender: TObject);
begin
  eList.CallAllEventsWithSender(E_CURSMOVE, sender);
end;

procedure cSpmFactory.SetActiveChart(c: TSpmChart);
var
  b:boolean;
begin
  if factivechart<>c then
  begin
    if c.DblCursor.visible then
    begin
      factivechart:=c;
      eList.CallAllEventsWithSender(E_SETACTSPMCHART, c);
    end;
  end;
end;

{ ISpmFrm }
procedure ISpmFrm.doClose;
begin
  m_lRefCount := 1;
end;

function ISpmFrm.doCreateFrm: TRecFrm;
begin
  result := TSpmChart.create(nil);
end;

function ISpmFrm.doGetName: LPCSTR;
begin
  result := 'SpmFrm';
end;

function ISpmFrm.doRepaint: boolean;
begin
  inherited;
  TSpmChart(m_pMasterWnd).UpdateView;
end;

{ TSpmTagInfo }
constructor TSpmTagInfo.create;
begin
  flags := tlist.create;
  m_initGraph := false;
end;

destructor TSpmTagInfo.destroy;
begin
  flags.destroy;
  if m_spmtrend <> nil then
    m_spmtrend.destroy;
end;

procedure TSpmTagInfo.DoUpdateSpm;
begin
  if m_spmtrend<>nil then
  begin
    m_spmtrend.dx := m_spm.SpmDx;
    m_spmtrend.name := m_spm.name;
  end;
end;

function TSpmTagInfo.GetAlg: cBaseAlgContainer;
begin
  result:=nil;
  if m_spm<>nil then
    result:=m_spm;
end;

procedure TSpmTagInfo.setAlg(a: cBaseAlgContainer);
begin
  if a is cSpm then
  begin
    m_spm := cSpm(a);
    m_algname := cSpm(a).resname;
    m_lastblock := cSpm(a).LastBlockTime;
    m_lastblockind := cSpm(a).m_ReadyBlockCount;
  end;
end;

procedure TSpmTagInfo.setShowLabels(b: boolean);
var
  l:cTextLabel;
  i:integer;
begin
  for I := 0 to flags.Count - 1 do
  begin
    l:=cTextLabel(flags.Items[i]);
    l.visible:=b;
  end;
end;

function TSpmTagInfo.update: boolean;
begin
  if m_spm<>nil then
  begin
    result:=m_lastblockind<m_spm.m_ReadyBlockCount;
    m_lastblock:=m_spm.LastBlockTime;
    m_lastblockind:=m_spm.m_ReadyBlockCount;
  end;
end;

{ tSpmBand }

destructor tSpmBand.destroy;
begin
  if m_freqband<>nil then
  begin
    m_freqband.destroy;
  end;
  m_trends.Destroy;
end;

constructor tSpmBand.create;
begin
  m_trends:=TStringList.create;
end;


function tSpmBand.getname: string;
begin
  if m_b<>nil then
    result:=m_b.name
  else
    result:='';
end;

function tSpmBand.getObj(s: string): tobject;
var
  I: Integer;
begin
  result:=nil;
  for I := 0 to m_trends.count - 1 do
  begin
    if m_trends.Strings[i]=s then
    begin
      result:=m_trends.Objects[i];
      exit;
    end;
  end;
end;

end.
