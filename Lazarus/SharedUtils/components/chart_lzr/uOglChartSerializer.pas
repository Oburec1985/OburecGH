unit uOglChartSerializer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, jsonparser, uOglChartTypes, uOglChartBaseObj,
  uOglChartLog;

type
  { TJsonChartSerializer serializes the chart object tree to JSON text.
    Reference counting is disabled deliberately: Lazarus demo code often keeps
    serializers in class variables and frees them manually. }
  TJsonChartSerializer = class(TInterfacedObject, IChartSerializer)
  private
    function ObjectToJson(AObject: TChartBaseObject): TJSONObject;
    procedure JsonToObject(AJson: TJSONObject; AObject: TChartBaseObject);
  protected
    function QueryInterface(constref IID: TGUID; out Obj): HResult; {$IFDEF WINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
    function _AddRef: LongInt; {$IFDEF WINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
    function _Release: LongInt; {$IFDEF WINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
  public
    function SaveObject(AObject: TObject): string;
    procedure LoadObject(AObject: TObject; const AData: string);
  end;

implementation

const
  cJsonType = 'ObjType';
  cJsonName = 'Name';
  cJsonCaption = 'Caption';
  cJsonAttributes = 'Attributes';
  cJsonChildren = 'Children';

{ TJsonChartSerializer }

function TJsonChartSerializer.QueryInterface(constref IID: TGUID; out Obj): HResult; {$IFDEF WINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
begin
  Result := inherited QueryInterface(IID, Obj);
  ChartLogDebug(Format('TJsonChartSerializer.QueryInterface self=%s result=%d', [
    ChartPtr(Self), Result
  ]));
end;

function TJsonChartSerializer._AddRef: LongInt; {$IFDEF WINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
begin
  Result := -1;
  ChartLogDebug('TJsonChartSerializer._AddRef self=' + ChartPtr(Self) + ' result=-1');
end;

function TJsonChartSerializer._Release: LongInt; {$IFDEF WINDOWS}stdcall{$ELSE}cdecl{$ENDIF};
begin
  Result := -1;
  ChartLogDebug('TJsonChartSerializer._Release self=' + ChartPtr(Self) + ' result=-1');
end;

function TJsonChartSerializer.ObjectToJson(AObject: TChartBaseObject): TJSONObject;
var
  I: Integer;
  lAttributes: TJSONObject;
  lChildren: TJSONArray;
begin
  ChartLogDebug(Format('ObjectToJson enter object=%s class=%s name="%s" children=%d', [
    ChartPtr(AObject), AObject.ClassName, AObject.Name, AObject.ChildCount
  ]));

  Result := TJSONObject.Create;
  try
    Result.Add(cJsonType, AObject.ClassName);
    Result.Add(cJsonName, AObject.Name);
    Result.Add(cJsonCaption, AObject.Caption);

    lAttributes := TJSONObject.Create;
    AObject.SaveJsonAttributes(lAttributes);
    Result.Add(cJsonAttributes, lAttributes);
    ChartLogDebug('ObjectToJson attributes saved object=' + ChartPtr(AObject));

    lChildren := TJSONArray.Create;
    for I := 0 to AObject.ChildCount - 1 do
    begin
      ChartLogDebug(Format('ObjectToJson child index=%d parent=%s child=%s save=%s', [
        I,
        ChartPtr(AObject),
        ChartPtr(AObject.Children[I]),
        BoolToStr(not AObject.Children[I].NotSaveToJson, True)
      ]));
      if not AObject.Children[I].NotSaveToJson then
        lChildren.Add(ObjectToJson(AObject.Children[I]));
    end;
    Result.Add(cJsonChildren, lChildren);
    ChartLogDebug('ObjectToJson leave object=' + ChartPtr(AObject));
  except
    on E: Exception do
    begin
      ChartLogException('ObjectToJson object=' + ChartPtr(AObject), E);
      Result.Free;
      raise;
    end;
  end;
end;

procedure TJsonChartSerializer.JsonToObject(AJson: TJSONObject; AObject: TChartBaseObject);
var
  I: Integer;
  lAttributes: TJSONObject;
  lChildren: TJSONArray;
  lChildJson: TJSONObject;
  lChild: TChartBaseObject;
begin
  ChartLogDebug(Format('JsonToObject enter json=%s object=%s', [
    ChartPtr(AJson), ChartPtr(AObject)
  ]));

  if not Assigned(AJson) or not Assigned(AObject) then
  begin
    ChartLogWarning('JsonToObject skipped because json or object is nil');
    Exit;
  end;

  try
    if AJson.IndexOfName(cJsonName) <> -1 then
      AObject.Name := AJson.Strings[cJsonName];
    if AJson.IndexOfName(cJsonCaption) <> -1 then
      AObject.Caption := AJson.Strings[cJsonCaption];
    ChartLogDebug(Format('JsonToObject identity loaded object=%s name="%s" caption="%s"', [
      ChartPtr(AObject), AObject.Name, AObject.Caption
    ]));

    lAttributes := nil;
    if AJson.IndexOfName(cJsonAttributes) <> -1 then
      lAttributes := AJson.Objects[cJsonAttributes];
    AObject.LoadJsonAttributes(lAttributes);
    ChartLogDebug('JsonToObject attributes loaded object=' + ChartPtr(AObject));

    AObject.ClearChildren;
    if AJson.IndexOfName(cJsonChildren) = -1 then
    begin
      ChartLogDebug('JsonToObject no children object=' + ChartPtr(AObject));
      Exit;
    end;

    lChildren := AJson.Arrays[cJsonChildren];
    ChartLogDebug(Format('JsonToObject children count=%d object=%s', [
      lChildren.Count, ChartPtr(AObject)
    ]));
    for I := 0 to lChildren.Count - 1 do
    begin
      if not (lChildren.Items[I] is TJSONObject) then
      begin
        ChartLogWarning(Format('JsonToObject skip non-object child index=%d parent=%s', [
          I, ChartPtr(AObject)
        ]));
        Continue;
      end;

      lChildJson := TJSONObject(lChildren.Items[I]);
      lChild := TChartBaseObject.Create;
      ChartLogDebug(Format('JsonToObject child created index=%d child=%s parent=%s', [
        I, ChartPtr(lChild), ChartPtr(AObject)
      ]));
      JsonToObject(lChildJson, lChild);
      AObject.AddChild(lChild);
    end;
    ChartLogDebug('JsonToObject leave object=' + ChartPtr(AObject));
  except
    on E: Exception do
    begin
      ChartLogException('JsonToObject object=' + ChartPtr(AObject), E);
      raise;
    end;
  end;
end;

function TJsonChartSerializer.SaveObject(AObject: TObject): string;
var
  lRoot: TJSONObject;
begin
  ChartLogInfo(Format('SaveObject enter serializer=%s object=%s', [
    ChartPtr(Self), ChartPtr(AObject)
  ]));

  Result := '';
  if not Assigned(AObject) or not (AObject is TChartBaseObject) then
  begin
    ChartLogWarning('SaveObject skipped: object is nil or not TChartBaseObject');
    Exit;
  end;

  try
    lRoot := ObjectToJson(TChartBaseObject(AObject));
    try
      Result := lRoot.AsJSON;
      ChartLogInfo(Format('SaveObject success serializer=%s json_length=%d json="%s"', [
        ChartPtr(Self), Length(Result), Result
      ]));
    finally
      lRoot.Free;
    end;
  except
    on E: Exception do
    begin
      ChartLogException('SaveObject serializer=' + ChartPtr(Self), E);
      raise;
    end;
  end;
end;

procedure TJsonChartSerializer.LoadObject(AObject: TObject; const AData: string);
var
  lParser: TJSONParser;
  lData: TJSONData;
begin
  ChartLogInfo(Format('LoadObject enter serializer=%s object=%s data_length=%d data="%s"', [
    ChartPtr(Self), ChartPtr(AObject), Length(AData), AData
  ]));

  if (AData = '') or not Assigned(AObject) or not (AObject is TChartBaseObject) then
  begin
    ChartLogWarning('LoadObject skipped: empty data, nil object, or unsupported object class');
    Exit;
  end;

  try
    lParser := TJSONParser.Create(AData);
    try
      lData := lParser.Parse;
      try
        ChartLogDebug(Format('LoadObject parsed json class=%s', [lData.ClassName]));
        if lData is TJSONObject then
          JsonToObject(TJSONObject(lData), TChartBaseObject(AObject));
      finally
        lData.Free;
      end;
    finally
      lParser.Free;
    end;
    ChartLogInfo('LoadObject success serializer=' + ChartPtr(Self));
  except
    on E: Exception do
    begin
      ChartLogException('LoadObject serializer=' + ChartPtr(Self), E);
      raise;
    end;
  end;
end;

end.
