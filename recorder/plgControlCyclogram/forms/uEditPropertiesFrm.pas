unit uEditPropertiesFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, uCommonMath;

type
  TEditPropertiesFrm = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    SG: TStringGrid;
    procedure ApplyBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    fExecute:boolean;
  public
    data, data1:pointer;
    fApplyCallBack:TNotifyEvent;
  public
    procedure SecCallBack(cb:TNotifyEvent; p_data:pointer);
    procedure SetTextToTags(str:string);
    //procedure SetTextZoneList(str:string);
    function Execute:boolean;
  end;

var
  EditPropertiesFrm: TEditPropertiesFrm;

implementation

{$R *.dfm}

procedure TEditPropertiesFrm.SetTextToTags(str:string);
var
  pars:tstringlist;
  I: Integer;
  cs:cstring;
begin
  SG.cells[0,0]:='Канал';
  SG.cells[1,1]:='Значение';

  pars:=ParsStrParamNoSort(str, ';');
  SG.RowCount:=pars.Count+2;
  for I := 0 to pars.Count - 1 do
  begin
    cs:=CString(pars.Objects[i]);
    SG.cells[0,i+1]:=pars.Strings[i];
    SG.cells[1,i+1]:=cs.str;
  end;
  delpars(pars);
  pars.Destroy;
end;

procedure TEditPropertiesFrm.ApplyBtnClick(Sender: TObject);
begin
  hide;
  if Assigned(fApplyCallBack) then
    fApplyCallBack(data);
  fExecute:=false;
end;

procedure TEditPropertiesFrm.CancelBtnClick(Sender: TObject);
begin
  hide;
end;

function TEditPropertiesFrm.Execute: boolean;
begin
  show;
end;

procedure TEditPropertiesFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ApplyBtnClick(nil);
end;

procedure TEditPropertiesFrm.SecCallBack(cb: TNotifyEvent; p_data: pointer);
begin
  fApplyCallBack:=cb;
  data:=p_data;
end;


end.
