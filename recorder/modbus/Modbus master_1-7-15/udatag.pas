unit UDATag;

{$mode ObjFPC}{$H+}{$codepage UTF8}

interface
uses Classes, SysUtils, dataaccess in '.\interfaces\dataaccess.pas',
  recorder, tags, fgl, ModbusDevice, LazUTF8;

type
PDataAccess = IDataAccess;
TDANotifyEvent = procedure (Sender: TObject; DA: IDataAccess) of object;
TDATag = class;
TDATags = specialize TFPGList<TDATag>;

TDATag = class(TInterfacedObject, IDataAccessEvents)
    private
    fRec: IRecorder;
    fDataAccess: IDataAccess;
    fIndex: IDataAccessIndex;
    fTag: ITag;
    fModbusTag: TModbusTag;
    fNewData: TDANotifyEvent;
    fLast_index: Cardinal; //Индекс последней точки в течение текущей записи (имеет значение если тэг векторный для вычисления временной метки)

    fName: AnsiString;
    function getName: AnsiString;
    procedure setName(const Value: AnsiString);
    function getRecorder: IRecorder;
    procedure setRecorder(const Value: IRecorder);
    function getTag: ITag;
    procedure DoNewData;
    function getDAIndex: IDataAccessIndex;
    function getLastIndex: Cardinal;
    procedure setLastIndex(const Value: Cardinal);
    function getModbusTag: TModbusTag;
    procedure setModbusTag(const Value: TModbusTag);

    public
    destructor Destroy; override;
    constructor Create;
    function Init: boolean;
    function UnInit: boolean;
    function OnDataReady(pDataAccess: IDataAccess): HRESULT; stdcall;
    property Name: AnsiString read getName write setName;
    property Recorder: IRecorder read getRecorder write setRecorder;
    property DAIndex: IDataAccessIndex read getDAIndex;
    property Tag: ITag read getTag;
    property OnNewData: TDANotifyEvent read fNewData write fNewData;
    property Last_index: Cardinal read getLastIndex write setLastIndex;
    property ModbusTag: TModbusTag read getModbusTag write setModbusTag;

end;

implementation

{ TDATag }

constructor TDATag.Create;
begin
  //fOburTag := cTag.create;
end;

destructor TDATag.Destroy;
begin
  fDataAccess := nil;
  fIndex := nil;
  fTag := nil;
  fRec := nil;
  inherited;
end;

procedure TDATag.DoNewData;
begin
  if Assigned(fNewData) then
     fNewData(self, fDataAccess);
end;

function TDATag.getDAIndex: IDataAccessIndex;
begin
  result := fIndex;
end;

function TDATag.getLastIndex: Cardinal;
begin
  result := fLast_index;
end;

function TDATag.getModbusTag: TModbusTag;
begin
  result := fModbusTag;
end;

function TDATag.getName: AnsiString;
begin
  result := fName;
end;

function TDATag.getRecorder: IRecorder;
begin
  result := fRec;
end;

function TDATag.getTag: ITag;
begin
  result := fTag;
end;

function TDATag.Init: boolean;
begin
  fTag := ITag(Recorder.GetTagByName(PAnsiChar(UTF8ToWinCP(ModbusTag.Name))));
  fLast_index := 0;
  if Assigned(fTag) then
    begin
      if fTag.QueryInterface(IDataAccess, fDataAccess) = S_OK then
        begin
          fDataAccess.Open(@fIndex, self);
        end;
    end;
end;

function TDATag.OnDataReady(pDataAccess: IDataAccess): HRESULT; stdcall;
begin
  DoNewData;
end;


procedure TDATag.setLastIndex(const Value: Cardinal);
begin
  fLast_index := Value;
end;

procedure TDATag.setModbusTag(const Value: TModbusTag);
begin
  fModbusTag := Value;
end;

procedure TDATag.setName(const Value: AnsiString);
begin
  fName := value;
end;

procedure TDATag.setRecorder(const Value: IRecorder);
begin
  fRec := Value;
end;

function TDATag.UnInit: boolean;
begin
  if (Assigned(fDataAccess)) then
  begin
    fDataAccess.Close(fIndex);
    fDataAccess := nil;
  end;

  fTag := nil;
  //fRec := nil;
end;

end.

