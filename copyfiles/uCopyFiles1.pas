unit uCopyFiles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, inifiles, uComponentServises,
  Dialogs, ExtCtrls, ComCtrls, uBtnListView, StdCtrls, activeX, shellApi, uCommonMath, uCommonTypes,uPathMng;

type
  Trec = class
  public
    src,dst:string;
    rewrite:boolean;
  public
    function Check:integer;
    function isFile:boolean;
    function getProp:string;
  end;

  TCopyFilesFrm = class(TForm)
    GroupBox1: TGroupBox;
    FilesLV: TBtnListView;
    Panel1: TPanel;
    Button1: TButton;
    SrcFileEdit: TEdit;
    DstFolderEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    DstFileEdit: TEdit;
    FullPathLabel: TLabel;
    SrcFolderEdit: TEdit;
    Label4: TLabel;
    ExecBtn: TButton;
    procedure FilesLVDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FilesLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ExecBtnClick(Sender: TObject);
    procedure FilesLVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    strlist:tstringlist;
    m_drag:boolean;
  private
    procedure addrow(r:trec);
    procedure updaterow(li:tlistitem);
    procedure ShowSelected;
    procedure EditSelected;
    procedure delRecords;
    procedure checkfiles;
    procedure save;
    procedure load;
  protected
    procedure WMDropFiles (var Msg: TMessage); message wm_DropFiles;
  public
    { Public declarations }
  end;

var
  CopyFilesFrm: TCopyFilesFrm;

const
  c_fail = -1;
  c_ident = 1;
  c_ok = 0;

  COL_SRC   = 'Исходный путь';
  COL_DST   = 'Назначение';
  COL_PROPS = 'Аттрибуты';
  COL_NO =    '№';

implementation

{$R *.dfm}

{ TCopyFilesFrm }
procedure TCopyFilesFrm.Button1Click(Sender: TObject);
begin
  EditSelected;
  checkfiles;
end;

procedure TCopyFilesFrm.checkfiles;
var
  I: Integer;
  li:tlistitem;
  r:TRec;
begin
  for I := 0 to FilesLV.items.Count - 1 do
  begin
    li:=FilesLV.items[i];
    r:=Trec(li.data);
    case r.Check of
      c_ok: FilesLV.DelColorItem(li.index);
      c_fail: FilesLV.addColorItem(li.index,clred);
      c_ident: FilesLV.addColorItem(li.index,cllightGreen);
    end;
  end;
  FilesLV.Invalidate;
end;

procedure TCopyFilesFrm.delRecords;
var
  I: Integer;
  li:tlistitem;
  r:TRec;
begin
  for I := 0 to FilesLV.items.Count - 1 do
  begin
    li:=FilesLV.items[i];
    r:=Trec(li.data);
    r.destroy;
  end;
  FilesLV.Clear;
end;

procedure TCopyFilesFrm.FilesLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if ctState = Change then
  begin
    ShowSelected;
  end;
end;

procedure TCopyFilesFrm.FilesLVDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  fname:string;
  I: Integer;
  li:tlistitem;
  r:trec;
begin
  delRecords;
  for I := 0 to strlist.Count - 1 do
  begin
    fname:=strlist.Strings[i];
    li:=FilesLV.Items.Add;
    r:=Trec.Create;
    li.Data:=r;
    r.src:=fname;
    FilesLV.SetSubItemByColumnName(COL_SRC, fname, li);
    FilesLV.SetSubItemByColumnName(COL_NO, inttostr(i), li);
    FilesLV.SetSubItemByColumnName(COL_PROPS, r.getProp, li);
  end;
  LVChange(FilesLV);
end;


procedure TCopyFilesFrm.FilesLVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  I: Integer;
  li:tlistitem;
  r:trec;
begin
  if key=VK_DELETE then
  begin
    li:=FilesLV.Selected;
    for I := 0 to FilesLV.SelCount - 1 do
    begin
      r:=trec(li.data);
      r.Destroy;
      li:=FilesLV.GetNextItem(li, sdBelow, [IsSelected]);
    end;
    FilesLV.DeleteSelected;
  end;
end;

procedure TCopyFilesFrm.FormCreate(Sender: TObject);
begin
  strlist:=TStringList.Create;
  DragAcceptFiles(Handle, true);
  load;
  checkfiles;
end;

procedure TCopyFilesFrm.FormDestroy(Sender: TObject);
begin
  save;
  strlist.Destroy;
end;

procedure TCopyFilesFrm.load;
var
  I, count: Integer;
  ifile:tinifile;
  cfg, section:string;
  r:Trec;
begin
  cfg:=ExtractFileDir(Application.ExeName)+'\cfg.ini';
  ifile:=TIniFile.Create(cfg);
  count:=ifile.ReadInteger('main','count', 0);
  for I := 0 to Count - 1 do
  begin
    section:='file_'+IntToStr(i);
    r        :=trec.Create;
    r.src    :=ifile.ReadString(section,'src',  '');
    r.dst    :=ifile.ReadString(section,'dst',  '');
    r.rewrite:=ifile.ReadBool  (section,'rewrite',  false);
    addrow(r);
  end;
  LVChange(FilesLV);
  ifile.Destroy;
end;

procedure TCopyFilesFrm.save;
var
  I: Integer;
  ifile:tinifile;
  cfg, section:string;
  r:Trec;
begin
  cfg:=ExtractFileDir(Application.ExeName)+'\cfg.ini';
  ifile:=TIniFile.Create(cfg);
  ifile.WriteInteger('main','count', FilesLV.items.Count);
  for I := 0 to FilesLV.items.Count - 1 do
  begin

    section:='file_'+IntToStr(i);
    r:=FilesLV.items[i].Data;
    ifile.WriteString(section,'src',r.src);
    ifile.WriteString(section,'dst',r.dst);
    ifile.WriteBool(section,'rewrite',  r.rewrite);
  end;
  ifile.Destroy;
end;

procedure TCopyFilesFrm.ShowSelected;
var
  I: Integer;
  li:tlistitem;
  r:trec;
begin
  li:=FilesLV.Selected;
  for I := 0 to FilesLV.SelCount - 1 do
  begin
    r:=trec(li.data);
    SetMultiSelectComponentString(srcFileEdit, extractfilename(r.src));
    SetMultiSelectComponentString(srcFolderEdit, extractfiledir(r.src));
    SetMultiSelectComponentString(DstFolderEdit, extractfiledir(r.dst));
    SetMultiSelectComponentString(DstFileEdit, extractfilename(r.dst));
    li:=FilesLV.GetNextItem(li, sdBelow, [IsSelected]);
  end;
  endMultiSelect(srcfileedit);
  endMultiSelect(srcfolderedit);
  endMultiSelect(DstFolderEdit);
  endMultiSelect(DstFileEdit);
  FullPathLabel.Caption:='Полный путь: '+DstFolderEdit.Text+'\'+DstFileEdit.text;
end;

procedure TCopyFilesFrm.updaterow(li:tlistitem);
var
  fname:string;
  I: Integer;
  r:trec;
begin
  r:=trec(li.data);
  FilesLV.SetSubItemByColumnName(COL_SRC, r.src, li);
  FilesLV.SetSubItemByColumnName(COL_DST, r.dst, li);
  FilesLV.SetSubItemByColumnName(COL_NO, inttostr(li.Index), li);
  FilesLV.SetSubItemByColumnName(COL_PROPS, r.getProp, li);
end;

procedure TCopyFilesFrm.addrow(r:trec);
var
  fname:string;
  li:tlistitem;
begin
  li:=FilesLV.Items.Add;
  li.data:=r;
  FilesLV.SetSubItemByColumnName(COL_SRC, r.src, li);
  FilesLV.SetSubItemByColumnName(COL_DST, r.dst, li);
  FilesLV.SetSubItemByColumnName(COL_NO, inttostr(li.Index), li);
  FilesLV.SetSubItemByColumnName(COL_PROPS, r.getProp, li);
end;

procedure TCopyFilesFrm.EditSelected;
var
  I: Integer;
  li:tlistitem;
  r:trec;
begin
  li:=FilesLV.Selected;
  for I := 0 to FilesLV.SelCount - 1 do
  begin
    r:=trec(li.data);
    if srcfolderedit.text<>'' then
      r.src:=srcfolderedit.text+'\'+ExtractFileName(r.src);
    if srcfileedit.text<>'' then
      r.src:=ExtractFileDir(r.src)+'\'+srcfileedit.text;

    if dstfolderedit.text<>'' then
      r.dst:=dstfolderedit.text+'\'+ExtractFileName(r.dst);
    if dstfileedit.text<>'' then
      r.dst:=ExtractFileDir(r.dst)+'\'+dstfileedit.text;
    updaterow(li);

    li:=FilesLV.GetNextItem(li, sdBelow, [IsSelected]);
  end;
  LVChange(FilesLV);
  //for I := 0 to FilesLV.SelCount - 1 do
  //begin
  //  li:=li:=FilesLV.items[i];
  //end;
end;

function getPWideStr(str:string):pWideChar;
var
  res:widestring;
begin
  res:=str+widechar(0);
  result:=@res[1];
end;

procedure TCopyFilesFrm.ExecBtnClick(Sender: TObject);
var
  I:Integer;
  li:tlistitem;
  r:Trec;
  res, b:boolean;
  outdir:string;
begin
  for I := 0 to FilesLV.items.Count - 1 do
  begin
    li:=FilesLV.Items[i];
    r:=Trec(li.data);
    if r.Check<>c_fail then
    begin
      if r.isFile then
      begin
        outdir:=extractfiledir(r.dst);
        if not DirectoryExists(outdir) then
          ForceDirectories(outdir);
        if fileexists(r.dst) then
          DeleteFile(r.dst);
        CopyFile(pwidechar(r.src), pwidechar(r.dst),res);
        //b:=CopyFileEx(pchar(r.src), pchar(r.dst),nil,nil,@res,COPY_FILE_FAIL_IF_EXISTS);
      end
      ELSE
      BEGIN
        CopyDir(r.src, r.dst);
      END;
    end;
  end;
  checkfiles;
end;

procedure TCopyFilesFrm.WMDropFiles(var Msg: TMessage);
var
  i, amount, size: integer;
  Filename: PChar;
begin
  inherited;
  strlist.Clear;
  Amount := DragQueryFile(Msg.WParam, $FFFFFFFF, Filename, 255);
  for i := 0 to (Amount - 1) do
  begin
    size := DragQueryFile(Msg.WParam, i, nil, 0) + 1;
    Filename := StrAlloc(size);
    DragQueryFile(Msg.WParam, i, Filename, size);
    strlist.Add(StrPas(Filename));
    StrDispose(Filename);
  end;
  DragFinish(Msg.WParam);
  FilesLVDragDrop(nil,nil,0,0);
end;

{ Trec }
function Trec.Check: integer;
begin
  result:=c_ok;
  if not fileexists(src) then
    result:=c_fail
  else
  begin
    if isfile then
    begin
      if fileexists(dst) then
      begin
        if CompareFiles(src, dst, false) then
          result:=c_ident;
      end;
    end;
  end;
end;

function Trec.getProp: string;
begin
  result:='';
  if isfile then
  begin
    result:=result+'file';
  end
  else
  begin
    result:=result+'folder';
  end;
  if rewrite then
  begin
    result:=result+';RW';
  end;
end;

function Trec.isFile: boolean;
begin
  result:=uPathMng.isfile(src);
end;

end.
