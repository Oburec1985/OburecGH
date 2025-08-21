unit uEditPropertiesFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, uCommonMath, uComponentServises,
  uModeObj, ucontrolObj;

type
  TEditPropertiesFrm = class(TForm)
    Panel1: TPanel;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    SG: TStringGrid;
    procedure ApplyBtnClick(Sender: TObject);
    procedure SGDblClick(Sender: TObject);
  public
    m_t:ctask;
    mode:cmodeobj;
    cb:tnotifyevent;
  public
    procedure ShowMN(t:ctask);
  end;

var
  EditPropertiesFrm: TEditPropertiesFrm;


function btostr(b:boolean):string;
function strtob(b:string):boolean;
function dirtostr(b:boolean):string;
function dirtobool(s:string):boolean;

const
  c_Prow  =1;   c_Irow  =2;  c_Drow  =3; c_ForwRow  =4;
  c_TAlarmRow  = 5; c_TthresholdRow  = 6;
  c_PAlarmRow  = 7; c_PthresholdRow  = 8;
  c_MNAlarmRow  = 9; c_MNthresholdRow  = 10;
  c_ConditionRow  = 11; c_ModeRow  = 12;
  c_NRampRow  = 13;

implementation

{$R *.dfm}

procedure TEditPropertiesFrm.ApplyBtnClick(Sender: TObject);
begin
  m_t.applyed:=false;
  m_t.m_data.P:=strtofloatext(SG.Cells[1,c_Prow]);
  m_t.m_data.I:=strtofloatext(SG.Cells[1,c_Irow]);
  m_t.m_data.D:=strtofloatext(SG.Cells[1,c_Drow]);
  m_t.m_data.forw:=dirtobool(SG.Cells[1,c_ForwRow]);
  m_t.m_data.TAlarm:=StrToB(SG.Cells[1,c_TAlarmRow]);
  m_t.m_data.Tthreshold:=strtofloatext(SG.Cells[1,c_TthresholdRow]);
  m_t.m_data.Palarm:=StrToB(SG.Cells[1,c_PAlarmRow]);
  m_t.m_data.Pthreshold:=strtofloatext(SG.Cells[1,c_PthresholdRow]);
  m_t.m_data.MNAlarm:=StrToB(SG.Cells[1,c_MNAlarmRow]);
  m_t.m_data.MNthreshold:=strtofloatext(SG.Cells[1,c_MNthresholdRow]);
  m_t.m_data.ModeType:=strToModeType(SG.Cells[1,c_ModeRow]);
  m_t.m_data.Nramp:=strtofloatext(SG.Cells[1,c_NRampRow]);
  close;
  cb(mode);
end;


procedure TEditPropertiesFrm.SGDblClick(Sender: TObject);
var
  pPnt: TPoint; // ���������� �������
  xCol, xRow: integer; // ����� ������ �������
begin
  GetCursorPos(pPnt);
  pPnt := TStringGrid(Sender).ScreenToClient(pPnt);
  // ������� ������� ����� ������
  xCol := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).X;
  xRow := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).Y;
  if xCol=1 then
  begin
    // ��� ������
    if xRow=c_ModeRow then
    begin
      if sg.Cells[xcol, xrow]='N' then
        sg.Cells[xcol, xrow]:='M'
      else
      begin
        if sg.Cells[xcol, xrow]='M' then
          sg.Cells[xcol, xrow]:='Stop'
        else
        begin
          sg.Cells[xcol, xrow]:='N'
        end;
      end;
    end;
    // �����������
    if xRow=c_ForwRow then
    begin
      if sg.Cells[xcol, xrow]='�� �������' then
        sg.Cells[xcol, xrow]:='������ �������'
      else
        sg.Cells[xcol, xrow]:='�� �������'
    end;
    // ��� ������
    if (xRow=c_TAlarmRow) or
       (xRow=c_PAlarmRow) or
       (xRow=c_MNAlarmRow)
    then
    begin
      if sg.Cells[xcol, xrow]='���.' then
        sg.Cells[xcol, xrow]:='����.'
      else
        sg.Cells[xcol, xrow]:='���.'
    end;

  end;
end;

function dirtostr(b:boolean):string;
begin
  if b then
    result:='�� �������'
  Else
    result:='������ �������';
end;

function dirtobool(s:string):boolean;
begin
  if s='�� �������' then
    result:=true
  else
    result:=false;
end;

function btostr(b:boolean):string;
begin
  if b then
    result:='���.'
  Else
    result:='����.';
end;

function strtob(b:string):boolean;
begin
  if b='���.' then
    result:=true
  Else
    result:=false;
end;

procedure TEditPropertiesFrm.ShowMN(t:ctask);
var
  i:integer;
begin
  m_t:=t;
  FormStyle:=fsStayOnTop;
  Show;
  sg.RowCount:=14;
  sg.ColCount:=3;
  SG.cells[0,0]:='�����';
  SG.cells[1,0]:='��������';
  SG.Cells[0,c_Prow]:='P';
  SG.Cells[1,c_Prow]:=floattostr(t.m_data.p);

  SG.Cells[0,c_Irow]:='I';
  SG.Cells[1,c_Irow]:=floattostr(t.m_data.i);

  SG.Cells[0,c_Drow]:='D';
  SG.Cells[1,c_Drow]:=floattostr(t.m_data.d);

  SG.Cells[0,c_ForwRow]:='�����������';
  SG.Cells[1,c_ForwRow]:=dirtostr(t.m_data.forw);

  SG.Cells[0,c_TAlarmRow]:='������ T';
  SG.Cells[1,c_TAlarmRow]:=btostr(t.m_data.TAlarm);

  SG.Cells[0,c_TthresholdRow]:='������� T';
  SG.Cells[1,c_TthresholdRow]:=floattostr(t.m_data.Tthreshold);

  SG.Cells[0,c_PAlarmRow]:='������ P�';
  SG.Cells[1,c_PAlarmRow]:=btostr(t.m_data.Palarm);

  SG.Cells[0,c_PthresholdRow]:='������� P�';
  SG.Cells[1,c_PthresholdRow]:=floattostr(t.m_data.Pthreshold);

  SG.Cells[0,c_MNAlarmRow]:='������ M/N';
  SG.Cells[1,c_MNAlarmRow]:=btostr(t.m_data.MNAlarm);

  SG.Cells[0,c_MNthresholdRow]:='������� M/N';
  SG.Cells[1,c_MNthresholdRow]:=floattostr(t.m_data.MNthreshold);

  SG.Cells[0,c_ConditionRow]:='������ �� ���.';  //SG.Cells[1,c_ConditionRow]:=;

  SG.Cells[0,c_ModeRow]:='��� ������';
  case t.m_data.ModeType of
    mtN: sg.Cells[1,c_ModeRow]:='N';
    mtM: sg.Cells[1,c_ModeRow]:='M';
    mtStop: sg.Cells[1,c_ModeRow]:='����';
  end;
  SG.Cells[0,c_NRampRow]:='����������� ����. N';
  SG.Cells[1,c_NRampRow]:=floattostr(t.m_data.Nramp);
  SGChange(sg);
end;


end.
