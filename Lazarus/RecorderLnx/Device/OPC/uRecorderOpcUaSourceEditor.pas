unit uRecorderOpcUaSourceEditor;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface

implementation

uses
  Classes, SysUtils, DateUtils, Forms, Controls, StdCtrls, ExtCtrls, Dialogs,
  ComCtrls, Grids, Contnrs, Graphics, ImgList,
  uRecorderTags, uRecorderConfiguredDataSources,
  uRecorderConfiguredSourceEditor, uRecorderOpcUaTypes, uRecorderOpcUaApi;

type
  TRecorderOpcUaProbeOperation = (opoTest, opoBrowse, opoRead);

  TRecorderOpcUaTreeItem = class
  public
    BrowsePath: string;
    NodeId: string;
    TagName: string;
    Readable: Boolean;
    IsProperty: Boolean;
    Writable: Boolean;
    DataTypeNodeId: string;
    DataTypeName: string;
    ValueText: string;
    ValueRank: Integer;
    Historizing: Boolean;
    HistoryReadable: Boolean;
    HistoryWritable: Boolean;
    TreeNode: TTreeNode;
  end;

  TRecorderOpcUaProbeThread = class(TThread)
  private
    fEndpoint: string;
    fErrorText: string;
    fInputNodeIds: TStringList;
    fInputTagNames: TStringList;
    fLines: TStringList;
    fOperation: TRecorderOpcUaProbeOperation;
    fPassword: string;
    fSessionTimeoutMs: Cardinal;
    fUserName: string;
    fElapsedMs: QWord;
    fSucceeded: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(const AEndpoint, AUserName, APassword: string;
      AOperation: TRecorderOpcUaProbeOperation; ANodeIds: TStrings = nil;
      ATagNames: TStrings = nil;
      ASessionTimeoutMs: Cardinal = CRecorderOpcUaDefaultSessionTimeoutMs);
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
    fBrowseTree: TTreeView;
    fCancelButton: TButton;
    fDiagnostics: TMemo;
    fEndpoint: TEdit;
    fInterval: TEdit;
    fSessionTimeout: TEdit;
    fMode: TComboBox;
    fNodes: TMemo; { compatibility field for the retired programmatic layout }
    fOkButton: TButton;
    fPassword: TEdit;
    fProbeButton: TButton;
    fReadButton: TButton;
    fSimplifiedTree: TCheckBox;
    fUserName: TEdit;
    fValueGrid: TStringGrid;
    fNodeImages: TImageList;
    fConfigPanel: TPanel;
    fTreePanel: TPanel;
    fTagPanel: TPanel;
    fDiagnosticsPanel: TPanel;
    fConfigSplitter: TSplitter;
    fTagSplitter: TSplitter;
    procedure BrowseTreeDblClick(Sender: TObject);
    procedure AuthChange(Sender: TObject);
    procedure BrowseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure ModeChange(Sender: TObject);
    procedure ProbeClick(Sender: TObject);
    procedure ProbeFinished(Sender: TObject);
    procedure RebuildBrowseTree;
    procedure SetProbeRunning(ARunning: Boolean);
    procedure SimplifiedTreeChange(Sender: TObject);
    procedure ReadClick(Sender: TObject);
  private
    fProbeThread: TRecorderOpcUaProbeThread;
    fTreeItems: TObjectList;
    fAutoBrowsePending: Boolean;
    procedure AddSelectedTreeNode;
    procedure AddDiagnostic(const AText: string);
    function AddOrFindTagRow(AItem: TRecorderOpcUaTreeItem): Integer;
    procedure BuildReadInputs(out ANodeIds, ATagNames: TStringList);
    function DataTypeImageIndex(const ADataTypeNodeId: string;
      AValueRank: Integer): Integer;
    procedure InitializeNodeImages;
    function SelectedTagCount: Integer;
    procedure ExpandConfiguredTreeNodes;
    procedure StartProbe(AOperation: TRecorderOpcUaProbeOperation);
    procedure UpdateControlState;
  public
    constructor CreateEditor(AOwner: TComponent;
      AConfig: TRecorderOpcUaConfig);
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
      const ASourceId: string; out ANewSourceId: string): Boolean;
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
    lTag := FindOpcUaTagByAddress(ARegistry, AOldSourceId, ANewSourceId,
      lNode.NodeId);
    if lTag = nil then
    begin
      lNode.TagName := UniqueOpcUaTagName(ARegistry, lNode.TagName);
      lTag := ARegistry.CreateTag(lNode.TagName, 4096);
    end
    else
      lNode.TagName := lTag.Name;
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
  ANodeIds, ATagNames: TStrings; ASessionTimeoutMs: Cardinal);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  fEndpoint := AEndpoint;
  fUserName := AUserName;
  fPassword := APassword;
  fOperation := AOperation;
  fSessionTimeoutMs := ASessionTimeoutMs;
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
      if not RecorderOpcUaLoad(lLoadError) then
      begin
        fErrorText := lLoadError;
        Exit;
      end;
      lHandle := RecorderOpcUaClientCreate(fEndpoint, fUserName, fPassword,
        CRecorderOpcUaDefaultPublishingIntervalMs, fSessionTimeoutMs);
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
            if not RecorderOpcUaClientBrowse(lHandle, fLines) then
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
  AConfig: TRecorderOpcUaConfig);
var
  I: Integer;
  lButtonPanel, lConfigPanel, lDiagnosticPanel, lNodePanel: TPanel;
  lNode: TRecorderOpcUaNode;
  lText: string;
begin
  inherited Create(AOwner);
  fTreeItems := TObjectList.Create(True);
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
  fAutoBrowsePending := (AConfig.Mode = oumClient) and
    (AConfig.Nodes.Count > 0);
  fValueGrid.RowCount := 1;
  fValueGrid.Cells[0, 0] := 'Тег';
  fValueGrid.Cells[1, 0] := 'Тип';
  fValueGrid.Cells[2, 0] := 'Доступ';
  fValueGrid.Cells[3, 0] := 'NodeId';
  fValueGrid.Cells[4, 0] := 'Значение';
  fValueGrid.Cells[5, 0] := 'Качество';
  fValueGrid.Cells[6, 0] := 'Время';
  fValueGrid.ColWidths[0] := 130;
  fValueGrid.ColWidths[1] := 100;
  fValueGrid.ColWidths[2] := 120;
  fValueGrid.ColWidths[3] := 260;
  fValueGrid.ColWidths[4] := 110;
  fValueGrid.ColWidths[5] := 90;
  fValueGrid.ColWidths[6] := 160;
  for I := 0 to AConfig.Nodes.Count - 1 do
  begin
    lNode := TRecorderOpcUaNode(AConfig.Nodes[I]);
    fValueGrid.RowCount := fValueGrid.RowCount + 1;
    fValueGrid.Cells[0, fValueGrid.RowCount - 1] := lNode.TagName;
    fValueGrid.Cells[1, fValueGrid.RowCount - 1] := '';
    if lNode.Writable and lNode.Readable then lText := 'Чтение и запись'
    else if lNode.Writable then lText := 'Только запись'
    else lText := 'Только чтение';
    fValueGrid.Cells[2, fValueGrid.RowCount - 1] := lText;
    fValueGrid.Cells[3, fValueGrid.RowCount - 1] := lNode.NodeId;
  end;
  AddDiagnostic(UTF8Encode('Готово. Endpoint: ') + AConfig.Endpoint);
  UpdateControlState;
  Exit;

  inherited CreateNew(AOwner, 1);
  Caption := 'OPC UA client/server';
  Position := poOwnerFormCenter;
  BorderStyle := bsSizeable;
  Width := 720;
  Height := 680;
  Constraints.MinWidth := 650;
  Constraints.MinHeight := 600;
  OnCloseQuery := @FormCloseQuery;
  fTreeItems := TObjectList.Create(True);

  lButtonPanel := TPanel.Create(Self);
  lButtonPanel.Parent := Self;
  lButtonPanel.Align := alBottom;
  lButtonPanel.Height := 48;
  lButtonPanel.Width := ClientWidth;
  lButtonPanel.BevelOuter := bvNone;
  lButtonPanel.BringToFront;

  fCancelButton := TButton.Create(Self);
  fCancelButton.Parent := lButtonPanel;
  fCancelButton.Caption := 'Отмена';
  fCancelButton.SetBounds(lButtonPanel.Width - 96, 10, 80, 28);
  fCancelButton.Anchors := [akTop, akRight];
  fCancelButton.Cancel := True;
  fCancelButton.ModalResult := mrCancel;

  fOkButton := TButton.Create(Self);
  fOkButton.Parent := lButtonPanel;
  fOkButton.Caption := 'OK';
  fOkButton.SetBounds(lButtonPanel.Width - 186, 10, 80, 28);
  fOkButton.Anchors := [akTop, akRight];
  fOkButton.Default := True;
  fOkButton.ModalResult := mrOk;

  lDiagnosticPanel := TPanel.Create(Self);
  lDiagnosticPanel.Parent := Self;
  lDiagnosticPanel.Align := alBottom;
  lDiagnosticPanel.Height := 210;
  lDiagnosticPanel.Width := ClientWidth;
  lDiagnosticPanel.BevelOuter := bvNone;
  AddLabel(Self, lDiagnosticPanel, 'Диагностика', 16, 3);
  fDiagnostics := TMemo.Create(Self);
  fDiagnostics.Parent := lDiagnosticPanel;
  fDiagnostics.SetBounds(16, 23, lDiagnosticPanel.Width - 32, 62);
  fDiagnostics.Anchors := [akLeft, akTop, akRight, akBottom];
  fDiagnostics.ReadOnly := True;
  fDiagnostics.ScrollBars := ssAutoVertical;
  fValueGrid := TStringGrid.Create(Self);
  fValueGrid.Parent := lDiagnosticPanel;
  fValueGrid.SetBounds(16, 91, lDiagnosticPanel.Width - 32, 111);
  fValueGrid.Anchors := [akLeft, akRight, akBottom];
  fValueGrid.ColCount := 5;
  fValueGrid.FixedRows := 1;
  fValueGrid.RowCount := 1;
  fValueGrid.Cells[0, 0] := 'Тег';
  fValueGrid.Cells[1, 0] := 'NodeId';
  fValueGrid.Cells[2, 0] := 'Значение';
  fValueGrid.Cells[3, 0] := 'Качество';
  fValueGrid.Cells[4, 0] := 'Время';
  fValueGrid.ColWidths[0] := 130;
  fValueGrid.ColWidths[1] := 190;
  fValueGrid.ColWidths[2] := 90;
  fValueGrid.ColWidths[3] := 90;
  fValueGrid.ColWidths[4] := 160;

  lConfigPanel := TPanel.Create(Self);
  lConfigPanel.Parent := Self;
  lConfigPanel.Align := alTop;
  lConfigPanel.Height := 260;
  lConfigPanel.Width := ClientWidth;
  lConfigPanel.BevelOuter := bvNone;
  AddLabel(Self, lConfigPanel, 'Режим', 16, 18);
  fMode := TComboBox.Create(Self);
  fMode.Parent := lConfigPanel;
  fMode.SetBounds(140, 14, 180, 28);
  fMode.Style := csDropDownList;
  fMode.Items.Add('Client');
  fMode.Items.Add('Server');
  fMode.ItemIndex := Ord(AConfig.Mode);
  fMode.OnChange := @ModeChange;
  AddLabel(Self, lConfigPanel, 'Endpoint URL', 16, 54);
  fEndpoint := TEdit.Create(Self);
  fEndpoint.Parent := lConfigPanel;
  fEndpoint.SetBounds(140, 50, 540, 28);
  fEndpoint.Anchors := [akLeft, akTop, akRight];
  fEndpoint.Text := AConfig.Endpoint;
  AddLabel(Self, lConfigPanel, 'Аутентификация', 16, 90);
  fAuth := TComboBox.Create(Self);
  fAuth.Parent := lConfigPanel;
  fAuth.SetBounds(140, 86, 220, 28);
  fAuth.Style := csDropDownList;
  fAuth.Items.Add('Анонимно');
  fAuth.Items.Add('Логин / пароль');
  if AConfig.AuthenticationMode = ouamUserPassword then
    fAuth.ItemIndex := 1
  else
    fAuth.ItemIndex := 0;
  fAuth.OnChange := @AuthChange;
  AddLabel(Self, lConfigPanel, 'Пользователь', 16, 126);
  fUserName := TEdit.Create(Self);
  fUserName.Parent := lConfigPanel;
  fUserName.SetBounds(140, 122, 220, 28);
  fUserName.Text := AConfig.UserName;
  AddLabel(Self, lConfigPanel, 'ENV пароля', 16, 162);
  fPassword := TEdit.Create(Self);
  fPassword.Parent := lConfigPanel;
  fPassword.SetBounds(140, 158, 220, 28);
  fPassword.Text := AConfig.PasswordEnvironment;
  AddLabel(Self, lConfigPanel, 'Интервал, мс', 390, 126);
  fInterval := TEdit.Create(Self);
  fInterval.Parent := lConfigPanel;
  fInterval.SetBounds(500, 122, 100, 28);
  fInterval.Text := IntToStr(AConfig.PublishingIntervalMs);
  fProbeButton := TButton.Create(Self);
  fProbeButton.Parent := lConfigPanel;
  fProbeButton.Caption := 'Проверить связь';
  fProbeButton.SetBounds(140, 205, 150, 30);
  fProbeButton.OnClick := @ProbeClick;
  fBrowseButton := TButton.Create(Self);
  fBrowseButton.Parent := lConfigPanel;
  fBrowseButton.Caption := 'Найти теги';
  fBrowseButton.SetBounds(300, 205, 130, 30);
  fBrowseButton.OnClick := @BrowseClick;
  fReadButton := TButton.Create(Self);
  fReadButton.Parent := lConfigPanel;
  fReadButton.Caption := 'Прочитать значения';
  fReadButton.SetBounds(440, 205, 160, 30);
  fReadButton.OnClick := @ReadClick;

  lNodePanel := TPanel.Create(Self);
  lNodePanel.Parent := Self;
  lNodePanel.Align := alClient;
  lNodePanel.Width := ClientWidth;
  lNodePanel.BevelOuter := bvNone;
  AddLabel(Self, lNodePanel,
    'Найденные узлы (двойной щелчок добавляет только канал)', 16, 5);
  fSimplifiedTree := TCheckBox.Create(Self);
  fSimplifiedTree.Parent := lNodePanel;
  fSimplifiedTree.Caption := 'Упрощённая структура';
  fSimplifiedTree.SetBounds(lNodePanel.Width - 190, 3, 174, 24);
  fSimplifiedTree.Anchors := [akTop, akRight];
  fSimplifiedTree.Checked := True;
  fSimplifiedTree.OnChange := @SimplifiedTreeChange;
  fBrowseTree := TTreeView.Create(Self);
  fBrowseTree.Parent := lNodePanel;
  fBrowseTree.SetBounds(16, 27, lNodePanel.Width - 32,
    lNodePanel.Height - 142);
  fBrowseTree.Anchors := [akLeft, akTop, akRight, akBottom];
  fBrowseTree.ReadOnly := True;
  fBrowseTree.OnDblClick := @BrowseTreeDblClick;
  AddLabel(Self, lNodePanel, 'Выбранные рабочие каналы: NodeId|имя тега',
    16, lNodePanel.Height - 108);
  fNodes := TMemo.Create(Self);
  fNodes.Parent := lNodePanel;
  fNodes.SetBounds(16, lNodePanel.Height - 88, lNodePanel.Width - 32, 80);
  fNodes.Anchors := [akLeft, akRight, akBottom];
  fNodes.ScrollBars := ssAutoBoth;
  fNodes.Lines.NameValueSeparator := '|';
  for I := 0 to AConfig.Nodes.Count - 1 do
  begin
    lNode := TRecorderOpcUaNode(AConfig.Nodes[I]);
    lText := lNode.NodeId + '|' + lNode.TagName;
    if lNode.Writable then lText := lText + '|rw';
    fNodes.Lines.Add(lText);
  end;
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
var
  I: Integer;
begin
  for I := 1 to fValueGrid.RowCount - 1 do
    if SameText(fValueGrid.Cells[3, I], AItem.NodeId) then Exit(I);
  Result := fValueGrid.RowCount;
  fValueGrid.RowCount := Result + 1;
  fValueGrid.Cells[0, Result] := AItem.TagName;
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
  fBrowseButton.Enabled := lClient and (fProbeThread = nil);
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
  UpdateControlState;
end;

procedure TRecorderOpcUaEditorForm.StartProbe(
  AOperation: TRecorderOpcUaProbeOperation);
var
  lSessionTimeoutSeconds: Integer;
  lPassword, lUserName: string;
  lReadNodeIds, lReadTagNames: TStringList;
begin
  if fProbeThread <> nil then Exit;
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
  try
    fProbeThread := TRecorderOpcUaProbeThread.Create(Trim(fEndpoint.Text),
      lUserName, lPassword, AOperation, lReadNodeIds, lReadTagNames,
      Cardinal(lSessionTimeoutSeconds) * 1000);
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

procedure TRecorderOpcUaEditorForm.BrowseClick(Sender: TObject);
begin
  StartProbe(opoBrowse);
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

procedure SetTreeNodeImage(ANode: TTreeNode; AImageIndex: Integer);
begin
  if ANode = nil then Exit;
  ANode.ImageIndex := AImageIndex;
  ANode.SelectedIndex := AImageIndex;
end;

procedure TRecorderOpcUaEditorForm.AddSelectedTreeNode;
var
  lItem: TRecorderOpcUaTreeItem;
  lRow: Integer;
begin
  if (fBrowseTree.Selected = nil) or (fBrowseTree.Selected.Data = nil) then Exit;
  lItem := TRecorderOpcUaTreeItem(fBrowseTree.Selected.Data);
  if lItem.IsProperty or not (lItem.Readable or lItem.Writable) then
  begin
    AddDiagnostic('Свойство доступно только для просмотра в настройках.');
    Exit;
  end;
  lRow := AddOrFindTagRow(lItem);
  fValueGrid.Row := lRow;
  AddDiagnostic(UTF8Encode('Канал в таблице тегов: ') + lItem.TagName +
    ' (' + lItem.DataTypeName + ')');
  UpdateControlState;
end;

procedure TRecorderOpcUaEditorForm.BrowseTreeDblClick(Sender: TObject);
begin
  AddSelectedTreeNode;
end;

function CreateTreeItem(AFields: TStrings): TRecorderOpcUaTreeItem;
var
  lAccess, lServerAccess, lUserAccess: Integer;
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
  if Result.DataTypeName = '' then Result.DataTypeName := Result.DataTypeNodeId;
  if Result.DataTypeName = '' then Result.DataTypeName := 'Неизвестный';
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

procedure AddFullTreeNode(ATree: TTreeView; AItem: TRecorderOpcUaTreeItem);
var
  I: Integer;
  lCategory, lPart: string;
  lParent: TTreeNode;
  lParts: TStringList;
begin
  if (Pos('ns=0;', LowerCase(AItem.NodeId)) = 1) or
     (Pos('objects/server/', LowerCase(AItem.BrowsePath)) = 1) then
    lCategory := 'Служебные узлы сервера'
  else if AItem.IsProperty then
    lCategory := 'Свойства оборудования'
  else if AItem.Writable and AItem.Readable then
    lCategory := 'Управляемые каналы (чтение/запись)'
  else if AItem.Writable then
    lCategory := 'Управляемые каналы (только запись)'
  else if AItem.Readable then
    lCategory := 'Каналы данных (только чтение)'
  else
    lCategory := 'Недоступные текущему пользователю';
  lParent := EnsureTreeChild(ATree, nil, lCategory);
  SetTreeNodeImage(lParent, CImageGroup);
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
  if AItem.IsProperty and (AItem.ValueText <> '') then
    AItem.TreeNode := ATree.Items.AddChild(lParent,
      AItem.TagName + ' = ' + AItem.ValueText + '  [' + AItem.NodeId + ']')
  else
    AItem.TreeNode := ATree.Items.AddChild(lParent,
      AItem.TagName + '  [' + AItem.NodeId + ']');
  AItem.TreeNode.Data := AItem;
  if AItem.IsProperty then SetTreeNodeImage(AItem.TreeNode, CImageProperty)
  else SetTreeNodeImage(AItem.TreeNode,
    TRecorderOpcUaEditorForm(ATree.Owner).DataTypeImageIndex(
      AItem.DataTypeNodeId, AItem.ValueRank));
end;

procedure AddSimplifiedChannel(ATree: TTreeView;
  AItem: TRecorderOpcUaTreeItem);
var
  lAccessNode, lChannelsNode, lDeviceNode: TTreeNode;
  lDeviceName: string;
begin
  if AItem.IsProperty or not (AItem.Readable or AItem.Writable) then Exit;
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
  AItem.TreeNode := ATree.Items.AddChild(lAccessNode, AItem.TagName);
  AItem.TreeNode.Data := AItem;
  SetTreeNodeImage(AItem.TreeNode,
    TRecorderOpcUaEditorForm(ATree.Owner).DataTypeImageIndex(
      AItem.DataTypeNodeId, AItem.ValueRank));
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
  if AItem.ValueText <> '' then
    AItem.TreeNode := ATree.Items.AddChild(lParent,
      AItem.TagName + ' = ' + AItem.ValueText)
  else
    AItem.TreeNode := ATree.Items.AddChild(lParent, AItem.TagName);
  AItem.TreeNode.Data := AItem;
  SetTreeNodeImage(AItem.TreeNode, CImageProperty);
end;

procedure TRecorderOpcUaEditorForm.RebuildBrowseTree;
var
  I: Integer;
  lItem: TRecorderOpcUaTreeItem;
begin
  fBrowseTree.Items.BeginUpdate;
  try
    fBrowseTree.Items.Clear;
    for I := 0 to fTreeItems.Count - 1 do
      TRecorderOpcUaTreeItem(fTreeItems[I]).TreeNode := nil;
    if fSimplifiedTree.Checked then
    begin
      for I := 0 to fTreeItems.Count - 1 do
        AddSimplifiedChannel(fBrowseTree,
          TRecorderOpcUaTreeItem(fTreeItems[I]));
      for I := 0 to fTreeItems.Count - 1 do
        AddSimplifiedProperty(fBrowseTree, fTreeItems,
          TRecorderOpcUaTreeItem(fTreeItems[I]));
    end
    else
      for I := 0 to fTreeItems.Count - 1 do
      begin
        lItem := TRecorderOpcUaTreeItem(fTreeItems[I]);
        AddFullTreeNode(fBrowseTree, lItem);
      end;
  finally
    fBrowseTree.Items.EndUpdate;
  end;
  ExpandConfiguredTreeNodes;
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
      if SameText(fValueGrid.Cells[3, J], lItem.NodeId) then
      begin
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

procedure TRecorderOpcUaEditorForm.ProbeFinished(Sender: TObject);
var
  I, J, lRow: Integer;
  lFields: TStringList;
begin
  if fProbeThread = nil then Exit;
  if fProbeThread.Succeeded then
  begin
    if fProbeThread.Operation = opoBrowse then
    begin
      fTreeItems.Clear;
      lFields := TStringList.Create;
      try
        lFields.Delimiter := #9;
        lFields.StrictDelimiter := True;
        for I := 0 to fProbeThread.Lines.Count - 1 do
        begin
          lFields.DelimitedText := fProbeThread.Lines[I];
          if lFields.Count >= 6 then
            fTreeItems.Add(CreateTreeItem(lFields));
        end;
      finally
        lFields.Free;
      end;
      RebuildBrowseTree;
      AddDiagnostic(Format('Найдено узлов: %d; выберите рабочие двойным щелчком; %d мс.',
        [fProbeThread.Lines.Count, fProbeThread.ElapsedMs]));
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
            if SameText(fValueGrid.Cells[3, J], lFields[1]) then
            begin
              lRow := J;
              Break;
            end;
          if lRow = 0 then Continue;
          fValueGrid.Cells[4, lRow] := lFields[2];
          fValueGrid.Cells[5, lRow] := lFields[3];
          fValueGrid.Cells[6, lRow] := lFields[4];
        end;
      finally
        lFields.Free;
      end;
      AddDiagnostic(Format('Прочитано значений: %d; %d мс.',
        [fProbeThread.Lines.Count, fProbeThread.ElapsedMs]));
    end
    else
      AddDiagnostic(Format('Соединение установлено; %d мс.',
        [fProbeThread.ElapsedMs]));
  end
  else
  begin
    if fProbeThread.ErrorText = '' then
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
  if not fAutoBrowsePending then Exit;
  fAutoBrowsePending := False;
  AddDiagnostic('Восстановление сохранённого дерева OPC UA...');
  StartProbe(opoBrowse);
end;

procedure TRecorderOpcUaEditorForm.SaveToConfig(
  AConfig: TRecorderOpcUaConfig);
var
  I, lSessionTimeoutSeconds: Integer;
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
  AConfig.PublishingIntervalMs := Cardinal(StrToIntDef(fInterval.Text,
    CRecorderOpcUaDefaultPublishingIntervalMs));
  if AConfig.PublishingIntervalMs < 10 then
    AConfig.PublishingIntervalMs := 10;
  lSessionTimeoutSeconds := StrToIntDef(fSessionTimeout.Text,
    CRecorderOpcUaDefaultSessionTimeoutMs div 1000);
  if lSessionTimeoutSeconds < 1 then lSessionTimeoutSeconds := 1;
  if lSessionTimeoutSeconds > 3600 then lSessionTimeoutSeconds := 3600;
  AConfig.SessionTimeoutMs := Cardinal(lSessionTimeoutSeconds) * 1000;
  AConfig.SimplifiedTree := fSimplifiedTree.Checked;
  AConfig.Nodes.Clear;
  for I := 1 to fValueGrid.RowCount - 1 do
  begin
    if Trim(fValueGrid.Cells[3, I]) = '' then Continue;
    lNode := AConfig.AddNode(Trim(fValueGrid.Cells[3, I]),
      Trim(fValueGrid.Cells[0, I]));
    lNode.Readable := not SameText(fValueGrid.Cells[2, I], 'Только запись');
    lNode.Writable := SameText(fValueGrid.Cells[2, I], 'Чтение и запись') or
      SameText(fValueGrid.Cells[2, I], 'Только запись');
  end;
end;

function TRecorderOpcUaSourceEditor.SupportsSource(const ASourceId,
  AModuleType: string): Boolean;
begin
  Result := RecorderIsOpcUaSource(ASourceId, AModuleType);
end;

function TRecorderOpcUaSourceEditor.EditSource(AOwner: TComponent;
  ARegistry: TRecorderTagRegistry; const ASourceId: string;
  out ANewSourceId: string): Boolean;
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
    lForm := TRecorderOpcUaEditorForm.CreateEditor(AOwner, lConfig);
    try
      if lForm.ShowModal <> mrOk then Exit;
      lForm.SaveToConfig(lConfig);
      ANewSourceId := RecorderOpcUaSourceId(lConfig.Endpoint, lConfig.Mode);
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
