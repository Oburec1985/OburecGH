unit uDacControlEditFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, recorder, tags, uCommonMath, inifiles, uControlObj, uRCFunc,
  uComponentServises, uCustomEditControlFrame, ubtnlistview, ComCtrls, Buttons,
  ExtCtrls,
  uCommonTypes,
  DCL_MYOWN;

type
  TDACControlEditFrame = class(TCustomControlEditFrame)
    FeedbackLabel: TLabel;
    DACCB: TComboBox;
    RightGB: TGroupBox;
    LowPanel: TPanel;
    AddZoneBtn: TSpeedButton;
    ZonesLB: TListBox;
    ChannelsLV: TBtnListView;
    TolEdit: TFloatEdit;
    TolLabel: TLabel;
    ZoneTypeCB: TCheckBox;
    ZonesCB: TCheckBox;
    UpdateBtn: TSpeedButton;
    procedure ChannelsLVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ChannelsLVDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure UpdateBtnClick(Sender: TObject);
    procedure AddZoneBtnClick(Sender: TObject);
    procedure TolEditChange(Sender: TObject);
    procedure ZonesLBClick(Sender: TObject);
  public
    m_CurCon:cControlObj;
    m_ZoneList:cZoneList;
  public
    procedure ShowZone(z:cZone);
    procedure ShowZones(c:cControlObj);
    procedure EndMS;override;
    function GetDsc:string;override;
    procedure doUpdateChannelList;override;
    function ControlType:string;override;
    procedure Save(f:tinifile; section:string);override;
    procedure Load(f:tinifile; section:string);override;
    procedure ShowControlProps(con:cControlObj; endMS:boolean);override;
    procedure editcontrol(c:cControlObj);override;
    procedure linkChannelsLV(drover:TDragOverEvent; drdrop:TDragDropEvent);override;
  published
  end;

  const
    c_DAC = 'Прямое управление ЦАП';

implementation
uses
  pluginclass;

{$R *.dfm}

{ TDACControlEditFrame }
procedure TDACControlEditFrame.linkChannelsLV(drover:TDragOverEvent; drdrop:TDragDropEvent);
begin
  daccb.OnDragDrop:=drdrop;
  daccb.OnDragOver:=drover;
end;

function TDACControlEditFrame.GetDsc:string;
begin
  result:=c_DAC;
end;

procedure TDACControlEditFrame.doUpdateChannelList;
var
  ir:iRecorder;
  I, ind, tcount: Integer;
  t:itag;
  tname, text:string;
  v:olevariant;
  ls:linkstate;
  b:boolean;
begin
  ir:=getIR;
  DACCB.Items.Clear;
  text:=DACCB.text;
  ind:=-1;
  tcount:=ir.GetTagsCount;
  if tcount=0 then exit;
  for I := 0 to ir.GetTagsCount - 1 do
  begin
    t:=GetTagByIndex(i);
    tname:=t.GetName;
    if tname=text then
      ind:=i;
    t.getproperty(TAGPROP_TYPE,v);
    ls:=t.GetLinkState;
    b:=false;
    case ls of
      LS_HARDWARE: ;
      LS_VIRTUAL: b:=true;
      LS_LOST: ;
      LS_PIPE: ;
    end;
    if (checkflag(v,TTAG_OUTPUT)) or (b) then
    begin
      DACCB.Items.AddObject(tname,pointer(t));
    end;
  end;
  if ind<>-1 then
  begin
    DACCB.ItemIndex:=ind;
  end
  else
    DACCB.text:=text;
  DACCB.itemindex:=-1;
end;

function TDACControlEditFrame.ControlType:string;
begin
  result:=c_DAC_CLASSID;
end;

procedure TDACControlEditFrame.Save(f:tinifile; section:string);
begin
  f.WriteString(section,'DACChannel',DACCB.text);
end;

procedure TDACControlEditFrame.Load(f:tinifile; section:string);
begin
  DACCB.text:=f.ReadString(section,'DACChannel','');
end;

procedure TDACControlEditFrame.ShowControlProps(con:cControlObj; endMS:boolean);
begin
  m_CurCon:=con;
  SetMultiSelectComponentString(DACCB, cDacControl(con).m_dac_name);
  showZones(con);
end;

procedure TDACControlEditFrame.ShowZone(z:cZone);
var
  I: Integer;
  li:tlistitem;
  p:TZonePair;
begin
  TolEdit.FloatNum:=z.tol;
  ZoneTypeCB.Checked:=(z.tol>0);
  ChannelsLV.Clear;
  for I := 0 to z.tags.Count - 1 do
  begin
    p:=z.GetZonePair(i);
    li:=ChannelsLV.Items.Add;
    li.Data:=pointer(p.tag);
    tbtnlistview(ChannelsLV).SetSubItemByColumnName('Канал',itag(p.tag).GetName,li);
    tbtnlistview(ChannelsLV).SetSubItemByColumnName('Значение',floattostr(p.value),li);
  end;
end;

procedure TDACControlEditFrame.ShowZones(c:cControlObj);
var
  I: Integer;
  z:cZone;
  srt:string;
begin
  m_Zonelist:=c.m_ZoneList;
  z:=nil;
  if ZonesLB.ItemIndex>-1 then
  begin
    z:=cZone(ZonesLB.Items.Objects[ZonesLB.ItemIndex]);
  end;
  ZonesLB.Clear;
  for I := 0 to c.m_ZoneList.Count - 1 do
  begin
    z:=c.m_ZoneList.GetZone(i);
    ZonesLB.AddItem(z.propstr,z);
  end;
  for I := 0 to ZonesLB.items.count - 1 do
  begin
    if z=cZone(ZonesLB.Items.Objects[i]) then
    begin
      ZonesLB.ItemIndex:=i;
      ShowZone(z);
      exit;
    end;
  end;
  z:=cZone(c.m_ZoneList.GetZone(0));
  ShowZone(z);
end;

procedure TDACControlEditFrame.TolEditChange(Sender: TObject);
begin
  if toledit.FloatNum<>0 then
  begin
    toledit.Color:=clWindow;
  end;
end;

procedure TDACControlEditFrame.UpdateBtnClick(Sender: TObject);
var
  z:cZone;
  I: Integer;
  pair:TZonePair;
  li:tlistitem;
  str:string;
  t:double;
begin
  if ZonesLB.ItemIndex>=0 then
  begin
    z:=cZone(ZonesLB.Items.Objects[ZonesLB.ItemIndex]);
    m_CurCon.m_zones_enabled:=ZonesCB.Checked;
    t:=z.tol;
    if zonetypecb.Checked then
      z.tol:=abs(tolEdit.FloatNum)
    else
      z.tol:=-abs(tolEdit.FloatNum);
    z.cleartags;
    for I := 0 to channelsLV.items.Count - 1 do
    begin
      li:=channelsLV.items[i];
      pair.tag:=(li.data);
      channelsLV.GetSubItemByColumnName('Значение',li,str);
      pair.value:=StrToFloat(str);
      z.AddZonePair(pair);
    end;
    //if z.tol<>t then
      ShowZones(m_CurCon);
    for I := 0 to ZonesLB.Count - 1 do
    begin
      if ZonesLB.Items.Objects[i]=z then
      begin
        ZonesLB.ItemIndex:=i;
        break;
      end;
    end;
  end;
end;

procedure TDACControlEditFrame.ZonesLBClick(Sender: TObject);
var
  z:czone;
begin
  if zoneslb.ItemIndex<>-1 then
  begin
    z:=cZone(zoneslb.Items.objects[zoneslb.ItemIndex]);
    ShowZone(z);
  end;
end;

procedure TDACControlEditFrame.editcontrol(c:cControlObj);
var
  t:itag;
  I: Integer;
  z:cZone;
begin
  m_CurCon:=c;
  m_CurCon.m_zones_enabled:=ZonesCB.Checked;
  t:=itag(getselectObject(DACCB));
  if t<>nil then
    cDacControl(c).dac:=t
  else
  begin
    if MultiSelectState(daccb) then
    begin

    end
    else
    begin
      cDacControl(c).dac:=nil;
    end;
  end;
end;

procedure TDACControlEditFrame.EndMS;
begin
  endMultiSelect(DACCB);
end;


procedure TDACControlEditFrame.AddZoneBtnClick(Sender: TObject);
var
  z:cZone;
begin
  if toledit.FloatNum<>0 then
  begin
    if zonetypecb.Checked then
      z:=m_CurCon.m_ZoneList.NewZone(toledit.FloatNum)
    else
      z:=m_CurCon.m_ZoneList.NewZone(-toledit.FloatNum);
    ShowZones(m_CurCon);
  end
  else
    toledit.Color:=clPink;
end;

procedure TDACControlEditFrame.ChannelsLVDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  t:itag;
  s:string;
  li, next, newli:tlistitem;
  b:boolean;
  p:tZonePair;
begin
  li:=tbtnlistview(source).selected;//tbtnlistview(source).GetItemAt(x,y);
  while li<>nil do
  begin
    b:=true;
    t:=itag(li.data);
    next:=tbtnlistview(source).GetNextItem(li, sdBelow, [isSelected]);
    // отрисовка свойств тега
    newli:=tbtnlistview(sender).items.Add;
    newli.data:=pointer(t);
    s:=t.getName;
    tbtnlistview(sender).SetSubItemByColumnName('Канал',s,newli);
    tbtnlistview(sender).SetSubItemByColumnName('Значение','1',newli);
    if li=next then break;
    li:=next;
  end;

  lvchange(tbtnlistview(sender));
end;


procedure TDACControlEditFrame.ChannelsLVDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
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

end.
