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
    RightGB: TGroupBox;
    LowPanel: TPanel;
    AddZoneBtn: TSpeedButton;
    ZonesLB: TListBox;
    ChannelsLV: TBtnListView;
    TolEdit: TFloatEdit;
    TolLabel: TLabel;
    ZoneTypeCB: TCheckBox;
    UpdateBtn: TSpeedButton;
    Panel1: TPanel;
    RelZoneCB: TCheckBox;
    TolEdit2: TFloatEdit;
    TolLabel2: TLabel;
    Panel2: TPanel;
    FeedbackLabel: TLabel;
    DACCB: TComboBox;
    ZonesCB: TCheckBox;
    UsePrevValsCB: TCheckBox;
    ChannelsGB: TGroupBox;
    TPairLV: TBtnListView;
    procedure ChannelsLVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ChannelsLVDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure UpdateBtnClick(Sender: TObject);
    procedure AddZoneBtnClick(Sender: TObject);
    procedure TolEditChange(Sender: TObject);
    procedure ZonesLBClick(Sender: TObject);
    procedure ZoneTypeCBClick(Sender: TObject);
    procedure RelZoneCBClick(Sender: TObject);
    procedure ZonesLBKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  public
    m_CurCon:cControlObj;
    m_ZoneList:cZoneList;
  public
    procedure ShowZoneElements;
    procedure ShowZone(z:cZone);
    procedure ShowZones(c:cControlObj);
    procedure ShowZonesLB;
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

procedure TDACControlEditFrame.ShowZoneElements;
begin
  if RelZoneCB.Checked then
  begin
    RelZoneCB.caption:='Относительные зоны';
    TolLabel.caption:='Допуск';
    TolLabel2.Visible:=false;
    TolEdit2.Visible:=false;
    ZoneTypeCB.Visible:=true;
  end
  else
  begin
    RelZoneCB.caption:='Абсолютные значения зон';
    TolLabel.caption:='Мин';
    TolLabel2.Visible:=true;
    TolEdit2.Visible:=true;
    ZoneTypeCB.Visible:=false;
  end;
end;

procedure TDACControlEditFrame.RelZoneCBClick(Sender: TObject);
begin
  if m_zonelist=nil then
    exit;
  ShowZoneElements;
  ShowZonesLB();
end;

procedure TDACControlEditFrame.ShowControlProps(con:cControlObj; endMS:boolean);
begin
  m_CurCon:=con;
  ZonesCB.Checked:=con.m_zones_enabled;
  SetMultiSelectComponentString(DACCB, cDacControl(con).m_dac_name);
  showZones(con);
end;

procedure TDACControlEditFrame.ShowZone(z:cZone);
var
  I: Integer;
  li:tlistitem;
  p:TTagPair;
begin
  TolEdit.FloatNum:=z.tol.x;
  TolEdit2.FloatNum:=z.tol.y;
  ZoneTypeCB.Checked:=(z.tol.x>0);
  // только для относительных зон
  if m_ZoneList.m_zones_Alg then
  begin
    if ZoneTypeCB.Checked then
      ZoneTypeCB.Caption:='Превышение уставки'
    else
      ZoneTypeCB.Caption:='Меньшен уставки';
  end;
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

procedure TDACControlEditFrame.ShowZonesLB;
var
  z:czone;
  I: Integer;
  srt:string;
begin
  z:=nil;
  if m_Zonelist.Count=0 then
  begin
    ZonesLB.Clear;
    exit;
  end;
  if ZonesLB.ItemIndex>-1 then
  begin
    z:=cZone(ZonesLB.Items.Objects[ZonesLB.ItemIndex]);
  end;
  ZonesLB.Clear;
  if (m_ZoneList.Count=1) and (not relZoneCB.Checked) then
  begin
    ZonesLB.AddItem(m_ZoneList.z_inf_neg.propstr(relZoneCB.Checked),m_ZoneList.z_inf_neg);
    z:=m_ZoneList.GetZone(0);
    ZonesLB.AddItem(z.propstr(relZoneCB.Checked),z);
    ZonesLB.AddItem(m_ZoneList.z_inf_pos.propstr(relZoneCB.Checked),m_ZoneList.z_inf_pos);
  end
  else
  begin
    for I := 0 to m_ZoneList.Count - 1 do
    begin
      z:=m_ZoneList.GetZone(i);
      ZonesLB.AddItem(z.propstr(relZoneCB.Checked),z);
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
  end;
  z:=cZone(m_ZoneList.GetZone(0));
  ShowZone(z);
end;

procedure TDACControlEditFrame.ShowZones(c:cControlObj);
var
  I: Integer;
  z:cZone;
  srt:string;
begin
  m_Zonelist:=c.m_ZoneList;
  RelZoneCB.Checked:=m_Zonelist.m_zones_Alg;
  ShowZoneElements;
  ShowZonesLB;
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
  pair:TTagPair;
  li:tlistitem;
  str:string;
  t:double;
begin
  if ZonesLB.ItemIndex>=0 then
  begin
    m_ZoneList.m_zones_Alg:=RelZoneCB.Checked;
    z:=cZone(ZonesLB.Items.Objects[ZonesLB.ItemIndex]);
    m_CurCon.m_zones_enabled:=ZonesCB.Checked;
    t:=z.tol.x;
    if RelZoneCB.checked then
    begin
      if zonetypecb.Checked then
        z.ftol.x:=abs(tolEdit.FloatNum)
      else
        z.ftol.x:=-abs(tolEdit.FloatNum);
    end
    else
      z.ftol.x:=tolEdit.FloatNum;
    z.ftol.y:=tolEdit2.FloatNum;
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
    if z.index<>-1 then
    begin
      cZonelist(z.owner).Delete(z.index);
      cZonelist(z.owner).AddObj(z);
      ShowZones(m_CurCon);
      for I := 0 to ZonesLB.Count - 1 do
      begin
        if ZonesLB.Items.Objects[i]=z then
        begin
          ZonesLB.ItemIndex:=i;
          break;
        end;
      end;
      z.fUsePrevZoneVals:=UsePrevValsCB.Checked;
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
    if z.defaultZone then
    begin
      UsePrevValsCB.Visible:=true;
      UsePrevValsCB.Checked:=z.fUsePrevZoneVals;
    end
    else
    begin
      UsePrevValsCB.Checked:=z.fUsePrevZoneVals;
      UsePrevValsCB.Visible:=false;
    end;
  end;
end;

procedure TDACControlEditFrame.ZonesLBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  z:cZone;
begin
  if key=VK_DELETE then
  begin
    z:=cZone(ZonesLB.Items.Objects[ZonesLB.ItemIndex]);
    if z.isneg then exit;
    if z.ispos then exit;
    z.destroy;
  end;
  ShowZones(m_CurCon);
end;

procedure TDACControlEditFrame.ZoneTypeCBClick(Sender: TObject);
begin
  inherited;
  if ZoneTypeCB.Checked then
    ZoneTypeCB.Caption:='Превышение уставки'
  else
    ZoneTypeCB.Caption:='Меньшен уставки';
end;

procedure TDACControlEditFrame.editcontrol(c:cControlObj);
var
  t:itag;
  I: Integer;
  z:cZone;
  tp:cTagPair;
  li:tlistitem;
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
  for I := 0 to c.TagsCount - 1 do
  begin
    tp:=c.getTag(i);
    li:=TPairLV.Items.Add;
    li.data:=tp;
    li.Caption:=tp.name;
    TPairLV.SetSubItemByColumnName('Значение', floattostr(tp.value), li);
  end;
end;

procedure TDACControlEditFrame.EndMS;
begin
  endMultiSelect(DACCB);
end;


procedure TDACControlEditFrame.AddZoneBtnClick(Sender: TObject);
var
  z, defzone:cZone;
  I: Integer;
  p:TTagPair;
begin
  if relZoneCB.Checked then
  begin
    if toledit.FloatNum<>0 then
    begin
      if zonetypecb.Checked then
        z:=m_CurCon.m_ZoneList.NewZone(p2d(toledit.FloatNum,0))
      else
        z:=m_CurCon.m_ZoneList.NewZone(p2d(-toledit.FloatNum,0));
      defzone:=m_CurCon.m_ZoneList.defaultZone;
      for I := 0 to defZone.tags.Count - 1 do
      begin
        p:=defZone.GetZonePair(i);
        z.AddZonePair(p);
      end;
      ShowZones(m_CurCon);
    end
    else
      toledit.Color:=clPink;
  end
  else
  begin
    z:=m_CurCon.m_ZoneList.NewZone(p2d(toledit.FloatNum,toledit2.FloatNum));
    ShowZones(m_CurCon);
  end;
end;

procedure TDACControlEditFrame.ChannelsLVDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  t:itag;
  s:string;
  li, next, newli:tlistitem;
  b:boolean;
  p:TTagPair;
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
