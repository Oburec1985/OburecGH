unit LoadBldForm;

interface

uses
  Windows, SysUtils,  Classes, uLoadBldFrame, uTreeStageCfg, forms,
  uBldFile, Controls, StdCtrls;

type
  TLoadBldF = class(TForm)
    LoadBldFrame1: TLoadBldFrame;
    TreeBldCfgFrame1: TTreeBldCfgFrame;
    GroupBox1: TGroupBox;
    CancelBtn: TButton;
    OkBtn: TButton;
  private
  public
    function ShowModal(filename:string; BldFile:cbldfilegen):integer;
  end;

var
  LoadBldF: TLoadBldF;

implementation
{$R *.dfm}

function TLoadBldF.ShowModal(filename:string; BldFile:cbldfilegen):integer;
var newBldFile:cBldFileGen;
begin
  TreeBldCfgFrame1.LincTree(bldFile);
  newBldFile:=cBldFileGen.Create;
  newBldFile.GetFile(filename);
  newBldFile.Load;
  LoadBldFrame1.update(newBldFile,filename);
  if inherited showmodal=mrok then
  begin
     bldFile:=newBldFile;
  end;
end;

end.
