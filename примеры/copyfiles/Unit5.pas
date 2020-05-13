unit Unit5;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl, XPMan, Math;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Button2: TButton;
    Button3: TButton;
    procedure BrowseClick(Sender: TObject);
    procedure StartClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Unit5_;

{$R *.dfm}

Type
  TProc = Procedure(Path:String;Size:Int64;Directory:Bool);

Var
  SizeAll,SizeAllCopied:Int64;
  Destination:String;
  Count:Integer;
  SPathLen:Integer;

Function CheckPath(Var Value:String):Bool;
Begin
  Result:=FileExists(Value);
  If Not Result
  Then
    Begin
      Result:=DirectoryExists(Value);
      Value:=IncludeTrailingPathDelimiter(Value);
    End;
End;

Procedure SizeAllFiles(Path:String;Size:Int64;Directory:Bool);
Begin
  If Not Directory
  Then
    Begin
      SizeAll:=SizeAll+Size;
      Inc(Count);
      Form2.Label3.Caption:=IntToStr(Count)+' files';
    End;
End;

Procedure CopyFileOrDirectory(Path:String;Size:Int64;Directory:Bool);
Const
  BlockSize = 64*1024;
Var
  _Path:String;
  SStream,DStream:TFileStream;
  _Size,SizeCopied:Int64;
Begin
  Form2.Label2.Caption:=Path;
  _Path:=Copy(Path,SPathLen+1,Length(Path)-SPathLen);
  If Directory
  Then
    ForceDirectories(Destination+_Path)
  Else
    Begin
      Form2.Gauge2.Progress:=0;
      SizeCopied:=0;
      SStream:=TFileStream.Create(Path,fmOpenRead);
      DStream:=TFileStream.Create(Destination+_Path,fmCreate);
      Repeat
        _Size:=DStream.CopyFrom(SStream,Min(BlockSize,SStream.Size-SStream.Position));
        SizeCopied:=SizeCopied+_Size;
        Form2.Gauge2.Progress:=SizeCopied*100 Div Size;
        SizeAllCopied:=SizeAllCopied+_Size;
        Form2.Gauge1.Progress:=SizeAllCopied*100 Div SizeAll;
        Application.ProcessMessages;
      Until SStream.Position>=SStream.Size;
      SStream.Free;
      DStream.Free;
    End;
End;

Procedure EnumFiles(Path:String;Proc:TProc);
Var
  SR:TSearchRec;
  Size:Int64;
  Flag:Bool;
  _Path,_Path_:String;
Begin
  _Path:=Path;
  If LastDelimiter(PathDelim,Path)=Length(Path)
  Then
    _Path:=_Path+'*.*';
  If FindFirst(_Path,faAnyFile,SR)=0
  Then
    Begin
      Repeat
        If (SR.Name<>'.') And (SR.Name<>'..')
        Then
          Begin
            Int64Rec(Size).Lo:=SR.FindData.nFileSizeLow;
            Int64Rec(Size).Hi:=SR.FindData.nFileSizeHigh;
            Flag:=SR.Attr And faDirectory=faDirectory;
            _Path_:=Path+SR.Name;
            If Flag
            Then
              _Path_:=IncludeTrailingPathDelimiter(_Path_);
            Proc(_Path_,Size,Flag);
            If Flag
            Then
              EnumFiles(_Path_,Proc);
          End;
      Until FindNext(SR)<>0;
      FindClose(SR);
    End;
End;

Function CopyFiles(Source,Dest:String):Bool;
Begin
  Result:=False;
  If CheckPath(Source) And CheckPath(Dest)
  Then
    Begin
      SPathLen:=Length(Source);
      SizeAll:=0;
      SizeAllCopied:=0;
      Destination:=Dest;
      Form2.Gauge1.Progress:=0;
      Form2.Gauge2.Progress:=0;
      Form2.Show;
      EnumFiles(Source,SizeAllFiles);
      EnumFiles(Source,CopyFileOrDirectory);
      Form2.Hide;
    End;
End;

procedure TForm1.BrowseClick(Sender: TObject);
Var
  Edit:TEdit;
  Directory:String;
begin
  Edit:=TEdit(FindComponent('Edit'+IntToStr(TButton(Sender).Tag)));
  If SelectDirectory('Browse directory','',Directory)
  Then
    Edit.Text:=Directory;
end;

procedure TForm1.StartClick(Sender: TObject);
begin
  CopyFiles(Edit1.Text,Edit2.Text);
end;

end.
