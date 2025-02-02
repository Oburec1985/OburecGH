unit uMDBRegObjFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uMDBBaseObjFrame, ExtCtrls, StdCtrls, uMeasureBase, uComponentServises,
  ComCtrls, uBtnListView;

type
  TMDBRegObjFrame = class(TMDBBaseObjFrame)
    TestDateLabel: TLabel;
    TestDate: TDateTimePicker;
    RegistratorLV: TBtnListView;
  private
    procedure ShowRegistrators(r:cregFolder);
  public
    procedure init(p_db:cMBase);override;
    procedure showObjProps(obj:cXmlFolder);override;
    function SupportObj(obj:cxmlFolder):boolean;override;
  end;

var
  MDBRegObjFrame: TMDBRegObjFrame;

implementation

{$R *.dfm}


procedure TMDBRegObjFrame.init(p_db: cMBase);
var
  I: Integer;
  str:string;
begin
  inherited;
end;

procedure TMDBRegObjFrame.showObjProps(obj: cXmlFolder);
begin
  inherited;
  TestDate.DateTime:=cRegFolder(obj).DateTime;
  ShowRegistrators(cRegFolder(obj));
end;

procedure TMDBRegObjFrame.ShowRegistrators(r: cregFolder);
var
  I: Integer;
  s:TBaseSignal;
  li:tlistitem;
begin
  RegistratorLV.clear;
  for I := 0 to r.m_signals.Count - 1 do
  begin
    s:=r.getSignal(i);
    li:=RegistratorLV.Items.Add;
    RegistratorLV.SetSubItemByColumnName('�����������',s.m_RCname,li);
    RegistratorLV.SetSubItemByColumnName('�����',s.m_path,li);
  end;
  LVChange(RegistratorLV);
end;

function TMDBRegObjFrame.SupportObj(obj: cxmlFolder): boolean;
begin
  if obj is cRegFolder then
    result:=true
  else
  begin
    result:=false;
  end;
end;

end.
