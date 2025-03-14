unit uChanFrame;

interface

uses
  Windows, Forms, StdCtrls, DCL_MYOWN, sysutils, uBldObj, uChan, Controls, Classes,
  ComCtrls, uBtnListView, uTickData, uBldMath, uMyMath, uCommonMath;

type
  TChanFrame = class(TFrame)
    CommonGB: TGroupBox;
    ImpulsCountLabel: TLabel;
    ChanLVLabel: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ImpulsCountIE: TIntEdit;
    ChanLV: TBtnListView;
    ShowAllCB: TCheckBox;
    TickEdit: TIntEdit;
    ResIndEdit: TIntEdit;
    OverflowLabel: TLabel;
    OverflowIE: TIntEdit;
    procedure ShowAllCBClick(Sender: TObject);
    procedure TickEditEnter(Sender: TObject);
  private
    mchan:cchan;
  private
    procedure showchan(chan:cchan);
  public
    procedure getObj(obj:cbldobj);
    constructor create(aowner:tcomponent);override;
  end;


implementation

{$R *.dfm}

const
  c_colNumber = '�';
  c_colTick = '����� � �����';
  c_colTime = '�����, ���.';

procedure initChanLV(lv:tlistview);
var
  col:tlistcolumn;
begin
  lv.Columns.Clear;
  col:=lv.Columns.Add;
  col.Caption:=c_colNumber;
  col:=lv.Columns.Add;
  col.Caption:=c_colTick;
  col:=lv.Columns.Add;
  col.Caption:=c_colTime;
end;

constructor TChanFrame.create(aowner:tcomponent);
begin
  inherited;
  initchanlv(ChanLV);
end;

procedure TChanFrame.getObj(obj:cbldobj);
var
  chan:cchan;
begin
  chan:=cchan(obj);
  mchan:=chan;
  // ����� ��������� �� �������
  impulscountie.IntNum:=chan.ticksCount;
  showchan(chan);
end;

procedure TChanFrame.TickEditEnter(Sender: TObject);
var
  tick:stickdata;
  i:integer;
begin
  if mchan<>nil then
  begin
    tick.OverflowCount:=overflowie.IntNum;
    tick.data:=tickEdit.IntNum;
    mchan.ticks.GetLow(@tick,i);
    ResIndEdit.IntNum:=i;
  end;
end;

procedure TChanFrame.ShowAllCBClick(Sender: TObject);
begin
  showchan(mchan);
end;

procedure TChanFrame.showchan(chan:cchan);
var
  c,I: Integer;
  li:tlistitem;
  str:string;
  tick:stickdata;
  time:single;
begin
  chanlv.Clear;
  if not showAllCB.Checked then
    c:=min(chan.ticks.Count,1000)
  else
    c:=chan.ticks.Count;
  for I := 0 to c - 1 do
  begin
    li:=ChanLV.Items.Add;
    tick:=chan.ticks.gettick(i);
    // ����� ������
    chanlv.SetSubItemByColumnName(c_colNumber, inttostr(i), li);
    // ����� ������
    str:=inttostr(tick.Data)+'/ '+inttostr(tick.OverflowCount);
    chanlv.SetSubItemByColumnName(c_colTick, str, li);
    // ����� ������
    time:=TickToSec(tick);
    chanlv.SetSubItemByColumnName(c_colTime, TruncFloatNumString(floattostr(time),3), li);
  end;
end;

end.
