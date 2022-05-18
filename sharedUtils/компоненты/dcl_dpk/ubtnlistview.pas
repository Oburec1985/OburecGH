// В Delphi7 кнопка в колонке BtnCol отрисовывается неверно при изменении
// размеров колонок. В Dev Stud. этой проблеммы нет. Функция отрисовки
// кнопки вынесена в модуль uAddConstForm
unit uBtnListView;

interface
uses
  Windows,  SysUtils, Classes, Graphics, Dialogs,
  ComCtrls, controls, CommCtrl, StdCtrls
  //,DesignIntf
  //,QDialogs
  ;
  type
    TClickItemEvent = procedure (item:TListItem; lv:TListView) of object;
    TGetColor = function (li:tlistitem):integer;

  cColorItem = class
  public
    index:integer;
    color:integer;
  end;

  type
  TBtnListView = class(TListView)
  public
    defcolor:tcolor;
    getcolor:TGetColor;
    colorlist:tlist;
  protected
    // элемент для редактирования ячейки ListView
    Edit1:TEdit;
    Item_edit:tlistitem;
    Sub_edit:integer;

    fChangeTextColor,
    fDrawColorBox:boolean;
    FOnColumnBtnClick:TClickItemEvent;
    FOnDblClickProcess:TClickItemEvent;
    mBtnCol:integer;
    m_bQuoteBtn:boolean;
    m_bQuoteDblClick:boolean;
    // позволяет редактировать ячейки
    fEditable:boolean;
  protected
    // события для добавления редактора ячейки
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure SetParent(AParent: TWinControl); override;
  private
    procedure drawColorBoxInLI(var li:TListItem;color:integer);
    //procedure advancedCustomDraw(Sender: TCustomListView; Item: TListItem;
    //          State: TCustomDrawState; Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure DoDblClickProcess(Item: TListItem; lv:TListView);
    procedure DoColumnBtnClick(Item: TListItem; lv:TListView);
    function CustomDrawItem(Item: TListItem; State: TCustomDrawState;
      Stage: TCustomDrawStage): Boolean; override;
    // Отрисовка кнопок на теле контрола
    function CustomDrawSubItem(Item: TListItem; SubItem: Integer;
             State: TCustomDrawState; Stage: TCustomDrawStage): Boolean;override;
   // Выставляет флаг произвольного рисования
    function IsCustomDrawn(Target: TCustomDrawTarget;
             Stage: TCustomDrawStage): Boolean;override;
    // Считать значение колонки кнопки
    function  ReadBtnCol:integer;
    // Записать значение колонки кнопки
    procedure WriteBtnCol(pBtnCol:integer);
    // В переопределенном колумн клике вызывается сортировка элементов
    procedure ColClick(Column: TListColumn); override;
    // Переопределен клик чтоб выделить нажатие по колумн кнопке
    procedure DblClick; override;
    // Переопределен клик чтоб выделить нажатие по колумн кнопке
    procedure Click; override;
  public
    mBtnClicked:boolean;
    constructor Create(AOwner: TComponent); override;
    destructor destroy; override;

    // получить значения SubItem по Item и имени колонки
    function GetSubItemByColumnName(const ColName:string;const li:TListItem;var Name:string):boolean;
    // установить значение в SubItem по имени колонки
    function SetSubItemByColumnName(const ColName:string;const Name:string; var li:TListItem):boolean;
    procedure columndrag(sender:tobject);
    procedure addColorItem(ind,color:integer);
    procedure DelColorItem(ind:integer);
    procedure clearcolors;
  published
    // Событие колумн клик
    property OnDblClickProcess:TClickItemEvent read FOnDblClickProcess write FOnDblClickProcess;
    // Событие колумн клик
    property OnColumnBtnClick:TClickItemEvent read FOnColumnBtnClick write FOnColumnBtnClick;
    // Номер колонки в которой рисуется кнопка
    property BtnCol: integer read ReadBtnCol write WriteBtnCol;
    // Спрашивать подтверждение нажатия кнопки?
    property QuoteColumnBtnClick:boolean read m_bQuoteBtn write m_bQuoteBtn;
    // Спрашивать подтверждение нажатия кнопки?
    property QuoteColumnDblClick:boolean read m_bQuoteDblClick write m_bQuoteDblClick;
    property DrawColorBox:boolean read fDrawColorBox write fDrawColorBox;
    property ChangeTextColor:boolean read fChangeTextColor write fChangeTextColor;
    property Editable:boolean read fEditable write fEditable;
  end;

implementation


procedure TBtnListView.DelColorItem(ind:integer);
var
  c, res:ccoloritem;
  I: Integer;
begin
  res:=nil;
  for I := 0 to colorlist.Count - 1 do
  begin
    c:=colorlist.Items[i];
    if c.index=ind then
    begin
      res:=c;
      break;
    end;
  end;
  if res<>nil then
  begin
    res.Destroy;
    colorlist.Delete(i);
  end;
end;

procedure TBtnListView.addColorItem(ind,color:integer);
var
  c, res:ccoloritem;
  I: Integer;
begin
  res:=nil;
  for I := 0 to colorlist.Count - 1 do
  begin
    c:=colorlist.Items[i];
    if c.index=ind then
    begin
      res:=c;
      break;
    end;
  end;
  if res=nil then
  begin
    c:=cColorItem.Create;
    c.index:=ind;
    c.color:=color;
    colorlist.Add(c);
  end
  else
  begin
    c:=res;
    c.color:=color;
  end;
end;

procedure TBtnListView.clearcolors;
var
  I: Integer;
  c:cColorItem;
begin
  for I := 0 to colorList.Count - 1 do
  begin
    c:=cColorItem(colorlist.Items[i]);
    c.Destroy;
  end;
  colorlist.Clear;
end;

procedure TBtnListView.columndrag(sender:tobject);
begin
  Invalidate;
end;

function TBtnListView.GetSubItemByColumnName(const ColName:string;const li:TListItem;var Name:string):boolean;
var
  colNumber:integer;
  function GetColumnNumber(const ColName:string;var colNumber:integer):bool;
  var i:integer;
  begin
    Result:=false;
    for i:=0 to TBtnListView(Self).Columns.Count-1 do
    begin
      if ColName=TBtnListView(Self).Columns[i].Caption then
      begin
        Result:=true;
        colNumber:=i;
        exit;
      end;
    end;
  end;
begin
  Result:=False;
  if GetColumnNumber(colName,colNumber) then
  begin
    if ColNumber = 0 then
    begin
      Name:=li.Caption;
      Result:=true;
    end
    else
    begin
      Result:=true;
      if ColNumber<=li.SubItems.Count then
        Name:=li.SubItems.Strings[ColNumber-1]
      else
      Result:=false;
    end;
  end;
end;

function TBtnListView.SetSubItemByColumnName(const ColName:string;const Name:string; var li:TListItem):boolean;
var
  colNumber,ind:integer;
  str:string;
  function GetColumnNumber(const ColName:string;var colNumber:integer):bool;
  var i:integer;
  begin
    Result:=false;
    for i:=0 to TBtnListView(Self).Columns.Count-1 do
    begin
      if ColName=TBtnListView(Self).Columns[i].Caption then
      begin
        Result:=true;
        colNumber:=i;
        exit;
      end;
    end;
  end;
begin
  Result:=false;
  if GetColumnNumber(colName,colNumber) then
  begin
    if ColNumber = 0 then
      li.Caption:=Name
    else
    begin
      while li.SubItems.Count<colNumber do
            ind:=li.SubItems.Add('1');
      li.SubItems.Strings[colNumber-1]:=Name;
    end;
    Result:=true;
    exit;
  end;
  showmessage('Не найдена колонка с именем '+ColName+' в ListView: '+name);
end;

procedure TBtnListView.DoDblClickProcess(Item: TListItem; lv:TListView);
begin
  if Assigned(FOnDblClickProcess) then
    FOnDblClickProcess(item, self);
end;

function GetListItem(sender:TObject):TListItem;
var P,P1:TPoint;
    y:integer;
    li:TListItem;
begin
  GetCursorPos(P);
  P1:=TBtnListView(sender).ScreenToClient(P);
  ScreenToClient(TBtnListView(sender).Handle,P);
  y:=p.y;
  Result:=TListView(Sender).GetItemAt(TListView(Sender).TopItem.Position.X,Y);
end;


procedure TBtnListView.DblClick;
var ExecuteDblClickEvent:boolean;
    li:TListItem;
begin
  ExecuteDblClickEvent:=true;
  if Items.Count=0 then
  begin
    exit;
  end;
  li:=GetListItem(self);
  if li<>nil  then
  begin
    li.Selected:=true;
    if m_bQuoteDblClick then
      ExecuteDblClickEvent:=(MessageDlg('Редактировать датчик?',mtConfirmation,MbYesNo,0) = 3);
    if ExecuteDblClickEvent then
    begin
      DoDblClickProcess(li , self);
    end;
  end;
  if not ExecuteDblClickEvent then
    inherited;
end;

procedure TBtnListView.DoColumnBtnClick(Item: TListItem;lv:TListView);
begin
  if Assigned(FOnColumnBtnClick) then
     OnColumnBtnClick(item,self);
end;

function TBtnListView.IsCustomDrawn(Target: TCustomDrawTarget;
          Stage: TCustomDrawStage): Boolean;
begin
  Result:= inherited IsCustomDrawn(Target,Stage);

  if (Stage = cdPrePaint) and (Target =dtSubItem) or
     (Target =dtItem)and (Stage = cdPostPaint) or
     (Stage = cdPreErase) or (Stage = cdPostErase) then
    result:=true;
end;


// Нарисовать ColorBox
procedure TBtnListView.drawColorBoxInLI(var li:TListItem;color:integer);
var
  Rect:TRect;
  settings:integer;
  col,
  uItemState:integer;
  procedure getRectByColIndex(var Rect:TRect;lv:tbtnlistview;column:integer);
  var i:integer;
  begin
    for i:=0 to column-1 do
    begin
      Rect.Left:=Rect.Left + lv.Column[i].Width;
    end;
    Rect.Right:=Rect.Left + lv.Column[column].Width;
  end;
begin
  if li.Selected then
  begin

  end;
  // Определить координаты (где рисуем)
  Rect:=li.DisplayRect(drBounds);
  getRectByColIndex(Rect,self,0);
  rect.Left:=rect.Right-abs(rect.Bottom-rect.top);
  //--------- Сделать заливку цветом кнопки
  col:=Canvas.Brush.Color;
  Canvas.Brush.Color:=color;
  Canvas.FillRect(Rect);
  //--------- Контуры квадрата
  Canvas.Brush.Color:=clBlack;
  Canvas.MoveTo(Rect.Left,Rect.Bottom-1);
  Canvas.LineTo(Rect.Right,Rect.Bottom-1);
  Canvas.LineTo(Rect.Right,Rect.Top);
  // -------- Отрисовка верхних контуров кнопки
  Canvas.Brush.Color:=clBlack;
  Canvas.MoveTo(Rect.Left,Rect.Bottom-1);
  Canvas.LineTo(Rect.Left,Rect.Top);
  Canvas.LineTo(Rect.Right,Rect.Top);
  //--------- Вернуть исходный цвет
  Canvas.Brush.Color:=col;
end;

// Нарисовать кнопку в 6-й колонке ListView
procedure drawButtonOnListItem(var li:TListItem;var LV:TCustomListView);
var
  Rect:TRect;
  Color:TColor;
  settings:integer;
  procedure getRectByColIndex(var Rect:TRect;column:integer);
  var i:integer;
  begin
    for i:=0 to column-1 do
    begin
      Rect.Left:=Rect.Left + TBtnListView(LV).Column[i].Width;
    end;
    Rect.Right:=Rect.Left + TBtnListView(LV).Column[column].Width;
  end;
begin
  // Определить координаты (где рисуем)
  Rect:=li.DisplayRect(drBounds);
  getRectByColIndex(Rect,TBtnListView(LV).ReadBtnCol);
  //--------- Сделать заливку цветом кнопки
  Color:=LV.Canvas.Brush.Color;
  LV.Canvas.Brush.Color:=clLtGray;
  LV.Canvas.FillRect(Rect);
  //--------- Контуры кнопки.
  LV.Canvas.Brush.Color:=clBlack;
  LV.Canvas.MoveTo(Rect.Left,Rect.Bottom-2);
  LV.Canvas.LineTo(Rect.Right-1,Rect.Bottom-2);
  LV.Canvas.LineTo(Rect.Right-1,Rect.Top);
  // -------- Отрисовка верхних контуров кнопки
  if TBtnListView(LV).mBtnClicked and li.Selected then
  begin
    LV.Canvas.Brush.Color:=clBlack;//clgray;
    LV.Canvas.MoveTo(Rect.Left+1,Rect.Bottom-2);
    LV.Canvas.LineTo(Rect.Left+1,Rect.Top);
    LV.Canvas.LineTo(Rect.Right-1,Rect.Top);
  end;
  //--------- Вернуть исходный цвет
  LV.Canvas.Brush.Color:=Color;
end;

function TBtnListView.CustomDrawItem(Item: TListItem; State: TCustomDrawState;
         Stage: TCustomDrawStage): Boolean;
var
  I: Integer;
  c:cColorItem;
begin
  result:=inherited CustomDrawItem(Item, State, Stage);
  if stage=cdPostPaint then
  begin
    if DrawColorBox then
    begin
      if assigned(getcolor) then
        drawColorBoxInLi(item,getcolor(item));
    end;
  end;
  if ChangeTextColor then
  begin
    if stage=cdPrePaint then
    begin
      if assigned(getcolor) then
      begin
        //Canvas.Brush.Color:=getcolor(item);
        Canvas.Font.color:=getcolor(item);
      end
      else
        showmessage('необходимо компоеннту назначить Getcolor');
    end;
    if (stage=cdPostpaint) then
    begin
      if assigned(getcolor) then
      begin
        //Canvas.Brush.Color:=getcolor(item);
        //Canvas.Brush.color:=defcolor;
      end
      else
        showmessage('необходимо компоеннту назначить Getcolor');
    end;
  end;
  if (not (cdsSelected in State)) and (not (cdsFocused in State)) and (not (cdsHot in state)) then
  begin
    for I := 0 to ColorList.Count - 1 do
    begin
      c:=ccoloritem(colorlist.Items[i]);
      if c.index=item.Index then
      begin
        Canvas.Brush.Color := c.color;
        //Canvas.FillRect(Item.DisplayRect(drLabel));
        //Canvas.TextOut(Item.DisplayRect(drLabel).Left,Item.DisplayRect(drLabel).Top, Item.Caption);
        break;
      end;
    end;
  end;
end;

procedure TBtnListView.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then // кнопка Enter
  begin
    if Item_edit<>nil then
    begin
      Item_edit.SubItems[Sub_edit] := Edit1.Text;
    end;
    Edit1.Visible := False;
  end;
end;

procedure TBtnListView.SetParent(AParent: TWinControl);
begin
  inherited;
  if Edit1<>nil then
  begin
    if edit1.parent=nil then
    begin
      Edit1.Parent:=AParent;
      Edit1.Visible:=false;
    end;
  end;
end;

procedure TBtnListView.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  R : TRect;
  ht : TLVHitTestInfo;

begin
  if Editable then
  begin
    inherited;
    Item_edit := GetItemAt(2, Y);
    if Item_edit = nil then
      Exit;

    FillChar(ht, SizeOf(ht), 0);
    ht.pt.x := X;
    ht.pt.y := Y;
    SendMessage(Handle, LVM_SUBITEMHITTEST, 0, Integer(@ht));
    Sub_edit := ht.iSubItem;
    if Sub_edit > 0 then
    begin
      ListView_GetSubItemRect(Handle, Item_edit.Index, Sub_edit, LVIR_BOUNDS, @R);
      Offsetrect(R, Left, Top);
      Edit1.SetBounds(R.Left+2, R.Top-2, R.Right-R.Left, R.Bottom-R.Top+4);
      Dec(Sub_edit);
      Edit1.Visible := true;
      Edit1.Text := Item_edit.SubItems[Sub_edit];
      //Edit1.SetFocus;
    end;
  end
  else
    inherited;
end;


function TBtnListView.CustomDrawSubItem(Item: TListItem; SubItem: Integer;
         State: TCustomDrawState; Stage: TCustomDrawStage): Boolean;
var
  Rect:TRect;
  Color:TColor;
  ownState:TownerDrawState;
begin
  if SubItem = ReadBtnCol then
  begin
    drawButtonOnListItem(item,TCustomListView(self));
  end
  else
  begin
    result:= inherited CustomDrawSubItem(Item,SubItem,State,Stage);

    //Rect:=item.DisplayRect(drBounds);
    //customDraw(Rect,Stage);

    //drawItem(item,Rect,ownState);
  end;
end;

// Определение нажатия по ListView
procedure TBtnListView.Click;
var P,P1:TPoint;
    x,y:integer;
    li:TListItem;
    ExecuteBtn:boolean;
    function GetColumn(x:integer):integer;
    var Col,i,ColumnStartX:integer;
    begin
      ColumnStartX:=TListView(Self).Column[0].Width;
      Col:=0; // В эту переменную пишется номер выбраной колонки
      for i:=1 to TListView(Self).Columns.Count-1 do
      begin
        if x<ColumnStartX then break;
        ColumnStartX:=ColumnStartX + TListView(Self).Column[i].Width;
        if x<ColumnStartX then
        begin
          col:=i;
          break;
        end;
      end;
      Result:=Col;
    end;
begin
  ExecuteBtn:=false;
  GetCursorPos(P);
  P:=ScreenToClient(P);
  x:=p.x;
  y:=p.y;
  // Проверка числа строк, чтоб не было ошибки.
  if TListView(Self).Items.Count=0 then exit
  else
    li:=TListView(Self).GetItemAt(TListView(Self).TopItem.Position.X,Y);
  if li<>nil  then
  begin
    li.Selected:=true;
    // Определяем номер колонки по которой щелкнули
    if GetColumn(x) = TBtnListView(Self).ReadBtnCol then
    begin
      ExecuteBtn:=true;
      TBtnListView(Self).mBtnClicked:=true; // рисовать кнопку нажатой
      if QuoteColumnBtnClick then
         ExecuteBtn:=(MessageDlg('Удалить датчик?',mtConfirmation,MbYesNo,0) = 3);
      if ExecuteBtn then
      begin
        DoColumnBtnClick(li, self);
      end;
      TBtnListView(Self).mBtnClicked:=false; // рисовать кнопку нажатой
      TListView(Self).Repaint;
    end;
  end;
  if not ExecuteBtn then
     inherited;
end;

// Процедура сортировки колонок TListView
function SortTListView(Item1, Item2: TListItem; Data: integer):integer; stdcall;
  function SortColumn(Item1, Item2: TListItem; Data: integer):integer;
  var
    i:integer;
    s1,s2:string;
  begin
    result:=0;
    if data=0 then
    begin
      s1:=Item1.caption;
      s2:=Item2.caption;
    end
    else
    begin
      if Data<Item1.SubItems.Count then
      begin
        s1:=Item1.SubItems[Data-1];
        s2:=Item2.SubItems[Data-1];
        i:=AnsiCompareStr(s1,s2);
        if i > 0 then
          Result := 1
        else if i < 0 then
          Result := -1
        else
          Result := 0;
      end;
    end;
  end;
begin
  Result:=SortColumn(Item1,Item2,Data);
end;

procedure TBtnListView.ColClick(Column: TListColumn);
begin
  CustomSort(@SortTListView, Column.Index);
  inherited ColClick(Column);
end;

// ------------- Чтение и запись значения в свойство BtnCol
function TBtnListView.ReadBtnCol:integer;
begin
  Result:=mBtnCol;
end;

procedure TBtnListView.WriteBtnCol(pBtnCol:integer);
begin
  if Columns.Count>=pBtnCol then
    mBtnCol:=pBtnCol;
end;

// --------------------------- Конструктор
Constructor TBtnListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  defcolor:=Canvas.Brush.Color;
  colorlist:=TList.Create;
  AutoSize:=false;
  RowSelect:=true;
  DrawColorBox:=false;
  ViewStyle:=vsReport;
  m_bQuoteBtn:=false;
  mBtnClicked:=false;
  m_bQuoteDblClick:=false;

  Edit1:=nil;

  if not(csDesigning in ComponentState) then
  begin
    Edit1:=TEdit.Create(self);
    Edit1.setsubcomponent(true);
    Edit1.name:='E1';
    Edit1.text:='111111';
    Edit1.OnKeyPress:=Edit1KeyPress;
    Edit1.BringToFront;
    Edit1.Visible:=false;
  end;
end;

destructor TBtnListView.destroy;
var
  I: Integer;
  c:cColorItem;
begin
  for I := 0 to colorList.Count - 1 do
  begin
    c:=cColorItem(colorlist.items[i]);
    c.Destroy;
  end;
  colorlist.Destroy;
  // компонент TEdit удаляется автоматично
  inherited;
end;

end.
