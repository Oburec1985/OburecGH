unit uRecorderFrequencyResponseSettingsDialog;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Dialogs,
  Graphics, Math, StrUtils, uRecorderTags, uRecorderFrequencyResponse,
  uRecorderFrequencyResponseModel;

function ShowRecorderFrequencyResponseSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderFrequencyResponseComponent;
  ARegistry: TRecorderTagRegistry): Boolean;

implementation

type
  TFrequencyResponseSettingsDialog = class(TForm)
  private
    fComponent, fDraft: TRecorderFrequencyResponseComponent;
    fRegistry: TRecorderTagRegistry;
    fTree: TTreeView;
    fAvailable: TListBox;
    fSearch, fName, fMinX, fMaxX, fMinY, fMaxY: TEdit;
    fBufferSize, fStep, fWidth: TEdit;
    fKind, fValueTag, fFrequencyTag, fMerge: TComboBox;
    fUniform, fLogX, fLogY, fLegend, fDrawLine, fDrawPoints: TCheckBox;
    fColor: TColorButton;
    fProps: TPanel;
    fLoading: Boolean;
    fEditing: TObject;
    procedure AddAxisClick(Sender: TObject);
    procedure AddLinesClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure SearchChange(Sender: TObject);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure OkClick(Sender: TObject);
    procedure BuildUi;
    procedure FillAvailable;
    procedure FillTree(ASelect: TObject = nil);
    procedure LoadSelection;
    procedure SaveSelection;
    procedure AddLabel(const AText: string; ATop: Integer);
    procedure SetRow(AControl: TControl; ATop: Integer);
    function SelectedAxis: TRecorderFrequencyResponseAxis;
    function SelectedLine: TRecorderFrequencyResponseLine;
    function FindAxis(const AName: string): TRecorderFrequencyResponseAxis;
    function EnsureAxisForKind(AKind: TRecorderFrequencyResponseKind): TRecorderFrequencyResponseAxis;
    function FloatValue(AEdit: TEdit; ADefault: Double): Double;
    procedure FillTagCombo(ACombo: TComboBox; AIncludeAuto: Boolean;
      AId: TRecorderTagId; const AName: string);
    function ComboTag(ACombo: TComboBox): TRecorderTag;
  public
    constructor CreateDialog(AOwner: TComponent;
      AComponent: TRecorderFrequencyResponseComponent;
      ARegistry: TRecorderTagRegistry); reintroduce;
    destructor Destroy; override;
  end;

function ShowRecorderFrequencyResponseSettingsDialog(AOwner: TComponent;
  AComponent: TRecorderFrequencyResponseComponent;
  ARegistry: TRecorderTagRegistry): Boolean;
var
  lDialog: TFrequencyResponseSettingsDialog;
begin
  lDialog := TFrequencyResponseSettingsDialog.CreateDialog(AOwner, AComponent, ARegistry);
  try Result := lDialog.ShowModal = mrOk; finally lDialog.Free; end;
end;

constructor TFrequencyResponseSettingsDialog.CreateDialog(AOwner: TComponent;
  AComponent: TRecorderFrequencyResponseComponent; ARegistry: TRecorderTagRegistry);
begin
  inherited CreateNew(AOwner, 1);
  fComponent := AComponent; fRegistry := ARegistry;
  fDraft := TRecorderFrequencyResponseComponent.Create; fDraft.Assign(AComponent);
  Caption := 'Настройка АФЧХ — ' + AComponent.Name;
  Position := poOwnerFormCenter; BorderStyle := bsSizeable;
  ClientWidth := 980; ClientHeight := 650;
  Constraints.MinWidth := 860; Constraints.MinHeight := 600;
  BuildUi; FillAvailable; FillTree;
end;

destructor TFrequencyResponseSettingsDialog.Destroy;
begin fDraft.Free; inherited Destroy; end;

procedure TFrequencyResponseSettingsDialog.AddLabel(const AText: string; ATop: Integer);
var l: TLabel;
begin l := TLabel.Create(Self); l.Parent := fProps; l.Caption := AText; l.SetBounds(12, ATop + 5, 165, 22); end;

procedure TFrequencyResponseSettingsDialog.SetRow(AControl: TControl; ATop: Integer);
begin AControl.Parent := fProps; AControl.SetBounds(180, ATop, 285, 26); AControl.Anchors := [akTop, akLeft, akRight]; end;

procedure TFrequencyResponseSettingsDialog.BuildUi;
var
  lLeft, lRight, lAvail: TPanel;
  b: TButton;
begin
  lLeft := TPanel.Create(Self); lLeft.Parent := Self; lLeft.Align := alLeft;
  lLeft.Width := 310; lLeft.Caption := '';
  fTree := TTreeView.Create(Self); fTree.Parent := lLeft; fTree.Align := alClient;
  fTree.ReadOnly := True; fTree.OnChange := @TreeChange;
  b := TButton.Create(Self); b.Parent := lLeft; b.Align := alBottom; b.Height := 30;
  b.Caption := 'Удалить выбранное'; b.OnClick := @DeleteClick;
  b := TButton.Create(Self); b.Parent := lLeft; b.Align := alBottom; b.Height := 30;
  b.Caption := 'Добавить ось'; b.OnClick := @AddAxisClick;

  lRight := TPanel.Create(Self); lRight.Parent := Self; lRight.Align := alClient; lRight.Caption := '';
  fProps := TPanel.Create(Self); fProps.Parent := lRight; fProps.Align := alTop;
  fProps.Height := 370; fProps.Caption := '';
  AddLabel('Имя:', 10); fName := TEdit.Create(Self); SetRow(fName, 10);
  AddLabel('Тип линии:', 42); fKind := TComboBox.Create(Self); fKind.Style := csDropDownList;
  fKind.Items.Add('АЧХ'); fKind.Items.Add('Фаза'); fKind.Items.Add('Передаточная характеристика'); SetRow(fKind, 42);
  AddLabel('Тег результата:', 74); fValueTag := TComboBox.Create(Self); fValueTag.Style := csDropDownList; SetRow(fValueTag, 74);
  AddLabel('Тег частоты:', 106); fFrequencyTag := TComboBox.Create(Self); fFrequencyTag.Style := csDropDownList; SetRow(fFrequencyTag, 106);
  AddLabel('Минимум:', 138); fMinY := TEdit.Create(Self); SetRow(fMinY, 138);
  AddLabel('Максимум:', 170); fMaxY := TEdit.Create(Self); SetRow(fMaxY, 170);
  AddLabel('Размер буфера:', 202); fBufferSize := TEdit.Create(Self); SetRow(fBufferSize, 202);
  AddLabel('Шаг dX, Гц:', 234); fStep := TEdit.Create(Self); SetRow(fStep, 234);
  AddLabel('Совпавшие точки:', 266); fMerge := TComboBox.Create(Self); fMerge.Style := csDropDownList;
  fMerge.Items.Add('Замещать'); fMerge.Items.Add('Большая амплитуда'); fMerge.Items.Add('Среднее'); SetRow(fMerge, 266);
  fUniform := TCheckBox.Create(Self); fUniform.Parent := fProps; fUniform.Caption := 'Равномерный X'; fUniform.SetBounds(180, 298, 140, 24);
  fDrawLine := TCheckBox.Create(Self); fDrawLine.Parent := fProps; fDrawLine.Caption := 'Линия'; fDrawLine.SetBounds(325, 298, 75, 24);
  fDrawPoints := TCheckBox.Create(Self); fDrawPoints.Parent := fProps; fDrawPoints.Caption := 'Точки'; fDrawPoints.SetBounds(400, 298, 75, 24);
  AddLabel('Цвет / толщина:', 330); fColor := TColorButton.Create(Self); fColor.Parent := fProps; fColor.SetBounds(180, 330, 95, 26);
  fWidth := TEdit.Create(Self); fWidth.Parent := fProps; fWidth.SetBounds(285, 330, 60, 26);
  fLogY := TCheckBox.Create(Self); fLogY.Parent := fProps; fLogY.Caption := 'Логарифмическая ось Y'; fLogY.SetBounds(355, 330, 190, 24);

  lAvail := TPanel.Create(Self); lAvail.Parent := lRight; lAvail.Align := alClient; lAvail.Caption := '';
  fSearch := TEdit.Create(Self); fSearch.Parent := lAvail; fSearch.Align := alTop; fSearch.Height := 28;
  fSearch.TextHint := 'Поиск доступных сигналов по имени, адресу или описанию'; fSearch.OnChange := @SearchChange;
  fAvailable := TListBox.Create(Self); fAvailable.Parent := lAvail; fAvailable.Align := alClient; fAvailable.MultiSelect := True;
  b := TButton.Create(Self); b.Parent := lAvail; b.Align := alBottom; b.Height := 32;
  b.Caption := 'Добавить выбранные сигналы линиями'; b.OnClick := @AddLinesClick;

  fMinX := TEdit.Create(Self); fMinX.Parent := Self; fMinX.SetBounds(326, 608, 80, 26); fMinX.Anchors := [akLeft, akBottom];
  fMaxX := TEdit.Create(Self); fMaxX.Parent := Self; fMaxX.SetBounds(414, 608, 80, 26); fMaxX.Anchors := [akLeft, akBottom];
  fLogX := TCheckBox.Create(Self); fLogX.Parent := Self; fLogX.Caption := 'Лог X'; fLogX.SetBounds(505, 608, 75, 26); fLogX.Anchors := [akLeft, akBottom];
  fLegend := TCheckBox.Create(Self); fLegend.Parent := Self; fLegend.Caption := 'Легенда'; fLegend.SetBounds(585, 608, 90, 26); fLegend.Anchors := [akLeft, akBottom];
  b := TButton.Create(Self); b.Parent := Self; b.Caption := 'OK'; b.Default := True; b.SetBounds(790, 608, 80, 28); b.Anchors := [akRight, akBottom]; b.OnClick := @OkClick;
  b := TButton.Create(Self); b.Parent := Self; b.Caption := 'Отмена'; b.Cancel := True; b.ModalResult := mrCancel; b.SetBounds(882, 608, 80, 28); b.Anchors := [akRight, akBottom];
  fMinX.Text := FloatToStr(fDraft.MinFrequencyHz); fMaxX.Text := FloatToStr(fDraft.MaxFrequencyHz);
  fLogX.Checked := False; fLegend.Checked := fDraft.LegendVisible;
end;

procedure TFrequencyResponseSettingsDialog.FillAvailable;
var I: Integer; t: TRecorderTag; s, n: string;
begin
  n := LowerCase(Trim(fSearch.Text)); fAvailable.Items.BeginUpdate;
  try fAvailable.Clear; if fRegistry <> nil then for I := 0 to fRegistry.TagCount - 1 do begin
    t := fRegistry.Tags[I]; s := t.Name + '  ' + t.Address + '  ' + t.Description;
    if (n = '') or (Pos(n, LowerCase(s)) > 0) then fAvailable.Items.AddObject(s, t);
  end; finally fAvailable.Items.EndUpdate; end;
end;

procedure TFrequencyResponseSettingsDialog.SearchChange(Sender: TObject); begin FillAvailable; end;

procedure TFrequencyResponseSettingsDialog.FillTree(ASelect: TObject);
var I, J: Integer; a: TRecorderFrequencyResponseAxis; l: TRecorderFrequencyResponseLine; n, c, selected: TTreeNode;
begin
  fEditing := nil; fLoading := True; selected := nil; fTree.Items.BeginUpdate;
  try fTree.Items.Clear; for I := 0 to fDraft.AxisCount - 1 do begin
    a := fDraft.Axes[I]; n := fTree.Items.AddObject(nil, a.Name, a); if TObject(a)=ASelect then selected:=n;
    for J := 0 to fDraft.LineCount - 1 do begin l:=fDraft.Lines[J]; if SameText(l.AxisName,a.Name) then begin c:=fTree.Items.AddChildObject(n,l.Name,l); if TObject(l)=ASelect then selected:=c; end; end;
    n.Expand(False);
  end; finally fTree.Items.EndUpdate; end;
  if selected=nil then selected:=fTree.Items.GetFirstNode; fTree.Selected:=selected;
  fLoading := False; LoadSelection;
end;

function TFrequencyResponseSettingsDialog.SelectedAxis: TRecorderFrequencyResponseAxis;
begin Result:=nil; if (fTree.Selected<>nil) and (TObject(fTree.Selected.Data) is TRecorderFrequencyResponseAxis) then Result:=TRecorderFrequencyResponseAxis(fTree.Selected.Data); end;
function TFrequencyResponseSettingsDialog.SelectedLine: TRecorderFrequencyResponseLine;
begin Result:=nil; if (fTree.Selected<>nil) and (TObject(fTree.Selected.Data) is TRecorderFrequencyResponseLine) then Result:=TRecorderFrequencyResponseLine(fTree.Selected.Data); end;

function TFrequencyResponseSettingsDialog.FindAxis(const AName: string): TRecorderFrequencyResponseAxis;
var I: Integer;
begin Result:=nil; for I:=0 to fDraft.AxisCount-1 do if SameText(fDraft.Axes[I].Name,AName) then Exit(fDraft.Axes[I]); end;

function TFrequencyResponseSettingsDialog.EnsureAxisForKind(AKind: TRecorderFrequencyResponseKind): TRecorderFrequencyResponseAxis;
var n: string;
begin if AKind=frkPhase then n:='Фаза' else n:='Амплитуда'; Result:=FindAxis(n); if Result=nil then begin Result:=fDraft.AddAxis; Result.Name:=n; if AKind=frkPhase then begin Result.MinValue:=-180; Result.MaxValue:=180; end; end; end;

procedure TFrequencyResponseSettingsDialog.FillTagCombo(ACombo: TComboBox; AIncludeAuto: Boolean; AId: TRecorderTagId; const AName: string);
var I, sel: Integer; t:TRecorderTag;
begin sel:=-1; ACombo.Items.BeginUpdate; try ACombo.Clear; if AIncludeAuto then ACombo.Items.AddObject('(автоматически)',nil);
  if fRegistry<>nil then for I:=0 to fRegistry.TagCount-1 do begin t:=fRegistry.Tags[I]; ACombo.Items.AddObject(t.Name,t); if ((AId<>0)and(t.Id=AId))or((AId=0)and SameText(t.Name,AName)) then sel:=ACombo.Items.Count-1; end;
  if sel>=0 then ACombo.ItemIndex:=sel else if AIncludeAuto then ACombo.ItemIndex:=0;
finally ACombo.Items.EndUpdate; end; end;

function TFrequencyResponseSettingsDialog.ComboTag(ACombo:TComboBox):TRecorderTag;
begin Result:=nil; if (ACombo.ItemIndex>=0) and (ACombo.Items.Objects[ACombo.ItemIndex] is TRecorderTag) then Result:=TRecorderTag(ACombo.Items.Objects[ACombo.ItemIndex]); end;

procedure TFrequencyResponseSettingsDialog.LoadSelection;
var a:TRecorderFrequencyResponseAxis; l:TRecorderFrequencyResponseLine;
begin fLoading:=True; try a:=SelectedAxis; l:=SelectedLine; if a<>nil then fEditing:=a else fEditing:=l;
  if a<>nil then begin fName.Text:=a.Name; fMinY.Text:=FloatToStr(a.MinValue); fMaxY.Text:=FloatToStr(a.MaxValue); fLogY.Checked:=a.Logarithmic; fKind.Enabled:=False; fValueTag.Enabled:=False; fFrequencyTag.Enabled:=False; end
  else if l<>nil then begin fName.Text:=l.Name; fKind.Enabled:=True; fKind.ItemIndex:=Ord(l.Kind); FillTagCombo(fValueTag,True,l.ValueTagId,l.ValueTagName); FillTagCombo(fFrequencyTag,True,l.FrequencyTagId,l.FrequencyTagName); fValueTag.Enabled:=True; fFrequencyTag.Enabled:=True; fBufferSize.Text:=IntToStr(l.BufferSize); fStep.Text:=FloatToStr(l.FrequencyStepHz); fMerge.ItemIndex:=Ord(l.MergeMode); fUniform.Checked:=l.UniformX; fColor.ButtonColor:=TColor(l.Color); fWidth.Text:=IntToStr(l.Width); fDrawLine.Checked:=l.DrawLine; fDrawPoints.Checked:=l.DrawPoints; end;
finally fLoading:=False; end; end;

procedure TFrequencyResponseSettingsDialog.SaveSelection;
var a:TRecorderFrequencyResponseAxis; l:TRecorderFrequencyResponseLine; old:string; I:Integer;
begin if fLoading then Exit; a:=nil; l:=nil; if fEditing is TRecorderFrequencyResponseAxis then a:=TRecorderFrequencyResponseAxis(fEditing) else if fEditing is TRecorderFrequencyResponseLine then l:=TRecorderFrequencyResponseLine(fEditing);
  if a<>nil then begin old:=a.Name; a.Name:=Trim(fName.Text); if a.Name='' then a.Name:=old; if not SameText(old,a.Name) then for I:=0 to fDraft.LineCount-1 do if SameText(fDraft.Lines[I].AxisName,old) then fDraft.Lines[I].AxisName:=a.Name; a.MinValue:=FloatValue(fMinY,a.MinValue); a.MaxValue:=FloatValue(fMaxY,a.MaxValue); a.Logarithmic:=fLogY.Checked; end
  else if l<>nil then begin l.Name:=Trim(fName.Text); l.Kind:=TRecorderFrequencyResponseKind(Max(0,fKind.ItemIndex)); l.SetValueTag(ComboTag(fValueTag)); l.SetFrequencyTag(ComboTag(fFrequencyTag)); l.BufferSize:=Max(1,StrToIntDef(fBufferSize.Text,l.BufferSize)); l.FrequencyStepHz:=FloatValue(fStep,l.FrequencyStepHz); l.MergeMode:=TRecorderFrequencyResponseMergeMode(Max(0,fMerge.ItemIndex)); l.UniformX:=fUniform.Checked; l.Color:=fColor.ButtonColor; l.Width:=Max(1,StrToIntDef(fWidth.Text,2)); l.DrawLine:=fDrawLine.Checked; l.DrawPoints:=fDrawPoints.Checked; end;
end;

procedure TFrequencyResponseSettingsDialog.TreeChange(Sender:TObject; Node:TTreeNode); begin if fLoading then Exit; SaveSelection; LoadSelection; end;

procedure TFrequencyResponseSettingsDialog.AddAxisClick(Sender:TObject);
var a:TRecorderFrequencyResponseAxis;
begin SaveSelection; a:=fDraft.AddAxis; a.Name:='Ось '+IntToStr(fDraft.AxisCount); FillTree(a); end;

procedure TFrequencyResponseSettingsDialog.AddLinesClick(Sender:TObject);
var I:Integer; t:TRecorderTag; l:TRecorderFrequencyResponseLine; a:TRecorderFrequencyResponseAxis; k:TRecorderFrequencyResponseKind;
begin SaveSelection; for I:=0 to fAvailable.Count-1 do if fAvailable.Selected[I] then begin t:=TRecorderTag(fAvailable.Items.Objects[I]); if ContainsText(t.Name,'phase') or ContainsText(t.Name,'фаз') then k:=frkPhase else k:=frkAmplitude; a:=EnsureAxisForKind(k); l:=fDraft.AddLine; l.Name:=t.Name; l.AxisName:=a.Name; l.Kind:=k; l.SetSourceTag(t); end; FillTree; end;

procedure TFrequencyResponseSettingsDialog.DeleteClick(Sender:TObject);
var a:TRecorderFrequencyResponseAxis; l:TRecorderFrequencyResponseLine; I:Integer;
begin a:=SelectedAxis; l:=SelectedLine; if l<>nil then begin for I:=0 to fDraft.LineCount-1 do if fDraft.Lines[I]=l then begin fDraft.DeleteLine(I); Break; end; end else if (a<>nil) and (fDraft.AxisCount>1) then begin for I:=fDraft.LineCount-1 downto 0 do if SameText(fDraft.Lines[I].AxisName,a.Name) then fDraft.DeleteLine(I); for I:=0 to fDraft.AxisCount-1 do if fDraft.Axes[I]=a then begin fDraft.DeleteAxis(I); Break; end; end; FillTree; end;

function TFrequencyResponseSettingsDialog.FloatValue(AEdit:TEdit; ADefault:Double):Double;
var s:string;
begin s:=StringReplace(Trim(AEdit.Text),'.',DecimalSeparator,[rfReplaceAll]); s:=StringReplace(s,',',DecimalSeparator,[rfReplaceAll]); Result:=StrToFloatDef(s,ADefault); end;

procedure TFrequencyResponseSettingsDialog.OkClick(Sender:TObject);
var I:Integer;
begin SaveSelection; fDraft.MinFrequencyHz:=FloatValue(fMinX,fDraft.MinFrequencyHz); fDraft.MaxFrequencyHz:=FloatValue(fMaxX,fDraft.MaxFrequencyHz); fDraft.LegendVisible:=fLegend.Checked;
  if fDraft.MaxFrequencyHz<=fDraft.MinFrequencyHz then begin MessageDlg('Проверьте диапазон X.',mtError,[mbOK],0); Exit; end;
  for I:=0 to fDraft.AxisCount-1 do if fDraft.Axes[I].MaxValue<=fDraft.Axes[I].MinValue then begin MessageDlg('Проверьте диапазон оси '+fDraft.Axes[I].Name,mtError,[mbOK],0); Exit; end;
  fComponent.Assign(fDraft); ModalResult:=mrOk;
end;

end.
