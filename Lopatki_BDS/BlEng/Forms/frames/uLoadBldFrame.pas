unit uLoadBldFrame;

interface

uses
  Windows, Messages, SysUtils, Forms,
  StdCtrls, uBtnListView, uBldFile, Controls, Classes, ComCtrls, uBldService;

type
  TLoadBldFrame = class(TFrame)
    SensorsLV: TBtnListView;
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    Label1: TLabel;
  private
  public
    procedure update(bldfile:cbldfilegen; filename:string);
  end;

implementation

{$R *.dfm}

procedure TLoadBldFrame.update(bldfile:cbldfilegen;filename:string);
begin
  showSensorsInLV(SensorsLV,bldfile);
  Edit1.Text:=filename;
end;

end.
