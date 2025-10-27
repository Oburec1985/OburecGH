unit uTransmisNumFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, uTagsListFrame, StdCtrls, Grids, uStringGridExt,
  ComCtrls, uCommonTypes, uCommonMath, mathfunction, uSetList,
  uComponentServises, uRCFunc, tags, uRecorderEvents, pluginClass;

type
  boolArray =  array of boolean;
  pBoolArray = ^boolArray;

  cTagRec = class
  public
    t:ctag;
    // 0 - ниже; 1 - выше; 2 - в диапазоне
    typeres:integer;
    thresh:point2d;
  public
    function eval:boolean;
    constructor create;
    destructor destroy;
  end;
  // значение тегов для данного режима
  cStateRec = class
  public
    rowname:string;
    // индекс значения синхронизирован с индексом тега в m_Tags
    b:array of boolean;
    cb:TCheckBox;
    // результат раскодировки при вып-ии encode
    res:integer;
    resNum:integer;
    // код передачи для отправки в тег
    code:integer;
    resNode:cIntNode;
    color:TColor;
  public
    procedure decode(v:integer);
    function encode:integer;
    constructor create;
    destructor destroy;
  end;

  TTransNumFrm = class(TForm)
    AlClientPan: TPanel;
    RightPan: TPanel;
    BottomPan: TPanel;
    TagsListFrame1: TTagsListFrame;
    RightSplitter: TSplitter;
    ChannelsSG: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure ChannelsSGDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ChannelsSGDblClick(Sender: TObject);
    procedure ChannelsSGDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ChannelsSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  public
    // список колонок
    m_Tags:tlist;
    // список строк
    m_States:tlist;
    m_stateVals:cIntNodeList;
    m_StateCount:integer;

    m_resTag:ctag;
    // текущий замер состояний вычисляемый в RunTime
    m_values:array of boolean;
  private
    procedure InitSG;
    function gettag(i:integer):cTagRec;overload;
    function gettag(s:string):cTagRec;overload;
    function getState(i:integer):cStateRec;overload;
    function getState(s:string):cStateRec;overload;
    function CreateTag(t:itag):cTagRec;overload;
    function CreateTag(s:string):cTagRec;overload;
    function FindTag(tname:string):integer;
    // очистка тегов (колонок)
    procedure clearTags;
    // очистка и установка длины массивов state.b
    procedure ClearValues;
    // вычисляем сколько есть уникальных состояний и вычисляем их номера
    procedure CompileStates;
    procedure updateStates;
  public
    procedure ValsToSg;
    procedure SgToVals;
    procedure UpdateState(row:integer);
    function tostr: string;
    procedure doUpdateTags(sender:tobject);
  public
    // отобразить список колонок из списка тегов
    procedure ShowColumns;
    procedure FromStr(s:string);
    function EvalStateNum:integer;
    constructor create(aowner:tcomponent);
    destructor destroy;
  end;

var
  TransNumFrm: TTransNumFrm;

const
  clGrass = TColor($00A7FED0);

implementation

function encode(b:array of boolean):integer;
var
  i,j:integer;
begin
  Result:=0;
  for I := 0 to length(b) - 1 do
  begin
    if b[i] then
    begin
      Result :=Result+ 1 shl i;
    end;
  end;
end;

procedure decode(v:integer; b:array of boolean);
var
  a:pboolarray;
  i:integer;
begin
  for I := 0 to length(b) - 1 do
  begin
    b[i]:=((v shr i) and 1)=1;
  end;
end;


{$R *.dfm}

procedure TTransNumFrm.ChannelsSGDblClick(Sender: TObject);
var
  pPnt: TPoint; // Координаты курсора
  xCol, xRow, ind: integer; // Адрес ячейки таблицы
  s:cStateRec;
  I: TPoint;
begin
  GetCursorPos(pPnt);
  pPnt := TStringGrid(Sender).ScreenToClient(pPnt);
  // Находим позицию нашей ячейки
  xCol := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).X;
  xRow := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).Y;
  if xRow>1 then
  begin
    if xCol>0 then
    begin
      s:=getState(xRow-2);
      if TStringGrid(Sender).Cells[xcol, xrow]='Вкл.' then
      begin
        TStringGrid(Sender).Cells[xcol, xrow]:='Выкл.';
        s.b[xcol-1]:=false;
      end
      else
      begin
        TStringGrid(Sender).Cells[xcol, xrow]:='Вкл.';
      end;
      UpdateState(xrow);
      CompileStates;
    end;
  end;

end;

procedure TTransNumFrm.ChannelsSGDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  li:tlistitem;
  t0,t:ctagrec;
  xCol, xRow:integer;
  str:string;
begin
  if source=TagsListFrame1.TagsLV then
  begin
    xCol := TStringGrid(Sender).MouseCoord(X, Y).X;
    xRow := TStringGrid(Sender).MouseCoord(X, Y).Y;
    t0:=nil;
    if (xCol>-1) and (xRow>-1) then
    begin
      str:=TStringGrid(Sender).cells[xcol, xrow];
      t0:=gettag(str);
    end;
    li:=TagsListFrame1.TagsLV.Selected;
    if t0<>nil then
    begin
      t0.t.tag:=nil;
      t0.t.tagname:=itag(li.data).GetName;
    end
    else
    begin
      // если таблица пустая
      while li<>nil do
      begin
        t:=CreateTag(itag(li.data));
        li:=TagsListFrame1.TagsLV.GetNextItem(li, sdAll, [isSelected]);
      end;
    end;
    ShowColumns;
    updateStates;
  end;
end;

procedure TTransNumFrm.ChannelsSGDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept:=false;
  if Source=TagsListFrame1.TagsLV then
  begin
    Accept:=true;
  end;
end;

procedure TTransNumFrm.ChannelsSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  sg: TStringGrid;
  Color: Integer;
  str: string;
  I: Integer;
  st:cstaterec;
  duplicateRow:boolean;
begin
  sg := TStringGrid(Sender);
  Color := sg.Canvas.Brush.Color;
  // окрас строки выбраного контрола
  str:=sg.Cells[acol, arow];
  if (arow=1) and (acol>0) then
  begin
    Color := sg.Canvas.Brush.Color;
    sg.Canvas.Brush.Color := clMenuBar;
    sg.Canvas.FillRect(Rect);
    sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
    sg.Canvas.Brush.Color := Color;
    Exit;
  end;
  if arow>1 then
  begin
    st:=getState(arow-2);
    if st.color<>clWindow then
    begin
      Color := sg.Canvas.Brush.Color;
      sg.Canvas.Brush.Color := st.color;
      sg.Canvas.FillRect(Rect);
      sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
      sg.Canvas.Brush.Color := Color;
      Exit;
    end;
  end;
  if str='Вкл.' then
  begin
    Color := sg.Canvas.Brush.Color;
    sg.Canvas.Brush.Color := clGrass;
    sg.Canvas.FillRect(Rect);
    sg.Canvas.TextOut(Rect.Left, Rect.Top, sg.Cells[ACol, ARow]);
    sg.Canvas.Brush.Color := Color;
  end

end;

procedure TTransNumFrm.clearTags;
var
  I: Integer;
  t:cTagRec;
begin
  for I := 0 to m_Tags.Count - 1 do
  begin
    t:=gettag(i);
    t.destroy;
  end;
  m_tags.Clear;
end;

procedure TTransNumFrm.ClearValues;
var
  I: Integer;
  s:cStateRec;
begin
  for I := 0 to m_States.Count - 1 do
  begin
    s:=cStateRec(m_States[i]);
    setlength(s.b, m_Tags.Count);
  end;
  setlength(m_values, m_Tags.Count);
  setlength(m_values, m_Tags.Count);
  ZeroMemory(m_values, m_Tags.Count);
end;

procedure TTransNumFrm.CompileStates;
var
  s:cstaterec;
  i:integer;
begin
  m_StateCount:=0;
  for i := 0 to m_States.Count - 1 do
  begin
    s:=getState(i);
    if s.color=clWindow then
    begin
      s.resNum:=m_StateCount;
      inc(m_StateCount);
    end;
  end;
end;

constructor TTransNumFrm.create(aowner: tcomponent);
var
  i:integer;
begin
  inherited;
  m_Tags:=TList.Create;
  m_States:=TList.Create;
  m_stateVals:=cIntNodeList.create;
  m_stateVals.destroydata:=true;

  m_resTag:=cTag.create;
  m_resTag.tag:=createScalar('TransmitVal', true);
  initsg;
  AddPlgEvent('TTransNumFrm_doUpdateTags', c_RUpdateData, doUpdateTags);
end;

destructor TTransNumFrm.destroy;
var
  I: Integer;
  cb:TCheckBox;
begin
  RemovePlgEvent(doUpdateTags, c_RUpdateData);
  m_tags.Destroy;
  m_States.Destroy;
  m_resTag.destroy;
  m_stateVals.destroy;
end;



procedure TTransNumFrm.doUpdateTags(sender: tobject);
begin
  EvalStateNum;
end;

function TTransNumFrm.EvalStateNum: integer;
var
  I, res: Integer;
  t:cTagRec;
  s:cStateRec;
begin
  for I := 0 to m_Tags.Count - 1 do
  begin
    t:=gettag(i);
    m_values[i]:=t.eval;
  end;
  res:=encode(m_values);
  result:=-1;
  for I := 0 to m_States.Count - 1 do
  begin
    s:=getState(i);
    if s.res=res then
    begin
      //result:=i;
      result:=s.code;
      break;
    end;
  end;
  if res<>0 then
    m_resTag.tag.PushValue(result, -1)
  else
    m_resTag.tag.PushValue(-1, -1)
end;

function TTransNumFrm.CreateTag(t: itag): ctagrec;
begin
  result:=CreateTag(t.GetName);
end;

function TTransNumFrm.CreateTag(s: string): cTagRec;
var
  I, ind: Integer;
begin
  i:=FindTag(s);
  if i=-1 then
  begin
    result:=cTagRec.create;
    Result.t.tagname:=s;
    Result.typeres:=1;
    // 2 атмосферы
    Result.thresh:=p2d(2,3);
    m_Tags.Add(result);
  end
  else
  begin
    Result:=ctagrec(m_Tags[i]);
  end;
end;

function TTransNumFrm.gettag(i: integer): ctagrec;
begin
  result:=ctagrec(m_Tags[i]);
end;

function TTransNumFrm.getState(i: integer): cStateRec;
begin
  if i>m_states.Count-1 then
  begin
    result:=nil;
  end
  else
    result:=cStateRec(m_states[i]);
end;

function TTransNumFrm.getState(s: string): cStateRec;
var
  I: Integer;
  state:cStateRec;
begin
  result:=nil;
  for I := 0 to m_states.Count - 1 do
  begin
    state:=getState(i);
    if state.rowname=s then
    begin
      result:=state;
      exit;
    end;
  end;
end;

function TTransNumFrm.gettag(s: string): ctagrec;
var
  i:integer;
begin
  i:=FindTag(s);
  if i=-1 then
    result:=nil
  else
    result:=gettag(i);
end;

function TTransNumFrm.FindTag(tname: string): integer;
var
  i:integer;
begin
  result:=-1;
  for I := 0 to m_Tags.Count - 1 do
  begin
    if ctagrec(m_Tags[i]).t.tagname=tname then
    begin
      result:=i;
      exit;
    end;
  end;
end;

procedure TTransNumFrm.FormShow(Sender: TObject);
begin
  TagsListFrame1.ShowChannels;
end;

procedure TTransNumFrm.InitSG;
var
  r:integer;
  I, ind: Integer;
  rec:cStateRec;
begin
  ChannelsSG.RowCount:=19;
  ChannelsSG.ColCount:=3;
  ChannelsSG.Cells[0,0]:='Передача';
  ChannelsSG.Cells[0,1]:='Включаемый электромагнит';
  r:=2;
  ChannelsSG.Cells[0,r]:='N';inc(r);
  ChannelsSG.Cells[0,r]:='1';inc(r);
  ChannelsSG.Cells[0,r]:='2';inc(r);
  ChannelsSG.Cells[0,r]:='3';inc(r);
  ChannelsSG.Cells[0,r]:='4';inc(r);
  ChannelsSG.Cells[0,r]:='5';inc(r);
  ChannelsSG.Cells[0,r]:='6';inc(r);
  ChannelsSG.Cells[0,r]:='ЗХ1';inc(r);
  ChannelsSG.Cells[0,r]:='ЗХ2';inc(r);
  ChannelsSG.Cells[0,r]:='ЗХ3';inc(r);
  ChannelsSG.Cells[0,r]:='Авар. вкл. 3';inc(r);
  ChannelsSG.Cells[0,r]:='Авар. вкл. 3Х2';inc(r);
  ChannelsSG.Cells[0,r]:='Прав. вмд. ПХ';inc(r);
  ChannelsSG.Cells[0,r]:='Прав. вмд. ЗХ';inc(r);
  ChannelsSG.Cells[0,r]:='Лев. вмд. ПХ';inc(r);
  ChannelsSG.Cells[0,r]:='Лев. вмд. ЗХ';inc(r);
  ChannelsSG.Cells[0,r]:='Блок ГТ';inc(r);
  SGchange(ChannelsSG);
  for I := 2 to ChannelsSG.RowCount-1 do
  begin
    rec:=cStateRec.create;
    rec.code:=i-2;
    m_States.Add(rec);
    ind:=m_stateVals.AddObj(rec.res);
    rec.resNode:=m_stateVals.Items[ind];
    rec.rowname:=ChannelsSG.Cells[0,i];
  end;
end;

procedure TTransNumFrm.SgToVals;
var
  r: Integer;
  c: Integer;
  s:cStateRec;
begin
  for r := 0 to m_States.Count - 1 do
  begin
    s:=getState(r);
    for c := 0 to m_Tags.Count - 1 do
    begin
      s.b[c]:=ChannelsSG.Cells[c+1,r+2]='Вкл';
    end;
  end;
end;

procedure TTransNumFrm.ShowColumns;
var
  I: Integer;
  t:cTagRec;
begin
  ChannelsSG.ColCount:=m_Tags.Count+1;
  for I := 0 to m_Tags.Count - 1 do
  begin
    t:=gettag(i);
    ChannelsSG.Cells[1+i, 1]:=t.t.tagname;
  end;
  SGChange(ChannelsSG);
end;

procedure TTransNumFrm.FromStr(s: string);
var
  I, j, res: Integer;
  t:cTagRec;
  state:cStateRec;
  n, next: cIntNode;
  str:string;
  c:integer;
begin
  str:=getSubStrByIndex(s, ';', 1, 0);
  c:=strtoIntExt(str);
  if c<1 then exit;

  clearTags;
  j:=1;
  for I := 0 to c - 1 do
  begin
    str:=getSubStrByIndex(s, ';', 1, j);
    inc(j);
    CreateTag(str);
  end;
  setlength(m_values, m_Tags.Count);
  str:=getSubStrByIndex(s, ';', 1, j);
  c:=strtoint(str);
  for I := 0 to c - 1 do
  begin
    state:=getState(i);
    setlength(state.b, m_Tags.Count);

    inc(j);
    str:=getSubStrByIndex(s, ';', 1, j);
    state.cb.Checked:=StrToBool(str);
    inc(j);
    str:=getSubStrByIndex(s, ';', 1, j);
    res:=StrToIntext(str);
    state.decode(res);
    state.res:=res;
  end;
  m_stateVals.Listclear;
  for I := 0 to c - 1 do
  begin
    state:=getState(i);
    // ищем объект с таким ключом
    j:=m_stateVals.Find(state.res);
    //state.resNode.i:=state.res;
    if (j=-1) and (state.res<>0) then
    begin
      state.color:=clWindow
    end
    else
      state.color:=clGray;
    j:=m_stateVals.AddObj(state.res);
    state.resNode:=cIntNode(m_stateVals.Items[j]);
  end;
  CompileStates;
  ValsToSg;
end;

function TTransNumFrm.tostr: string;
var
  I: Integer;
  t:cTagRec;
  s:cStateRec;
begin
  result:=inttostr(m_Tags.Count)+';';
  for I := 0 to m_Tags.Count - 1 do
  begin
    t:=gettag(i);
    result:=result+t.t.tagname+';';
  end;
  result:=result+inttostr(m_States.Count)+';';
  for I := 0 to m_States.Count - 1 do
  begin
    s:=getState(i);
    result:=result+booltostr(s.cb.Checked)+';';
    result:=result+inttostr(s.res)+';';
  end;
end;

procedure TTransNumFrm.UpdateState(row: integer);
var
  s:cStateRec;
  I, ind: Integer;
  str:string;
  n:cIntNode;
begin
  s:=getState(row-2);
  for I := 1 to ChannelsSG.ColCount - 1 do
  begin
    str:=ChannelsSG.Cells[i, row];
    s.b[i-1]:=str='Вкл.';
  end;
  s.encode;
  m_stateVals.RemoveObj(s.resNode);
  // ищем объект с таким ключом
  ind:=m_stateVals.Find(s.res);
  s.resNode.i:=s.res;
  if ind=-1 then
  begin
    s.color:=clWindow
  end
  else
    s.color:=clGray;
  ind:=m_stateVals.AddObj(s.resNode);
  ChannelsSG.Invalidate;
end;

procedure TTransNumFrm.updateStates;
var
  i:integer;
  state:cStateRec;
begin
  setlength(m_values, m_Tags.Count);
  for I := 0 to m_States.Count - 1 do
  begin
    state:=getState(i);
    setlength(state.b, m_Tags.Count);
  end;
end;

procedure TTransNumFrm.ValsToSg;
var
  r: Integer;
  c: Integer;
  s:cStateRec;
begin
  for r := 0 to m_States.Count - 1 do
  begin
    s:=getState(r);
    for c := 0 to m_Tags.Count - 1 do
    begin
      if s.b[c] then
        ChannelsSG.Cells[c+1,r+2]:='Вкл.'
      else
        ChannelsSG.Cells[c+1,r+2]:='Выкл'
    end;
  end;
end;

{ cTagRec }
constructor cTagRec.create;
begin
  t:=cTag.create;
end;

destructor cTagRec.destroy;
begin
  t.destroy;
end;

function cTagRec.eval: boolean;
var
  v:double;
begin
  v:=t.GetMeanEst;
  result:=false;
  case typeres of
    0:  // меньше порога
    begin
      result:=v<thresh.x;
    end;
    1:  // больше порога
    begin
      result:=v>thresh.x;
    end;
    2:
    begin
      if v>thresh.x then
      begin
        if v<thresh.y then
        begin
          result:=True;
        end;
      end;
    end;
  end;
end;
{ cStateRec }

constructor cStateRec.create;
begin
  cb:=TCheckBox.Create(nil);
  cb.Checked:=true;
  color:=clGray;
end;

procedure cStateRec.decode(v: integer);
var
  a:pboolarray;
  i:integer;
begin
  for I := 0 to length(b) - 1 do
  begin
    b[i]:=((v shr i) and 1)=1;
  end;
end;

destructor cStateRec.destroy;
begin
  cb.Destroy;
end;

function cStateRec.encode: integer;
var
  i,j:integer;
begin
  if cb.Checked then
  begin
    Result:=0;
    for I := 0 to length(b) - 1 do
    begin
      if b[i] then
      begin
        Result :=Result+ 1 shl i;
      end;
    end;
  end
  else
    result:=-1;
  res:=result;
end;

end.
