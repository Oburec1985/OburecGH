unit uBaseObjService;

interface
uses classes,uBaseObj, controls, stdCtrls, ComCtrls, uBaseObjMng,
     uBtnListView, sysutils, inifiles, dialogs, VirtualTrees, uVTServices;

type
  StrObj = class
  public
    str:string;
  end;


  // отобразить объект в TListView
  procedure ShowInTreeViwe(obj:cBaseObj;TV:TTreeView);overload;
  procedure ShowInTreeViwe(obj:cBaseObj;TV:TTreeView;Images:TImageList);overload;
  procedure showInTreeView(tv:ttreeView; obj:cBaseObj);overload;
  procedure ShowBaseObjectInTreeView(obj:cBaseObj; tree:TTreeView; root:TTreeNode);

  procedure showInVTreeView(tv:TVTree; obj:cBaseObj);overload;
  procedure showInVTreeView(tv:TVTree; obj:cBaseObj; image:TImageList);overload;
  procedure AddObjToVTreeView(tv:TVTree; obj:cBaseObj; image:TImageList);overload;
  procedure ShowBaseObjectInVTreeView(tv:TVTree; obj:cBaseObj; root:pvirtualnode);


  // вытащить выбранный в TV объект
  function GetObjFromTreeView(tv:ttreeView):cBaseObj;
  // отобразить список объектов в lv
  procedure ShowMngInLV(lv:tbtnlistview;mng:cBaseObjMng);overload;
  procedure ShowBaseObjInLV(lv:tbtnlistview;obj:cBaseObj);

  // загружает все строки в глобальную переменную GetConstString
  procedure LoadStrings(fname:string);
  // взять из списка нужную строку по идентификатору
  function GetConstString(constStr:string):string;overload;
  function GetConstString(constStr:string; defaultName:string):string;overload;

  procedure DeleteStrings;

var
  v_ColName,
  v_ColNum,
  v_ColAdress,
  v_ColValue,
  v_ColDSC,
  v_Time,
  v_ColType,
  v_recentfiles,
  v_Helpfiles,
  v_StrNotFound
  :string;

  ColumnNames: tstringlist;

implementation

procedure ShowBaseObjInLV(lv:tbtnlistview;obj:cBaseObj);
var li:tlistitem;
begin
  if obj.ShowInGraphs then
  begin
    li:=lv.items.add;
    li.ImageIndex:=obj.imageindex;
    lv.SetSubItemByColumnName(v_ColName,obj.Name,li);
    lv.SetSubItemByColumnName(v_ColNum,inttostr(li.Index),li);
    // вписать тип датчика
    lv.SetSubItemByColumnName(v_ColType,obj.typestring,li);
  end;
end;

procedure ShowMngInLV(lv:tbtnlistview;mng:cBaseObjMng);
var
  obj:cBaseObj;
  i:integer;
begin
  lv.clear;
  lv.SmallImages:=mng.images_16;
  for I := 0 to mng.count - 1 do
  begin
    obj:=cBaseObj(mng.getobj(i));
    ShowBaseObjInLV(lv,obj);
  end;
end;


procedure ShowInTreeViwe(obj:cbaseobj;TV:TTreeView);
begin
  ShowBaseObjectInTreeView(obj,tv,nil);
end;

procedure ShowInTreeViwe(obj:cbaseobj;TV:TTreeView;Images:TImageList);
begin
  tv.Images:=images;
  ShowInTreeViwe(obj,tv);
end;

// используется в рекурсии
procedure ShowBaseObjectInTreeView(obj:cBaseObj; tree:TTreeView; root:TTreeNode);
var
  i:integer;
  child,world:cbaseobj;
  node:ttreenode;
begin
  if obj.ShowInGraphs then
  begin
    node:=tree.Items.AddChildObject (root,obj.name,obj);
    node.Data:=obj;
    node.ImageIndex:=obj.imageindex;
    node.SelectedIndex:=obj.imageindex;
  end;
  for I := 0 to obj.ChildCount - 1 do
  begin
    child:=cbaseobj(obj.getChild(i));
    if obj.ShowInGraphs then
      ShowBaseObjectInTreeView(child,tree,node)
    else
      ShowBaseObjectInTreeView(child,tree,root);
  end;
end;


{procedure ShowObjectInTreeView(obj:cBaseObj;tree:TTreeView;root:TTreeNode);
var
  i:integer;
  child:cBaseObj;
  node:ttreenode;
begin
  if obj<>nil then
  begin
    // node:=tree.Items.AddChildObjectFirst (root,obj.name,obj);
    node:=tree.Items.AddChildObject (root,obj.name,obj);
    node.SelectedIndex:=obj.imageindex;
    node.ImageIndex:=obj.imageindex;
    node.Data:=obj;
    for I := 0 to obj.ChildCount - 1 do
    begin
      child:=obj.getChild(i);
      ShowObjectInTreeView(child,tree,node);
    end;
  end;
end;}

procedure ShowBaseObjectInVTreeView(tv:TVTree; obj:cBaseObj; root:pvirtualnode);
var
  i:integer;
  child,world:cbaseobj;
  node:pvirtualNode;
  d:pnodedata;
begin
  if obj=nil then exit;
  
  if obj.ShowInGraphs then
  begin
    node:=tv.AddChild(root);
    d:=tv.GetNodeData(node);
    d.color:=tv.normalcolor;
    d.caption:=obj.caption;
    d.Data:=obj;
    d.ImageIndex:=obj.imageindex;
    obj.ShowComponent(node, tv);
  end;
  for I := 0 to obj.ChildCount - 1 do
  begin
    child:=cbaseobj(obj.getChild(i));
    if obj.ShowInGraphs then
      ShowBaseObjectInVTreeView(tv,child,node)
    else
      ShowBaseObjectInVTreeView(tv,child,root);
  end;
end;

procedure showInVTreeView(tv:TVTree; obj:cBaseObj; image:TImageList);
begin
  tv.Images:=image;
  showInVTreeView(tv,obj);
end;

procedure showInVTreeView(tv:TVTree; obj:cBaseObj);
begin
  tv.Clear;
  ShowBaseObjectInVTreeView(tv,obj,nil);
end;

procedure AddObjToVTreeView(tv:TVTree; obj:cBaseObj; image:TImageList);
begin
  tv.Images:=obj.images;
  ShowBaseObjectInVTreeView(tv,obj,nil);
end;

procedure showInTreeView(tv:ttreeView; obj:cBaseObj);
begin
  //tv.Images:=obj.images;
  ShowBaseObjectInTreeView(obj,tv,nil);
end;

function GetObjFromTreeView(tv:ttreeView):cBaseObj;
var node:ttreenode;
begin
  node:=tv.Selected;
  result:=cBaseObj(node.Data);
end;

procedure LoadStrings(fname:string);
var
  ifile:tInifile;
  keys:tStringlist;
  I: Integer;
  str:string;
  strO:StrObj;
begin
  if ColumnNames=nil then
  begin
    ColumnNames:=tstringlist.Create;
    ColumnNames.Sorted:=true;
  end
  else
  begin
    showmessage('Попытка повторной инициализации списка строк');
  end;
  if fileexists(fname) then
  begin
    keys:=TStringList.Create;
    iFile:=tinifile.Create(fname);
    ifile.ReadSection('ColumnNames',keys);
    for I := 0 to keys.Count - 1 do
    begin
      // удалять не надо т.к. удалиться при закрытии приложения с списком
      strO:=strobj.Create;
      strO.str:=ifile.ReadString('ColumnNames',keys.Strings[i],'');
      ColumnNames.AddObject(keys.Strings[i],StrO);
    end;
    keys.Destroy;
    ifile.Destroy;
  end;

  v_ColName:= GetConstString('ColName','№');
  v_ColNum:= GetConstString('ColNum', 'Name');
  v_ColType:= GetConstString('ColType', 'Type');
  v_ColAdress:=GetConstString('ColAdress', 'Adress');
  v_ColValue:=GetConstString('ColValue', 'Value');
  v_ColDSC:=GetConstString('ColDsc', 'Dsc');
  v_Time:=GetConstString('ColTime', 'Time');
  v_recentfiles:=GetConstString('RecentFiles', 'RecentFiles');
  v_Helpfiles:=GetConstString('Help', 'Help');
  v_StrNotFound:=GetConstString('StrNotFound', 'String Not Found');
end;
// взять из списка нужную строку по идентификатору
function GetConstString(constStr:string):string;
var
  strO:StrObj;
  i:integer;
begin
  result:='';
  if ColumnNames<>nil then
  begin
    if ColumnNames.Find(constStr, i) then
    begin
      result:=StrObj(ColumnNames.objects[i]).str;
    end
    else
    begin
      showmessage(v_StrNotFound+conststr);
    end;
  end;
end;

function GetConstString(constStr:string; defaultName:string):string;
var
  strO:StrObj;
  i:integer;
begin
  result:='';
  if ColumnNames<>nil then
  begin
    if ColumnNames.Find(constStr, i) then
    begin
      result:=StrObj(ColumnNames.objects[i]).str;
    end
    else
    begin
      showmessage(v_StrNotFound+conststr);
      result:=defaultName;
    end;
  end;
end;

// удалить строки
procedure DeleteStrings;
var
  StrO:strobj;
  i:integer;
begin
  if ColumnNames<>nil then
  begin
    for I := 0 to ColumnNames.Count - 1 do
    begin
      StrO:=StrObj(ColumnNames.Objects[i]);
      StrO.Destroy;
    end;
    ColumnNames.Destroy;
  end;
end;


end.
