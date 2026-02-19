unit uEditTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uSpin, ExtCtrls, Grids, uStringGridExt, ubladeDB,
  uComponentServises,
  Spin, ComCtrls, uBtnListView;

type
  TEditTestFrm = class(TForm)
    TestGB: TGroupBox;
    TurbLabel: TLabel;
    StageLabel: TLabel;
    SketchLabel: TLabel;
    TurbCB: TComboBox;
    StageCB: TComboBox;
    GroupBox1: TGroupBox;
    ThresholdLabel: TLabel;
    ThresholdSE: TFloatSpinEdit;
    BladeCB: TComboBox;
    Label1: TLabel;
    PersonE: TEdit;
    DateLabel: TLabel;
    GroupBox2: TGroupBox;
    OkBtn: TButton;
    Splitter2: TSplitter;
    blNumSE: TLabel;
    BladeSe: TSpinEdit;
    ProfileSG: TStringGridExt;
    Splitter1: TSplitter;
    TurbNameCb: TComboBox;
    BlCountIE: TSpinEdit;
    BlCountLabel: TLabel;
    TNameLabel: TLabel;
    StageCountLabel: TLabel;
    StageCountSE: TSpinEdit;
    SideCB: TCheckBox;
    Label2: TLabel;
    BandCountIE: TSpinEdit;
    BladesGB: TGroupBox;
    BladesLV: TBtnListView;
    BladesControlPan: TPanel;
    SelectAllCb: TCheckBox;
    procedure OkBtnClick(Sender: TObject);
    procedure ProfileSGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Splitter2Moved(Sender: TObject);
    procedure BladeSeChange(Sender: TObject);
    procedure TurbNameCbChange(Sender: TObject);
    procedure TurbCBChange(Sender: TObject);
    procedure StageCBChange(Sender: TObject);
    procedure SideCBClick(Sender: TObject);
    procedure BandCountIEChange(Sender: TObject);
    procedure BlCountIEChange(Sender: TObject);
    procedure SelectAllCbClick(Sender: TObject);
    procedure BladesLVChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure TurbNameCbKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BladeCBChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure init;
    procedure showbase;
    procedure showbladetypes;
    procedure showTurbs;
    procedure showTurb(t: cTurbFolder);
    procedure updateTypes;
    // перенести данные из Sg в тип лопатки
    procedure ToneToType;
    // показать свойства типа лопатки выбраной в поле "чертеж"
    procedure ShowTone;
    function ValidRowCount: integer;
    procedure ShowBlades;
    // выбраная турбина в форме
    function selectTurb: cTurbFolder;
  public
    m_frm:tform;
  public
    procedure Edit(f: TForm);
    constructor create(aowner: tcomponent);
  end;

var

  EditTestFrm: TEditTestFrm;

implementation
uses
  uevalfrffrm;

{$R *.dfm}
{ TEditTestFrm }

procedure TEditTestFrm.BandCountIEChange(Sender: TObject);
begin
  if (BandCountIE.Value <> 0) and (BandCountIE.Value < 10) then
  begin
    ProfileSG.RowCount := BandCountIE.Value + 1;
  end;
end;

procedure TEditTestFrm.BladeCBChange(Sender: TObject);
begin
  ShowTone;
end;

procedure TEditTestFrm.BladeSeChange(Sender: TObject);
var
  f, s, bl: cxmlfolder;
begin
  f := g_mbase.SelectTurb;
  if f <> nil then
  begin
    s := f.selected;
    if s <> nil then
    begin
      if BladeSe.Value > -1 then
      begin
        bl := cxmlfolder(s.getChild(BladeSe.Value));
        if bl <> nil then
        begin
          s.selected := bl;
        end;
        SideCB.Checked := cBladeFolder(bl).m_sideCB;
      end;
    end;
  end;
end;

procedure TEditTestFrm.BladesLVChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if BladesLV.SelCount <> BladesLV.Items.Count then
    SelectAllCb.Checked := false;
end;

procedure TEditTestFrm.BlCountIEChange(Sender: TObject);
begin
  BladeSe.MaxValue := BlCountIE.Value - 1;
end;

constructor TEditTestFrm.create(aowner: tcomponent);
begin
  inherited;
  init;
end;

procedure TEditTestFrm.Edit(f: TForm);
begin
  m_frm:=f;
  PersonE.text:=TFRFFrm(m_frm).m_Person;
  showbase;
  if showmodal = mrok then
  begin
  end;
end;

procedure TEditTestFrm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  s:cStageFolder;
  t:cturbfolder;
  ind:integer;
begin
  t:=g_mbase.SelectTurb;
  if t<>nil then
  begin
    if t.StageCount>0 then
    begin
      if StageCB.ItemIndex=-1 then
      begin
        ind:=0;
        StageCB.ItemIndex:=0;
      end
      else
        ind:=StageCB.ItemIndex;
      if t.StageCount>0 then
      begin
        s:=t.GetStage(ind);
        g_mbase.SelectStage:=s;
      end;
    end;
  end;
end;

procedure TEditTestFrm.init;
begin
  // Поиск БД
  ProfileSG.ColCount := 4;
  ProfileSG.RowCount := 4;
  ProfileSG.Cells[0, 0] := 'Тон №';
  ProfileSG.Cells[1, 0] := 'F1';
  ProfileSG.Cells[2, 0] := 'F2';
  ProfileSG.Cells[3, 0] := 'Допуск, %';
  DateLabel.Caption := 'Дата: ' + DateToStr(now);
end;

procedure TEditTestFrm.OkBtnClick(Sender: TObject);
var
  f, s, bl: cxmlfolder;
  I,j, tblCount: integer;
  str, pref: string;
begin
  TFRFFrm(m_frm).m_Person:=PersonE.text;
  if TurbNameCb.text <> '' then
  begin
    f := cxmlfolder(g_mbase.getobj(TurbNameCb.text));
    if f = nil then
    begin
      f := cTurbFolder.create;
      f.setObjType(TurbCB.text);
      f.name := TurbNameCb.text;
      g_mbase.root.selected := f;
      g_mbase.root.AddChild(f);
      AddComboBoxItem(f.name, TurbNameCb);
      setComboBoxItem(f.name, TurbNameCb);
      if TurbNameCb.ItemIndex>-1 then
      begin
        TurbNameCb.Items.Objects[i]:=f;
      end;
      AddComboBoxItem(TurbCB.text, TurbCB);
      setComboBoxItem(TurbCB.text, TurbCB);
      f.setObjType(TurbCB.text); // повтор!!!!
      TurbCB.Color:=clWindow;
      StageCB.Clear;
      for I := 0 to StageCountSE.Value - 1 do
      begin
        s := cStageFolder.create;
        s.name := f.name + '_Stage_' + inttostr(i+1);
        if i>0 then
        begin
          tblCount:=cTurbFolder(f).GetBladeCount(i);
        end
        else
          tblCount:=BlCountIE.Value;
        cStageFolder(s).BlCount := tblCount;
        for j := 0 to s.childCount - 1 do
        begin
          bl:=cbladefolder(s.getChild(j));
          bl.m_ObjType:=bladecb.text;
          bl.fdefCaption:=false;
        end;
        f.AddChild(s);
        cStageFolder(s).SetBladeType(BladeCB.text);
        for j := 0 to s.childCount - 1 do
        begin
          bl:=cbladefolder(s.getChild(j));
          bl.fdefCaption:=true;
        end;
        StageCB.AddItem(inttostr(i+1), s);
        if i=0 then
          f.selected := s;
      end;
      if StageCountSE.Value>0 then
        StageCB.ItemIndex:=0;
    end
    else
    begin
      f.setObjType(TurbCB.text);
      TurbCB.Color:=clWindow;
      //cTurbFolder(f).setbladetype(BladeCB.text);
      pref:=StageCB.text;
      StageCB.Clear;
      for I := 0 to StageCountSE.Value - 1 do
      begin
        s := cTurbFolder(f).GetStage(I);
        if s = nil then
        begin
          s := cStageFolder.create;
          s.name := f.name + '_Stage_' + inttostr(i);
          cStageFolder(s).BlCount := BlCountIE.Value;
          cTurbFolder(f).AddChild(s);
        end;
        StageCB.Items.AddObject(inttostr(I + 1), s);
      end;
      setComboBoxItem(pref, StageCB);

      s := g_mbase.SelectStage;
      cStageFolder(s).BlCount := BlCountIE.Value;
      if cStageFolder(s).selected = nil then
      begin
        for I := 0 to cStageFolder(s).ChildCount - 1 do
        begin
          bl := cBladeFolder(cStageFolder(s).getChild(I));
          bl.setObjType(BladeCB.text);
        end;
      end;
      cStageFolder(s).SetBladeType(BladeCB.text);
    end;
  end;
  updateTypes;
  g_mbase.UpdateXMLDescriptors;
  ShowBlades;
end;

procedure TEditTestFrm.ProfileSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    SGChange(ProfileSG);
  end;
end;

procedure TEditTestFrm.SelectAllCbClick(Sender: TObject);
var
  I: integer;
  li: TListItem;
begin
  for I := 0 to BladesLV.Items.Count - 1 do
  begin
    li := BladesLV.Items[I];
    li.selected := SelectAllCb.Checked;
  end;
end;

procedure TEditTestFrm.showbladetypes;
var
  I: integer;
  o: cObjType;
  s:cStageFolder;
begin
  BladeCB.Clear;
  for I := 0 to cBladeBaseFolder(g_mbase.m_BaseFolder).m_BladeTypes.Count - 1 do
  begin
    o := g_mbase.getBladeType(I);
    BladeCB.AddItem(o.name, o);
  end;
end;

procedure TEditTestFrm.showTurbs;
var
  I, ind: integer;
  t: cTurbFolder;
  str: string;
begin
  // заполняем типы объектов
  TurbCB.Clear;
  for I := 0 to g_mbase.root.m_turbTypes.Count - 1 do
  begin
    TurbCB.Items.AddObject(g_mbase.root.m_turbTypes.Strings[I],
      g_mbase.root.m_turbTypes.Objects[I]);
  end;
  TurbNameCb.Clear;
  for I := 0 to g_mbase.root.ChildCount - 1 do
  begin
    t := cTurbFolder(g_mbase.m_BaseFolder.getChild(I));
    ind:=AddComboBoxItem(t.name, TurbNameCb);
    turbnamecb.items.Objects[ind]:=t;
  end;
  // установка выбраной турбины
  if g_mbase.SelectTurb <> nil then
  begin
    setComboBoxItem(g_mbase.SelectTurb.name, TurbNameCb);
    str := g_mbase.SelectTurb.ObjType;
    setComboBoxItem(str, TurbCB);
  end
  else
  begin
    TurbCB.ItemIndex := 0;
  end;
end;

function TEditTestFrm.selectTurb: cTurbFolder;
var
  t:tobject;
begin
  result:=nil;
  t:=cTurbFolder(GetComboBoxItem(TurbNameCb));
  if t<>nil then
    result:=cTurbFolder(t);
end;

procedure TEditTestFrm.showbase;
var
  I: integer;
  t: cTurbFolder;
  s:cStageFolder;
begin
  // отобразить список турбин
  showTurbs;
  BladeCB.Clear;
  for I := 0 to g_mbase.root.m_BladeTypes.Count - 1 do
  begin
    BladeCB.Items.AddObject(g_mbase.root.m_BladeTypes.Strings[I],
      g_mbase.root.m_BladeTypes.Objects[I]);
  end;
  // типы турбин
  showbladetypes;
  t := g_mbase.SelectTurb;
  s:=g_mbase.selectStage;
  if s<>nil then
  begin
    setComboBoxItem(s.GetBladeType,BladeCB);
  end
  else
    BladeCB.ItemIndex := 0;
  if t <> nil then
  begin
    showTurb(t);
    // ступень
    t.selected := cxmlfolder(t.getChild(0));
    BlCountIE.Value := cStageFolder(t.selected).BlCount;
    // лопатка
    t.selected.selected := cxmlfolder(t.selected.getChild(0));
    ShowTone;
  end;
  SGChange(ProfileSG);
end;

procedure TEditTestFrm.ShowBlades;
var
  I: integer;
  t: cTurbFolder;
  s: cStageFolder;
  b: cBladeFolder;
  li: TListItem;
  str: string;
begin
  t := g_mbase.SelectTurb;
  if t = nil then
    exit;
  if StageCB.ItemIndex = -1 then
    s := t.GetStage(0)
  else
    s := t.GetStage(StageCB.ItemIndex);
  BladesLV.Clear;
  BladesLV.clearcolors;
  for I := 0 to s.ChildCount - 1 do
  begin
    li := BladesLV.Items.Add;
    BladesLV.SetSubItemByColumnName('№', inttostr(I), li);
    b := s.GetBlade(I);
    if b.m_sideCB then
      str := 'Правая'
    else
      str := 'Левая';
    if b.m_sideCB then
    begin
      BladesLV.addColorItem(li.Index, clgray);
    end;
    BladesLV.SetSubItemByColumnName('Тип', str, li);
    BladesLV.SetSubItemByColumnName('sn', b.m_sn, li);
  end;
end;

procedure TEditTestFrm.ShowTone;
var
  o: cObjType;
  s: string;
  r, c: integer;
begin
  o := g_mbase.root.getType(BladeCB.text);
  ClearGrid(ProfileSG, false);
  if o <> nil then
  begin
    s := o.getval('ToneCount');
    if s <> '' then
    begin
      c := strtoint(s);
      BandCountIE.Value := c;
      ProfileSG.RowCount := c + 2;
      for r := 0 to c - 1 do
      begin
        ProfileSG.Cells[1, r + 1] := o.getval('F1_' + inttostr(r + 1));
        ProfileSG.Cells[2, r + 1] := o.getval('F2_' + inttostr(r + 1));
        ProfileSG.Cells[3, r + 1] := o.getval('Threshold_' + inttostr(r + 1));
      end;
    end;
    SGChange(ProfileSG);
  end;
end;

procedure TEditTestFrm.showTurb(t: cTurbFolder);
var
  I, c: integer;
  s: cStageFolder;
begin
  c := t.StageCount;
  if c = 0 then
  begin
    if t.ChildCount > 0 then
    begin
      c := t.ChildCount;
      t.StageCount := c;
    end;
  end;
  StageCountSE.Value := c;
  StageCB.Items.Clear;

  for I := 0 to StageCountSE.Value - 1 do
  begin
    s := cStageFolder(t.getChild(I));
    StageCB.Items.AddObject(inttostr(I + 1), s);
  end;
  BlCountIE.Value := t.GetBladeCount(strtoint(StageCB.text));
  ShowBlades;
end;

procedure TEditTestFrm.SideCBClick(Sender: TObject);
var
  bl: cBladeFolder;
  t: cTurbFolder;
  s: cStageFolder;
  I: integer;
  li: TListItem;
begin
  if SideCB.Checked then
  begin
    SideCB.Caption := 'Правая лопатка';
  end
  else
  begin
    SideCB.Caption := 'Левая лопатка';
  end;
  t := g_mbase.SelectTurb;
  if StageCB.ItemIndex = -1 then
    s := t.GetStage(0)
  else
    s := t.GetStage(StageCB.ItemIndex);
  if BladesLV.SelCount > 0 then
  begin
    for I := 0 to BladesLV.Items.Count - 1 do
    begin
      li := BladesLV.Items[I];
      if li.selected then
      begin
        bl := s.GetBlade(li.Index);
        bl.m_sideCB := SideCB.Checked;
      end;
    end;
  end
  else
  begin
    bl := s.GetBlade(BladeSe.Value);
    bl.m_sideCB := SideCB.Checked;
  end;
  ShowBlades;
end;

procedure TEditTestFrm.Splitter2Moved(Sender: TObject);
begin
  Splitter1.Left := Splitter2.Left;
end;

procedure TEditTestFrm.StageCBChange(Sender: TObject);
var
  t: cTurbFolder;
  s: cStageFolder;
  ind:integer;
begin
  t := g_mbase.SelectTurb;
  ind:=StageCB.ItemIndex;
  if ind=-1 then
    ind:=0;
  s:=nil;
  if t.StageCount>0 then
  begin
    s := t.GetStage(ind);
    if s=nil then
    begin
      s:=cStageFolder.create;
      s.name := t.name + '_Stage_' + inttostr(ind+1);
      t.AddChild(s);
    end;
  end;
  if s <> nil then
  begin
    t.selected := s;
    BlCountIE.Value := t.GetBladeCount(StageCB.ItemIndex);
    setComboBoxItem(s.getBladeType, BladeCB);
    ShowTone;
  end;
  ShowBlades;
end;

function isValidRow(sg: tstringgrid; r: integer): boolean;
begin
  result := false;
  if sg.Cells[1, r] <> '' then
    if sg.Cells[2, r] <> '' then
      result := true;
end;

procedure TEditTestFrm.updateTypes;
var
  o: cObjType;
  bl: cBladeFolder;
  s: cStageFolder;
  t: cTurbFolder;
  I: Integer;
begin
  // тип турбины
  o := g_mbase.root.getType(TurbCB.text);
  if o <> nil then
  begin

  end
  else
  begin
    o := cObjType.create;
    o.name := TurbCB.text;
    g_mbase.root.m_turbTypes.AddObject(o.name, o);
  end;
  // типы лопаток на ступенях
  t := g_mbase.SelectTurb;
  t.ObjType := TurbCB.text;
  o:=g_mbase.getType(TurbCB.text);
  o.setPropVal('StageBType_'+StageCB.text, BladeCB.text);
  o.setPropVal('StageCount', inttostr(StageCountSE.Value));
  o.setPropVal('StageBCount_' + StageCB.text, inttostr(BlCountIE.Value));

  if StageCB.ItemIndex = 0 then
  begin
    StageCB.ItemIndex := 0;
    StageCB.text := '1';
  end;
  if StageCB.ItemIndex = -1 then
  begin
    StageCB.ItemIndex := 0;
    s := t.GetStage(0);
  end
  else
  begin
    s := t.GetStage(StageCB.ItemIndex);
  end;
  if s=nil then
  begin
    s := cStageFolder.create;
    s.name := t.name + '_Stage_' + StageCB.text;
    t.AddChild(s);
    for I := 0 to t.ChildCount - 1 do
    begin
      if t.GetStage(i)=s then
      begin
        AddComboBoxItem(inttostr(i+1),StageCB);
        break;
      end;
    end;
  end;
  cStageFolder(s).BlCount := BlCountIE.Value;
  if s.BlCount > 0 then
  begin
    //bl := s.GetBlade(0);
    //o.setPropVal('StageBtype_' + inttostr(StageCB.ItemIndex), BladeCB.text);
    AddComboBoxItem(BladeCB.text, BladeCB);
    cBladeBaseFolder(g_mbase.m_BaseFolder).AddBladeType(BladeCB.text);
  end;
  ToneToType;
end;

procedure TEditTestFrm.ToneToType;
var
  o: cObjType;
  r: integer;
  str: string;
begin
  o := g_mbase.root.getType(BladeCB.text);
  if o <> nil then
  begin
    o.addProp('ToneCount', inttostr(ValidRowCount));
    for r := 1 to ProfileSG.RowCount - 1 do
    begin
      if isValidRow(ProfileSG, r) then
      begin
        if ProfileSG.Cells[3, r] <> '' then
        begin
          ProfileSG.Cells[3, r] := ThresholdSE.text;
        end;
        o.addProp('F1_' + inttostr(r), ProfileSG.Cells[1, r]);
        o.addProp('F2_' + inttostr(r), ProfileSG.Cells[2, r]);
        if ProfileSG.Cells[3, r] = '' then
        begin
          ProfileSG.Cells[3, r] := ThresholdSE.text;
          o.addProp('Threshold_' + inttostr(r), ThresholdSE.text);
        end
        else
          o.addProp('Threshold_' + inttostr(r), ProfileSG.Cells[3, r]);
      end;
    end;
  end;
end;

procedure TEditTestFrm.TurbCBChange(Sender: TObject);
var
  str: string;
  o: cObjType;
  I: integer;
  t:cTurbFolder;
  s:cstagefolder;
  b:boolean;
begin
  b:=CheckCBItemInd(TurbCB);
  if not b then
    exit;
  // установка типа турбины
  o := g_mbase.getType(TurbCB.text);
  if o <> nil then
  begin
    StageCB.text := '1';
    str := o.getval('StageCount');
    StageCountSE.Value := StrToIntDef(str, 0);
    // выбраная турбина в форме
    t:=selectTurb;
    if t<>nil then
    begin
      if t.m_ObjType<>TurbCB.text then
      begin
        TurbCB.Color:=clYellow;
      end
      else
        TurbCB.Color:=clWindow;
      StageCB.Clear;
      for I := 0 to StageCountSE.Value - 1 do
      begin
        s := t.GetStage(I);
        StageCB.Items.AddObject(inttostr(I + 1), s);
        if i=0 then
        begin
          StageCB.ItemIndex:=0;
        end;
      end;
    end;
    // число лопаток
    str := o.getval('StageBCount_1');
    BlCountIE.Value := StrToIntDef(str, 0);
    str := o.getval('StageBtype_1');
    if str <> '' then
    begin
      setComboBoxItem(str, BladeCB);
    end;
    ShowTone;
  end;
end;

procedure TEditTestFrm.TurbNameCbChange(Sender: TObject);
var
  str: string;
  I: integer;
  t: cTurbFolder;
  s: cStageFolder;
begin
  if CheckCBItemInd(TComboBox(Sender)) then
  begin
    t := cTurbFolder(g_mbase.root.getChild(TurbNameCb.ItemIndex));
    if g_mbase.root.selected = t then
      exit;
    g_mbase.root.selected := t;
    // установка типа турбины
    str := t.getObjTypeName;
    setComboBoxItem(str, TurbCB);
    StageCB.text := '1';
    StageCountSE.Value := t.StageCount;

    //StageCB

    if StageCountSE.Value > 0 then
    begin
      StageCB.clear;
      for I := 0 to StageCountSE.Value - 1 do
      begin
        StageCB.Items.AddObject(inttostr(i+1), t.GetStage(i));
      end;
      StageCB.ItemIndex:=0;
      // число лопаток
      BlCountIE.Value := cTurbFolder(g_mbase.root.selected).GetBladeCount(0);
      str :=t.bladetype(StageCB.ItemIndex);
      //str := cTurbFolder(g_mbase.root.selected).bladetype(0);
      if str<>'' then
      begin
        //showbladetypes;
        setComboBoxItem(str, BladeCB);
      end;
      ShowTone;
    end
    else
    begin
      bladeslv.clear;
    end;
  end;
end;

procedure TEditTestFrm.TurbNameCbKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  TurbNameCbChange(TurbNameCb);
end;


function TEditTestFrm.ValidRowCount: integer;
var
  r: integer;
  str: string;
begin
  result := 0;
  for r := 1 to ProfileSG.RowCount - 1 do
  begin
    if isValidRow(ProfileSG, r) then
    begin
      inc(result);
    end;
  end;
end;

end.
