unit uTransmisNumFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, uTagsListFrame, StdCtrls, Grids, uStringGridExt,
  ComCtrls, uCommonTypes, uCommonMath, mathfunction, uSetList,
  uModeObj, u3120ControlObj, uProgramObj,
  uComponentServises, uRCFunc, tags, uRecorderEvents, pluginClass, uBtnListView;

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
    rowname,
    mode:string;
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
    ModeLinkCb: TCheckBox;
    ModesLV: TBtnListView;
    procedure FormShow(Sender: TObject);
    procedure ChannelsSGDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ChannelsSGDblClick(Sender: TObject);
    procedure ChannelsSGDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ChannelsSGDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ChannelsSGSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure ChannelsSGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  public
    // список колонок
    m_Tags:tlist;
    // список строк
    m_States:tlist;
    m_stateVals:cIntNodeList;
    m_StateCount,
    // для отслеживания изменения передачи
    lastRes:integer;

    m_resTag:ctag;
    // текущий замер состояний вычисляемый в RunTime
    m_values:array of boolean;

    m_thresh_OverRow : Integer;
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
    procedure ShowModeList;
  public
    procedure ValsToSg;
    procedure SgToVals;
    procedure UpdateState(row:integer);
    procedure UpdateThresh(col:integer);
    procedure UpdateThreshAll;
    function GetThresh(col:integer): string;
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
  i:integer;
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
  xCol, xRow: integer; // Адрес ячейки таблицы
  s:cStateRec;
begin
  GetCursorPos(pPnt);
  pPnt := TStringGrid(Sender).ScreenToClient(pPnt);
  // Находим позицию нашей ячейки
  xCol := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).X;
  xRow := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).Y;

  if xRow>1 then
  begin
    UpdateThreshAll;
    if xRow = m_thresh_OverRow then Exit;

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
  xCol, xRow, ModeCol:integer;
  str:string;
  s:cStateRec;
begin
  xCol := TStringGrid(Sender).MouseCoord(X, Y).X;
  xRow := TStringGrid(Sender).MouseCoord(X, Y).Y;
  if source=TagsListFrame1.TagsLV then
  begin
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
  if Source=ModesLV then
  begin
    if xrow>1 then
    begin
      str:=ChannelsSG.Cells[ChannelsSG.ColCount-1, 1];
      str:=ModesLV.Selected.Caption;
      ChannelsSG.Cells[ChannelsSG.ColCount-1, xrow]:=str;
      s:=getState(xrow-2);
      s.mode:=str;
      SGChange(ChannelsSG);
    end;
  end;
end;

procedure TTransNumFrm.ChannelsSGDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  pPnt: TPoint; // Координаты курсора
  ModeCol,row,col:integer;
  s:string;
begin
  Accept:=false;
  if (Source=TagsListFrame1.TagsLV) or (Source=ModesLV) then
  begin
    if source=modesLV then
    begin
      Row := TStringGrid(Sender).MouseCoord(X, Y).y;
      if row<2 then
      begin
        Accept:=false;
        exit;
      end;
    end;
    Accept:=true;
    exit;
  end;

end;

procedure TTransNumFrm.ChannelsSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  sg: TStringGrid;
  Color: Integer;
  str: string;
  st:cstaterec;
begin
  if ARow = m_thresh_OverRow then Exit;

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

procedure TTransNumFrm.ChannelsSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  t:cTagRec;
  pPnt:tpoint;
  xCol, xRow:integer;
  val:string;
begin
  GetCursorPos(pPnt);
  pPnt := TStringGrid(Sender).ScreenToClient(pPnt);
  // Находим позицию нашей ячейки
  xCol := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).X;
  xRow := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).Y;
  if key=VK_DELETE then
  begin
    if xcol>0 then
    begin
      t:=gettag(xcol-1);
      if t<>nil then
      begin
        t.destroy;
      end;
    end;
    ShowColumns;
    updateStates;
  end;
end;

procedure TTransNumFrm.ChannelsSGSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
var
  t:cTagRec;
begin
  if acol>0 then
  begin
    if arow=m_thresh_OverRow then
    begin
      if isvalue(value) then
      begin
        t:=gettag(acol-1);
        t.thresh.x:=strtofloat(value);
      end;
    end;
  end;
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
begin
  RemovePlgEvent(doUpdateTags, c_RUpdateData);
  m_tags.Destroy;
  m_States.Destroy;
  m_resTag.destroy;
  m_stateVals.destroy;

  inherited;
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
  p:cProgramObj;
  m:cmodeobj;
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
    m_resTag.tag.PushValue(-1, -1);
  // переключение режима
  if g_conmng.state<>c_Stop then
  begin
    if ModeLinkCb.Checked then
    begin
      if lastRes<>result then
      begin
        if s.mode<>'' then
        begin
          p:=g_conmng.getProgram(0);
          m:=p.getmode(s.mode);
          if not m.active then
          begin
            m.active:=true;
          end;
        end;
      end;
    end;
  end;
  lastRes:=result;
end;

function TTransNumFrm.CreateTag(t: itag): ctagrec;
begin
  result:=CreateTag(t.GetName);
end;

function TTransNumFrm.CreateTag(s: string): cTagRec;
var
  I: Integer;
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
  ShowModeList;
end;

procedure TTransNumFrm.InitSG;
var
  r:integer;
  I, ind: Integer;
  rec:cStateRec;
begin
  //ChannelsSG.RowCount:=19;
  ChannelsSG.ColCount:=4;
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
  ChannelsSG.Cells[0,r]:='Давление больше'; m_thresh_OverRow := r; inc(r);
  ChannelsSG.RowCount:=r;
  SGchange(ChannelsSG);
  // rowCount-2 т.к. последний режим - не передача а часть интерфейса настройки порогов
  for I := 2 to ChannelsSG.RowCount-2 do
  begin
    rec:=cStateRec.create;
    rec.code:=i-2;
    m_States.Add(rec);
    ind:=m_stateVals.AddObj(rec.res);
    rec.resNode:=m_stateVals.Items[ind];
    rec.rowname:=ChannelsSG.Cells[0,i];
  end;
end;
// обновить заголовки таблицы
procedure TTransNumFrm.ShowColumns;
var
  I: Integer;
  t:cTagRec;
begin
  ChannelsSG.ColCount:=m_Tags.Count+2;
  for I := 0 to m_Tags.Count - 1 do
  begin
    t:=gettag(i);
    ChannelsSG.Cells[1+i, 1]:=t.t.tagname;
    ChannelsSG.Cells[1+i, ChannelsSG.RowCount-1]:=floattostr(t.thresh.x);
  end;
  ChannelsSG.Cells[ChannelsSG.ColCount-1, 1]:='Режим';
  SGChange(ChannelsSG);
end;

procedure TTransNumFrm.ShowModeList;
var
  I: Integer;
  li:tlistitem;
  p:cProgramObj;
  m:cModeObj;
begin
  ModesLV.Clear;
  p:=g_conmng.getProgram(0);
  if p<>nil then
  begin
    for I := 0 to p.ModeCount - 1 do
    begin
      m:=p.getmode(i);
      li:=ModesLV.Items.Add;
      li.Caption:=m.name;
    end;
  end;
end;

procedure TTransNumFrm.FromStr(s: string);
var
  I, j, res: Integer;
  state:cStateRec;
  t:cTagRec;
  str:string;
  c:integer;
begin
  j:=0;

  str:=getSubStrByIndex(s, ';', 1, j);
  ModeLinkCb.Checked:=strtobool(str);
  inc(j);

  str:=getSubStrByIndex(s, ';', 1, j);
  c:=strtoIntExt(str);
  inc(j);
  if c<1 then exit;

  clearTags;
  for I := 0 to c - 1 do
  begin
    str:=getSubStrByIndex(s, ';', 1, j);
    inc(j);
    t:=CreateTag(str);
    str:=getSubStrByIndex(s, ';', 1, j);
    inc(j);
    t.thresh.x:=StrToFloat(str);
  end;
  setlength(m_values, m_Tags.Count);
  ChannelsSG.ColCount:=m_Tags.Count+2;
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
    inc(j);
    str:=getSubStrByIndex(s, ';', 1, j);
    state.mode:=str;
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

// формат строки
// <число тегов>;<тег>;<Thresh.x>;....<число режимов>;<режим используется>;<раскодировка (число)>;....
function TTransNumFrm.tostr: string;
var
  I: Integer;
  t:cTagRec;
  s:cStateRec;
begin
  result:='';
  result:=boolToStr(ModeLinkCb.Checked)+';';
  result:=result+inttostr(m_Tags.Count)+';';


  for I := 0 to m_Tags.Count - 1 do
  begin
    t:=gettag(i);
    result:=result+t.t.tagname+';'+FloatToStr(t.thresh.x)+';';
  end;
  result:=result+inttostr(m_States.Count)+';';
  for I := 0 to m_States.Count - 1 do
  begin
    s:=getState(i);
    result:=result+booltostr(s.cb.Checked)+';';
    result:=result+inttostr(s.res)+';';
    result:=result+s.mode+';';
  end;
end;

procedure TTransNumFrm.UpdateState(row: integer);
var
  s:cStateRec;
  I, ind: Integer;
  str:string;
begin
  s:=getState(row-2);
  for I := 1 to ChannelsSG.ColCount - 2 do
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

procedure TTransNumFrm.UpdateThresh(col:integer);
var
  t:cTagRec;
  Value: Double;
begin
  t:=gettag(col);

  if t <> nil then
    begin
      if not TryStrToFloat(ChannelsSG.Cells[col+1,m_thresh_OverRow], Value) then
        begin
          if ChannelsSG.Cells[col+1,m_thresh_OverRow] = '' then
            begin
              t.thresh.x := 2;
            end
          else
            begin
              MessageBox(0, PChar('Значение "' + ChannelsSG.Cells[col+1,m_thresh_OverRow] +
                       '" не является корректным числом с плавающей точкой'), PChar('Ошибка конвертации числа'), MB_OK + MB_ICONERROR + MB_APPLMODAL + MB_TOPMOST);

              ChannelsSG.Row := m_thresh_OverRow; // Устанавливаем номер строки
              ChannelsSG.Col := col+1;            // Устанавливаем номер столбца
              ChannelsSG.SetFocus();              // Передаем фокус сетке
            end;
        end
      else
        begin
          t.thresh.x := Value;
        end;
    end;
end;

procedure TTransNumFrm.UpdateThreshAll;
var i: Integer;
begin
  for i := 0 to m_Tags.Count - 1 do UpdateThresh(i);
end;

function TTransNumFrm.GetThresh(col:integer): string;
var t:cTagRec;
begin
  t:=gettag(col);

  if t <> nil then Result:=FloatToStr(t.thresh.x);
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
        ChannelsSG.Cells[c+1,r+2]:='Выкл';

      if r+2 = m_thresh_OverRow then
        ChannelsSG.Cells[c+1,m_thresh_OverRow]:=GetThresh(c);
    end;
    ChannelsSG.Cells[ChannelsSG.ColCount-1, r+2]:=s.mode;
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

      if r+2 = m_thresh_OverRow then
        UpdateThresh(c);
    end;
  end;
end;

{ cTagRec }
constructor cTagRec.create;
begin
  t:=cTag.create;
  // по умолчанию больше двух
  thresh.x:=2;
  thresh.y:=3;
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
  i:integer;
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
