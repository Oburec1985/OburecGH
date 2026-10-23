unit uRcFreqRespDlg;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Dialogs,
  Graphics, Math, StrUtils, LazUTF8, uRecorderTags, uRecorderFrequencyResponse,
  uRecorderFrequencyResponseModel;

function ShowRcFreqRespDlg(AOwner: TComponent;
  AComp: TRecorderFrequencyResponseComponent;
  AReg: TRecorderTagRegistry): Boolean;

implementation

{$R *.lfm}

type
  TRcFreqRespDlg = class(TForm)
  published
    pnlLeft, pnlMain, pnlBottom, pnlAvail, pnlAxes: TPanel;
    splitTree, splitAvailable: TSplitter;
    btnDel, btnAddAxis, btnOk, btnCancel, btnAddLines: TButton;
    lblName, lblKind, lblValue, lblFreq, lblMinY, lblMaxY: TLabel;
    lblBuf, lblStep, lblMerge, lblStyle, lblMinX, lblMaxX: TLabel;
    fTree: TTreeView;
    fAvailable: TListView;
    fSearch, fName, fMinX, fMaxX, fMinY, fMaxY: TEdit;
    fBufSize, fStep, fWidth: TEdit;
    fKind, fValueTag, fFreqTag, fMerge, fFreqMode: TComboBox;
    lblFreqMode, lblFrequencyHint: TLabel;
    fUniform, fLogX, fLogY, fLegend, fDrawLine, fDrawPoints: TCheckBox;
    fColor: TColorButton;
    fProps: TPanel;
    procedure AddAxisClick(Sender: TObject);
    procedure AddLinesClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure SearchChange(Sender: TObject);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure OkClick(Sender: TObject);
    procedure BindingChange(Sender: TObject);
    procedure KindChange(Sender: TObject);
    procedure TreeDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeDragDrop(Sender, Source: TObject; X, Y: Integer);
  private
    fComp, fDraft: TRecorderFrequencyResponseComponent;
    fReg: TRecorderTagRegistry;
    fLoading: Boolean;
    fEditing: TObject;
    fTags: TList;
    fTagSearch: TStringList;
    procedure UpdateBinding;
    procedure FilterTagChoices;
    function EditingAxis: TRecorderFrequencyResponseAxis;
    procedure FillAvailable;
    procedure FillTree(ASelect: TObject = nil);
    procedure LoadSelection;
    procedure SaveSelection;
    function SelectedAxis: TRecorderFrequencyResponseAxis;
    function SelectedLine: TRecorderFrequencyResponseLine;
    function FindAxis(const AName: string): TRecorderFrequencyResponseAxis;
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
var I: Integer; lTag: TRecorderTag;
begin
  inherited Create(AOwner);
  fComp := AComp; fReg := AReg;
  fDraft := TRecorderFrequencyResponseComponent.Create; fDraft.Assign(AComp);
  fTags := TList.Create;
  fTagSearch := TStringList.Create;
  if fReg <> nil then for I := 0 to fReg.TagCount - 1 do
  begin
    lTag := fReg.Tags[I];
    fTags.Add(lTag);
    fTagSearch.Add(UTF8LowerCase(lTag.Name+' '+lTag.Address+' '+lTag.Description));
  end;
  Caption := 'Настройка АФЧХ — ' + AComp.Name;
  fKind.Items.Add('АЧХ');
  fKind.Items.Add('Фаза');
  fKind.Items.Add('FRF');
  fFreqMode.Items.Add('Автоматически');
  fFreqMode.Items.Add('Последнее значение');
  fFreqMode.Items.Add('Мат. ожидание');
  fFreqMode.Items.Add('Главная гармоника спектра');
  fFreqMode.Items.Add('Тахо — расчётный тег');
  fMerge.Items.Add('Замещать');
  fMerge.Items.Add('Большая амплитуда');
  fMerge.Items.Add('Среднее');
  fMinX.Text := FloatToStr(fDraft.MinFrequencyHz);
  fMaxX.Text := FloatToStr(fDraft.MaxFrequencyHz);
  fLegend.Checked := fDraft.LegendVisible;
  fLogX.Checked := fDraft.LogFrequency;
  FillAvailable;
  FillTree;
end;

destructor TRcFreqRespDlg.Destroy;
begin fTagSearch.Free; fTags.Free; fDraft.Free; inherited Destroy; end;

procedure TRcFreqRespDlg.FillAvailable;
var I: Integer; t: TRecorderTag; n: string; lItem: TListItem; lSelected: TList;
begin
  n := UTF8LowerCase(Trim(fSearch.Text));
  lSelected := TList.Create;
  fAvailable.Items.BeginUpdate;
  try
    for I := 0 to fAvailable.Items.Count-1 do
      if fAvailable.Items[I].Selected then lSelected.Add(fAvailable.Items[I].Data);
    fAvailable.Items.Clear;
    for I := 0 to fTags.Count-1 do begin
      if (n <> '') and (Pos(n,fTagSearch[I])=0) then Continue;
      t := TRecorderTag(fTags[I]);
      lItem := fAvailable.Items.Add;
      lItem.Caption := t.Name; lItem.Data := t;
      if t.PollFrequencyHz>0 then lItem.SubItems.Add(FloatToStr(t.PollFrequencyHz))
      else lItem.SubItems.Add('—');
      lItem.Selected := lSelected.IndexOf(t)>=0;
    end;
  finally fAvailable.Items.EndUpdate; lSelected.Free; end;
end;

procedure TRcFreqRespDlg.SearchChange(Sender: TObject);
begin FillAvailable; FilterTagChoices; end;

procedure TRcFreqRespDlg.FilterTagChoices;
var lValue,lFrequency:TRecorderTag;
begin
  if not (fEditing is TRecorderFrequencyResponseLine) then Exit;
  lValue:=ComboTag(fValueTag); lFrequency:=ComboTag(fFreqTag);
  fLoading:=True;
  try
    if lValue<>nil then FillTagCombo(fValueTag,True,lValue.Id,lValue.Name)
    else FillTagCombo(fValueTag,True,0,'');
    if lFrequency<>nil then FillTagCombo(fFreqTag,True,lFrequency.Id,lFrequency.Name)
    else FillTagCombo(fFreqTag,True,0,'');
  finally fLoading:=False; end;
end;

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
var n:TTreeNode;
begin
  Result:=nil; n:=fTree.Selected;
  if (n<>nil) and (n.Parent<>nil) then n:=n.Parent;
  if (n<>nil) and (TObject(n.Data) is TRecorderFrequencyResponseAxis) then
    Result:=TRecorderFrequencyResponseAxis(n.Data);
end;
function TRcFreqRespDlg.SelectedLine: TRecorderFrequencyResponseLine;
begin Result:=nil; if (fTree.Selected<>nil) and (TObject(fTree.Selected.Data) is TRecorderFrequencyResponseLine) then Result:=TRecorderFrequencyResponseLine(fTree.Selected.Data); end;

function TRcFreqRespDlg.FindAxis(const AName: string): TRecorderFrequencyResponseAxis;
var I: Integer;
begin Result:=nil; for I:=0 to fDraft.AxisCount-1 do if SameText(fDraft.Axes[I].Name,AName) then Exit(fDraft.Axes[I]); end;

procedure TRcFreqRespDlg.FillTagCombo(ACombo: TComboBox; AIncludeAuto: Boolean; AId: TRecorderTagId; const AName: string);
var I, sel: Integer; t:TRecorderTag; lSelected:Boolean; lFilter:string;
begin sel:=-1; ACombo.Items.BeginUpdate; try ACombo.Clear; if AIncludeAuto then ACombo.Items.AddObject('(автоматически)',nil);
  lFilter:=UTF8LowerCase(Trim(fSearch.Text));
  for I:=0 to fTags.Count-1 do begin
    t:=TRecorderTag(fTags[I]);
    lSelected:=((AId<>0)and(t.Id=AId))or((AId=0)and SameText(t.Name,AName));
    // Сохраняет выбранный тег в списке, даже если общий поиск его отфильтровал.
    if not lSelected and (lFilter<>'') and (Pos(lFilter,fTagSearch[I])=0) then Continue;
    ACombo.Items.AddObject(t.Name,t);
    if lSelected then sel:=ACombo.Items.Count-1;
  end;
  if sel>=0 then ACombo.ItemIndex:=sel else if AIncludeAuto then ACombo.ItemIndex:=0;
finally ACombo.Items.EndUpdate; end; end;

function TRcFreqRespDlg.ComboTag(ACombo:TComboBox):TRecorderTag;
begin Result:=nil; if (ACombo.ItemIndex>=0) and (ACombo.Items.Objects[ACombo.ItemIndex] is TRecorderTag) then Result:=TRecorderTag(ACombo.Items.Objects[ACombo.ItemIndex]); end;

procedure TRcFreqRespDlg.LoadSelection;
var a:TRecorderFrequencyResponseAxis; l:TRecorderFrequencyResponseLine;
begin
  fLoading:=True;
  try
    a:=SelectedAxis; l:=SelectedLine;
    if l<>nil then fEditing:=l else fEditing:=a;
    fKind.Enabled:=(a<>nil) and (l=nil);
    fValueTag.Enabled:=l<>nil; fFreqTag.Enabled:=l<>nil; fFreqMode.Enabled:=l<>nil;
    fBufSize.Enabled:=l<>nil; fStep.Enabled:=l<>nil; fMerge.Enabled:=l<>nil;
    fUniform.Enabled:=l<>nil; fColor.Enabled:=l<>nil; fWidth.Enabled:=l<>nil;
    fDrawLine.Enabled:=l<>nil; fDrawPoints.Enabled:=l<>nil;
    if a<>nil then begin
      fName.Text:=a.Name; fKind.ItemIndex:=Ord(a.Kind);
      fMinY.Text:=FloatToStr(a.MinValue); fMaxY.Text:=FloatToStr(a.MaxValue);
      fLogY.Checked:=a.Logarithmic;
    end;
    if l<>nil then begin
      fName.Text:=l.Name; FillTagCombo(fValueTag,True,l.ValueTagId,l.ValueTagName);
      fBufSize.Text:=IntToStr(l.BufferSize); fStep.Text:=FloatToStr(l.FrequencyStepHz);
      fMerge.ItemIndex:=Ord(l.MergeMode); fUniform.Checked:=l.UniformX;
      fColor.ButtonColor:=TColor(l.Color); fWidth.Text:=IntToStr(l.Width);
      fDrawLine.Checked:=l.DrawLine; fDrawPoints.Checked:=l.DrawPoints;
    end else begin
      fValueTag.Clear; fFreqTag.Clear; fFreqMode.ItemIndex:=-1;
      lblFrequencyHint.Caption:='';
    end;
  finally fLoading:=False; end;
  UpdateBinding;
end;

function TRcFreqRespDlg.EditingAxis:TRecorderFrequencyResponseAxis;
begin
  Result:=nil;
  if fEditing is TRecorderFrequencyResponseAxis then Result:=TRecorderFrequencyResponseAxis(fEditing)
  else if fEditing is TRecorderFrequencyResponseLine then
    Result:=FindAxis(TRecorderFrequencyResponseLine(fEditing).AxisName);
end;

procedure TRcFreqRespDlg.UpdateBinding;
var l:TRecorderFrequencyResponseLine; b:TRecorderFrequencyResponseBinding;
begin
  if not (fEditing is TRecorderFrequencyResponseLine) then Exit;
  l:=TRecorderFrequencyResponseLine(fEditing);
  b:=RecorderResolveFrequencyResponseBinding(fReg,l);
  fLoading:=True;
  try
    if b.FrequencyTag<>nil then FillTagCombo(fFreqTag,True,b.FrequencyTag.Id,b.FrequencyTag.Name)
    else FillTagCombo(fFreqTag,True,l.FrequencyTagId,l.FrequencyTagName);
    if b.ValueTag<>nil then
      FillTagCombo(fValueTag,True,b.ValueTag.Id,b.ValueTag.Name);
    fFreqMode.ItemIndex:=Ord(b.FrequencyMode);
    fFreqTag.Enabled:=not b.FrequencyLocked;
    fFreqMode.Enabled:=not b.FrequencyLocked;
    fValueTag.Enabled:=not b.ValueFromSummary;
    lblFrequencyHint.Caption:=b.Hint; lblFrequencyHint.Hint:=b.Hint;
    fFreqTag.Hint:=b.Hint; fFreqMode.Hint:=b.Hint;
  finally fLoading:=False; end;
end;

procedure TRcFreqRespDlg.BindingChange(Sender:TObject);
var lLine:TRecorderFrequencyResponseLine;
begin
  if fLoading or not (fEditing is TRecorderFrequencyResponseLine) then Exit;
  lLine:=TRecorderFrequencyResponseLine(fEditing);
  // Автоматически разрешённый тег только отображается, пока пользователь не сменит выбор.
  if Sender=fValueTag then lLine.SetValueTag(ComboTag(fValueTag));
  if Sender=fFreqTag then begin
    lLine.SetFrequencyTag(ComboTag(fFreqTag));
    lLine.FrequencyMode:=frfmAutomatic;
  end;
  if Sender=fFreqMode then
    lLine.FrequencyMode:=TRecorderFrequencyResponseFrequencyMode(Max(0,fFreqMode.ItemIndex));
  UpdateBinding;
end;

procedure TRcFreqRespDlg.KindChange(Sender:TObject);
var a:TRecorderFrequencyResponseAxis; I:Integer;
begin
  if fLoading or not (fEditing is TRecorderFrequencyResponseAxis) then Exit;
  a:=TRecorderFrequencyResponseAxis(fEditing);
  a.Kind:=TRecorderFrequencyResponseKind(Max(0,fKind.ItemIndex));
  for I:=0 to fDraft.LineCount-1 do
    if SameText(fDraft.Lines[I].AxisName,a.Name) then fDraft.Lines[I].Kind:=a.Kind;
end;

procedure TRcFreqRespDlg.SaveSelection;
var a:TRecorderFrequencyResponseAxis; l:TRecorderFrequencyResponseLine; old:string; I:Integer;
begin
  if fLoading then Exit; a:=EditingAxis; l:=nil;
  if fEditing is TRecorderFrequencyResponseLine then l:=TRecorderFrequencyResponseLine(fEditing);
  if a<>nil then begin
    if l=nil then begin
      old:=a.Name; a.Name:=Trim(fName.Text); if a.Name='' then a.Name:=old;
      if not SameText(old,a.Name) then for I:=0 to fDraft.LineCount-1 do
        if SameText(fDraft.Lines[I].AxisName,old) then fDraft.Lines[I].AxisName:=a.Name;
    end;
    a.MinValue:=FloatValue(fMinY,a.MinValue); a.MaxValue:=FloatValue(fMaxY,a.MaxValue); a.Logarithmic:=fLogY.Checked;
  end;
  if l<>nil then begin
    l.Name:=Trim(fName.Text);
    l.BufferSize:=Max(1,StrToIntDef(fBufSize.Text,l.BufferSize));
    l.FrequencyStepHz:=FloatValue(fStep,l.FrequencyStepHz);
    l.MergeMode:=TRecorderFrequencyResponseMergeMode(Max(0,fMerge.ItemIndex));
    l.UniformX:=fUniform.Checked; l.Color:=fColor.ButtonColor;
    l.Width:=Max(1,StrToIntDef(fWidth.Text,2));
    l.DrawLine:=fDrawLine.Checked; l.DrawPoints:=fDrawPoints.Checked;
  end;
  for I:=0 to fTree.Items.Count-1 do if fTree.Items[I].Data=Pointer(fEditing) then begin
    if l<>nil then fTree.Items[I].Text:=l.Name
    else if a<>nil then fTree.Items[I].Text:=a.Name;
    Break;
  end;
end;

procedure TRcFreqRespDlg.TreeChange(Sender:TObject; Node:TTreeNode); begin if fLoading then Exit; SaveSelection; LoadSelection; end;

procedure TRcFreqRespDlg.AddAxisClick(Sender:TObject);
var a:TRecorderFrequencyResponseAxis;
begin SaveSelection; a:=fDraft.AddAxis; a.Name:='Узел '+IntToStr(fDraft.AxisCount); FillTree(a); end;

procedure TRcFreqRespDlg.AddLinesClick(Sender:TObject);
var I:Integer; t:TRecorderTag; l:TRecorderFrequencyResponseLine; a:TRecorderFrequencyResponseAxis;
begin
  SaveSelection; a:=SelectedAxis; if a=nil then Exit; l:=nil;
  for I:=0 to fAvailable.Items.Count-1 do if fAvailable.Items[I].Selected then begin
    t:=TRecorderTag(fAvailable.Items[I].Data); l:=fDraft.AddLine;
    l.Name:=t.Name; l.AxisName:=a.Name; l.Kind:=a.Kind; l.SetSourceTag(t);
  end;
  if l<>nil then FillTree(l);
end;

procedure TRcFreqRespDlg.TreeDragOver(Sender,Source:TObject; X,Y:Integer;
  State:TDragState; var Accept:Boolean);
begin Accept:=(Source=fAvailable) and (fAvailable.SelCount>0) and (fTree.GetNodeAt(X,Y)<>nil); end;

procedure TRcFreqRespDlg.TreeDragDrop(Sender,Source:TObject; X,Y:Integer);
var n:TTreeNode;
begin
  if Source<>fAvailable then Exit;
  n:=fTree.GetNodeAt(X,Y); if n=nil then Exit;
  fTree.Selected:=n; AddLinesClick(Sender);
end;

procedure TRcFreqRespDlg.DeleteClick(Sender:TObject);
var a:TRecorderFrequencyResponseAxis; l:TRecorderFrequencyResponseLine; I:Integer;
begin
  a:=SelectedAxis; l:=SelectedLine; fEditing:=nil;
  if l<>nil then begin
    for I:=0 to fDraft.LineCount-1 do if fDraft.Lines[I]=l then begin fDraft.DeleteLine(I); Break; end;
  end else if (a<>nil) and (fDraft.AxisCount>1) then begin
    for I:=fDraft.LineCount-1 downto 0 do if SameText(fDraft.Lines[I].AxisName,a.Name) then fDraft.DeleteLine(I);
    for I:=0 to fDraft.AxisCount-1 do if fDraft.Axes[I]=a then begin fDraft.DeleteAxis(I); Break; end;
  end;
  FillTree;
end;

function TRcFreqRespDlg.FloatValue(AEdit:TEdit; ADefault:Double):Double;
var s:string;
begin s:=StringReplace(Trim(AEdit.Text),'.',DefaultFormatSettings.DecimalSeparator,[rfReplaceAll]); s:=StringReplace(s,',',DefaultFormatSettings.DecimalSeparator,[rfReplaceAll]); Result:=StrToFloatDef(s,ADefault); end;

procedure TRcFreqRespDlg.OkClick(Sender:TObject);
var I:Integer;
begin SaveSelection; fDraft.MinFrequencyHz:=FloatValue(fMinX,fDraft.MinFrequencyHz); fDraft.MaxFrequencyHz:=FloatValue(fMaxX,fDraft.MaxFrequencyHz); fDraft.LegendVisible:=fLegend.Checked; fDraft.LogFrequency:=fLogX.Checked;
  if IsNan(fDraft.MinFrequencyHz) or IsInfinite(fDraft.MinFrequencyHz) or
    IsNan(fDraft.MaxFrequencyHz) or IsInfinite(fDraft.MaxFrequencyHz) or
    (fDraft.MaxFrequencyHz<=fDraft.MinFrequencyHz) or
    (fDraft.LogFrequency and (fDraft.MinFrequencyHz<=0)) then
  begin MessageDlg('Проверьте диапазон X: для логарифма min должен быть больше нуля.',mtError,[mbOK],0); Exit; end;
  for I:=0 to fDraft.AxisCount-1 do
    if IsNan(fDraft.Axes[I].MinValue) or IsInfinite(fDraft.Axes[I].MinValue) or
      IsNan(fDraft.Axes[I].MaxValue) or IsInfinite(fDraft.Axes[I].MaxValue) or
      (fDraft.Axes[I].MaxValue<=fDraft.Axes[I].MinValue) or
      (fDraft.Axes[I].Logarithmic and (fDraft.Axes[I].MinValue<=0)) then
    begin MessageDlg('Проверьте диапазон Y узла '+fDraft.Axes[I].Name+'. Для логарифма min должен быть больше нуля.',mtError,[mbOK],0); Exit; end;
  for I:=0 to fDraft.LineCount-1 do
    if IsNan(fDraft.Lines[I].FrequencyStepHz) or IsInfinite(fDraft.Lines[I].FrequencyStepHz) or
      (fDraft.Lines[I].UniformX and (fDraft.Lines[I].FrequencyStepHz<=0)) then
    begin MessageDlg('Для равномерного X задайте положительный шаг: '+fDraft.Lines[I].Name,mtError,[mbOK],0); Exit; end;
  fComp.Assign(fDraft); ModalResult:=mrOk;
end;

end.
