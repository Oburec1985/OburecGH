unit uDacVectorTagMirror;

interface

uses
  Windows, SysUtils, ActiveX, Variants,
  recorder, tags, blaccess, uRCFunc;

type
  TDacVectorTagMirror = class
  private
    fTag: ITag;
    fBlock: IBlockAccess;
    fTagName: string;
    function CreateVectorTagR8(const ATagName: string; AFreq: Double): ITag;
    procedure AttachTag(const ATag: ITag; const ATagName: string);
    function CanCreateTag: Boolean;
    function CanWriteSamples: Boolean;
  public
    destructor Destroy; override;
    procedure Reset;
    function Configure(const ATagName: string; AFreq: Double): Boolean;
    function WriteSamples(ASamples: Pointer; ACount: Integer): Boolean;
    property TagName: string read fTagName;
  end;

implementation

function TDacVectorTagMirror.CreateVectorTagR8(const ATagName: string;
  AFreq: Double): ITag;
var
  ir: IRecorder;
  v: OleVariant;
begin
  Result := nil;
  ir := getIR;
  if ir = nil then
    Exit;

  Result := ITag(ir.CreateTag(LPCSTR(StrToAnsi(ATagName)), LS_VIRTUAL, nil));
  if Result = nil then
    Exit;

  VariantInit(v);
  VariantClear(v);
  TPropVariant(v).vt := VT_UI4;
  v := TTAG_VECTOR or TTAG_INPUT or TTAG_IRREGULAR;
  Result.SetProperty(TAGPROP_TYPE, v);
  Result.SetProperty(TAGPROP_ENABLEFREQCORRECTION, True);

  VariantClear(v);
  TPropVariant(v).vt := VT_R8;
  Result.SetProperty(TAGPROP_DATATYPE, v);
  Result.SetFreq(AFreq);
  Result.CfgWritable(True);
end;

procedure TDacVectorTagMirror.AttachTag(const ATag: ITag; const ATagName: string);
begin
  fTag := ATag;
  fTagName := ATagName;
  fBlock := nil;
  if Assigned(fTag) then
    fTag.QueryInterface(IBlockAccess, fBlock);
end;

function TDacVectorTagMirror.CanCreateTag: Boolean;
var
  ir: IRecorder;
begin
  Result := False;
  ir := getIR;
  if ir = nil then
    Exit;
  Result := ir.CheckState(RS_STOP);
end;

function TDacVectorTagMirror.CanWriteSamples: Boolean;
var
  ir: IRecorder;
begin
  Result := False;
  ir := getIR;
  if ir = nil then
    Exit;
  Result := not ir.CheckState(RS_STOP);
end;

destructor TDacVectorTagMirror.Destroy;
begin
  Reset;
  inherited;
end;

procedure TDacVectorTagMirror.Reset;
begin
  fBlock := nil;
  fTag := nil;
  fTagName := '';
end;

function TDacVectorTagMirror.Configure(const ATagName: string; AFreq: Double): Boolean;
var
  lTag: ITag;
  lName: string;
begin
  lName := Trim(ATagName);
  if lName = '' then
  begin
    Reset;
    Result := False;
    Exit;
  end;

  if SameText(fTagName, lName) and Assigned(fTag) then
  begin
    fTag.SetFreq(AFreq);
    Result := True;
    Exit;
  end;

  lTag := getTagByName(lName);
  if (lTag = nil) and CanCreateTag then
  begin
    ecm;
    try
      lTag := CreateVectorTagR8(lName, AFreq);
    finally
      lcm;
    end;
  end;

  AttachTag(lTag, lName);
  if Assigned(fTag) then
    fTag.SetFreq(AFreq);
  Result := Assigned(fTag);
end;

function TDacVectorTagMirror.WriteSamples(ASamples: Pointer; ACount: Integer): Boolean;
begin
  Result := Assigned(fTag) and (ASamples <> nil) and (ACount > 0) and
    CanWriteSamples and not FAILED(fTag.PushDataEx(ASamples, ACount));
end;

end.