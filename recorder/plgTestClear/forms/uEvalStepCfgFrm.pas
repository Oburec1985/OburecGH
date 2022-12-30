unit uEvalStepCfgFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uTagsListFrame, ExtCtrls, DCL_MYOWN, Spin, uSpin,
  ubtnlistview, ComCtrls, tags,
  uRcCtrls, Buttons;

type
  TEvalStepCfgFrm = class(TForm)
    BottomPanel: TPanel;
    RightPanel: TPanel;
    TagsListFrame1: TTagsListFrame;
    AlgsLB: TListBox;
    MainPanel: TPanel;
    InChanLabel: TLabel;
    OutChanE: TEdit;
    OutChanLabel: TLabel;
    FFTCb: TCheckBox;
    FFTSizeSB: TSpinButton;
    FFTBlockSizeIE: TIntEdit;
    FFTBlockSizeLabel: TLabel;
    FFTShiftSB: TSpinButton;
    FFTShiftIE: TIntEdit;
    FFTShiftLabel: TLabel;
    TrigGB: TGroupBox;
    ThresholdSE: TFloatSpinEdit;
    ThresholdLabel: TLabel;
    OffsetSE: TFloatSpinEdit;
    OffsetLabel: TLabel;
    FsSE: TFloatSpinEdit;
    FsLabel: TLabel;
    InChanCB: TRcComboBox;
    InFsLabel: TLabel;
    InFsFE: TFloatEdit;
    FFTdxFE: TFloatEdit;
    FFTdxLabel: TLabel;
    UpdateAlgBtn: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure AlgsLBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure AlgsLBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FFTSizeSBDownClick(Sender: TObject);
    procedure FFTSizeSBUpClick(Sender: TObject);
    procedure AlgsLBKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EvalStepCfgFrm: TEvalStepCfgFrm;

implementation
uses
  uEvalStepAlg;

{$R *.dfm}

procedure TEvalStepCfgFrm.AlgsLBDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  li: tlistitem;
  t:itag;
  a:cEvalStepAlg;
  I: Integer;
begin
  if Source = TagsListFrame1.TagsLV then
  begin
    if source is  tlistview then
    begin
      li:=tbtnlistview(source).SelectFirst;
      if li<>nil then
      begin
        t:=itag(li.data);
        for I := 1 to tbtnlistview(source).SelCount - 1 do
        begin
          li:=tbtnlistview(source).GetNextItem(li, sdAll, isSelected);
          t:=itag(li.data);
        end;
      end;
    end;
    if t = nil then
      exit;
    a:=g_AlgList.addAlg(t.GetName);
    a.m_tag.tag:=t;
    InFsFE.FloatNum:=t.GetFreq;
    AlgsLB.AddItem(a.name,a);
  end;
end;

procedure TEvalStepCfgFrm.AlgsLBDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  li: tlistitem;
  obj: TObject;
begin
  if Source is tlistview then
  begin
    Accept := true;
  end;
end;

procedure TEvalStepCfgFrm.AlgsLBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  I: Integer;
  a:cEvalStepAlg;
begin
  if key=VK_DELETE then
  begin
    for I := 0 to AlgsLB.Count-1 do
    begin
      if AlgsLB.Selected[i] then
      begin
        a:=cEvalStepAlg(AlgsLB.Items.Objects[i]);
        g_AlgList.delAlg(a);
      end;
      AlgsLB.DeleteSelected;
    end;
  end;
end;

procedure TEvalStepCfgFrm.FFTSizeSBDownClick(Sender: TObject);
begin
  if sender = FFTSizeSB then
  begin
    if FFTBlockSizeIE.IntNum>2 then
      FFTBlockSizeIE.IntNum := round(FFTBlockSizeIE.IntNum/2);
  end;
  if sender = FFTShiftSB then
  begin
    if FFTShiftIE.IntNum>2 then
      FFTShiftIE.IntNum := round(FFTShiftIE.IntNum/2);
  end;

end;


procedure TEvalStepCfgFrm.FFTSizeSBUpClick(Sender: TObject);
begin
  if sender = FFTSizeSB then
  begin
    if FFTBlockSizeIE.IntNum>2 then
      FFTBlockSizeIE.IntNum:=FFTBlockSizeIE.IntNum*2;
  end;
  if sender = FFTShiftSB then
  begin
    if FFTShiftIE.IntNum>2 then
      FFTShiftIE.IntNum:=FFTShiftIE.IntNum*2;
  end;
end;

procedure TEvalStepCfgFrm.FormShow(Sender: TObject);
begin
  TagsListFrame1.ShowChannels;
end;

end.
