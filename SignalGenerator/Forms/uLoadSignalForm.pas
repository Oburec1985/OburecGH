unit uLoadSignalForm;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, umerasignal, inifiles, uCommonTypes,
  Dialogs, StdCtrls, DCL_MYOWN, Controls, umerafile, ubuffsignal;

type
  TLoadSignalForm = class(TForm)
    PathBtn: TButton;
    OpenDialog1: TOpenDialog;
    PathEdit: TEdit;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    procedure PathBtnClick(Sender: TObject);
  public
    signals:cMeraFile;
  private
  public
    function LoadMera(path:string):boolean;
    function LoadSignals(p_signals:cMeraFile):boolean;
  end;

var
  LoadSignalForm: TLoadSignalForm;

implementation

{$R *.dfm}

function TLoadSignalForm.LoadSignals(p_signals:cMeraFile):boolean;
begin
  result:=false;
  signals:=p_signals;
  if showmodal=mrok then
  begin
    result:=LoadMera(PathEdit.Text);
    signals.Load(PathEdit.Text);
  end;
end;

procedure TLoadSignalForm.PathBtnClick(Sender: TObject);
begin
  if OpenDialog1.execute then
  begin
    pathedit.Text:=opendialog1.FileName;
  end;
end;

function TLoadSignalForm.LoadMera(path:string):boolean;
var
  fname:string;
begin
  result:=false;
  if fileexists(path) then
  begin
    LoadSignalForm.signals:=signals;
    signals.load(path);
    result:=true;
  end;
end;

end.
