unit uEvalStepCfgFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uTagsListFrame, ExtCtrls, DCL_MYOWN, Spin, uSpin,
  ubtnlistview, ComCtrls, tags, uComponentservises, uRCFunc, uCommonTypes,
  uCommonMath, MathFunction,
  uRcCtrls, Buttons, Grids, math;

type
  TEvalStepCfgFrm = class(TForm)
    BottomPanel: TPanel;
    RightPanel: TPanel;
    TagsListFrame1: TTagsListFrame;
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
    BlockSizeFE: TFloatEdit;
    BlockSizeFLabel: TLabel;
    LeftPanel: TPanel;
    AlgsLB: TListBox;
    ScalesLV: TBtnListView;
    FltRG: TRadioGroup;
    ScalarTagCB: TCheckBox;
    ValTypeRG: TRadioGroup;
    MeanGB: TGroupBox;
    TrigMeanLenFE: TFloatSpinEdit;
    TrigMeanLenLabel: TLabel;
    Label1: TLabel;
    TrigMeanLenIE: TIntEdit;
    procedure FormShow(Sender: TObject);
    procedure AlgsLBDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure AlgsLBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FFTSizeSBDownClick(Sender: TObject);
    procedure FFTSizeSBUpClick(Sender: TObject);
    procedure AlgsLBKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AlgsLBMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AlgsLBClick(Sender: TObject);
    procedure UpdateAlgBtnClick(Sender: TObject);
    procedure FFTBlockSizeIEChange(Sender: TObject);
    procedure FltRGClick(Sender: TObject);
    procedure TrigTypeValCBClick(Sender: TObject);
    procedure ValTypeRGClick(Sender: TObject);
    procedure TrigMeanLenFEChange(Sender: TObject);
    procedure TrigMeanLenIEChange(Sender: TObject);
  private
    fSel:tobject;
  private
    // отобразить размер блока в норм формате
    procedure ShowBlockSize(t:double);
    procedure UpdateSel;
    procedure EndMsel;
    procedure ShowAlg(a: TObject);
    procedure UpdateAlg(a: TObject);
    function  GenOutTag(str: string; freq:double): itag;
  public
    { Public declarations }
  end;

var
  EvalStepCfgFrm: TEvalStepCfgFrm;

implementation

uses
  uEvalStepAlg;
{$R *.dfm}

procedure TEvalStepCfgFrm.EndMsel;
begin
  // m_pars обновлен в inherited
  endMultiSelect(FFTShiftIE);
  endMultiSelect(FFTBlockSizeIE);
  endMultiSelect(ThresholdSE);
  endMultiSelect(OffsetSE);
  endMultiSelect(FFTCb);
  endMultiSelect(InFsFE);
  endMultiSelect(InChanCB);
  endMultiSelect(BlockSizeFE);
  endMultiSelect(OutChanE);
  endMultiSelect(FsSE);
  endMultiSelect(FltRG);
  endMultiSelect(FFTdxFE);
  endMultiSelect(ValTypeRG);
  endMultiSelect(TrigMeanLenIE);
  endMultiSelect(ScalarTagCB);
end;

procedure TEvalStepCfgFrm.ShowAlg(a: TObject);
var
  t: ctag;
begin
  SetMultiSelectComponentString(FFTShiftIE, inttostr(cEvalStepAlg(a).m_fftShift));
  SetMultiSelectComponentString(FFTBlockSizeIE, inttostr(cEvalStepAlg(a).m_fftCount));
  SetMultiSelectComponentString(ThresholdSE, floattostr(cEvalStepAlg(a).m_Threshold));
  SetMultiSelectComponentString(OffsetSE, floattostr(cEvalStepAlg(a).m_TrigOffset));
  SetMultiSelectComponentBool(FFTCb, cEvalStepAlg(a).m_fftFlt);
  SetMultiSelectItemInd(FltRG, cEvalStepAlg(a).m_fltType);
  SetMultiSelectComponentBool(ScalarTagCB, cEvalStepAlg(a).m_useScalar);
  SetMultiSelectItemInd(ValTypeRG, cEvalStepAlg(a).m_TrigType);
  SetMultiSelectComponentString(TrigMeanLenIE, inttostr(cEvalStepAlg(a).m_TrigMeanLenI));
  t := cEvalStepAlg(a).m_tag;
  if t.tag <> nil then
  begin
    SetMultiSelectComponentString(InFsFE, floattostr(t.tag.GetFreq));
    SetMultiSelectComponentString(InChanCB, t.tag.GetName);
    SetMultiSelectComponentString(BlockSizeFE, floattostr(1 / t.tag.GetFreq * cEvalStepAlg(a).m_fftCount));
    SetMultiSelectComponentString(OutChanE, cEvalStepAlg(a).m_outTag.tagname);
    SetMultiSelectComponentString(FsSE, floattostr(cEvalStepAlg(a).m_outTag.tag.GetFreq));
    if cEvalStepAlg(a).m_fftCount<>0 then
    begin
      SetMultiSelectComponentString(FFTdxFE, floattostr(t.tag.GetFreq/cEvalStepAlg(a).m_fftCount));
    end
    else
    begin
      SetMultiSelectComponentString(FFTdxFE, '0');
    end;
  end;
  FltRGClick(nil);
end;

procedure TEvalStepCfgFrm.ShowBlockSize(t: double);
begin
  if t<0.1 then
  begin
    BlockSizeFe.FloatNum:=t*1000;
    BlockSizeFLabel.Caption:='Размер блока, мс';
  end
  else
  begin
    BlockSizeFe.FloatNum:=t;
    BlockSizeFLabel.Caption:='Размер блока, сек';
  end;
end;

procedure TEvalStepCfgFrm.TrigMeanLenFEChange(Sender: TObject);
begin
  if fsel<>nil then
  begin
    if cEvalStepAlg(fSel).m_outTag.freq<>0 then
      TrigMeanLenIE.IntNum:=round(TrigMeanLenFE.Value*cEvalStepAlg(fSel).m_outTag.freq);
  end;
end;

procedure TEvalStepCfgFrm.TrigMeanLenIEChange(Sender: TObject);
begin
  if fsel<>nil then
  begin
    if TrigMeanLenIE.Text<>'' then
    begin
      if cEvalStepAlg(fSel).m_outTag.freq<>0 then
        TrigMeanLenFE.Value:=TrigMeanLenIE.IntNum/cEvalStepAlg(fSel).m_outTag.freq;
    end;
  end;
end;

procedure TEvalStepCfgFrm.TrigTypeValCBClick(Sender: TObject);
begin
  MeanGB.Visible:=false;
  case ValTypeRG.ItemIndex of
    0: ValTypeRG.Caption:='Мгновенное значение';
    1: MeanGB.Visible:=true;
  end;
end;

procedure TEvalStepCfgFrm.UpdateAlg(a: TObject);
var
  t: itag;
  i,l,j:integer;
  p2:point2d;
  str:string;
  li:tlistitem;
begin
  if FltRG.ItemIndex=3 then
  begin
    if l<>0 then
    begin
      setlength(cEvalStepAlg(a).m_band, ScalesLV.Items.Count);
      for I := 0 to ScalesLV.Items.Count - 1 do
      begin
        li:=ScalesLV.Items[i];
        ScalesLV.GetSubItemByColumnName('F',li,str);
        p2.x:=StrToFloatDef(str, 0);
        ScalesLV.GetSubItemByColumnName('Scale',li,str);
        p2.y:=StrToFloatDef(str, 0);
        cEvalStepAlg(a).m_band[i]:=p2;
      end;
    end;
  end;

  if FFTShiftIE.IntNum>FFTBlockSizeIE.IntNum then
    FFTShiftIE.IntNum:=FFTBlockSizeIE.IntNum;
  cEvalStepAlg(a).m_fftCount := FFTBlockSizeIE.IntNum;
  cEvalStepAlg(a).m_fftShift := FFTShiftIE.IntNum;
  cEvalStepAlg(a).m_fftFlt := FFTCb.Checked;
  cEvalStepAlg(a).m_fltType := FltRG.ItemIndex;
  cEvalStepAlg(a).m_Threshold := ThresholdSE.Value;
  cEvalStepAlg(a).m_TrigOffset := OffsetSE.Value;
  cEvalStepAlg(a).m_TrigType:=ValTypeRG.ItemIndex;
  cEvalStepAlg(a).m_TrigMeanLenI := TrigMeanLenIE.IntNum;

  if AlgsLB.SelCount<2 then
    cEvalStepAlg(a).m_tag.tag := InChanCB.gettag(InChanCB.ItemIndex);
  t := cEvalStepAlg(a).m_tag.tag;
  if t<>nil then
  begin
    if cEvalStepAlg(a).m_outTag.tag = nil then
    begin
      cEvalStepAlg(a).m_outTag.tag := GenOutTag(cEvalStepAlg(a).m_tag.tagname, cEvalStepAlg(a).m_tag.tag.GetFreq);
    end;
    cEvalStepAlg(a).m_useScalar:=ScalarTagCB.Checked;
    if ScalarTagCB.Checked then
    begin
      if cEvalStepAlg(a).m_outScTag=nil then
        cEvalStepAlg(a).m_outScTag:=cScalarTag.Create;
      cEvalStepAlg(a).m_outScTag.name:=cEvalStepAlg(a).m_tag.tagname+'_trig';
      cEvalStepAlg(a).m_outScTag.CreateTag;
    end;
  end;
  cEvalStepAlg(a).UpdateFFTSize;
end;

procedure TEvalStepCfgFrm.AlgsLBClick(Sender: TObject);
begin
  UpdateSel;
end;

procedure TEvalStepCfgFrm.AlgsLBDragDrop(Sender, Source: TObject;
  X, Y: Integer);
var
  li: tlistitem;
  t: itag;
  a: cEvalStepAlg;
  I: Integer;
begin
  if Source = TagsListFrame1.TagsLV then
  begin
    if Source is tlistview then
    begin
      li := tbtnlistview(Source).Selected;
      if li <> nil then
      begin
        for I := 0 to tbtnlistview(Source).SelCount - 1 do
        begin
          if I = 0 then
            li := tbtnlistview(Source).Selected
          else
            li := tbtnlistview(Source).GetNextItem(li, sdAll, [isSelected]);
          t := itag(li.data);
          if t = nil then
            exit;
          a := g_AlgList.addAlg(t.GetName);
          a.m_tag.tag := t;
          AlgsLB.AddItem(a.name, a);
          if t <> nil then
          begin
            if cEvalStepAlg(a).m_outTag.tag = nil then
            begin
              cEvalStepAlg(a).m_outTag.tag := GenOutTag(t.GetName, t.GetFreq);
            end;
          end;
        end;
      end;
    end;
  end;
end;

function TEvalStepCfgFrm.GenOutTag(str: string; freq:double): itag;
var
  t: itag;
begin
  t := getTagByName(str + '_flt');
  if t = nil then
  begin
    ecm;
    t := createVectorTagR8(str + '_flt', Freq,
      true, // cfgWrite
      true, // irregular
      false);
    lcm;
    result := t;
  end
  else
    result := t;
end;

procedure TEvalStepCfgFrm.AlgsLBDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
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
  a: cEvalStepAlg;
begin
  if Key = VK_DELETE then
  begin
    while AlgsLB.SelCount<>0 do
    begin
      for I := 0 to AlgsLB.Count - 1 do
      begin
        if AlgsLB.Selected[I] then
        begin
          a := cEvalStepAlg(AlgsLB.Items.Objects[I]);
          g_AlgList.delAlg(a);
        end;
        AlgsLB.DeleteSelected;
        break;
      end;
    end;
  end;
end;

procedure TEvalStepCfgFrm.UpdateAlgBtnClick(Sender: TObject);
var
  I: Integer;
  a: cEvalStepAlg;
begin
  for I := 0 to AlgsLB.Count - 1 do
  begin
    if AlgsLB.Selected[I] then
    begin
      a := cEvalStepAlg(AlgsLB.Items.Objects[I]);
      UpdateAlg(a);
    end;
  end;
end;

procedure TEvalStepCfgFrm.UpdateSel;
var
  I: Integer;
  a: cEvalStepAlg;
begin
  fSel:=nil;
  for I := 0 to AlgsLB.Count - 1 do
  begin
    if AlgsLB.Selected[I] then
    begin
      a := cEvalStepAlg(AlgsLB.Items.Objects[I]);
      if fSel=nil then
        fSel:=a;
      ShowAlg(a);
    end;
  end;
  EndMsel;
end;

procedure TEvalStepCfgFrm.ValTypeRGClick(Sender: TObject);
begin
  MeanGB.Visible:=false;
  case ValTypeRG.ItemIndex of
    0: ;
    1: MeanGB.Visible:=true;
  end;
end;

procedure TEvalStepCfgFrm.AlgsLBMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  UpdateSel;
end;

procedure TEvalStepCfgFrm.FFTBlockSizeIEChange(Sender: TObject);
var
  t:itag;
begin
  if InChanCB.ItemIndex>-1 then
  begin
    t := InChanCB.gettag(InChanCB.ItemIndex);
    if FFTBlockSizeIE.IntNum<>0 then
      FFTdxFE.FloatNum:=t.GetFreq/FFTBlockSizeIE.IntNum;
    if FFTBlockSizeIE.IntNum<FFTShiftIE.IntNum then
      FFTShiftIE.IntNum:=FFTBlockSizeIE.IntNum;
    ShowBlockSize(FFTBlockSizeIE.IntNum/t.GetFreq);
    FltRGClick(nil);
  end;
end;

procedure TEvalStepCfgFrm.FFTSizeSBDownClick(Sender: TObject);
begin
  if Sender = FFTSizeSB then
  begin
    if FFTBlockSizeIE.IntNum >= 2 then
      FFTBlockSizeIE.IntNum := round(FFTBlockSizeIE.IntNum / 2)
    else
    begin
      FFTBlockSizeIE.IntNum := 2;
    end;
  end;
  if Sender = FFTShiftSB then
  begin
    if FFTShiftIE.IntNum >= 2 then
      FFTShiftIE.IntNum := round(FFTShiftIE.IntNum / 2)
    else
    begin
      FFTShiftIE.IntNum := 2;
    end;
  end;
end;

procedure TEvalStepCfgFrm.FFTSizeSBUpClick(Sender: TObject);
begin
  if Sender = FFTSizeSB then
  begin
    if FFTBlockSizeIE.IntNum >= 2 then
      FFTBlockSizeIE.IntNum := FFTBlockSizeIE.IntNum * 2
    else
      FFTBlockSizeIE.IntNum := 2;
  end;
  if Sender = FFTShiftSB then
  begin
    if FFTShiftIE.IntNum >= 2 then
      FFTShiftIE.IntNum := FFTShiftIE.IntNum * 2
    else
      FFTShiftIE.IntNum := 2;
  end;
end;

procedure TEvalStepCfgFrm.FltRGClick(Sender: TObject);
var
  fr, df:double;
  t:itag;
  i, ind:integer;
  li:tlistitem;
begin
  fr:=1;
  if InChanCB.ItemIndex>-1 then
  begin
    t := InChanCB.gettag(InChanCB.ItemIndex);
    fr:=t.GetFreq;
    df:=t.GetFreq/FFTBlockSizeIE.IntNum;
  end;
  if FltRG.ItemIndex>-1 then
  begin
    ScalesLV.items.clear;
    for I := 0 to 2 do
    begin
      ScalesLV.Items.add;
    end;
    case FltRG.ItemIndex of
      0: // ФВЧ
      if t<>nil then
      begin
        li:=ScalesLV.items[0];
        ScalesLV.SetSubItemByColumnName('Scale','0',li);
        ScalesLV.SetSubItemByColumnName('Инд.', inttostr(li.Index), li);
        ScalesLV.SetSubItemByColumnName('F','0',li);
        for I := 1 to ScalesLV.items.Count - 1 do
        begin
          li:=ScalesLV.items[i];
          ScalesLV.SetSubItemByColumnName('Инд.', inttostr(li.Index), li);
          if i=1 then
          begin
            if FFTdxFE.FloatNum<>0 then
            begin
              ScalesLV.SetSubItemByColumnName('F',formatstr(FFTdxFE.FloatNum, 4),li)
            end
            else
              ScalesLV.SetSubItemByColumnName('F','1',li)
          end
          else
            ScalesLV.SetSubItemByColumnName('F',floattostr(t.GetFreq/2),li);
          ScalesLV.SetSubItemByColumnName('Scale','1',li);
        end;
      end
      else
      begin
        //fFltCurve[0]:=p2d(0,0);fFltCurve[1]:=p2d(dF,1);fFltCurve[2]:=p2d(t.GetFreq/2,1);
      end;
      1: // ФНЧ 1/2
      begin
        if t<>nil then
        begin
          li:=ScalesLV.items[0];
          ScalesLV.SetSubItemByColumnName('Инд.', inttostr(li.Index), li);
          ScalesLV.SetSubItemByColumnName('F','0',li);
          ScalesLV.SetSubItemByColumnName('Scale','1',li);
          li:=ScalesLV.items[1];
          ScalesLV.SetSubItemByColumnName('Инд.', inttostr(li.Index), li);
          ScalesLV.SetSubItemByColumnName('F',floattostr(t.GetFreq/4),li);
          ScalesLV.SetSubItemByColumnName('Scale','1',li);
          li:=ScalesLV.items[2];
          ScalesLV.SetSubItemByColumnName('Инд.', inttostr(li.Index), li);
          ScalesLV.SetSubItemByColumnName('F',floattostr(t.GetFreq/2),li);
          ScalesLV.SetSubItemByColumnName('Scale','0',li);
        end;
      end;
      2:
      begin
        if t<>nil then
        begin
          li:=ScalesLV.items[0];
          ScalesLV.SetSubItemByColumnName('Инд.', inttostr(li.Index), li);
          ScalesLV.SetSubItemByColumnName('F','0',li);
          ScalesLV.SetSubItemByColumnName('Scale','1',li);
          li:=ScalesLV.items[1];
          ScalesLV.SetSubItemByColumnName('Инд.', inttostr(li.Index), li);
          // фильтр 10 Hz
          ScalesLV.SetSubItemByColumnName('F',floattostr(10),li);
          ScalesLV.SetSubItemByColumnName('Scale','1',li);
          li:=ScalesLV.items[2];
          ScalesLV.SetSubItemByColumnName('Инд.', inttostr(li.Index), li);
          ScalesLV.SetSubItemByColumnName('F',floattostr(t.GetFreq/2),li);
          ScalesLV.SetSubItemByColumnName('Scale','0',li);
        end;
      end;
      3: // User
      begin
        if fSel<>nil then
        begin
          ScalesLV.items.Clear;
          for I := 0 to length(cEvalStepAlg(fSel).m_band) - 1 do
          begin
            li:=ScalesLV.Items.add;
            ScalesLV.SetSubItemByColumnName('Инд.', inttostr(li.Index), li);
            ScalesLV.SetSubItemByColumnName('F', floattostr(cEvalStepAlg(fSel).m_band[i].x), li);
            ScalesLV.SetSubItemByColumnName('Scale', floattostr(cEvalStepAlg(fSel).m_band[i].y), li);
          end;
        end;
      end;
    end
  end
  else
  begin
    if fSel<>nil then
    begin
      //setlength(fFltCurve,length(cEvalStepAlg(fSel).m_band));
      //move(cEvalStepAlg(fSel).m_band[0],fFltCurve[0], length(cEvalStepAlg(fSel).m_band)*sizeof(point2d));
    end;
  end;
  LVChange(ScalesLV);
end;

procedure TEvalStepCfgFrm.FormShow(Sender: TObject);
var
  I: Integer;
  a:cEvalStepAlg;
begin
  AlgsLB.Clear;
  TagsListFrame1.ShowChannels;
  InChanCB.updateTagsList;
  if g_AlgList<>nil then
  begin
    for I := 0 to g_AlgList.Count - 1 do
    begin
      a:=g_AlgList.getobj(i);
      AlgsLB.AddItem(a.name, a);
    end;
  end;
end;

end.
