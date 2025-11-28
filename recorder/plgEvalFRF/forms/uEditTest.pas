unit uEditTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uSpin, ExtCtrls, Grids, uStringGridExt, ubladeDB, uComponentServises,
  Spin;

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
    ObjPropSG: TStringGridExt;
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
  private
    procedure init;
    procedure showbase;
    procedure showTurb(t:cTurbFolder);
    procedure updateTypes;
    // перенести данные из Sg в тип лопатки
    procedure ToneToType;
    // показать свойства типа лопатки выбраной в поле "чертеж"
    procedure ShowTone;
    function ValidRowCount:integer;
  public
    procedure Edit(f:tform);
    constructor create(aowner:tcomponent);
  end;

var
  EditTestFrm: TEditTestFrm;

implementation

{$R *.dfm}

{ TEditTestFrm }

procedure TEditTestFrm.BandCountIEChange(Sender: TObject);
begin
  if BandCountIE.Value<>0 then
  begin
    ProfileSG.RowCount:=BandCountIE.Value+1;
  end;
end;

procedure TEditTestFrm.BladeSeChange(Sender: TObject);
var
  f, s, bl:cxmlfolder;
begin
  f:=g_mbase.SelectTurb;
  if f<>nil then
  begin
    s:=f.selected;
    if s<>nil then
    begin
      if BladeSe.Value>-1 then
      begin
        bl:=cxmlFolder(s.getChild(BladeSe.Value));
        if bl<>nil then
        begin
          s.selected:=bl;
        end;
        SideCb.Checked:=cBladeFolder(bl).m_sideCB;
      end;
    end;
  end;
end;

procedure TEditTestFrm.BlCountIEChange(Sender: TObject);
begin
  bladeSe.MaxValue:=BlCountIE.Value-1;
end;

constructor TEditTestFrm.create(aowner: tcomponent);
begin
  inherited;
  init;
end;

procedure TEditTestFrm.Edit(f: tform);
begin
  showbase;
  if showmodal=mrok then
  begin

  end;
end;

procedure TEditTestFrm.init;
begin
  // Поиск БД
  ProfileSG.ColCount:=4;
  ProfileSG.rowCount:=4;
  ProfileSG.Cells[0,0]:='Тон №';
  ProfileSG.Cells[1,0]:='F1';
  ProfileSG.Cells[2,0]:='F2';
  ProfileSG.Cells[3,0]:='Допуск, %';
  DateLabel.Caption:= 'Дата: '+DateToStr(now);
end;

procedure TEditTestFrm.OkBtnClick(Sender: TObject);
var
  f, s, bl:cxmlfolder;
  I: Integer;
begin
  updateTypes;
  if TurbNameCb.text<>'' then
  begin
    f:=cxmlfolder(g_mbase.getobj(TurbNameCb.text));
    if f=nil then
    begin
      f:=cTurbFolder.create;
      f.setObjType(TurbCB.text);
      f.name:=TurbNameCb.text;
      g_mbase.root.selected:=f;
      g_mbase.root.AddChild(f);
      TurbNameCb.AddItem(f.name, f);
      setComboBoxItem(f.name,TurbNameCb);

      s:=cStageFolder.create;
      s.name:=f.name+'_Stage_'+StageCB.text;
      cStageFolder(s).BlCount:=BlCountIE.Value;
      f.AddChild(s);
      f.selected:=s;

      bl:=cBladeFolder.create;
      bl.setObjType(BladeCB.text);
      bl.name:='Bl_'+inttostr(BladeSe.Value);
      s.AddChild(bl);
      f.selected:=bl;
    end
    else
    begin
      f.setObjType(TurbCB.text);
      s:=g_mbase.SelectStage;
      cStageFolder(s).BlCount:=BlCountIE.Value;
      if cStageFolder(s).selected=nil then
      begin
        for I := 0 to cStageFolder(s).ChildCount - 1 do
        begin
          bl:=cBladeFolder(cStageFolder(s).getChild(i));
          bl.setObjType(BladeCB.Text);
        end;
      end;
      bl:=g_mbase.SelectBlade;
      bl.setObjType(BladeCB.Text);
    end;
  end;
  g_mbase.UpdateXMLDescriptors;
end;

procedure TEditTestFrm.ProfileSGKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_RETURN then
  begin
    SGChange(ProfileSG);
  end;
end;

procedure TEditTestFrm.showbase;
var
  I: Integer;
  t:cTurbFolder;
begin
  // заполняем типы объектов
  turbCB.Clear;
  for I := 0 to g_mbase.root.m_turbTypes.Count-1 do
  begin
    turbcb.Items.AddObject(g_mbase.root.m_turbTypes.Strings[i], g_mbase.root.m_turbTypes.Objects[i]);
  end;
  turbCB.ItemIndex:=0;

  BladeCB.clear;
  for I := 0 to g_mbase.root.m_BladeTypes.Count-1 do
  begin

    BladeCB.Items.AddObject(g_mbase.root.m_BladeTypes.Strings[i], g_mbase.root.m_BladeTypes.Objects[i]);
  end;

  TurbNameCB.Clear;
  t:=nil;
  for I := 0 to g_mbase.root.ChildCount - 1 do
  begin
    t:=cTurbFolder(g_mbase.root.getChild(i));
    TurbNameCB.AddItem(t.name, t);
    if i=0 then
    begin
      TurbNameCB.ItemIndex:=0;
    end;
  end;
  BladeCB.ItemIndex:=0;
  if t<>nil then
  begin
    showTurb(t);
    // ступень
    t.selected:=cxmlfolder(t.getChild(0));
    BlCountIE.Value:=cStageFolder(t.selected).BlCount;
    // лопатка
    t.selected.selected:=cxmlfolder(t.selected.getChild(0));
    ShowTone;
  end;
  SGChange(ProfileSG);
end;

procedure TEditTestFrm.ShowTone;
var
  o:cObjType;
  s:string;
  r,c:integer;
begin
  o:=g_mbase.root.getType(BladeCB.Text);
  if o<>nil then
  begin
    s:=o.getval('ToneCount');
    if s<>'' then
    begin
      c:=strtoint(s);
      BandCountIE.Value:=c;
      ProfileSG.RowCount:=c+2;
    end;
    for r := 0 to c-1 do
    begin
      ProfileSG.Cells[1, r+1]:=o.getval('F1_'+inttostr(r+1));
      ProfileSG.Cells[2, r+1]:=o.getval('F2_'+inttostr(r+1));
      ProfileSG.Cells[3, r+1]:=o.getval('Threshold_'+inttostr(r+1));
    end;
  end;
end;

procedure TEditTestFrm.showTurb(t: cTurbFolder);
var
  I, c: Integer;
  s:cStageFolder;
begin
  c:=t.StageCount;
  if c=0 then
  begin
    if t.childcount>0 then
    begin
      c:=t.childcount;
      t.StageCount:=c;
    end;
  end;
  StageCountSE.Value:=c;
  StageCB.Items.Clear;

  for I := 0 to StageCountSE.Value - 1 do
  begin
    s:=cStageFolder(t.getChild(i));
    StageCB.Items.AddObject(inttostr(i+1), s);
  end;
  BlCountIE.Value:=t.GetBladeCount(strtoint(StageCB.Text));
end;

procedure TEditTestFrm.SideCBClick(Sender: TObject);
var
  bl:cBladeFolder;
  t:cTurbFolder;
  s:cStageFolder;
begin
  if SideCB.Checked then
  begin
    SideCB.Caption:= 'Правая лопатка';
  end
  else
  begin
    SideCB.Caption:='Левая лопатка';
  end;
  t:=g_mbase.SelectTurb;
  if StageCB.ItemIndex=-1 then
    s:=t.GetStage(0)
  else
    s:=t.GetStage(StageCB.ItemIndex);
  bl:=s.GetBlade(BladeSe.Value);
  bl.m_sideCB:=sidecb.Checked;
end;

procedure TEditTestFrm.Splitter2Moved(Sender: TObject);
begin
  splitter1.Left:=Splitter2.Left;
end;

procedure TEditTestFrm.StageCBChange(Sender: TObject);
var
  t:cTurbFolder;
  s:cStageFolder;
begin
  t:=g_mbase.SelectTurb;
  s:=t.GetStage(StageCB.ItemIndex);
  if s<>nil then
  begin
    t.selected:=s;
    BlCountIE.Value:=t.GetBladeCount(StageCB.ItemIndex);
  end;
end;

function isValidRow(sg:tstringgrid;r:integer):boolean;
begin
  result:=false;
  if sg.Cells[1,r]<>'' then
    if sg.Cells[2,r]<>'' then
      result:=true;
end;

procedure TEditTestFrm.updateTypes;
var
  o:cObjType;
begin
  ToneToType;
  // тип турбины
  o:=g_mbase.root.getType(TurbCB.text);
  if o<>nil then
  begin
  end
  else
  begin
    o:=cObjType.create;
    o.name:=TurbCB.text;
    g_mbase.root.m_turbTypes.AddObject(o.name,o);
    TurbCB.AddItem(o.name, o);
    CheckCBItemInd(TurbCB);
  end;
  o.setPropVal('StageCount', inttostr(StageCountSE.Value));
  o.setPropVal('StageBCount_'+stageCB.Text, inttostr(BlCountIE.Value));
end;

procedure TEditTestFrm.ToneToType;
var
  o:cObjType;
  r:integer;
  str:string;
begin
  o:=g_mbase.root.getType(BladeCB.Text);
  if o<>nil then
  begin
    o.addProp('ToneCount', inttostr(ValidRowCount));
    for r := 1 to ProfileSG.rowCount - 1 do
    begin
      if isValidRow(ProfileSG, r) then
      begin
        if ProfileSG.Cells[3,r]<>'' then
        begin
          ProfileSG.Cells[3,r]:=ThresholdSE.Text;
        end;
        o.addProp('F1_'+inttostr(r), ProfileSG.Cells[1, r]);
        o.addProp('F2_'+inttostr(r), ProfileSG.Cells[2, r]);
        o.addProp('Threshold_'+inttostr(r), ProfileSG.Cells[3, r]);
      end;
    end;
  end;
end;

procedure TEditTestFrm.TurbCBChange(Sender: TObject);
begin
  TurbNameCbChange(Sender);
end;

procedure TEditTestFrm.TurbNameCbChange(Sender: TObject);
begin
  if CheckCBItemInd(tcombobox(Sender)) then
  begin
    g_mbase.root.selected:=
                cTurbFolder(g_mbase.root.
                getChild(TurbNameCb.ItemIndex));
  end;
end;

function TEditTestFrm.ValidRowCount: integer;
var
  r:integer;
  str:string;
begin
  result:=0;
  for r := 1 to ProfileSG.rowCount - 1 do
  begin
    if isValidRow(ProfileSG, r) then
    begin
      inc(result);
    end;
  end;
end;

end.
