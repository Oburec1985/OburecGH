unit uGetSensorsForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  ExtCtrls, StdCtrls,
  ubldeng, ubtnlistview, usensorlist, usensor,
  ComCtrls, uBldCompProc;

type
  TSelectSensorsForm = class(TForm)
    SensorsLV: TBtnListView;
    SelectActionGB: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
  private

  public
    procedure ShowModal(sensors:calgsensorlist; eng:cbldeng);
    constructor create(aowner:tcomponent);override;
  end;

var
  SelectSensorsForm: TSelectSensorsForm;

implementation

{$R *.dfm}
constructor TSelectSensorsForm.create(aowner:tcomponent);
begin
  inherited;
  initSensorsLV(SensorsLV);
end;

procedure TSelectSensorsForm.ShowModal(sensors:calgsensorlist; eng:cbldeng);
var
  I,scount: Integer;
  li:tlistitem;
begin
  sensors.clear;
  ShowEngSensorsInLV(SensorsLV,eng);
  scount:=0;
  if inherited showmodal=mrok then
  begin
    for I := sensorsLV.Selected.Index to sensorsLV.items.count - 1 do
    begin
      li:=sensorsLV.items[i];
      if li.Selected then
      begin
        inc(scount);
        sensors.add(csensor(li.Data));
        if scount=sensorsLV.SelCount then
          exit;
      end;
    end;
  end;
end;

end.
