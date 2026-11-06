unit uCoordinatorSqlQueueStore;

{$mode objfpc}{$H+}
{$codepage UTF8}

{ Persistent, password-free pending SQL endpoint changes. The coordinator owns
  retries and acknowledgement; this unit only validates and stores records. }

interface

uses Classes, SysUtils;

type
  TStoredSqlCommand = record
    CommandId, InstanceId, CorrelationId, Host, Database, ServerDatabase: string;
    Port: Integer;
  end;
  TStoredSqlCommands = array of TStoredSqlCommand;

  TCoordinatorSqlQueueStore = class
  private
    fFileName: string;
  public
    constructor Create(const AFileName: string);
    function Load: TStoredSqlCommands;
    procedure Save(const ACommands: TStoredSqlCommands);
  end;

implementation

uses fpjson, jsonparser
  {$ifdef unix}, BaseUnix{$endif}
  {$ifdef windows}, Windows{$endif};

constructor TCoordinatorSqlQueueStore.Create(const AFileName: string);
begin
  inherited Create;
  fFileName := ExpandFileName(AFileName);
end;

function TCoordinatorSqlQueueStore.Load: TStoredSqlCommands;
var
  lText: TStringList;
  lData: TJSONData;
  lArray: TJSONArray;
  lItem: TJSONObject;
  lIndex: Integer;
begin
  Result := nil;
  if not FileExists(fFileName) then Exit;
  lText := TStringList.Create;
  try
    lText.LoadFromFile(fFileName);
    lData := GetJSON(lText.Text);
    try
      if not (lData is TJSONArray) then
        raise Exception.Create('Invalid SQL command queue: expected array');
      lArray := TJSONArray(lData);
      SetLength(Result, lArray.Count);
      for lIndex := 0 to lArray.Count - 1 do
      begin
        if not (lArray.Items[lIndex] is TJSONObject) then
          raise Exception.Create('Invalid SQL command queue entry');
        lItem := TJSONObject(lArray.Items[lIndex]);
        Result[lIndex].CommandId := lItem.Get('command_id', '');
        Result[lIndex].InstanceId := lItem.Get('instance_id', '');
        Result[lIndex].CorrelationId := lItem.Get('correlation_id', '');
        Result[lIndex].Host := lItem.Get('host', '');
        Result[lIndex].Database := lItem.Get('database', '');
        Result[lIndex].ServerDatabase := lItem.Get('server_database', '');
        Result[lIndex].Port := lItem.Get('port', -1);
        if (Result[lIndex].CommandId = '') or (Result[lIndex].InstanceId = '') or
           (Result[lIndex].Host = '') or
           (Result[lIndex].Port < 0) or (Result[lIndex].Port > 65535) then
          raise Exception.Create('Invalid SQL command queue fields');
      end;
    finally
      lData.Free;
    end;
  finally
    lText.Free;
  end;
end;

procedure TCoordinatorSqlQueueStore.Save(const ACommands: TStoredSqlCommands);
var
  lArray: TJSONArray;
  lItem: TJSONObject;
  lText: TStringList;
  lIndex: Integer;
  lTmp: string;
begin
  lArray := TJSONArray.Create;
  lText := TStringList.Create;
  try
    for lIndex := 0 to High(ACommands) do
    begin
      lItem := TJSONObject.Create;
      lItem.Add('command_id', ACommands[lIndex].CommandId);
      lItem.Add('instance_id', ACommands[lIndex].InstanceId);
      lItem.Add('correlation_id', ACommands[lIndex].CorrelationId);
      lItem.Add('host', ACommands[lIndex].Host);
      lItem.Add('port', ACommands[lIndex].Port);
      if ACommands[lIndex].ServerDatabase <> '' then
        lItem.Add('server_database', ACommands[lIndex].ServerDatabase);
      lArray.Add(lItem);
    end;
    lText.Text := lArray.AsJSON;
    lTmp := fFileName + '.tmp';
    lText.SaveToFile(lTmp);
    {$ifdef unix}
    if fpRename(PChar(lTmp), PChar(fFileName)) <> 0 then
      raise Exception.Create('Cannot replace SQL command queue');
    {$else}
    if not MoveFileEx(PChar(lTmp), PChar(fFileName),
      MOVEFILE_REPLACE_EXISTING or $8 { MOVEFILE_WRITE_THROUGH }) then
      raise Exception.Create('Cannot replace SQL command queue');
    {$endif}
  finally
    lText.Free;
    lArray.Free;
  end;
end;

end.
