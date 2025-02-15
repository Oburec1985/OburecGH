unit uSpmChartEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, uBtnListView, StdCtrls, ExtCtrls, Buttons,
  uControlEditFrame, uModeFrame, uRecorderEvents, uControlObj,
  uComponentServises,
  pluginClass, ImgList, VirtualTrees, uVTServices, Menus, inifiles, uFilemng,
  uBaseObj, uRCFunc, uRvclService,
  tags, recorder, uBaseObjService, uModesTabsForm, activex, uRTrig,
  DCL_MYOWN, uRcCtrls, uTrigsFrm, uEventTypes, uBaseAlg, uspmchart,
  uEditProfileFrm, uControlWarnFrm, uSpm,
  uPhaseAlg, uGrmsSrcAlg, uSpin
  // , uBaseAlg
  ;

type
  TSpmChartEditFrm = class(TForm)
    PropPanel: TPanel;
    MinXLabel: TLabel;
    MaxXLabel: TLabel;
    MinYLabel: TLabel;
    MaxYLabel: TLabel;
    UpdateBtn: TSpeedButton;
    MinXfe: TFloatEdit;
    MaxXfe: TFloatEdit;
    MinYfe: TFloatEdit;
    MaxYfe: TFloatEdit;
    LgYcb: TCheckBox;
    LgXcb: TCheckBox;
    TubesGB: TGroupBox;
    TubeWarningCB: TCheckBox;
    TubeProfileCB: TCheckBox;
    TubeAlarmCB: TCheckBox;
    FormChannelsGB: TGroupBox;
    ChanNamesPanel: TPanel;
    FrmTagPropLabel: TLabel;
    FrmTagPropValue: TLabel;
    FilterEdit: TEdit;
    FrmTagPropValueEdit: TEdit;
    FrmTagPropNameCB: TComboBox;
    TagsLV: TBtnListView;
    Panel1: TPanel;
    TagsGB: TGroupBox;
    TagsLB: TListBox;
    AlgLibSpm: TCheckBox;
    Label1: TLabel;
    ProfileBtn: TButton;
    ProfileCB: TComboBox;
    ShowLabels: TCheckBox;
    procedure UpdateBtnClick(Sender: TObject);
    procedure TagsLBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TagsLBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TagsLBDrawItem(Control: TWinControl; Index: Integer; Rect: TRect;
      State: TOwnerDrawState);
    procedure TagsLBKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GraphTypeRGClick(Sender: TObject);
    procedure ProfileBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  public
    curChart: TSpmChart;
  private
  private
    procedure createevents;
    procedure Destroyevents;
    procedure doLeaveCfg(Sender: TObject);
    function CheckSpmOnAdd(alg: cBaseAlgContainer): Boolean;
    procedure showChartTags;
    procedure ShowProfiles;
  public
    procedure updateTagsList;
    // ���������� ������ ��������� �����
    procedure ShowSpmTags;
    procedure ShowAphTags;
    procedure EditChart(chart: TSpmChart);
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
  end;

var
  SpmChartEditFrm: TSpmChartEditFrm;

implementation
uses
  uCursorFrm, uCreateComponents;

{$R *.dfm}
{ TSpmChartEditFrm }


constructor TSpmChartEditFrm.create(aowner: tcomponent);
begin
  inherited;
  createevents;
end;


destructor TSpmChartEditFrm.destroy;
begin
  Destroyevents;
  inherited;
end;

procedure TSpmChartEditFrm.createevents;
begin
  AddPlgEvent('TSpmChartEditFrm_UpdateCfg', c_RC_LeaveCfg, doLeaveCfg);
end;

procedure TSpmChartEditFrm.Destroyevents;
begin
  RemovePlgEvent(doLeaveCfg, c_RC_LeaveCfg);
end;

procedure TSpmChartEditFrm.doLeaveCfg(Sender: TObject);
begin
  if g_CreateFrms then
    ShowSpmTags;
end;

function TSpmChartEditFrm.CheckSpmOnAdd(alg: cBaseAlgContainer): Boolean;
var
  I: Integer;
  obj: cBaseAlgContainer;
begin
  result := true;
  for I := 0 to TagsLB.count - 1 do
  begin
    obj := cBaseAlgContainer(TagsLB.items.Objects[I]);
    if obj = alg then
    begin
      result := false;
      exit;
    end;
  end;
end;

procedure TSpmChartEditFrm.EditChart(chart: TSpmChart);
var
  I: Integer;
  ti: TSpmTagInfo;
begin
  curChart := chart;
  if chart <> nil then
  begin
    MinXfe.FloatNum := chart.aX.X;
    MaxXfe.FloatNum := chart.aX.Y;
    MinYfe.FloatNum := chart.aY.X;
    MaxYfe.FloatNum := chart.aY.Y;
    LgXcb.Checked := chart.lgX;
    LgYcb.Checked := chart.lgY;
    TubeProfileCB.Checked := chart.ShowProfile;
    TubeWarningCB.Checked := chart.ShowProfile;
    TubeAlarmCB.Checked := chart.ShowAlarms;
    ShowLabels.Checked:=curChart.ShowLabels;

    ShowProfiles;
    showChartTags;
    showmodal;
  end;
end;

procedure TSpmChartEditFrm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  cursfrm:TCursorFrm;
begin
  if g_CursorFrm<>nil then
    g_CursorFrm.doSetActChart(curChart);
end;

procedure TSpmChartEditFrm.GraphTypeRGClick(Sender: TObject);
begin
  updateTagsList;
end;

procedure TSpmChartEditFrm.ProfileBtnClick(Sender: TObject);
var
  p:tprofile;
  I: Integer;
begin
  if profilecb.ItemIndex=-1 then
    p:=nil
  else
    p:=tprofile(profilecb.Items.Objects[profilecb.ItemIndex]);
  p:=EditProfileFrm.editProfile(p, g_CtrlWrnFactory.m_pList);
  ShowProfiles;
  for I := 0 to ProfileCB.items.Count - 1 do
  begin
    if ProfileCB.Items.Objects[i]=p then
    begin
      ProfileCB.ItemIndex:=i;
      break;
    end;
  end;
end;

procedure TSpmChartEditFrm.UpdateBtnClick(Sender: TObject);
var
  I, j: Integer;
  alg: cBaseAlgContainer;
  find: Boolean;
  ti: TSpmTagInfo;
begin
  if curChart <> nil then
  begin
    curChart.aX.X := MinXfe.FloatNum;
    curChart.aX.Y := MaxXfe.FloatNum;
    curChart.aY.X := MinYfe.FloatNum;
    curChart.aY.Y := MaxYfe.FloatNum;

    curChart.lgX := LgXcb.Checked;
    curChart.lgY := LgYcb.Checked;
    curChart.ShowProfile := TubeProfileCB.Checked;
    curChart.ShowWarnings := TubeWarningCB.Checked;
    curChart.ShowAlarms := TubeAlarmCB.Checked;
    curChart.ShowLabels:=ShowLabels.Checked;


    if profilecb.ItemIndex<>-1 then
      curchart.profile:=tprofile(profilecb.Items.Objects[profilecb.ItemIndex]);
    for I := 0 to TagsLB.count - 1 do
    begin
      alg := cSpm(TagsLB.items.Objects[I]);
      curChart.addalg(alg);
    end;
    // ������ ������
    I := 0;
    while I < curChart.m_tagslist.count - 1 do
    begin
      ti := curChart.TagInfo(I);
      find := false;
      for j := 0 to TagsLB.count - 1 do
      begin
        alg := cBaseAlgContainer(TagsLB.items.Objects[j]);
        if (alg = ti.m_spm) then
        begin
          find := true;
          continue;
        end;
      end;
      if not find then
      begin
        ti.destroy;
        curChart.m_tagslist.Delete(I);
      end
      else
        inc(I);
    end;
  end;
  curChart.UpdateOpts;
end;

procedure TSpmChartEditFrm.updateTagsList;
begin
  ShowSpmTags;
end;

procedure TSpmChartEditFrm.ShowAphTags;
var
  I, ind: Integer;
  ir: IRecorder;
  t: iTag;
  tname: string;
  li: TListItem;
  a: cBaseAlgContainer;
begin
  ir := getIR;
  // ��������� ������ �������
  TagsLV.Clear;
  for I := 0 to g_algMng.count - 1 do
  begin
    a := g_algMng.getalg(I);
    if a is cPhaseAlg then
    begin
      tname := cPhaseAlg(a).resname;
      if ((pos(lowercase(FilterEdit.text), lowercase(tname)) > 0) or
          (FilterEdit.text = '')) then
      begin
        li := TagsLV.items.Add;
        li.Data := pointer(a);
        TagsLV.SetSubItemByColumnName('���', tname, li);
      end;
    end;
    if a is cGrmsSrcAlg then
    begin
      tname := cGrmsSrcAlg(a).resname;
      if ((pos(lowercase(FilterEdit.text), lowercase(tname)) > 0) or
          (FilterEdit.text = '')) then
      begin
        li := TagsLV.items.Add;
        li.Data := pointer(a);
        TagsLV.SetSubItemByColumnName('���', tname, li);
      end;
    end;
  end;
  LVChange(TagsLV);
end;

procedure TSpmChartEditFrm.showChartTags;
var
  I: Integer;
  ti: TSpmTagInfo;
begin
  TagsLB.Clear;
  for I := 0 to curChart.m_tagslist.count - 1 do
  begin
    ti := curChart.TagInfo(I);
    if ti.m_spm=nil then
    begin
      ti.alg:=g_algMng.getSpm(ti.m_algname);
    end;
    TagsLB.items.AddObject(ti.m_algname, ti.m_spm);
  end;
end;

procedure TSpmChartEditFrm.ShowSpmTags;
var
  I, ind: Integer;
  ir: IRecorder;
  tname: string;
  li: TListItem;
  a: cBaseAlgContainer;
begin
  ir := getIR;
  // ��������� ������ �������
  TagsLV.Clear;
  for I := 0 to g_algMng.count - 1 do
  begin
    a := cBaseAlgContainer(g_algMng.getobj(I));
    if a is cSpm then
    begin
      tname := cSpm(a).resname;
      if ((pos(lowercase(FilterEdit.text), lowercase(cspm(a).name)) > 0) or
          (FilterEdit.text = '')) then
      begin
        li := TagsLV.items.Add;
        li.Data := pointer(a);
        TagsLV.SetSubItemByColumnName('���', cspm(a).name, li);
        TagsLV.SetSubItemByColumnName('�����', cspm(a).m_tag.tagname, li);
      end;
    end;
  end;
  LVChange(TagsLV);
end;

procedure TSpmChartEditFrm.TagsLBDragDrop(Sender, Source: TObject;
  X, Y: Integer);
var
  s: string;
  alg: cBaseAlgContainer;
  li, next, newli: TListItem;
  b: Boolean;
begin
  li := TBtnListView(Source).selected;
  while li <> nil do
  begin
    b := true;
    alg := cSpm(li.Data);
    next := TBtnListView(Source).GetNextItem(li, sdBelow, [isSelected]);
    // ��������� ������� ����
    if CheckSpmOnAdd(alg) then
      TagsLB.items.AddObject(alg.name, alg);
    if li = next then
      break;
    li := next;
  end;
end;

procedure TSpmChartEditFrm.TagsLBDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
var
  li: TListItem;
begin
  Accept:=false;
  if Source = TagsLV then
  begin
    li := TBtnListView(Source).selected;
    if li = nil then
      exit;
    if li.Data <> nil then
    begin
      if li.Data <> nil then
      begin
        // Accept:= Supports(itag(li.Data),IID_ITAG);
        Accept := TObject(li.Data) is cSpm;
        if not Accept then
        begin
          Accept := TObject(li.Data) is cGrmsSrcAlg;
          if not Accept then
          begin
            Accept := TObject(li.Data) is cPhaseAlg;
          end;
        end;
      end;
    end;
  end;
end;

procedure TSpmChartEditFrm.TagsLBDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  t: TSpmTagInfo;
  error: Boolean;
begin
  with TagsLB.Canvas do
  begin
    t := TSpmTagInfo(TagsLB.items.Objects[Index]);
    error := t.m_spm = nil;
    if not error then
    begin
      error := not t.m_spm.ready;
    end;
    if error then
    begin
      // ���� ��������������� ������ ������.
      Brush.Color := clRed;
      FillRect(Rect);
      Font.Color := RGB(255, 255, 255);
      TextOut(Rect.Left, Rect.Top, TagsLB.items[Index]);
    end
    else
    begin
      FillRect(Rect);
      if Index >= 0 then
        TextOut(Rect.Left + 2, Rect.Top, TagsLB.items[Index]);
      // ��������� ���������
      { Brush.Color := clWhite;
        FillRect(Rect);
        Font.Color := font.Color;
        TextOut(Rect.Left, Rect.Top, SignalsLB.Items[Index]); }
    end;
  end;
end;

procedure TSpmChartEditFrm.TagsLBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  li: TListItem;
  I: Integer;
  alg: cBaseAlgContainer;
  j: Integer;
  ti: TSpmTagInfo;
begin
  if Key = VK_DELETE then
  begin
    I := 0;
    while I <= TagsLB.count - 1 do
    begin
      if TagsLB.selected[I] then
      begin
        alg := cBaseAlgContainer(TagsLB.items.Objects[I]);
        for j := 0 to curChart.m_tagslist.count - 1 do
        begin
          ti := curChart.TagInfo(j);
          if ti.m_spm = alg then
          begin
            ti.destroy;
            curChart.m_tagslist.Delete(j);
            break;
          end;
        end;
        TagsLB.items.Delete(I);
        continue;
      end
      else
      begin
        inc(I);
      end;
    end;
  end;
end;

procedure TSpmChartEditFrm.ShowProfiles;
var
  p:tprofile;
  i:integer;
begin
  ProfileCB.Clear;
  p:=nil;
  for I := 0 to g_CtrlWrnFactory.m_pList.count - 1 do
  begin
    p:=g_CtrlWrnFactory.m_pList.getprof(i);
    ProfileCB.AddItem(p.name,p);
  end;
  if p<>nil then
    setComboBoxItem(p.name,ProfileCB);
end;


end.
