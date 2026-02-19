unit uControlEditFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, uDacControlEditFrame,
  Recorder, Tags, uBtnListView, uComponentServises, uCustomEditControlFrame,
  inifiles, uControlObj, uCommonMath, uRCFunc;

type
  TControlEditFrame = class(TFrame)
    ControlPanel: TPanel;
    ControlsPageControl: TPageControl;
    ControlNameLabel: TLabel;
    FeedbackLabel: TLabel;
    ControlNameEdit: TEdit;
    FeedbackCB: TComboBox;
    Splitter1: TSplitter;
    procedure FeedbackCBDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FeedbackCBDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FeedbackCBChange(Sender: TObject);
  private
    m_frameList:tstringlist;
    m_init:boolean;
    m:cControlMng;
  private
    procedure doUpdateChannelList;
    procedure addframe(fr:tCustomControlEditFrame);
  public
    procedure EndControlsMS;
    // отобразить состояние
    procedure Show;
    procedure ShowChannels;
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
    procedure Save(f:tinifile; section:string);
    procedure Load(f:tinifile; section:string);
    function CheckControlName:boolean;
    function CreateControl(p_m:cControlMng):cControlObj;
    procedure editControl(con:ccontrolobj);
    procedure ShowControlProps(con:ccontrolobj; endMS:boolean);
  end;

implementation
uses
  pluginclass;
{$R *.dfm}

procedure TControlEditFrame.EndControlsMS;
var
  fr:TCustomControlEditFrame;
  i:integer;
begin
  endMultiSelect(ControlNameEdit);
  endMultiSelect(FeedbackCB);
  for I := 0 to m_frameList.Count - 1 do
  begin
    fr:=TCustomControlEditFrame(m_frameList.Objects[i]);
    fr.endMS;
  end;
end;

function TControlEditFrame.CheckControlName:boolean;
var
  con:cControlObj;
begin
  con:=m.getControlObj(ControlNameEdit.text);
  if con<>nil then
  begin
    ControlNameEdit.color := $008080FF;
    result:=false;
    exit;
  end;
  if ControlNameEdit.text <> '' then
  begin
    result := true;
    ControlNameEdit.color := clWindow;
  end
  else
  begin
    ControlNameEdit.color := $008080FF;
    result:=false;
    exit;
  end;
end;

function TControlEditFrame.CreateControl(p_m:cControlMng):cControlObj;
var
  con:cControlObj;
  fr:TCustomControlEditFrame;
  t:itag;
begin
  m:=p_m;
  result:=nil;
  if CheckControlName then
  begin
    fr:=TCustomControlEditFrame(m_frameList.Objects[ControlsPageControl.ActivePageIndex]);
    con:=m.createControl(ControlNameEdit.Text, fr.ControlType);
    fr.editcontrol(con);
    t:=nil;
    if feedbackcb.Text<>'' then
    begin
      if feedbackcb.ItemIndex=-1 then
      begin
        setComboBoxItem(feedbackcb.Text,feedbackcb);
      end;
      if feedbackcb.ItemIndex>-1  then
      begin
        t:=itag(pointer(feedbackcb.Items.Objects[feedbackcb.ItemIndex]));
      end;
    end;
    con.config(t,nil);
    result:=con;
  end
  else
  begin
    showmessage('Необходимо назначить имя!');
  end;
end;



procedure TControlEditFrame.editControl(con:ccontrolobj);
var
  fr:TCustomControlEditFrame;
  t:itag;
  err, b:boolean;
begin
  fr:=TCustomControlEditFrame(m_frameList.Objects[ControlsPageControl.ActivePageIndex]);
  if not MultiSelectState(ControlNameEdit) then
  begin
    con.name:=ControlNameEdit.text;
  end;
  t:=itag(getselectobject(FeedbackCB));
  if (t<>nil) then
    con.config(t, nil);
  if t=nil then
  begin
    if not MultiSelectState(FeedbackCB) then
    begin
      con.config(nil, nil);
    end;
  end;
  if fr<>nil then
  begin
    fr.editcontrol(con);
  end;
end;



procedure TControlEditFrame.Save(f: tinifile; section: string);
var
  fr:TCustomControlEditFrame;
  i:integer;
begin
  f.WriteString(section, 'ControlName', ControlNameEdit.text);
  f.WriteString(section, 'ControlFeedBack', ControlNameEdit.text);
  for I := 0 to m_frameList.Count - 1 do
  begin
    fr:=TCustomControlEditFrame(m_frameList.Objects[i]);
    fr.Save(f, section);
  end;
end;

procedure TControlEditFrame.Load(f: tinifile; section: string);
var
  fr:TCustomControlEditFrame;
  i:integer;
begin
  ControlNameEdit.text:=f.ReadString(section, 'ControlName', '');
  ControlNameEdit.text:=f.ReadString(section, 'ControlFeedBack', '');
  for I := 0 to m_frameList.Count - 1 do
  begin
    fr:=TCustomControlEditFrame(m_frameList.Objects[i]);
    fr.Load(f, section);
  end;
end;

procedure TControlEditFrame.Show;
begin
  doUpdateChannelList;
  if not m_init then
  begin
    m_init:=true;
  end;
  ShowChannels;
end;

procedure TControlEditFrame.ShowChannels;
var
  I,ind, tCount: Integer;
  ir:IRecorder;
  t:iTag;
  tname, text:string;
  ls:linkstate;
  b:boolean;
  v:olevariant;
  li:tlistitem;
begin
  ir:=getIR;
  // обновляем список каналов
  tCount:=ir.GetTagsCount;

  // Входные каналы
  FeedBackCB.Items.Clear;
  text:=FeedBackCB.text;
  ind:=-1;
  if tCount=0 then exit;
  for I := 0 to tCount - 1 do
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
    if (checkflag(v,TTAG_INPUT)) or (b) then
    begin
      FeedBackCB.Items.AddObject(tname,pointer(t));
    end;
  end;
end;

procedure TControlEditFrame.doUpdateChannelList;
var
  fr:TCustomControlEditFrame;
  i:integer;
begin
  showChannels;
  for I := 0 to m_frameList.Count - 1 do
  begin
    fr:=TCustomControlEditFrame(m_frameList.Objects[i]);
    fr.doUpdateChannelList;
  end;
end;

procedure TControlEditFrame.ShowControlProps(con:ccontrolobj; endMS:boolean);
var
  fr:TCustomControlEditFrame;
  i:integer;
  tname:string;
begin
  SetMultiSelectComponentString(ControlNameEdit,con.name);
  tname:=con.feedbackname;
  SetMultiSelectComponentString(FeedbackCB,tname);
  //if endMS then
  //EndControlsMS;
  for I := 0 to m_frameList.Count - 1 do
  begin
    fr:=TCustomControlEditFrame(m_frameList.Objects[i]);
    fr.ShowControlProps(con, endMS);
  end;
end;


procedure TControlEditFrame.FeedbackCBChange(Sender: TObject);
begin
  if tcombobox(sender).ItemIndex>-1 then
  begin
    setComboBoxItem(tcombobox(sender).text,tcombobox(sender));
  end;
end;

procedure TControlEditFrame.FeedbackCBDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  t:itag;
  s:string;
  li:tlistitem;
begin
  li:=tbtnlistview(source).selected;//tbtnlistview(source).GetItemAt(x,y);
  t:=itag(li.data);
  s:=t.getname;
  setComboBoxItem(s,tcombobox(sender));
end;

procedure TControlEditFrame.FeedbackCBDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  li:tlistitem;
  v:cardinal;
begin
  Accept:=false;
  if source is tBtnListView then
  begin
    li:=tBtnListView(source).selected;
    if li=nil then exit;
    if li.Data <>nil then
    begin
      if GetObjectClass(li.Data) = nil then
      begin
        if tListitem(source).Data <>nil then
        begin
          Accept:= Supports(itag(li.Data),IID_ITAG);
        end;
      end;
    end;
  end;
end;

procedure TControlEditFrame.addframe(fr:tCustomControlEditFrame);
var
  page:TTabSheet;
begin
  m_frameList.AddObject(fr.ClassName, fr);
  // создание подфреймов с настройками конкретных реализаций контрола
  page:=TTabSheet.Create(self);
  page.Caption:=fr.GetDsc;
  page.PageControl:=ControlsPageControl;
  fr.Parent:=page;
  fr.linkChannelsLV(FeedbackCBDragOver, FeedbackCBDragDrop);
end;

constructor TControlEditFrame.create(aowner:tcomponent);
var
  fr:tCustomControlEditFrame;
begin
  inherited;
  m_init:=false;
  m_frameList:=TStringList.Create;
  // создаем фремй прямого управления DAC
  fr:=TDacControlEditFrame.Create(self);
  addframe(fr);
end;

destructor TControlEditFrame.destroy;
begin
  m_frameList.Destroy;
  inherited;
end;

end.
