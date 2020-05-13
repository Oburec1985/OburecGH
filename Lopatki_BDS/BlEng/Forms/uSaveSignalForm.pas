unit uSaveSignalForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, ubldeng,
  Dialogs, StdCtrls, DCL_MYOWN, uMeraFile, ucommonmath, uMeraSignal;

type
  TSaveSignalsForm = class(TForm)
    TestNameEdit: TEdit;
    TestNameLabel: TLabel;
    DscEdit: TEdit;
    DscLabel: TLabel;
    FilePathEdit: TEdit;
    FilePathLabel: TLabel;
    Button1: TButton;
    SaveDialog1: TSaveDialog;
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    Mera3dCB: TCheckBox;
    FreqLabel: TLabel;
    FreqIE: TIntEdit;
    Label1: TLabel;
    ZSize: TIntEdit;
    Label2: TLabel;
    dZ: TIntEdit;
    WriteXYCheckBox: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Mera3dCBClick(Sender: TObject);
    procedure WriteXYCheckBoxClick(Sender: TObject);
  private
    ext, dir, name:string;
    signals:tstringlist;
  private
    function testOpts:cardinal;
  public
    function showmodal(alg:tobject):integer;
  end;

var
  SaveSignalsForm: TSaveSignalsForm;

implementation
uses
  uBaseBldAlg;

const
  c_FreqError = $00000001;
  c_PathError = $00000002;

{$R *.dfm}

function TSaveSignalsForm.testOpts:cardinal;
begin
  result:=0;
  if FreqIE.IntNum<=0 then
    setflag(Result,c_freqError);
end;

procedure TSaveSignalsForm.WriteXYCheckBoxClick(Sender: TObject);
begin
  freqie.Enabled:=not WriteXYCheckBox.checked;
end;

procedure TSaveSignalsForm.Button1Click(Sender: TObject);
var
  i:integer;
begin
  if SaveDialog1.Execute(handle) then
  begin
    case SaveDialog1.FilterIndex of
      1:
      begin
        ext:='.mera';
      end;
    end;
  end;
  FilePathEdit.Text:=SaveDialog1.FileName;
end;


procedure TSaveSignalsForm.Mera3dCBClick(Sender: TObject);
begin
  if mera3dcb.checked then
  begin
    freqie.IntNum:=1;
  end;
  freqie.enabled:=not mera3dcb.checked;
  ZSize.Enabled:=mera3dcb.checked;
  dz.Enabled:=mera3dcb.checked;
end;

function TSaveSignalsForm.showmodal(alg:tobject):integer;
var
  eng:cbldeng;
begin
  eng:=cBaseOpts(alg).eng;
  if cBaseOpts(alg).path='' then
  begin
    cBaseOpts(alg).path:=eng.SaveFolder+datetostr(now)+'\'+cBaseOpts(alg).testname+'\'+cBaseOpts(alg).testname+'.mera';
  end;
  zsize.IntNum:=cBaseOpts(alg).portionSize;
  Mera3dCB.Checked:=cBaseOpts(alg).b_3D;
  FreqIE.IntNum:=cBaseOpts(alg).SampleRate;

  filepathedit.text:=cBaseOpts(alg).path;
  TestNameEdit.text:=cBaseOpts(alg).testname;
  DscEdit.Text:=cBaseOpts(alg).dsc;
  result:=inherited showmodal;
  if result=mrok then
  begin
    cBaseOpts(alg).path:=filepathedit.text;
    cBaseOpts(alg).testname:=TestNameEdit.text;
    cBaseOpts(alg).dsc:=DscEdit.Text;
    if WriteXYCheckBox.checked then
      cBaseOpts(alg).SampleRate:=0
    else
      cBaseOpts(alg).SampleRate:=FreqIE.IntNum;
    cBaseOpts(alg).b_3D:=Mera3dCB.Checked;
    cBaseOpts(alg).portionSize:=zsize.IntNum;
    cBaseOpts(alg).dz:=dz.IntNum;

  end;
end;

end.
