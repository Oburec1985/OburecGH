// класс от которого наследуются все объекты движка программы. Предназначен для
// организации общего интерфейса пользователя всех объектов. Включает в себя
// следующие данные
unit uBaseObj;

interface
uses
  sysutils, uEventList, classes, controls, dialogs, ucommonMath,
  uEventTypes, NativeXML, uMetaData,
  uSetList;

type
  cBaseObj = class;
  // возвращает - нужно ли продолжать перечисление
  enumProc = function(obj:cBaseObj; data:pointer):boolean;
  cBaseObjList = class;

  cBaseObj = class
  public
    fdefCaption:boolean;
    f_caption:string;
    // если заблокирован то не удаляется при удалении родителя при выставленном флаге
    // destroydata
    // е удаляется при вызове метода clear. Принудительно флаз сбрасывается перед очисткой движка при удалении движка
    blocked:boolean;
    // индекс иконки
    fimageind:integer;
    // родительский объект. Нужно для правильного отображения в TreeView
    fparent:cBaseObj;
    // объект создается автоматически в рамках другого объекта. Используется как подпапка
    // для хранения объектов. Влияет на то как будет сохраняться и загружаться
    // Нельзя ставить True для вспомогательных корневых объектов,т.к. объект будет разрушен и не восттановлен при загрузке
    // исправлено параметром ниже
    autocreate:boolean;
    // объект вспомогательный. Не отображается в движке
    fHelper:boolean;
    metadata:MetaDataList;
    // список в котором лежит объект
    list:cBaseObjList;
    itemindex:integer;
    // дочерние объекты. Нужно для правильного отображения в TreeView
    childrens:cBaseObjList;
  protected
    fBaseObjMng:tobject;
    // Имя объекта
    fname:string;
    // Сортировка (-1 если не сортирован)
    fsort:integer;
  public
    procedure DoBeforeLincParent;virtual;
    // происходит при назначении нового родителя (в том числе если новый родитель nil)
    procedure DoLincParent;virtual;
    // заменяет ссылку на engine, но не добавляет объект в список engina
    procedure ReplaceObjMng(mng:tobject);virtual;
    procedure CreateChildrens;virtual;
  protected
    procedure setcaption(str:string);virtual;
    // если к менеджеру объектов прилинкован объект с именем parentname то он линкуется как родитель
    function GetParentName:string;
    procedure SetParentName(parentname:string);virtual;
    // Перечисляет всех потомков дерева, вызывая при этом процедуру
    // в которую передается
    // перечисляемый объект и указатель на дополнительные данные
    function fEnumGroupMembers(proc:enumProc;data:pointer;var continue:boolean):boolean;
    // отлинковывает от двига все связи объекта
    procedure unLincMng;virtual;
    // получить ссылку на главный объект (для датчика - ступень, для ступени - турбина и т.д.)
    function GetMainParent:cbaseObj;virtual;
    procedure SetMainParent(p:cbaseObj);virtual;
    // Поддерживаемые классы дочерних объектов
    function SupportedChildClass(obj:cbaseobj):boolean;overload;virtual;
    function SupportedChildClass(classname:string):boolean;overload;virtual;
    function SupportedChildClass(objtype:integer):boolean;overload;virtual;
  public
    // виртуальная функция для отображения в компоеннтах. Реализуется в наследниках например для отображения в VirtualTreeView
    procedure ShowComponent(node: pointer; component:tcomponent);virtual;
    procedure setMng(m:tobject);virtual;
    function getMng:tobject;
    // корневой в группе
    function isHeader:boolean;
    function GetRoot:cbaseobj;
    function mainParentClassName:string;virtual;
    // Строка описывающая тип объекта
    function TypeString:String;virtual;
    procedure EnumGroupMembers(proc:enumProc;data:pointer);
    function find(name:string;var index:integer):boolean;virtual;
    // поиск по простому ключу KeyComparator в cSetList
    function findObj(key:pointer; var ind:integer):cbaseobj;
    // возвращает список потомков с подходящим classname
    // ищем во всем дереве
    function getChildrensByClassName(p_classname:ansistring):tstringlist;
    function getChildrenByName(name:string):cbaseobj;
    function getChildrenByCaption(name:string):cbaseobj;
    // получить потомка по ссылке
    function getChild(i:integer):cBaseObj;overload;
    // получить потомка по имени
    function GetChild(name:string):cBaseObj;overload;
    // Число потомков
    function ChildCount:integer;
    constructor create;virtual;
    destructor destroy;virtual;
    // добавить объект потомок
    procedure AddChild(newChild:cBaseObj);
    // прилинковать к объекту
    procedure lincTo(p_parent:cBaseObj);
    // Отлинковать объект от родителя
    procedure unlinc;virtual;
    // Отлинковать дочерние объекты
    procedure unlincChildrens;
    // проверить является находится ли объект где то выше по дереву
    function isParentObj(obj:cbaseobj):boolean;
    // получить родителя класс которого = classname. с самим собой не сравнивает
    function GetParentByClassName(p_classname:string):cbaseobj;
    // имеют общего родителя - возвращает общего родителя
    function HaveCommonParent(obj:cbaseobj):cbaseobj;
    // Удаление потомка (вызывает деструктор потомка и отвязывает от дерева)
    procedure deletechild(i:integer);overload;virtual;
    procedure deletechild(name:string);overload;virtual;
    procedure deletechild(node:pointer);overload;virtual;
    procedure destroychildrens;
    procedure clear;
    procedure LoadObjAttributes(xmlNode:txmlNode; mng:tobject);virtual;
    procedure SaveObjAttributes(xmlNode:txmlNode);virtual;
    // происходит, когда объект создается движком
    procedure OnEngCreate;virtual;
  protected
    // Установка имени
    procedure setname(str:string);virtual;
    // Установка родителя
    procedure setParent(p:cBaseObj);virtual;
    // Установка типа сортировки
    procedure setsorted(value:integer);virtual;abstract;
    procedure setimageind(ind:integer);
    function getimageindex:integer;virtual;
    // Установка картинок
    procedure setImageList(p_imagelist:timagelist);virtual;
    function getImageList:timagelist;virtual;
    // установка свойства удалять вложенные объекты
    function getdestroydata:boolean;
    procedure SetDestroyData(b:boolean);
    function getShowInGraphs:boolean;virtual;
    procedure setShowInGraphs(b:boolean);virtual;
  protected
    property sorted:integer read fsort write setsorted;
  public
    property mainParent:cBaseObj read getMainParent write setMainParent;
    property parent:cBaseObj read fparent write setParent;
    property name:string read fname write setname;
    property imageindex:integer read getimageindex write setimageind;
    property images:tImageList read getImageList write setImageList;
    property parentName:string read getParentName write SetParentName;
    property destroydata:boolean read GetDestroyData write SetDestroyData;
    // отображать в дереве объектов и легенде
    property ShowInGraphs:boolean read getShowInGraphs write setShowInGraphs;
    property caption:string read f_caption write setcaption;
  end;

  // именованый список объктов
  cBaseObjList = class(cSetList)
  private
    fcomparetype:integer;
  protected
    // метаданные в фильтре (имя)
    mDataName:string;
    // тип метаданных
    mDataClass:TClass;
    // поскольку класс является чисто интерфесным и не содержит листа,
    // то необходимо в потомках переписывать процедуру удаления самого листа списка
    // более того
  protected
    // сортировка может проводиться либо по имени либо по динамическому свойству.
    // перед сортировкой должен быть выполнен метод prepareMetaDataSort куда передается класс
    // и имя свойства по которому нужно сортировать
    //  c_StrCompare = 1;
    // c_MetaCompare = 2;
    procedure setcomparetype(t:integer);virtual;
  public
    constructor create;virtual;
    destructor destroy;virtual;
    procedure cleardata;
    procedure removeobj(i:integer);override;
    function getobj(name:string):cbaseobj;overload;virtual;
    function getobj(i:integer):cbaseobj;overload;
    procedure addobj(obj:cbaseobj);
    procedure deleteobj(obj:cbaseobj);
    // Удаление потомка (вызывает деструктор потомка и отвязывает от дерева)
    procedure deletechild(i:integer);override;
    procedure deletechild(name:string);overload;
    procedure deletechild(node:pointer);overload;override;
    procedure PrepareMetaDataSort(sortname:string;cl:tclass);
    function find(name:string;var index:integer):boolean;overload;virtual;
    function find(obj:cbaseobj;var index:integer):boolean;overload;
    property comparetype:integer read fcomparetype write setcomparetype;
  end;

const
  c_BaseObj_Img = 5;
  c_StrCompare = 1;
  c_MetaCompare = 2;
  c_BlueLeft = 30;
  c_BlueRight = 28;
  c_BlueDown = 31;
  c_BlueUpdate = 29;



implementation
uses
  uBaseObjMng  ;

type
  sList = class(tstringlist)
  protected
    slisttext:string;
  end;

function IsClass(obj:tobject;name:string):boolean;
var
  cl:tclass;
begin
  result:=false;
  cl:=obj.ClassType;
  if cl.ClassName=name then
  begin
    result:=true;
  end
  else
  while cl.ClassParent<>nil do
  begin
    cl:=cl.ClassParent;
    if cl.ClassName=name then
    begin
      result:=true;
      exit;
    end;
  end;
end;

function NameComparator(p1,p2:pointer):integer;
var
  s1,s2:ansistring;
begin
  s1:=cbaseobj(p1).name;
  s2:=cbaseobj(p2).name;
  result:=NameComparatorStrBaseNum(s1, s2);
end;

function NameKeyComparator(p1,p2:pointer):integer;
var
  s1,s2:ansistring;
begin
  s1:=string(cbaseobj(p1).name);
  s2:=string(p2^);
  result:=NameComparatorStrBaseNum(s1, s2);
end;

function MetaDataCompare(p1,p2:pointer):integer;
var
  o1,o2:cbaseobj;
  prop1,prop2:MetaData;
begin
  o1:=cbaseobj(p1);
  o2:=cbaseobj(p2);
  prop1:=o1.metadata.GetObj(o1.list.mDataName);
  prop2:=o2.metadata.GetObj(o2.list.mDataName);
  if prop1<>nil then
  begin
    if prop1.ClassType=o1.list.mDataClass then
    begin
      if prop2=nil then
      begin
        result:=1;
      end
      else
      begin
        if prop2.ClassType<>o1.list.mDataClass then
        begin
          result:=1;
        end
        else
        begin
          result:=prop1.compare(prop2);
        end;
      end;
    end
    else
    begin
      if prop2<>nil then
      begin
        if prop2.ClassType=o1.list.mDataClass then
        begin
          result:=-1;
        end
        else
        begin
          result:=StrComp(pansichar(p1),pansichar(p2));
        end;
      end
      else
      begin
        result:=StrComp(pansichar(p1),pansichar(p2));
      end;
    end;
  end
  else
  begin
    if prop2=nil then
    begin
      result:=StrComp(pansichar(p1),pansichar(p2));
    end
    else
    begin
      result:=-1;
    end;
  end;
end;

constructor cBaseObj.create;
begin
  fdefCaption:=true;
  fhelper:=false;
  fparent:=nil;
  blocked:=false;
  fname:=classname;
  f_caption:=classname;
  imageindex:=c_baseobj_img;
  metadata:=metadatalist.create;
  fBaseObjMng:=nil;
  CreateChildrens;
end;

destructor cBaseObj.destroy;
var
  events:ceventlist;
begin
  metadata.destroy;
  metadata:=nil;
  unlinc;
  if not childrens.destroydata then
    unlincChildrens;
  if (fBaseObjMng<>nil) then
  begin
    events:=cBaseObjMng(fBaseObjMng).Events;
    // отлинковываем двиг
    setMng(nil);
    // Вызов событий для извещения фреймов об удалении объекта
    if events<>nil then
      events.CallAllEventsWithSender(E_OnDestroyObject, self);
  end;
  childrens.Destroy;
  childrens:=nil;
  // Удаляем объект
  inherited;
end;

function cBaseObj.GetMainParent:cbaseObj;
var
  lparent:cbaseobj;
begin
  lparent:=parent;
  if lparent<>nil then
  begin
    if lparent.autocreate then
    begin
      while lparent<>nil do
      begin
        if lparent.autocreate then
        begin
          lparent:=lparent.parent;
          if lparent<>nil then
          begin
            if not lparent.autocreate then
              break;
          end
          else
            break;
        end;
      end;
    end;
  end;
  if lparent=nil then
  begin
    if parent<>nil then
    begin
      result:=parent;
      exit;
    end;
  end;
  result:=lparent;
end;

procedure cBaseObj.SetMainParent(p:cbaseObj);
begin
  parent:=p;
end;

function cBaseObj.mainParentClassName:string;
begin
  result:='cBaseObj';
end;

function cBaseObj.isHeader:boolean;
begin
  result:=true;
  if parent<>nil then
    result:=false;
end;

function cBaseObj.GetRoot:cbaseobj;
var
  obj:cbaseobj;
begin
  obj:=parent;
  if obj<>nil then
  begin
    while obj.parent<>nil do
    begin
      obj:=obj.parent;
    end;
    result:=obj;
  end
  else
  begin
   result:=self;
  end;
end;

function cBaseObj.TypeString:String;
begin
  result:='Базовый объект';
end;

procedure cBaseObj.setMng(m:tobject);
begin
  if (fBaseObjMng<>m) then
  begin
    if ((fBaseObjMng<>nil)) or (m=nil) then
    begin
      unLincMng;
    end;
    // заменить ссылку на eng
    //ReplaceObjMng(m);
    if m<>nil then
    begin
      cBaseObjMng(m).Add(self);
    end;
  end;
end;

function cBaseObj.getMng:tobject;
begin
  result:=fBaseObjMng;
end;

procedure cBaseObj.ReplaceObjMng(mng:tobject);
begin
  fBaseObjMng:=mng;
end;

procedure cBaseObj.unLincMng;
begin
  if fBaseObjMng<>nil then
  begin
    cbaseobjmng(fBaseObjMng).removeobj(self);
  end;
  // отлинковать потомков
  //unlincChildrens;
  // отлинковать родителя
  parent:=nil;
end;

procedure cBaseObj.SetParentName(parentname:string);
var parentObj:cbaseobj;
begin
  parentObj:=cbaseobjmng(fbaseobjmng).getobj(parentname);
  if parent<>nil then
    parent:=parentObj;
end;


procedure cBaseObj.setShowInGraphs(b: boolean);
begin

end;

procedure cBaseObj.ShowComponent(node: pointer; component: tcomponent);
begin

end;

// Установка индекса картинки
procedure cBaseObj.setimageind(ind:integer);
begin
  fimageind:=ind;
end;

function cBaseObj.getimageindex:integer;
begin
  result:=fimageind;
end;

procedure cBaseObj.setImageList(p_imagelist:timagelist);
begin
  cbaseobjmng(fbaseobjmng).images_16:=p_imagelist;
end;

function cBaseObj.getImageList:timagelist;
begin
  if cbaseobjmng(fbaseobjmng)<>nil then
    result:=cbaseobjmng(fbaseobjmng).images_16
  else
    result:=nil;
end;


// Число потомков
function cBaseObj.ChildCount:integer;
begin
  if childrens<>nil then
    result:=childrens.count;
end;

procedure cBaseObj.setcaption(str:string);
begin
  f_caption:=str;
  fdefCaption:=false;
end;

function cBaseObj.GetParentName:string;
begin
  if fparent<>nil then
    result:=parent.name
  else
    result:='';
end;

procedure cBaseObj.DoBeforeLincParent;
begin

end;

procedure cBaseObj.doLincParent;
begin

end;

procedure cBaseObj.unlinc;
var
  I,c: Integer;
begin
  if fparent<>nil then
  begin
    DoBeforeLincParent;
    for I := 0 to parent.ChildCount - 1 do
    begin
      if fparent.getChild(i)=self then
      begin
        fparent.childrens.removeobj(i);
        c:=fparent.ChildCount;
        break;
      end;
    end;
    fparent:=nil;
    doLincParent;
  end;
end;

// Установка имени
procedure cBaseObj.setname(str:string);
var
  index, lcount:integer;
  b:boolean;
  obj:cbaseobj;
  lname:string;
begin
  lname:=fname;
  // отлинковываем от родителя
  if parent<>nil then
  begin
    parent.childrens.RemoveObj(self);
  end;
  if cBaseObjMng(fBaseObjMng)<>nil then
  begin
    b:=true;
    while b do
    begin
      obj:=cBaseObjMng(fBaseObjMng).getobj(str);
      if obj<>nil then
      begin
        if obj<>self then
        begin
          str:=modname(str, false)
        end
        else
          break;
      end
      else
        break;
    end;
    lcount:=cBaseObjMng(fBaseObjMng).count;
    // т.к. в этом методе подразумевается полное удаление из движка а не временное для переименования
    //cBaseObjMng(fBaseObjMng).removeobj(self);
    cBaseObjMng(fBaseObjMng).objects.removeobj(self);
    fname:=str;
    if lcount<>cBaseObjMng(fBaseObjMng).count then
    begin
      cBaseObjMng(fBaseObjMng).objects.addobj(self);
    end;
    cBaseObjMng(fBaseObjMng).Events.CallAllEventsWithSender(E_OnRenameObj,self);
  end
  else
    fname:=str;
  // прилинковываем к родителю
  if parent<>nil then
  begin
    parent.childrens.addobj(self);
  end;
  if fdefCaption then
    f_caption:=fname;
end;

procedure cBaseObj.setParent(p:cBaseObj);
begin
  if (p=nil) then
  begin
    unlinc;
  end;
  if (p<>nil) and (p<>fparent) then
  begin
    p.AddChild(self);
  end;
end;

procedure cBaseObj.AddChild(newChild:cBaseObj);
var
  index:integer;
  str:string;
  m:cbaseobjmng;
begin
  if SupportedChildClass(newChild) then
  begin
    newChild.DoBeforeLincParent;
    if newchild.getMng=nil then
    begin
      m:=cbaseobjmng(getMng);
      if m<>nil then
      begin
        newChild.setMng(m);
      end;
    end;
    if newChild.fparent<>nil then
    begin
      if newchild.fparent=self then
        exit;
      newChild.unlinc;
    end;
    str:=newChild.name;
    while childrens.Find(str,index) do
    begin
      str:=modname(str, true);
    end;
    if str<>newChild.name then
      newChild.name:=str;
    childrens.AddObj(newChild);
    newChild.fparent:=self;
    newChild.DoLincParent;
  end;
end;

procedure cBaseObj.lincTo(p_parent:cBaseObj);
begin
  p_parent.AddChild(self);
end;

// получить потомка по имени
function cBaseObj.GetChild(name:string):cBaseObj;
begin
  result:=childrens.getobj(name);
end;

function cBaseObj.getChild(i:integer):cBaseObj;
begin
  result:=childrens.getobj(i);
end;

function cBaseObj.fEnumGroupMembers(proc:enumProc;data:pointer;var continue:boolean):boolean;
var i:integer;
    obj:cBaseObj;
begin
  result:=true;
  if continue then
  begin
    continue:=proc(self, data);
    if continue then
    begin
      for I := 0 to ChildCount - 1 do
      begin
        obj:=getChild(i);
        obj.fEnumGroupMembers(proc, data, continue);
        if not continue then
          exit;
      end;
    end;
  end;
end;

procedure cBaseObj.EnumGroupMembers(proc:enumProc;data:pointer);
var
  continue:boolean;
begin
  continue:=true;
  fEnumGroupMembers(proc,data,continue);
end;

procedure cBaseObj.unlincChildrens;
var obj:cbaseobj;
begin
  while childcount<>0 do
  begin
    obj:=getChild(0);
    obj.parent:=nil;
  end;
end;

function cBaseObj.find(name:string;var index:integer):boolean;
begin
  result:=childrens.find(name,index);
end;

function cBaseObj.SupportedChildClass(obj:cbaseobj):boolean;
begin
  if obj is cbaseobj then
    result:=true
  else
    result:=false;
end;

function cBaseObj.SupportedChildClass(classname:string):boolean;
var
  i:integer;
begin
  result:=true;
end;

function cBaseObj.SupportedChildClass(objtype:integer):boolean;
begin
  result:=true;
end;

procedure cBaseObj.destroychildrens;
begin
  while childcount<>0 do
  begin
    deletechild(0);
  end;
end;

procedure cBaseObj.clear;
begin
  destroychildrens;
end;

procedure cBaseObj.deletechild(i:integer);
begin
  childrens.deletechild(i);
end;

procedure cBaseObj.deletechild(name:string);
begin
  childrens.deletechild(name);
end;

procedure cBaseObj.deletechild(node:pointer);
begin
  childrens.deleteobj(cbaseobj(node));
end;

function cBaseObj.GetParentByClassName(p_classname:string):cbaseobj;
var
  node:cbaseobj;
begin
  result:=nil;
  node:=self;
  while (node.parent<>nil) do
  begin
    if IsClass(node.parent,p_classname) then
    begin
      result:=node.parent;
      break;
    end;
    node:=node.parent;
  end;
end;

function cBaseObj.isParentObj(obj:cbaseobj):boolean;
var
  node:cbaseobj;
begin
  result:=false;
  node:=self;
  while node.parent<>nil do
  begin
    if node=obj then
    begin
      result:=true;
      break;
    end;
    node:=node.parent;
  end;
end;

function cBaseObj.HaveCommonParent(obj:cbaseobj):cbaseobj;
var
  node:cbaseobj;
begin
  result:=nil;
  node:=obj;
  while node.parent<>nil do
  begin
    if isParentObj(node) then
    begin
      result:=node;
      break;
    end;
    node:=node.parent;
  end;
end;

function CheckChild(obj:cBaseObj; data:pointer):boolean;
var
  cl:tclass;
begin
  result:=true;
  cl:=obj.ClassType;
  if cl.ClassName=slist(data).slisttext then
  begin
    slist(data).AddObject(obj.name,obj);
  end
  else
  begin
    while cl.ClassParent<>nil do
    begin
      cl:=cl.ClassParent;
      if obj.ClassParent.ClassName=slist(data).slisttext then
      begin
        slist(data).AddObject(obj.name,obj);
        exit;
      end;
    end;
  end;
end;

function cBaseObj.getChildrensByClassName(p_classname:ansistring):tstringlist;
var
  list:sList;
begin
  list:=sList.Create;
  list.slisttext:=p_classname;
  EnumGroupMembers(CheckChild, list);
  result:=list;
end;

function CheckChildCaption(obj:cBaseObj; data:pointer):boolean;
begin
  result:=true;
  if obj.caption=slist(data).slisttext then
  begin
    slist(data).AddObject(obj.name,obj);
    // прервать поиск
    result:=false;
  end;
end;

function cBaseObj.getChildrenByCaption(name:string):cbaseobj;
var
  list:sList;
begin
  list:=sList.Create;
  list.slisttext:=name;
  EnumGroupMembers(CheckChildCaption, list);
  if list.count>0 then
  begin
    result:=cbaseobj(list.Objects[0]);
  end
  else
    result:=nil;
  list.Destroy;
end;


function CheckChildName(obj:cBaseObj; data:pointer):boolean;
begin
  result:=true;
  if obj.Name=slist(data).slisttext then
  begin
    slist(data).AddObject(obj.name,obj);
    // прервать поиск
    result:=false;
  end;
end;


function cBaseObj.getChildrenByName(name:string):cbaseobj;
var
  list:sList;
begin
  list:=sList.Create;
  list.slisttext:=name;
  EnumGroupMembers(CheckChildName, list);
  if list.count>0 then
  begin
    result:=cbaseobj(list.Objects[0]);
  end
  else
    result:=nil;
  list.Destroy;
end;

function cBaseObj.findObj(key:pointer; var ind:integer):cbaseobj;
begin
  ind:=childrens.FindobjWithKey(key);
  if ind>=0 then
    result:=cbaseobj(childrens.Get(ind))
  else
    result:=nil;
end;

function cBaseObj.getdestroydata:boolean;
begin
  result:=childrens.destroydata;
end;

procedure cBaseObj.SetDestroyData(b:boolean);
begin
  childrens.destroydata:=b;
end;

procedure cBaseObj.LoadObjAttributes(xmlNode:txmlNode; mng:tobject);
begin

end;

procedure cBaseObj.SaveObjAttributes(xmlNode:txmlNode);
begin
  xmlNode.WriteAttributeBool('AutoCreate',autocreate);
end;

procedure cBaseObj.OnEngCreate;
begin

end;

procedure cBaseObj.CreateChildrens;
begin
  childrens:=cBaseObjList.create;
end;

function cBaseObj.getShowInGraphs:boolean;
begin
  result:=not fhelper;
end;

constructor cBaseObjList.create;
begin
  inherited;
  destroydata:=false;
  comparetype:=c_StrCompare;
end;

destructor cBaseObjList.destroy;
begin
  if destroydata then
    cleardata;
  inherited;
end;

// Удаление потомка (вызывает деструктор потомка и отвязывает от дерева)
procedure cBaseObjList.deletechild(i:integer);
var
  obj:cbaseobj;
  b:boolean;
begin
  //b:=false;
  obj:=cbaseobj(getobj(i));
  removeobj(i);
  //if obj.name='C_01' then
  //begin
  //  b:=true;
  //end;
  if not obj.blocked then
  begin
    if destroydata then
    begin
      //if b then
      //begin
      //  logRCInfo('c:\RCInfo5_.txt');
      //end;
      obj.destroy;
      //if b then
      //begin
      //  logRCInfo('c:\RCInfo5.txt');
      //  b:=false;
      //end;
    end;
  end
  else
    obj.fBaseObjMng:=nil;
end;


procedure cBaseObjList.removeobj(i:integer);
var
  obj:cbaseobj;
begin
  obj:=getobj(i);
  obj.list:=nil;
  inherited;
end;

procedure cBaseObjList.deletechild(name:string);
var
  i:integer;
begin
  if find(name,i) then
    deletechild(i);
end;

procedure cBaseObjList.deletechild(node:pointer);
begin
  cbaseobj(node).destroy;
end;

procedure cBaseObjList.deleteobj(obj:cbaseobj);
var
  i:integer;
  lobj:cbaseobj;
begin
  for I := 0 to count - 1 do
  begin
    lobj:=getobj(i);
    if lobj=obj then
    begin
      deletechild(i);
    end;
  end;
end;

procedure cBaseObjList.cleardata;
begin
  while count<>0 do
  begin
    deletechild(0);
  end;
end;

function cBaseObjList.getobj(name:string):cbaseobj;
var index:integer;
begin
  if not find(name,index) then
  begin
    result:=nil;
  end
  else
  begin
    result:=getobj(index);
  end;
end;

function cBaseObjList.find(obj:cbaseobj;var index:integer):boolean;
var i:integer;
begin
  result:=false;
  for I := 0 to count - 1 do
  begin
    if obj=getobj(i) then
    begin
      result:=true;
      index:=i;
      exit;
    end;
  end;
end;

function cBaseObjList.find(name:string;var index:integer):boolean;
var i:integer;
begin
  result:=false;
  if comparetype=c_StrCompare then
  begin
    index:=FindobjWithKey(@name);
    if index<>-1 then
      result:=true;
  end
  else
  begin
    for I := 0 to count - 1 do
    begin
      if name=getobj(i).name then
      begin
        result:=true;
        index:=i;
        exit;
      end;
    end;
  end;
end;

procedure cBaseObjList.setcomparetype(t:integer);
begin
  fcomparetype:=t;
  if t=c_strCompare then
  begin
    comparator:=NameComparator;
    keyComparator:=NameKeyComparator;
  end;
  if t=c_MetaCompare then
  begin
    // сортировка по свойству
    comparator:=MetaDataCompare;
  end;
  sorted:=true;
end;

procedure cBaseObjList.addobj(obj:cbaseobj);
begin
  obj.list:=self;
  inherited addobj(obj);
end;

procedure cBaseObjList.PrepareMetaDataSort(sortname:string;cl:tclass);
begin
  mDataName:=sortname;
  mDataClass:=cl;
end;

function cBaseObjList.getobj(i:integer):cbaseobj;
begin
  if i<Count then
    result:=cbaseobj(getnode(i))
  else
    result:=nil;
end;


end.
