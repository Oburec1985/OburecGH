unit uTrigsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, uVTServices, Buttons, StdCtrls, DCL_MYOWN, ExtCtrls,
  ubaseobj, uComponentServises,
  uCommonMath, ComCtrls, uBtnListView,
  uControlObj, uBaseObjService, ImgList, activex,
  PluginClass, recorder, uRcCtrls, uRCFunc, uRvclService, tags,
  uRTrig, uTagsListFrame;

type
  TTrigsFrm = class(TForm)
    TrigsPanel: TPanel;
    TrigTV: TVTree;
    TrigsActionBtnPanel: TPanel;
    UpdateTrigBtn: TSpeedButton;
    AddTrigBtn: TSpeedButton;
    ImageList_16: TImageList;
    ImageList_32: TImageList;
    TrigsImages16: TImageList;
    TrigsImages32: TImageList;
    fv: TPanel;
    StartProgramGB: TGroupBox;
    ThresholdLabel: TLabel;
    TrigNameLabel: TLabel;
    Label1: TLabel;
    TrigRG: TRadioGroup;
    ThresholdFE: TFloatEdit;
    TrigNameEdit: TEdit;
    NotCB: TCheckBox;
    ActionsPanel: TPanel;
    ActionsTypesLB: TListBox;
    ActionPropsPanel: TPanel;
    ActionTargetLabel: TLabel;
    Label2: TLabel;
    ActionTarget: TComboBox;
    ActionText: TEdit;
    ActionsGB: TGroupBox;
    ActionsLV: TBtnListView;
    RightPanel: TPanel;
    ProgramTV: TVTree;
    EnableOnStartCB: TCheckBox;
    ActionFrontCB: TCheckBox;
    TagsListFrame1: TTagsListFrame;
    DisableOnApplyCB: TCheckBox;
    mdbPropPanel: TPanel;
    PropNameLabel: TLabel;
    Label3: TLabel;
    PropNameEdit: TEdit;
    MDBValueCB: TRcComboBox;
    TrigChannelCB: TRcComboBox;
    procedure AddTrigBtnClick(Sender: TObject);
    procedure ActionsLVDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ActionsLVDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ActionsLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ActionTargetDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ActionTargetDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TrigTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure EnableOnStartCBClick(Sender: TObject);
    procedure TrigTVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TrigRGClick(Sender: TObject);
    procedure ActionsLVKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure NotCBClick(Sender: TObject);
    procedure ActionsLVClick(Sender: TObject);
    procedure UpdateTrigBtnClick(Sender: TObject);
    procedure ActionFrontCBClick(Sender: TObject);
    procedure TrigTVBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
    procedure TrigTVClick(Sender: TObject);
    procedure DisableOnApplyCBClick(Sender: TObject);
    procedure ActionsTypesLBClick(Sender: TObject);
    procedure ActionTargetChange(Sender: TObject);
    procedure MDBValueCBChange(Sender: TObject);
    procedure PropNameEditChange(Sender: TObject);
    procedure ActionsLVEnter(Sender: TObject);
    procedure ActionsLVCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure TrigTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
      Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
      var Effect: Integer; var Accept: Boolean);
    procedure TrigTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
      DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
      Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure TrigNameEditChange(Sender: TObject);
  private
    m_conmng: cControlMng;
  protected
    procedure UpdateTrigPanByFocusedAction;
    // отобразить дерево с объектами движка
    procedure showControls;
    procedure ShowControlsInCB;

    //  отобразить список существующих триггеров
    procedure ShowTrigs;
    procedure TrigsToCB;
    procedure ShowProperties(t: cBaseTrig);
    procedure applyTrigProps(t: cBaseTrig; node: pvirtualnode);
    function NewTrig: cBaseTrig;
    procedure ShowAction(a: TTrigAction);
    // отобразить теги (в комбобоксах и списке тегов)
    procedure ShowTags(ir: irecorder);
    // отобразить список каналов в listView. Вызывается в ShowTags
    procedure ShowChannels;
    function FocusedAction:tTrigAction;
    procedure deleteTrigFromCB(t:cbasetrig);
  public
    procedure LinkPlg(p_conmng: cControlMng);
    function showmodal: Integer; override;
  end;

const
  c_MDB_addProp = 'БДИ: Прибавить свойство';
  c_MDB_setProp = 'БДИ: Установить свойство';
  c_MDB_decProp = 'БДИ: Вычесть свойство';

var
  TrigsFrm: TTrigsFrm;

implementation

{$R *.dfm}
{ TTrigsFrm }

function getselectTrig(tv: TVTree): cBaseTrig;
var
  n, parentnode: pvirtualnode;
  d: pnodedata;
begin
  result := nil;
  n := GetSelectNode(tv);
  if n = nil then
  begin
    n:=tv.GetFirst(true);
  end;
  if n=nil then exit;
  d := tv.getnodedata(n);
  if TObject(d.data) is cbaseobj then
  begin
    result := cBaseTrig(d.data);
  end
  else
  begin
    parentnode := n.Parent;
    d := tv.getnodedata(parentnode);
    result := cBaseTrig(d.data);
  end;
end;

procedure TTrigsFrm.ActionFrontCBClick(Sender: TObject);
var
  a:ttrigaction;
begin
  a:=FocusedAction;
  if a<>nil then
  begin
    a.m_Front:=ActionFrontCB.Checked;
  end;
end;

procedure TTrigsFrm.ActionsLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  a:TTrigAction;
begin
  if item.Data<>nil then
  begin
    a:=TTrigAction(item.Data);
    ShowAction(a);
  end
  else
  begin
    ActionTarget.Text:='';
    ActionText.Text:='';
  end;
  UpdateTrigPanByFocusedAction;
end;

procedure TTrigsFrm.ActionsLVClick(Sender: TObject);
var
  p:tpoint;
  li:tlistitem;
begin
  GetCursorPos(P);
  li:=actionslv.GetItemAt(p.x,p.y);
  if li=nil then
  begin
    actionslv.ItemFocused:=nil;
  end
  else
    ShowAction(FocusedAction);
  UpdateTrigPanByFocusedAction;
end;

procedure TTrigsFrm.ActionsLVCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
 if cdsFocused in State then
    begin
      //Item.Selected:=false;
      Sender.Canvas.Brush.Color:=clNavy;
    end;
end;

procedure TTrigsFrm.ActionsLVDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  a: TTrigAction;
  t: cBaseTrig;
  li: tlistitem;
begin
  if Source = ActionsTypesLB then
  begin
    t := getselectTrig(TrigTV);
    if t = nil then
      exit;
    a := TTrigAction.Create(t);
    case ActionsTypesLB.ItemIndex of
      0: // стартовать
        begin
          a.opertype := c_action_Start;
        end;
      1: // остановить
        begin
          a.opertype := c_action_Stop;
        end;
      2: // след. режим
        begin
          a.opertype := c_action_Next;
        end;
      3: // пред. режим
        begin
          a.opertype := c_action_Prev;
        end;
      4: // пауза
        begin
          a.opertype := c_action_Pause;
        end;
      5: // отключить
        begin
          a.opertype := c_action_Disable;
        end;
      6: // включить
        begin
          a.opertype := c_action_Enable;
        end;
      7: // БДИ
        begin
          a.opertype := c_action_MDBaddProp;
          a.targetname:=ActionTarget.Text;
        end;
      8: // БДИ
        begin
          a.opertype := c_action_MDBsetProp;
          a.targetname:=ActionTarget.Text;
        end;
      9: // БДИ
        begin
          a.opertype := c_action_MDBdecProp;
          a.targetname:=ActionTarget.Text;
        end;
    end;
    t.addAction(a);
    li := ActionsLV.items.Add;
    li.data := a;
    ActionsLV.SetSubItemByColumnName('Действия', ActionsTypesLB.items[ActionsTypesLB.ItemIndex], li);
    ShowAction(a);
    lvchange(ActionsLV);
  end;
end;

procedure TTrigsFrm.ActionsLVDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  li: tlistitem;
  a: TTrigAction;
  obj: TObject;
begin
  if Source = ActionsTypesLB then
  begin
    Accept := true;
  end;
  if Source = ProgramTV then
  begin
    li := ActionsLV.ItemFocused;
    if li = nil then
      exit;

    a := TTrigAction(li.data);
    obj := GetSelectObjectFromVTV(ProgramTV);
    // if GetObjectClass(li.Data) = nil then
    case a.opertype of
      c_action_Start:
        begin
          if (obj is cProgramObj) or (obj is cModeObj) then
          begin
            Accept := true;
          end;
        end;
      c_action_Stop:
        begin
          if (obj is cProgramObj) or (obj is cModeObj) then
          begin
            Accept := true;
          end;
        end;
      c_action_Next:
        begin
          if (obj is cProgramObj) then
          begin
            Accept := true;
          end;
        end;
      c_action_Prev:
        begin
          if (obj is cProgramObj) then
          begin
            Accept := true;
          end;
        end;
      c_action_Pause:
        begin
          if (obj is cProgramObj) then
          begin
            Accept := true;
          end;
        end;
      c_action_Enable:
        begin
          if (obj is cBaseTrig) then
          begin
            Accept := true;
          end;
        end;
      c_action_Disable:
        begin
          if (obj is cBaseTrig) then
          begin
            Accept := true;
          end;
        end;
    end;
  end;
end;

procedure TTrigsFrm.ActionsLVEnter(Sender: TObject);
var
  a:TTrigAction;
begin
  a:=FocusedAction;
  if a<>nil then
    ShowAction(a);
end;

procedure TTrigsFrm.ActionsLVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  li:tlistitem;
  I: Integer;
begin
  if key=VK_DELETE then
  begin
    for I := 0 to ActionsLV.SelCount - 1 do
    begin
      if i=0 then
        li:=ActionsLV.Selected
      else
        li:=ActionsLV.GetNextItem(li,sdAll,[isSelected]);
      ttrigaction(li.data).Destroy;
      li.Data:=nil;
    end;
    ActionsLV.DeleteSelected;
  end;
end;

procedure TTrigsFrm.ActionsTypesLBClick(Sender: TObject);
var
  str:string;
begin
  if ActionsTypesLB.ItemIndex>=0 then
  begin
    str:=ActionsTypesLB.Items.Strings[ActionsTypesLB.ItemIndex];
    if (str=c_MDB_addProp) or (str=c_MDB_setProp)  or (str=c_MDB_decProp) then
    begin
      ActionTarget.Items.Clear;
      ActionTarget.items.Add(c_MDB_objid);
      ActionTarget.items.Add(c_MDB_testid);
      ActionTarget.items.Add(c_MDB_regid);
      ActionTarget.ItemIndex:=2;
      mdbPropPanel.Visible:=true;
      PropNameEdit.Text:='';
      MDBValueCB.ItemIndex:=-1;
    end
    else
    begin
      ShowControlsInCB;
      mdbPropPanel.Visible:=false;
    end;
  end;
end;

procedure TTrigsFrm.ActionTargetChange(Sender: TObject);
var
  a:ttrigaction;
begin
  a:=FocusedAction;
  if a<>nil then
  begin
    if ActionTarget.ItemIndex<0 then exit;
    if (a.opertype=c_action_MDBaddProp) or
       (a.opertype=c_action_MDBsetProp) or
       (a.opertype=c_action_MDBdecProp) then
    begin
      a.targetname:=ActionTarget.Text;
    end
    else
    begin
      a.m_target:=ActionTarget.Items.Objects[ActionTarget.ItemIndex];
    end;
    ShowAction(a);
  end;
end;

procedure TTrigsFrm.ActionTargetDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  o:tobject;
  t:cbasetrig;
  a:ttrigaction;
begin
  if source=ProgramTV then
  begin
    o:=GetSelectObjectFromVTV(ProgramTV);
    if o<>nil then
    begin
      if o is cbaseobj then
      begin
        if setComboBoxItem(cbaseobj(o).caption,ActionTarget)<>-1 then
        begin
          a:=FocusedAction;
          if a<>nil then
          begin
            a.m_target:=o;
            ShowAction(a);
          end;
        end;
      end;
    end;
  end;
  if source=TrigTV then
  begin
    t:=getselectTrig(TrigTV);
    if t<>nil then
    begin
      if setComboBoxItem(t.caption,ActionTarget)<>-1 then
      begin
        a:=FocusedAction;
        if a<>nil then
        begin
          a.m_target:=t;
          ShowAction(a);
        end;
      end;
    end;
  end;
end;

procedure TTrigsFrm.ActionTargetDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  li:tlistitem;
begin
  // dragType в TV стоит dtVcl
  if Source=ProgramTV then
  begin
    Accept:=true;
  end
  else
  begin
    li:=ActionsLV.Selected;
    if li<>nil then
    begin
      if (ttrigaction(li.Data).opertype=c_action_Enable) or (ttrigaction(li.Data).opertype=c_action_Disable) then
      begin
        if Source=TrigTV then
        begin
          Accept:=true;
        end
      end;
    end;
  end;
end;

procedure TTrigsFrm.AddTrigBtnClick(Sender: TObject);
var
  t: cBaseTrig;
begin
  t := NewTrig;
end;

function TrigTypeToClass(t:integer):tclass;
begin
  case t of
    c_Trig_front: result:=cRTrig;
    c_Trig_Fall: result:=cRTrig;
    c_Trig_hiLvl: result:=cRTrig;
    c_Trig_loLvl: result:=cRTrig;
    c_Trig_Eqv: result:=cRTrig;
    c_Trig_Pause: result:=cTimeTrig;
    c_Trig_Alarms: result:=cAlarmTrig;
    c_Trig_Start: result:=cRTrig;
    c_Trig_Stop: result:=cRTrig;
  end;
end;

function CreateTrig(t:integer):cBaseTrig;
begin
  case t of
    c_Trig_front: result:=cRTrig.create(nil);
    c_Trig_Fall: result:=cRTrig.create(nil);
    c_Trig_hiLvl: result:=cRTrig.create(nil);
    c_Trig_loLvl: result:=cRTrig.create(nil);
    c_Trig_Eqv: result:=cRTrig.create(nil);
    c_Trig_Pause: result:=cTimeTrig.create(nil);
    c_Trig_Alarms: result:=cAlarmTrig.create(nil);
    c_Trig_Start: result:=cRTrig.create(nil);
    c_Trig_Stop: result:=cRTrig.create(nil);
  end;
end;


procedure TTrigsFrm.applyTrigProps(t: cBaseTrig; node: pvirtualnode);
var
  d: pnodedata;
  cl:tclass;
begin
  d := TrigTV.getnodedata(node);
  d.caption := TrigNameEdit.Text;
  cl:=TrigTypeToClass(TrigRG.ItemIndex);
  if cl<>t.ClassType then
  begin
    t.destroy;
    t:=CreateTrig(TrigRG.ItemIndex);
    d.data:=t;
    t.name:=TrigNameEdit.Text;
    g_conmng.addtrig(t);
  end;
  t.Trigtype := inttotrigtype(TrigRG.ItemIndex);
  d.ImageIndex:=t.imageindex;

  if t is crtrig then
  begin
    crtrig(t).setchannel(TrigChannelCB.Text);
    crtrig(t).Threshold := ThresholdFE.FloatNum;
  end;
  if t is cAlarmTrig then
  begin
    cAlarmTrig(t).setchannel(TrigChannelCB.Text);
  end;
  t.name := TrigNameEdit.Text;
  if t is cTimeTrig then
  begin
    cTimeTrig(t).dueTime := round(ThresholdFE.FloatNum) * 1000;
  end;
  t.Inverse := NotCB.Checked;
  TrigTV.Refresh;
end;

procedure TTrigsFrm.deleteTrigFromCB(t: cbasetrig);
var
  I: Integer;
begin
  for I := 0 to ActionTarget.Items.Count - 1 do
  begin
    if t=ActionTarget.Items.Objects[i] then
    begin
      ActionTarget.Items.Delete(i);
      break;
    end;
  end;
end;

procedure TTrigsFrm.DisableOnApplyCBClick(Sender: TObject);
var
  t:cbasetrig;
begin
  t:=getselectTrig(TrigTV);
  if t<>nil then
  begin
    t.m_DisableOnApply:=DisableOnApplyCB.Checked;
  end;
end;

procedure TTrigsFrm.EnableOnStartCBClick(Sender: TObject);
var
  t:cbasetrig;
begin
  t:=getselectTrig(TrigTV);
  if t<>nil then
  begin
    t.m_EnableOnStart:=EnableOnStartCB.Checked;
  end;
end;

function TTrigsFrm.FocusedAction: tTrigAction;
begin
  result:=nil;
  if ActionsLV.ItemFocused<>nil then
  begin
    result:=tTrigAction(ActionsLV.ItemFocused.Data);
  end;
end;

procedure TTrigsFrm.LinkPlg(p_conmng: cControlMng);
begin
  m_conmng := p_conmng;
end;

procedure TTrigsFrm.MDBValueCBChange(Sender: TObject);
var
  a:TTrigAction;
begin
  a:=FocusedAction;
  if a<>nil then
  begin
    a.mdbPropVal:=MDBValueCB.Text;
    if CheckCBItemInd(MDBValueCB) then
    begin
      a.mdbtag:=MDBValueCB.gettag(MDBValueCB.ItemIndex);
    end
    else
    begin
      a.mdbtag:=nil;
    end;
  end;
end;

function TTrigsFrm.NewTrig: cBaseTrig;
var
  obj: TObject;
  parentnode, n: pvirtualnode;
  node: pvirtualnode;
  d: pnodedata;
  subname: string;
begin
  TrigNameEditChange(nil);
  // parentnode:=TrigTV.GetFirstSelected(false);
  case inttotrigtype(TrigRG.ItemIndex) of
    TrPause:
    begin
      result := cTimeTrig.Create(nil);
    end;
    trAlarms:
    begin
      result := cAlarmTrig.Create(nil);
    end
    else
    begin
      result := crtrig.Create(nil);
    end;
  end;
  crtrig(result).Trigtype := inttotrigtype(TrigRG.ItemIndex);

  result.m_actions := TList.Create;
  if result is crtrig then
  begin
    crtrig(result).Threshold := ThresholdFE.FloatNum;
    crtrig(result).setchannel(TrigChannelCB.Text);
  end;
  if result is cAlarmTrig then
  begin
    cAlarmTrig(result).setchannel(TrigChannelCB.Text);
  end;
  if TrigNameEdit.Text = '' then
  begin
    TrigNameEdit.Text := result.ClassName;
  end;
  result.name := TrigNameEdit.Text;
  if result is cTimeTrig then
  begin
    cTimeTrig(result).dueTime := round(ThresholdFE.FloatNum * 1000);
  end;
  obj := GetSelectObjectFromVTV(TrigTV);
  if obj <> nil then
  begin
    if obj is cbaseobj then
    begin
      cbaseobj(obj).AddChild(result);
      // добавляем узел в отображении
      n := GetObjectNodeFromVTV(TrigTV, pointer(obj));
      if n = nil then
        exit;
      node := TrigTV.AddChild(n);
      d := TrigTV.getnodedata(node);
      d.color := TrigTV.normalcolor;
      d.caption := result.caption;
      d.data := result;
      d.ImageIndex := result.ImageIndex;
      result.ShowComponent(node, TrigTV);
    end;
    if obj is tstringlist then
    begin
      n := GetSelectNode(TrigTV);
      parentnode := n.Parent;
      d := TrigTV.getnodedata(parentnode);
      if obj = cBaseTrig(d.data).m_orTrigs then
      begin
        cBaseTrig(d.data).addOrTrig(result);
      end;
      if obj = cBaseTrig(d.data).m_andTrigs then
      begin
        cBaseTrig(d.data).addAndTrig(result);
      end;
      node := TrigTV.AddChild(n);
      d := TrigTV.getnodedata(node);
      d.color := TrigTV.normalcolor;
      d.caption := result.caption;
      d.data := result;
      d.ImageIndex := result.ImageIndex;
      result.ShowComponent(node, TrigTV);
    end;
  end
  else
  // не выбран ни один узел
  begin
    node := TrigTV.AddChild(TrigTV.RootNode);
    d := TrigTV.getnodedata(node);
    d.color := TrigTV.normalcolor;
    d.caption := result.caption;
    d.data := result;
    d.ImageIndex := result.ImageIndex;
    result.ShowComponent(node, TrigTV)
  end;
  g_conmng.addtrig(result);

  ActionTarget.AddItem(result.caption, result);
  TrigTV.Refresh;
end;

procedure TTrigsFrm.NotCBClick(Sender: TObject);
var
  t:cbasetrig;
begin
  t:=getselectTrig(TrigTV);
  if t<>nil then
  begin
    t.Inverse:=NotCB.Checked;
  end;
end;

procedure TTrigsFrm.PropNameEditChange(Sender: TObject);
var
  a:TTrigAction;
begin
  a:=FocusedAction;
  a.mdbPropName:=propnameedit.Text;
end;

procedure TTrigsFrm.ShowAction(a: TTrigAction);
var
  str:string;
begin
  if a.m_target<>nil then
  begin
    setComboBoxItem(cbaseobj(a.m_target).caption,ActionTarget);
    if a.m_target is cbaseobj then
    begin
      ActionTarget.text:=cbaseobj(a.m_target).caption;
    end;
  end
  else
  begin
    setComboBoxItem('',ActionTarget);
  end;
  ActionFrontCB.Checked:=a.m_Front;
  ActionText.Text:=a.GetString;

  str:=ActionsTypesLB.Items.Strings[a.opertype];
  if (str=c_MDB_addProp) or (str=c_MDB_setProp)  or (str=c_MDB_decProp) then
  begin
    ActionTarget.Items.Clear;
    ActionTarget.items.Add(c_MDB_objid);
    ActionTarget.items.Add(c_MDB_testid);
    ActionTarget.items.Add(c_MDB_regid);
    setComboBoxItem(a.targetname,ActionTarget);
    mdbPropPanel.Visible:=true;
    PropNameEdit.Text:=a.mdbPropName;
    setComboBoxItem(a.mdbPropVal,MDBValueCB);
  end
  else
  begin
    mdbPropPanel.Visible:=false;
  end;
end;

procedure ShowProgramsTV(tv: TVTree; mng: cControlMng; image: TImageList);
var
  I: Integer;
begin
  showInVTreeView(tv, mng.programs, image);
end;

procedure TTrigsFrm.showControls;
begin
  ShowProgramsTV(ProgramTV, m_conmng, ImageList_16);
  ShowControlsInCB;
end;

procedure TTrigsFrm.ShowControlsInCB;
var
  I: Integer;
  o:cbaseobj;
begin
  ActionTarget.Clear;
  for I := 0 to g_conmng.Count - 1 do
  begin
    o:=g_conmng.getobj(i);
    if (o is cControlObj)
    or (o is cProgramObj)
    or (o is cModeObj)
    then
    begin
      ActionTarget.AddItem(o.caption, o);
    end;
  end;
  for I := 0 to g_conmng.TrigCount - 1 do
  begin
    o:=g_conmng.getTrig(i);
    ActionTarget.AddItem(o.caption, o);
  end;
end;

function TTrigsFrm.showmodal: Integer;
begin
  ShowTags(getir);
  showControls;
  ShowTrigs;
  result := inherited showmodal;
end;

procedure TTrigsFrm.ShowProperties(t: cBaseTrig);
var
  I: Integer;
  a:TTrigAction;
  li:tlistitem;
  p:TLVChangeEvent;
begin
  if t = nil then
    exit;
  NotCB.Checked:=t.Inverse;
  EnableOnStartCB.Checked:=t.m_EnableOnStart;
  DisableOnApplyCB.Checked:=t.m_DisableOnApply;
  TrigNameEdit.Text := t.name;
  TrigRG.ItemIndex := trigtypetoint(t.Trigtype);
  ThresholdFE.Visible:=true;
  if t is crtrig then
  begin
    setComboBoxItem(crtrig(t).channame, TrigChannelCB);
    ThresholdFE.FloatNum := crtrig(t).Threshold;
  end;
  if t is cAlarmTrig then
  begin
    ThresholdFE.Visible:=false;
    setComboBoxItem(cAlarmTrig(t).tag.tagname, TrigChannelCB);
    ThresholdFE.FloatNum := crtrig(t).Threshold;
  end;
  if t is cTimeTrig then
  begin
    TrigChannelCB.Text := '';
    ThresholdFE.FloatNum := cTimeTrig(t).dueTime / 1000;
  end;
  ActionsLV.clear;
  p:=ActionsLV.OnChange;
  ActionsLV.OnChange:=nil;
  for I := 0 to t.m_actions.Count - 1 do
  begin
    a:=TTrigAction(t.m_actions.Items[i]);
    li:=ActionsLV.Items.Add;
    li.data:=a;
    ActionsLV.SetSubItemByColumnName('Действия',a.GetString,li);
  end;
  LVChange(ActionsLV);
  ActionsLV.OnChange:=p;
end;

procedure TTrigsFrm.ShowTags(ir: irecorder);
begin
  tagsToCB(ir,TrigChannelCB);
  tagsToCB(ir,mdbValueCB);
  ShowChannels;
end;

procedure TTrigsFrm.ShowChannels;
begin
  TagsListFrame1.ShowChannels;
end;

procedure TTrigsFrm.ShowTrigs;
var
  I: Integer;
  t: cBaseTrig;
begin
  TrigTV.Clear;
  for I := 0 to m_conmng.TrigCount - 1 do
  begin
    t := m_conmng.getTrig(I);
    if t.Parent = nil then
    begin
      if t.m_actions <> nil then
      begin
        ShowBaseObjectInVTreeView(TrigTV, t, nil);
      end;
    end;
  end;
  TrigsToCB;
end;

procedure TTrigsFrm.TrigNameEditChange(Sender: TObject);
var
  t:cbasetrig;
begin
  t:=g_conmng.getTrig(TrigNameEdit.text);
  if t<>nil then
  begin
    TrigNameEdit.Color:=c_lightRed;
    TrigNameEdit.ShowHint:=true;
    exit;
  end
  else
  begin
    TrigNameEdit.Color:=clWindow;
    TrigNameEdit.ShowHint:=false;
  end;
end;

procedure TTrigsFrm.TrigRGClick(Sender: TObject);
var
  lvisible:boolean;
begin
  lvisible:=not (
                  (inttotrigtype(TrigRG.ItemIndex)=TrPause) or
                  (inttotrigtype(TrigRG.ItemIndex)=trStart) or
                  (inttotrigtype(TrigRG.ItemIndex)=trStop)
                );
  TrigChannelCB.Visible:=lvisible;
  TrigNameLabel.Visible:=lvisible;
  lvisible:=not (
                  (inttotrigtype(TrigRG.ItemIndex)=trStart) or
                  (inttotrigtype(TrigRG.ItemIndex)=trStop) or
                  (inttotrigtype(TrigRG.ItemIndex)=trAlarms)
                );
  ThresholdLabel.Visible:=lvisible;
  ThresholdFE.Visible:=lvisible;

  lvisible:=not (
                  (inttotrigtype(TrigRG.ItemIndex)=trStart) or
                  (inttotrigtype(TrigRG.ItemIndex)=trStop)
                );
  notCB.Visible:=lvisible;
  EnableOnStartCB.Visible:=lvisible;
  DisableOnApplyCB.Visible:=lvisible;
end;

procedure TTrigsFrm.TrigsToCB;
var
  I: Integer;
  n:PVirtualNode;
  d:PNodeData;
  t:cbasetrig;
begin
  i:=0;
  while I <= ActionTarget.items.Count - 1 do
  begin
    if ActionTarget.Items.Objects[i] is cbasetrig then
    begin
      ActionTarget.Items.Delete(i);
    end;
    inc(i);
  end;
  for I := 0 to m_conmng.TrigCount - 1 do
  begin
    t := m_conmng.getTrig(I);
    if t.m_actions <> nil then
    begin
      ActionTarget.Items.AddObject(t.caption,t);
    end;
  end;
end;

procedure TTrigsFrm.TrigTVBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
begin
  if Sender.FocusedNode=node then
  begin
    TargetCanvas.Brush.Color := clMenuHighlight;
    TargetCanvas.FillRect(CellRect);
  end;
end;

procedure TTrigsFrm.TrigTVChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  t:cbasetrig;
  d:pnodedata;
  cl:tclass;
  a:ttrigaction;
begin
  a:=FocusedAction;
  if a<>nil then
  begin
    exit;
  end;
  if node<>nil then
  begin
    d:=TrigTV.getnodedata(node);
    if d<>nil then
    begin
      if d.data <>nil then
      begin
        cl:=GetObjectClass(d.data);
        if (cl = cBaseTrig) or (cl.ClassParent = cBaseTrig) then
        begin
          t:=cbasetrig(d.data);
          ShowProperties(t);
        end;
      end;
    end;
  end
  else
  begin
    ActionsLV.clear;
  end;
end;

procedure TTrigsFrm.TrigTVClick(Sender: TObject);
begin
  if TrigTV.SelectedCount=0 then
  begin
    TrigTV.FocusedNode:=nil;
  end;
end;

procedure TTrigsFrm.TrigTVDragDrop(Sender: TBaseVirtualTree; Source: TObject;
  DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState;
  Pt: TPoint; var Effect: Integer; Mode: TDropMode);
var
  pSource, pTarget: PVirtualNode;
  attMode: TVTNodeAttachMode;
  dstdata,srcdata:pnodedata;
  n:pvirtualnode;
  d:PNodeData;
  I: Integer;
  t, srcT:cbasetrig;
begin
  pSource := TVirtualStringTree(Source).FocusedNode;
  pTarget := Sender.DropTargetNode;
  srcdata:=trigtv.GetNodeData(pSource);
  if tobject(srcdata.data) is cbasetrig then
  begin
    srcT:=cbasetrig(srcdata.data);
  end
  else
  begin
    if tobject(srcdata.data) is tstringlist then
    begin
      pSource:=pSource.Parent;
      srcdata:=trigtv.GetNodeData(pSource);
      srcT:=cbasetrig(srcdata.data);
    end;
  end;
  dstdata:=trigtv.GetNodeData(pTarget);
  for I := 0 to g_conmng.trigCount - 1 do
  begin
    t:=g_conmng.getTrig(i);
    if t.m_andTrigs=dstdata.data then
    begin
      t.addAndTrig(srcT);
      ShowTrigs;
      exit;
    end;
    if t.m_orTrigs=dstdata.data then
    begin
      t.addOrTrig(srcT);
      ShowTrigs;
      exit;
    end;
  end;

end;

procedure TTrigsFrm.TrigTVDragOver(Sender: TBaseVirtualTree; Source: TObject;
  Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode;
  var Effect: Integer; var Accept: Boolean);
var
  pSource, pTarget:PVirtualNode;
  dstdata,srcdata:pnodedata;
begin
  Accept := false;
  if Source = TrigTV then
  begin
    pSource := TVirtualStringTree(Source).FocusedNode;
    pTarget := Sender.DropTargetNode;
    if pTarget=nil then
      exit;
    dstdata:=Sender.GetNodeData(pTarget);
    if tobject(dstdata.data) is tstringlist then
    begin
      Accept:=true;
    end;
  end;
end;

procedure TTrigsFrm.TrigTVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  t:cbasetrig;
  n, next:PVirtualNode;
  d:pnodedata;
  I: Integer;
begin
  if key=VK_DELETE then
  begin
    t:=getselectTrig(TrigTV);
    if t<>nil then
    begin
      n:=TrigTV.GetNodeByPointer(t);
    end;
    while n<>nil do
    begin
      next:=TrigTV.GetNextSelected(n,false);
      d:=TrigTV.GetNodeData(n);
      t:=cbasetrig(d.data);
      deleteTrigFromCB(t);
      t.destroy;
      d.data:=nil;
      TrigTV.DeleteNode(n, true);
      n:=next;
    end;
  end;
end;

procedure TTrigsFrm.UpdateTrigBtnClick(Sender: TObject);
var
  t:cbasetrig;
  n:pvirtualnode;
begin
  t:=getselectTrig(trigtv);
  n:=trigtv.GetNodeByPointer(t);
  applyTrigProps(t, n);
end;

procedure TTrigsFrm.UpdateTrigPanByFocusedAction;
var
  b:boolean;
begin
  if actionslv.ItemFocused=nil then
  begin
    b:=true;
  end
  else
  begin
    b:=false;
  end;
  UpdateTrigBtn.Enabled:=b;
  AddTrigBtn.Enabled:=b;
  TrigNameEdit.Enabled:=b;
  TrigChannelCB.Enabled:=b;
  ThresholdFE.Enabled:=b;
  NotCB.Enabled:=b;
  EnableOnStartCB.Enabled:=b;
  DisableOnApplyCB.Enabled:=b
end;

end.
