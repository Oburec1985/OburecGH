unit uDigsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  uRCFunc,
  uHardwareMath, MathFunction,
  Forms, ComCtrls,
  uRecBasicFactory,
  uRecorderEvents,
  uComponentServises,
  uChart,
  inifiles,
  upage,
  tags,
  complex,
  uBuffTrend1d,
  uCommonMath,
  uCommonTypes,
  pluginClass,
  uMeasureBase,
  uMBaseControl,
  shellapi,
  uPathMng,
  uExcel,
  uListMath,
  uSpm, uBaseAlg,
  opengl, uSimpleObjects,
  math, uAxis, uDrawObj, uDoubleCursor, uBasicTrend,
  uThresholdsFrm,
  Dialogs, ExtCtrls, StdCtrls, DCL_MYOWN, Spin, Buttons,
  // uPathMng,
  uRcCtrls, Menus, Grids;

type
  TDigColumn = class(TNamedObj)
  public
    estimate:integer;
    useThreshold:boolean;
    HH:double;
    color:tcolor;
  protected
  public
    function fullname:string;
    constructor create;
  end;


  TGroup = class(TNamedObj)
  public
    m_tags: tlist;
  protected
  public
    procedure clear;
    function addTag(t:ctag):ctag;overload;
    function addTag(s:string):ctag;overload;
    function gettag(i:integer):ctag;
    constructor create;override;
    destructor destroy;
  end;

  TDigsFrm = class(TRecFrm)
    SignalsSG: TStringGrid;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    procedure N1Click(Sender: TObject);
    procedure SignalsSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure SignalsSGSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
  private

  public
    m_FontSize, m_digits:integer;
    // Знач. цифр/ Кол-о цифр
    m_Format:boolean;
    colNames:TNamedObjList;
    glist:TNamedObjList;
  protected
    procedure ShowTagVals;
    procedure UpdateView;
    procedure setColCount(c:integer);
    function getColCount:integer;
  public
    procedure showcfg;
    property colCount:integer read getColCount Write setColCount;
    constructor create(Aowner: tcomponent); override;
    destructor destroy; override;
    procedure SaveSettings(a_pIni: TIniFile; str: LPCSTR); override;
    procedure LoadSettings(a_pIni: TIniFile; str: LPCSTR); override;
  end;

  IDigsFrm = class(cRecBasicIFrm)
  public
    function doRepaint: boolean; override;
    function doGetName: LPCSTR; override;
    procedure doClose; override;
    function doCreateFrm: TRecFrm; override;
  end;

  cDigsFrmFactory = class(cRecBasicFactory)
  public
  private
    // число дочерних компонентов
    m_counter: integer;
  protected
    procedure doDestroyForms; override;
    procedure createevents;
    procedure destroyevents;
  public
    procedure doAfterLoad; override;
    procedure doUpdateData(Sender: TObject);
    procedure doChangeRState(Sender: TObject);
    procedure doChangeCfg(Sender: TObject);
    procedure doStart;
    procedure doStop;
  public
    constructor create;
    destructor destroy; override;
    function doCreateForm: cRecBasicIFrm; override;
    procedure doSetDefSize(var PSize: SIZE); override;
  end;

var
  g_DigsFrmFactory: cDigsFrmFactory;

const
  c_Pic = 'OSC_FRM';
  c_Name = 'Цифровой формуляр';
  c_defXSize = 560;
  c_defYSize = 355;

  // ctrl+shift+G
  // ['{54C462CD-F137-4BA6-9EB5-EFD92D159DE5}']
  IID_PRESS: TGuid = (D1: $54C462CD; D2: $F137; D3: $4BA6;
    D4: ($9E, $B5, $EF, $D9, $2D, $15, $9D, $E5));

var
  DigsFrm: TDigsFrm;

implementation
uses
  uDigsFrmEdit;

procedure SetGridFocus(SGrid: TStringGrid; r, c: integer);
var
  SRect: TGridRect;
begin
  with SGrid do
  begin
    SetFocus; {Передаем фокус сетке}
    Row := r; {Устанавливаем Row/Col}
    Col := c;
    SRect.Top := r; {Определяем выбранную область}
    SRect.Left := c;
    SRect.Bottom := r;
    SRect.Right := c;
    Selection := SRect; {Устанавливаем выбор}
  end;
end;



{$R *.dfm}
{ cDigsFrmFactory }

constructor cDigsFrmFactory.create;
begin
  inherited;
  m_lRefCount := 1;
  m_counter := 0;
  m_name := c_Name;
  m_picname := c_Pic;
  m_Guid := IID_PRESS;
  createevents;
end;

destructor cDigsFrmFactory.destroy;
begin
  destroyevents;
  inherited;
end;

procedure cDigsFrmFactory.destroyevents;
begin
  RemovePlgEvent(doUpdateData, c_RUpdateData);
  RemovePlgEvent(doChangeCfg, c_RC_LeaveCfg);
  RemovePlgEvent(doChangeRState, c_RC_DoChangeRCState);
end;

procedure cDigsFrmFactory.createevents;
begin
  addplgevent('DigsFrmFact_doUpdateData', c_RUpdateData, doUpdateData);
  addplgevent('DigsFrmFact_doChangeRState', c_RC_DoChangeRCState,
    doChangeRState);
  addplgevent('DigsFrmFact_doChangeRState', c_RC_LeaveCfg, doChangeCfg);
end;

procedure cDigsFrmFactory.doAfterLoad;
begin
  inherited;

end;

procedure cDigsFrmFactory.doChangeCfg(Sender: TObject);
begin

end;

procedure cDigsFrmFactory.doChangeRState(Sender: TObject);
begin
  case GetRCStateChange of
    RSt_Init:
      begin
        doStart;
        doStop;
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
        doStop;
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
        doStop;
      end;
    RSt_RecToView:
      begin
        doStart;
      end;
  end;
end;

function cDigsFrmFactory.doCreateForm: cRecBasicIFrm;
begin
  result := nil;
  result := IDigsFrm.create();
  inc(m_counter);
end;

procedure cDigsFrmFactory.doDestroyForms;
begin
  inherited;

end;

procedure cDigsFrmFactory.doSetDefSize(var PSize: SIZE);
begin
  inherited;
  PSize.cx := c_defXSize;
  PSize.cy := c_defYSize;
end;

procedure cDigsFrmFactory.doStart;
begin

end;

procedure cDigsFrmFactory.doStop;
begin

end;

procedure cDigsFrmFactory.doUpdateData(Sender: TObject);
begin

end;

{ IDigsFrm }

procedure IDigsFrm.doClose;
begin
  m_lRefCount := 1;
end;

function IDigsFrm.doCreateFrm: TRecFrm;
begin
  result := TDigsFrm.create(nil);
end;

function IDigsFrm.doGetName: LPCSTR;
begin
  result := c_Name;
end;

function IDigsFrm.doRepaint: boolean;
begin
  TDigsFrm(m_pMasterWnd).UpdateView;
end;

{ TGroup }

function TGroup.addTag(t: ctag): ctag;
var
  I: Integer;
begin
  result:=t;
  for I := 0 to m_tags.Count - 1 do
  begin
    if m_tags.items[i]=t then
      exit;
  end;
  m_tags.Add(t);
end;

function TGroup.addTag(s: string): ctag;
var
  I: Integer;
  t, lt:ctag;
begin
  t:=nil;
  for I := 0 to m_tags.Count - 1 do
  begin
    lt:=ctag(m_tags.items[i]);
    if lt.tagname=s then
    begin
      t:=lt;
      break;
    end;
  end;
  if t=nil then
  begin
    t:=cTag.create;
    t.tagname:=s;
  end;
  m_tags.Add(t);
end;

procedure TGroup.clear;
var
  I: Integer;
  t:ctag;
begin
  for I := 0 to m_tags.Count - 1 do
  begin
    t:=gettag(i);
    t.destroy;
  end;
  m_tags.Clear;
end;

constructor TGroup.create;
begin
  inherited;
  m_tags := TList.create;
end;

destructor TGroup.destroy;
var
  i:integer;
begin
  if owner<>nil then
  begin
    if owner.find(name,i) then
    begin
      owner.Delete(i);
    end;
  end;
  m_tags.destroy;
  inherited;
end;

function TGroup.gettag(i: integer): ctag;
begin
  result:=nil;
  if i<0 then exit;
  if i<m_tags.Count then
  begin
    result:=ctag(m_tags.items[i]);
  end;
end;

{ TDigsFrm }
constructor TDigsFrm.create;
begin
  inherited;
  m_digits:=4;
  glist:=TNamedobjList.Create;
  glist.cl:=TGroup;
  glist.sorted:=false;
  colNames:=TNamedobjList.Create;
  colNames.Sorted:=false;
  colNames.Duplicates:=dupAccept;
  colNames.cl:=TDigColumn;
end;

destructor TDigsFrm.destroy;
begin
  glist.Destroy;
  colNames.destroy;
  inherited;
end;

function TDigsFrm.getColCount: integer;
begin
  result:=colNames.Count;
end;

procedure TDigsFrm.LoadSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i, j, k: integer;
  col:TDigColumn;
  g:TGroup;
  s, s1:string;
  t:ctag;
begin
  inherited;
  m_Format:=a_pIni.ReadBool(str, 'DigFormat', False);
  m_FontSize:=a_pIni.ReadInteger(str, 'FSize', 0);
  m_Digits:=a_pIni.ReadInteger(str, 'Digits', 4);
  j:=a_pIni.ReadInteger(str, 'GCount', 0);
  for I := 0 to j - 1 do
  begin
    s:=a_pIni.ReadString(str, 'GName_'+inttostr(i), '');
    g:=TGroup(glist.Add(s));
    s:=a_pIni.ReadString(str, 'GTags_'+inttostr(i), s);
    k:=0;
    s1:=s;
    while checkstr(s1) do
    begin
      s1:=getSubStrByIndex(s,';',1,k);
      inc(k);
      g.addTag(s1);
    end;
  end;
  j:=a_pIni.ReadInteger(str, 'ColCount', 0);
  for I := 0 to j-1 do
  begin
    s:=a_pIni.ReadString(str, 'CName_'+inttostr(i), '');
    col:=tdigcolumn(colNames.Add(s));
    col.estimate:=a_pIni.ReadInteger(str, 'CEst_'+inttostr(i), 0);
    if col.estimate<0 then
      col.estimate:=0;

    col.useThreshold:=a_pIni.ReadBool(str, 'CUseThresh_'+inttostr(i), false);
    col.color:=a_pIni.ReadInteger(str, 'CColor_'+inttostr(i), clpink);
    if col.color=0 then
      col.color:=clpink;
    col.HH:=readFloatFromIni(a_pIni,str, 'CThresh_'+inttostr(i));
  end;
  showcfg;
end;

procedure TDigsFrm.SaveSettings(a_pIni: TIniFile; str: LPCSTR);
var
  i: integer;
  col:TDigColumn;
  g:TGroup;
  s:string;
  j: Integer;
  t:ctag;
begin
  inherited;
  a_pIni.WriteBool(str, 'DigFormat', m_Format);
  a_pIni.WriteInteger(str, 'FSize', m_FontSize);
  a_pIni.WriteInteger(str, 'Digits', m_Digits);
  a_pIni.WriteInteger(str, 'GCount', glist.Count);
  a_pIni.WriteInteger(str, 'ColCount', colNames.Count);
  for I := 0 to colNames.Count-1 do
  begin
    col:=tdigcolumn(colNames.Get(i));
    a_pIni.WriteString(str, 'CName_'+inttostr(i), col.name);
    a_pIni.WriteInteger(str, 'CEst_'+inttostr(i), col.estimate);
    a_pIni.WriteBool(str, 'CUseThresh_'+inttostr(i), col.useThreshold);
    a_pIni.WriteFloat(str, 'CThresh_'+inttostr(i), col.HH);
    a_pIni.WriteInteger(str, 'CColor_'+inttostr(i), col.color);
  end;
  for I := 0 to glist.Count-1 do
  begin
    g:=tgroup(glist.Get(i));
    a_pIni.WriteString(str, 'GName_'+inttostr(i), g.name);
    s:='';
    for j := 0 to g.m_tags.Count - 1 do
    begin
      t:=g.gettag(j);
      s:=s+t.tagname+';';
    end;
    a_pIni.WriteString(str, 'GTags_'+inttostr(i), s);
  end;
end;

procedure TDigsFrm.N1Click(Sender: TObject);
begin
  DigsFrmEdit.Edit(self);
end;


procedure TDigsFrm.setColCount(c: integer);
var
  col:TDigColumn;
begin
  if c>colNames.Count then
  begin
    while c>colNames.Count do
    begin
      colNames.Add('c_'+inttostr(colNames.Count));
    end;
  end
  else
  begin
    while c<colNames.Count do
    begin
      col:=TDigColumn(colNames.Get(colNames.Count-1));
      col.destroy;
    end;
  end;
  SignalsSG.ColCount:=c;
end;

procedure TDigsFrm.showcfg;
var
  I, j: Integer;
  g: tgroup;
  c:tdigcolumn;
  t:ctag;
begin
  signalsSG.Font.Size:=m_FontSize;
  if glist.Count<1 then
    SignalsSG.RowCount:=2
  else
    SignalsSG.RowCount:=glist.Count+1;
  if colNames.Count<1 then
    SignalsSG.ColCount:=2
  else
    SignalsSG.ColCount:=colNames.Count+1;
  for I := 0 to colNames.Count - 1 do
  begin
    c:=tdigcolumn(colNames.Get(i));
    SignalsSG.Cells[i+1,0]:=c.fullname;
  end;
  for I := 0 to gList.Count - 1 do
  begin
    g:=tgroup(gList.Get(i));
    SignalsSG.Cells[0,i+1]:=g.name;
  end;
  SGChange(SignalsSG);
end;

procedure TDigsFrm.ShowTagVals;
var
  I: Integer;
  j: Integer;
  g:tgroup;
  c:TDigColumn;
  t:ctag;
  s, f:string;
  v:double;
begin
  for I := 0 to glist.Count-1 do
  begin
    g:=tgroup(glist.Get(i));
    for j := 0 to g.m_tags.Count - 1 do
    begin
      t:=g.gettag(j);
      c:=TDigColumn(colNames.Get(j));
      if t.tag<>nil then
      begin
        case c.estimate of
          0:v:=getmean(t.tag);
          1:v:=getamp(t.tag);
          2:v:=GetPkPk(t.tag);
          3:v:=GetRMSD(t.tag)
        end;
        if m_Format then
        begin
          f:='%.' +inttostr(m_digits)+'f';
          s:=format(f, [v]);
        end
        else
          s:=formatstrNoE(v, m_digits);
        SignalsSG.Cells[j+1, i+1]:=s;
      end;
    end;
  end;
end;

procedure TDigsFrm.SignalsSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  g:TGroup;
  t:cTag;
  b:boolean;
  a:TAlarms;
  s:string;
  c:integer;
  col:TDigColumn;
  bAlarm, bColThreshold:boolean;
  v:double;
begin
  bColThreshold:=false;
  Color := SignalsSG.Canvas.Brush.Color;
  t:=nil;
  if ThresholdFrm<>nil then
  begin
    if arow>0 then
    begin
      if acol>0 then
      begin
        bAlarm:=false;
        g:=tgroup(glist.Get(arow-1));
        if g<>nil then
        begin
          t:=g.gettag(acol-1);
          if t<>nil then
          begin
            a:=ThresholdFrm.getalarm(t.tagname);
            if a<>nil then
            begin
              if a.notValid then
              begin
                SignalsSG.Canvas.Brush.Color := a.notValidCol;
              end
              else
              if a.activeA<>nil then
              begin
                a.activeA.GetColor(c);
                SignalsSG.Canvas.Brush.Color := c;
                bAlarm:=true;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  if acol>0 then
  begin
    if not bAlarm then
    begin
      if t<>nil then
      begin
        if t.tag<>nil  then
        begin
          col:=TDigColumn(colNames.Get(acol-1));
          if col<>nil then
          begin
            case col.estimate of
              0:v:=getmean(t.tag);
              1:v:=getamp(t.tag);
              2:v:=GetPkPk(t.tag);
              3:v:=GetRMSD(t.tag)
            end;
            if col.useThreshold then
            begin
              if v>col.HH then
              begin
                bColThreshold:=true;
                SignalsSG.Canvas.Brush.Color := col.color;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  if (gdSelected in State) then
  begin
    if not (bColThreshold or bAlarm) then
    begin
      SignalsSG.Canvas.Brush.Color := clwindow;
      SignalsSG.Canvas.Font.Color:=clBlack;
    end;
  end;
  SignalsSG.Canvas.FillRect(Rect);
  SignalsSG.Canvas.TextOut(Rect.Left, Rect.Top, SignalsSG.Cells[ACol, ARow]);
  SignalsSG.Canvas.Brush.Color := Color;
end;

procedure TDigsFrm.SignalsSGSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  SetGridFocus(SignalsSG,0,0);
end;

procedure TDigsFrm.UpdateView;
begin
  ShowTagVals;
  //SGChange(SignalsSG);
end;

{ TDigColumn }
constructor TDigColumn.create;
begin
  useThreshold:=false;
  HH:=10;
  color:=clPink;
  estimate:=0;
end;

function TDigColumn.fullname: string;
var
  s:string;
begin
  case estimate of
    0: s:='m';
    1: s:='Pk';
    2: s:='Pk-Pk';
    3: s:='Rms';
  end;
  result:=name+', '+s;
end;


end.
