unit uSpmFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uwpSpmFrame, ExtCtrls, StdCtrls;

type
  TSpmFrm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    WPSpmFrame1: TWPSpmFrame;
  public
    constructor Create(AOwner: TComponent); override;
    function ShowmodalEx(str:string):string;
  end;

var
  SpmFrm: TSpmFrm;

const
  c_spmopts='isFill0=1,typeWindow=1,typeMagnitude=1,kindFunc=4,numPoints=16384';

implementation

uses
  uLocalizationHelper;

{$R *.dfm}

constructor TSpmFrm.Create(AOwner: TComponent);
begin
  inherited;
  TranslateForm(Self);
end;


function TSpmFrm.ShowmodalEx(str:string):string;
var
  i:integer;
begin
  wpspmFrame1.SetOpts(str);
  i:=inherited Showmodal;
  if i=mrok then
  begin
    result:=wpspmFrame1.getopts;
  end;
end;

end.
