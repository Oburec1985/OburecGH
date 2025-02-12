unit uUTSFrame;

interface

uses
  Windows, SysUtils, Classes, Forms, uUtsSensor, ubldobj, uChan, uBldGlobalStrings,
  StdCtrls, ComCtrls, uBtnListView, uBaseObjService, utickdata, Controls,
  uBldCompProc;

type
  TUTSFrame = class(TFrame)
    UTSChannel: TComboBox;
    UtsLabel: TLabel;
    UTSLV: TBtnListView;
    SEVCB: TComboBox;
    SignalTypeLabel: TLabel;
  private
    s:cUTSSensor;
  private
    procedure initUtsLV;
    procedure ShowTicks;
    procedure addtick(tick:stickdata; t:double);
    // ��������� � �������
    function GetTime(tick:stickdata):double;
  public
    //  ���������� �������� ������� � �����
    procedure GetObj(obj:cbldobj);
    //  ��������� �������� ������� �� ������ � ������
    procedure SetObj(obj:cbldobj);
    constructor create(aOwner:tcomponent);override;
  end;

implementation

{$R *.dfm}

procedure TUTSFrame.initUtsLV;
var
  col:tlistcolumn;
begin

  UTSLV.Columns.Clear;
  col:=UTSLV.Columns.Add;
  col.Caption:=v_ColNum;
  col.width:=100;
  // ��������� ������� ����� � �����
  col:=UTSLV.Columns.Add;
  col.Caption:=v_ColTick;
  col.width:=100;
  // ��������� ������� ����� � ��������
  col:=UTSLV.Columns.Add;
  col.Caption:=v_Time;
  col.width:=100;
end;

procedure TUTSFrame.addtick(tick:stickdata; t:double);
var
  li:tlistitem;
begin
  li:=UTSLV.items.Add;
  UTSLV.SetSubItemByColumnName(v_ColNum, inttostr(li.Index), li);
  UTSLV.SetSubItemByColumnName(v_ColTick, ticktostr(tick),  li);
  UTSLV.SetSubItemByColumnName(v_Time, floattostr(t), li);
end;

procedure TUTSFrame.ShowTicks;
var
  I: Integer;
begin
  UTSLV.Clear;
  for I := 0 to s.Count - 1 do
  begin
    addtick(s.gettick(i),s.gettime(i));
  end;
end;

procedure TUTSFrame.GetObj(obj:cbldobj);
begin

  s:=cUTSSensor(obj);
  showChanInCB(s.eng,UTSChannel);
  if s.channumber<>-1 then
  begin
    if s.chan<>nil then
      UTSChannel.text:=s.chan.name;
  end;
  if s.UTSSignalType=IRIG_B then
  begin
    SEVCB.ItemIndex:=0;
  end
  else
  begin
    SEVCB.ItemIndex:=1;
  end;
  if s.chan<>nil then
    ShowTicks;
end;

procedure TUTSFrame.SetObj(obj:cbldobj);
begin
  if UTSChannel.ItemIndex<>-1 then
  begin
    s.SetUtsChan(cChan(UTSChannel.Items.Objects[UTSChannel.ItemIndex]));
    if SEVCB.ItemIndex=0 then
    begin
      s.UTSSignalType:=IRIG_B;
    end
    else
    begin
      s.UTSSignalType:=UTS;
    end;
    ShowTicks;
  end;
end;

constructor TUTSFrame.create(aOwner:tcomponent);
begin
  inherited;
  initUtsLV;
end;

function TUTSFrame.GetTime(tick:stickdata):double;
var
  lo:integer;
begin

end;

end.
