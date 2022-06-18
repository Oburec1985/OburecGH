unit uAlgFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, uBtnListView, Buttons, StdCtrls, uAlgFrame,
  uCounterAlgFrame, uBaseAlg, uAlgAddFrm, uComponentServises, uBaseObj, uPhaseFrame,
  uPhaseCrossSpmFrame,  uTagsListFrame, uTahoAlgFrame, uGrmsFrame, tags,
  ucommonmath,
  uGrmsSrcFrame,
  uSpmFrame,
  uAriphmAlgFrame,
  uFillFctFrame,
  uPeakFactorFrame,
  uIntegralAlgFrame,
  uRCFunc, Menus, uBandsFrm;

type
  TAlgFrm = class(TForm)
    TagsListPanel: TPanel;
    AlgPropPanel: TPanel;
    BottomPanel: TPanel;
    Splitter1: TSplitter;
    AlgLV: TBtnListView;
    Panel1: TPanel;
    AddAlgBtn: TSpeedButton;
    UpdateAlgBtn: TSpeedButton;
    Splitter2: TSplitter;
    AlgsPageControl: TPageControl;
    TagsListFrame1: TTagsListFrame;
    MainMenu1: TMainMenu;
    BandsMenu: TMenuItem;
    procedure AddAlgBtnClick(Sender: TObject);
    procedure AlgLVKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure AlgLVSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure UpdateAlgBtnClick(Sender: TObject);
    procedure BandsMenuClick(Sender: TObject);
    procedure AlgLVCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    m_frameList:tstringlist;
    m_init:boolean;
  private
    function selectalg:cbasealgcontainer;
    procedure delalg(a: cbaseobj);
    procedure showAlgsInLV;
    procedure addframe(fr:TBaseAlgFrame);
  public
    constructor create(aowner:tcomponent);override;
    destructor destroy;override;
  end;

var
  AlgFrm: TAlgFrm;

implementation

{$R *.dfm}

{ TAlgFrm }

procedure TAlgFrm.AddAlgBtnClick(Sender: TObject);
var
  a:cbasealgcontainer;
  I: Integer;
  li:tlistitem;
  t:itag;
  showalg:boolean;
begin
  for I := 0 to TagsListFrame1.TagsLV.SelCount - 1 do
  begin
    if i=0 then
    begin
      li:=TagsListFrame1.TagsLV.Selected;
      showalg:=true;
    end
    else
    begin
      li:=TagsListFrame1.TagsLV.GetNextItem(li,sdAll, [isSelected]);
      showalg:=false;
    end;
    t:=itag(li.Data);
    a:=addAlgFrm.CreateAlg(showalg);
    if a<>nil then
    begin
      a.setfirstchannel(t);
      if t<>nil then
      begin
        //a.createOutChan;
        a.updateoutchan;
      end;
      while g_algMng.getAlg(a.name)<>nil do
      begin
        a.name:=modname(a.name, false);
      end;
      g_algMng.Add(a, nil);
    end
    else
    begin
      exit;
    end;
  end;
  showAlgsInLV;
end;

procedure TAlgFrm.addframe(fr: TBaseAlgFrame);
var
  page:TTabSheet;
begin
  m_frameList.AddObject(fr.ClassName, fr);
  // создание подфреймов с настройками конкретных реализаций контрола
  page:=TTabSheet.Create(self);
  page.Caption:=fr.GetDsc;
  page.PageControl:=AlgsPageControl;
  fr.Parent:=page;
end;

procedure TAlgFrm.AlgLVCustomDrawItem(Sender: TCustomListView; Item: TListItem;
  State: TCustomDrawState; var DefaultDraw: Boolean);
var
  r:trect;
  str:string;
  I: integer;
begin
 if Item.Selected and not (cdsFocused in State) then
 begin
   DefaultDraw:=false;
   r:=Item.DisplayRect(drBounds);
   with TListView(sender).Canvas do
   begin
     Brush.Color:=clHighlight;
     FillRect(r);
     Brush.Color:=clHighlightText;
     str:=item.Caption;
     for I := 0 to item.SubItems.Count - 1 do
     begin
       str:=str+ ' ' +item.SubItems[i];
     end;
     TextOut(r.Left,R.Top,str);
   end;
 end
 else
 begin
   DefaultDraw:=true;
 end;
end;

procedure TAlgFrm.AlgLVKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  I: Integer;
  li, next: TListItem;
  obj: cbaseobj;
begin
  if Key = VK_DELETE then
  begin
    li:=AlgLV.Selected;
    while li<>nil do
    begin
      obj:=cbaseobj(li.data);
      next:=AlgLV.GetNextItem(li,sdAll,[isSelected]);
      delalg(obj);
      li:=next;
    end;
  end;
end;

procedure TAlgFrm.AlgLVSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  I: Integer;
  fr,firstalgFrame:TBaseAlgFrame;
  firstalg,a:cbasealgcontainer;
  j: Integer;
  li:tlistitem;
begin
  firstalgFrame:=nil;
  for j := 0 to algLV.SelCount - 1 do
  begin
    if j=0 then
      li:=algLV.Selected
    else
      li:=algLV.GetNextItem(li,sdAll,[isselected]);
    a:=cbasealgcontainer(li.data);
    if j=0 then
    begin
      firstalg:=a;
      for I := 0 to m_frameList.Count - 1 do
      begin
        fr:=TBaseAlgFrame(m_frameList.Objects[i]);
        fr.m_a:=a;
        if not fr.ShowAlg(a) then
        begin
          AlgsPageControl.Pages[i].Visible:=false;
          AlgsPageControl.Pages[i].TabVisible:=false;
        end
        else
        begin
          AlgsPageControl.ActivePageIndex:=i;
          AlgsPageControl.Pages[i].Visible:=true;
          AlgsPageControl.Pages[i].TabVisible:=true;
          firstalgFrame:=fr;
        end;
      end;
    end
    else
    begin
      if a.ClassType=firstalg.ClassType then
        firstalgFrame.ShowAlg(a);
    end;
  end;
  if firstalgFrame<>nil then
    firstalgFrame.EndMsel;
end;

procedure TAlgFrm.BandsMenuClick(Sender: TObject);
begin
  bandsFrm.showmodal;
end;

procedure TAlgFrm.delalg(a: cbaseobj);
var
  I: Integer;
  li:tlistitem;
begin
  // удаление из таблицы контролов
  for I := 0 to AlgLV.items.Count - 1 do
  begin
    li:=AlgLV.items[i];
    if li.data=a then
    begin
      li.Destroy;
      break;
    end;
  end;
  a.destroy;
end;

constructor TAlgFrm.create(aowner: tcomponent);
var
  fr:TBaseAlgFrame;
begin
  inherited;
  m_init:=false;
  m_frameList:=TStringList.Create;

  // создаем фремй прямого управления DAC
  fr:=TTahoAlgFrame.Create(self);
  addframe(fr);

  fr:=TCounterAlgFrame.Create(self);
  addframe(fr);

  //fr:=TGrmsFrame.Create(self);
  //addframe(fr);

  fr:=TSynchroPhasePhrame.Create(self);
  addframe(fr);

  fr:=TGrmsSrcFrame.Create(self);
  addframe(fr);

  fr:=TSpmFrame.Create(self);
  addframe(fr);

  fr:=TPhaseFrame.Create(self);
  addframe(fr);

  fr:=TFillFctFrame.Create(self);
  addframe(fr);

  fr:=TPeakFactorFrame.Create(self);
  addframe(fr);

  fr:=TIntegralAlgFrame.Create(self);
  addframe(fr);

  fr:=TAriphmAlgFrame.Create(self);
  addframe(fr);
end;

destructor TAlgFrm.destroy;
begin
  m_frameList.Destroy;
  inherited;
end;

procedure TAlgFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if g_algMng<>nil then
    g_algMng.Events.CallAllEvents(E_OnChangeAlgCfg);
end;

procedure TAlgFrm.FormShow(Sender: TObject);
var
  I: Integer;
  fr:TBaseAlgFrame;
begin
  //FullDebugModeScanMemoryPoolBeforeEveryOperation:=true;
  showAlgsInLV;
  TagsListFrame1.ShowChannels;
  for I := 0 to m_frameList.Count - 1 do
  begin
    fr:=TBaseAlgFrame(m_frameList.Objects[i]);
    fr.doShow;
  end;
  //FullDebugModeScanMemoryPoolBeforeEveryOperation:=false;
end;

function TAlgFrm.selectalg: cbasealgcontainer;
begin
  result:=nil;
  if AlgLV.Selected<>nil then
  begin
    result:=cbasealgcontainer(AlgLV.Selected.Data);
  end;
end;

procedure TAlgFrm.showAlgsInLV;
var
  I: Integer;
  a:cbaseobj;
  li:tlistitem;
begin
  AlgLV.clear;
  for I := 0 to g_AlgMng.Count - 1 do
  begin
    a:=cbasealgcontainer(g_AlgMng.getObj(i));
    if a is cbasealgcontainer then
    begin
      li:=AlgLV.items.Add;
      li.data:=a;
      AlgLV.SetSubItemByColumnName('Имя',a.name,li);
      AlgLV.SetSubItemByColumnName('Тип',cbasealgcontainer(a).getdsc,li);
    end;
  end;
  LVChange(AlgLV);
end;

procedure TAlgFrm.UpdateAlgBtnClick(Sender: TObject);
var
  a:cbasealgcontainer;
  fr:TBaseAlgFrame;
  firsAlg:TClass;
  I: Integer;
  li:tlistitem;
  str:string;
begin
  fr:=TBaseAlgFrame(m_frameList.Objects[AlgsPageControl.ActivePageIndex]);
  str:=fr.properties;
  for I := 0 to AlgLV.SelCount - 1 do
  begin
    if i=0 then
    begin
      li:=AlgLV.Selected;
    end
    else
    begin
      li:=AlgLV.GetNextItem(li,sdAll, [isSelected]);
    end;
    a:=cbasealgcontainer(li.Data);
    if i=0 then
      firsAlg:=a.ClassType;
    if a<>nil then
    begin
      if a.ClassType=firsAlg then
      begin
        a.Properties:=str;
        if lowercase(a.name)<>lowercase(a.resname) then
        begin
          if a.resname<>'' then
          begin
            a.name:=a.resname;
          end;
        end;
      end;
    end;
  end;
  showAlgsInLV;
end;

end.
