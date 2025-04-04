unit uMDBTestObjFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uMDBBaseObjFrame, ExtCtrls, StdCtrls, uMeasureBase, uComponentServises,
  ComCtrls;


type
  // ��� �������� File>>New>>Inheritable item
  TMDBTestObjFrame = class(TMDBBaseObjFrame)
    TestTypeCB: TComboBox;
    TestTypeLabel: TLabel;
    TestDate: TDateTimePicker;
    TestDateLabel: TLabel;
  private
    { Private declarations }
  public
    procedure init(p_db:cMBase);override;
    procedure showObjProps(obj:cXmlFolder);override;
    function SupportObj(obj:cxmlFolder):boolean;override;
  end;

var
  MDBTestObjFrame: TMDBTestObjFrame;

implementation

{$R *.dfm}

{ TMDBBaseObjFrame1 }

procedure TMDBTestObjFrame.init(p_db: cMBase);
var
  I: Integer;
  str:string;
begin
  inherited;
  for I := 0 to cBaseMeaFolder(p_db.m_BaseFolder).m_TestTypes.Count - 1 do
  begin
    str:=cBaseMeaFolder(p_db.m_BaseFolder).m_TestTypes.Strings[i];
    TestTypeCB.AddItem(str, nil);
  end;
end;

procedure TMDBTestObjFrame.showObjProps(obj: cXmlFolder);
begin
  inherited;
  setComboBoxItem(ctestFolder(obj).ObjType, TestTypeCB);
  TestDate.DateTime:=ctestFolder(obj).DateTime;
end;

function TMDBTestObjFrame.SupportObj(obj: cxmlFolder): boolean;
begin
  if obj is cTestFolder then
    result:=true
  else
  begin
    result:=false;
  end;
end;

end.
