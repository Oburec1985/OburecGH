unit uBaseObjFrame;

interface

uses
  Windows, Classes, Forms,  StdCtrls, Controls, uBaseObj;

type
  TBaseObjPropertyFrame = class(TFrame)
    CommonGB: TGroupBox;
    NameEdit: TEdit;
    NameLabel: TLabel;
    TypeEdit: TEdit;
    TypeLabel: TLabel;
  private
    { Private declarations }
  public
    procedure GetObj(obj:cBaseObj);
  end;

implementation

{$R *.dfm}
procedure TBaseObjPropertyFrame.GetObj(obj:cBaseObj);
begin

end;

end.
