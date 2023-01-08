unit uComponentServises;

interface
uses
  ueventlist, ubtnlistview, classes, stdctrls, controls, spin, uspin, uPathMng,
  comctrls, sysutils, extctrls, Graphics, grids, dialogs, windows, ShlObj,
  VirtualTrees, uVTServices, forms, uBaseObj, DCL_MYOWN, uCommonMath;

// возвращает -1 если объект не найден
function setComboBoxItem(str:string; c:tcombobox):integer;
function GetComboBoxItem(c:tcombobox):tobject;
function RenameComboBoxItem(newname:string; obj:tobject;c:tcombobox):integer;
function CheckCBItemInd(c:tcombobox):boolean;
// работает для TEDit и TCombobox
// Если dir =true то ищем папку иначе ищем файл
function CheckFolderComponent(c:twincontrol; dir:boolean):boolean;overload;
function CheckFolderComponent(c:twincontrol; text:string;dir:boolean):boolean;overload;
// отобразитьс события в LV
procedure ShowEventsInLV(events:cEventList; lv:tbtnlistview);
// создать и проименовать колонки
procedure InitLVForEvents(lv:tbtnlistview);
//
function FindNodeInTV(obj:tobject; tv:ttreeview):ttreenode;
// выбрать объект
function SelectNodeInTV(obj:tobject; tv:ttreeview):ttreenode;

// найти колонку в sg по имени
function getColumn(SG:tStringGrid; name:string):integer;
// найти cnhjre в sg по имени
function getRow(SG:tStringGrid; name:string; col:integer):integer;
procedure SGChange(sg:tStringGrid);
// выровнять колонки по максимальной ширине строки в таблице
procedure LVChange(lv:tlistview);
// возвращает false если попытались записать разные строки
function SetMultiSelectComponentBool(c:twincontrol;b:boolean):boolean;
function GetMultiSelectComponentBool(c:twincontrol;var err:boolean):boolean;
function SetMultiSelectComponentString(c:twincontrol;text:string):boolean;
function GetMultiSelectComponentString(c:twincontrol;var err:boolean):string;
// для радиогруппы
function SetMultiSelectItemInd(c:twincontrol;ind:integer):boolean;
procedure endMultiSelect(c:twincontrol);
function MultiSelectState(c:twincontrol):boolean;
function getselectObject(c:twincontrol):pointer;

function OpenDialog(vstDlg:TFileOpenDialog; base:string):string;

function GetSelectObjectFromVTV(tv:TVTree):pointer;
function GetObjectNodeFromVTV(tv:TVTree; obj:cbaseobj):pointer;
function GetSelectNode(tv:TVTree):pVirtualNode;
function ChildSelected(n:pVirtualNode; tagsTV:TVTree):boolean;
function ParentSelected(n:pVirtualNode; tagsTV:TVTree):boolean;

function getParentFontSize(c:tWinControl):integer;
procedure CheckFolder(c:TWinControl);

const
  c_lightRed = $008080FF;


implementation
const
  c_ColInd = 'Индекс';
  c_ColName = 'Имя';
  c_ColType = 'Тип';
  c_ColAdr = 'Адрес';
  // добавок в пикселях при расчете ширины колонки в LV
  c_ColTabs = 15;

procedure CheckFolder(c:TWinControl);
var
  str:string;
  color:integer;
begin
  // получение пути
  if c is tedit then
    str:=tedit(c).text
  else
  begin
    if c is tcombobox then
    begin
      str:=tcombobox(c).text;
    end;
  end;
  // проверка пути
  if isDirectory(str) then
  begin
    if DirectoryExists(str) then
    begin
      color := clWindow;
    end
    else
    begin
      color := $008080FF;
    end;
  end
  else
  begin
    if fileexists(str) then
    begin
      color := clWindow;
    end
    else
    begin
      color := $008080FF;
    end;
  end;
  // установка цвета
  if c is tedit then
  begin
    tedit(c).Color:=color;
  end;
end;

function getParentFontSize(c:tWinControl):integer;
begin
  if c is TStringGrid then
  begin
    result:=TStringGrid(c).Canvas.Font.Size;
    if TStringGrid(c).ParentFont then
    begin
      if TStringGrid(c).Parent<>nil then
      begin
        result:=getParentFontSize(c.Parent);
      end;
    end;
  end;
  if c is TGroupBox then
  begin
    result:=TGroupBox(c).Font.Size;
    if TGroupBox(c).ParentFont then
    begin
      result:=getParentFontSize(c.Parent);
    end;
  end;
  if c is TPanel then
  begin
    result:=TPanel(c).Font.Size;
    if TPanel(c).ParentFont then
    begin
      result:=getParentFontSize(c.Parent);
    end;
  end;
  if c is TForm then
  begin
    result:=TForm(c).Font.Size;
    if TForm(c).ParentFont then
    begin
      result:=getParentFontSize(c.Parent);
    end;
  end;
end;

procedure SGChange(sg:tStringGrid);
var
  x, y, w, fsize, oldfont: integer;
  s: string;
  MaxWidth: integer;
begin
  sg.ClientHeight := sg.DefaultRowHeight * sg.RowCount + 5;
  begin
    for x := 0 to sg.ColCount - 1 do
    begin
      MaxWidth := 0;
      for y := 0 to sg.RowCount - 1 do
      begin
        fsize:=getParentFontSize(sg);
        oldfont:=sg.Canvas.Font.size;
        sg.Canvas.Font.size:=fsize;
        w := sg.Canvas.TextWidth(sg.Cells[x,y]);
        sg.Canvas.Font.size:=oldfont;
        if w > MaxWidth then
          MaxWidth := w;
      end;
      //sg.ColWidths[x] := round(1.1*MaxWidth) + 5;
      sg.ColWidths[x] := round(1.25*MaxWidth) + 5;
      //sg.ColWidths[x] := 100;
    end;
  end;
end;

function ParentSelected(n:pVirtualNode; tagsTV:TVTree):boolean;
var
  p:pVirtualNode;
  d:pnodedata;
begin
  result:=false;
  p:=n.Parent;
  while p<>nil do
  begin
    if tagsTV.RootNode=p then
    begin
      result:=false;
      exit;
    end;
    if vsselected in p.States then
    begin
      result:=true;
      exit;
    end
    else
    begin
      p:=p.parent;
    end;
  end;
end;

function ChildSelected(n:pVirtualNode; tagsTV:TVTree):boolean;
var
  I: Integer;
  ch:pVirtualNode;
begin
  if n.ChildCount=0 then
  begin
    result:=false;
  end
  else
  begin
    for I := 0 to n.ChildCount - 1 do
    begin
      if i=0 then
      begin
        ch:=n.FirstChild;
      end
      else
      begin
        ch:=tagstv.GetNext(ch);
      end;
      if vsSelected in ch.States then
      begin
        result:=true;
        exit;
      end
      else
      begin
        result:=ChildSelected(ch, tagstv);
      end;
    end;
  end;
end;

function GetSelectNode(tv:TVTree):pVirtualNode;
var
  node:PVirtualNode;
  data:pnodedata;
  obj:pointer;
begin
  result:=nil;
  if tv.SelectedCount>0 then
  begin
    result:=tv.GetFirstSelected(true);
  end;
end;

function GetObjectNodeFromVTV(tv:TVTree; obj:cbaseobj):pointer;
begin
  result:=tv.GetNodeByPointer(obj);
end;

function GetSelectObjectFromVTV(tv:TVTree):pointer;
var
  node:PVirtualNode;
  data:pnodedata;
  obj:pointer;
begin
  result:=nil;
  if tv.SelectedCount>0 then
  begin
    node:=tv.GetFirstSelected(false);
    while node<>nil do
    begin
      data:=tv.GetNodeData(node);
      result:=data.data;
      exit;
      //if obj is cOperObj then
      //begin
      //  GetOperObjOpts(coperobj(obj),OperTVSelects);
      //end;
      //if obj is cSignalsOpt then
      //begin
      //  OperTVSelects.AddObj(obj);
      //end;
      //node:=tv.GetNextSelected(node, true);
      //inc(i);
    end;
  end;
end;


function GetOsVersion: integer;
var
  str: string;
  VersionInformation: OSVERSIONINFO;
begin
  VersionInformation.dwOSVersionInfoSize := sizeof(VersionInformation);
  GetVersionEx(VersionInformation);
  // str:='OS Version '+
  // intToStr(VersionInformation.dwMajorVersion)+'.'+
  // intToStr(VersionInformation.dwMinorVersion)+' '+VersionInformation.szCSDVersion;
  // Result:=str;
  result := VersionInformation.dwMajorVersion;
end;

function SelectDirectoryLoc(const Title: string; var Path: string): boolean;
var
  lpItemID, start: PItemIDList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array [0 .. MAX_PATH] of char;
  TempPath: array [0 .. MAX_PATH] of char;
begin
  FillChar(BrowseInfo, sizeof(TBrowseInfo), #0);
  BrowseInfo.pszDisplayName := @Path[1];
  BrowseInfo.hwndOwner := 0;
  BrowseInfo.lpszTitle := PChar(Title);

  // BrowseInfo.pidlRoot:=start;
  BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
  lpItemID := SHBrowseForFolder(BrowseInfo);
  result := lpItemID <> nil;
  if result then
  begin
    SHGetPathFromIDList(lpItemID, TempPath);
    Path := TempPath;
    GlobalFreePtr(lpItemID);
  end;
end;

function OpenDialog(vstDlg:TFileOpenDialog; base:string):string;
var
  str:string;
begin
  result:=base;
  if GetOsVersion >= 6 then
  begin
    vstDlg.filename := base;
    vstDlg.Options := [fdoPickFolders, fdoForceFileSystem];
    if vstDlg.Execute() then
    begin
      result := vstDlg.filename;
    end;
  end
  else
  begin
    // OpenDialog1.Options := [ofOldStyleDialog, fdoForceFileSystem];
    str := base;
    // if SelectDirectory('Выбор базового каталога', '',str) then
    if SelectDirectoryLoc('Выбор базового каталога', str) then
    begin
      result := str;
    end;
  end;
end;

function RenameComboBoxItem(newname:string; obj:tobject;c:tcombobox):integer;
var
  I: Integer;
begin
  for I := 0 to c.items.Count - 1 do
  begin
    if c.Items.Objects[i]=obj then
    begin
      c.Items.Strings[i]:=newname;
      if c.Text=newname then
      begin
        if c.ItemIndex=-1 then
          c.ItemIndex:=i;
      end;
      CheckCBItemInd(c);
      exit;
    end;
  end;
end;

function GetComboBoxItem(c:tcombobox):tobject;
begin
  result:=nil;
  if c.ItemIndex>=0 then
  begin
    result:=c.Items.Objects[c.ItemIndex];
  end;
end;

function setComboBoxItem(str:string; c:tcombobox):integer;
var
  I: Integer;
begin
  result:=-1;
  for I := 0 to c.Items.Count - 1 do
  begin
    if (lowercase(c.Items[i])=lowercase(str)) then
    begin
      c.ItemIndex:=i;
      c.text:=str;
      result:=i;
      CheckCBItemInd(c);
      exit;
    end;
  end;
  if str='' then
  begin
    c.ItemIndex:=-1;
  end
  else
  begin
    c.ItemIndex:=-1;
    c.text:=str;
  end;
  CheckCBItemInd(c);
end;

function CheckCBItemInd(c:tcombobox):boolean;
begin
  if c.itemindex=-1 then
  begin
    c.Color:=c_lightRed;
    result:=false;
  end
  else
  begin
    c.Color:=clWindow;
    result:=true;
  end;
end;

function getselectObject(c:twincontrol):pointer;
begin
  result:=nil;
  if c is TComboBox then
  begin
    if TComboBox(c).ItemIndex>-1 then
    begin
      result:=TComboBox(c).Items.Objects[TComboBox(c).ItemIndex];
    end;
  end;
end;

function MultiSelectState(c:twincontrol):boolean;
begin
  if c.Tag=-1 then
    result:=true
  else
    result:=false;
end;

procedure endMultiSelect(c:twincontrol);
begin
  if c is tradiogroup then
  begin
    TEdit(c).Tag:=0;
  end;
  if c is tedit then
  begin
    TEdit(c).Tag:=0;
    if TEdit(c).text='_' then
    begin
      TEdit(c).text:='';
    end;
  end;
  if c is tSpinEdit then
  begin
    tSpinEdit(c).Tag:=0;
    if tSpinEdit(c).text='_' then
    begin
      tSpinEdit(c).text:='';
    end;
  end;
  if c is tfloatSpinEdit then
  begin
    tfloatSpinEdit(c).Tag:=0;
    if tfloatSpinEdit(c).text='_' then
    begin
      tfloatSpinEdit(c).text:='';
    end;
  end;
  if c is tcheckbox then
  begin
    tcheckbox(c).Tag:=0;
    //if tcheckbox(c).State=cbGrayed then
    //begin
    //  tcheckbox(c).State:=cbUnchecked;
    //end;
  end;
  if c is tCombobox then
  begin
    tCombobox(c).Tag:=0;
    //if tcheckbox(c).State=cbGrayed then
    //begin
    //  tcheckbox(c).State:=cbUnchecked;
    //end;
  end;
end;

function SetMultiSelectItemInd(c:twincontrol;ind:integer):boolean;
begin
  // возвращает false если пытались записать разные строки
  // Tag =0 если первое вхождение в процедуру
  result:=true;
  if c is tradiogroup then
  begin
    // первое вхождение
    if tradiogroup(c).Tag=0 then
    begin
      tradiogroup(c).Tag:=1;
      tradiogroup(c).itemindex:=ind;
    end
    else
    begin
      if ind<>tradiogroup(c).ItemIndex then
      begin
        tradiogroup(c).Tag:=0;
        result:=false;
        tradiogroup(c).ItemIndex:=-1;
      end;
    end;
  end
end;

function GetMultiSelectComponentBool(c:twincontrol;var err:boolean):boolean;
begin
  err:=false;
  if c is TCheckBox then
  begin
    if TCheckBox(c).State=cbGrayed then
    begin
      err:=true;
    end
    else
    begin
      result:=TCheckBox(c).checked;
    end;
  end;
end;

function SetMultiSelectComponentBool(c:twincontrol;b:boolean):boolean;
begin
  result:=true;
  if c is TCheckBox then
  begin
    if TCheckBox(c).Tag=0 then
    begin
      TCheckBox(c).Tag:=1;
      TCheckBox(c).State:=cbUnchecked;
      TCheckBox(c).Checked:=b;
    end
    else
    begin
      if TCheckBox(c).State<>cbGrayed then
      begin
        if b<>TCheckBox(c).checked then
        begin
          TCheckBox(c).Tag:=0;
          TCheckBox(c).State:=cbGrayed;
          result:=false;
        end;
      end;
    end;
  end;
end;

function GetMultiSelectComponentString(c:twincontrol;var err:boolean):string;
var
  str:string;
begin
  err:=false;
  result:='';
  if c is tcombobox then
  begin
    result:=tcombobox(c).text;
    if MultiSelectState(c) then
    begin
      if (Result='') or (Result='_') then
      begin
        err:=true;
      end;
    end
    else
    begin

    end;
  end;
  if c is tedit then
  begin
    if (c is TFloatEdit) or (c is TIntEdit) then
    begin
      str:=tedit(c).text;
      if str<>'00' then
      begin
        result:=str;
      end
      else
      begin
        err:=true;
      end;
    end
    else
    begin
      str:=tedit(c).text;
      if checkstr(str) then
      begin
        result:=str;
      end
      else
      begin
        err:=true;
      end;
    end;
  end;
end;

function SetMultiSelectComponentString(c:twincontrol;text:string):boolean;
begin
  // возвращает false если пытались записать разные строки
  // Tag =0 если первое вхождение в процедуру; 1 если повторное; -1 если разные значения с разных элементов
  result:=true;
  if c is tedit then
  begin
    if tedit(c).text<>'_' then
    begin
      if TEdit(c).Tag=0 then
      begin
        TEdit(c).Tag:=1;
        tedit(c).Text:=text;
      end
      else
      begin
        if text<>tedit(c).text then
        begin
          TEdit(c).Tag:=-1;
          result:=false;
          if c is tfloatedit then
          begin
            tedit(c).Text:='00';
          end
          else
          begin
            if c is TIntEdit then
            begin
              tedit(c).Text:='00';
            end
            else
            begin
              tedit(c).Text:='_';
            end;
          end;
        end;
      end;
    end;
  end
  else
  begin
    if c is tSpinEdit then
    begin
      if tSpinEdit(c).text<>'_' then
      begin
        if tSpinEdit(c).Tag=0 then
        begin
          tSpinEdit(c).Tag:=1;
          tSpinEdit(c).Text:=text;
          result:=true;
        end
        else
        begin
          if text<>tSpinEdit(c).text then
          begin
            tSpinEdit(c).Tag:=-1;
            result:=false;
            tSpinEdit(c).Text:='_';
          end;
        end;
      end;
    end;
    if c is tFloatSpinEdit then
    begin
      if tFloatSpinEdit(c).text<>'_' then
      begin
        if tFloatSpinEdit(c).Tag=0 then
        begin
          tFloatSpinEdit(c).Tag:=1;
          tFloatSpinEdit(c).Text:=text;
          result:=true;
        end
        else
        begin
          if text<>tFloatSpinEdit(c).text then
          begin
            tFloatSpinEdit(c).Tag:=-1;
            result:=false;
            tFloatSpinEdit(c).Text:='_';
          end;
        end;
      end;
    end;
    if c is tCombobox then
    begin
      // перв. вхожд в проц
      if tCombobox(c).Tag=0 then
      begin
        tCombobox(c).Tag:=1;
        setComboBoxItem(text, tCombobox(c));
        result:=true;
      end
      else
      begin
        if text<>tCombobox(c).text then
        begin
          tCombobox(c).Tag:=-1;
          result:=false;
          tCombobox(c).Text:='';
          tCombobox(c).ItemIndex:=-1;
        end;
      end;
    end;
  end;
end;

function CheckFolderComponent(c:twincontrol; text:string;dir:boolean):boolean;overload;
var
  b:boolean;
begin
  if (c is tedit) then
  begin
    if dir then
      b:=DirectoryExists(Text)
    else
      b:=FileExists(Text);
    if b then
    begin
      tedit(c).color := clWindow;
      result:=true;
      exit;
    end
    else
    begin
      tedit(c).color := $008080FF;
      result:=false;
      exit;
    end;
  end;
  if (c is tcombobox) then
  begin
    if dir then
      b:=DirectoryExists(Text)
    else
      b:=FileExists(Text);
    if b then
    begin
      tcombobox(c).color := clWindow;
      result:=true;
      exit;
    end
    else
    begin
      tcombobox(c).color := $008080FF;
      result:=false;
      exit;
    end;
  end;
end;

function CheckFolderComponent(c:twincontrol; dir:boolean):boolean;
var
  b:boolean;
begin
  if (c is tedit) then
  begin
    if dir then
      b:=DirectoryExists(tedit(c).Text)
    else
      b:=FileExists(tedit(c).Text);
    if b then
    begin
      tedit(c).color := clWindow;
      result:=true;
      exit;
    end
    else
    begin
      tedit(c).color := $008080FF;
      result:=false;
      exit;
    end;
  end;
  if (c is tcombobox) then
  begin
    if dir then
      b:=DirectoryExists(tcombobox(c).Text)
    else
      b:=FileExists(tcombobox(c).Text);
    if b then
    begin
      tcombobox(c).color := clWindow;
      result:=true;
      exit;
    end
    else
    begin
      tcombobox(c).color := $008080FF;
      result:=false;
      exit;
    end;
  end;
end;

procedure LVChange(lv:tlistview);
var
  I,w,w2 : Integer;
  col:tlistcolumn;
  j:integer;
  colwidth:array of integer;
  li:tlistitem;
begin
  setlength(colwidth,lv.Columns.Count);
  // берем ширину названий колонок
  for j := 0 to lv.columns.Count - 1 do
  begin
    w:=30;
    w2:=lv.StringWidth(lv.columns[j].Caption);
    if w<w2 then
      w:=w2;
    if w>colwidth[j] then
      colwidth[j]:=w+c_ColTabs;
  end;
  for I := 0 to lv.items.Count - 1 do
  begin
    li:=lv.Items[i];
    for j := 0 to lv.columns.Count - 1 do
    begin
      if j=0 then
      begin
        w:=lv.StringWidth(li.Caption);
        if w<30 then
          w:=30;
        w2:=lv.StringWidth(lv.columns[j].Caption);
        if w<w2 then
          w:=w2;
      end
      else
      begin
        if j-1<=li.SubItems.Count-1 then
        begin
          w:=lv.StringWidth(li.SubItems[j-1])+c_ColTabs;
          w2:=lv.StringWidth(lv.Columns[j].Caption)+c_ColTabs;
          if w<w2 then
            w:=w2;
        end
        else
          w:=0;
      end;
      if w>colwidth[j] then
        colwidth[j]:=w+c_ColTabs;
    end;
  end;
  w:=0;
  for i := 0 to lv.Columns.Count - 1 do
  begin
    if colwidth[i]<>0 then
      w:=w+colwidth[i];
  end;
  for I := 0 to lv.Columns.Count - 1 do
  begin
    col:=lv.Columns[i];
    if colwidth[i]<>0 then
      col.Width:=colwidth[i]
    else
      col.Width:=lv.Width-w;
  end;
  //setlength(colwidth,0);
end;

function getColumn(SG:tStringGrid; name:string):integer;
var
  I: Integer;
begin
  i:=-1;
  for I := 0 to sg.Rows[0].Count - 1 do
  begin
    if sg.Rows[0].Strings[i]=name then
    begin
      result:=i;
      exit;
    end;
  end;
end;

function getRow(SG:tStringGrid; name:string; col:integer):integer;
var
  I: Integer;
begin
  i:=-1;
  for I := 1 to sg.Cols[col].Count - 1 do
  begin
    if sg.Cols[col].Strings[i]=name then
    begin
      result:=i;
      exit;
    end;
  end;
end;

procedure InitLVForEvents(lv:tbtnlistview);
var
  col:tlistcolumn;
begin
  // создаем колонки
  lv.Columns.Clear;
  col:=lv.Columns.add;
  col.Caption:=c_ColInd;
  col:=lv.Columns.add;
  col.Caption:=c_ColName;
  col:=lv.Columns.add;
  col.Caption:=c_ColType;
  col:=lv.Columns.add;
  col.Caption:=c_ColAdr;
end;

procedure ShowEventsInLV(events:cEventList; lv:tbtnlistview);
var
  i:integer;
  li:tlistitem;
  e:cEvent;
begin
  lv.Clear;
  for I := 0 to events.count - 1 do
  begin
    e:=events.GetEvent(i);
    li:=lv.Items.Add;
    lv.SetSubItemByColumnName(c_ColInd,inttostr(i),li);
    //lv.SetSubItemByColumnName(c_ColName,'sdsfsdf',li);
    lv.SetSubItemByColumnName(c_ColName,e.name,li);
    lv.SetSubItemByColumnName(c_ColType,inttostr(e.EventType),li);
    lv.SetSubItemByColumnName(c_ColAdr,IntToHex(integer(@e.action),6),li);
  end;
end;

function FindNode(obj:tobject;node:ttreenode):ttreenode;
var
  child:ttreenode;
  i:integer;
begin
  if node.Data=obj then
  begin
    result:=node;
    exit;
  end;
  for I := 0 to node.Count - 1 do
  begin
    child:=node.Item[i];
    result:=FindNode(obj,child);
    if result<>nil then
      exit;
  end;
  result:=nil;
end;

function FindNodeInTV(obj:tobject; tv:ttreeview):ttreenode;
var
  node:ttreenode;
  i:integer;
begin
  result:=nil;
  for I := 0 to tv.items.Count - 1 do
  begin
    node:=tv.Items[i];
    if node.Data=obj then
      result:=node;
  end;
end;

function SelectNodeInTV(obj:tobject; tv:ttreeview):ttreenode;
var
  node:ttreenode;
begin
  node:=FindNodeInTV(obj,tv);
  node.Selected:=true;
end;


end.
