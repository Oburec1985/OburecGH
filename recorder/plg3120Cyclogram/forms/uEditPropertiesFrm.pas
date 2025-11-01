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
  c_MNAlarmRow  = 9;
  c_MthresholdRow  = 10;
  c_NthresholdRow  = 11;
  c_ConditionRow  = 12; c_ModeRow  = 13;
  c_NRampRow  = 14; c_MRampRow = 15;
  c_StartRow  = 16;
  c_StopRow  = 17;

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
  m_t.m_data.Mthreshold:=strtofloatext(SG.Cells[1,c_MthresholdRow]);
  m_t.m_data.Nthreshold:=strtofloatext(SG.Cells[1,c_NthresholdRow]);
  m_t.m_data.ModeType:=strToModeType(SG.Cells[1,c_ModeRow]);
  m_t.m_data.Nramp:=strtofloatext(SG.Cells[1,c_NRampRow]);
  m_t.m_data.Mramp:=strtofloatext(SG.Cells[1,c_MRampRow]);

  m_t.m_data.cmd_start:=StrToB(SG.Cells[1,c_StartRow]);
  m_t.m_data.cmd_stop:=StrToB(SG.Cells[1,c_StopRow]);
  close;
  cb(mode);
end;


procedure TEditPropertiesFrm.SGDblClick(Sender: TObject);
var
  pPnt: TPoint; // Координаты курсора
  xCol, xRow: integer; // Адрес ячейки таблицы
begin
  GetCursorPos(pPnt);
  pPnt := TStringGrid(Sender).ScreenToClient(pPnt);
  // Находим позицию нашей ячейки
  xCol := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).X;
  xRow := TStringGrid(Sender).MouseCoord(pPnt.X, pPnt.Y).Y;
  if xCol=1 then
  begin
    // тип режима
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
    // Направление
    if xRow=c_ForwRow then
    begin
      if sg.Cells[xcol, xrow]='По часовой' then
        sg.Cells[xcol, xrow]:='Против часовой'
      else
        sg.Cells[xcol, xrow]:='По часовой'
    end;
    // тип режима
    if (xRow=c_TAlarmRow) or
       (xRow=c_PAlarmRow) or
       (xRow=c_MNAlarmRow) or
       (xRow=c_StartRow) or
       (xRow=c_StopRow)
    then
    begin
      if sg.Cells[xcol, xrow]='Вкл.' then
        sg.Cells[xcol, xrow]:='Выкл.'
      else
        sg.Cells[xcol, xrow]:='Вкл.'
    end;
  end;
end;

function dirtostr(b:boolean):string;
begin
  if b then
    result:='По часовой'
  Else
    result:='Против часовой';
end;

function dirtobool(s:string):boolean;
begin
  if s='По часовой' then
    result:=true
  else
    result:=false;
end;

function btostr(b:boolean):string;
begin
  if b then
    result:='Вкл.'
  Else
    result:='Выкл.';
end;

function strtob(b:string):boolean;
begin
  if b='Вкл.' then
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
  sg.RowCount:=17;
  sg.ColCount:=3;
  SG.cells[0,0]:='Канал';
  SG.cells[1,0]:='Значение';
  SG.Cells[0,c_Prow]:='P';
  SG.Cells[1,c_Prow]:=floattostr(t.m_data.p);

  SG.Cells[0,c_Irow]:='I';
  SG.Cells[1,c_Irow]:=floattostr(t.m_data.i);

  SG.Cells[0,c_Drow]:='D';
  SG.Cells[1,c_Drow]:=floattostr(t.m_data.d);

  SG.Cells[0,c_ForwRow]:='Направление';
  SG.Cells[1,c_ForwRow]:=dirtostr(t.m_data.forw);

  SG.Cells[0,c_TAlarmRow]:='Защита T';
  SG.Cells[1,c_TAlarmRow]:=btostr(t.m_data.TAlarm);

  SG.Cells[0,c_TthresholdRow]:='Уровень T';
  SG.Cells[1,c_TthresholdRow]:=floattostr(t.m_data.Tthreshold);

  SG.Cells[0,c_PAlarmRow]:='Защита Pм';
  SG.Cells[1,c_PAlarmRow]:=btostr(t.m_data.Palarm);

  SG.Cells[0,c_PthresholdRow]:='Уровень Pм';
  SG.Cells[1,c_PthresholdRow]:=floattostr(t.m_data.Pthreshold);

  SG.Cells[0,c_MNAlarmRow]:='Защита M/N';
  SG.Cells[1,c_MNAlarmRow]:=btostr(t.m_data.MNAlarm);

  SG.Cells[0,c_MthresholdRow]:='Уровень защиты M';
  SG.Cells[1,c_MthresholdRow]:=floattostr(t.m_data.Mthreshold);

  SG.Cells[0,c_NthresholdRow]:='Уровень защиты N';
  SG.Cells[1,c_NthresholdRow]:=floattostr(t.m_data.Nthreshold);

  SG.Cells[0,c_ConditionRow]:='Работа по усл.';  //SG.Cells[1,c_ConditionRow]:=;

  SG.Cells[0,c_ModeRow]:='Тип режима';
  case t.m_data.ModeType of
    mtN: sg.Cells[1,c_ModeRow]:='N';
    mtM: sg.Cells[1,c_ModeRow]:='M';
    mtStop: sg.Cells[1,c_ModeRow]:='Стоп';
  end;
  SG.Cells[0,c_NRampRow]:='Ограничение скор. N';
  SG.Cells[1,c_NRampRow]:=floattostr(t.m_data.Nramp);
  SG.Cells[0,c_MRampRow]:='Ограничение скор. M';
  SG.Cells[1,c_MRampRow]:=floattostr(t.m_data.Mramp);

  SG.Cells[0,c_StartRow]:='Команда Старт';
  SG.Cells[1,c_StartRow]:=btostr(t.m_data.cmd_start);
  SG.Cells[0,c_StopRow]:='Команда Стоп';
  SG.Cells[1,c_StopRow]:=btostr(t.m_data.cmd_stop);

  SGChange(sg);
end;


end.
