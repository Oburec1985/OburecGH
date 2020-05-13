
{******************************************}
{                                          }
{             FastReport v4.0              }
{         TeeChart Add-In Object           }
{                                          }
{         Copyright (c) 1998-2008          }
{         by Alexander Tzyganenko,         }
{            Fast Reports Inc.             }
{                                          }
{******************************************}

unit frxChart;

interface

{$I frx.inc}
{$I tee.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Menus, Controls,
{$IFDEF FR_COM}
  FastReport_TLB, ComObj,
{$ENDIF}
  frxClass,
  TeeProcs, TeEngine, Chart, Series, TeCanvas
{$IFDEF Delphi6}
, Variants
{$ENDIF};


type
  TfrxChartObject = class(TComponent);  // fake component
  TChartClass = class of TCustomChart;

  TfrxSeriesDataType = (dtDBData, dtBandData, dtFixedData);
  TfrxSeriesSortOrder = (soNone, soAscending, soDescending);
  TfrxSeriesXType = (xtText, xtNumber, xtDate);
  TSeriesClass = class of TChartSeries;
  TfrxChartSeries = (csLine, csArea, csPoint, csBar, csHorizBar,
    csPie, csGantt, csFastLine, csArrow, csBubble, csChartShape, csHorizArea,
    csHorizLine, csPolar, csRadar, csPolarBar, csGauge, csSmith, csPyramid,
    csDonut, csBezier, csCandle, csVolume, csPointFigure, csHistogram,
    csHorizHistogram, csErrorBar, csError, csHighLow, csFunnel, csBox,
    csHorizBox, csSurface, csContour, csWaterFall, csColorGrid, csVector3D,
    csTower, csTriSurface, csPoint3D, csBubble3D, csMyPoint, csBarJoin, csBar3D);


{$IFDEF FR_COM}
  TfrxSeriesItem = class(TCollectionItem, IfrxSeriesItem, IUnknown )
  private
    FRefCount: Integer;
    FSeries: TChartSeries;
{$ELSE}
  TfrxSeriesItem = class(TCollectionItem)
  private
{$ENDIF}
    FDataBand: TfrxDataBand;
    FDataSet: TfrxDataSet;
    FDataSetName: String;
    FDataType: TfrxSeriesDataType;
    FSortOrder: TfrxSeriesSortOrder;
    FTopN: Integer;
    FTopNCaption: String;
    FSource1: String;
    FSource2: String;
    FSource3: String;
    FSource4: String;
    FSource5: String;
    FSource6: String;
    FXType: TfrxSeriesXType;
    FValues1: String;
    FValues2: String;
    FValues3: String;
    FValues4: String;
    FValues5: String;
    FValues6: String;
    procedure FillSeries(Series: TChartSeries);
    procedure SetDataSet(const Value: TfrxDataSet);
    procedure SetDataSetName(const Value: String);
    function GetDataSetName: String;
{$IFDEF FR_COM}
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    { IfrxSeriesItem }
    function Get_DataBand(out Value: IfrxDataBand): HResult; stdcall;
    function Set_DataBand(const Value: IfrxDataBand): HResult; stdcall;
    function Get_DataSet(out Value: IfrxDataSet): HResult; stdcall;
    function Set_DataSet(const Value: IfrxDataSet): HResult; stdcall;
    function Get_DataSetName(out Value: WideString): HResult; stdcall;
    function Set_DataSetName(const Value: WideString): HResult; stdcall;
    function Get_XSource(out Value: WideString): HResult; stdcall;
    function Set_XSource(const Value: WideString): HResult; stdcall;
    function Get_YSource(out Value: WideString): HResult; stdcall;
    function Set_YSource(const Value: WideString): HResult; stdcall;
    function Get_XValues(out Value: WideString): HResult; stdcall;
    function Set_XValues(const Value: WideString): HResult; stdcall;
    function Get_YValues(out Value: WideString): HResult; stdcall;
    function Set_YValues(const Value: WideString): HResult; stdcall;
    function Get_TopNCaption(out Value: WideString): HResult; stdcall;
    function Set_TopNCaption(const Value: WideString): HResult; stdcall;
    function Get_Title(out Value: WideString): HResult; stdcall;
    function Set_Title(const Value: WideString): HResult; stdcall;
    function Get_ZSource(out Value: WideString): HResult; stdcall;
    function Set_ZSource(const Value: WideString): HResult; stdcall;
    function Get_ZValues(out Value: WideString): HResult; stdcall;
    function Set_ZValues(const Value: WideString): HResult; stdcall;
    function Get_FourthSource(out Value: WideString): HResult; stdcall;
    function Set_FourthSource(const Value: WideString): HResult; stdcall;
    function Get_FourthValues(out Value: WideString): HResult; stdcall;
    function Set_FourthValues(const Value: WideString): HResult; stdcall;
    function Get_FifthSource(out Value: WideString): HResult; stdcall;
    function Set_FifthSource(const Value: WideString): HResult; stdcall;
    function Get_FifthValues(out Value: WideString): HResult; stdcall;
    function Set_FifthValues(const Value: WideString): HResult; stdcall;
    function Get_SixthSource(out Value: WideString): HResult; stdcall;
    function Set_SixthSource(const Value: WideString): HResult; stdcall;
    function Get_SixthValues(out Value: WideString): HResult; stdcall;
    function Set_SixthValues(const Value: WideString): HResult; stdcall;
    function Get_XAxisType(out Value: frxSeriesXType): HResult; stdcall;
    function Set_XAxisType(Value: frxSeriesXType): HResult; stdcall;
    function Set_ColorEachPoint(Value: WordBool): HResult; stdcall;
    function Set_ColorEachLine(Value: WordBool): HResult; stdcall;
{$ENDIF}
  published
    property DataType: TfrxSeriesDataType read FDataType write FDataType;
    property DataBand: TfrxDataBand read FDataBand write FDataBand;
    property DataSet: TfrxDataSet read FDataSet write SetDataSet;
    property DataSetName: String read GetDataSetName write SetDataSetName;
    property SortOrder: TfrxSeriesSortOrder read FSortOrder write FSortOrder;
    property TopN: Integer read FTopN write FTopN;
    property TopNCaption: String read FTopNCaption write FTopNCaption;
    property XType: TfrxSeriesXType read FXType write FXType;

    { source expressions }
    property Source1: String read FSource1 write FSource1;
    property Source2: String read FSource2 write FSource2;
    property Source3: String read FSource3 write FSource3;
    property Source4: String read FSource4 write FSource4;
    property Source5: String read FSource5 write FSource5;
    property Source6: String read FSource6 write FSource6;

    { ready values. For internal use only. }
    property Values1: String read FValues1 write FValues1;
    property Values2: String read FValues2 write FValues2;
    property Values3: String read FValues3 write FValues3;
    property Values4: String read FValues4 write FValues4;
    property Values5: String read FValues5 write FValues5;
    property Values6: String read FValues6 write FValues6;

    { backward compatibility }
    property XSource: String read FSource1 write FSource1;
    property YSource: String read FSource2 write FSource2;
    property XValues: String read FValues1 write FValues1;
    property YValues: String read FValues2 write FValues2;
    {}
{$IFDEF FR_COM}
    property Series: TChartSeries read FSeries write FSeries;
{$ENDIF}
  end;

  TfrxSeriesData = class(TCollection)
  private
    FReport: TfrxReport;
    function GetSeries(Index: Integer): TfrxSeriesItem;
  public
    constructor Create(Report: TfrxReport);
    function Add: TfrxSeriesItem;
    property Items[Index: Integer]: TfrxSeriesItem read GetSeries; default;
  end;

{$IFDEF FR_COM}
  TfrxChartAxis = class(TAutoObject, IfrxChartAxis)
    FAxis:  TChartAxis;
  private
    function Get_Automatic: WordBool; safecall;
    procedure Set_Automatic(Value: WordBool); safecall;
    function Get_Minimum: Double; safecall;
    procedure Set_Minimum(Value: Double); safecall;
    function Get_Maximum: Double; safecall;
    procedure Set_Maximum(Value: Double); safecall;
    function Get_AutomaticMaximum: WordBool; safecall;
    procedure Set_AutomaticMaximum(Value: WordBool); safecall;
    function Get_AutomaticMinimum: WordBool; safecall;
    procedure Set_AutomaticMinimum(Value: WordBool); safecall;
    function Get_AxisValuesFormat: WideString; safecall;
    procedure Set_AxisValuesFormat(const Value: WideString); safecall;
    function Get_EndPosition: Double; safecall;
    procedure Set_EndPosition(Value: Double); safecall;
    function Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
    function Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function Get_Labels: WordBool; safecall;
    procedure Set_Labels(Value: WordBool); safecall;
    function Get_LabelsExponent: WordBool; safecall;
    procedure Set_LabelsExponent(Value: WordBool); safecall;
    function Get_LabelsSeparation: Integer; safecall;
    procedure Set_LabelsSeparation(Value: Integer); safecall;
    function Get_LabelStyle: Integer; safecall;
    procedure Set_LabelStyle(Value: Integer); safecall;
    function Get_Logarithmic: WordBool; safecall;
    procedure Set_Logarithmic(Value: WordBool); safecall;
{
    property Automatic: WordBool read Get_Automatic write Set_Automatic;
    property Minimum: Double read Get_Minimum write Set_Minimum;
    property Maximum: Double read Get_Maximum write Set_Maximum;
    property AutomaticMaximum: WordBool read Get_AutomaticMaximum write Set_AutomaticMaximum;
    property AutomaticMinimum: WordBool read Get_AutomaticMinimum write Set_AutomaticMinimum;
    property AxisValuesFormat: WideString read Get_AxisValuesFormat write Set_AxisValuesFormat;
    property EndPosition: Double read Get_EndPosition write Set_EndPosition;
    property Width: Integer read Get_Width write Set_Width;
    property Color: Integer read Get_Color write Set_Color;
    property Labels: WordBool read Get_Labels write Set_Labels;
    property LabelsExponent: WordBool read Get_LabelsExponent write Set_LabelsExponent;
    property LabelsSeparation: Integer read Get_LabelsSeparation write Set_LabelsSeparation;
    property LabelStyle: Integer read Get_LabelStyle write Set_LabelStyle;
    property Logarithmic: WordBool read Get_Logarithmic write Set_Logarithmic;
}
{
    function Get_Automatic(out Value: WordBool): HResult; stdcall;
    function Set_Automatic(Value: WordBool): HResult; stdcall;
    function Get_Minimum(out Value: Double): HResult; stdcall;
    function Set_Minimum(Value: Double): HResult; stdcall;
    function Get_Maximum(out Value: Double): HResult; stdcall;
    function Set_Maximum(Value: Double): HResult; stdcall;
    function Get_AutomaticMaximum(out Value: WordBool): HResult; stdcall;
    function Set_AutomaticMaximum(Value: WordBool): HResult; stdcall;
    function Get_AutomaticMinimum(out Value: WordBool): HResult; stdcall;
    function Set_AutomaticMinimum(Value: WordBool): HResult; stdcall;
    function Get_AxisValuesFormat(out Value: WideString): HResult; stdcall;
    function Set_AxisValuesFormat(const Value: WideString): HResult; stdcall;
    function Get_EndPosition(out Value: Double): HResult; stdcall;
    function Set_EndPosition(Value: Double): HResult; stdcall;
    function Get_Width(out Value: Integer): HResult; stdcall;
    function Set_Width(Value: Integer): HResult; stdcall;
    function Get_Color(out Value: Integer): HResult; stdcall;
    function Set_Color(Value: Integer): HResult; stdcall;
    function Get_Labels(out Value: WordBool): HResult; stdcall;
    function Set_Labels(Value: WordBool): HResult; stdcall;
    function Get_LabelsExponent(out Value: WordBool): HResult; stdcall;
    function Set_LabelsExponent(Value: WordBool): HResult; stdcall;
    function Get_LabelsSeparation(out Value: Integer): HResult; stdcall;
    function Set_LabelsSeparation(Value: Integer): HResult; stdcall;
    function Get_LabelStyle(out Value: Integer): HResult; stdcall;
    function Set_LabelStyle(Value: Integer): HResult; stdcall;
    function Get_Logarithmic(out Value: WordBool): HResult; stdcall;
    function Set_Logarithmic(Value: WordBool): HResult; stdcall;
}
  public
    constructor Create(Axis: TChartAxis);
  end;

  TfrxChartView = class(TfrxView, IfrxChartView)
  private
    FLeftAxis:  TfrxChartAxis;
    FBottomAxis:  TfrxChartAxis;
{$ELSE}
  TfrxChartView = class(TfrxView)
{$ENDIF}
  private
    FChart: TCustomChart;
    FSeriesData: TfrxSeriesData;
    FIgnoreNulls: Boolean;
    procedure FillChart;
    procedure ReadData(Stream: TStream);
    procedure ReadData1(Reader: TReader);
    procedure ReadData2(Reader: TReader);
    procedure WriteData(Stream: TStream);
    procedure WriteData1(Writer: TWriter);
    procedure WriteData2(Writer: TWriter);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CreateChart; virtual;
    class function GetChartClass: TChartClass; virtual;
    {$IFDEF FR_COM}
    function GetSeriesItem(Index: Integer): IfrxSeriesItem; safecall;
    function AddSeriesItem(SeriesType: frxSeriesType): IfrxSeriesItem; safecall;
    function SeriesCount: Integer; safecall;
    function Get_View3D: WordBool; safecall;
    procedure Set_View3D(Value: WordBool); safecall;
    function Get_View3dWalls: WordBool; safecall;
    procedure Set_View3dWalls(Value: WordBool); safecall;
    function Get_LeftAxis: IfrxChartAxis; safecall;
    function Get_BottomAxis: IfrxChartAxis; safecall;
    property View3D: WordBool read Get_View3D write Set_View3D;
    property View3dWalls: WordBool read Get_View3dWalls write Set_View3dWalls;
    property LeftAxis: IfrxChartAxis read Get_LeftAxis;
    property BottomAxis: IfrxChartAxis read Get_BottomAxis;
    {$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetDescription: String; override;
    procedure Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX, OffsetY: Extended); override;
    procedure AfterPrint; override;
    procedure GetData; override;
    procedure BeforeStartReport; override;
    procedure OnNotify(Sender: TObject); override;
    procedure ClearSeries;
    procedure AddSeries(Series: TfrxChartSeries);

    property Chart: TCustomChart read FChart;
    property SeriesData: TfrxSeriesData read FSeriesData;
  published
    property IgnoreNulls: Boolean read FIgnoreNulls write FIgnoreNulls default False;
    property BrushStyle;
    property Color;
    property Cursor;
    property Frame;
    property TagStr;
    property URL;
  end;


implementation

uses
  frxChartHelpers, frxChartRTTI,
{$IFNDEF NO_EDITORS}
  frxChartEditor,
{$ENDIF}
  frxDsgnIntf, frxUtils, frxRes, Math;


{ TfrxSeriesItem }

procedure TfrxSeriesItem.SetDataSet(const Value: TfrxDataSet);
begin
  FDataSet := Value;
  if FDataSet = nil then
    FDataSetName := '' else
    FDataSetName := FDataSet.UserName;
end;

procedure TfrxSeriesItem.SetDataSetName(const Value: String);
begin
  FDataSetName := Value;
  if FDataSetName = '' then
    FDataSet := nil
  else  if TfrxSeriesData(Collection).FReport <> nil then
    FDataSet := TfrxSeriesData(Collection).FReport.FindDataSet(FDataSet, FDataSetName);
end;

function TfrxSeriesItem.GetDataSetName: String;
begin
  if FDataSet = nil then
    Result := FDataSetName else
    Result := FDataSet.UserName;
end;

procedure TfrxSeriesItem.FillSeries(Series: TChartSeries);
var
  i: Integer;
  sl1, sl2, sl3, sl4, sl5, sl6: TStringList;
  v1, v2, v3, v4, v5, v6: String;
  Helper: TfrxSeriesHelper;

  procedure Sort;
  var
    i, idx, iStart, SortOrd: Integer;
    d, mMax: Double;
    s: String;
  begin
    if sl1.Count <> sl2.Count then exit;

   {bug fix, stringList sort all negative values as string }
    if FSortOrder = soAscending then  SortOrd := 1
    else SortOrd := -1;
    iStart := 0;

    while sl2.Count > iStart do
    begin
      idx := 0;
      mMax := MaxDouble * SortOrd;
      for i := iStart to sl2.Count - 1 do
      begin
        s := sl2[i];
        if not frxIsValidFloat(s) then d := 0
        else d := frxStrToFloat(s);
        if d * SortOrd < mMax * SortOrd then
        begin
          mMax := d;
          idx := i;
        end;
      end;
      sl1.Move(idx,iStart);
      sl2.Move(idx,iStart);
      if idx < sl3.Count then sl3.Move(idx, iStart);
      if idx < sl4.Count then sl4.Move(idx, iStart);
      if idx < sl5.Count then sl5.Move(idx, iStart);
      if idx < sl6.Count then sl6.Move(idx, iStart);
      inc(iStart);
    end;
  end;

  procedure MakeTopN;
  var
    i: Integer;
    d: Double;
  begin
    if sl1.Count <> sl2.Count then exit;
    { for future using
    if FSortOrder <> soNone then Sort;}

    FSortOrder := soDescending;
    Sort;
    d := 0;
    for i := sl2.Count - 1 downto FTopN - 1 do
    begin
      d := d + frxStrToFloat(sl2[i]);
      sl1.Delete(i);
      sl2.Delete(i);
      if i < sl3.Count then sl3.Delete(i);
      if i < sl4.Count then sl4.Delete(i);
      if i < sl5.Count then sl5.Delete(i);
      if i < sl6.Count then sl6.Delete(i);
    end;

    sl1.Add(FTopNCaption);
    sl2.Add(FloatToStr(d));
  end;

begin
  sl1 := TStringList.Create;
  sl2 := TStringList.Create;
  sl3 := TStringList.Create;
  sl4 := TStringList.Create;
  sl5 := TStringList.Create;
  sl6 := TStringList.Create;
  Series.Clear;

  v1 := FValues1;
  if (v1 <> '') and (v1[1] = ';') then
    Delete(v1, 1, 1);
  v2 := FValues2;
  if (v2 <> '') and (v2[1] = ';') then
    Delete(v2, 1, 1);
  v3 := FValues3;
  if (v3 <> '') and (v3[1] = ';') then
    Delete(v3, 1, 1);
  v4 := FValues4;
  if (v4 <> '') and (v4[1] = ';') then
    Delete(v4, 1, 1);
  v5 := FValues5;
  if (v5 <> '') and (v5[1] = ';') then
    Delete(v5, 1, 1);
  v6 := FValues6;
  if (v6 <> '') and (v6[1] = ';') then
    Delete(v6, 1, 1);

  frxSetCommaText(v1, sl1);
  frxSetCommaText(v2, sl2);
  frxSetCommaText(v3, sl3);
  frxSetCommaText(v4, sl4);
  frxSetCommaText(v5, sl5);
  frxSetCommaText(v6, sl6);

  Helper := frxFindSeriesHelper(Series);

  try
    if sl2.Count > 0 then
    begin
      if (FTopN > 0) and (FTopN < sl2.Count) then
        MakeTopN
      else if FSortOrder <> soNone then
        Sort;

      for i := 0 to sl2.Count - 1 do
      begin
        if i < sl1.Count then v1 := sl1[i] else v1 := '';
        if i < sl2.Count then v2 := sl2[i] else v2 := '';
        if i < sl3.Count then v3 := sl3[i] else v3 := '';
        if i < sl4.Count then v4 := sl4[i] else v4 := '';
        if i < sl5.Count then v5 := sl5[i] else v5 := '';
        if i < sl6.Count then v6 := sl6[i] else v6 := '';
        Helper.AddValues(Series, v1, v2, v3, v4, v5, v6, FXType);
      end;
    end;

  finally
    Helper.Free;
    sl1.Free;
    sl2.Free;
    sl3.Free;
    sl4.Free;
    sl5.Free;
    sl6.Free;
  end;
end;

{$IFDEF FR_COM}
function TfrxSeriesItem.QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TfrxSeriesItem._AddRef: Integer; stdcall;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TfrxSeriesItem._Release: Integer; stdcall;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then Destroy;
end;

function TfrxSeriesItem.Get_DataBand(out Value: IfrxDataBand): HResult; stdcall;
begin
  Value := DataBand;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_DataBand(const Value: IfrxDataBand): HResult; stdcall;
var
  idsp:   {IfrxComponentSelf}IInterfaceComponentReference;
begin
  Result := Value.QueryInterface({IfrxComponentSelf}IInterfaceComponentReference, idsp);
  if Result = S_OK then
  begin
    DataBand := TfrxDataBand(idsp.{Get_Object} GetComponent);
    idsp._Release;
  end;
end;

function TfrxSeriesItem.Get_DataSet(out Value: IfrxDataSet): HResult; stdcall;
begin
  Value := DataSet;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_DataSet(const Value: IfrxDataSet): HResult; stdcall;
var
  idsp:   {IfrxComponentSelf} IInterfaceComponentReference;
begin
  Result := Value.QueryInterface({IfrxComponentSelf}IInterfaceComponentReference, idsp);
  if Result = S_OK  then
  begin
    DataSet := TfrxDataSet(idsp.GetComponent{Get_Object});
  end;
end;

function TfrxSeriesItem.Get_DataSetName(out Value: WideString): HResult; stdcall;
begin
  Value := DataSetName;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_DataSetName(const Value: WideString): HResult; stdcall;
begin
  DataSetName := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_XSource(out Value: WideString): HResult; stdcall;
begin
  Value := XSource;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_XSource(const Value: WideString): HResult; stdcall;
begin
  XSource := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_YSource(out Value: WideString): HResult; stdcall;
begin
  Value := YSource;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_YSource(const Value: WideString): HResult; stdcall;
begin
  YSource := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_XValues(out Value: WideString): HResult; stdcall;
begin
  Value := XValues;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_XValues(const Value: WideString): HResult; stdcall;
begin
  XValues := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_YValues(out Value: WideString): HResult; stdcall;
begin
  Value := YValues;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_YValues(const Value: WideString): HResult; stdcall;
begin
  YValues := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_TopNCaption(out Value: WideString): HResult; stdcall;
begin
  Value := TopNCaption;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_TopNCaption(const Value: WideString): HResult; stdcall;
begin
  TopNCaption := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_Title(out Value: WideString): HResult; stdcall;
begin
  Value := Series.Title;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_Title(const Value: WideString): HResult; stdcall;
begin
  Series.Title := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_ZSource(out Value: WideString): HResult; stdcall;
begin
  Value := Source3;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_ZSource(const Value: WideString): HResult; stdcall;
begin
  Source3 := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_ZValues(out Value: WideString): HResult; stdcall;
begin
  Value := Values3;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_ZValues(const Value: WideString): HResult; stdcall;
begin
  Values3 := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_FourthSource(out Value: WideString): HResult; stdcall;
begin
  Value := Source4;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_FourthSource(const Value: WideString): HResult; stdcall;
begin
  Source4 := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_FourthValues(out Value: WideString): HResult; stdcall;
begin
  Value := Values4;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_FourthValues(const Value: WideString): HResult; stdcall;
begin
  Values4 := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_FifthSource(out Value: WideString): HResult; stdcall;
begin
  Value := Source5;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_FifthSource(const Value: WideString): HResult; stdcall;
begin
  Source5 := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_FifthValues(out Value: WideString): HResult; stdcall;
begin
  Value := Values5;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_FifthValues(const Value: WideString): HResult; stdcall;
begin
  Values5 := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_SixthSource(out Value: WideString): HResult; stdcall;
begin
  Value := Source6;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_SixthSource(const Value: WideString): HResult; stdcall;
begin
  Source6 := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Get_SixthValues(out Value: WideString): HResult; stdcall;
begin
  Value := Values6;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_SixthValues(const Value: WideString): HResult; stdcall;
begin
  Values6 := Value;
  Result := S_OK;
end;
function TfrxSeriesItem.Get_XAxisType(out Value: frxSeriesXType): HResult; stdcall;
begin
  Value := frxSeriesXType(XType);
  Result := S_OK;
end;

function TfrxSeriesItem.Set_XAxisType(Value: frxSeriesXType): HResult; stdcall;
begin
  XType := TfrxSeriesXType(Value);
  Result := S_OK;
end;

function TfrxSeriesItem.Set_ColorEachPoint(Value: WordBool): HResult; stdcall;
begin
  FSeries.ColorEachPoint := Value;
  Result := S_OK;
end;

function TfrxSeriesItem.Set_ColorEachLine(Value: WordBool): HResult; stdcall;
begin
  Result := E_INVALIDARG;
  if FSeries is TCustomSeries then
  begin
    TCustomSeries(FSeries).ColorEachLine := Value;
    Result := S_OK;
  end;
end;
{$ENDIF}

{ TfrxSeriesData }

constructor TfrxSeriesData.Create(Report: TfrxReport);
begin
  inherited Create(TfrxSeriesItem);
  FReport := Report;
end;

function TfrxSeriesData.Add: TfrxSeriesItem;
begin
  Result := TfrxSeriesItem(inherited Add);
end;

function TfrxSeriesData.GetSeries(Index: Integer): TfrxSeriesItem;
begin
  Result := TfrxSeriesItem(inherited Items[Index]);
end;


{ TfrxChartView }

constructor TfrxChartView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CreateChart;
  FSeriesData := TfrxSeriesData.Create(Report);
end;

destructor TfrxChartView.Destroy;
begin
  FChart.Free;
  inherited Destroy;
  FSeriesData.Free;
end;

class function TfrxChartView.GetDescription: String;
begin
  Result := frxResources.Get('obChart');
end;

procedure TfrxChartView.Notification(AComponent: TComponent; Operation: TOperation);
var
  i: Integer;
begin
  inherited;
  if Operation = opRemove then
  begin
    for i := 0 to FSeriesData.Count - 1 do
      if AComponent is TfrxDataSet then
      begin
        if FSeriesData[i].DataSet = AComponent then
          FSeriesData[i].DataSet := nil;
      end
      else if AComponent is TfrxBand then
      begin
        if FSeriesData[i].DataBand = AComponent then
          FSeriesData[i].DataBand := nil;
      end;
  end;
end;

class function TfrxChartView.GetChartClass: TChartClass;
begin
  Result := TChart;
end;

procedure TfrxChartView.CreateChart;
begin
  FChart := GetChartClass.Create(Self);
  with FChart do
  begin
    Color := clWhite;
    BevelInner := bvNone;
    BevelOuter := bvNone;
    Name := 'Chart';
    Frame.Visible := False;
    View3DOptions.Rotation := 0;
    Title.Text.Text := '';
  end;
end;

procedure TfrxChartView.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty('Chart', ReadData, WriteData, True);
  Filer.DefineProperty('ChartElevation', ReadData1, WriteData1, True);
  Filer.DefineProperty('SeriesData', ReadData2, WriteData2, True);
end;

procedure TfrxChartView.ReadData(Stream: TStream);
begin
  FChart.Free;
  CreateChart;
  Stream.ReadComponent(FChart);
end;

procedure TfrxChartView.WriteData(Stream: TStream);
begin
  Stream.WriteComponent(FChart);
end;

procedure TfrxChartView.ReadData1(Reader: TReader);
begin
  FChart.View3DOptions.Elevation := Reader.ReadInteger;
end;

procedure TfrxChartView.WriteData1(Writer: TWriter);
begin
  Writer.WriteInteger(FChart.View3DOptions.Elevation);
end;

procedure TfrxChartView.ReadData2(Reader: TReader);
begin
  frxReadCollection(FSeriesData, Reader, Self);
end;

procedure TfrxChartView.WriteData2(Writer: TWriter);
begin
  frxWriteCollection(FSeriesData, Writer, Self);
end;

procedure TfrxChartView.FillChart;
var
  i: Integer;
begin
  for i := 0 to FSeriesData.Count - 1 do
    FSeriesData[i].FillSeries(FChart.Series[i]);
end;

procedure TfrxChartView.Draw(Canvas: TCanvas; ScaleX, ScaleY, OffsetX,
  OffsetY: Extended);
var
  EMF: TMetafile;
begin
  BeginDraw(Canvas, ScaleX, ScaleY, OffsetX, OffsetY);
  DrawBackground;

  FillChart;

  if Color = clTransparent then
    FChart.Color := clWhite else
    FChart.Color := Color;
  FChart.BufferedDisplay := True;
  EMF := FChart.TeeCreateMetafile(False, Rect(0, 0, Round(Width), Round(Height)));
  Canvas.StretchDraw(Rect(FX, FY, FX1, FY1), EMF);
  EMF.Free;

  DrawFrame;
end;

procedure TfrxChartView.AfterPrint;
var
  i: Integer;
begin
  for i := 0 to FSeriesData.Count - 1 do
    with FSeriesData[i] do
    begin
      Values1 := '';
      Values2 := '';
      Values3 := '';
      Values4 := '';
      Values5 := '';
      Values6 := '';
    end;
end;

procedure TfrxChartView.GetData;
var
  i: Integer;
  function ConvertVarToStr(Val: Variant): String;
  begin
    if not FIgnoreNulls and VarIsNull(Val) then
      Result := '0'
    else
      Result := VarToStr(Val)
  end;
begin
  inherited;
  for i := 0 to FSeriesData.Count - 1 do
    with FSeriesData[i] do
      if (DataType = dtDBData) and (DataSet <> nil) then
      begin
        Values1 := '';
        Values2 := '';
        Values3 := '';
        Values4 := '';
        Values5 := '';
        Values6 := '';

        DataSet.First;
        while not DataSet.Eof do
        begin
          if Source1 <> '' then
            Values1 := Values1 + ';' + VarToStr(Report.Calc(Source1));
          if Source2 <> '' then
            Values2 := Values2 + ';' + ConvertVarToStr(Report.Calc(Source2));
          if Source3 <> '' then
            Values3 := Values3 + ';' + ConvertVarToStr(Report.Calc(Source3));
          if Source4 <> '' then
            Values4 := Values4 + ';' + ConvertVarToStr(Report.Calc(Source4));
          if Source5 <> '' then
            Values5 := Values5 + ';' + ConvertVarToStr(Report.Calc(Source5));
          if Source6 <> '' then
            Values6 := Values6 + ';' + ConvertVarToStr(Report.Calc(Source6));
          DataSet.Next;
        end;
      end
      else if DataType = dtFixedData then
      begin
        Values1 := Source1;
        Values2 := Source2;
        Values3 := Source3;
        Values4 := Source4;
        Values5 := Source5;
        Values6 := Source6;
      end
end;

procedure TfrxChartView.BeforeStartReport;
var
  i: Integer;
begin
  for i := 0 to FSeriesData.Count - 1 do
    with FSeriesData[i] do
    begin
      Values1 := '';
      Values2 := '';
      Values3 := '';
      Values4 := '';
      Values5 := '';
      Values6 := '';
    end;
  Report.Engine.NotifyList.Add(Self);
end;

procedure TfrxChartView.OnNotify(Sender: TObject);
var
  i: Integer;
  function ConvertVarToStr(Val: Variant): String;
  begin
    if FIgnoreNulls and VarIsNull(Val) then
      Result := '0'
    else
      Result := VarToStr(Val)
  end;
begin
  inherited;
  for i := 0 to FSeriesData.Count - 1 do
    with FSeriesData[i] do
      if (DataType = dtBandData) and (DataBand = Sender) then
      begin
        Report.CurObject := Self.Name;
        if Source1 <> '' then
          Values1 := Values1 + ';' + VarToStr(Report.Calc(Source1));
        if Source2 <> '' then
          Values2 := Values2 + ';' + ConvertVarToStr(Report.Calc(Source2));
        if Source3 <> '' then
          Values3 := Values3 + ';' + ConvertVarToStr(Report.Calc(Source3));
        if Source4 <> '' then
          Values4 := Values4 + ';' + ConvertVarToStr(Report.Calc(Source4));
        if Source5 <> '' then
          Values5 := Values5 + ';' + ConvertVarToStr(Report.Calc(Source5));
        if Source6 <> '' then
          Values6 := Values6 + ';' + ConvertVarToStr(Report.Calc(Source6));
      end;
end;

procedure TfrxChartView.AddSeries(Series: TfrxChartSeries);
var
  sc: TSeriesClass;
  s: TChartSeries;
  b: Boolean;
{$IFDEF FR_COM}
  item: TfrxSeriesItem;
{$ENDIF}
begin
  sc := frxChartSeries[Integer(Series)];
  s := TChartSeries(sc.NewInstance);
  s.Create(Chart);
  Chart.AddSeries(s);
{$IFNDEF FR_COM}
  SeriesData.Add;
{$ELSE}
  item := SeriesData.Add;
  item.Series := s;
{$ENDIF}

  with Chart do
  begin
    b := not (s is TPieSeries);
    View3DOptions.Orthogonal := b;
    AxisVisible := b;
    View3DWalls := b;
  end;
end;

procedure TfrxChartView.ClearSeries;
begin
  FChart.Free;
  CreateChart;
  SeriesData.Clear;
end;

{$IFDEF FR_COM}
function TfrxChartView.GetSeriesItem(Index: Integer): IfrxSeriesItem; safecall;
begin
  Result := SeriesData.Items[Index] as IfrxSeriesItem;
  Result._AddRef;
end;

function TfrxChartView.AddSeriesItem(SeriesType: frxSeriesType): IfrxSeriesItem; safecall;
begin
  AddSeries( TfrxChartSeries(SeriesType) );
  Result := GetSeriesItem(SeriesData.Count-1);
end;

function TfrxChartView.SeriesCount: Integer; safecall;
begin
  Result := SeriesData.Count;
end;

function TfrxChartView.Get_View3D: WordBool; safecall;
begin
  Result := Chart.View3D;
end;

procedure TfrxChartView.Set_View3D(Value: WordBool); safecall;
begin
  Chart.View3D := Value;
end;

function TfrxChartView.Get_View3dWalls: WordBool; safecall;
begin
  Result := Chart.View3DWalls;
end;

procedure TfrxChartView.Set_View3dWalls(Value: WordBool); safecall;
begin
  Chart.View3dWalls := Value;
end;

function TfrxChartView.Get_LeftAxis: IfrxChartAxis; safecall;
begin
  if FLeftAxis = nil then
    FLeftAxis := TfrxChartAxis.Create(Chart.LeftAxis);
  Result := FLeftAxis;
  Result._AddRef;
end;

function TfrxChartView.Get_BottomAxis: IfrxChartAxis; safecall;
begin
  if FBottomAxis = nil then
    FBottomAxis := TfrxChartAxis.Create(Chart.BottomAxis);
  Result := FBottomAxis;
  Result._AddRef;
end;

{ TfrxChartAxis }
constructor TfrxChartAxis.Create(Axis: TChartAxis);
begin
  FAxis := Axis;
end;

function TfrxChartAxis.Get_Automatic: WordBool; safecall;
begin
  Result := FAxis.Automatic;
end;

procedure TfrxChartAxis.Set_Automatic(Value: WordBool); safecall;
begin
  FAxis.Automatic := Value;
end;

function TfrxChartAxis.Get_Minimum: Double; safecall;
begin
  Result := FAxis.Minimum;
end;

procedure TfrxChartAxis.Set_Minimum(Value: Double); safecall;
begin
  FAxis.Minimum := Value;
end;

function TfrxChartAxis.Get_Maximum: Double; safecall;
begin
  Result := FAxis.Maximum;
end;

procedure TfrxChartAxis.Set_Maximum(Value: Double); safecall;
begin
  FAxis.Maximum := Value;
end;

function TfrxChartAxis.Get_AutomaticMaximum: WordBool; safecall;
begin
  Result := FAxis.AutomaticMaximum;
end;

procedure TfrxChartAxis.Set_AutomaticMaximum(Value: WordBool); safecall;
begin
  FAxis.AutomaticMaximum := Value;
end;

function TfrxChartAxis.Get_AutomaticMinimum: WordBool; safecall;
begin
  Result := FAxis.AutomaticMinimum;
end;

procedure TfrxChartAxis.Set_AutomaticMinimum(Value: WordBool); safecall;
begin
  FAxis.AutomaticMinimum := Value;
end;

function TfrxChartAxis.Get_AxisValuesFormat: WideString; safecall;
begin
  Result := FAxis.AxisValuesFormat;
end;

procedure TfrxChartAxis.Set_AxisValuesFormat(const Value: WideString); safecall;
begin
  FAxis.AxisValuesFormat := Value;
end;

function TfrxChartAxis.Get_EndPosition: Double; safecall;
begin
  Result := FAxis.EndPosition;
end;

procedure TfrxChartAxis.Set_EndPosition(Value: Double); safecall;
begin
  FAxis.EndPosition := Value;
end;

function TfrxChartAxis.Get_Width: Integer; safecall;
begin
  Result := FAxis.Axis.Width;
end;

procedure TfrxChartAxis.Set_Width(Value: Integer); safecall;
begin
  FAxis.Axis.Width := Value;
end;

function TfrxChartAxis.Get_Color: Integer; safecall;
begin
  Result := FAxis.Axis.Color;
end;

procedure TfrxChartAxis.Set_Color(Value: Integer); safecall;
begin
  FAxis.Axis.Color := Value;
end;

function TfrxChartAxis.Get_Labels: WordBool; safecall;
begin
  Result := FAxis.Labels;
end;

procedure TfrxChartAxis.Set_Labels(Value: WordBool); safecall;
begin
  FAxis.Labels := Value;
end;

function TfrxChartAxis.Get_LabelsExponent: WordBool; safecall;
begin
  Result := FAxis.LabelsExponent;
end;

procedure TfrxChartAxis.Set_LabelsExponent(Value: WordBool); safecall;
begin
  FAxis.LabelsExponent := Value;
end;

function TfrxChartAxis.Get_LabelsSeparation: Integer; safecall;
begin
  Result := FAxis.LabelsSeparation;
end;

procedure TfrxChartAxis.Set_LabelsSeparation(Value: Integer); safecall;
begin
  FAxis.LabelsSeparation := Value;
end;

function TfrxChartAxis.Get_LabelStyle: Integer; safecall;
begin
  Result := Integer(FAxis.LabelStyle);
end;

procedure TfrxChartAxis.Set_LabelStyle(Value: Integer); safecall;
begin
  FAxis.LabelStyle := TAxisLabelStyle(Value);
end;

function TfrxChartAxis.Get_Logarithmic: WordBool; safecall;
begin
  Result := FAxis.Logarithmic;
end;

procedure TfrxChartAxis.Set_Logarithmic(Value: WordBool); safecall;
begin
  FAxis.Logarithmic := Value;
end;
{$ENDIF}


initialization
{$IFNDEF TeeChartStd}
{$IFNDEF TeeChartStd7}
{$IFNDEF TeeChartStd8}
{$IFNDEF TeeChart4}
  RegisterTeeStandardSeries;
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
  frxObjects.RegisterObject1(TfrxChartView, nil, '', '', 0, 25);

finalization
  frxObjects.UnRegister(TfrxChartView);

end.


