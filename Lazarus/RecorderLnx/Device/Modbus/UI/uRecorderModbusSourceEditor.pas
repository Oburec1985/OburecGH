unit uRecorderModbusSourceEditor;

{
  Transactional LCL editor for a Modbus datasource. The form edits an owned
  draft tree; the registry and configured datasource are touched only after OK.
  Public tag addresses intentionally contain only datasource alias + tag alias,
  never the internal Bus/Device path used by the Modbus runtime.
}

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

uses
  Classes;

procedure RecorderModbusEditorResourceSmokeTest(AOwner: TComponent);
procedure RecorderModbusEditorCapture(const AFileName, AMode: string);

implementation

uses
  SysUtils, Math, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Dialogs,
  Contnrs, LazUTF8, LCLType, Graphics,
  uRecorderTags, uRecorderDataSources, uRecorderConfiguredDataSources,
  uRecorderConfiguredSourceEditor, uModbusCoreTypes,
  uRecorderModbusTransport, uRecorderModbusTcpTransport,
  uRecorderModbusRtuTransport;

type
  TModbusDraftKind = (mdkBus, mdkDevice, mdkTag);

  TModbusTagDraft = class
  public
    Id: string;
    Name: string;
    Description: string;
    UnitText: string;
    Scale: Double;
    Offset: Double;
    Region: Integer;
    Address: Integer;
    DataType: Integer;
    Endian: Integer;
    Access: Integer;
    Enabled: Boolean;
    function Clone: TModbusTagDraft;
  end;

  TModbusDeviceDraft = class
  public
    Id: string;
    Name: string;
    Description: string;
    UnitId: Integer;
    Enabled: Boolean;
    Tags: TObjectList;
    constructor Create;
    destructor Destroy; override;
    function Clone: TModbusDeviceDraft;
  end;

  TModbusNodeRef = class
  public
    Kind: TModbusDraftKind;
    Item: TObject;
  end;

  TModbusProbeThread = class(TThread)
  private
    fTransport: IRecorderModbusTransport;
    fResult: TRecorderModbusTransportResult;
  protected
    procedure Execute; override;
  public
    constructor Create(const ATransport: IRecorderModbusTransport);
    property ProbeResult: TRecorderModbusTransportResult read fResult;
  end;

  {$M+}
  TRecorderModbusEditorForm = class(TForm)
  published
    AccessCombo: TComboBox;
    AddressModeCombo: TComboBox;
    AddDeviceButton: TButton;
    AddTagButton: TButton;
    ApplyButton: TButton;
    AddressEdit: TEdit;
    AliasEdit: TEdit;
    BaudCombo: TComboBox;
    CancelButton: TButton;
    CanonicalLabel: TLabel;
    ConfigTree: TTreeView;
    DataTypeCombo: TComboBox;
    DeleteButton: TButton;
    DescriptionEdit: TEdit;
    DetailsPanel: TPanel;
    DeviceEnabledCheck: TCheckBox;
    DeviceNameEdit: TEdit;
    DevicePanel: TPanel;
    DiagnosticsMemo: TMemo;
    DuplicateButton: TButton;
    EndianCombo: TComboBox;
    FramingCombo: TComboBox;
    HostEdit: TEdit;
    NoSelectionLabel: TLabel;
    NotationLabel: TLabel;
    OffsetEdit: TEdit;
    OkButton: TButton;
    PollEdit: TEdit;
    PortEdit: TEdit;
    PreviewLabel: TLabel;
    RegionCombo: TComboBox;
    RetriesEdit: TEdit;
    RtuPanel: TPanel;
    ScaleEdit: TEdit;
    SearchEdit: TEdit;
    SerialEdit: TEdit;
    StatusLabel: TLabel;
    TagEnabledCheck: TCheckBox;
    TagNameEdit: TEdit;
    TagPanel: TPanel;
    TcpPanel: TPanel;
    TestButton: TButton;
    TimeoutEdit: TEdit;
    TopSplitter: TSplitter;
    TransportCombo: TComboBox;
    UnitIdEdit: TEdit;
    UnitEdit: TEdit;
    WorkspaceSplitter: TSplitter;
    DiagnosticsSplitter: TSplitter;
    procedure AddDeviceClick(Sender: TObject);
    procedure AddTagClick(Sender: TObject);
    procedure ApplyClick(Sender: TObject);
    procedure AddressModeChanged(Sender: TObject);
    procedure ConfigChanged(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure DetailChanged(Sender: TObject);
    procedure DuplicateClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure OkClick(Sender: TObject);
    procedure SearchChanged(Sender: TObject);
    procedure TestClick(Sender: TObject);
    procedure TransportChanged(Sender: TObject);
    procedure TreeSelectionChanged(Sender: TObject);
  private
    fConfig: TModbusBusConfig;
    fApplied: Boolean;
    fDevices: TObjectList;
    fNodeRefs: TObjectList;
    fLoading: Boolean;
    fProbeThread: TModbusProbeThread;
    function AddDevice(const AName: string; AUnitId: Integer): TModbusDeviceDraft;
    function AddTag(ADevice: TModbusDeviceDraft; const AName: string;
      AAddress: Integer): TModbusTagDraft;
    procedure AddDiagnostic(const AText: string);
    function CurrentDevice: TModbusDeviceDraft;
    function CurrentRef: TModbusNodeRef;
    function CurrentTag: TModbusTagDraft;
    function ItemMatches(const ADevice: TModbusDeviceDraft;
      ATag: TModbusTagDraft): Boolean;
    procedure LoadConfig;
    procedure LoadDetails;
    function NewNodeRef(AKind: TModbusDraftKind; AItem: TObject): TModbusNodeRef;
    procedure RebuildTree(ASelectItem: TObject = nil);
    procedure ProbeFinished(Sender: TObject);
    procedure SaveDetails;
    procedure SaveToConfig;
    procedure SetProbeRunning(ARunning: Boolean);
    function TryReadAddress(out ARegion: TModbusRegion;
      out AAddress: Word): Boolean;
    function TryReadFloat(AEdit: TEdit; out AValue: Double): Boolean;
    procedure UpdateAddressPreview;
    procedure UpdateControlState;
    function ValidateConfig(out AError: string): Boolean;
  public
    constructor CreateEditor(AOwner: TComponent; AConfig: TModbusBusConfig);
    destructor Destroy; override;
    property Applied: Boolean read fApplied;
  end;
  {$M-}

{$R *.lfm}

  TRecorderModbusSourceEditor = class(TInterfacedObject,
    IRecorderConfiguredSourceEditor)
  public
    function SupportsSource(const ASourceId, AModuleType: string): Boolean;
    function EditSource(AOwner: TComponent; ARegistry: TRecorderTagRegistry;
      const ASourceId: string; out ANewSourceId: string;
      ADataSources: TRecorderDataSourceManager): Boolean;
  end;

function UniqueModbusSourceId(ARegistry: TRecorderTagRegistry;
  const AAlias, AOldSourceId: string): string;
var
  lIndex: Integer;
  lBase: string;
begin
  lBase := RecorderModbusSourceId(AAlias);
  Result := lBase;
  if SameText(Result, AOldSourceId) or
    (RecorderConfiguredDataSourcesFind(ARegistry, Result) = nil) then Exit;
  lIndex := 2;
  repeat
    Result := lBase + ' [' + IntToStr(lIndex) + ']';
    Inc(lIndex);
  until RecorderConfiguredDataSourcesFind(ARegistry, Result) = nil;
end;

function FindPublishedTag(ARegistry: TRecorderTagRegistry;
  const AOldSourceId, ANewSourceId, AAddress: string): TRecorderTag;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ARegistry.TagCount - 1 do
    if SameText(ARegistry.Tags[I].Address, AAddress) and
      (SameText(ARegistry.Tags[I].SourceId, AOldSourceId) or
       SameText(ARegistry.Tags[I].SourceId, ANewSourceId)) then
      Exit(ARegistry.Tags[I]);
end;

function UniquePublishedName(ARegistry: TRecorderTagRegistry;
  const AAlias: string): string;
var
  lIndex: Integer;
begin
  Result := AAlias;
  if ARegistry.FindByName(Result) = nil then Exit;
  Result := AAlias + ' [Modbus]';
  lIndex := 2;
  while ARegistry.FindByName(Result) <> nil do
  begin
    Result := Format('%s [Modbus %d]', [AAlias, lIndex]);
    Inc(lIndex);
  end;
end;

procedure PublishModbusTags(ARegistry: TRecorderTagRegistry;
  AConfig: TModbusBusConfig; const AOldSourceId, ANewSourceId,
  AOldConfigText: string);
var
  I, J: Integer;
  lOldI, lOldJ: Integer;
  lFound: Boolean;
  lDevice: TModbusDeviceConfig;
  lConfigTag: TModbusTagConfig;
  lOldConfig: TModbusBusConfig;
  lTag: TRecorderTag;
  lAddress, lOldAddress: string;
begin
  lOldConfig := TModbusBusConfig.Create;
  try
    if Trim(AOldConfigText) <> '' then
      try lOldConfig.LoadJsonString(AOldConfigText); except lOldConfig.Clear; end;
    { Remove missing stable identities before assigning current leaves.  This
      makes delete A + create B with the same alias unambiguous: A is removed
      first and B receives a new Recorder tag. }
    for lOldI := 0 to lOldConfig.DeviceCount - 1 do
      for lOldJ := 0 to lOldConfig.DeviceAt(lOldI).TagCount - 1 do
      begin
        lFound := False;
        for I := 0 to AConfig.DeviceCount - 1 do
          for J := 0 to AConfig.DeviceAt(I).TagCount - 1 do
            if SameText(AConfig.DeviceAt(I).TagAt(J).Id,
              lOldConfig.DeviceAt(lOldI).TagAt(lOldJ).Id) then
              lFound := True;
        if lFound then Continue;
        lOldAddress := ModbusTagIdentity(lOldConfig.Alias,
          lOldConfig.DeviceAt(lOldI).TagAt(lOldJ).Alias);
        lTag := FindPublishedTag(ARegistry, AOldSourceId, ANewSourceId,
          lOldAddress);
        if lTag <> nil then ARegistry.RemoveTag(lTag);
      end;
    for I := 0 to AConfig.DeviceCount - 1 do
    begin
      lDevice := AConfig.DeviceAt(I);
      for J := 0 to lDevice.TagCount - 1 do
      begin
        lConfigTag := lDevice.TagAt(J);
        lAddress := ModbusTagIdentity(AConfig.Alias, lConfigTag.Alias);
        lTag := nil;
        { Stable config identity is authoritative across bus/tag renames. }
        for lOldI := 0 to lOldConfig.DeviceCount - 1 do
          for lOldJ := 0 to lOldConfig.DeviceAt(lOldI).TagCount - 1 do
            if SameText(lOldConfig.DeviceAt(lOldI).TagAt(lOldJ).Id,
              lConfigTag.Id) then
            begin
              lOldAddress := ModbusTagIdentity(lOldConfig.Alias,
                lOldConfig.DeviceAt(lOldI).TagAt(lOldJ).Alias);
              lTag := FindPublishedTag(ARegistry, AOldSourceId,
                ANewSourceId, lOldAddress);
            end;
        { Address fallback is only for a brand-new/legacy leaf with no old
          stable identity. Deleted stable identities were removed above. }
        if lTag = nil then
          lTag := FindPublishedTag(ARegistry, AOldSourceId, ANewSourceId,
            lAddress);
        if lTag = nil then
          lTag := ARegistry.CreateTag(UniquePublishedName(ARegistry,
            lConfigTag.Alias), 4096);
        lTag.SourceId := ANewSourceId;
        lTag.ModuleType := CRecorderModbusModuleType;
        lTag.Address := lAddress;
        lTag.Description := lConfigTag.Description;
        lTag.ExternalWriteAllowed := lConfigTag.Access = maReadWrite;
        lTag.PollFrequencyHz := 1000.0 / AConfig.PollIntervalMs;
      end;
    end;
  finally
    lOldConfig.Free;
  end;
end;

constructor TModbusProbeThread.Create(
  const ATransport: IRecorderModbusTransport);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fTransport := ATransport;
end;

procedure TModbusProbeThread.Execute;
begin
  try
    fResult := fTransport.Open;
    if fResult.Code = mtcOk then
      fTransport.Close;
  except
    on E: Exception do
      fResult := ModbusTransportError(mtcOpenFailed, mtsOpen,
        fTransport.Endpoint, E.Message);
  end;
  fTransport := nil;
end;

function TModbusTagDraft.Clone: TModbusTagDraft;
begin
  Result := TModbusTagDraft.Create;
  Result.Id := '';
  Result.Name := Name;
  Result.Description := Description;
  Result.UnitText := UnitText;
  Result.Scale := Scale;
  Result.Offset := Offset;
  Result.Region := Region;
  Result.Address := Address;
  Result.DataType := DataType;
  Result.Endian := Endian;
  Result.Access := Access;
  Result.Enabled := Enabled;
end;

constructor TModbusDeviceDraft.Create;
begin
  inherited Create;
  Tags := TObjectList.Create(True);
  Enabled := True;
end;

destructor TModbusDeviceDraft.Destroy;
begin
  Tags.Free;
  inherited Destroy;
end;

function TModbusDeviceDraft.Clone: TModbusDeviceDraft;
var
  I: Integer;
begin
  Result := TModbusDeviceDraft.Create;
  Result.Id := '';
  Result.Name := Name;
  Result.Description := Description;
  Result.UnitId := UnitId;
  Result.Enabled := Enabled;
  for I := 0 to Tags.Count - 1 do
    Result.Tags.Add(TModbusTagDraft(Tags[I]).Clone);
end;

constructor TRecorderModbusEditorForm.CreateEditor(AOwner: TComponent;
  AConfig: TModbusBusConfig);
begin
  inherited Create(AOwner);
  fConfig := AConfig;
  fApplied := False;
  fDevices := TObjectList.Create(True);
  fNodeRefs := TObjectList.Create(True);
  fLoading := True;
  try
    TransportCombo.ItemIndex := 0;
    BaudCombo.ItemIndex := 4;
    FramingCombo.ItemIndex := 0;
    RegionCombo.ItemIndex := 2;
    DataTypeCombo.ItemIndex := 1;
    EndianCombo.ItemIndex := 0;
    AccessCombo.ItemIndex := 0;
    AddressModeCombo.ItemIndex := 0;
    LoadConfig;
    RebuildTree;
  finally
    fLoading := False;
  end;
  UpdateControlState;
end;

destructor TRecorderModbusEditorForm.Destroy;
begin
  if fProbeThread <> nil then
  begin
    fProbeThread.OnTerminate := nil;
    fProbeThread.WaitFor;
    FreeAndNil(fProbeThread);
  end;
  fNodeRefs.Free;
  fDevices.Free;
  inherited Destroy;
end;

function TRecorderModbusEditorForm.AddDevice(const AName: string;
  AUnitId: Integer): TModbusDeviceDraft;
begin
  Result := TModbusDeviceDraft.Create;
  Result.Name := AName;
  Result.UnitId := AUnitId;
  fDevices.Add(Result);
end;

function TRecorderModbusEditorForm.AddTag(ADevice: TModbusDeviceDraft;
  const AName: string; AAddress: Integer): TModbusTagDraft;
begin
  Result := TModbusTagDraft.Create;
  Result.Name := AName;
  Result.Address := AAddress;
  Result.Region := 2;
  Result.DataType := 1;
  Result.Endian := 0;
  Result.Access := 0;
  Result.Enabled := True;
  Result.Scale := 1.0;
  ADevice.Tags.Add(Result);
end;

procedure TRecorderModbusEditorForm.AddDiagnostic(const AText: string);
begin
  DiagnosticsMemo.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AText);
end;

function TRecorderModbusEditorForm.NewNodeRef(AKind: TModbusDraftKind;
  AItem: TObject): TModbusNodeRef;
begin
  Result := TModbusNodeRef.Create;
  Result.Kind := AKind;
  Result.Item := AItem;
  fNodeRefs.Add(Result);
end;

function TRecorderModbusEditorForm.CurrentRef: TModbusNodeRef;
begin
  Result := nil;
  if ConfigTree.Selected <> nil then
    Result := TModbusNodeRef(ConfigTree.Selected.Data);
end;

function TRecorderModbusEditorForm.CurrentDevice: TModbusDeviceDraft;
var
  lRef: TModbusNodeRef;
begin
  Result := nil;
  lRef := CurrentRef;
  if lRef = nil then Exit;
  if lRef.Kind = mdkDevice then
    Result := TModbusDeviceDraft(lRef.Item)
  else if (lRef.Kind = mdkTag) and (ConfigTree.Selected.Parent <> nil) then
    Result := TModbusDeviceDraft(
      TModbusNodeRef(ConfigTree.Selected.Parent.Data).Item);
end;

function TRecorderModbusEditorForm.CurrentTag: TModbusTagDraft;
var
  lRef: TModbusNodeRef;
begin
  Result := nil;
  lRef := CurrentRef;
  if (lRef <> nil) and (lRef.Kind = mdkTag) then
    Result := TModbusTagDraft(lRef.Item);
end;

function TRecorderModbusEditorForm.ItemMatches(
  const ADevice: TModbusDeviceDraft; ATag: TModbusTagDraft): Boolean;
var
  lNeedle, lText: string;
begin
  lNeedle := UTF8LowerCase(Trim(SearchEdit.Text));
  if lNeedle = '' then Exit(True);
  lText := ADevice.Name;
  lText := lText + ' ' + IntToStr(ADevice.UnitId);
  if ATag <> nil then
    lText := lText + ' ' + ATag.Name + ' ' + ATag.Description + ' ' +
      IntToStr(ATag.Address) + ' ' +
      FormatReferenceAddress(TModbusRegion(ATag.Region), ATag.Address) + ' ' +
      ModbusRegionName(TModbusRegion(ATag.Region)) + ' ' +
      ModbusRegionDisplayName(TModbusRegion(ATag.Region));
  Result := Pos(lNeedle, UTF8LowerCase(lText)) > 0;
end;

procedure TRecorderModbusEditorForm.RebuildTree(ASelectItem: TObject);
var
  I, J: Integer;
  lBusNode, lDeviceNode, lTagNode, lSelected: TTreeNode;
  lDevice: TModbusDeviceDraft;
  lTag: TModbusTagDraft;
  lHasMatchingTag: Boolean;
begin
  ConfigTree.BeginUpdate;
  try
    ConfigTree.Items.Clear;
    fNodeRefs.Clear;
    lSelected := nil;
    lBusNode := ConfigTree.Items.AddObject(nil, 'Шина: ' + AliasEdit.Text,
      NewNodeRef(mdkBus, nil));
    for I := 0 to fDevices.Count - 1 do
    begin
      lDevice := TModbusDeviceDraft(fDevices[I]);
      lHasMatchingTag := ItemMatches(lDevice, nil);
      for J := 0 to lDevice.Tags.Count - 1 do
        lHasMatchingTag := lHasMatchingTag or
          ItemMatches(lDevice, TModbusTagDraft(lDevice.Tags[J]));
      if not lHasMatchingTag then Continue;
      lDeviceNode := ConfigTree.Items.AddChildObject(lBusNode,
        Format('%s  [Unit %d]', [lDevice.Name, lDevice.UnitId]),
        NewNodeRef(mdkDevice, lDevice));
      if lDevice = ASelectItem then lSelected := lDeviceNode;
      for J := 0 to lDevice.Tags.Count - 1 do
      begin
        lTag := TModbusTagDraft(lDevice.Tags[J]);
        if not ItemMatches(lDevice, lTag) then Continue;
        lTagNode := ConfigTree.Items.AddChildObject(lDeviceNode,
          Format('%s  [%d]', [lTag.Name, lTag.Address]),
          NewNodeRef(mdkTag, lTag));
        if lTag = ASelectItem then lSelected := lTagNode;
      end;
      lDeviceNode.Expand(False);
    end;
    lBusNode.Expand(False);
    if lSelected <> nil then ConfigTree.Selected := lSelected;
  finally
    ConfigTree.EndUpdate;
  end;
  LoadDetails;
  UpdateControlState;
end;

procedure TRecorderModbusEditorForm.LoadDetails;
var
  lDevice: TModbusDeviceDraft;
  lTag: TModbusTagDraft;
begin
  fLoading := True;
  try
    lDevice := CurrentDevice;
    lTag := CurrentTag;
    DevicePanel.Visible := (lDevice <> nil) and (lTag = nil);
    TagPanel.Visible := lTag <> nil;
    NoSelectionLabel.Visible := (lDevice = nil) and (lTag = nil);
    if DevicePanel.Visible then
    begin
      DeviceNameEdit.Text := lDevice.Name;
      UnitIdEdit.Text := IntToStr(lDevice.UnitId);
      DeviceEnabledCheck.Checked := lDevice.Enabled;
    end;
    if TagPanel.Visible then
    begin
      TagNameEdit.Text := lTag.Name;
      DescriptionEdit.Text := lTag.Description;
      RegionCombo.ItemIndex := lTag.Region;
      if AddressModeCombo.ItemIndex = 1 then
        AddressEdit.Text := FormatReferenceAddress(TModbusRegion(lTag.Region),
          lTag.Address)
      else
        AddressEdit.Text := IntToStr(lTag.Address);
      if TModbusRegion(lTag.Region) in [mrCoil, mrDiscreteInput] then
        DataTypeCombo.ItemIndex := Ord(mdBool)
      else
        DataTypeCombo.ItemIndex := lTag.DataType;
      EndianCombo.ItemIndex := lTag.Endian;
      AccessCombo.ItemIndex := lTag.Access;
      TagEnabledCheck.Checked := lTag.Enabled;
      UnitEdit.Text := lTag.UnitText;
      ScaleEdit.Text := FloatToStr(lTag.Scale);
      OffsetEdit.Text := FloatToStr(lTag.Offset);
    end;
  finally
    fLoading := False;
  end;
  UpdateAddressPreview;
end;

procedure TRecorderModbusEditorForm.SaveDetails;
var
  lDevice: TModbusDeviceDraft;
  lTag: TModbusTagDraft;
  lRegion: TModbusRegion;
  lAddress: Word;
  lValue: Double;
begin
  if fLoading then Exit;
  lDevice := CurrentDevice;
  lTag := CurrentTag;
  if (lDevice <> nil) and (lTag = nil) then
  begin
    lDevice.Name := Trim(DeviceNameEdit.Text);
    lDevice.UnitId := StrToIntDef(UnitIdEdit.Text, -1);
    lDevice.Enabled := DeviceEnabledCheck.Checked;
  end;
  if lTag <> nil then
  begin
    lTag.Name := Trim(TagNameEdit.Text);
    lTag.Description := Trim(DescriptionEdit.Text);
    if TryReadAddress(lRegion, lAddress) then
    begin
      lTag.Region := Ord(lRegion);
      lTag.Address := lAddress;
    end;
    if TModbusRegion(lTag.Region) in [mrCoil, mrDiscreteInput] then
      lTag.DataType := Ord(mdBool)
    else
      lTag.DataType := DataTypeCombo.ItemIndex;
    lTag.Endian := EndianCombo.ItemIndex;
    lTag.Access := AccessCombo.ItemIndex;
    lTag.Enabled := TagEnabledCheck.Checked;
    lTag.UnitText := Trim(UnitEdit.Text);
    if TryReadFloat(ScaleEdit, lValue) then lTag.Scale := lValue;
    if TryReadFloat(OffsetEdit, lValue) then lTag.Offset := lValue;
  end;
  UpdateAddressPreview;
end;

procedure TRecorderModbusEditorForm.UpdateAddressPreview;
var
  lTag: TModbusTagDraft;
  lRegion: Integer;
begin
  lTag := CurrentTag;
  if lTag = nil then
  begin
    NotationLabel.Caption := 'Человеческая запись: —';
    CanonicalLabel.Caption := 'Канонический адрес: —';
    PreviewLabel.Caption := 'Публичный адрес: ' + Trim(AliasEdit.Text);
    Exit;
  end;
  lRegion := EnsureRange(lTag.Region, 0, 3);
  NotationLabel.Caption := 'Человеческая запись: ' +
    FormatReferenceAddress(TModbusRegion(lRegion), lTag.Address);
  CanonicalLabel.Caption := Format('Канонический адрес: %s:%d; хранится '
    + 'zero-based, внутренний путь устройства наружу не публикуется.',
    [ModbusRegionName(TModbusRegion(lRegion)), lTag.Address]);
  PreviewLabel.Caption := Format('Публичный адрес: %s/%s',
    [Trim(AliasEdit.Text), Trim(lTag.Name)]);
end;

procedure TRecorderModbusEditorForm.UpdateControlState;
var
  lRef: TModbusNodeRef;
  lBitChannel: Boolean;
begin
  lRef := CurrentRef;
  AddTagButton.Enabled := CurrentDevice <> nil;
  DuplicateButton.Enabled := (lRef <> nil) and (lRef.Kind <> mdkBus);
  DeleteButton.Enabled := DuplicateButton.Enabled;
  TcpPanel.Visible := TransportCombo.ItemIndex = 0;
  RtuPanel.Visible := TransportCombo.ItemIndex = 1;
  lBitChannel := (CurrentTag <> nil) and
    (RegionCombo.ItemIndex in [Ord(mrCoil), Ord(mrDiscreteInput)]);
  DataTypeCombo.Enabled := (CurrentTag <> nil) and not lBitChannel;
  EndianCombo.Enabled := (CurrentTag <> nil) and not lBitChannel and
    (DataTypeCombo.ItemIndex >= Ord(mdUInt32));
end;

procedure TRecorderModbusEditorForm.AddDeviceClick(Sender: TObject);
var
  lDevice: TModbusDeviceDraft;
begin
  lDevice := AddDevice(Format('Устройство %d', [fDevices.Count + 1]),
    fDevices.Count + 1);
  RebuildTree(lDevice);
end;

procedure TRecorderModbusEditorForm.AddTagClick(Sender: TObject);
var
  lDevice: TModbusDeviceDraft;
  lTag: TModbusTagDraft;
begin
  lDevice := CurrentDevice;
  if lDevice = nil then Exit;
  lTag := AddTag(lDevice, Format('Тег %d', [lDevice.Tags.Count + 1]),
    lDevice.Tags.Count);
  RebuildTree(lTag);
end;

procedure TRecorderModbusEditorForm.DuplicateClick(Sender: TObject);
var
  lDevice, lCopyDevice: TModbusDeviceDraft;
  lTag, lCopyTag: TModbusTagDraft;
begin
  lTag := CurrentTag;
  lDevice := CurrentDevice;
  if lTag <> nil then
  begin
    lCopyTag := lTag.Clone;
    lCopyTag.Name := lCopyTag.Name + ' копия';
    lDevice.Tags.Add(lCopyTag);
    RebuildTree(lCopyTag);
  end
  else if lDevice <> nil then
  begin
    lCopyDevice := lDevice.Clone;
    lCopyDevice.Name := lCopyDevice.Name + ' копия';
    fDevices.Add(lCopyDevice);
    RebuildTree(lCopyDevice);
  end;
end;

procedure TRecorderModbusEditorForm.DeleteClick(Sender: TObject);
var
  lDevice: TModbusDeviceDraft;
  lTag: TModbusTagDraft;
begin
  lTag := CurrentTag;
  lDevice := CurrentDevice;
  if lTag <> nil then
    lDevice.Tags.Remove(lTag)
  else if lDevice <> nil then
    fDevices.Remove(lDevice)
  else
    Exit;
  RebuildTree;
end;

procedure TRecorderModbusEditorForm.ConfigChanged(Sender: TObject);
begin
  if fLoading then Exit;
  UpdateAddressPreview;
end;

procedure TRecorderModbusEditorForm.DetailChanged(Sender: TObject);
var
  lTag: TModbusTagDraft;
begin
  if fLoading then Exit;
  lTag := CurrentTag;
  if (Sender = RegionCombo) and (lTag <> nil) then
  begin
    lTag.Region := RegionCombo.ItemIndex;
    fLoading := True;
    try
      if TModbusRegion(lTag.Region) in [mrCoil, mrDiscreteInput] then
      begin
        lTag.DataType := Ord(mdBool);
        DataTypeCombo.ItemIndex := Ord(mdBool);
      end;
      if AddressModeCombo.ItemIndex = 1 then
        AddressEdit.Text := FormatReferenceAddress(TModbusRegion(lTag.Region),
          lTag.Address);
    finally
      fLoading := False;
    end;
  end;
  SaveDetails;
  UpdateControlState;
end;

procedure TRecorderModbusEditorForm.AddressModeChanged(Sender: TObject);
begin
  if not fLoading then LoadDetails;
end;

function TRecorderModbusEditorForm.TryReadAddress(out ARegion: TModbusRegion;
  out AAddress: Word): Boolean;
var
  lValue: Int64;
begin
  ARegion := TModbusRegion(EnsureRange(RegionCombo.ItemIndex, 0, 3));
  AAddress := 0;
  if AddressModeCombo.ItemIndex = 1 then
  begin
    Result := TryParseReferenceAddress(AddressEdit.Text, ARegion, AAddress);
    Result := Result and (Ord(ARegion) = RegionCombo.ItemIndex);
    Exit;
  end;
  Result := TryStrToInt64(Trim(AddressEdit.Text), lValue) and
    (lValue >= 0) and (lValue <= High(Word));
  if Result then AAddress := Word(lValue);
end;

function TRecorderModbusEditorForm.TryReadFloat(AEdit: TEdit;
  out AValue: Double): Boolean;
begin
  Result := TryStrToFloat(Trim(AEdit.Text), AValue, DefaultFormatSettings) and
    not IsNan(AValue) and not IsInfinite(AValue);
end;

procedure TRecorderModbusEditorForm.TransportChanged(Sender: TObject);
begin
  UpdateControlState;
end;

procedure TRecorderModbusEditorForm.TreeSelectionChanged(Sender: TObject);
begin
  LoadDetails;
  UpdateControlState;
end;

procedure TRecorderModbusEditorForm.SearchChanged(Sender: TObject);
begin
  if not fLoading then RebuildTree;
end;

procedure TRecorderModbusEditorForm.TestClick(Sender: TObject);
var
  lPort, lBaud, lDataBits, lStopBits, lTimeout: Integer;
  lFrame: string;
  lParity: TRecorderModbusParity;
  lTransport: IRecorderModbusTransport;
begin
  if fProbeThread <> nil then Exit;
  if TransportCombo.ItemIndex = Ord(mtTcp) then
  begin
    if (Trim(HostEdit.Text) = '') or not TryStrToInt(PortEdit.Text, lPort) or
      (lPort < 1) or (lPort > 65535) then
    begin
      AddDiagnostic('Ошибка: укажите TCP host и порт 1..65535.');
      Exit;
    end;
    if not TryStrToInt(TimeoutEdit.Text, lTimeout) or (lTimeout < 1) then
      lTimeout := 1000;
    lTransport := TRecorderModbusTcpTransport.Create(Trim(HostEdit.Text),
      Word(lPort), Cardinal(lTimeout));
  end
  else
  begin
    lFrame := FramingCombo.Text;
    if (Trim(SerialEdit.Text) = '') or
      not TryStrToInt(BaudCombo.Text, lBaud) or (lBaud <= 0) or
      (Length(lFrame) <> 3) then
    begin
      AddDiagnostic('Ошибка: укажите RTU порт, скорость и формат кадра.');
      Exit;
    end;
    lDataBits := StrToIntDef(Copy(lFrame, 1, 1), 0);
    lStopBits := StrToIntDef(Copy(lFrame, 3, 1), 0);
    case UpCase(lFrame[2]) of
      'E': lParity := mpEven;
      'O': lParity := mpOdd;
    else
      lParity := mpNone;
    end;
    lTransport := TRecorderModbusRtuTransport.Create(Trim(SerialEdit.Text),
      lBaud, lDataBits, lParity, lStopBits);
  end;
  fProbeThread := TModbusProbeThread.Create(lTransport);
  fProbeThread.OnTerminate := @ProbeFinished;
  SetProbeRunning(True);
  AddDiagnostic('Проверка подключения запущена...');
  fProbeThread.Start;
end;

procedure TRecorderModbusEditorForm.SetProbeRunning(ARunning: Boolean);
begin
  TestButton.Enabled := not ARunning;
  OkButton.Enabled := not ARunning;
  ApplyButton.Enabled := not ARunning;
  if ARunning then StatusLabel.Caption := 'Подключение...';
end;

procedure TRecorderModbusEditorForm.ProbeFinished(Sender: TObject);
var
  lResult: TRecorderModbusTransportResult;
begin
  if fProbeThread = nil then Exit;
  lResult := fProbeThread.ProbeResult;
  if lResult.Code = mtcOk then
  begin
    StatusLabel.Caption := 'Связь установлена';
    AddDiagnostic('Успешно: транспорт открыт и закрыт.');
  end
  else
  begin
    StatusLabel.Caption := 'Ошибка подключения';
    AddDiagnostic(Format('Ошибка %d, %s: %s', [Ord(lResult.Code),
      lResult.Endpoint, lResult.Detail]));
  end;
  FreeAndNil(fProbeThread);
  SetProbeRunning(False);
end;

function TRecorderModbusEditorForm.ValidateConfig(out AError: string): Boolean;
var
  I, J, K, L, lPoll, lTimeout, lRetries, lPort, lBaud, lSpan: Integer;
  lDevice: TModbusDeviceDraft;
  lOtherDevice: TModbusDeviceDraft;
  lTag: TModbusTagDraft;
  lOtherTag: TModbusTagDraft;
  lRegion: TModbusRegion;
  lAddress: Word;
  lValue: Double;
  lFrame: string;
begin
  Result := False;
  AError := '';
  if Trim(AliasEdit.Text) = '' then AError := 'Укажите алиас datasource.';
  if not TryStrToInt(PollEdit.Text, lPoll) then lPoll := 0;
  if not TryStrToInt(TimeoutEdit.Text, lTimeout) then lTimeout := 0;
  if not TryStrToInt(RetriesEdit.Text, lRetries) then lRetries := -1;
  if (AError = '') and (lPoll < 1) then AError := 'Интервал опроса должен быть больше нуля.';
  if (AError = '') and (lTimeout < 1) then AError := 'Таймаут должен быть больше нуля.';
  if (AError = '') and ((lRetries < 0) or (lRetries > 20)) then AError := 'Число повторов должно быть от 0 до 20.';
  if TransportCombo.ItemIndex = Ord(mtTcp) then
  begin
    if (AError = '') and (Trim(HostEdit.Text) = '') then
      AError := 'Укажите TCP host.';
    if not TryStrToInt(PortEdit.Text, lPort) then lPort := 0;
    if (AError = '') and ((lPort < 1) or (lPort > 65535)) then
      AError := 'TCP порт должен быть 1..65535.';
  end
  else
  begin
    if (AError = '') and (Trim(SerialEdit.Text) = '') then
      AError := 'Укажите последовательный порт RTU.';
    if not TryStrToInt(BaudCombo.Text, lBaud) then lBaud := 0;
    if (AError = '') and (lBaud <= 0) then AError := 'Скорость RTU должна быть положительной.';
    lFrame := FramingCombo.Text;
    if (AError = '') and ((Length(lFrame) <> 3) or
      not (lFrame[1] in ['7', '8']) or not (UpCase(lFrame[2]) in ['N', 'E', 'O']) or
      not (lFrame[3] in ['1', '2'])) then AError := 'Некорректный формат RTU кадра.';
  end;
  if (AError = '') and (CurrentTag <> nil) and
    not TryReadAddress(lRegion, lAddress) then
    AError := 'Адрес не соответствует выбранной области или режиму ввода.';
  if (AError = '') and (CurrentTag <> nil) and not TryReadFloat(ScaleEdit, lValue) then
    AError := 'Некорректный масштаб.';
  if (AError = '') and (CurrentTag <> nil) and not TryReadFloat(OffsetEdit, lValue) then
    AError := 'Некорректное смещение.';
  for I := 0 to fDevices.Count - 1 do
  begin
    lDevice := TModbusDeviceDraft(fDevices[I]);
    if (AError = '') and (Trim(lDevice.Name) = '') then
      AError := 'У устройства не задан алиас.';
    if (AError = '') and ((lDevice.UnitId < 1) or (lDevice.UnitId > 247)) then
      AError := Format('Unit ID устройства "%s" должен быть 1..247.', [lDevice.Name]);
    for K := 0 to I - 1 do
    begin
      lOtherDevice := TModbusDeviceDraft(fDevices[K]);
      if (AError = '') and SameText(lOtherDevice.Name, lDevice.Name) then
        AError := 'Повторяется алиас устройства: ' + lDevice.Name;
      if (AError = '') and (lOtherDevice.UnitId = lDevice.UnitId) then
        AError := Format('Повторяется Unit ID %d.', [lDevice.UnitId]);
    end;
    for J := 0 to lDevice.Tags.Count - 1 do
    begin
      lTag := TModbusTagDraft(lDevice.Tags[J]);
      if (AError = '') and (Trim(lTag.Name) = '') then AError := 'У тега не задано имя.';
      if (AError = '') and (lTag.Region in [1, 2]) and (lTag.Access <> 0) then
        AError := Format('Discrete/Input Register "%s" доступен только для чтения.', [lTag.Name]);
      if lTag.Region in [Ord(mrCoil), Ord(mrDiscreteInput)] then
        lSpan := 1
      else case lTag.DataType of
        Ord(mdUInt32), Ord(mdInt32), Ord(mdFloat32): lSpan := 2;
        Ord(mdFloat64): lSpan := 4;
      else
        lSpan := 1;
      end;
      if (AError = '') and (lTag.Address + lSpan - 1 > 65535) then
        AError := Format('Тег "%s" выходит за адрес 65535.', [lTag.Name]);
      for K := 0 to fDevices.Count - 1 do
        for L := 0 to TModbusDeviceDraft(fDevices[K]).Tags.Count - 1 do
        begin
          lOtherTag := TModbusTagDraft(TModbusDeviceDraft(fDevices[K]).Tags[L]);
          if (lOtherTag = lTag) then Break;
          if (AError = '') and SameText(lOtherTag.Name, lTag.Name) then
            AError := 'Повторяется публичный алиас тега: ' + lTag.Name;
        end;
    end;
  end;
  Result := AError = '';
end;

procedure TRecorderModbusEditorForm.OkClick(Sender: TObject);
var
  lError: string;
begin
  SaveDetails;
  if ValidateConfig(lError) then Exit;
  ModalResult := mrNone;
  AddDiagnostic('Ошибка: ' + lError);
  MessageDlg('Modbus Master', lError, mtError, [mbOK], 0);
end;

procedure TRecorderModbusEditorForm.ApplyClick(Sender: TObject);
var
  lError: string;
begin
  SaveDetails;
  if not ValidateConfig(lError) then
  begin
    AddDiagnostic('Ошибка: ' + lError);
    MessageDlg('Modbus Master', lError, mtError, [mbOK], 0);
    Exit;
  end;
  SaveToConfig;
  fApplied := True;
  AddDiagnostic('Настройки применены.');
end;

procedure TRecorderModbusEditorForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := fProbeThread = nil;
  if not CanClose then
    AddDiagnostic('Дождитесь завершения проверки подключения.');
end;

procedure TRecorderModbusEditorForm.LoadConfig;
var
  I, J: Integer;
  lSourceDevice: TModbusDeviceConfig;
  lSourceTag: TModbusTagConfig;
  lDevice: TModbusDeviceDraft;
  lTag: TModbusTagDraft;
begin
  AliasEdit.Text := fConfig.Alias;
  TransportCombo.ItemIndex := Ord(fConfig.Transport);
  PollEdit.Text := IntToStr(fConfig.PollIntervalMs);
  TimeoutEdit.Text := IntToStr(fConfig.TimeoutMs);
  RetriesEdit.Text := IntToStr(fConfig.Retries);
  HostEdit.Text := fConfig.Host;
  PortEdit.Text := IntToStr(fConfig.Port);
  SerialEdit.Text := fConfig.SerialPort;
  BaudCombo.ItemIndex := BaudCombo.Items.IndexOf(IntToStr(fConfig.BaudRate));
  if BaudCombo.ItemIndex < 0 then BaudCombo.ItemIndex := 0;
  FramingCombo.ItemIndex := FramingCombo.Items.IndexOf(
    IntToStr(fConfig.DataBits) + fConfig.Parity + IntToStr(fConfig.StopBits));
  if FramingCombo.ItemIndex < 0 then FramingCombo.ItemIndex := 0;
  for I := 0 to fConfig.DeviceCount - 1 do
  begin
    lSourceDevice := fConfig.DeviceAt(I);
    lDevice := AddDevice(lSourceDevice.Alias, lSourceDevice.UnitId);
    lDevice.Id := lSourceDevice.Id;
    lDevice.Description := lSourceDevice.Description;
    lDevice.Enabled := lSourceDevice.Enabled;
    for J := 0 to lSourceDevice.TagCount - 1 do
    begin
      lSourceTag := lSourceDevice.TagAt(J);
      lTag := AddTag(lDevice, lSourceTag.Alias, lSourceTag.Address);
      lTag.Id := lSourceTag.Id;
      lTag.Description := lSourceTag.Description;
      lTag.UnitText := lSourceTag.EngineeringUnit;
      lTag.Scale := lSourceTag.Scale;
      lTag.Offset := lSourceTag.Offset;
      lTag.Region := Ord(lSourceTag.Region);
      if lSourceTag.Region in [mrCoil, mrDiscreteInput] then
        lTag.DataType := Ord(mdBool)
      else
        lTag.DataType := Ord(lSourceTag.DataType);
      lTag.Endian := Ord(lSourceTag.ByteOrder);
      lTag.Access := Ord(lSourceTag.Access);
      lTag.Enabled := lSourceTag.Enabled;
    end;
  end;
end;

procedure TRecorderModbusEditorForm.SaveToConfig;
var
  I, J: Integer;
  lDevice: TModbusDeviceDraft;
  lTag: TModbusTagDraft;
  lTargetDevice: TModbusDeviceConfig;
  lTargetTag: TModbusTagConfig;
  lFrame: string;
begin
  fConfig.Clear;
  fConfig.Alias := Trim(AliasEdit.Text);
  fConfig.Transport := TModbusTransport(TransportCombo.ItemIndex);
  fConfig.PollIntervalMs := StrToInt(PollEdit.Text);
  fConfig.TimeoutMs := StrToInt(TimeoutEdit.Text);
  fConfig.Retries := StrToInt(RetriesEdit.Text);
  fConfig.Host := Trim(HostEdit.Text);
  fConfig.Port := StrToInt(PortEdit.Text);
  fConfig.SerialPort := Trim(SerialEdit.Text);
  fConfig.BaudRate := StrToInt(BaudCombo.Text);
  lFrame := FramingCombo.Text;
  fConfig.DataBits := StrToIntDef(Copy(lFrame, 1, 1), 8);
  if Length(lFrame) >= 2 then fConfig.Parity := lFrame[2] else fConfig.Parity := 'N';
  fConfig.StopBits := StrToIntDef(Copy(lFrame, 3, 1), 1);
  for I := 0 to fDevices.Count - 1 do
  begin
    lDevice := TModbusDeviceDraft(fDevices[I]);
    lTargetDevice := fConfig.AddDevice;
    if lDevice.Id <> '' then lTargetDevice.Id := lDevice.Id;
    lTargetDevice.Alias := lDevice.Name;
    lTargetDevice.Description := lDevice.Description;
    lTargetDevice.UnitId := lDevice.UnitId;
    lTargetDevice.Enabled := lDevice.Enabled;
    for J := 0 to lDevice.Tags.Count - 1 do
    begin
      lTag := TModbusTagDraft(lDevice.Tags[J]);
      lTargetTag := lTargetDevice.AddTag;
      if lTag.Id <> '' then lTargetTag.Id := lTag.Id;
      lTargetTag.Alias := lTag.Name;
      lTargetTag.Description := lTag.Description;
      lTargetTag.EngineeringUnit := lTag.UnitText;
      lTargetTag.Scale := lTag.Scale;
      lTargetTag.Offset := lTag.Offset;
      lTargetTag.Region := TModbusRegion(lTag.Region);
      lTargetTag.Address := lTag.Address;
      if lTargetTag.Region in [mrCoil, mrDiscreteInput] then
        lTargetTag.DataType := mdBool
      else
        lTargetTag.DataType := TModbusDataType(lTag.DataType);
      lTargetTag.ByteOrder := TModbusByteOrder(lTag.Endian);
      lTargetTag.Access := TModbusAccess(lTag.Access);
      lTargetTag.Enabled := lTag.Enabled;
    end;
  end;
end;

function TRecorderModbusSourceEditor.SupportsSource(const ASourceId,
  AModuleType: string): Boolean;
begin
  Result := SameText(AModuleType, CRecorderModbusModuleType) or
    RecorderIsModbusSource(ASourceId);
end;

function TRecorderModbusSourceEditor.EditSource(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  out ANewSourceId: string; ADataSources: TRecorderDataSourceManager): Boolean;
var
  lConfig: TModbusBusConfig;
  lEntry, lOldEntry: TRecorderConfiguredDataSource;
  lForm: TRecorderModbusEditorForm;
  lModalResult: TModalResult;
  lError, lOldConfigText: string;
begin
  Result := False;
  ANewSourceId := ASourceId;
  lConfig := TModbusBusConfig.Create;
  try
    lOldEntry := RecorderConfiguredDataSourcesFind(ARegistry, ASourceId);
    lOldConfigText := '';
    if lOldEntry <> nil then lOldConfigText := lOldEntry.SpecificConfigText;
    if (lOldEntry <> nil) and (Trim(lOldEntry.SpecificConfigText) <> '') then
      try
        lConfig.LoadJsonString(lOldEntry.SpecificConfigText);
      except
        on E: Exception do
        begin
          MessageDlg('Modbus Master', 'Ошибка конфигурации: ' + E.Message,
            mtError, [mbOK], 0);
          Exit;
        end;
      end;
    lForm := TRecorderModbusEditorForm.CreateEditor(AOwner, lConfig);
    try
      lModalResult := lForm.ShowModal;
      if lModalResult = mrOk then
        lForm.SaveToConfig
      else if not lForm.Applied then
        Exit;
      if not lConfig.Validate(lError) then
      begin
        MessageDlg('Modbus Master', lError, mtError, [mbOK], 0);
        Exit;
      end;
      ANewSourceId := UniqueModbusSourceId(ARegistry, lConfig.Alias, ASourceId);
      if (ASourceId <> '') and not SameText(ASourceId, ANewSourceId) then
        RecorderConfiguredDataSourcesRemove(ARegistry, ASourceId);
      lEntry := RecorderConfiguredDataSourcesEnsure(ARegistry, ANewSourceId,
        CRecorderModbusModuleType, 1000.0 / lConfig.PollIntervalMs);
      PublishModbusTags(ARegistry, lConfig, ASourceId, ANewSourceId,
        lOldConfigText);
      lEntry.SpecificConfigText := lConfig.ToJsonString;
      ARegistry.RegisterActiveSource(ANewSourceId);
      Result := True;
    finally
      lForm.Free;
    end;
  finally
    lConfig.Free;
  end;
end;

procedure RecorderModbusEditorResourceSmokeTest(AOwner: TComponent);
var
  lConfig: TModbusBusConfig;
  lForm: TRecorderModbusEditorForm;
begin
  lConfig := TModbusBusConfig.Create;
  try
    lConfig.Alias := 'smoke';
    lForm := TRecorderModbusEditorForm.CreateEditor(AOwner, lConfig);
    try
      if (lForm.StatusLabel.Left <> lForm.TestButton.Left) or
        (lForm.StatusLabel.Width <> lForm.TestButton.Width) then
        raise Exception.Create('Modbus connection status is not aligned with test button');
      if lForm.ApplyButton.Caption <> 'Применить' then
        raise Exception.Create('Modbus apply button resource is not loaded');
    finally
      lForm.Free;
    end;
  finally
    lConfig.Free;
  end;
end;

procedure RecorderModbusEditorCapture(const AFileName, AMode: string);
var
  lBitmap: TBitmap;
  lConfig: TModbusBusConfig;
  lDevice: TModbusDeviceConfig;
  lForm: TRecorderModbusEditorForm;
  lPng: TPortableNetworkGraphic;
  lTag: TModbusTagConfig;
begin
  lConfig := TModbusBusConfig.Create;
  try
    lConfig.Alias := 'press-shop';
    lConfig.Host := '192.168.10.25';
    lConfig.SerialPort := {$IFDEF WINDOWS}'COM4'{$ELSE}'/dev/ttyUSB0'{$ENDIF};
    if SameText(AMode, 'rtu') then lConfig.Transport := mtRtu;
    lDevice := lConfig.AddDevice;
    lDevice.Alias := 'meter-1';
    lDevice.Description := 'Энергометр участка';
    lDevice.UnitId := 7;
    lTag := lDevice.AddTag;
    lTag.Alias := 'active-power';
    lTag.Description := 'Активная мощность';
    lTag.EngineeringUnit := 'kW';
    lTag.Region := mrHoldingRegister;
    lTag.Address := 20;
    lTag.DataType := mdFloat32;
    lTag.ByteOrder := moCDAB;
    lForm := TRecorderModbusEditorForm.CreateEditor(nil, lConfig);
    try
      lForm.Position := poDesigned;
      lForm.Left := 20;
      lForm.Top := 20;
      lForm.Show;
      if lForm.ConfigTree.Items.Count > 2 then
        lForm.ConfigTree.Selected := lForm.ConfigTree.Items[2];
      lForm.TreeSelectionChanged(lForm.ConfigTree);
      Application.ProcessMessages;
      lBitmap := lForm.GetFormImage;
      try
        lPng := TPortableNetworkGraphic.Create;
        try
          lPng.Assign(lBitmap);
          lPng.SaveToFile(AFileName);
        finally
          lPng.Free;
        end;
      finally
        lBitmap.Free;
      end;
      lForm.Hide;
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
  g_Editor := TRecorderModbusSourceEditor.Create;
  RecorderRegisterConfiguredSourceEditor(g_Editor);

finalization
  g_Editor := nil;

end.
