unit uDownloadRegsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, pathutils,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, uBtnListView, uMeasureBase, uBaseObj,
  uPathMng, uComponentServises, ImgList, uCommonMath, inifiles;

type
  TDownloadRegsFrm = class(TForm)
    ActionPanel: TPanel;
    DownloadBtn: TButton;
    RegsLV: TBtnListView;
    ImageList_16: TImageList;
    DelBatRegsBtn: TButton;
    RenameCB: TCheckBox;
    UncheckAll: TCheckBox;
    procedure DownloadBtnClick(Sender: TObject);
    procedure DelBatRegsBtnClick(Sender: TObject);
    procedure UncheckAllClick(Sender: TObject);
  private
    m_db:cMBase;
  public
    Procedure ShowDB(db:cMBase);
  end;

var
  DownloadRegsFrm: TDownloadRegsFrm;


implementation

{$R *.dfm}

const
  c_image_del=0;
  c_image_ok=1;


{ TDownloadRegsFrm }

procedure TDownloadRegsFrm.DelBatRegsBtnClick(Sender: TObject);
var
  I, j: Integer;
  li:tlistitem;
  r:cRegFolder;
  s:TBaseSignal;
  sigFolder, str:string;
  del:boolean;
begin
  r:=nil;
  for I := 0 to RegsLV.items.Count - 1 do
  begin
    li:=RegsLV.Items[i];
    if li.ImageIndex=c_image_del then
    begin
      r:=cregfolder(li.data);
      RegsLV.GetSubItemByColumnName('Путь',li,sigFolder);
      for j:= 0 to r.m_signals.Count - 1 do
      begin
        s:=r.getSignal(j);
        // удаляем из регистрации сигнал которого не существует на диске сетевого ПК
        if s.m_path=sigfolder then
        begin
          s.Destroy;
          r.m_signals.Delete(j);
          r.CreateXMLDesc;
          break;
        end;
      end;
    end;
    del:=true;
    if r<>nil then
    begin
      for j := 0 to r.m_signals.Count - 1 do
      begin
        s:=r.getSignal(j);
        if s.m_path<>'' then
        begin
          del:=false;
          break;
        end;
      end;
      if del then
      begin
        r.delFolder;
        r.destroy;
      end;
    end;
  end;
  i:=0;
  while I <=RegsLV.items.Count - 1 do
  begin
    li:=RegsLV.Items[i];
    if li.ImageIndex=c_image_del then
    begin
      li.Destroy;
    end
    else
      inc(i);
  end;
end;

procedure TDownloadRegsFrm.DownloadBtnClick(Sender: TObject);
var
  I, j: Integer;
  li:tlistitem;
  reg:cRegFolder;
  test:cTestFolder;
  obj:cObjFolder;
  s:tbasesignal;
  path, newpath, oldpath, newname:string;

  ifile:tinifile;
begin
  for I := 0 to RegsLV.items.Count - 1 do
  begin
    li:=RegsLV.Items[i];
    if li.Checked then
    begin
      reg:=cRegFolder(li.data);
      for j := 0 to reg.m_signals.Count - 1 do
      begin
        RegsLV.GetSubItemByColumnName('Путь',li,path);
        s:=reg.getSignal(j);
        if s.m_path=path then
        begin
          // s.m_folder - 'D:\USML\signal0436\signal0436.mera' в случае локального Recorder
          // reg.Absolutepath='D:\mera\mdb\Obj_001\Test_001\Reg_0028'
          //if s. then
          newpath:=AddSlashToPath(reg.Absolutepath)+s.m_RCname;
          path:=ExtractFileDir(path);
          if CopyDir(path, newpath, handle) then
          begin
            oldpath:=s.m_path;
            s.m_path:=newpath+'\'+extractfilename(s.m_path);
            s.m_copy:=true;
            li.Checked:=false;
            if renameCB.Checked then
            begin
              // переименование mera файла и изменение описания
              ifile:=tinifile.Create(s.m_path);
              ifile.WriteString('Mera','Test','Файл источник='+ExtractFilename(s.m_path));
              ifile.destroy;
              test:=cTestFolder(reg.parent);
              obj:=cobjfolder(test.parent);
              newname:=s.m_RCname+'_'+obj.name+'_'+test.name+'_'+reg.name+'.mera';
              RenameFile(s.m_path, extractfiledir(s.m_path)+'\'+newname);
              s.m_path:=newpath+'\'+newname;
            end;
          end;
          continue;
        end;
      end;
      reg.CreateXMLDesc;
    end;
  end;
  i:=0;
  while i<RegsLV.items.Count do
  begin
    li:=RegsLV.Items[i];
    if not li.Checked then
    begin
      li.Delete;
    end
    else
      inc(i);
  end;
end;

procedure TDownloadRegsFrm.ShowDB(db:cMBase);
var
  I: Integer;
  obj:cbaseobj;
  reg:cRegFolder;
  testobj, test:cxmlfolder;
  j: Integer;
  s:tbasesignal;
  li:tlistitem;
begin
  m_db:=db;
  regslv.clear;
  for I := 0 to m_db.Count - 1 do
  begin
    obj:=m_db.GetObj(i);
    if obj is cRegFolder then
    begin
      reg:=obj as cRegFolder;
      if not reg.empty then
      begin
        if not reg.Complete then
        begin
          if not reg.rar then
          begin
            for j := 0 to reg.m_signals.Count - 1 do
            begin
              s:=reg.getSignal(j);
              if s.m_path<>'' then
              begin
                if not s.m_copy then
                begin
                  li:=regslv.Items.Add;
                  regslv.SetSubItemByColumnName('Регистрация',reg.caption, li);
                  if fileexists(s.m_path) then
                    li.ImageIndex:=c_image_ok
                  else
                    li.ImageIndex:=c_image_del;
                  regslv.SetSubItemByColumnName('Путь',s.m_path, li);
                  test:=cxmlfolder(reg.GetParentByClassName('cTestFolder'));
                  testObj:=cxmlfolder(test.GetParentByClassName('cObjFolder'));
                  regslv.SetSubItemByColumnName('Объект',testObj.path, li);
                  regslv.SetSubItemByColumnName('Испытание',test.path, li);
                  li.Checked:=true;
                  li.data:=reg;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  LVChange(regsLV);
  Show;
end;

procedure TDownloadRegsFrm.UncheckAllClick(Sender: TObject);
var
  I: Integer;
  li:TListItem;
begin
  if not UncheckAll.Checked then
  begin
    for I := 0 to regsLV.items.Count - 1 do
    begin
      li:=RegsLV.Items[i];
      li.Checked:=false;
    end;
  end;

end;

end.
