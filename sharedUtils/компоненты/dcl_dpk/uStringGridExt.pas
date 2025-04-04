unit uStringGridExt;

interface
uses
  Windows,  SysUtils, Classes, Graphics, Dialogs,
  ComCtrls, controls, CommCtrl, Grids
  ;

type
  TStringGridExt = class(tstringgrid)
  public
    m_row, m_col:integer;
    CanDelFirstRow:boolean;
  protected
    //TSelectCellEvent = procedure (Sender: TObject; ACol, ARow: Longint;
    //  var CanSelect: Boolean) of object;
    fOnEndEdititng: TSelectCellEvent;
  protected
    function SelectCell(ACol: Integer; ARow: Integer): Boolean; override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    function rowempty(row:integer):boolean;
    procedure eraseRow(row:integer);
    procedure deleteRow(row:integer);
  published
    property OnEndEdititng: TSelectCellEvent read fOnEndEdititng write fOnEndEdititng;
    constructor create(aowner:tcomponent);override;
  end;

implementation

{ TStringGridExt }

constructor TStringGridExt.create(aowner: tcomponent);
begin
  inherited;
  CanDelFirstRow:=false;
end;

procedure TStringGridExt.deleteRow(row: integer);
var
  i,j: Integer;
begin
  for i:=row+1 to RowCount-1 do
  begin
    for j:=0 to ColCount-1 do
      Cells[j, i-1]:=Cells[j, i];
  end;
  RowCount:=RowCount-1;
end;



procedure TStringGridExt.KeyDown(var Key: Word; Shift: TShiftState);
var
  r:integer;
begin


  if row=0 then
  begin
    if not CanDelFirstRow then
      exit;
  end;

  if EditorMode=false then
  begin
    if key=VK_DELETE then
    begin
      if row=0 then
      begin
        if CanDelFirstRow then
          deleteRow(Row);
      end
      else
      begin
        if rowCount>2 then
          deleteRow(Row);
      end;
    end;
  end;
  inherited;
end;

procedure TStringGridExt.KeyPress(var Key: Char);
var
  l_canselect:boolean;
begin
  if key=#13 then
  begin
    if Assigned(fOnEndEdititng) then
    begin
      fOnEndEdititng(self,col, row, l_canselect);
    end;
  end;
  if key=char(vk_delete) then
  begin
    if Assigned(fOnEndEdititng) then
    begin
      fOnEndEdititng(self,col, row, l_canselect);
    end;
  end;
  inherited;
end;

function TStringGridExt.rowempty(row: integer): boolean;
var
  I: Integer;
begin
  result:=true;
  for I := 0 to ColCount - 1 do
  begin
    if cells[i, row] <>'' then
    begin
      result:=false;
      exit;
    end;
  end;
end;

procedure TStringGridExt.eraseRow(row: integer);
var
  I: Integer;
begin
  for I := 0 to ColCount - 1 do
  begin
    if cells[i, row] <>'' then
    begin
      cells[i, row] :='';
    end;
  end;
end;

function TStringGridExt.SelectCell(ACol, ARow: Integer): Boolean;
var
  l_canselect:boolean;
begin
  if (EditorMode=True) then
  begin
    if Assigned(fOnEndEdititng) then
    begin
      fOnEndEdititng(self, col, row, l_canselect);
    end;
  end;
  result:=inherited SelectCell(ACol, ARow);
end;

end.
