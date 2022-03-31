unit uDacControlEditFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, recorder, tags, uCommonMath, inifiles, uControlObj, uRCFunc,
  uComponentServises, uCustomEditControlFrame, ubtnlistview, ComCtrls, Buttons,
  ExtCtrls, DCL_MYOWN;

type
  TDACControlEditFrame = class(TCustomControlEditFrame)
    FeedbackLabel: TLabel;
    DACCB: TComboBox;
    RightGB: TGroupBox;
    LowPanel: TPanel;
    AddZoneBtn: TSpeedButton;
    ListBox1: TListBox;
    ChannelsLV: TBtnListView;
    TolEdit: TFloatEdit;
    TolLabel: TLabel;
    ZoneTypeCB: TCheckBox;
    procedure ChannelsLVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ChannelsLVDragDrop(Sender, Source: TObject; X, Y: Integer);
  public
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
  SetMultiSelectComponentString(DACCB,cDacControl(con).m_dac_name);
  //if endMS then
  //begin
  //  endMultiSelect(DACCB);
  //end;
end;

procedure TDACControlEditFrame.editcontrol(c:cControlObj);
var
  t:itag;
begin
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


procedure TDACControlEditFrame.ChannelsLVDragDrop(Sender, Source: TObject; X,
  Y: Integer);
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
    // отрисовка свойств тега
    newli:=tbtnlistview(sender).items.Add;
    newli.data:=pointer(t);
    s:=t.getName;
    tbtnlistview(sender).SetSubItemByColumnName('Имя',s,newli);
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
