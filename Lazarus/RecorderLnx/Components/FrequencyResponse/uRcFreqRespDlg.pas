unit uRcFreqRespDlg;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Dialogs,
  Graphics, Math, StrUtils, uRecorderTags, uRecorderFrequencyResponse,
  uRecorderFrequencyResponseModel;

function ShowRcFreqRespDlg(AOwner: TComponent;
  AComp: TRecorderFrequencyResponseComponent;
  AReg: TRecorderTagRegistry): Boolean;

implementation

{$R *.lfm}

type
  TRcFreqRespDlg = class(TForm)
    fTree: TTreeView;
    fAvailable: TListBox;
    fSearch, fName, fMinX, fMaxX, fMinY, fMaxY: TEdit;
    fBufSize, fStep, fWidth: TEdit;
    fKind, fValueTag, fFreqTag, fMerge: TComboBox;
    fUniform, fLogX, fLogY, fLegend, fDrawLine, fDrawPoints: TCheckBox;
    fColor: TColorButton;
    fProps: TPanel;
    procedure AddAxisClick(Sender: TObject);
    procedure AddLinesClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure SearchChange(Sender: TObject);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure OkClick(Sender: TObject);
  private
    fComp, fDraft: TRecorderFrequencyResponseComponent;
    fReg: TRecorderTagRegistry;
    fLoading: Boolean;
    fEditing: TObject;
    procedure FillAvailable;
    procedure FillTree(ASelect: TObject = nil);
    procedure LoadSelection;
    procedure SaveSelection;
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
      AComp: TRecorderFrequencyResponseComponent;
      AReg: TRecorderTagRegistry); reintroduce;
    destructor Destroy; override;
  end;

function ShowRcFreqRespDlg(AOwner: TComponent;
  AComp: TRecorderFrequencyResponseComponent;
  AReg: TRecorderTagRegistry): Boolean;
var
  lDlg: TRcFreqRespDlg;
begin
  lDlg := TRcFreqRespDlg.CreateDialog(AOwner, AComp, AReg);
  try Result := lDlg.ShowModal = mrOk; finally lDlg.Free; end;
end;

constructor TRcFreqRespDlg.CreateDialog(AOwner: TComponent;
  AComp: TRecorderFrequencyResponseComponent; AReg: TRecorderTagRegistry);
begin
  inherited Create(AOwner);
  fComp := AComp; fReg := AReg;
  fDraft := TRecorderFrequencyResponseComponent.Create; fDraft.Assign(AComp);
  Caption := 'Настройка АФЧХ — ' + AComp.Name;
  fKind.Items.Add('АЧХ');
  fKind.Items.Add('Фаза');
  fKind.Items.Add('Передаточная характеристика');
  fMerge.Items.Add('Замещать');
  fMerge.Items.Add('Большая амплитуда');
  fMerge.Items.Add('Среднее');
  fMinX.Text := FloatToStr(fDraft.MinFrequencyHz);
  fMaxX.Text := FloatToStr(fDraft.MaxFrequencyHz);
  fLegend.Checked := fDraft.LegendVisible;
  FillAvailable;
  FillTree;
end;

destructor TRcFreqRespDlg.Destroy;
begin fDraft.Free; inherited Destroy; end;

procedure TRcFreqRespDlg.FillAvailable;
var I: Integer; t: TRecorderTag; s, n: string;
begin
  n := LowerCase(Trim(fSearch.Text)); fAvailable.Items.BeginUpdate;
  try fAvailable.Clear; if fReg <> nil then for I := 0 to fReg.TagCount - 1 do begin
    t := fReg.Tags[I]; s := t.Name + '  ' + t.Address + '  ' + t.Description;
    if (n = '') or (Pos(n, LowerCase(s)) > 0) then fAvailable.Items.AddObject(s, t);
  end; finally fAvailable.Items.EndUpdate; end;
end;

procedure TRcFreqRespDlg.SearchChange(Sender: TObject); begin FillAvailable; end;

procedure TRcFreqRespDlg.FillTree(ASelect: TObject);
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

function TRcFreqRespDlg.SelectedAxis: TRecorderFrequencyResponseAxis;
begin Result:=nil; if (fTree.Selected<>nil) and (TObject(fTree.Selected.Data) is TRecorderFrequencyResponseAxis) then Result:=TRecorderFrequencyResponseAxis(fTree.Selected.Data); end;
function TRcFreqRespDlg.SelectedLine: TRecorderFrequencyResponseLine;
begin Result:=nil; if (fTree.Selected<>nil) and (TObject(fTree.Selected.Data) is TRecorderFrequencyResponseLine) then Result:=TRecorderFrequencyResponseLine(fTree.Selected.Data); end;

function TRcFreqRespDlg.FindAxis(const AName: string): TRecorderFrequencyResponseAxis;
var I: Integer;
begin Result:=nil; for I:=0 to fDraft.AxisCount-1 do if SameText(fDraft.Axes[I].Name,AName) then Exit(fDraft.Axes[I]); end;

function TRcFreqRespDlg.EnsureAxisForKind(AKind: TRecorderFrequencyResponseKind): TRecorderFrequencyResponseAxis;
var n: string;
begin if AKind=frkPhase then n:='Фаза' else n:='Амплитуда'; Result:=FindAxis(n); if Result=nil then begin Result:=fDraft.AddAxis; Result.Name:=n; if AKind=frkPhase then begin Result.MinValue:=-180; Result.MaxValue:=180; end; end; end;

procedure TRcFreqRespDlg.FillTagCombo(ACombo: TComboBox; AIncludeAuto: Boolean; AId: TRecorderTagId; const AName: string);
var I, sel: Integer; t:TRecorderTag;
begin sel:=-1; ACombo.Items.BeginUpdate; try ACombo.Clear; if AIncludeAuto then ACombo.Items.AddObject('(автоматически)',nil);
  if fReg<>nil then for I:=0 to fReg.TagCount-1 do begin t:=fReg.Tags[I]; ACombo.Items.AddObject(t.Name,t); if ((AId<>0)and(t.Id=AId))or((AId=0)and SameText(t.Name,AName)) then sel:=ACombo.Items.Count-1; end;
  if sel>=0 then ACombo.ItemIndex:=sel else if AIncludeAuto then ACombo.ItemIndex:=0;
finally ACombo.Items.EndUpdate; end; end;

function TRcFreqRespDlg.ComboTag(ACombo:TComboBox):TRecorderTag;
begin Result:=nil; if (ACombo.ItemIndex>=0) and (ACombo.Items.Objects[ACombo.ItemIndex] is TRecorderTag) then Result:=TRecorderTag(ACombo.Items.Objects[ACombo.ItemIndex]); end;

procedure TRcFreqRespDlg.LoadSelection;
var a:TRecorderFrequencyResponseAxis; l:TRecorderFrequencyResponseLine;
begin fLoading:=True; try a:=SelectedAxis; l:=SelectedLine; if a<>nil then fEditing:=a else fEditing:=l;
  if a<>nil then begin fName.Text:=a.Name; fMinY.Text:=FloatToStr(a.MinValue); fMaxY.Text:=FloatToStr(a.MaxValue); fLogY.Checked:=a.Logarithmic; fKind.Enabled:=False; fValueTag.Enabled:=False; fFreqTag.Enabled:=False; end
  else if l<>nil then begin fName.Text:=l.Name; fKind.Enabled:=True; fKind.ItemIndex:=Ord(l.Kind); FillTagCombo(fValueTag,True,l.ValueTagId,l.ValueTagName); FillTagCombo(fFreqTag,True,l.FrequencyTagId,l.FrequencyTagName); fValueTag.Enabled:=True; fFreqTag.Enabled:=True; fBufSize.Text:=IntToStr(l.BufferSize); fStep.Text:=FloatToStr(l.FrequencyStepHz); fMerge.ItemIndex:=Ord(l.MergeMode); fUniform.Checked:=l.UniformX; fColor.ButtonColor:=TColor(l.Color); fWidth.Text:=IntToStr(l.Width); fDrawLine.Checked:=l.DrawLine; fDrawPoints.Checked:=l.DrawPoints; end;
finally fLoading:=False; end; end;

procedure TRcFreqRespDlg.SaveSelection;
var a:TRecorderFrequencyResponseAxis; l:TRecorderFrequencyResponseLine; old:string; I:Integer;
begin if fLoading then Exit; a:=nil; l:=nil; if fEditing is TRecorderFrequencyResponseAxis then a:=TRecorderFrequencyResponseAxis(fEditing) else if fEditing is TRecorderFrequencyResponseLine then l:=TRecorderFrequencyResponseLine(fEditing);
  if a<>nil then begin old:=a.Name; a.Name:=Trim(fName.Text); if a.Name='' then a.Name:=old; if not SameText(old,a.Name) then for I:=0 to fDraft.LineCount-1 do if SameText(fDraft.Lines[I].AxisName,old) then fDraft.Lines[I].AxisName:=a.Name; a.MinValue:=FloatValue(fMinY,a.MinValue); a.MaxValue:=FloatValue(fMaxY,a.MaxValue); a.Logarithmic:=fLogY.Checked; end
  else if l<>nil then begin l.Name:=Trim(fName.Text); l.Kind:=TRecorderFrequencyResponseKind(Max(0,fKind.ItemIndex)); l.SetValueTag(ComboTag(fValueTag)); l.SetFrequencyTag(ComboTag(fFreqTag)); l.BufferSize:=Max(1,StrToIntDef(fBufSize.Text,l.BufferSize)); l.FrequencyStepHz:=FloatValue(fStep,l.FrequencyStepHz); l.MergeMode:=TRecorderFrequencyResponseMergeMode(Max(0,fMerge.ItemIndex)); l.UniformX:=fUniform.Checked; l.Color:=fColor.ButtonColor; l.Width:=Max(1,StrToIntDef(fWidth.Text,2)); l.DrawLine:=fDrawLine.Checked; l.DrawPoints:=fDrawPoints.Checked; end;
end;

procedure TRcFreqRespDlg.TreeChange(Sender:TObject; Node:TTreeNode); begin if fLoading then Exit; SaveSelection; LoadSelection; end;

procedure TRcFreqRespDlg.AddAxisClick(Sender:TObject);
var a:TRecorderFrequencyResponseAxis;
begin SaveSelection; a:=fDraft.AddAxis; a.Name:='Ось '+IntToStr(fDraft.AxisCount); FillTree(a); end;

procedure TRcFreqRespDlg.AddLinesClick(Sender:TObject);
var I:Integer; t:TRecorderTag; l:TRecorderFrequencyResponseLine; a:TRecorderFrequencyResponseAxis; k:TRecorderFrequencyResponseKind;
begin SaveSelection; for I:=0 to fAvailable.Count-1 do if fAvailable.Selected[I] then begin t:=TRecorderTag(fAvailable.Items.Objects[I]); if ContainsText(t.Name,'phase') or ContainsText(t.Name,'фаз') then k:=frkPhase else k:=frkAmplitude; a:=EnsureAxisForKind(k); l:=fDraft.AddLine; l.Name:=t.Name; l.AxisName:=a.Name; l.Kind:=k; l.SetSourceTag(t); end; FillTree; end;

procedure TRcFreqRespDlg.DeleteClick(Sender:TObject);
var a:TRecorderFrequencyResponseAxis; l:TRecorderFrequencyResponseLine; I:Integer;
begin a:=SelectedAxis; l:=SelectedLine; if l<>nil then begin for I:=0 to fDraft.LineCount-1 do if fDraft.Lines[I]=l then begin fDraft.DeleteLine(I); Break; end; end else if (a<>nil) and (fDraft.AxisCount>1) then begin for I:=fDraft.LineCount-1 downto 0 do if SameText(fDraft.Lines[I].AxisName,a.Name) then fDraft.DeleteLine(I); for I:=0 to fDraft.AxisCount-1 do if fDraft.Axes[I]=a then begin fDraft.DeleteAxis(I); Break; end; end; FillTree; end;

function TRcFreqRespDlg.FloatValue(AEdit:TEdit; ADefault:Double):Double;
var s:string;
begin s:=StringReplace(Trim(AEdit.Text),'.',DecimalSeparator,[rfReplaceAll]); s:=StringReplace(s,',',DecimalSeparator,[rfReplaceAll]); Result:=StrToFloatDef(s,ADefault); end;

procedure TRcFreqRespDlg.OkClick(Sender:TObject);
var I:Integer;
begin SaveSelection; fDraft.MinFrequencyHz:=FloatValue(fMinX,fDraft.MinFrequencyHz); fDraft.MaxFrequencyHz:=FloatValue(fMaxX,fDraft.MaxFrequencyHz); fDraft.LegendVisible:=fLegend.Checked;
  if fDraft.MaxFrequencyHz<=fDraft.MinFrequencyHz then begin MessageDlg('Проверьте диапазон X.',mtError,[mbOK],0); Exit; end;
  for I:=0 to fDraft.AxisCount-1 do if fDraft.Axes[I].MaxValue<=fDraft.Axes[I].MinValue then begin MessageDlg('Проверьте диапазон оси '+fDraft.Axes[I].Name,mtError,[mbOK],0); Exit; end;
  fComp.Assign(fDraft); ModalResult:=mrOk;
end;

end.
