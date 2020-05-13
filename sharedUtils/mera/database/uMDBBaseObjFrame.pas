unit uMDBBaseObjFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtCtrls, uMeasureBase;

type
  TMDBBaseObjFrame = class(TFrame)
    PathEdit: TEdit;
    PathLabel: TLabel;
    DscEdit: TEdit;
    DscLabel: TLabel;
    Panel1: TPanel;
  private
    { Private declarations }
  public
    function SupportObj(obj:cxmlFolder):boolean;virtual;
    procedure init(p_db:cMBase);virtual;
    procedure showObjProps(obj:cXmlFolder);virtual;
  end;

implementation

{$R *.dfm}

{ TMDBBaseObjFrame }

procedure TMDBBaseObjFrame.init(p_db: cMBase);
begin

end;

procedure TMDBBaseObjFrame.showObjProps(obj: cXmlFolder);
begin
  PathEdit.Text:=obj.Absolutepath;
  DscEdit.text:=obj.dsc;
end;

function TMDBBaseObjFrame.SupportObj(obj: cxmlFolder): boolean;
begin
  result:=false;
  if obj is cObjFolder then
    result:=true;
  if  obj is cRegFolder then
    result:=true;
end;

end.
