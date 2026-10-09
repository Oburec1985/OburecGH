unit uRecorder3dVertexColorModifierFrame;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, ExtCtrls, Spin, ColorBox,
  uRecorder3dModel, uRecorderTags, u3dVertexColors;

type
  TRecorder3dVertexColorModifierFrame=class(TFrame)
  published
    lblGradients,lblGradientName,lblLeft,lblRight,lblAnchors,lblAnchorName,
      lblRadius,lblFalloff,lblExponent,lblGradient,lblTagSearch,lblTag,
      lblEstimate,lblStatus:TLabel;
    lbGradients,lbAnchors:TListBox;
    btnAddGradient,btnDeleteGradient,btnAddAnchor,btnDeleteAnchor:TButton;
    edGradientName,edAnchorName,edTagSearch:TEdit;
    cbLeftColor,cbRightColor:TColorBox;
    seLeftValue,seRightValue,seRadius,seExponent:TFloatSpinEdit;
    cbFalloff,cbGradient,cbTag,cbEstimate:TComboBox;
    chkUseDefaultEstimate,chkEnabled,chkApplyColor,chkShowValueLabel:TCheckBox;
    procedure GradientSelectionChange(Sender:TObject);
    procedure AnchorSelectionChange(Sender:TObject);
    procedure AddGradientClick(Sender:TObject);
    procedure DeleteGradientClick(Sender:TObject);
    procedure AddAnchorClick(Sender:TObject);
    procedure DeleteAnchorClick(Sender:TObject);
    procedure GradientPropertyChange(Sender:TObject);
    procedure AnchorPropertyChange(Sender:TObject);
    procedure TagChange(Sender:TObject);
    procedure TagSearchChange(Sender:TObject);
  private
    fComponent:TRecorder3dComponent;
    fRegistry:TRecorderTagRegistry;
    fMeshNodeId:QWord;
    fLogicalVertexId:LongWord;
    fHasVertex,fLoading:Boolean;
    fOnChanged:TNotifyEvent;
    function SelectedGradient:TRecorder3dGradientStrip;
    function SelectedAnchor:TRecorder3dVertexColorAnchor;
    function NextGradientId:QWord;
    function NextAnchorId:QWord;
    procedure ReloadGradients(AKeepId:QWord=0);
    procedure ReloadAnchors(AKeepId:QWord=0);
    procedure ReloadGradientCombo;
    procedure ReloadTags;
    procedure ReloadEstimates;
    procedure LoadGradient;
    procedure LoadAnchor;
    procedure UpdateActions;
    procedure Changed;
  public
    constructor Create(AOwner:TComponent); override;
    procedure Configure(AComponent:TRecorder3dComponent;
      ARegistry:TRecorderTagRegistry);
    procedure SetSelectedVertex(AMeshNodeId:QWord;
      ALogicalVertexId:LongWord; AHasVertex:Boolean);
    procedure Reload;
    property OnChanged:TNotifyEvent read fOnChanged write fOnChanged;
  end;

implementation

uses Math, LazUTF8;

{$R *.lfm}

constructor TRecorder3dVertexColorModifierFrame.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  cbFalloff.Items.Add('Линейный');
  cbFalloff.Items.Add('Плавный');
  cbFalloff.Items.Add('Степенной');
  cbFalloff.ItemIndex:=0;
  UpdateActions;
end;

procedure TRecorder3dVertexColorModifierFrame.ReloadEstimates;
var
  A:TRecorder3dVertexColorAnchor;
  T:TRecorderTag;
  K:TRecorderTagEstimateKind;
  SelectedIndex:Integer;
begin
  A:=SelectedAnchor;
  T:=nil;
  if (A<>nil) and (fRegistry<>nil) then
    T:=RecorderResolveTagReference(fRegistry,A.TagId,A.TagName);
  cbEstimate.Items.Clear;
  SelectedIndex:=-1;
  if (T<>nil) and T.IsVector then
    for K:=Low(K) to High(K) do
      if T.EstimateSettings.EnabledKinds[K] or
        ((A<>nil) and not A.UseDefaultEstimate and (A.EstimateKind=K)) then
      begin
        if T.EstimateSettings.EnabledKinds[K] then
          cbEstimate.Items.AddObject(RecorderTagEstimateKindToName(K),
            TObject(PtrUInt(Ord(K)+1)))
        else
          cbEstimate.Items.AddObject(RecorderTagEstimateKindToName(K)+
            ' (недоступна)',TObject(PtrUInt(Ord(K)+1)));
        if (A<>nil) and (A.EstimateKind=K) then
          SelectedIndex:=cbEstimate.Items.Count-1;
      end;
  cbEstimate.ItemIndex:=SelectedIndex;
end;

function TRecorder3dVertexColorModifierFrame.SelectedGradient:TRecorder3dGradientStrip;
begin
  Result:=nil;
  if (fComponent<>nil) and (lbGradients.ItemIndex>=0) then
    Result:=fComponent.FindGradientStrip(QWord(PtrUInt(
      lbGradients.Items.Objects[lbGradients.ItemIndex])));
end;

function TRecorder3dVertexColorModifierFrame.SelectedAnchor:TRecorder3dVertexColorAnchor;
var I:Integer; Id:QWord;
begin
  Result:=nil;
  if (fComponent=nil) or (lbAnchors.ItemIndex<0) then Exit;
  Id:=QWord(PtrUInt(lbAnchors.Items.Objects[lbAnchors.ItemIndex]));
  for I:=0 to fComponent.VertexColorAnchorCount-1 do
    if fComponent.VertexColorAnchors[I].Id=Id then Exit(fComponent.VertexColorAnchors[I]);
end;

function TRecorder3dVertexColorModifierFrame.NextGradientId:QWord;
var I:Integer;
begin Result:=1; if fComponent<>nil then for I:=0 to fComponent.GradientStripCount-1 do Result:=Max(Result,fComponent.GradientStrips[I].Id+1); end;
function TRecorder3dVertexColorModifierFrame.NextAnchorId:QWord;
var I:Integer;
begin Result:=1; if fComponent<>nil then for I:=0 to fComponent.VertexColorAnchorCount-1 do Result:=Max(Result,fComponent.VertexColorAnchors[I].Id+1); end;

procedure TRecorder3dVertexColorModifierFrame.Configure(AComponent:TRecorder3dComponent; ARegistry:TRecorderTagRegistry);
begin fComponent:=AComponent; fRegistry:=ARegistry; Reload; end;

procedure TRecorder3dVertexColorModifierFrame.SetSelectedVertex(AMeshNodeId:QWord; ALogicalVertexId:LongWord; AHasVertex:Boolean);
begin fMeshNodeId:=AMeshNodeId; fLogicalVertexId:=ALogicalVertexId; fHasVertex:=AHasVertex; UpdateActions; end;

procedure TRecorder3dVertexColorModifierFrame.Reload;
begin fLoading:=True; try ReloadGradients; ReloadAnchors; finally fLoading:=False; end; LoadGradient; LoadAnchor; UpdateActions; end;

procedure TRecorder3dVertexColorModifierFrame.ReloadGradients(AKeepId:QWord);
var I,S:Integer; G:TRecorder3dGradientStrip;
begin
  if (AKeepId=0) and (SelectedGradient<>nil) then AKeepId:=SelectedGradient.Id;
  lbGradients.Items.Clear; S:=-1;
  if fComponent<>nil then for I:=0 to fComponent.GradientStripCount-1 do begin G:=fComponent.GradientStrips[I]; lbGradients.Items.AddObject(G.Name,TObject(PtrUInt(G.Id))); if G.Id=AKeepId then S:=I; end;
  if (S<0) and (lbGradients.Count>0) then S:=0; lbGradients.ItemIndex:=S; ReloadGradientCombo;
end;

procedure TRecorder3dVertexColorModifierFrame.ReloadAnchors(AKeepId:QWord);
var I,S:Integer; A:TRecorder3dVertexColorAnchor;
begin
  if (AKeepId=0) and (SelectedAnchor<>nil) then AKeepId:=SelectedAnchor.Id;
  lbAnchors.Items.Clear; S:=-1;
  if fComponent<>nil then for I:=0 to fComponent.VertexColorAnchorCount-1 do begin A:=fComponent.VertexColorAnchors[I]; lbAnchors.Items.AddObject(A.Name,TObject(PtrUInt(A.Id))); if A.Id=AKeepId then S:=I; end;
  if (S<0) and (lbAnchors.Count>0) then S:=0; lbAnchors.ItemIndex:=S;
end;

procedure TRecorder3dVertexColorModifierFrame.ReloadGradientCombo;
var I,S:Integer; A:TRecorder3dVertexColorAnchor; G:TRecorder3dGradientStrip;
begin
  A:=SelectedAnchor; S:=-1; cbGradient.Items.Clear;
  if fComponent<>nil then for I:=0 to fComponent.GradientStripCount-1 do begin G:=fComponent.GradientStrips[I]; cbGradient.Items.AddObject(G.Name,TObject(PtrUInt(G.Id))); if (A<>nil) and (A.GradientId=G.Id) then S:=I; end;
  cbGradient.ItemIndex:=S;
end;

procedure TRecorder3dVertexColorModifierFrame.ReloadTags;
var I,S:Integer; A:TRecorder3dVertexColorAnchor; T:TRecorderTag; Filter,SearchText,TagCaption:string;
begin
  A:=SelectedAnchor; S:=0; Filter:=UTF8LowerCase(Trim(edTagSearch.Text));
  cbTag.Items.Clear; cbTag.Items.AddObject('(нет)',nil);
  if fRegistry<>nil then for I:=0 to fRegistry.TagCount-1 do begin T:=fRegistry.Tags[I]; SearchText:=UTF8LowerCase(T.Name+' '+T.Address+' '+T.Description); if (Filter<>'') and (Pos(Filter,SearchText)=0) then Continue; TagCaption:=T.Name; if Trim(T.Address)<>'' then TagCaption:=TagCaption+' — '+T.Address; cbTag.Items.AddObject(TagCaption,T); if (A<>nil) and (A.TagId=T.Id) then S:=cbTag.Items.Count-1; end;
  cbTag.ItemIndex:=S;
end;

procedure TRecorder3dVertexColorModifierFrame.LoadGradient;
var G:TRecorder3dGradientStrip;
begin fLoading:=True; try G:=SelectedGradient; if G=nil then begin edGradientName.Clear; Exit; end; edGradientName.Text:=G.Name; cbLeftColor.Selected:=G.LeftColor; cbRightColor.Selected:=G.RightColor; seLeftValue.Value:=G.LeftValue; seRightValue.Value:=G.RightValue; finally fLoading:=False; end; UpdateActions; end;

procedure TRecorder3dVertexColorModifierFrame.LoadAnchor;
var A:TRecorder3dVertexColorAnchor;
begin fLoading:=True; try A:=SelectedAnchor; ReloadGradientCombo; ReloadTags; ReloadEstimates; if A=nil then begin edAnchorName.Clear; Exit; end; edAnchorName.Text:=A.Name; seRadius.Value:=A.Radius; seExponent.Value:=A.FalloffExponent; cbFalloff.ItemIndex:=Ord(A.Falloff); chkUseDefaultEstimate.Checked:=A.UseDefaultEstimate; chkEnabled.Checked:=A.Enabled; chkApplyColor.Checked:=A.ApplyColor; chkShowValueLabel.Checked:=A.ShowValueLabel; finally fLoading:=False; end; UpdateActions; end;

procedure TRecorder3dVertexColorModifierFrame.UpdateActions;
var HasG,HasA,HasTag,VectorTag:Boolean; A:TRecorder3dVertexColorAnchor; T:TRecorderTag; E:TRecorderTagEstimate;
begin HasG:=SelectedGradient<>nil; HasA:=SelectedAnchor<>nil; A:=SelectedAnchor; T:=nil; if (A<>nil) and (fRegistry<>nil) then T:=RecorderResolveTagReference(fRegistry,A.TagId,A.TagName); HasTag:=T<>nil; VectorTag:=HasTag and T.IsVector; btnDeleteGradient.Enabled:=HasG; btnAddAnchor.Enabled:=fHasVertex and (fComponent<>nil) and (fComponent.GradientStripCount>0); btnDeleteAnchor.Enabled:=HasA; edGradientName.Enabled:=HasG; cbLeftColor.Enabled:=HasG; cbRightColor.Enabled:=HasG; seLeftValue.Enabled:=HasG; seRightValue.Enabled:=HasG; edAnchorName.Enabled:=HasA; seRadius.Enabled:=HasA; seExponent.Enabled:=HasA and (cbFalloff.ItemIndex=Ord(vcfExponent)); cbFalloff.Enabled:=HasA; cbGradient.Enabled:=HasA; edTagSearch.Enabled:=HasA; cbTag.Enabled:=HasA; chkUseDefaultEstimate.Enabled:=HasA and VectorTag; cbEstimate.Enabled:=HasA and VectorTag and not chkUseDefaultEstimate.Checked; chkEnabled.Enabled:=HasA; chkApplyColor.Enabled:=HasA; chkShowValueLabel.Enabled:=HasA; if not fHasVertex then lblStatus.Caption:='Выберите вершину' else if not HasG then lblStatus.Caption:='Сначала создайте градиент' else if not HasA then lblStatus.Caption:='Добавьте цветовой якорь' else if not HasTag then lblStatus.Caption:='Выберите тег' else if not VectorTag then lblStatus.Caption:='Используется текущее значение' else begin if A.UseDefaultEstimate then E:=T.Estimate(T.EstimateSettings.DefaultKind) else E:=T.Estimate(A.EstimateKind); if E.Valid then lblStatus.Caption:='Оценка готова' else lblStatus.Caption:='Нет данных выбранной оценки'; end; end;

procedure TRecorder3dVertexColorModifierFrame.Changed;
begin if Assigned(fOnChanged) then fOnChanged(Self); end;
procedure TRecorder3dVertexColorModifierFrame.GradientSelectionChange(Sender:TObject); begin if not fLoading then LoadGradient; end;
procedure TRecorder3dVertexColorModifierFrame.AnchorSelectionChange(Sender:TObject); begin if not fLoading then LoadAnchor; end;

procedure TRecorder3dVertexColorModifierFrame.AddGradientClick(Sender:TObject);
var G:TRecorder3dGradientStrip;
begin if fComponent=nil then Exit; G:=fComponent.AddGradientStrip; G.Id:=NextGradientId; G.Name:='Градиент '+IntToStr(G.Id); ReloadGradients(G.Id); LoadGradient; Changed; end;
procedure TRecorder3dVertexColorModifierFrame.DeleteGradientClick(Sender:TObject);
var I:Integer; G:TRecorder3dGradientStrip;
begin G:=SelectedGradient; if G=nil then Exit; for I:=fComponent.GradientStripCount-1 downto 0 do if fComponent.GradientStrips[I]=G then fComponent.DeleteGradientStrip(I); Reload; Changed; end;
procedure TRecorder3dVertexColorModifierFrame.AddAnchorClick(Sender:TObject);
var A:TRecorder3dVertexColorAnchor; G:TRecorder3dGradientStrip;
begin if (fComponent=nil) or not fHasVertex then Exit; G:=SelectedGradient; if G=nil then Exit; A:=fComponent.AddVertexColorAnchor; A.Id:=NextAnchorId; A.Name:='Якорь '+IntToStr(A.Id); A.MeshNodeId:=fMeshNodeId; A.LogicalVertexId:=fLogicalVertexId; A.GradientId:=G.Id; ReloadAnchors(A.Id); LoadAnchor; Changed; end;
procedure TRecorder3dVertexColorModifierFrame.DeleteAnchorClick(Sender:TObject);
var I:Integer; A:TRecorder3dVertexColorAnchor;
begin A:=SelectedAnchor; if A=nil then Exit; for I:=fComponent.VertexColorAnchorCount-1 downto 0 do if fComponent.VertexColorAnchors[I]=A then fComponent.DeleteVertexColorAnchor(I); ReloadAnchors; LoadAnchor; Changed; end;

procedure TRecorder3dVertexColorModifierFrame.GradientPropertyChange(Sender:TObject);
var G:TRecorder3dGradientStrip; Id:QWord;
begin if fLoading then Exit; G:=SelectedGradient; if G=nil then Exit; G.Name:=edGradientName.Text; G.LeftColor:=cbLeftColor.Selected; G.RightColor:=cbRightColor.Selected; G.LeftValue:=seLeftValue.Value; G.RightValue:=seRightValue.Value; Id:=G.Id; ReloadGradients(Id); Changed; end;
procedure TRecorder3dVertexColorModifierFrame.AnchorPropertyChange(Sender:TObject);
var A:TRecorder3dVertexColorAnchor;
begin if fLoading then Exit; A:=SelectedAnchor; if A=nil then Exit; A.Name:=edAnchorName.Text; A.Radius:=seRadius.Value; A.FalloffExponent:=seExponent.Value; if cbFalloff.ItemIndex>=0 then A.Falloff:=T3dVertexColorFalloff(cbFalloff.ItemIndex); if cbGradient.ItemIndex>=0 then A.GradientId:=QWord(PtrUInt(cbGradient.Items.Objects[cbGradient.ItemIndex])); A.UseDefaultEstimate:=chkUseDefaultEstimate.Checked; if cbEstimate.ItemIndex>=0 then A.EstimateKind:=TRecorderTagEstimateKind(PtrUInt(cbEstimate.Items.Objects[cbEstimate.ItemIndex])-1); A.Enabled:=chkEnabled.Checked; A.ApplyColor:=chkApplyColor.Checked; A.ShowValueLabel:=chkShowValueLabel.Checked; ReloadAnchors(A.Id); UpdateActions; Changed; end;
procedure TRecorder3dVertexColorModifierFrame.TagChange(Sender:TObject);
var A:TRecorder3dVertexColorAnchor; T:TRecorderTag;
begin if fLoading then Exit; A:=SelectedAnchor; if A=nil then Exit; T:=nil; if cbTag.ItemIndex>=0 then T:=TRecorderTag(cbTag.Items.Objects[cbTag.ItemIndex]); if T=nil then begin A.TagId:=0; A.TagName:=''; end else begin A.TagId:=T.Id; A.TagName:=T.Name; end; fLoading:=True; try ReloadEstimates; finally fLoading:=False; end; Changed; UpdateActions; end;
procedure TRecorder3dVertexColorModifierFrame.TagSearchChange(Sender:TObject); begin if not fLoading then begin fLoading:=True; try ReloadTags; finally fLoading:=False; end; end; end;

end.
