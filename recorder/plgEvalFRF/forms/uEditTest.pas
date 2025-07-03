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
    procedure OkBtnClick(Sender: TObject);
    procedure ProfileSGKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Splitter2Moved(Sender: TObject);
  private
    procedure init;
    procedure showbase;
    // перенести данные из Sg в тип лопатки
    procedure ToneToType;
    // показать свойства лопатки
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
begin
  ToneToType;
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

      s:=cStageFolder.create;
      s.name:=f.name+'_Stage_'+StageCB.text;
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
  BladeCB.ItemIndex:=0;
  g_mbase.root.selected:=cxmlfolder(g_mbase.root.getChild(0));
  if g_mbase.root.selected<>nil then
  begin
    g_mbase.root.selected.selected:=cxmlfolder(g_mbase.root.selected.getChild(0));
    g_mbase.root.selected.selected.selected:=cxmlfolder(g_mbase.root.selected.selected.getChild(0));
  end;
  ShowTone;
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

procedure TEditTestFrm.Splitter2Moved(Sender: TObject);
begin
  splitter1.Left:=Splitter2.Left;
end;

function isValidRow(sg:tstringgrid;r:integer):boolean;
begin
  result:=false;
  if sg.Cells[1,r]<>'' then
    if sg.Cells[2,r]<>'' then
      result:=true;
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
