unit u3120Db;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  inifiles, uStringGridExt,  Dialogs, StdCtrls, ExtCtrls, Grids, ComCtrls,
  uBtnListView, uComponentServises,
  activex,
  cfreg, blaccess, uCommonMath, PathUtils,
  uMeasureBase, DB, DBClient,
  Menus, ScktComp, ShlObj;


// создание базы данных
procedure InitDB;
procedure createObj(obj, test:string);
// получить имя новой регистрации
function getNewReg(t: cXmlFolder): cXmlFolder;
function TestPath:string;
function BasePath:string;
// отобразить объекты базы в CB
procedure ShowDB(ObjCb, TestCb:tcombobox; selobj, seltest:string);

var
  g_obj, g_test, g_reg:cXmlFolder;

implementation

procedure InitDB;
begin
  // объявлена в uMeasureBase
  g_mbase:=cMBase.create;
  g_mbase.InitBaseFolder('c:\Mera Files\3120Base\');
end;

procedure ShowDB(ObjCb, TestCb:tcombobox; selobj, seltest:string);
var
  I: Integer;
  o:cxmlfolder;
  s:string;
begin
  if ObjCb<>nil then
  begin
    ObjCb.Clear;
    for I := 0 to g_mbase.m_BaseFolder.ChildCount - 1 do
    begin
      o:=cxmlfolder(g_mbase.m_BaseFolder.getChild(i));
      ObjCb.AddItem(o.name,o);
    end;
    if selobj='' then
      Objcb.ItemIndex:=0
    else
      setComboBoxItem(selobj, Objcb);
    if Objcb.ItemIndex>-1 then
      g_obj:=cxmlfolder(Objcb.Items.Objects[Objcb.ItemIndex])
    else
      g_obj:=nil;
  end;
  if TestCb<>nil then
  begin
    TestCb.Clear;
    for I := 0 to g_obj.ChildCount - 1 do
    begin
      o:=cxmlfolder(g_obj.getChild(i));
      TestCb.AddItem(o.name,o);
    end;
    if seltest='' then
      TestCb.ItemIndex:=0
    else
      setComboBoxItem(seltest, TestCb);
    if TestCb.ItemIndex>-1 then
      g_test:=cxmlfolder(TestCb.Items.Objects[TestCb.ItemIndex])
    else
      g_test:=nil;
  end;
end;


procedure createObj(obj, test:string);
var
  r:string;
begin
  if g_mbase=nil then
    initdb;
  if obj='' then
    exit;
  g_obj:=cxmlfolder(g_mbase.getobj(obj));
  if g_obj=nil then
  begin
    g_obj := cObjFolder.Create;
    // для вновь создаваемых нет смысла что то искать внутри
    g_obj.scanFolder := false;
    g_obj.scanFile := false;
    g_mbase.m_BaseFolder.AddChild(g_obj);
    g_obj.Path := obj;
    // создаем описатели и каталог
    g_obj.CreateFiles;
  end;
  if test='' then
    exit;
  // создаем испытание
  g_test:=cxmlfolder(g_obj.getChild(test));
  if g_test=nil then
  begin
    g_test := cTestFolder.Create;
    //cTestFolder(g_test).ObjType:=Test;
    g_test.name := Test;
    // для вновь создаваемых нет смысла что то искать внутри
    g_test.scanFolder := false;
    g_test.scanFile := false;
    g_obj.AddChild(g_test);
    g_test.Path := test;
    g_test.caption := test;
    g_test.CreateFiles;
  end;
  g_reg:=getNewReg(cTestfolder(g_test));
end;

function getNewReg(t: cXmlFolder): cXmlFolder;
var
  fld: string;
  reg: cregFolder;
begin
  reg:=nil;
  if t.ChildCount>0 then
  begin
    reg:=cregfolder(t.getChild(t.ChildCount-1));
    if reg.empty then
    begin
      result:=reg;
      exit;
    end;
  end;
  reg:=cRegFolder.create;
  reg.name:='Reg_'+inttostr(t.ChildCount+1);
  reg.caption:='Reg_'+inttostr(t.ChildCount+1);
  t.AddChild(reg);
  result:=reg;
end;

function TestPath:string;
begin
  if g_test<>nil then
    result:=g_test.Absolutepath
  else
    result:='';
end;

function BasePath:string;
begin
  result:=g_mbase.m_BaseFolder.Absolutepath;
end;

end.
