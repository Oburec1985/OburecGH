unit uModeFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCL_MYOWN, ExtCtrls, ComCtrls, Buttons, uBtnListView,
  Recorder, Tags, Spin, uComponentServises, inifiles, uBaseObj, uCommonMath,
  uControlObj, uRTrig, uRvclService, uModesTabsForm, uTrigFrame, VirtualTrees, uRCFunc;

type
  TModeFrame = class(TFrame)
    PageControl1: TPageControl;
    ModesPage: TTabSheet;
    ModeChannelsGB: TGroupBox;
    ChannelsLV: TBtnListView;
    ModePanel: TPanel;
    ModeNameLabel: TLabel;
    ModeNameEdit: TEdit;
    Splitter1: TSplitter;
    ProgramPage: TTabSheet;
    ProgramCountSE: TSpinEdit;
    ProgramCounterLabel: TLabel;
    ProgramNameE: TEdit;
    ProgramNameLabel: TLabel;
    ModeTimeFE: TFloatEdit;
    ModeTimeLabel: TLabel;
    ShowModesTabBtn: TSpeedButton;
    StartProgramCB: TCheckBox;
    EnableProgramOnStartCB: TCheckBox;
    InfinityModeCB: TCheckBox;
    CheckThresholdCB: TCheckBox;
    CheckLengthFe: TFloatEdit;
    Label2: TLabel;
    procedure ChannelsLVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ChannelsLVDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ChannelsLVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ShowModesTabBtnClick(Sender: TObject);
  public
    m_mng:cControlMng;
    m_mode:cModeObj;
    m_prog:cProgramObj;
  private
    procedure ShowChannels;
  public
    procedure LinkMng(m:cControlMng);
    procedure ShowProgObjProps(p:cBaseProgramObj; endMS:boolean);
    function CreateObj: cbaseobj;
    // ��������� ��������� ������ � ������
    procedure editObj(obj: cbaseobj);
    procedure Show;
    procedure Save(f: tinifile; section: string);
    procedure Load(f: tinifile; section: string);
  end;

implementation

uses
  pluginclass;
{$R *.dfm}
{ TModeFrame }

procedure TModeFrame.Show;
begin
  ShowChannels;
end;

procedure TModeFrame.Save(f: tinifile; section: string);
begin
  //f.WriteString(section, 'StartProgramTrigger', StartProgramCB.text);
  //f.WriteString(section, 'StopProgramTrigger', StopProgramCB.text);
  //f.WriteFloat(section, 'StartTrigLvl', StartThresholdFE.FloatNum);
  //f.WriteFloat(section, 'StopTrigLvl', StopThresholdFE.FloatNum);
  //f.WriteInteger(section, 'StartProgramType', StartProgramRG.ItemIndex);
  //f.WriteInteger(section, 'StopProgramType', StopProgramRG.ItemIndex);
  //f.WriteString(section, 'ProgramName', ProgramNameE.text);
end;

procedure TModeFrame.LinkMng(m: cControlMng);
begin
  m_mng:=m;
end;

procedure TModeFrame.Load(f: tinifile; section: string);
begin
  //StartProgramCB.text := f.ReadString(section, 'StartProgramTrigger', '');
  //StopProgramCB.text := f.ReadString(section, 'StartProgramTrigger', '');
  //StartThresholdFE.FloatNum:=IniReadFloatEx(f, section, 'StartTrigLvl', 0.5);
  //StopThresholdFE.FloatNum:=IniReadFloatEx(f, section, 'StopTrigLvl', 0.5);
  //StartProgramRG.ItemIndex:=f.ReadInteger(section, 'StartProgramType', 0);
  //StopProgramRG.ItemIndex:=f.ReadInteger(section, 'StopProgramType', 0);
  ProgramNameE.text := f.ReadString(section, 'ProgramName', '');
end;

procedure TModeFrame.ShowChannels;
var
  ir: IRecorder;
begin
  ir := getIR;
end;

procedure TModeFrame.ShowModesTabBtnClick(Sender: TObject);
begin
  if not ModesTabForm.visible then
  begin
    if m_prog=nil then
    begin
      if m_mng.ProgramCount>0 then
      begin
        m_prog:=m_mng.getprogram(0);
      end;
    end;
    if m_prog<>nil then
    begin
      ModesTabForm.Show(m_prog);
    end;
  end
  else
  begin
    ModesTabForm.hide;
  end;
end;

function GetCBobj(cb:tcombobox):pointer;
begin
  result:=nil;
  if cb.ItemIndex>-1 then
  begin
    result:=cb.Items.Objects[cb.ItemIndex];
  end;
end;

procedure TModeFrame.ChannelsLVDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  t:itag;
  s:string;
  li, next, newli:tlistitem;
  b:boolean;
begin
  li:=tbtnlistview(source).selected;//tbtnlistview(source).GetItemAt(x,y);
  while li<>nil do
  begin
    b:=true;
    t:=itag(li.data);
    next:=tbtnlistview(source).GetNextItem(li, sdBelow, [isSelected]);
    // ��������� ������� ����
    newli:=tbtnlistview(sender).items.Add;
    newli.data:=pointer(t);
    s:=t.getName;
    tbtnlistview(sender).SetSubItemByColumnName('���',s,newli);
    tbtnlistview(sender).SetSubItemByColumnName('��������','1',newli);
    if li=next then break;
    li:=next;
  end;
  lvchange(tbtnlistview(sender));
end;

procedure TModeFrame.ChannelsLVDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  li:tlistitem;
begin
  if source is tBtnListView then
  begin
    li:=tBtnListView(source).selected;
    if li=nil then exit;
    if li.Data <>nil then
    begin
      if tListitem(source).Data <>nil then
      begin
        Accept:= Supports(itag(li.Data),IID_ITAG);
      end;
    end;
  end;
end;

procedure TModeFrame.ChannelsLVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  li, del:tlistitem;
  b:boolean;
begin
  if key=VK_DELETE then
  begin
    li:=tbtnlistview(sender).selected;//tbtnlistview(source).GetItemAt(x,y);
    while li<>nil do
    begin
      b:=true;
      del:=li;
      li:=tbtnlistview(sender).GetNextItem(li, sdBelow, [isSelected]);
      if li=del then
        li:=nil;
      del.Destroy;
    end;
  end;
end;

function TModeFrame.CreateObj: cbaseobj;
var
  p:cprogramobj;
  m:cModeObj;
  cb:tcombobox;
begin
  case PageControl1.ActivePageIndex of
    0:
    // ���������
    begin
      p:=cProgramObj.create;
      editObj(p);
      result:=p;
    end;
    1: // ������
    begin
      m:=cModeObj.create;
      editObj(m);
      result:=m;
    end;
  end;
end;

procedure TModeFrame.editObj(obj: cbaseobj);
var
  p:cprogramobj;
  m:cModeObj;
  i:integer;
  t:itag;
  v:double;
  li:tlistitem;
  str:string;
  err, b:boolean;
begin
  if obj is cProgramObj then
  begin
    p:=cProgramObj(obj);
    if (ProgramNameE.Text<>'') and (ProgramNameE.Text<>'_') then
      p.name:=ProgramNameE.text;
    if ProgramCountSE.Text<>'' then
      p.RepeatCount:=ProgramCountSE.Value;
    p.m_StartOnPlay:=StartProgramCB.Checked;
    p.m_enableOnStart:=EnableProgramOnStartCB.Checked;
  end
  else
  begin
    if obj is cModeObj then
    begin
      m:=cModeObj(obj);
      b:=GetMultiSelectComponentBool(InfinityModeCB, err);
      if not err then
      begin
        cmodeobj(m).Infinity:=b;
      end;
      b:=GetMultiSelectComponentBool(CheckThresholdCB, err);
      if not err then
      begin
        cmodeobj(m).CheckThreshold:=b;
      end;
      GetMultiSelectComponentString(CheckLengthFe, err);
      if not err then
      begin
        cmodeobj(m).CheckLength:=CheckLengthFe.FloatNum;
      end;

      if ModeNameEdit.text<>'' then
        m.name:=ModeNameEdit.text;
      if ModeTimeFE.Text<>'' then
        m.ModeLength:=ModeTimeFE.FloatNum;
      // ������� �� ���� �����
      // ������� ������ ������
    end;
    m.clearsteptags;
    for i:= 0 to ChannelsLV.items.Count - 1 do
    begin
      li:=ChannelsLV.items[i];
      ChannelsLV.GetSubItemByColumnName('��������',li,str);
      v:=strtofloatext(str);
      //ChannelsLV.GetSubItemByColumnName('���',li,str);
      t:=itag(li.Data);
      m.addstepTag(t,v);
    end;
  end;
end;

procedure TModeFrame.ShowProgObjProps(p:cBaseProgramObj; endMS:boolean);
var
  i:integer;
  li:tlistitem;
  tname:string;
  m:cmodeobj;
  prog:cprogramobj;

  trigname:string;
  thresh:double;
  trigtype:ttrigtype;
  tr, basetr:crtrig;
  s:cstepval;
begin
  if p is cmodeobj then
  begin
    m:=cmodeobj(p);
    SetMultiSelectComponentString(ModeNameEdit,m.name);
    SetMultiSelectComponentString(ModeTimefe,floattostr(m.ModeLength));

    SetMultiSelectComponentBool(CheckThresholdCB,m.CheckThreshold);
    SetMultiSelectComponentBool(InfinityModeCB,m.Infinity);
    SetMultiSelectComponentString(CheckLengthFe,floattostr(m.CheckLength));

    trigname:='';
    thresh:=0;
    trigtype:=trFront;
    trigname:='';
    thresh:=0;
    trigtype:=trFront;

    if endMS then
    begin
      endMultiSelect(ModeNameEdit);
      endMultiSelect(ModeTimefe);
      endMultiSelect(CheckLengthFe);
      endMultiSelect(CheckThresholdCB);
      endMultiSelect(InfinityModeCB);
    end;
    ChannelsLV.clear;
    for I := 0 to m.stepValCount - 1 do
    begin
      li:=channelslv.Items.add;
      s:=m.getstepval(i);
      li.Data:=pointer(s.m_t);
      channelslv.SetSubItemByColumnName('���',s.name,li);
      channelslv.SetSubItemByColumnName('��������',floattostr(s.m_val),li);
    end;
  end;
  if p is cProgramObj then
  begin
    prog:=cProgramObj(p);
    SetMultiSelectComponentString(ProgramNameE,prog.name);
    SetMultiSelectComponentString(ProgramCountSE,inttostr(prog.RepeatCount));
    SetMultiSelectComponentBool(StartProgramCB,prog.m_StartOnPlay);
    SetMultiSelectComponentBool(EnableProgramOnStartCB,prog.m_enableOnStart);
    if endMS then
    begin
      endMultiSelect(ProgramNameE);
      endMultiSelect(ProgramCountSE);
      endMultiSelect(StartProgramCB);
      endMultiSelect(EnableProgramOnStartCB);
    end;
  end;
end;

end.
