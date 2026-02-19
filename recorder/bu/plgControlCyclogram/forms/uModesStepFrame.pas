unit uModesStepFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, uControlObj, uCommonTypes, uCommonMath, uComponentServises;

type
  TModesStepFrame = class(TFrame)
    ModesSG: TStringGrid;
    procedure ModesSGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ModesSGSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure ModesStepSGGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
  private
    m_val:string;
    m_row,m_col:integer;
    m_p:cProgramObj;
    namelist:tstringlist;
  protected
    function checkStepName(s:string):boolean;
    function getColumnInd(s:string):integer;
    function getStepName(col:integer):string;
    procedure InitSG;
    procedure setInterval(row:integer;m:cModeObj);
    procedure getnamelist(p:cprogramobj);
    function GetMode(row: integer): cmodeobj;
    function GetModeName(row: integer): string;
  public
    procedure UpdateModesIntervalSG;
    procedure ModesSGEditCell(ARow, ACol: Integer; const Value: string);
    procedure ShowProgram(p:cprogramobj);
    constructor create(aOwner:tcomponent);override;
    destructor destroy;override;
  end;

const
  c_headerRows = 1;
  c_headerColumns = 2;
  C_Mode_Col = 0;
  C_Interval_Col = 1;
  C_Control_Col = 2;

implementation

{$R *.dfm}

procedure TModesStepFrame.UpdateModesIntervalSG;
var
  i, row, col:integer;
  m:cmodeobj;
begin
  for i:= 0 to m_p.ModeCount - 1 do
  begin
    row:=i+c_headerRows;
    m:=m_p.getMode(i);
    ModesSG.Cells[C_Mode_Col, row] := m.name;
    setInterval(row,m);
  end;
end;

function TModesStepFrame.checkStepName(s: string):boolean;
var
  I: Integer;
begin
  result:=true;
  for I := 0 to namelist.Count - 1 do
  begin
    if s=namelist.Strings[i] then
    begin
      result:=false;
      exit;
    end;
  end;
end;

function TModesStepFrame.getColumnInd(s:string):integer;
var
  I: Integer;
begin
  i:=-1;
  for I := 0 to ModesSG.ColCount - 1 do
  begin
    if s=ModesSG.Cells[i,0] then
    begin
      result:=i;
      exit;
    end;
  end;
end;

function TModesStepFrame.getStepName(col:integer):string;
begin

  result:=ModesSG.Cells[col,0];
end;

constructor TModesStepFrame.create(aOwner: tcomponent);
begin
  inherited;
  InitSG;
  namelist:=TStringList.Create;
end;

destructor TModesStepFrame.destroy;
begin
  namelist.Destroy;
  namelist:=nil;
  inherited;
end;

procedure TModesStepFrame.getnamelist(p:cprogramobj);
var
  m:cmodeobj;
  i, j, column:integer;
  step:cstepval;
begin
  column:=c_headerColumns;
  for I := 0 to p.ModeCount - 1 do
  begin
    m:=p.getMode(i);
    for j := 0 to m.stepValCount - 1 do
    begin
      step:=m.getstepval(j);
      if checkStepName(step.tagname) then
      begin
        ModesSG.Cells[column,0]:=step.tagname;
        namelist.Add(step.tagname);
      end;
    end;
  end;
end;

procedure TModesStepFrame.InitSG;
begin
  ModesSG.RowCount:=2;
  ModesSG.ColCount:=2;
  ModesSG.Cells[C_Mode_Col, 0] := 'Режим';
  ModesSG.Cells[C_Interval_Col, 0] := 'Время';
end;

function TModesStepFrame.GetMode(row: integer): cmodeobj;
var
  str:string;
begin
  str:=GetModeName(row);
  result:=m_p.getMode(str);
end;


function TModesStepFrame.GetModeName(row: integer): string;
begin
  result:=ModesSG.Cells[C_Mode_Col, row];
end;

procedure TModesStepFrame.ModesSGEditCell(ARow, ACol: Integer; const Value: string);
var
  m:cmodeobj;
  t:ctask;
  step:cstepval;
  stepname:string;
begin
  M:=GetMode(arow);
  if ACol>c_Interval_Col then
  begin
    if isValue(value) then
    begin
      stepname:=getStepName(acol);
      step:=m.getstepval(stepname);
      if step=nil then
      begin
        m.addstepTag(stepname,strtofloat(value));
      end
      else
      begin
        step.m_val:=strtofloat(value);
      end;
    end;
  end;
  if ACol=c_Interval_Col then
  begin
    // возвращаем что было
    setInterval(arow,m);
  end;
end;

procedure TModesStepFrame.ModesStepSGGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: string);
begin
  ModesSGSetEditText(sender, acol, arow, value);
end;

procedure TModesStepFrame.ModesSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_RETURN then
  begin
    ModesSGEditCell(m_row, m_col, m_val);
    SGChange(ModesSG);
  end;
end;

procedure TModesStepFrame.ModesSGSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
begin
  m_val:=value;
  m_col:=acol;
  m_row:=arow;
  ModesSGEditCell(m_row, m_col, m_val);
end;

procedure TModesStepFrame.setInterval(row: integer; m: cModeObj);
var
  p2:point2d;
begin
  p2:=m.gettimeinterval;
  ModesSG.Cells[C_Interval_Col, row] := floattostr(p2.x)+'..'+floattostr(p2.y);
end;

procedure TModesStepFrame.ShowProgram(p: cprogramobj);
var
  I, j, row, col: Integer;
  m:cModeObj;
  step:cstepval;
begin
  m_p:=p;
  getnamelist(p);
  ModesSG.RowCount:=p.ModeCount+c_headerRows;
  ModesSG.ColCount:=namelist.count+c_headerColumns;
  for I := 0 to namelist.Count - 1 do
  begin
    col:=c_headerColumns+i;
    ModesSG.Cells[col,0]:=namelist.Strings[i];
  end;
  row:=c_headerRows;
  for I := 0 to p.ModeCount - 1 do
  begin
    m:=p.getMode(i);
    ModesSG.Cells[C_Mode_Col, row] := m.name;
    setInterval(row,m);
    for j := 0 to m.stepValCount - 1 do
    begin
      step:=m.getstepval(j);
      col:=getColumnInd(step.tagname);
      ModesSG.Cells[col,row]:=floattostr(step.m_val);
    end;
    inc(row);
  end;
end;

end.
