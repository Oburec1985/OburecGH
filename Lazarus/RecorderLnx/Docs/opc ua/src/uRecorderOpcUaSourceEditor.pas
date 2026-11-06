unit uRecorderOpcUaSourceEditor;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

implementation

uses
  Classes, SysUtils, Math, DateUtils, Forms, Controls, StdCtrls, ExtCtrls, Dialogs,
  ComCtrls, Grids, Contnrs, Graphics, ImgList, Menus, LazUTF8, LCLType,
  uRecorderTags, uRecorderDataSources, uRecorderMessages,
  uRecorderConfiguredDataSources,
  uRecorderConfiguredSourceEditor, uRecorderOpcUaTypes, uRecorderOpcUaApi,
  uRecorderHardwareLiveDevices, uRecorderOpcUaDiscovery;

type
  TRecorderOpcUaProbeOperation = (opoTest, opoBrowse, opoBrowseChildren,
    opoRead, opoDiscover);
  TRecorderOpcUaNameOperation = (onoRemove, onoAdd);

  TRecorderOpcUaNameOperationDialog = class(TForm)
  private
    fOperationGroup: TRadioGroup;
    fNameText: TEdit;
    fPreview: TLabel;
    fOriginalName: string;
    procedure UpdatePreview(Sender: TObject);
  public
    constructor CreateDialog(AOwner: TComponent; const AOriginalName,
      AInitialText: string);
    function Execute(out AOperation: TRecorderOpcUaNameOperation;
      out AText: string): Boolean;
  end;

  TRecorderOpcUaTreeItem = class
  public
    BrowsePath: string;
    NodeId: string;
    TagName: string;
    TypeDefinition: string;
    Readable: Boolean;
    IsProperty: Boolean;
    Writable: Boolean;
    DataTypeNodeId: string;
    DataTypeName: string;
    ValueText: string;
    ValueTimestamp: string;
    ArrayValues: TStringList;
    ValueRank: Integer;
    NodeClass: Cardinal;
    Historizing: Boolean;
    HistoryReadable: Boolean;
    HistoryWritable: Boolean;
    ArrayParent: TRecorderOpcUaTreeItem;
    IsIndexedArrayElement: Boolean;
    HasIndexedChildren: Boolean;
    TreeNode: TTreeNode;
    constructor Create;
    destructor Destroy; override;
  end;

  TRecorderOpcUaUsedItem = class
  public
    NodeId: string;
    TreeNode: TTreeNode;
  end;

  TRecorderOpcUaProbeThread = class(TThread)
  private
    fEndpoint: string;
    fErrorText: string;
    fBrowseNodeId: string;
    fBrowsePath: string;
    fInputNodeIds: TStringList;
    fInputTagNames: TStringList;
    fLines: TStringList;
    fOperation: TRecorderOpcUaProbeOperation;
    fPassword: string;
    fSessionTimeoutMs: Cardinal;
    fMaxReferencesPerNode: Cardinal;
    fRequestTimeoutMs: Cardinal;
    fBrowseTimeoutMs: Cardinal;
    fTimestampsToReturn: Cardinal;
    fUserName: string;
    fElapsedMs: QWord;
    fSucceeded: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(const AEndpoint, AUserName, APassword: string;
      AOperation: TRecorderOpcUaProbeOperation; ANodeIds: TStrings = nil;
      ATagNames: TStrings = nil;
      ASessionTimeoutMs: Cardinal = CRecorderOpcUaDefaultSessionTimeoutMs;
      AMaxReferencesPerNode: Cardinal = CRecorderOpcUaDefaultMaxNodesPerRequest;
      ARequestTimeoutMs: Cardinal = CRecorderOpcUaDefaultRequestTimeoutMs;
      ATimestampsToReturn: Cardinal = Ord(outServer);
      ABrowseTimeoutMs: Cardinal = CRecorderOpcUaDefaultBrowseTimeoutMs;
      const ABrowseNodeId: string = ''; const ABrowsePath: string = '');
    destructor Destroy; override;
    property Operation: TRecorderOpcUaProbeOperation read fOperation;
    property ElapsedMs: QWord read fElapsedMs;
    property ErrorText: string read fErrorText;
    property Lines: TStringList read fLines;
    property Succeeded: Boolean read fSucceeded;
  end;

  {$M+}
  TRecorderOpcUaEditorForm = class(TForm)
  published
    fAuth: TComboBox;
    fBrowseButton: TButton;
    fInteractiveBrowseButton: TButton;
    fBrowsePopup: TPopupMenu;
    fBrowseTree: TTreeView;
    fCancelButton: TButton;
    fDiagnostics: TMemo;
    fEndpoint: TEdit;
    fDiscoveryButton: TButton;
    fInterval: TEdit;
    fSessionTimeout: TEdit;
    fMode: TComboBox;
    fNodes: TMemo; { compatibility field for the retired programmatic layout }
    fOkButton: TButton;
    fPassword: TEdit;
    fProbeButton: TButton;
    fReadButton: TButton;
    fAddSelectedMenuItem: TMenuItem;
    fSimplifiedTree: TCheckBox;
    fTreeSearch: TEdit;
    fUsedSearch: TEdit;
    fPropertiesGrid: TStringGrid;
    fProtocolSettings: TStringGrid;
    fUsedTree: TTreeView;
    fUsedContentPanel: TPanel;
    fUsedPropertiesSplitter: TSplitter;
    fUsedPropertiesGrid: TStringGrid;
    fUsedPropertiesHost: TPanel;
    fSelectedNameEdit: TEdit;
    fEditNamesButton: TButton;
    fAddConnectionAddressCheck: TCheckBox;
    fDetailsPages: TPageControl;
    fPropertiesTab: TTabSheet;
    fUsedTab: TTabSheet;
    fUserName: TEdit;
    fValueGrid: TStringGrid;
    fNodeImages: TImageList;
    fConfigPanel: TPanel;
    fWorkspacePanel: TPanel;
    fTreePanel: TPanel;
    fDiagnosticsPanel: TPanel;
    fConfigSplitter: TSplitter;
    fBrowserSplitter: TSplitter;
    procedure BrowseTreeDblClick(Sender: TObject);
    procedure BrowseTreeSelectionChanged(Sender: TObject);
    procedure BrowseTreeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BrowseTreeStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure BrowsePopupPopup(Sender: TObject);
    procedure AddSelectedMenuClick(Sender: TObject);
    procedure AuthChange(Sender: TObject);
    procedure BrowseClick(Sender: TObject);
    procedure InteractiveBrowseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure ModeChange(Sender: TObject);
    procedure ProbeClick(Sender: TObject);
    procedure DiscoveryClick(Sender: TObject);
    procedure ProbeFinished(Sender: TObject);
    procedure ProtocolSettingsSelectEditor(Sender: TObject; ACol, ARow: Integer;
      var Editor: TWinControl);
    procedure ProtocolSettingsSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure PropertiesGridEditingDone(Sender: TObject);
    procedure PropertiesGridSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure RebuildBrowseTree(ASelectedNodeIds: TStrings = nil);
    procedure CaptureBrowseSelection(ANodeIds: TStrings);
    procedure SetProbeRunning(ARunning: Boolean);
    procedure SimplifiedTreeChange(Sender: TObject);
    procedure TreeSearchChange(Sender: TObject);
    procedure UsedSearchChange(Sender: TObject);
    procedure UsedTreeSelectionChanged(Sender: TObject);
    procedure UsedPropertiesGridEditingDone(Sender: TObject);
    procedure UsedPropertiesGridSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
    procedure EditNamesClick(Sender: TObject);
    procedure AddConnectionAddressChange(Sender: TObject);
    procedure UsedTreeDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure UsedTreeDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure UsedTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure UsedTreeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UsedTreeMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure UsedTreeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ReadClick(Sender: TObject);
  private
    fProbeThread: TRecorderOpcUaProbeThread;
    fBrowseCache: TStringList;
    fBrowseCacheEndpoint: string;
    fInteractiveBrowse: Boolean;
    fInteractiveParentNodeId: string;
    fRegistry: TRecorderTagRegistry;
    fSourceId: string;
    fTreeItems: TObjectList;
    fUsedItems: TObjectList;
    fAutoBrowsePending: Boolean;
    fDragSelectionHasUsableItem: Boolean;
    fUsedMouseAnchor: TTreeNode;
    fUsedMouseDownY: Integer;
    fUsedMouseSelecting: Boolean;
    fUpdatingProperties: Boolean;
    fUpdatingUsedProperties: Boolean;
    fUpdatingAddressCheck: Boolean;
    fCommonNameSubstring: string;
    function AppendTagRow(AItem: TRecorderOpcUaTreeItem): Integer;
    procedure AddTreeItemToGrid(AItem: TRecorderOpcUaTreeItem);
    procedure AddSelectedTreeNode;
    procedure AddSelectedTreeNodes;
    procedure CollectUsableTreeItems(ANode: TTreeNode; AItems: TList;
      ANodeIds: TStrings);
    procedure BuildSelectedUsableTreeItems(AItems: TList);
    function TreeNodeContainsUsableItem(ANode: TTreeNode): Boolean;
    function SelectionContainsUsableItem: Boolean;
    procedure AddDiagnostic(const AText: string);
    function AddOrFindTagRow(AItem: TRecorderOpcUaTreeItem): Integer;
    function FindTagRow(AItem: TRecorderOpcUaTreeItem): Integer;
    function FindTagRowByNodeId(const ANodeId: string): Integer;
    procedure BuildReadInputs(out ANodeIds, ATagNames: TStringList);
    function DataTypeImageIndex(const ADataTypeNodeId: string;
      AValueRank: Integer): Integer;
    function ItemMatchesSearch(AItem: TRecorderOpcUaTreeItem): Boolean;
    function ItemOrDescendantMatchesSearch(
      AItem: TRecorderOpcUaTreeItem): Boolean;
    function UsedItemMatchesSearch(AItem: TRecorderOpcUaTreeItem;
      const ATagName, ANodeId: string): Boolean;
    procedure InitializeNodeImages;
    procedure LinkIndexedArrayItems;
    procedure LoadBrowseLines(ALines: TStrings);
    procedure AppendBrowseLines(ALines: TStrings);
    procedure AppendBrowseCacheLines(ALines: TStrings);
    procedure LoadConfiguredNodesAsOfflineTree;
    function FindTreeItemByNodeId(const ANodeId: string): TRecorderOpcUaTreeItem;
    procedure RebuildUsedTree;
    function UsedTreeNodeKey(ANode: TTreeNode): string;
    procedure CaptureUsedTreeState(AExpandedKeys, ASelectedKeys: TStrings;
      out AFocusedKey, ATopKey: string);
    procedure RestoreUsedTreeState(AExpandedKeys, ASelectedKeys: TStrings;
      const AFocusedKey, ATopKey: string);
    procedure CollectUsedNodeIds(ANode: TTreeNode; ANodeIds: TStrings);
    procedure SelectUsedVisibleRange(AFirst, ALast: TTreeNode);
    procedure RemoveSelectedUsedChannels;
    procedure ShowSelectedNodeProperties;
    procedure ShowSelectedUsedProperties;
    procedure ApplyNameOperationToSelected(AOperation: TRecorderOpcUaNameOperation;
      const AText: string);
    function SelectedUsableTreeNodeCount: Integer;
    function SelectedTagCount: Integer;
    procedure ExpandConfiguredTreeNodes;
    procedure StartProbe(AOperation: TRecorderOpcUaProbeOperation;
      const ABrowseNodeId: string = ''; const ABrowsePath: string = '');
    procedure UpdateControlState;
  public
    constructor CreateEditor(AOwner: TComponent; AConfig: TRecorderOpcUaConfig;
      ARegistry: TRecorderTagRegistry; const ASourceId: string);
    destructor Destroy; override;
    procedure SaveToConfig(AConfig: TRecorderOpcUaConfig);
  end;
  {$M-}

{$R *.lfm}

  TRecorderOpcUaSourceEditor = class(TInterfacedObject,
    IRecorderConfiguredSourceEditor)
  public
    function SupportsSource(const ASourceId, AModuleType: string): Boolean;
    function EditSource(AOwner: TComponent; ARegistry: TRecorderTagRegistry;
      const ASourceId: string; out ANewSourceId: string;
      ADataSources: TRecorderDataSourceManager): Boolean;
  end;

const
  CProtocolRowReceive = 0;
  CProtocolRowMode = 1;
  CProtocolRowInterval = 2;
  CProtocolRowMaxRead = 3;
  CProtocolRowTimestamp = 4;
  CProtocolRowWrite = 5;
  CProtocolRowMaxWrite = 6;
  CProtocolRowBrowse = 7;
  CProtocolRowMaxBrowse = 8;
  CProtocolRowBrowseTimeout = 9;
  CProtocolRowConnection = 10;
  CProtocolRowTimeout = 11;
  CProtocolRowSubscription = 12;
  CProtocolRowArchive = 13;

function CompactOpcUaNodeAddress(const ANodeId: string): string; forward;

function WrapOpcUaPreviewName(const AName: string): string;
var
  lRemaining, lChunk: string;
begin
  Result := '';
  lRemaining := AName;
  while UTF8Length(lRemaining) > 62 do
  begin
    lChunk := UTF8Copy(lRemaining, 1, 62);
    if Result <> '' then Result := Result + LineEnding;
    Result := Result + lChunk;
    Delete(lRemaining, 1, Length(lChunk));
  end;
  if Result <> '' then Result := Result + LineEnding;
  Result := Result + lRemaining;
end;

function StripOuterNameDots(const AName: string): string;
begin
  Result := Trim(AName);
  while (Result <> '') and (Result[1] = '.') do Delete(Result, 1, 1);
  while (Result <> '') and (Result[Length(Result)] = '.') do
    Delete(Result, Length(Result), 1);
end;

constructor TRecorderOpcUaNameOperationDialog.CreateDialog(AOwner: TComponent;
  const AOriginalName, AInitialText: string);
var
  lLabel: TLabel;
  lButton: TButton;
begin
  inherited CreateNew(AOwner, 1);
  Caption := 'Редактирование имён тегов';
  Position := poOwnerFormCenter;
  BorderStyle := bsDialog;
  Width := 536;
  Height := 300;
  Constraints.MinWidth := 536;
  Constraints.MinHeight := 300;
  fOriginalName := AOriginalName;

  fOperationGroup := TRadioGroup.Create(Self);
  fOperationGroup.Parent := Self;
  fOperationGroup.SetBounds(12, 8, 490, 64);
  fOperationGroup.Caption := 'Операция';
  fOperationGroup.Columns := 2;
  fOperationGroup.Items.Add('Удалить подстроку');
  fOperationGroup.Items.Add('Добавить перед именем');
  fOperationGroup.ItemIndex := 0;
  fOperationGroup.OnClick := @UpdatePreview;

  lLabel := TLabel.Create(Self);
  lLabel.Parent := Self;
  lLabel.SetBounds(16, 78, 150, 18);
  lLabel.Caption := 'Подстрока';

  fNameText := TEdit.Create(Self);
  fNameText.Parent := Self;
  fNameText.SetBounds(12, 98, 490, 26);
  fNameText.Anchors := [akLeft, akTop, akRight];
  fNameText.Text := AInitialText;
  fNameText.OnChange := @UpdatePreview;

  fPreview := TLabel.Create(Self);
  fPreview.Parent := Self;
  fPreview.SetBounds(12, 130, 490, 100);
  fPreview.Anchors := [akLeft, akTop, akRight];
  fPreview.AutoSize := False;
  fPreview.WordWrap := True;
  fPreview.ShowHint := True;

  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(330, 240, 80, 28);
  lButton.Anchors := [akRight, akBottom];
  lButton.Caption := 'Выполнить';
  lButton.ModalResult := mrOk;
  lButton.Default := True;

  lButton := TButton.Create(Self);
  lButton.Parent := Self;
  lButton.SetBounds(420, 240, 80, 28);
  lButton.Anchors := [akRight, akBottom];
  lButton.Caption := 'Отмена';
  lButton.ModalResult := mrCancel;
  lButton.Cancel := True;
  UpdatePreview(nil);
end;

procedure TRecorderOpcUaNameOperationDialog.UpdatePreview(Sender: TObject);
var
  lText, lResult: string;
begin
  lText := Trim(fNameText.Text);
  if (Length(lText) >= 3) and
    (Copy(lText, Length(lText) - 2, 3) = '***') then
    Delete(lText, Length(lText) - 2, 3);
  lResult := fOriginalName;
  if lText <> '' then
    if fOperationGroup.ItemIndex = 0 then
      lResult := StripOuterNameDots(
        StringReplace(lResult, lText, '', [rfReplaceAll]))
    else if Copy(lResult, 1, Length(lText)) <> lText then
      lResult := lText + lResult;
  fPreview.Caption := WrapOpcUaPreviewName(fOriginalName) + LineEnding +
    '>>> ' + WrapOpcUaPreviewName(lResult);
  fPreview.Hint := fPreview.Caption;
end;

function TRecorderOpcUaNameOperationDialog.Execute(
  out AOperation: TRecorderOpcUaNameOperation; out AText: string): Boolean;
var
  lText: string;
begin
  Result := ShowModal = mrOk;
  if not Result then Exit;
  AOperation := onoRemove;
  if fOperationGroup.ItemIndex = 1 then AOperation := onoAdd;
  lText := Trim(fNameText.Text);
  if (Length(lText) >= 3) and
    (Copy(lText, Length(lText) - 2, 3) = '***') then
    Delete(lText, Length(lText) - 2, 3);
  AText := lText;
end;

function SelectDiscoveredOpcUaEndpoint(AOwner: TComponent;
  AEndpoints: TStrings): string;
var
  lDialog: TForm;
  lPrompt: TLabel;
  lEndpointList: TComboBox;
  lOkButton, lCancelButton: TButton;
  I, lSeparator: Integer;
  lName, lEndpoint: string;
begin
  Result := '';
  if (AEndpoints = nil) or (AEndpoints.Count = 0) then Exit;
  lDialog := TForm.Create(AOwner);
  try
    lDialog.Caption := 'Найденные OPC UA серверы';
    lDialog.Position := poOwnerFormCenter;
    lDialog.BorderStyle := bsDialog;
    lDialog.ClientWidth := 620;
    lDialog.ClientHeight := 150;
    lDialog.Constraints.MinWidth := 500;
    lPrompt := TLabel.Create(lDialog);
    lPrompt.Parent := lDialog;
    lPrompt.Caption := 'Выберите сервер:';
    lPrompt.SetBounds(12, 12, 200, 20);
    lEndpointList := TComboBox.Create(lDialog);
    lEndpointList.Parent := lDialog;
    lEndpointList.Style := csDropDownList;
    lEndpointList.SetBounds(12, 38, 596, 28);
    lEndpointList.Anchors := [akLeft, akTop, akRight];
    for I := 0 to AEndpoints.Count - 1 do
    begin
      lSeparator := Pos(#9, AEndpoints[I]);
      if lSeparator > 0 then
      begin
        lName := Copy(AEndpoints[I], 1, lSeparator - 1);
        lEndpoint := Copy(AEndpoints[I], lSeparator + 1, MaxInt);
      end
      else
      begin
        lName := AEndpoints[I];
        lEndpoint := AEndpoints[I];
      end;
      lEndpointList.Items.Add(lName + ' — ' + lEndpoint);
    end;
    lEndpointList.ItemIndex := 0;
    lOkButton := TButton.Create(lDialog);
    lOkButton.Parent := lDialog;
    lOkButton.Caption := 'Выбрать';
    lOkButton.ModalResult := mrOk;
    lOkButton.Default := True;
    lOkButton.SetBounds(424, 102, 88, 30);
    lOkButton.Anchors := [akRight, akBottom];
    lCancelButton := TButton.Create(lDialog);
    lCancelButton.Parent := lDialog;
    lCancelButton.Caption := 'Отмена';
    lCancelButton.ModalResult := mrCancel;
    lCancelButton.Cancel := True;
    lCancelButton.SetBounds(520, 102, 88, 30);
    lCancelButton.Anchors := [akRight, akBottom];
    if lDialog.ShowModal = mrOk then
    begin
      I := lEndpointList.ItemIndex;
      if (I >= 0) and (I < AEndpoints.Count) then
      begin
        lSeparator := Pos(#9, AEndpoints[I]);
        if lSeparator > 0 then
          Result := Copy(AEndpoints[I], lSeparator + 1, MaxInt)
        else
          Result := AEndpoints[I];
      end;
    end;
  finally
    lDialog.Free;
  end;
end;

function OpcUaBrowsePathToRecorderName(const ABrowsePath: string): string;
begin
  Result := StringReplace(Trim(ABrowsePath), '/', '.', [rfReplaceAll]);
  while (Result <> '') and (Result[1] = '.') do
    Delete(Result, 1, 1);
  while (Result <> '') and (Result[Length(Result)] = '.') do
    Delete(Result, Length(Result), 1);
end;

function OpcUaBrowsePathToRecorderPrefix(const ABrowsePath: string): string;
var
  lPath: string;
  lLastSeparator: Integer;
begin
  lPath := Trim(ABrowsePath);
  lLastSeparator := LastDelimiter('/', lPath);
  if lLastSeparator > 0 then
    SetLength(lPath, lLastSeparator - 1)
  else
    lPath := '';
  Result := OpcUaBrowsePathToRecorderName(lPath);
end;

constructor TRecorderOpcUaTreeItem.Create;
begin
  inherited Create;
  ArrayValues := TStringList.Create;
end;

destructor TRecorderOpcUaTreeItem.Destroy;
begin
  ArrayValues.Free;
  inherited Destroy;
end;

function FindOpcUaTagByAddress(ARegistry: TRecorderTagRegistry;
  const AOldSourceId, ANewSourceId, AAddress: string): TRecorderTag;
var
  I: Integer;
  lTag: TRecorderTag;
begin
  Result := nil;
  for I := 0 to ARegistry.TagCount - 1 do
  begin
    lTag := ARegistry.Tags[I];
    if not SameText(Trim(lTag.Address), Trim(AAddress)) then
      Continue;
    if SameText(lTag.SourceId, ANewSourceId) or
      ((AOldSourceId <> '') and SameText(lTag.SourceId, AOldSourceId)) then
      Exit(lTag);
  end;
end;

function UniqueOpcUaTagName(ARegistry: TRecorderTagRegistry;
  const ARequestedName: string): string;
var
  lIndex: Integer;
  lStem: string;
begin
  lStem := Trim(ARequestedName);
  if lStem = '' then
    lStem := 'OPC UA channel';
  Result := lStem;
  if ARegistry.FindByName(Result) = nil then
    Exit;
  Result := lStem + ' [OPC UA]';
  lIndex := 2;
  while ARegistry.FindByName(Result) <> nil do
  begin
    Result := Format('%s [OPC UA %d]', [lStem, lIndex]);
    Inc(lIndex);
  end;
end;

function UniqueOpcUaSourceId(ARegistry: TRecorderTagRegistry;
  const ARequestedId, AOldSourceId: string): string;
var
  lIndex: Integer;
begin
  Result := ARequestedId;
  if SameText(Result, AOldSourceId) or
    (RecorderConfiguredDataSourcesFind(ARegistry, Result) = nil) then Exit;
  lIndex := 2;
  repeat
    Result := Format('%s [%d]', [ARequestedId, lIndex]);
    Inc(lIndex);
  until RecorderConfiguredDataSourcesFind(ARegistry, Result) = nil;
end;

procedure PublishOpcUaClientTags(ARegistry: TRecorderTagRegistry;
  AConfig: TRecorderOpcUaConfig; const AOldSourceId, ANewSourceId: string);
var
  I: Integer;
  lNode: TRecorderOpcUaNode;
  lTag: TRecorderTag;
begin
  if (ARegistry = nil) or (AConfig = nil) or
    (AConfig.Mode <> oumClient) then
    Exit;
  for I := 0 to AConfig.Nodes.Count - 1 do
  begin
    lNode := TRecorderOpcUaNode(AConfig.Nodes[I]);
    if lNode.RecorderTagId <> 0 then
      lTag := ARegistry.FindById(lNode.RecorderTagId)
    else
      lTag := nil;
    if lTag = nil then
      lTag := FindOpcUaTagByAddress(ARegistry, AOldSourceId, ANewSourceId,
        lNode.NodeId);
    if lTag = nil then
    begin
      lNode.TagName := UniqueOpcUaTagName(ARegistry, lNode.TagName);
      lTag := ARegistry.CreateTag(lNode.TagName, 4096);
    end
    else
    begin
      if (Trim(lNode.TagName) <> '') and
        not SameText(lNode.TagName, lTag.Name) and
        ((ARegistry.FindByName(Trim(lNode.TagName)) = nil) or
         (ARegistry.FindByName(Trim(lNode.TagName)) = lTag)) then
        ARegistry.RenameTag(lTag, Trim(lNode.TagName));
      lNode.TagName := lTag.Name;
    end;
    lNode.RecorderTagId := lTag.Id;
    lTag.SourceId := ANewSourceId;
    lTag.ModuleType := CRecorderOpcUaModuleType;
    lTag.Address := lNode.NodeId;
    lTag.ExternalWriteAllowed := lNode.Writable;
    lTag.PollFrequencyHz := 1000.0 / AConfig.PublishingIntervalMs;
  end;
end;

procedure AddLabel(AOwner: TComponent; AParent: TWinControl;
  const ACaption: string; ALeft, ATop: Integer);
var
  lLabel: TLabel;
begin
  lLabel := TLabel.Create(AOwner);
  lLabel.Parent := AParent;
  lLabel.Caption := ACaption;
  lLabel.Left := ALeft;
  lLabel.Top := ATop;
end;

constructor TRecorderOpcUaProbeThread.Create(const AEndpoint, AUserName,
  APassword: string; AOperation: TRecorderOpcUaProbeOperation;
  ANodeIds, ATagNames: TStrings; ASessionTimeoutMs,
  AMaxReferencesPerNode, ARequestTimeoutMs,
  ATimestampsToReturn, ABrowseTimeoutMs: Cardinal;
  const ABrowseNodeId, ABrowsePath: string);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fEndpoint := AEndpoint;
  fBrowseNodeId := ABrowseNodeId;
  fBrowsePath := ABrowsePath;
  fUserName := AUserName;
  fPassword := APassword;
  fOperation := AOperation;
  fSessionTimeoutMs := ASessionTimeoutMs;
  fMaxReferencesPerNode := Max(1, AMaxReferencesPerNode);
  fRequestTimeoutMs := Max(100, ARequestTimeoutMs);
  fBrowseTimeoutMs := Max(CRecorderOpcUaMinimumBrowseTimeoutMs,
    ABrowseTimeoutMs);
  fTimestampsToReturn := EnsureRange(ATimestampsToReturn, 0, 3);
  fInputNodeIds := TStringList.Create;
  fInputTagNames := TStringList.Create;
  if ANodeIds <> nil then fInputNodeIds.Assign(ANodeIds);
  if ATagNames <> nil then fInputTagNames.Assign(ATagNames);
  fLines := TStringList.Create;
end;

destructor TRecorderOpcUaProbeThread.Destroy;
begin
  fInputTagNames.Free;
  fInputNodeIds.Free;
  fLines.Free;
  inherited Destroy;
end;

procedure TRecorderOpcUaProbeThread.Execute;
var
  I, lIndex: Integer;
  lHandle: TRecorderOpcUaHandle;
  lLoadError: string;
  lNodeId, lTagName: string;
  lQuality: Cardinal;
  lStartedAt: QWord;
  lTime, lValue: Double;
begin
  lStartedAt := GetTickCount64;
  fSucceeded := False;
  try
    try
      if fOperation = opoDiscover then
      begin
        fSucceeded := RecorderOpcUaDiscoverMdns(fLines,
          CRecorderOpcUaDiscoveryTimeoutMs, fErrorText);
        Exit;
      end;
      if not RecorderOpcUaLoad(lLoadError) then
      begin
        fErrorText := lLoadError;
        Exit;
      end;
      lHandle := RecorderOpcUaClientCreate(fEndpoint, fUserName, fPassword,
        CRecorderOpcUaDefaultPublishingIntervalMs, fSessionTimeoutMs,
        fRequestTimeoutMs, fTimestampsToReturn, fBrowseTimeoutMs);
      if lHandle = nil then
      begin
        fErrorText := 'Не удалось создать OPC UA client session';
        Exit;
      end;
      try
        if not RecorderOpcUaClientConnect(lHandle) then
        begin
          fErrorText := RecorderOpcUaLastError(lHandle);
          Exit;
        end;
        case fOperation of
          opoBrowse:
            if not RecorderOpcUaClientBrowse(lHandle, fLines,
              fMaxReferencesPerNode) then
            begin
              fErrorText := RecorderOpcUaLastError(lHandle);
              Exit;
            end;
          opoBrowseChildren:
            if not RecorderOpcUaClientBrowseChildren(lHandle,
              fBrowseNodeId, fBrowsePath, fLines,
              fMaxReferencesPerNode) then
            begin
              fErrorText := RecorderOpcUaLastError(lHandle);
              Exit;
            end;
          opoRead:
            begin
              for I := 0 to fInputNodeIds.Count - 1 do
              begin
                lNodeId := Trim(fInputNodeIds[I]);
                if lNodeId = '' then Continue;
                lIndex := RecorderOpcUaClientAddNode(lHandle, lNodeId);
                if lIndex < 0 then
                begin
                  fErrorText := RecorderOpcUaLastError(lHandle);
                  Exit;
                end;
              end;
              if not RecorderOpcUaClientIterate(lHandle, 0) then
              begin
                fErrorText := RecorderOpcUaLastError(lHandle);
                Exit;
              end;
              for I := 0 to fInputNodeIds.Count - 1 do
              begin
                lNodeId := Trim(fInputNodeIds[I]);
                if I < fInputTagNames.Count then
                  lTagName := fInputTagNames[I]
                else
                  lTagName := lNodeId;
                if RecorderOpcUaClientReadChanged(lHandle, I, lValue,
                  lTime, lQuality) then
                  fLines.Add(lTagName + #9 + lNodeId + #9 +
                    FloatToStr(lValue) + #9 + '0x' + IntToHex(lQuality, 8) +
                    #9 + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz',
                      UnixToDateTime(Trunc(lTime), False) +
                      Frac(lTime) / 86400.0));
              end;
            end;
        end;
        fSucceeded := True;
      finally
        RecorderOpcUaClientDestroy(lHandle);
      end;
    except
      on E: Exception do
        fErrorText := E.ClassName + ': ' + E.Message;
    end;
  finally
    fElapsedMs := GetTickCount64 - lStartedAt;
  end;
end;

constructor TRecorderOpcUaEditorForm.CreateEditor(AOwner: TComponent;
  AConfig: TRecorderOpcUaConfig; ARegistry: TRecorderTagRegistry;
  const ASourceId: string);
var
  I: Integer;
  lDiscardBrowseCache: Boolean;
  lNode: TRecorderOpcUaNode;
  lTag: TRecorderTag;
  lText: string;
begin
  inherited Create(AOwner);
  fRegistry := ARegistry;
  fSourceId := ASourceId;
  fBrowseCache := TStringList.Create;
  fBrowseCacheEndpoint := Trim(AConfig.BrowseCacheEndpoint);
  if fBrowseCacheEndpoint = '' then
    fBrowseCacheEndpoint := Trim(AConfig.Endpoint);
  fBrowseCache.Assign(AConfig.BrowseCache);
  lDiscardBrowseCache := (fBrowseCache.Count > 0) and
    ((Trim(AConfig.BrowseCacheEndpoint) = '') or
     not SameText(Trim(AConfig.BrowseCacheEndpoint), Trim(AConfig.Endpoint)));
  if lDiscardBrowseCache then fBrowseCache.Clear;
  fTreeItems := TObjectList.Create(True);
  fUsedItems := TObjectList.Create(True);
  fProtocolSettings.RowCount := CProtocolRowArchive + 1;
  fProtocolSettings.ColWidths[0] := 260;
  fProtocolSettings.ColWidths[1] := 300;
  fProtocolSettings.Cells[0, CProtocolRowReceive] := 'Приём текущих данных';
  fProtocolSettings.Cells[0, CProtocolRowMode] := 'Тип приёма';
  if AConfig.PollingType = ouptSubscription then
    fProtocolSettings.Cells[1, CProtocolRowMode] := 'Subscribe'
  else
    fProtocolSettings.Cells[1, CProtocolRowMode] := 'Read';
  fProtocolSettings.Cells[0, CProtocolRowInterval] :=
    'Период Read/публикации, мс';
  fProtocolSettings.Cells[1, CProtocolRowInterval] :=
    IntToStr(AConfig.PublishingIntervalMs);
  fProtocolSettings.Cells[0, CProtocolRowMaxRead] := 'Макс. узлов за ReadRequest';
  fProtocolSettings.Cells[1, CProtocolRowMaxRead] :=
    IntToStr(AConfig.MaxNodesPerRead);
  fProtocolSettings.Cells[0, CProtocolRowTimestamp] := 'Метка времени';
  case AConfig.TimestampMode of
    outSource: fProtocolSettings.Cells[1, CProtocolRowTimestamp] := 'Source';
    outBoth: fProtocolSettings.Cells[1, CProtocolRowTimestamp] := 'Both';
    outNeither: fProtocolSettings.Cells[1, CProtocolRowTimestamp] := 'Neither';
  else
    fProtocolSettings.Cells[1, CProtocolRowTimestamp] := 'Server';
  end;
  fProtocolSettings.Cells[0, CProtocolRowWrite] := 'Запись значений';
  fProtocolSettings.Cells[0, CProtocolRowMaxWrite] :=
    'Макс. узлов за WriteRequest';
  fProtocolSettings.Cells[1, CProtocolRowMaxWrite] :=
    IntToStr(AConfig.MaxNodesPerWrite);
  fProtocolSettings.Cells[0, CProtocolRowBrowse] := 'Просмотр адресного пространства';
  fProtocolSettings.Cells[0, CProtocolRowMaxBrowse] :=
    'Макс. ссылок на узел за BrowseRequest';
  fProtocolSettings.Cells[1, CProtocolRowMaxBrowse] :=
    IntToStr(AConfig.MaxNodesPerBrowse);
  fProtocolSettings.Cells[0, CProtocolRowBrowseTimeout] :=
    'Таймаут одного Browse/BrowseNext, с (мин. 30)';
  fProtocolSettings.Cells[1, CProtocolRowBrowseTimeout] :=
    IntToStr(AConfig.BrowseTimeoutMs div 1000);
  fProtocolSettings.Cells[0, CProtocolRowConnection] := 'Соединение';
  fProtocolSettings.Cells[0, CProtocolRowTimeout] :=
    'OPC UA TimeoutHint запроса, с';
  fProtocolSettings.Cells[1, CProtocolRowTimeout] :=
    IntToStr(AConfig.RequestTimeoutMs div 1000);
  fProtocolSettings.Cells[0, CProtocolRowSubscription] := 'Subscription';
  fProtocolSettings.Cells[1, CProtocolRowSubscription] :=
    'MonitoredItems + Publish при типе Subscribe';
  fProtocolSettings.Cells[0, CProtocolRowArchive] := 'Архив (HistoryRead)';
  fProtocolSettings.Cells[1, CProtocolRowArchive] :=
    'Не поддерживается текущим клиентом';
  InitializeNodeImages;
  fMode.ItemIndex := Ord(AConfig.Mode);
  fEndpoint.Text := AConfig.Endpoint;
  if AConfig.AuthenticationMode = ouamUserPassword then
    fAuth.ItemIndex := 1
  else
    fAuth.ItemIndex := 0;
  fUserName.Text := AConfig.UserName;
  fPassword.Text := AConfig.PasswordEnvironment;
  fInterval.Text := IntToStr(AConfig.PublishingIntervalMs);
  fSessionTimeout.Text := IntToStr(AConfig.SessionTimeoutMs div 1000);
  fSimplifiedTree.Checked := AConfig.SimplifiedTree;
  fBrowseTree.MultiSelect := True;
  fBrowseTree.MultiSelectStyle := [msControlSelect, msShiftSelect,
    msVisibleOnly];
  fAutoBrowsePending := False;
  fValueGrid.RowCount := 1;
  fValueGrid.Cells[0, 0] := 'Тег';
  fValueGrid.Cells[1, 0] := 'Тип';
  fValueGrid.Cells[2, 0] := 'Доступ';
  fValueGrid.Cells[3, 0] := 'NodeId';
  fValueGrid.Cells[4, 0] := 'Значение';
  fValueGrid.Cells[5, 0] := 'Качество';
  fValueGrid.Cells[6, 0] := 'Время';
  fValueGrid.Cells[7, 0] := 'DataType NodeId';
  fValueGrid.Cells[8, 0] := 'Role';
  fValueGrid.Cells[9, 0] := 'Message kind';
  fValueGrid.Cells[10, 0] := 'Message color';
  fValueGrid.Cells[11, 0] := 'Recorder tag id';
  fValueGrid.Cells[12, 0] := 'ValueRank';
  fValueGrid.ColWidths[0] := 130;
  fValueGrid.ColWidths[1] := 100;
  fValueGrid.ColWidths[2] := 120;
  fValueGrid.ColWidths[3] := 260;
  fValueGrid.ColWidths[4] := 110;
  fValueGrid.ColWidths[5] := 90;
  fValueGrid.ColWidths[6] := 160;
  fValueGrid.ColWidths[7] := 0;
  fValueGrid.ColWidths[8] := 0;
  fValueGrid.ColWidths[9] := 0;
  fValueGrid.ColWidths[10] := 0;
  fValueGrid.ColWidths[11] := 0;
  fValueGrid.ColWidths[12] := 0;
  fPropertiesGrid.Cells[0, 0] := 'Свойство';
  fPropertiesGrid.Cells[1, 0] := 'Значение';
  fPropertiesGrid.ColWidths[0] := 170;
  fPropertiesGrid.ColWidths[1] := 360;
  fUsedPropertiesGrid.Cells[0, 0] := 'Свойство';
  fUsedPropertiesGrid.Cells[1, 0] := 'Значение';
  fUsedPropertiesGrid.ColWidths[0] := 170;
  fUsedPropertiesGrid.ColWidths[1] := 360;
  for I := 0 to AConfig.Nodes.Count - 1 do
  begin
    lNode := TRecorderOpcUaNode(AConfig.Nodes[I]);
    if (fRegistry <> nil) and (lNode.RecorderTagId <> 0) then
    begin
      lTag := fRegistry.FindById(lNode.RecorderTagId);
      if lTag <> nil then
        lNode.TagName := lTag.Name;
    end;
    if (fRegistry <> nil) and (lNode.RecorderTagId = 0) then
    begin
      lTag := FindOpcUaTagByAddress(fRegistry, ASourceId, ASourceId,
        lNode.NodeId);
      if lTag <> nil then
      begin
        lNode.RecorderTagId := lTag.Id;
        lNode.TagName := lTag.Name;
      end;
    end;
    if (lNode.NodeId <> '') and (Pos(lNode.NodeId, lNode.TagName) > 0) then
      lNode.TagName := StringReplace(lNode.TagName, lNode.NodeId,
        CompactOpcUaNodeAddress(lNode.NodeId), [rfReplaceAll]);
    lNode.TagName := Trim(lNode.TagName);
    while (lNode.TagName <> '') and (lNode.TagName[1] = '.') do
      Delete(lNode.TagName, 1, 1);
    fValueGrid.RowCount := fValueGrid.RowCount + 1;
    fValueGrid.Cells[0, fValueGrid.RowCount - 1] := lNode.TagName;
    fValueGrid.Cells[1, fValueGrid.RowCount - 1] := '';
    if lNode.Writable and lNode.Readable then lText := 'Чтение и запись'
    else if lNode.Writable then lText := 'Только запись'
    else lText := 'Только чтение';
    fValueGrid.Cells[2, fValueGrid.RowCount - 1] := lText;
    fValueGrid.Cells[3, fValueGrid.RowCount - 1] := lNode.NodeId;
    fValueGrid.Cells[7, fValueGrid.RowCount - 1] := lNode.DataTypeNodeId;
    fValueGrid.Cells[8, fValueGrid.RowCount - 1] := IntToStr(Ord(lNode.Role));
    fValueGrid.Cells[9, fValueGrid.RowCount - 1] :=
      RecorderMessageKindName(lNode.MessageKind);
    fValueGrid.Cells[10, fValueGrid.RowCount - 1] :=
      IntToStr(lNode.MessageColor);
    fValueGrid.Cells[11, fValueGrid.RowCount - 1] :=
      IntToStr(lNode.RecorderTagId);
    fValueGrid.Cells[12, fValueGrid.RowCount - 1] :=
      IntToStr(lNode.ValueRank);
  end;
  if fBrowseCache.Count > 0 then
    LoadBrowseLines(fBrowseCache)
  else
    LoadConfiguredNodesAsOfflineTree;
  RebuildUsedTree;
  if lDiscardBrowseCache then
    AddDiagnostic('Кэш дерева не подтверждён текущим Endpoint и удалён. Нажмите «Обновить дерево» для чтения текущего устройства.');
  AddDiagnostic(UTF8Encode('Готово. Endpoint: ') + AConfig.Endpoint);
  UpdateControlState;
end;

destructor TRecorderOpcUaEditorForm.Destroy;
begin
  if fProbeThread <> nil then
  begin
    fProbeThread.OnTerminate := nil;
    fProbeThread.Terminate;
    fProbeThread.WaitFor;
    fProbeThread.Free;
  end;
  fTreeItems.Free;
  fUsedItems.Free;
  fBrowseCache.Free;
  inherited Destroy;
end;

const
  CImageDevice = 0;
  CImageGroup = 1;
  CImageProperty = 2;
  CImageBoolean = 3;
  CImageSigned = 4;
  CImageUnsigned = 5;
  CImageFloat = 6;
  CImageText = 7;
  CImageDateTime = 8;
  CImageBinary = 9;
  CImageOther = 10;

procedure AddColorImage(AImages: TImageList; AColor: TColor;
  AShape: Integer);
var
  lBitmap: TBitmap;
begin
  lBitmap := TBitmap.Create;
  try
    lBitmap.SetSize(16, 16);
    lBitmap.Transparent := True;
    lBitmap.TransparentColor := clFuchsia;
    lBitmap.Canvas.Brush.Color := clFuchsia;
    lBitmap.Canvas.FillRect(0, 0, 16, 16);
    lBitmap.Canvas.Pen.Color := clBlack;
    lBitmap.Canvas.Brush.Color := AColor;
    case AShape of
      0: lBitmap.Canvas.Rectangle(2, 3, 14, 13);
      1: lBitmap.Canvas.RoundRect(2, 3, 14, 13, 4, 4);
      2: lBitmap.Canvas.Ellipse(3, 3, 13, 13);
    else
      begin
        lBitmap.Canvas.MoveTo(8, 2);
        lBitmap.Canvas.LineTo(14, 8);
        lBitmap.Canvas.LineTo(8, 14);
        lBitmap.Canvas.LineTo(2, 8);
        lBitmap.Canvas.LineTo(8, 2);
        lBitmap.Canvas.FloodFill(8, 8, clBlack, fsBorder);
      end;
    end;
    AImages.AddMasked(lBitmap, clFuchsia);
  finally
    lBitmap.Free;
  end;
end;

procedure TRecorderOpcUaEditorForm.InitializeNodeImages;
begin
  fNodeImages.Clear;
  AddColorImage(fNodeImages, $00D08040, 0); { device }
  AddColorImage(fNodeImages, $00D0D0D0, 1); { group }
  AddColorImage(fNodeImages, $00808080, 2); { property }
  AddColorImage(fNodeImages, $0040B050, 3); { boolean }
  AddColorImage(fNodeImages, $00D08030, 3); { signed }
  AddColorImage(fNodeImages, $00F0B040, 3); { unsigned }
  AddColorImage(fNodeImages, $004080E0, 3); { float }
  AddColorImage(fNodeImages, $00C060C0, 3); { text }
  AddColorImage(fNodeImages, $00D0C040, 3); { datetime }
  AddColorImage(fNodeImages, $006080A0, 3); { bytes }
  AddColorImage(fNodeImages, $00909090, 3); { other/custom }
end;

function TRecorderOpcUaEditorForm.DataTypeImageIndex(
  const ADataTypeNodeId: string; AValueRank: Integer): Integer;
begin
  if SameText(ADataTypeNodeId, 'i=1') or
     SameText(ADataTypeNodeId, 'ns=0;i=1') then Exit(CImageBoolean);
  if SameText(ADataTypeNodeId, 'i=2') or SameText(ADataTypeNodeId, 'i=4') or
     SameText(ADataTypeNodeId, 'i=6') or SameText(ADataTypeNodeId, 'i=8') or
     SameText(ADataTypeNodeId, 'ns=0;i=2') or
     SameText(ADataTypeNodeId, 'ns=0;i=4') or
     SameText(ADataTypeNodeId, 'ns=0;i=6') or
     SameText(ADataTypeNodeId, 'ns=0;i=8') then Exit(CImageSigned);
  if SameText(ADataTypeNodeId, 'i=3') or SameText(ADataTypeNodeId, 'i=5') or
     SameText(ADataTypeNodeId, 'i=7') or SameText(ADataTypeNodeId, 'i=9') or
     SameText(ADataTypeNodeId, 'ns=0;i=3') or
     SameText(ADataTypeNodeId, 'ns=0;i=5') or
     SameText(ADataTypeNodeId, 'ns=0;i=7') or
     SameText(ADataTypeNodeId, 'ns=0;i=9') then Exit(CImageUnsigned);
  if SameText(ADataTypeNodeId, 'i=10') or SameText(ADataTypeNodeId, 'i=11') or
     SameText(ADataTypeNodeId, 'ns=0;i=10') or
     SameText(ADataTypeNodeId, 'ns=0;i=11') then Exit(CImageFloat);
  if SameText(ADataTypeNodeId, 'i=12') or
     SameText(ADataTypeNodeId, 'ns=0;i=12') then Exit(CImageText);
  if SameText(ADataTypeNodeId, 'i=13') or
     SameText(ADataTypeNodeId, 'ns=0;i=13') then Exit(CImageDateTime);
  if SameText(ADataTypeNodeId, 'i=15') or
     SameText(ADataTypeNodeId, 'ns=0;i=15') then Exit(CImageBinary);
  Result := CImageOther;
end;

function TRecorderOpcUaEditorForm.SelectedTagCount: Integer;
begin
  Result := fValueGrid.RowCount - 1;
end;

function TRecorderOpcUaEditorForm.AddOrFindTagRow(
  AItem: TRecorderOpcUaTreeItem): Integer;
begin
  Result := FindTagRow(AItem);
  if Result = 0 then Result := AppendTagRow(AItem);
end;

function TRecorderOpcUaEditorForm.FindTagRow(
  AItem: TRecorderOpcUaTreeItem): Integer;
begin
  if AItem = nil then Exit(0);
  Result := FindTagRowByNodeId(AItem.NodeId);
end;

function TRecorderOpcUaEditorForm.FindTagRowByNodeId(
  const ANodeId: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to fValueGrid.RowCount - 1 do
    if fValueGrid.Cells[3, I] = ANodeId then Exit(I);
end;

function TRecorderOpcUaEditorForm.AppendTagRow(
  AItem: TRecorderOpcUaTreeItem): Integer;
var
  lRecorderName: string;
begin
  Result := fValueGrid.RowCount;
  fValueGrid.RowCount := Result + 1;
  lRecorderName := OpcUaBrowsePathToRecorderName(AItem.BrowsePath);
  if lRecorderName = '' then lRecorderName := AItem.TagName;
  fValueGrid.Cells[0, Result] := lRecorderName;
  fValueGrid.Cells[1, Result] := AItem.DataTypeName;
  if AItem.ValueRank >= 0 then
    fValueGrid.Cells[1, Result] := fValueGrid.Cells[1, Result] + '[]';
  if AItem.Writable and AItem.Readable then
    fValueGrid.Cells[2, Result] := 'Чтение и запись'
  else if AItem.Writable then
    fValueGrid.Cells[2, Result] := 'Только запись'
  else
    fValueGrid.Cells[2, Result] := 'Только чтение';
  fValueGrid.Cells[3, Result] := AItem.NodeId;
  fValueGrid.Cells[7, Result] := AItem.DataTypeNodeId;
  fValueGrid.Cells[8, Result] := IntToStr(Ord(ounrAuto));
  fValueGrid.Cells[9, Result] := RecorderMessageKindName(rmkInformation);
  fValueGrid.Cells[10, Result] := '-1';
  fValueGrid.Cells[11, Result] := '0';
  fValueGrid.Cells[12, Result] := IntToStr(AItem.ValueRank);
end;

procedure TRecorderOpcUaEditorForm.BuildReadInputs(out ANodeIds,
  ATagNames: TStringList);
var
  I: Integer;
begin
  ANodeIds := TStringList.Create;
  ATagNames := TStringList.Create;
  for I := 1 to fValueGrid.RowCount - 1 do
    if (Trim(fValueGrid.Cells[3, I]) <> '') and
      not SameText(fValueGrid.Cells[2, I], 'Только запись') then
    begin
      ANodeIds.Add(fValueGrid.Cells[3, I]);
      ATagNames.Add(fValueGrid.Cells[0, I]);
    end;
end;

procedure TRecorderOpcUaEditorForm.AddDiagnostic(const AText: string);
begin
  fDiagnostics.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
  fDiagnostics.SelStart := Length(fDiagnostics.Text);
end;

procedure TRecorderOpcUaEditorForm.UpdateControlState;
var
  lClient, lCredentials: Boolean;
begin
  lClient := fMode.ItemIndex = Ord(oumClient);
  lCredentials := lClient and (fAuth.ItemIndex = 1);
  fAuth.Enabled := lClient;
  fUserName.Enabled := lCredentials;
  fPassword.Enabled := lCredentials;
  fProbeButton.Enabled := lClient and (fProbeThread = nil);
  fDiscoveryButton.Enabled := lClient and (fProbeThread = nil);
  fBrowseButton.Enabled := lClient and (fProbeThread = nil);
  fInteractiveBrowseButton.Enabled := lClient and (fProbeThread = nil);
  fReadButton.Enabled := lClient and (fProbeThread = nil) and
    (SelectedTagCount > 0);
end;

procedure TRecorderOpcUaEditorForm.AuthChange(Sender: TObject);
begin
  UpdateControlState;
end;

procedure TRecorderOpcUaEditorForm.ModeChange(Sender: TObject);
begin
  UpdateControlState;
end;

procedure TRecorderOpcUaEditorForm.SetProbeRunning(ARunning: Boolean);
begin
  fOkButton.Enabled := not ARunning;
  fCancelButton.Enabled := not ARunning;
  fBrowseTree.Enabled := not ARunning;
  UpdateControlState;
end;

procedure TRecorderOpcUaEditorForm.StartProbe(
  AOperation: TRecorderOpcUaProbeOperation;
  const ABrowseNodeId, ABrowsePath: string);
var
  lRequestTimeoutSeconds, lBrowseTimeoutSeconds, lSessionTimeoutSeconds: Integer;
  lTimestampsToReturn: Cardinal;
  lPassword, lUserName: string;
  lReadNodeIds, lReadTagNames: TStringList;
begin
  if fProbeThread <> nil then Exit;
  if AOperation = opoDiscover then
  begin
    AddDiagnostic('Ищу OPC UA серверы через mDNS multicast...');
    fProbeThread := TRecorderOpcUaProbeThread.Create('', '', '', AOperation,
      nil, nil);
    fProbeThread.OnTerminate := @ProbeFinished;
    SetProbeRunning(True);
    fProbeThread.Start;
    Exit;
  end;
  if Trim(fEndpoint.Text) = '' then
  begin
    AddDiagnostic('Ошибка: Endpoint URL не задан.');
    Exit;
  end;
  lUserName := '';
  lPassword := '';
  if fAuth.ItemIndex = 1 then
  begin
    lUserName := Trim(fUserName.Text);
    if lUserName = '' then
    begin
      AddDiagnostic('Ошибка: для входа с паролем задайте пользователя.');
      Exit;
    end;
    if Trim(fPassword.Text) <> '' then
      lPassword := GetEnvironmentVariable(Trim(fPassword.Text));
  end;
  if AOperation = opoBrowse then
    AddDiagnostic(UTF8Encode('Поиск тегов: ') + Trim(fEndpoint.Text))
  else if AOperation = opoBrowseChildren then
    AddDiagnostic(UTF8Encode('Чтение ветки OPC UA: ') + ABrowsePath)
  else if AOperation = opoRead then
  begin
    if SelectedTagCount = 0 then
    begin
      AddDiagnostic('Ошибка: сначала добавьте рабочие узлы из дерева.');
      Exit;
    end;
    AddDiagnostic(UTF8Encode('Чтение выбранных каналов: ') +
      IntToStr(SelectedTagCount));
  end
  else
    AddDiagnostic(UTF8Encode('Проверка OPC UA: ') + Trim(fEndpoint.Text));
  lReadNodeIds := nil;
  lReadTagNames := nil;
  if AOperation = opoRead then
    BuildReadInputs(lReadNodeIds, lReadTagNames);
  lSessionTimeoutSeconds := StrToIntDef(fSessionTimeout.Text,
    CRecorderOpcUaDefaultSessionTimeoutMs div 1000);
  if lSessionTimeoutSeconds < 1 then lSessionTimeoutSeconds := 1;
  if lSessionTimeoutSeconds > 3600 then lSessionTimeoutSeconds := 3600;
  lRequestTimeoutSeconds := Max(1, StrToIntDef(
    fProtocolSettings.Cells[1, CProtocolRowTimeout],
    CRecorderOpcUaDefaultRequestTimeoutMs div 1000));
  lBrowseTimeoutSeconds := Max(
    CRecorderOpcUaMinimumBrowseTimeoutMs div 1000, StrToIntDef(
    fProtocolSettings.Cells[1, CProtocolRowBrowseTimeout],
    CRecorderOpcUaDefaultBrowseTimeoutMs div 1000));
  lBrowseTimeoutSeconds := Min(86400, lBrowseTimeoutSeconds);
  if SameText(Trim(fProtocolSettings.Cells[1, CProtocolRowTimestamp]),
    'Source') then lTimestampsToReturn := Ord(outSource)
  else if SameText(Trim(fProtocolSettings.Cells[1, CProtocolRowTimestamp]),
    'Both') then lTimestampsToReturn := Ord(outBoth)
  else if SameText(Trim(fProtocolSettings.Cells[1, CProtocolRowTimestamp]),
    'Neither') then lTimestampsToReturn := Ord(outNeither)
  else lTimestampsToReturn := Ord(outServer);
  try
    fProbeThread := TRecorderOpcUaProbeThread.Create(Trim(fEndpoint.Text),
      lUserName, lPassword, AOperation, lReadNodeIds, lReadTagNames,
      Cardinal(lSessionTimeoutSeconds) * 1000,
      Cardinal(Max(1, StrToIntDef(
      fProtocolSettings.Cells[1, CProtocolRowMaxBrowse],
      CRecorderOpcUaDefaultMaxNodesPerRequest))),
      Cardinal(lRequestTimeoutSeconds) * 1000, lTimestampsToReturn,
      Cardinal(lBrowseTimeoutSeconds) * 1000, ABrowseNodeId, ABrowsePath);
  finally
    lReadTagNames.Free;
    lReadNodeIds.Free;
  end;
  fProbeThread.OnTerminate := @ProbeFinished;
  SetProbeRunning(True);
  fProbeThread.Start;
end;

procedure TRecorderOpcUaEditorForm.ProbeClick(Sender: TObject);
begin
  StartProbe(opoTest);
end;

procedure TRecorderOpcUaEditorForm.DiscoveryClick(Sender: TObject);
begin
  StartProbe(opoDiscover);
end;

procedure TRecorderOpcUaEditorForm.ProtocolSettingsSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
var
  lEditable: Boolean;
begin
  lEditable := (ACol = 1) and (ARow in [CProtocolRowMode,
    CProtocolRowInterval,
    CProtocolRowMaxRead, CProtocolRowTimestamp, CProtocolRowMaxWrite,
    CProtocolRowMaxBrowse, CProtocolRowBrowseTimeout,
    CProtocolRowTimeout]);
  if lEditable then
    fProtocolSettings.Options := fProtocolSettings.Options + [goEditing]
  else
    fProtocolSettings.Options := fProtocolSettings.Options - [goEditing];
end;

procedure TRecorderOpcUaEditorForm.ProtocolSettingsSelectEditor(Sender: TObject;
  ACol, ARow: Integer; var Editor: TWinControl);
var
  lPickList: TPickListCellEditor;
begin
  if (ACol <> 1) or not (ARow in [CProtocolRowMode,
    CProtocolRowTimestamp]) then Exit;

  Editor := fProtocolSettings.EditorByStyle(cbsPickList);
  lPickList := TPickListCellEditor(Editor);
  lPickList.Style := csDropDownList;
  lPickList.Clear;
  if ARow = CProtocolRowMode then
  begin
    lPickList.Items.Add('Read');
    lPickList.Items.Add('Subscribe');
  end
  else
  begin
    lPickList.Items.Add('Server');
    lPickList.Items.Add('Source');
    lPickList.Items.Add('Both');
    lPickList.Items.Add('Neither');
  end;
  lPickList.ItemIndex := lPickList.Items.IndexOf(
    fProtocolSettings.Cells[ACol, ARow]);
end;

procedure TRecorderOpcUaEditorForm.BrowseClick(Sender: TObject);
begin
  fInteractiveBrowse := False;
  fInteractiveParentNodeId := '';
  fInteractiveBrowseButton.Caption := 'Интерактивное чтение';
  fSimplifiedTree.Enabled := True;
  if (Trim(fEndpoint.Text) <> '') and
    not SameText(Trim(fEndpoint.Text), fBrowseCacheEndpoint) then
  begin
    fBrowseCache.Clear;
    fBrowseCacheEndpoint := Trim(fEndpoint.Text);
    LoadBrowseLines(fBrowseCache);
    AddDiagnostic('Адрес изменён: старый кэш OPC UA удалён перед чтением нового дерева.');
  end;
  StartProbe(opoBrowse);
end;

procedure TRecorderOpcUaEditorForm.InteractiveBrowseClick(Sender: TObject);
var
  lParentNodeId, lBrowsePath: string;
  lItem: TRecorderOpcUaTreeItem;
begin
  if not fInteractiveBrowse then
  begin
    fInteractiveBrowse := True;
    fSimplifiedTree.Checked := False;
    fSimplifiedTree.Enabled := False;
    fInteractiveBrowseButton.Caption := 'Прочитать ветку';
    if (Trim(fEndpoint.Text) <> '') and
      not SameText(Trim(fEndpoint.Text), fBrowseCacheEndpoint) then
    begin
      fBrowseCache.Clear;
      fBrowseCacheEndpoint := Trim(fEndpoint.Text);
      AddDiagnostic('Адрес изменён: старый кэш OPC UA удалён. ' +
        'Прочитанные ветки будут сохранены в кэш.');
    end;
    if fBrowseCache.Count > 0 then
      LoadBrowseLines(fBrowseCache)
    else
    begin
      fBrowseTree.Items.Clear;
      fTreeItems.Clear;
      RebuildBrowseTree;
    end;
    fInteractiveParentNodeId := CRecorderOpcUaObjectsFolderNodeId;
    lParentNodeId := CRecorderOpcUaObjectsFolderNodeId;
    lBrowsePath := CRecorderOpcUaObjectsFolderBrowsePath;
    RebuildBrowseTree;
    AddDiagnostic('Интерактивный Browse: читаю только корень Objects. ' +
      'Выберите узел и нажмите «Прочитать ветку», чтобы загрузить его детей.');
  end
  else
  begin
    if (fBrowseTree.Selected = nil) or (fBrowseTree.Selected.Data = nil) then
    begin
      AddDiagnostic('Интерактивный Browse: выберите узел дерева.');
      Exit;
    end;
    lItem := TRecorderOpcUaTreeItem(fBrowseTree.Selected.Data);
    if lItem.IsProperty then
    begin
      AddDiagnostic('Интерактивный Browse: выбранное свойство не имеет ветки.');
      Exit;
    end;
    lParentNodeId := lItem.NodeId;
    lBrowsePath := lItem.BrowsePath;
    fInteractiveParentNodeId := lParentNodeId;
  end;
  StartProbe(opoBrowseChildren, lParentNodeId, lBrowsePath);
end;

procedure TRecorderOpcUaEditorForm.ReadClick(Sender: TObject);
begin
  StartProbe(opoRead);
end;

function FindTreeChild(ATree: TTreeView; AParent: TTreeNode;
  const AText: string): TTreeNode;
var
  lNode: TTreeNode;
begin
  Result := nil;
  if AParent = nil then lNode := ATree.Items.GetFirstNode
  else lNode := AParent.GetFirstChild;
  while lNode <> nil do
  begin
    if SameText(lNode.Text, AText) then Exit(lNode);
    lNode := lNode.GetNextSibling;
  end;
end;

function EnsureTreeChild(ATree: TTreeView; AParent: TTreeNode;
  const AText: string): TTreeNode;
begin
  Result := FindTreeChild(ATree, AParent, AText);
  if Result = nil then Result := ATree.Items.AddChild(AParent, AText);
end;

function EnsureTreeItemChild(ATree: TTreeView; AParent: TTreeNode;
  const AText, ANodeId: string): TTreeNode;
var
  lNode: TTreeNode;
  lItem: TRecorderOpcUaTreeItem;
begin
  Result := nil;
  if AParent = nil then lNode := ATree.Items.GetFirstNode
  else lNode := AParent.GetFirstChild;
  while lNode <> nil do
  begin
    if lNode.Text = AText then
    begin
      if lNode.Data = nil then Exit(lNode);
      lItem := TRecorderOpcUaTreeItem(lNode.Data);
      if lItem.NodeId = ANodeId then Exit(lNode);
    end;
    lNode := lNode.GetNextSibling;
  end;
  Result := ATree.Items.AddChild(AParent, AText);
end;

procedure SetTreeNodeImage(ANode: TTreeNode; AImageIndex: Integer);
begin
  if ANode = nil then Exit;
  ANode.ImageIndex := AImageIndex;
  ANode.SelectedIndex := AImageIndex;
end;

function TRecorderOpcUaEditorForm.FindTreeItemByNodeId(
  const ANodeId: string): TRecorderOpcUaTreeItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to fTreeItems.Count - 1 do
    if TRecorderOpcUaTreeItem(fTreeItems[I]).NodeId = ANodeId then
      Exit(TRecorderOpcUaTreeItem(fTreeItems[I]));
end;

procedure TRecorderOpcUaEditorForm.RebuildUsedTree;
var
  I, J: Integer;
  lItem: TRecorderOpcUaTreeItem;
  lParent: TTreeNode;
  lPart: string;
  lParts: TStringList;
  lExpandedKeys, lSelectedKeys: TStringList;
  lFocusedKey, lTopKey: string;
  lUsed: TRecorderOpcUaUsedItem;
begin
  lExpandedKeys := TStringList.Create;
  lSelectedKeys := TStringList.Create;
  try
    lExpandedKeys.CaseSensitive := True;
    lSelectedKeys.CaseSensitive := True;
    CaptureUsedTreeState(lExpandedKeys, lSelectedKeys, lFocusedKey, lTopKey);
    fUsedTree.Items.BeginUpdate;
    try
      fUsedTree.Items.Clear;
      fUsedItems.Clear;
      for I := 1 to fValueGrid.RowCount - 1 do
      begin
        if Trim(fValueGrid.Cells[3, I]) = '' then Continue;
        lItem := FindTreeItemByNodeId(fValueGrid.Cells[3, I]);
        if not UsedItemMatchesSearch(lItem, fValueGrid.Cells[0, I],
          fValueGrid.Cells[3, I]) then Continue;
        lUsed := TRecorderOpcUaUsedItem.Create;
        lUsed.NodeId := fValueGrid.Cells[3, I];
        fUsedItems.Add(lUsed);
        lParent := nil;
        if lItem <> nil then
        begin
          lParts := TStringList.Create;
          try
            lParts.Delimiter := '/';
            lParts.StrictDelimiter := True;
            lParts.DelimitedText := lItem.BrowsePath;
            for J := 0 to lParts.Count - 2 do
            begin
              lPart := Trim(lParts[J]);
              if lPart <> '' then
                lParent := EnsureTreeChild(fUsedTree, lParent, lPart);
            end;
          finally
            lParts.Free;
          end;
          lUsed.TreeNode := fUsedTree.Items.AddChild(lParent, lItem.TagName);
          SetTreeNodeImage(lUsed.TreeNode,
            DataTypeImageIndex(lItem.DataTypeNodeId, lItem.ValueRank));
        end
        else
        begin
          lParent := EnsureTreeChild(fUsedTree, nil, 'Используемые каналы');
          lUsed.TreeNode := fUsedTree.Items.AddChild(lParent,
            fValueGrid.Cells[0, I]);
        end;
        lUsed.TreeNode.Data := lUsed;
      end;
    finally
      fUsedTree.Items.EndUpdate;
    end;
    RestoreUsedTreeState(lExpandedKeys, lSelectedKeys, lFocusedKey, lTopKey);
    ShowSelectedUsedProperties;
  finally
    lSelectedKeys.Free;
    lExpandedKeys.Free;
  end;
end;

function TRecorderOpcUaEditorForm.UsedTreeNodeKey(ANode: TTreeNode): string;
var
  lPath: string;
  lUsed: TRecorderOpcUaUsedItem;
begin
  Result := '';
  if ANode = nil then Exit;
  if ANode.Data <> nil then
  begin
    lUsed := TRecorderOpcUaUsedItem(ANode.Data);
    Exit('id:' + lUsed.NodeId);
  end;
  lPath := ANode.Text;
  ANode := ANode.Parent;
  while ANode <> nil do
  begin
    lPath := ANode.Text + '/' + lPath;
    ANode := ANode.Parent;
  end;
  Result := 'path:' + lPath;
end;

procedure TRecorderOpcUaEditorForm.CaptureUsedTreeState(AExpandedKeys,
  ASelectedKeys: TStrings; out AFocusedKey, ATopKey: string);
var
  I: Integer;
  lNode: TTreeNode;
begin
  AExpandedKeys.Clear;
  ASelectedKeys.Clear;
  lNode := fUsedTree.Items.GetFirstNode;
  while lNode <> nil do
  begin
    if lNode.Expanded then AExpandedKeys.Add(UsedTreeNodeKey(lNode));
    lNode := lNode.GetNext;
  end;
  for I := 0 to Integer(fUsedTree.SelectionCount) - 1 do
    ASelectedKeys.Add(UsedTreeNodeKey(fUsedTree.Selections[I]));
  AFocusedKey := UsedTreeNodeKey(fUsedTree.Selected);
  ATopKey := UsedTreeNodeKey(fUsedTree.TopItem);
end;

procedure TRecorderOpcUaEditorForm.RestoreUsedTreeState(AExpandedKeys,
  ASelectedKeys: TStrings; const AFocusedKey, ATopKey: string);
var
  lKey: string;
  lNode, lFocusedNode, lTopNode: TTreeNode;
begin
  lFocusedNode := nil;
  lTopNode := nil;
  lNode := fUsedTree.Items.GetFirstNode;
  while lNode <> nil do
  begin
    lKey := UsedTreeNodeKey(lNode);
    lNode.Expanded := AExpandedKeys.IndexOf(lKey) >= 0;
    lNode.Selected := ASelectedKeys.IndexOf(lKey) >= 0;
    if lKey = AFocusedKey then lFocusedNode := lNode;
    if lKey = ATopKey then lTopNode := lNode;
    lNode := lNode.GetNext;
  end;
  if lFocusedNode <> nil then fUsedTree.Selected := lFocusedNode;
  if lTopNode <> nil then fUsedTree.TopItem := lTopNode;
end;

function TRecorderOpcUaEditorForm.UsedItemMatchesSearch(
  AItem: TRecorderOpcUaTreeItem; const ATagName, ANodeId: string): Boolean;
var
  lNeedle: string;
begin
  lNeedle := UTF8LowerCase(Trim(fUsedSearch.Text));
  Result := (lNeedle = '') or
    (Pos(lNeedle, UTF8LowerCase(ATagName)) > 0) or
    (Pos(lNeedle, UTF8LowerCase(ANodeId)) > 0);
  if Result or (AItem = nil) then Exit;
  Result := (Pos(lNeedle, UTF8LowerCase(AItem.BrowsePath)) > 0) or
    (Pos(lNeedle, UTF8LowerCase(AItem.DataTypeName)) > 0) or
    (Pos(lNeedle, UTF8LowerCase(AItem.ValueText)) > 0);
end;

procedure TRecorderOpcUaEditorForm.UsedSearchChange(Sender: TObject);
begin
  RebuildUsedTree;
end;

procedure TRecorderOpcUaEditorForm.UsedTreeSelectionChanged(Sender: TObject);
begin
  ShowSelectedUsedProperties;
end;

procedure TRecorderOpcUaEditorForm.ShowSelectedUsedProperties;
var
  lItem: TRecorderOpcUaTreeItem;
  lNodeId, lRole, lQualityTime, lAddress, lFullBrowseName,
    lFullAddress, lLegacyAddress, lRecorderName: string;
  lRow, I, J, lCommonLength, lCandidateLength, lStart,
    lSelectionCount: Integer;
  lNames: TStringList;
  lCommon, lCandidate: string;
  lFound, lHasBrowsePath: Boolean;

  procedure SetProperty(ARow: Integer; const AName, AValue: string);
  begin
    fUsedPropertiesGrid.Cells[0, ARow] := AName;
    fUsedPropertiesGrid.Cells[1, ARow] := AValue;
  end;
begin
  if fUsedPropertiesGrid = nil then Exit;
  fCommonNameSubstring := '';
  fSelectedNameEdit.Text := '';
  fSelectedNameEdit.Hint := '';
  fUpdatingAddressCheck := True;
  try
    fAddConnectionAddressCheck.Checked := False;
  finally
    fUpdatingAddressCheck := False;
  end;
  fUpdatingUsedProperties := True;
  try
    fUsedPropertiesGrid.Clean;
    fUsedPropertiesGrid.RowCount := 14;
    SetProperty(0, 'Свойство', 'Значение');
    lNames := TStringList.Create;
    try
      lSelectionCount := 0;
      for I := 0 to Integer(fUsedTree.SelectionCount) - 1 do
      begin
        if fUsedTree.Selections[I].Data = nil then Continue;
        lNodeId := TRecorderOpcUaUsedItem(
          fUsedTree.Selections[I].Data).NodeId;
        lRow := FindTagRowByNodeId(lNodeId);
        if lRow = 0 then Continue;
        lNames.Add(fValueGrid.Cells[0, lRow]);
        Inc(lSelectionCount);
      end;
      if (lSelectionCount > 1) and (lNames.Count > 0) then
      begin
        lCommonLength := UTF8Length(lNames[0]);
        for I := 1 to lNames.Count - 1 do
          lCommonLength := Min(lCommonLength, UTF8Length(lNames[I]));
        lCommon := '';
        for lCandidateLength := lCommonLength downto 1 do
        begin
          for lStart := 1 to lCommonLength - lCandidateLength + 1 do
          begin
            lCandidate := UTF8Copy(lNames[0], lStart, lCandidateLength);
            lFound := True;
            for J := 1 to lNames.Count - 1 do
              if UTF8Pos(UTF8LowerCase(lCandidate),
                UTF8LowerCase(lNames[J])) = 0 then
              begin
                lFound := False;
                Break;
              end;
            if lFound then
            begin
              lCommon := lCandidate;
              Break;
            end;
          end;
          if lCommon <> '' then Break;
        end;
        if lCommon <> '' then
          fCommonNameSubstring := lCommon + '***'
        else
          fCommonNameSubstring := '***';
      end
      else if lSelectionCount = 1 then
        fCommonNameSubstring := lNames[0];
    finally
      lNames.Free;
    end;
    if (fUsedTree.Selected = nil) or (fUsedTree.Selected.Data = nil) then Exit;
    lNodeId := TRecorderOpcUaUsedItem(fUsedTree.Selected.Data).NodeId;
    lRow := FindTagRowByNodeId(lNodeId);
    if lRow = 0 then Exit;
    lItem := FindTreeItemByNodeId(lNodeId);
    SetProperty(1, 'Имя тега Recorder', fValueGrid.Cells[0, lRow]);
    fSelectedNameEdit.Text := fValueGrid.Cells[0, lRow];
    fSelectedNameEdit.Hint := fSelectedNameEdit.Text;
    lRecorderName := fValueGrid.Cells[0, lRow];
    lHasBrowsePath := False;
    if lItem <> nil then
    begin
      lAddress := OpcUaBrowsePathToRecorderPrefix(lItem.BrowsePath);
      lFullBrowseName := OpcUaBrowsePathToRecorderName(lItem.BrowsePath);
      lFullAddress := lNodeId;
      lLegacyAddress := CompactOpcUaNodeAddress(lNodeId);
      if lAddress <> '' then
        lHasBrowsePath := (Pos(lAddress + '.', lRecorderName) = 1) or
          (Pos(lAddress + ' ', lRecorderName) = 1) or
          (Pos(' ' + lAddress, lRecorderName) > 0);
      if (not lHasBrowsePath) and (lFullBrowseName <> '') then
        lHasBrowsePath := Pos(lFullBrowseName, lRecorderName) = 1;
      if (not lHasBrowsePath) and (lFullAddress <> '') then
        lHasBrowsePath := Pos(lFullAddress, lRecorderName) = 1;
      if (not lHasBrowsePath) and (lLegacyAddress <> '') then
        lHasBrowsePath := Pos(lLegacyAddress, lRecorderName) = 1;
    end;
    fUpdatingAddressCheck := True;
    try
      fAddConnectionAddressCheck.Checked := lHasBrowsePath;
    finally
      fUpdatingAddressCheck := False;
    end;
    SetProperty(2, 'Endpoint URL', fEndpoint.Text);
    SetProperty(3, 'Строка подключения', fEndpoint.Text + ' | ' + lNodeId);
    SetProperty(4, 'NodeId', lNodeId);
    if lItem <> nil then
    begin
      SetProperty(5, 'Имя узла сервера', lItem.TagName);
      SetProperty(6, 'Browse path', lItem.BrowsePath);
    end;
    SetProperty(7, 'Тип данных', fValueGrid.Cells[1, lRow]);
    SetProperty(8, 'DataType NodeId', fValueGrid.Cells[7, lRow]);
    SetProperty(9, 'Доступ', fValueGrid.Cells[2, lRow]);
    lRole := fValueGrid.Cells[8, lRow];
    if lRole = IntToStr(Ord(ounrMessage)) then lRole := 'Сообщение'
    else lRole := 'Тег';
    SetProperty(10, 'Роль канала', lRole);
    SetProperty(11, 'Значение', fValueGrid.Cells[4, lRow]);
    lQualityTime := fValueGrid.Cells[5, lRow];
    if fValueGrid.Cells[6, lRow] <> '' then
      lQualityTime := lQualityTime + ' / ' + fValueGrid.Cells[6, lRow];
    SetProperty(12, 'Качество / время', lQualityTime);
    SetProperty(13, 'Recorder tag id', fValueGrid.Cells[11, lRow]);
  finally
    fUpdatingUsedProperties := False;
  end;
end;

procedure TRecorderOpcUaEditorForm.UsedPropertiesGridSelectCell(
  Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect := True;
  if (ACol = 1) and (ARow = 1) and (fUsedTree.Selected <> nil) and
    (fUsedTree.Selected.Data <> nil) then
    fUsedPropertiesGrid.Options := fUsedPropertiesGrid.Options + [goEditing]
  else
    fUsedPropertiesGrid.Options := fUsedPropertiesGrid.Options - [goEditing];
end;

procedure TRecorderOpcUaEditorForm.UsedPropertiesGridEditingDone(
  Sender: TObject);
var
  lName, lNodeId: string;
  lRow: Integer;
begin
  if fUpdatingUsedProperties or (fUsedPropertiesGrid.Row <> 1) or
    (fUsedPropertiesGrid.Col <> 1) or (fUsedTree.Selected = nil) or
    (fUsedTree.Selected.Data = nil) then Exit;
  lNodeId := TRecorderOpcUaUsedItem(fUsedTree.Selected.Data).NodeId;
  lRow := FindTagRowByNodeId(lNodeId);
  if lRow = 0 then Exit;
  lName := Trim(fUsedPropertiesGrid.Cells[1, 1]);
  if lName = '' then
  begin
    fUsedPropertiesGrid.Cells[1, 1] := fValueGrid.Cells[0, lRow];
    Exit;
  end;
  fValueGrid.Cells[0, lRow] := lName;
  RebuildUsedTree;
end;

procedure TRecorderOpcUaEditorForm.EditNamesClick(Sender: TObject);
var
  I, lRow: Integer;
  lNodeIds: TStringList;
  lFirstName, lNodeId, lInitialText, lText: string;
  lOperation: TRecorderOpcUaNameOperation;
  lDialog: TRecorderOpcUaNameOperationDialog;
begin
  if fUsedTree.SelectionCount = 0 then Exit;
  lFirstName := '';
  lNodeIds := TStringList.Create;
  try
    lNodeIds.CaseSensitive := True;
    lNodeIds.Sorted := True;
    lNodeIds.Duplicates := dupIgnore;
    for I := 0 to Integer(fUsedTree.SelectionCount) - 1 do
      CollectUsedNodeIds(fUsedTree.Selections[I], lNodeIds);
    for I := 0 to lNodeIds.Count - 1 do
    begin
      lNodeId := lNodeIds[I];
      lRow := FindTagRowByNodeId(lNodeId);
      if lRow = 0 then Continue;
      lFirstName := fValueGrid.Cells[0, lRow];
      Break;
    end;
  finally
    lNodeIds.Free;
  end;
  if lFirstName = '' then Exit;
  lInitialText := fCommonNameSubstring;
  if lInitialText = '' then lInitialText := '***';
  lDialog := TRecorderOpcUaNameOperationDialog.CreateDialog(Self,
    lFirstName, lInitialText);
  try
    if not lDialog.Execute(lOperation, lText) then Exit;
  finally
    lDialog.Free;
  end;
  if lText = '' then Exit;
  ApplyNameOperationToSelected(lOperation, lText);
  if lOperation = onoRemove then
  begin
    fUpdatingAddressCheck := True;
    try
      fAddConnectionAddressCheck.Checked := False;
    finally
      fUpdatingAddressCheck := False;
    end;
  end;
end;

function CompactOpcUaNodeAddress(const ANodeId: string): string;
var
  lMarkerPos, lPayloadStart, lFirstSeparator, lLastSeparator: Integer;
begin
  Result := ANodeId;
  lMarkerPos := Pos('|var|', ANodeId);
  if lMarkerPos = 0 then Exit;
  lPayloadStart := lMarkerPos + Length('|var|');
  lFirstSeparator := Pos('.', Copy(ANodeId, lPayloadStart, MaxInt));
  if lFirstSeparator = 0 then Exit;
  lFirstSeparator := lFirstSeparator + lPayloadStart - 1;
  lLastSeparator := LastDelimiter('.', ANodeId);
  if lLastSeparator <= lFirstSeparator then Exit;
  Result := Copy(ANodeId, 1, lFirstSeparator) +
    Copy(ANodeId, lLastSeparator + 1, MaxInt);
end;

procedure TRecorderOpcUaEditorForm.AddConnectionAddressChange(Sender: TObject);
var
  I, lRow, lChanged: Integer;
  lNodeIds: TStringList;
  lName, lAddress, lFullBrowseName, lLegacyAddress, lFullAddress,
    lUpdatedName: string;
  lTreeItem: TRecorderOpcUaTreeItem;
begin
  if fUpdatingAddressCheck then Exit;
  lNodeIds := TStringList.Create;
  try
    lNodeIds.CaseSensitive := True;
    lNodeIds.Sorted := True;
    lNodeIds.Duplicates := dupIgnore;
    for I := 0 to Integer(fUsedTree.SelectionCount) - 1 do
      CollectUsedNodeIds(fUsedTree.Selections[I], lNodeIds);
    lChanged := 0;
    for I := 0 to lNodeIds.Count - 1 do
    begin
      lRow := FindTagRowByNodeId(lNodeIds[I]);
      if lRow = 0 then Continue;
      lName := fValueGrid.Cells[0, lRow];
      lFullAddress := lNodeIds[I];
      lLegacyAddress := CompactOpcUaNodeAddress(lFullAddress);
      lTreeItem := FindTreeItemByNodeId(lFullAddress);
      if lTreeItem <> nil then
      begin
        lFullBrowseName := OpcUaBrowsePathToRecorderName(
          lTreeItem.BrowsePath);
        lAddress := OpcUaBrowsePathToRecorderPrefix(lTreeItem.BrowsePath)
      end
      else
      begin
        lFullBrowseName := '';
        lAddress := '';
      end;
      if fAddConnectionAddressCheck.Checked then
      begin
        if lAddress = '' then Continue;
        { Remove an address stored by older versions before prefixing the
          BrowsePath-based name. }
        lName := StringReplace(lName, lFullAddress, '', [rfReplaceAll]);
        if lLegacyAddress <> lFullAddress then
          lName := StringReplace(lName, lLegacyAddress, '', [rfReplaceAll]);
        if lFullBrowseName <> '' then
          lName := StringReplace(lName, lFullBrowseName, '',
            [rfReplaceAll]);
        lName := Trim(lName);
        while (lName <> '') and (lName[1] = '.') do Delete(lName, 1, 1);
        while (lName <> '') and (lName[Length(lName)] = '.') do
          Delete(lName, Length(lName), 1);
        if Copy(lName, 1, Length(lAddress)) <> lAddress then
        begin
          if lName <> '' then lName := lAddress + '.' + lName
          else lName := lAddress;
        end;
        if lName = fValueGrid.Cells[0, lRow] then Continue;
        fValueGrid.Cells[0, lRow] := lName;
      end
      else
      begin
        lUpdatedName := lName;
        if lAddress <> '' then
          lUpdatedName := StringReplace(lUpdatedName, lAddress, '',
            [rfReplaceAll]);
        if lFullBrowseName <> '' then
          lUpdatedName := StringReplace(lUpdatedName, lFullBrowseName, '',
            [rfReplaceAll]);
        lUpdatedName := StringReplace(lUpdatedName, lFullAddress, '',
          [rfReplaceAll]);
        if lLegacyAddress <> lFullAddress then
          lUpdatedName := StringReplace(lUpdatedName, lLegacyAddress, '',
            [rfReplaceAll]);
        lUpdatedName := Trim(lUpdatedName);
        while (lUpdatedName <> '') and (lUpdatedName[1] = '.') do
          Delete(lUpdatedName, 1, 1);
        while (lUpdatedName <> '') and
          (lUpdatedName[Length(lUpdatedName)] = '.') do
          Delete(lUpdatedName, Length(lUpdatedName), 1);
        if lUpdatedName = lName then Continue;
        if (lUpdatedName = '') and (lTreeItem <> nil) then
          lUpdatedName := lTreeItem.TagName;
        fValueGrid.Cells[0, lRow] := lUpdatedName;
      end;
      Inc(lChanged);
    end;
  finally
    lNodeIds.Free;
  end;
  RebuildUsedTree;
  if fAddConnectionAddressCheck.Checked then
    AddDiagnostic(Format('Browse path добавлен в имена тегов: %d', [lChanged]))
  else
    AddDiagnostic(Format('Browse path удалён из имён тегов: %d', [lChanged]));
end;

procedure TRecorderOpcUaEditorForm.ApplyNameOperationToSelected(
  AOperation: TRecorderOpcUaNameOperation; const AText: string);
var
  I, lRow, lChanged: Integer;
  lNodeIds: TStringList;
  lName, lUpdatedName: string;
begin
  if fUsedTree.SelectionCount = 0 then Exit;
  if Trim(AText) = '' then Exit;
  lNodeIds := TStringList.Create;
  try
    lNodeIds.CaseSensitive := True;
    lNodeIds.Sorted := True;
    lNodeIds.Duplicates := dupIgnore;
    for I := 0 to Integer(fUsedTree.SelectionCount) - 1 do
      CollectUsedNodeIds(fUsedTree.Selections[I], lNodeIds);
    lChanged := 0;
    for I := 0 to lNodeIds.Count - 1 do
    begin
      lRow := FindTagRowByNodeId(lNodeIds[I]);
      if lRow = 0 then Continue;
      lName := fValueGrid.Cells[0, lRow];
      if AOperation = onoRemove then
        lUpdatedName := StripOuterNameDots(
          StringReplace(lName, AText, '', [rfReplaceAll]))
      else if Copy(lName, 1, Length(AText)) <> AText then
        lUpdatedName := AText + lName
      else
        lUpdatedName := lName;
      if lUpdatedName = lName then Continue;
      fValueGrid.Cells[0, lRow] := lUpdatedName;
      Inc(lChanged);
    end;
  finally
    lNodeIds.Free;
  end;
  RebuildUsedTree;
  if AOperation = onoRemove then
    AddDiagnostic(Format('Удалена подстрока в именах Recorder: %d',
      [lChanged]))
  else
    AddDiagnostic(Format('Добавлен префикс к именам Recorder: %d',
      [lChanged]));
end;

procedure TRecorderOpcUaEditorForm.RemoveSelectedUsedChannels;
var
  I, J: Integer;
  lNodeIds: TStringList;
begin
  lNodeIds := TStringList.Create;
  try
    lNodeIds.CaseSensitive := True;
    lNodeIds.Sorted := True;
    lNodeIds.Duplicates := dupIgnore;
    for I := 0 to Integer(fUsedTree.SelectionCount) - 1 do
      CollectUsedNodeIds(fUsedTree.Selections[I], lNodeIds);
    for J := fValueGrid.RowCount - 1 downto 1 do
      if lNodeIds.IndexOf(fValueGrid.Cells[3, J]) >= 0 then
        fValueGrid.DeleteRow(J);
    if fValueGrid.RowCount < 1 then fValueGrid.RowCount := 1;
  finally
    lNodeIds.Free;
  end;
  RebuildUsedTree;
  UpdateControlState;
end;

procedure TRecorderOpcUaEditorForm.CollectUsedNodeIds(ANode: TTreeNode;
  ANodeIds: TStrings);
var
  lChild: TTreeNode;
  lUsed: TRecorderOpcUaUsedItem;
begin
  if (ANode = nil) or (ANodeIds = nil) then Exit;
  if ANode.Data <> nil then
  begin
    lUsed := TRecorderOpcUaUsedItem(ANode.Data);
    if ANodeIds.IndexOf(lUsed.NodeId) < 0 then ANodeIds.Add(lUsed.NodeId);
  end;
  lChild := ANode.GetFirstChild;
  while lChild <> nil do
  begin
    CollectUsedNodeIds(lChild, ANodeIds);
    lChild := lChild.GetNextSibling;
  end;
end;

procedure TRecorderOpcUaEditorForm.ShowSelectedNodeProperties;
var
  lRow: Integer;
  lItem: TRecorderOpcUaTreeItem;
  lAccess, lClassName, lTypeName: string;

  procedure SetProperty(ARow: Integer; const AName, AValue: string);
  begin
    fPropertiesGrid.Cells[0, ARow] := AName;
    fPropertiesGrid.Cells[1, ARow] := AValue;
  end;

begin
  fPropertiesGrid.Clean;
  fUpdatingProperties := True;
  fPropertiesGrid.RowCount := 15;
  SetProperty(0, 'Свойство', 'Значение');
  if (fBrowseTree.Selected = nil) or
    (fBrowseTree.Selected.Data = nil) then
  begin
    fUpdatingProperties := False;
    Exit;
  end;
  lItem := TRecorderOpcUaTreeItem(fBrowseTree.Selected.Data);
  case lItem.NodeClass of
    1: lClassName := 'Object';
    2: lClassName := 'Variable';
    4: lClassName := 'Method';
  else
    lClassName := IntToStr(lItem.NodeClass);
  end;
  if lItem.Readable and lItem.Writable then lAccess := 'Чтение и запись'
  else if lItem.Writable then lAccess := 'Только запись'
  else if lItem.Readable then lAccess := 'Только чтение'
  else lAccess := 'Нет доступа';
  lTypeName := lItem.DataTypeName;
  if lItem.ValueRank >= 0 then lTypeName := lTypeName + '[]';
  SetProperty(1, 'Имя', lItem.TagName);
  SetProperty(2, 'Browse path', lItem.BrowsePath);
  SetProperty(3, 'NodeId', lItem.NodeId);
  SetProperty(4, 'Класс узла', lClassName);
  SetProperty(5, 'TypeDefinition', lItem.TypeDefinition);
  SetProperty(6, 'Тип данных', lTypeName);
  SetProperty(7, 'Доступ', lAccess);
  SetProperty(8, 'Значение', lItem.ValueText);
  SetProperty(9, 'Время значения', lItem.ValueTimestamp);
  SetProperty(10, 'ValueRank', IntToStr(lItem.ValueRank));
  SetProperty(11, 'Historizing', BoolToStr(lItem.Historizing, True));
  SetProperty(12, 'HDA read', BoolToStr(lItem.HistoryReadable, True));
  SetProperty(13, 'HDA write', BoolToStr(lItem.HistoryWritable, True));
  lRow := FindTagRow(lItem);
  if lRow > 0 then
    SetProperty(14, 'Имя тега Recorder', fValueGrid.Cells[0, lRow])
  else
    SetProperty(14, 'Имя тега Recorder', '(канал не используется)');
  fUpdatingProperties := False;
end;

procedure TRecorderOpcUaEditorForm.PropertiesGridSelectCell(Sender: TObject;
  ACol, ARow: Integer; var CanSelect: Boolean);
begin
  CanSelect := True;
  if (ACol = 1) and (ARow = 14) and
    (fBrowseTree.Selected <> nil) and (fBrowseTree.Selected.Data <> nil) and
    (FindTagRow(TRecorderOpcUaTreeItem(fBrowseTree.Selected.Data)) > 0) then
    fPropertiesGrid.Options := fPropertiesGrid.Options + [goEditing]
  else
    fPropertiesGrid.Options := fPropertiesGrid.Options - [goEditing];
end;

procedure TRecorderOpcUaEditorForm.PropertiesGridEditingDone(Sender: TObject);
var
  lItem: TRecorderOpcUaTreeItem;
  lName: string;
  lRow: Integer;
begin
  if fUpdatingProperties or (fPropertiesGrid.Row <> 14) or
    (fPropertiesGrid.Col <> 1) or (fBrowseTree.Selected = nil) or
    (fBrowseTree.Selected.Data = nil) then Exit;
  lItem := TRecorderOpcUaTreeItem(fBrowseTree.Selected.Data);
  lRow := FindTagRow(lItem);
  if lRow < 1 then Exit;
  lName := Trim(fPropertiesGrid.Cells[1, 14]);
  if lName = '' then
  begin
    fPropertiesGrid.Cells[1, 14] := fValueGrid.Cells[0, lRow];
    Exit;
  end;
  fValueGrid.Cells[0, lRow] := lName;
  RebuildUsedTree;
end;

procedure TRecorderOpcUaEditorForm.AddSelectedTreeNode;
var
  lItem: TRecorderOpcUaTreeItem;
begin
  if (fBrowseTree.Selected = nil) or (fBrowseTree.Selected.Data = nil) then Exit;
  lItem := TRecorderOpcUaTreeItem(fBrowseTree.Selected.Data);
  if lItem.IsProperty or not (lItem.Readable or lItem.Writable) then
  begin
    AddDiagnostic('Свойство доступно только для просмотра в настройках.');
    Exit;
  end;
  AddTreeItemToGrid(lItem);
  RebuildUsedTree;
  AddDiagnostic(UTF8Encode('Канал в таблице тегов: ') + lItem.TagName +
    ' (' + lItem.DataTypeName + ')');
  UpdateControlState;
end;

procedure TRecorderOpcUaEditorForm.AddTreeItemToGrid(
  AItem: TRecorderOpcUaTreeItem);
begin
  if (AItem = nil) or AItem.IsProperty or
    not (AItem.Readable or AItem.Writable) then
    Exit;
  fValueGrid.Row := AddOrFindTagRow(AItem);
end;

function TRecorderOpcUaEditorForm.SelectedUsableTreeNodeCount: Integer;
var
  lItems: TList;
begin
  lItems := TList.Create;
  try
    BuildSelectedUsableTreeItems(lItems);
    Result := lItems.Count;
  finally
    lItems.Free;
  end;
end;

procedure TRecorderOpcUaEditorForm.CollectUsableTreeItems(ANode: TTreeNode;
  AItems: TList; ANodeIds: TStrings);
var
  lChild: TTreeNode;
  lItem: TRecorderOpcUaTreeItem;
begin
  if (ANode = nil) or (AItems = nil) or (ANodeIds = nil) then Exit;
  if ANode.Data <> nil then
  begin
    lItem := TRecorderOpcUaTreeItem(ANode.Data);
    if not lItem.IsProperty and (lItem.Readable or lItem.Writable) and
      (ANodeIds.IndexOf(lItem.NodeId) < 0) then
    begin
      ANodeIds.Add(lItem.NodeId);
      AItems.Add(lItem);
    end;
  end;
  lChild := ANode.GetFirstChild;
  while lChild <> nil do
  begin
    CollectUsableTreeItems(lChild, AItems, ANodeIds);
    lChild := lChild.GetNextSibling;
  end;
end;

procedure TRecorderOpcUaEditorForm.BuildSelectedUsableTreeItems(AItems: TList);
var
  I: Integer;
  lNode: TTreeNode;
  lNodeIds: TStringList;
begin
  if AItems = nil then Exit;
  AItems.Clear;
  lNodeIds := TStringList.Create;
  try
    lNodeIds.CaseSensitive := True;
    lNodeIds.Sorted := True;
    lNodeIds.Duplicates := dupIgnore;
    for I := 0 to fBrowseTree.Items.Count - 1 do
    begin
      lNode := fBrowseTree.Items[I];
      if lNode.Selected then
        CollectUsableTreeItems(lNode, AItems, lNodeIds);
    end;
  finally
    lNodeIds.Free;
  end;
end;

procedure TRecorderOpcUaEditorForm.AddSelectedTreeNodes;
var
  I, lAdded, lLastRow: Integer;
  lItems: TList;
  lExistingNodeIds: TStringList;
  lItem: TRecorderOpcUaTreeItem;
begin
  lAdded := 0;
  lLastRow := 0;
  lItems := TList.Create;
  lExistingNodeIds := TStringList.Create;
  try
    BuildSelectedUsableTreeItems(lItems);
    lExistingNodeIds.CaseSensitive := True;
    lExistingNodeIds.Sorted := True;
    lExistingNodeIds.Duplicates := dupIgnore;
    for I := 1 to fValueGrid.RowCount - 1 do
      lExistingNodeIds.Add(fValueGrid.Cells[3, I]);
    for I := 0 to lItems.Count - 1 do
    begin
      lItem := TRecorderOpcUaTreeItem(lItems[I]);
      if lExistingNodeIds.IndexOf(lItem.NodeId) >= 0 then Continue;
      lLastRow := AppendTagRow(lItem);
      lExistingNodeIds.Add(lItem.NodeId);
      Inc(lAdded);
    end;
  finally
    lExistingNodeIds.Free;
    lItems.Free;
  end;
  if lAdded > 0 then
  begin
    fValueGrid.Row := lLastRow;
    RebuildUsedTree;
    AddDiagnostic(Format('Добавлено в используемые: %d', [lAdded]));
  end;
  UpdateControlState;
end;

function TRecorderOpcUaEditorForm.TreeNodeContainsUsableItem(
  ANode: TTreeNode): Boolean;
var
  lChild: TTreeNode;
  lItem: TRecorderOpcUaTreeItem;
begin
  Result := False;
  if ANode = nil then Exit;
  if ANode.Data <> nil then
  begin
    lItem := TRecorderOpcUaTreeItem(ANode.Data);
    if not lItem.IsProperty and (lItem.Readable or lItem.Writable) then
      Exit(True);
  end;
  lChild := ANode.GetFirstChild;
  while lChild <> nil do
  begin
    if TreeNodeContainsUsableItem(lChild) then Exit(True);
    lChild := lChild.GetNextSibling;
  end;
end;

function TRecorderOpcUaEditorForm.SelectionContainsUsableItem: Boolean;
var
  I: Integer;
  lNode: TTreeNode;
begin
  Result := False;
  for I := 0 to fBrowseTree.Items.Count - 1 do
  begin
    lNode := fBrowseTree.Items[I];
    if lNode.Selected and TreeNodeContainsUsableItem(lNode) then Exit(True);
  end;
end;

procedure TRecorderOpcUaEditorForm.BrowseTreeDblClick(Sender: TObject);
begin
  AddSelectedTreeNode;
end;

procedure TRecorderOpcUaEditorForm.BrowseTreeSelectionChanged(Sender: TObject);
begin
  ShowSelectedNodeProperties;
end;

procedure TRecorderOpcUaEditorForm.BrowseTreeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lNode: TTreeNode;
begin
  if Button <> mbRight then Exit;
  lNode := fBrowseTree.GetNodeAt(X, Y);
  if (lNode <> nil) and not lNode.Selected then
    fBrowseTree.Items.SelectOnlyThis(lNode);
end;

procedure TRecorderOpcUaEditorForm.BrowseTreeStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  fDragSelectionHasUsableItem := SelectionContainsUsableItem;
end;

procedure TRecorderOpcUaEditorForm.BrowsePopupPopup(Sender: TObject);
var
  lCount: Integer;
begin
  lCount := SelectedUsableTreeNodeCount;
  fAddSelectedMenuItem.Enabled := lCount > 0;
  if lCount > 1 then
    fAddSelectedMenuItem.Caption := Format(
      'Добавить выбранные в используемые (%d)', [lCount])
  else
    fAddSelectedMenuItem.Caption :=
      'Добавить в используемые';
end;

procedure TRecorderOpcUaEditorForm.AddSelectedMenuClick(Sender: TObject);
begin
  AddSelectedTreeNodes;
end;

procedure TRecorderOpcUaEditorForm.UsedTreeDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := (Source = fBrowseTree) and
    fDragSelectionHasUsableItem;
end;

procedure TRecorderOpcUaEditorForm.UsedTreeDragDrop(Sender, Source: TObject;
  X, Y: Integer);
begin
  if Source = fBrowseTree then AddSelectedTreeNodes;
end;

procedure TRecorderOpcUaEditorForm.UsedTreeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_DELETE then Exit;
  RemoveSelectedUsedChannels;
  Key := 0;
end;

procedure TRecorderOpcUaEditorForm.UsedTreeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button <> mbLeft then Exit;
  fUsedMouseAnchor := fUsedTree.GetNodeAt(X, Y);
  fUsedMouseDownY := Y;
  fUsedMouseSelecting := False;
end;

procedure TRecorderOpcUaEditorForm.UsedTreeMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  lNode: TTreeNode;
begin
  if not (ssLeft in Shift) or (fUsedMouseAnchor = nil) then Exit;
  if not fUsedMouseSelecting and (Abs(Y - fUsedMouseDownY) < 4) then Exit;
  lNode := fUsedTree.GetNodeAt(X, Y);
  if lNode = nil then Exit;
  fUsedMouseSelecting := True;
  SelectUsedVisibleRange(fUsedMouseAnchor, lNode);
end;

procedure TRecorderOpcUaEditorForm.UsedTreeMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button <> mbLeft then Exit;
  fUsedMouseAnchor := nil;
  fUsedMouseSelecting := False;
end;

procedure TRecorderOpcUaEditorForm.SelectUsedVisibleRange(AFirst,
  ALast: TTreeNode);
var
  lInside, lPassedRange: Boolean;
  lNode: TTreeNode;
begin
  if (AFirst = nil) or (ALast = nil) then Exit;
  fUsedTree.Items.BeginUpdate;
  try
    lNode := fUsedTree.Items.GetFirstNode;
    while lNode <> nil do
    begin
      lNode.Selected := False;
      lNode := lNode.GetNext;
    end;

    lInside := False;
    lPassedRange := False;
    lNode := fUsedTree.Items.GetFirstNode;
    while lNode <> nil do
    begin
      if (lNode = AFirst) or (lNode = ALast) then
      begin
        if AFirst = ALast then
        begin
          lNode.Selected := True;
          Break;
        end;
        if lInside then
          lPassedRange := True
        else
          lInside := True;
      end;
      if lInside or lPassedRange then lNode.Selected := True;
      if lPassedRange then Break;
      lNode := lNode.GetNextVisible;
    end;
  finally
    fUsedTree.Items.EndUpdate;
  end;
end;

function CreateTreeItem(AFields: TStrings): TRecorderOpcUaTreeItem;
var
  I, lAccess, lArrayCount, lServerAccess, lUserAccess: Integer;
begin
  Result := nil;
  if AFields.Count < 6 then Exit;
  lServerAccess := StrToIntDef(AFields[4], 0);
  lUserAccess := StrToIntDef(AFields[5], 0);
  lAccess := lServerAccess and lUserAccess;
  Result := TRecorderOpcUaTreeItem.Create;
  Result.NodeId := AFields[0];
  Result.TagName := AFields[1];
  Result.BrowsePath := AFields[2];
  Result.TypeDefinition := AFields[3];
  Result.IsProperty := SameText(AFields[3], 'i=68') or
    SameText(AFields[3], 'ns=0;i=68');
  Result.Readable := (lAccess and $01) <> 0;
  Result.Writable := (lAccess and $02) <> 0;
  Result.ValueRank := -1;
  if AFields.Count > 6 then Result.DataTypeNodeId := AFields[6];
  if AFields.Count > 7 then Result.DataTypeName := AFields[7];
  if AFields.Count > 8 then Result.ValueText := AFields[8];
  if AFields.Count > 9 then Result.ValueRank := StrToIntDef(AFields[9], -1);
  if AFields.Count > 10 then Result.Historizing :=
    StrToBoolDef(AFields[10], False);
  if AFields.Count > 11 then Result.HistoryReadable :=
    StrToBoolDef(AFields[11], False);
  if AFields.Count > 12 then Result.HistoryWritable :=
    StrToBoolDef(AFields[12], False);
  if AFields.Count > 13 then Result.NodeClass :=
    Cardinal(StrToIntDef(AFields[13], 0));
  if AFields.Count > 14 then Result.ValueTimestamp := AFields[14];
  if AFields.Count > 15 then
  begin
    lArrayCount := StrToIntDef(AFields[15], 0);
    if lArrayCount > AFields.Count - 16 then
      lArrayCount := AFields.Count - 16;
    for I := 0 to lArrayCount - 1 do
      Result.ArrayValues.Add(AFields[16 + I]);
  end;
  if Result.DataTypeName = '' then Result.DataTypeName := Result.DataTypeNodeId;
  if Result.DataTypeName = '' then Result.DataTypeName := 'Неизвестный';
end;

procedure TRecorderOpcUaEditorForm.LoadBrowseLines(ALines: TStrings);
var
  I: Integer;
  lFields: TStringList;
  lSelectedNodeIds: TStringList;
begin
  lSelectedNodeIds := TStringList.Create;
  lFields := TStringList.Create;
  try
    CaptureBrowseSelection(lSelectedNodeIds);
    fBrowseTree.Items.BeginUpdate;
    try
      fBrowseTree.Items.Clear;
    finally
      fBrowseTree.Items.EndUpdate;
    end;
    fTreeItems.Clear;
    lFields.Delimiter := #9;
    lFields.StrictDelimiter := True;
    if ALines <> nil then
      for I := 0 to ALines.Count - 1 do
      begin
        lFields.DelimitedText := ALines[I];
        if lFields.Count >= 6 then
          fTreeItems.Add(CreateTreeItem(lFields));
      end;
    LinkIndexedArrayItems;
    RebuildBrowseTree(lSelectedNodeIds);
  finally
    lFields.Free;
    lSelectedNodeIds.Free;
  end;
  RebuildUsedTree;
  if (ALines <> nil) and (ALines.Count > 0) then
    AddDiagnostic(Format('Загружено сохранённое дерево OPC UA: %d узлов. ' +
      'Для повторного чтения нажмите «Обновить дерево».', [ALines.Count]));
end;

procedure TRecorderOpcUaEditorForm.AppendBrowseLines(ALines: TStrings);
var
  I: Integer;
  lFields: TStringList;
  lKnownNodeIds: TStringList;
  lAdded: Integer;
  lItem: TRecorderOpcUaTreeItem;
begin
  if ALines = nil then Exit;
  lFields := TStringList.Create;
  lKnownNodeIds := TStringList.Create;
  lAdded := 0;
  try
    lKnownNodeIds.CaseSensitive := True;
    lKnownNodeIds.Sorted := True;
    lKnownNodeIds.Duplicates := dupIgnore;
    for I := 0 to fTreeItems.Count - 1 do
      lKnownNodeIds.Add(TRecorderOpcUaTreeItem(fTreeItems[I]).NodeId);
    lFields.Delimiter := #9;
    lFields.StrictDelimiter := True;
    for I := 0 to ALines.Count - 1 do
    begin
      lFields.DelimitedText := ALines[I];
      if lFields.Count < 6 then Continue;
      if lKnownNodeIds.IndexOf(lFields[0]) >= 0 then Continue;
      lItem := CreateTreeItem(lFields);
      fTreeItems.Add(lItem);
      lKnownNodeIds.Add(lItem.NodeId);
      Inc(lAdded);
    end;
  finally
    lKnownNodeIds.Free;
    lFields.Free;
  end;
  LinkIndexedArrayItems;
  RebuildBrowseTree;
  AddDiagnostic(Format('Интерактивный Browse: добавлено узлов %d; всего в сессии %d.',
    [lAdded, fTreeItems.Count]));
end;

procedure TRecorderOpcUaEditorForm.AppendBrowseCacheLines(ALines: TStrings);
var
  I, J, lTabPos: Integer;
  lNodeId: string;
  lNewFields: TStringList;
  lFound: Boolean;
begin
  if ALines = nil then Exit;
  lNewFields := TStringList.Create;
  try
    lNewFields.Delimiter := #9;
    lNewFields.StrictDelimiter := True;
    for I := 0 to ALines.Count - 1 do
    begin
      lNewFields.DelimitedText := ALines[I];
      if lNewFields.Count < 6 then Continue;
      lNodeId := lNewFields[0];
      lFound := False;
      for J := 0 to fBrowseCache.Count - 1 do
      begin
        lTabPos := Pos(#9, fBrowseCache[J]);
        if lTabPos = 0 then Continue;
        if Copy(fBrowseCache[J], 1, lTabPos - 1) <> lNodeId then Continue;
        fBrowseCache[J] := ALines[I];
        lFound := True;
        Break;
      end;
      if not lFound then fBrowseCache.Add(ALines[I]);
    end;
    fBrowseCacheEndpoint := Trim(fEndpoint.Text);
  finally
    lNewFields.Free;
  end;
end;

function OfflineNodeName(const ANodeId, ARecorderName: string): string;
var
  I: Integer;
begin
  Result := Trim(ANodeId);
  I := LastDelimiter('.|/', Result);
  if I > 0 then Result := Copy(Result, I + 1, MaxInt);
  if Result = '' then Result := Trim(ARecorderName);
  if Result = '' then Result := ANodeId;
end;

procedure TRecorderOpcUaEditorForm.LoadConfiguredNodesAsOfflineTree;
var
  I: Integer;
  lAccess: string;
  lItem: TRecorderOpcUaTreeItem;
  lSelectedNodeIds: TStringList;
begin
  lSelectedNodeIds := TStringList.Create;
  try
    CaptureBrowseSelection(lSelectedNodeIds);
    fBrowseTree.Items.Clear;
    fTreeItems.Clear;
    for I := 1 to fValueGrid.RowCount - 1 do
    begin
      if Trim(fValueGrid.Cells[3, I]) = '' then Continue;
      lItem := TRecorderOpcUaTreeItem.Create;
      lItem.NodeId := fValueGrid.Cells[3, I];
      lItem.TagName := OfflineNodeName(lItem.NodeId, fValueGrid.Cells[0, I]);
      lItem.BrowsePath := 'Сохранённые используемые каналы/' + lItem.TagName;
      lItem.DataTypeNodeId := fValueGrid.Cells[7, I];
      lItem.DataTypeName := lItem.DataTypeNodeId;
      if lItem.DataTypeName = '' then lItem.DataTypeName := 'Неизвестный';
      lAccess := fValueGrid.Cells[2, I];
      lItem.Readable := Pos('Чтение', lAccess) > 0;
      lItem.Writable := Pos('запись', UTF8LowerCase(lAccess)) > 0;
      lItem.NodeClass := 2;
      fTreeItems.Add(lItem);
    end;
    RebuildBrowseTree(lSelectedNodeIds);
  finally
    lSelectedNodeIds.Free;
  end;
  if fTreeItems.Count > 0 then
    AddDiagnostic(Format('Полный Browse-кэш отсутствует. Восстановлены ' +
      '%d используемых каналов из конфигурации. Для полного дерева ' +
      'нажмите «Обновить дерево» и сохраните настройки.', [fTreeItems.Count]))
  else
    AddDiagnostic('Browse-кэш и сохранённые используемые каналы отсутствуют. ' +
      'Нажмите «Обновить дерево».');
end;

function OpcUaDeviceName(const APath: string): string;
var
  I: Integer;
  lParts: TStringList;
begin
  Result := '';
  lParts := TStringList.Create;
  try
    lParts.Delimiter := '/';
    lParts.StrictDelimiter := True;
    lParts.DelimitedText := APath;
    for I := 0 to lParts.Count - 2 do
      if SameText(Trim(lParts[I]), 'DeviceSet') then
        Exit(Trim(lParts[I + 1]));
    if (lParts.Count > 1) and SameText(Trim(lParts[0]), 'Objects') and
      not SameText(Trim(lParts[1]), 'Server') then
      Result := Trim(lParts[1]);
  finally
    lParts.Free;
  end;
end;

function IsPathChildOf(const APath, AParentPath: string): Boolean;
begin
  Result := (Length(APath) > Length(AParentPath)) and
    (Copy(APath, 1, Length(AParentPath)) = AParentPath) and
    (APath[Length(AParentPath) + 1] = '/');
end;

function IsDirectPathChildOf(const APath, AParentPath: string): Boolean;
var
  lTail: string;
begin
  Result := False;
  if not IsPathChildOf(APath, AParentPath) then Exit;
  lTail := Copy(APath, Length(AParentPath) + 2, MaxInt);
  Result := Pos('/', lTail) = 0;
end;

function IsIndexedArrayElementName(const AParentName,
  AChildName: string): Boolean;
var
  I, lIndex: Integer;
  lIndexText, lPrefix: string;
begin
  Result := False;
  if (AParentName = '') or (AChildName = '') then Exit;
  lPrefix := AParentName + '[';
  if (Pos(lPrefix, AChildName) <> 1) or
    (AChildName[Length(AChildName)] <> ']') then Exit;
  lIndexText := Copy(AChildName, Length(lPrefix) + 1,
    Length(AChildName) - Length(lPrefix) - 1);
  if lIndexText = '' then Exit;
  for I := 1 to Length(lIndexText) do
    if not (lIndexText[I] in ['0'..'9']) then Exit;
  Result := TryStrToInt(lIndexText, lIndex) and (lIndex >= 0);
end;

procedure TRecorderOpcUaEditorForm.LinkIndexedArrayItems;
var
  I, J: Integer;
  lChild, lParent: TRecorderOpcUaTreeItem;
begin
  for I := 0 to fTreeItems.Count - 1 do
  begin
    lChild := TRecorderOpcUaTreeItem(fTreeItems[I]);
    lChild.ArrayParent := nil;
    lChild.IsIndexedArrayElement := False;
    lChild.HasIndexedChildren := False;
  end;
  for I := 0 to fTreeItems.Count - 1 do
  begin
    lChild := TRecorderOpcUaTreeItem(fTreeItems[I]);
    for J := 0 to fTreeItems.Count - 1 do
    begin
      lParent := TRecorderOpcUaTreeItem(fTreeItems[J]);
      if (lParent = lChild) or
        ((lParent.ValueRank < 0) and (lParent.ArrayValues.Count = 0)) or
        not IsDirectPathChildOf(lChild.BrowsePath, lParent.BrowsePath) then
        Continue;
      lChild.ArrayParent := lParent;
      lChild.IsIndexedArrayElement := IsIndexedArrayElementName(
        lParent.TagName, lChild.TagName);
      if lChild.IsIndexedArrayElement then
        lParent.HasIndexedChildren := True;
      Break;
    end;
  end;
end;

function FindOwningChannel(AItems: TObjectList;
  AProperty: TRecorderOpcUaTreeItem): TRecorderOpcUaTreeItem;
var
  I, lBestLength: Integer;
  lCandidate: TRecorderOpcUaTreeItem;
  lDeviceName: string;
begin
  Result := nil;
  lBestLength := -1;
  lDeviceName := OpcUaDeviceName(AProperty.BrowsePath);
  for I := 0 to AItems.Count - 1 do
  begin
    lCandidate := TRecorderOpcUaTreeItem(AItems[I]);
    if lCandidate.IsProperty or
      not (lCandidate.Readable or lCandidate.Writable) or
      (lCandidate.TreeNode = nil) or
      not SameText(OpcUaDeviceName(lCandidate.BrowsePath), lDeviceName) then
      Continue;
    if IsPathChildOf(AProperty.BrowsePath, lCandidate.BrowsePath) and
      (Length(lCandidate.BrowsePath) > lBestLength) then
    begin
      Result := lCandidate;
      lBestLength := Length(lCandidate.BrowsePath);
    end;
  end;
end;

procedure AddArrayValueNodes(ATree: TTreeView; AParent: TTreeNode;
  AItem: TRecorderOpcUaTreeItem; const AFilter: string);
var
  I: Integer;
  lNeedle: string;
  lNode: TTreeNode;
  lShowAll: Boolean;
begin
  if (AParent = nil) or (AItem = nil) or
    (AItem.ArrayValues.Count = 0) then Exit;
  lNeedle := UTF8LowerCase(Trim(AFilter));
  lShowAll := (lNeedle = '') or
    (Pos(lNeedle, UTF8LowerCase(AItem.TagName)) > 0) or
    (Pos(lNeedle, UTF8LowerCase(AItem.NodeId)) > 0) or
    (Pos(lNeedle, UTF8LowerCase(AItem.BrowsePath)) > 0) or
    (Pos(lNeedle, UTF8LowerCase(AItem.DataTypeName)) > 0);
  for I := 0 to AItem.ArrayValues.Count - 1 do
  begin
    if not lShowAll and
      (Pos(lNeedle, UTF8LowerCase(AItem.ArrayValues[I])) = 0) then Continue;
    lNode := ATree.Items.AddChild(AParent,
      Format('%d = %s', [I + 1, AItem.ArrayValues[I]]));
    lNode.Data := nil;
    SetTreeNodeImage(lNode,
      TRecorderOpcUaEditorForm(ATree.Owner).DataTypeImageIndex(
      AItem.DataTypeNodeId, -1));
  end;
end;

procedure AddFullTreeNode(ATree: TTreeView; AItem: TRecorderOpcUaTreeItem);
var
  I: Integer;
  lCaption, lPart: string;
  lParent: TTreeNode;
  lParts: TStringList;
begin
  if (AItem = nil) or (AItem.TreeNode <> nil) then Exit;
  if AItem.ArrayParent <> nil then
  begin
    AddFullTreeNode(ATree, AItem.ArrayParent);
    lParent := AItem.ArrayParent.TreeNode;
  end
  else
  begin
    lParent := nil;
    lParts := TStringList.Create;
    try
      lParts.Delimiter := '/';
      lParts.StrictDelimiter := True;
      lParts.DelimitedText := AItem.BrowsePath;
      for I := 0 to lParts.Count - 2 do
      begin
        lPart := Trim(lParts[I]);
        if lPart <> '' then
        begin
          lParent := EnsureTreeChild(ATree, lParent, lPart);
          SetTreeNodeImage(lParent, CImageGroup);
        end;
      end;
    finally
      lParts.Free;
    end;
  end;
  if AItem.IsProperty and (AItem.ValueText <> '') then
  begin
    lCaption := AItem.TagName + ' = ' + AItem.ValueText;
    AItem.TreeNode := ATree.Items.AddChild(lParent, lCaption);
  end
  else
  begin
    lCaption := AItem.TagName;
    AItem.TreeNode := EnsureTreeItemChild(ATree, lParent, lCaption,
      AItem.NodeId);
  end;
  AItem.TreeNode.Data := AItem;
  if AItem.IsProperty then SetTreeNodeImage(AItem.TreeNode, CImageProperty)
  else SetTreeNodeImage(AItem.TreeNode,
    TRecorderOpcUaEditorForm(ATree.Owner).DataTypeImageIndex(
      AItem.DataTypeNodeId, AItem.ValueRank));
  if not AItem.HasIndexedChildren then
    AddArrayValueNodes(ATree, AItem.TreeNode, AItem,
      TRecorderOpcUaEditorForm(ATree.Owner).fTreeSearch.Text);
end;

procedure AddSimplifiedChannel(ATree: TTreeView;
  AItem: TRecorderOpcUaTreeItem);
var
  lAccessNode, lChannelsNode, lDeviceNode: TTreeNode;
  lDeviceName: string;
begin
  if (AItem = nil) or (AItem.TreeNode <> nil) or AItem.IsProperty or
    not (AItem.Readable or AItem.Writable) then Exit;
  if AItem.IsIndexedArrayElement and (AItem.ArrayParent <> nil) then
  begin
    AddSimplifiedChannel(ATree, AItem.ArrayParent);
    lAccessNode := AItem.ArrayParent.TreeNode;
  end
  else
  begin
    lDeviceName := OpcUaDeviceName(AItem.BrowsePath);
    if lDeviceName = '' then Exit;
    lDeviceNode := EnsureTreeChild(ATree, nil,
      UTF8Encode('Устройство: ') + lDeviceName);
    SetTreeNodeImage(lDeviceNode, CImageDevice);
    lChannelsNode := EnsureTreeChild(ATree, lDeviceNode, 'Каналы');
    SetTreeNodeImage(lChannelsNode, CImageGroup);
    if AItem.Writable and AItem.Readable then
      lAccessNode := EnsureTreeChild(ATree, lChannelsNode, 'Чтение и запись')
    else if AItem.Writable then
      lAccessNode := EnsureTreeChild(ATree, lChannelsNode, 'Только запись')
    else
      lAccessNode := EnsureTreeChild(ATree, lChannelsNode, 'Только чтение');
    SetTreeNodeImage(lAccessNode, CImageGroup);
  end;
  if lAccessNode = nil then Exit;
  AItem.TreeNode := ATree.Items.AddChild(lAccessNode, AItem.TagName);
  AItem.TreeNode.Data := AItem;
  SetTreeNodeImage(AItem.TreeNode,
    TRecorderOpcUaEditorForm(ATree.Owner).DataTypeImageIndex(
      AItem.DataTypeNodeId, AItem.ValueRank));
  if not AItem.HasIndexedChildren then
    AddArrayValueNodes(ATree, AItem.TreeNode, AItem,
      TRecorderOpcUaEditorForm(ATree.Owner).fTreeSearch.Text);
end;

procedure AddSimplifiedProperty(ATree: TTreeView; AItems: TObjectList;
  AItem: TRecorderOpcUaTreeItem);
var
  lDeviceName: string;
  lDeviceNode, lParent: TTreeNode;
  lOwner: TRecorderOpcUaTreeItem;
begin
  if not AItem.IsProperty then Exit;
  lDeviceName := OpcUaDeviceName(AItem.BrowsePath);
  if lDeviceName = '' then Exit;
  lOwner := FindOwningChannel(AItems, AItem);
  if lOwner <> nil then
    lParent := lOwner.TreeNode
  else
  begin
    lDeviceNode := EnsureTreeChild(ATree, nil,
      UTF8Encode('Устройство: ') + lDeviceName);
    SetTreeNodeImage(lDeviceNode, CImageDevice);
    lParent := EnsureTreeChild(ATree, lDeviceNode, 'Свойства');
    SetTreeNodeImage(lParent, CImageGroup);
  end;
  if lParent = nil then
  begin
    lDeviceNode := EnsureTreeChild(ATree, nil,
      UTF8Encode('Устройство: ') + lDeviceName);
    SetTreeNodeImage(lDeviceNode, CImageDevice);
    lParent := EnsureTreeChild(ATree, lDeviceNode, 'Свойства');
    SetTreeNodeImage(lParent, CImageGroup);
  end;
  if AItem.ValueText <> '' then
    AItem.TreeNode := ATree.Items.AddChild(lParent,
      AItem.TagName + ' = ' + AItem.ValueText)
  else
    AItem.TreeNode := ATree.Items.AddChild(lParent, AItem.TagName);
  AItem.TreeNode.Data := AItem;
  SetTreeNodeImage(AItem.TreeNode, CImageProperty);
  if not AItem.HasIndexedChildren then
    AddArrayValueNodes(ATree, AItem.TreeNode, AItem,
      TRecorderOpcUaEditorForm(ATree.Owner).fTreeSearch.Text);
end;

procedure TRecorderOpcUaEditorForm.CaptureBrowseSelection(ANodeIds: TStrings);
var
  I: Integer;
  lNode: TTreeNode;
  lItem: TRecorderOpcUaTreeItem;
begin
  if (ANodeIds = nil) or (fBrowseTree = nil) then Exit;
  for I := 0 to fBrowseTree.Items.Count - 1 do
  begin
    lNode := fBrowseTree.Items[I];
    if (lNode = nil) or not lNode.Selected or (lNode.Data = nil) then Continue;
    lItem := TRecorderOpcUaTreeItem(lNode.Data);
    if (lItem <> nil) and (lItem.NodeId <> '') and
      (ANodeIds.IndexOf(lItem.NodeId) < 0) then
      ANodeIds.Add(lItem.NodeId);
  end;
end;

procedure TRecorderOpcUaEditorForm.RebuildBrowseTree(
  ASelectedNodeIds: TStrings);
var
  I: Integer;
  lItem: TRecorderOpcUaTreeItem;
  lSelectedNodeIds: TStringList;
  lOwnSelectionList: Boolean;
begin
  lOwnSelectionList := ASelectedNodeIds = nil;
  if lOwnSelectionList then
  begin
    lSelectedNodeIds := TStringList.Create;
    ASelectedNodeIds := lSelectedNodeIds;
  end
  else
    lSelectedNodeIds := nil;
  try
    if lOwnSelectionList then
    begin
      CaptureBrowseSelection(ASelectedNodeIds);
    end;
    fBrowseTree.Items.BeginUpdate;
    try
      fBrowseTree.Items.Clear;
      for I := 0 to fTreeItems.Count - 1 do
        TRecorderOpcUaTreeItem(fTreeItems[I]).TreeNode := nil;
      if fSimplifiedTree.Checked then
      begin
        for I := 0 to fTreeItems.Count - 1 do
        begin
          lItem := TRecorderOpcUaTreeItem(fTreeItems[I]);
          if ItemOrDescendantMatchesSearch(lItem) then
            AddSimplifiedChannel(fBrowseTree, lItem);
        end;
        for I := 0 to fTreeItems.Count - 1 do
        begin
          lItem := TRecorderOpcUaTreeItem(fTreeItems[I]);
          if ItemMatchesSearch(lItem) then
            AddSimplifiedProperty(fBrowseTree, fTreeItems, lItem);
        end;
      end
      else
        for I := 0 to fTreeItems.Count - 1 do
        begin
          lItem := TRecorderOpcUaTreeItem(fTreeItems[I]);
          if ItemOrDescendantMatchesSearch(lItem) then
            AddFullTreeNode(fBrowseTree, lItem);
        end;
    finally
      fBrowseTree.Items.EndUpdate;
    end;
    ExpandConfiguredTreeNodes;
    for I := 0 to fTreeItems.Count - 1 do
    begin
      lItem := TRecorderOpcUaTreeItem(fTreeItems[I]);
      if (lItem.TreeNode <> nil) and
        (ASelectedNodeIds.IndexOf(lItem.NodeId) >= 0) then
        lItem.TreeNode.Selected := True;
    end;
  finally
    if lOwnSelectionList then lSelectedNodeIds.Free;
  end;
end;

function TRecorderOpcUaEditorForm.ItemMatchesSearch(
  AItem: TRecorderOpcUaTreeItem): Boolean;
var
  I: Integer;
  lNeedle: string;
begin
  lNeedle := UTF8LowerCase(Trim(fTreeSearch.Text));
  Result := (lNeedle = '') or
    (Pos(lNeedle, UTF8LowerCase(AItem.TagName)) > 0) or
    (Pos(lNeedle, UTF8LowerCase(AItem.NodeId)) > 0) or
    (Pos(lNeedle, UTF8LowerCase(AItem.BrowsePath)) > 0) or
    (Pos(lNeedle, UTF8LowerCase(AItem.DataTypeName)) > 0) or
    (Pos(lNeedle, UTF8LowerCase(AItem.ValueText)) > 0);
  if Result then Exit;
  for I := 0 to AItem.ArrayValues.Count - 1 do
    if Pos(lNeedle, UTF8LowerCase(AItem.ArrayValues[I])) > 0 then Exit(True);
end;

function TRecorderOpcUaEditorForm.ItemOrDescendantMatchesSearch(
  AItem: TRecorderOpcUaTreeItem): Boolean;
var
  I: Integer;
  lCandidate: TRecorderOpcUaTreeItem;
begin
  if ItemMatchesSearch(AItem) then Exit(True);
  Result := False;
  if Trim(fTreeSearch.Text) = '' then Exit(True);
  for I := 0 to fTreeItems.Count - 1 do
  begin
    lCandidate := TRecorderOpcUaTreeItem(fTreeItems[I]);
    if IsPathChildOf(lCandidate.BrowsePath, AItem.BrowsePath) and
      ItemMatchesSearch(lCandidate) then Exit(True);
  end;
end;

procedure TRecorderOpcUaEditorForm.ExpandConfiguredTreeNodes;
var
  I, J: Integer;
  lItem: TRecorderOpcUaTreeItem;
  lNode: TTreeNode;
begin
  for I := 0 to fTreeItems.Count - 1 do
  begin
    lItem := TRecorderOpcUaTreeItem(fTreeItems[I]);
    if lItem.TreeNode = nil then Continue;
    for J := 1 to fValueGrid.RowCount - 1 do
      if fValueGrid.Cells[3, J] = lItem.NodeId then
      begin
        fValueGrid.Cells[1, J] := lItem.DataTypeName;
        if lItem.ValueRank >= 0 then
          fValueGrid.Cells[1, J] := fValueGrid.Cells[1, J] + '[]';
        fValueGrid.Cells[7, J] := lItem.DataTypeNodeId;
        fValueGrid.Cells[12, J] := IntToStr(lItem.ValueRank);
        lNode := lItem.TreeNode;
        while lNode <> nil do
        begin
          lNode.Expanded := True;
          lNode := lNode.Parent;
        end;
        Break;
      end;
  end;
end;

procedure TRecorderOpcUaEditorForm.SimplifiedTreeChange(Sender: TObject);
begin
  RebuildBrowseTree;
end;

procedure TRecorderOpcUaEditorForm.TreeSearchChange(Sender: TObject);
begin
  RebuildBrowseTree;
end;

procedure TRecorderOpcUaEditorForm.ProbeFinished(Sender: TObject);
var
  I, J, lRow: Integer;
  lFields: TStringList;
  lItem: TRecorderOpcUaTreeItem;
  lEndpoint: string;
begin
  if fProbeThread = nil then Exit;
  if fProbeThread.Succeeded then
  begin
    if fProbeThread.Operation = opoDiscover then
    begin
      AddDiagnostic(Format('Найдено OPC UA серверов: %d; %d мс.',
        [fProbeThread.Lines.Count, fProbeThread.ElapsedMs]));
      lEndpoint := SelectDiscoveredOpcUaEndpoint(Self, fProbeThread.Lines);
      if lEndpoint <> '' then
      begin
        fEndpoint.Text := lEndpoint;
        AddDiagnostic('Выбран Endpoint: ' + lEndpoint);
      end;
    end
    else
    begin
      RecorderHardwareClearSourceOffline(RecorderOpcUaSourceId(
        Trim(fEndpoint.Text), oumClient));
      if fSourceId <> '' then
        RecorderHardwareClearSourceOffline(fSourceId);
      if fProbeThread.Operation = opoBrowse then
      begin
        fBrowseCache.Assign(fProbeThread.Lines);
        fBrowseCacheEndpoint := Trim(fEndpoint.Text);
        LoadBrowseLines(fBrowseCache);
        AddDiagnostic(Format('Browse завершён: Endpoint %s; узлов %d; %d мс.',
          [fBrowseCacheEndpoint, fProbeThread.Lines.Count,
           fProbeThread.ElapsedMs]));
      end
      else if fProbeThread.Operation = opoBrowseChildren then
      begin
        AppendBrowseCacheLines(fProbeThread.Lines);
        AppendBrowseLines(fProbeThread.Lines);
        lItem := FindTreeItemByNodeId(fInteractiveParentNodeId);
        if (lItem <> nil) and (lItem.TreeNode <> nil) then
          lItem.TreeNode.Selected := True;
        AddDiagnostic(Format('Ветка прочитана: %s; детей %d; %d мс.',
          [fInteractiveParentNodeId, fProbeThread.Lines.Count,
           fProbeThread.ElapsedMs]));
      end
      else if fProbeThread.Operation = opoRead then
      begin
        lFields := TStringList.Create;
        try
          lFields.Delimiter := #9;
          lFields.StrictDelimiter := True;
          for I := 0 to fProbeThread.Lines.Count - 1 do
          begin
            lFields.DelimitedText := fProbeThread.Lines[I];
            if lFields.Count < 5 then Continue;
            lRow := 0;
            for J := 1 to fValueGrid.RowCount - 1 do
              if fValueGrid.Cells[3, J] = lFields[1] then
              begin
                lRow := J;
                Break;
              end;
            if lRow = 0 then Continue;
            fValueGrid.Cells[4, lRow] := lFields[2];
            fValueGrid.Cells[5, lRow] := lFields[3];
            fValueGrid.Cells[6, lRow] := lFields[4];
            lItem := FindTreeItemByNodeId(lFields[1]);
            if lItem <> nil then
            begin
              lItem.ValueText := lFields[2];
              lItem.ValueTimestamp := lFields[4];
            end;
          end;
        finally
          lFields.Free;
        end;
        AddDiagnostic(Format('Прочитано значений: %d; %d мс.',
          [fProbeThread.Lines.Count, fProbeThread.ElapsedMs]));
        ShowSelectedNodeProperties;
      end
      else
        AddDiagnostic(Format('Соединение установлено; %d мс.',
          [fProbeThread.ElapsedMs]));
    end;
  end
  else
  begin
    if fProbeThread.Operation = opoDiscover then
      AddDiagnostic(UTF8Encode('Поиск OPC UA: ') + fProbeThread.ErrorText)
    else if fProbeThread.Operation = opoBrowse then
      AddDiagnostic(Format('Browse не выполнен: Endpoint %s; кэш этого адреса содержит %d узлов; %s',
        [Trim(fProbeThread.fEndpoint), fBrowseCache.Count,
         fProbeThread.ErrorText]))
    else if fProbeThread.Operation = opoBrowseChildren then
      AddDiagnostic(Format('Чтение ветки не выполнено: %s; %s',
        [fInteractiveParentNodeId, fProbeThread.ErrorText]))
    else if fProbeThread.ErrorText = '' then
      AddDiagnostic('Ошибка: операция OPC UA завершилась без диагностики')
    else
      AddDiagnostic(UTF8Encode('Ошибка: ') + fProbeThread.ErrorText);
  end;
  fProbeThread.Free;
  fProbeThread := nil;
  SetProbeRunning(False);
end;

procedure TRecorderOpcUaEditorForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := fProbeThread = nil;
  if not CanClose then
    AddDiagnostic('Дождитесь завершения сетевой операции.');
end;

procedure TRecorderOpcUaEditorForm.FormShow(Sender: TObject);
begin
  { Browse is explicit. The saved cache is loaded by the constructor, so
    opening settings never touches an unavailable controller. }
end;

procedure TRecorderOpcUaEditorForm.SaveToConfig(
  AConfig: TRecorderOpcUaConfig);
var
  I, lSessionTimeoutSeconds, lValue: Integer;
  lNode: TRecorderOpcUaNode;
begin
  AConfig.Mode := TRecorderOpcUaMode(fMode.ItemIndex);
  AConfig.Endpoint := Trim(fEndpoint.Text);
  if (AConfig.Mode = oumClient) and (fAuth.ItemIndex = 1) then
  begin
    AConfig.AuthenticationMode := ouamUserPassword;
    AConfig.UserName := Trim(fUserName.Text);
    AConfig.PasswordEnvironment := Trim(fPassword.Text);
  end
  else
  begin
    AConfig.AuthenticationMode := ouamAnonymous;
    AConfig.UserName := '';
    AConfig.PasswordEnvironment := '';
  end;
  AConfig.PublishingIntervalMs := Cardinal(StrToIntDef(
    fProtocolSettings.Cells[1, CProtocolRowInterval],
    CRecorderOpcUaDefaultPublishingIntervalMs));
  if AConfig.PublishingIntervalMs < 10 then
    AConfig.PublishingIntervalMs := 10;
  lSessionTimeoutSeconds := StrToIntDef(fSessionTimeout.Text,
    CRecorderOpcUaDefaultSessionTimeoutMs div 1000);
  if lSessionTimeoutSeconds < 1 then lSessionTimeoutSeconds := 1;
  if lSessionTimeoutSeconds > 3600 then lSessionTimeoutSeconds := 3600;
  AConfig.SessionTimeoutMs := Cardinal(lSessionTimeoutSeconds) * 1000;
  lValue := StrToIntDef(
    fProtocolSettings.Cells[1, CProtocolRowMaxRead],
    CRecorderOpcUaDefaultMaxNodesPerRequest);
  AConfig.MaxNodesPerRead := Cardinal(Max(1, lValue));
  lValue := StrToIntDef(
    fProtocolSettings.Cells[1, CProtocolRowMaxWrite],
    CRecorderOpcUaDefaultMaxNodesPerRequest);
  AConfig.MaxNodesPerWrite := Cardinal(Max(1, lValue));
  lValue := StrToIntDef(
    fProtocolSettings.Cells[1, CProtocolRowMaxBrowse],
    CRecorderOpcUaDefaultMaxNodesPerRequest);
  AConfig.MaxNodesPerBrowse := Cardinal(Max(1, lValue));
  lValue := StrToIntDef(
    fProtocolSettings.Cells[1, CProtocolRowBrowseTimeout],
    CRecorderOpcUaDefaultBrowseTimeoutMs div 1000);
  lValue := EnsureRange(lValue,
    Integer(CRecorderOpcUaMinimumBrowseTimeoutMs div 1000), 86400);
  AConfig.BrowseTimeoutMs := Cardinal(lValue) * 1000;
  lValue := StrToIntDef(
    fProtocolSettings.Cells[1, CProtocolRowTimeout],
    CRecorderOpcUaDefaultRequestTimeoutMs div 1000);
  AConfig.RequestTimeoutMs := Cardinal(Max(1, lValue)) * 1000;
  if SameText(Trim(fProtocolSettings.Cells[1, CProtocolRowTimestamp]),
    'Source') then
    AConfig.TimestampMode := outSource
  else if SameText(Trim(fProtocolSettings.Cells[1, CProtocolRowTimestamp]),
    'Both') then
    AConfig.TimestampMode := outBoth
  else if SameText(Trim(fProtocolSettings.Cells[1, CProtocolRowTimestamp]),
    'Neither') then
    AConfig.TimestampMode := outNeither
  else
    AConfig.TimestampMode := outServer;
  if SameText(Trim(fProtocolSettings.Cells[1, CProtocolRowMode]),
    'Subscribe') then
    AConfig.PollingType := ouptSubscription
  else
    AConfig.PollingType := ouptRead;
  AConfig.ArchiveEnabled := False;
  AConfig.SimplifiedTree := fSimplifiedTree.Checked;
  AConfig.BrowseCache.Assign(fBrowseCache);
  AConfig.BrowseCacheEndpoint := fBrowseCacheEndpoint;
  AConfig.Nodes.Clear;
  for I := 1 to fValueGrid.RowCount - 1 do
  begin
    if Trim(fValueGrid.Cells[3, I]) = '' then Continue;
    lNode := AConfig.AddNode(Trim(fValueGrid.Cells[3, I]),
      Trim(fValueGrid.Cells[0, I]), False, True,
      Trim(fValueGrid.Cells[7, I]), StrToIntDef(fValueGrid.Cells[12, I], -1));
    lNode.Readable := not SameText(fValueGrid.Cells[2, I], 'Только запись');
    lNode.Writable := SameText(fValueGrid.Cells[2, I], 'Чтение и запись') or
      SameText(fValueGrid.Cells[2, I], 'Только запись');
    lNode.Role := TRecorderOpcUaNodeRole(EnsureRange(
      StrToIntDef(fValueGrid.Cells[8, I], Ord(ounrAuto)),
      Ord(Low(TRecorderOpcUaNodeRole)), Ord(High(TRecorderOpcUaNodeRole))));
    lNode.MessageKind := RecorderMessageKindFromName(
      fValueGrid.Cells[9, I]);
    lNode.MessageColor := StrToIntDef(fValueGrid.Cells[10, I], -1);
    lNode.RecorderTagId := StrToInt64Def(fValueGrid.Cells[11, I], 0);
  end;
end;

function TRecorderOpcUaSourceEditor.SupportsSource(const ASourceId,
  AModuleType: string): Boolean;
begin
  Result := RecorderIsOpcUaSource(ASourceId, AModuleType);
end;

function TRecorderOpcUaSourceEditor.EditSource(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  out ANewSourceId: string; ADataSources: TRecorderDataSourceManager): Boolean;
var
  lConfig: TRecorderOpcUaConfig;
  lEntry, lOldEntry: TRecorderConfiguredDataSource;
  lForm: TRecorderOpcUaEditorForm;
  lLoadError: string;
begin
  Result := False;
  ANewSourceId := ASourceId;
  lConfig := TRecorderOpcUaConfig.Create;
  try
    lOldEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
    if (lOldEntry <> nil) and (Trim(lOldEntry.SpecificConfigText) <> '') and
      not lConfig.LoadJson(lOldEntry.SpecificConfigText, lLoadError) then
    begin
      MessageDlg('OPC UA', UTF8Encode('Ошибка конфигурации: ') + lLoadError,
        mtError, [mbOK], 0);
      Exit;
    end;
    lForm := TRecorderOpcUaEditorForm.CreateEditor(AOwner, lConfig,
      ARegistry, ASourceId);
    try
      if lForm.ShowModal <> mrOk then Exit;
      lForm.SaveToConfig(lConfig);
      ANewSourceId := UniqueOpcUaSourceId(ARegistry,
        RecorderOpcUaSourceId(lConfig.Endpoint, lConfig.Mode), ASourceId);
      if (ASourceId <> '') and not SameText(ASourceId, ANewSourceId) then
        RecorderConfiguredDataSourcesRemove(ARegistry, ASourceId);
      lEntry := RecorderConfiguredDataSourcesEnsure(ARegistry, ANewSourceId,
        CRecorderOpcUaModuleType, 1000.0 / lConfig.PublishingIntervalMs);
      PublishOpcUaClientTags(ARegistry, lConfig, ASourceId, ANewSourceId);
      lEntry.SpecificConfigText := lConfig.ToJson;
      ARegistry.RegisterActiveSource(ANewSourceId);
      Result := True;
    finally
      lForm.Free;
    end;
  finally
    lConfig.Free;
  end;
end;

var
  g_Editor: IRecorderConfiguredSourceEditor;

initialization
  g_Editor := TRecorderOpcUaSourceEditor.Create;
  RecorderRegisterConfiguredSourceEditor(g_Editor);

finalization
  g_Editor := nil;

end.
