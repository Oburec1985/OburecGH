{*************************************************************************}
{ TDBAdvSmoothDatePicker component                                          }
{ for Delphi & C++Builder                                                 }
{                                                                         }
{ written by TMS Software                                                 }
{           copyright � 2010                                              }
{           Email : info@tmssoftware.com                                  }
{           Web : http://www.tmssoftware.com                              }
{                                                                         }
{ The source code is given as is. The author is not responsible           }
{ for any possible damage done due to the use of this code.               }
{ The component can be freely used in any application. The complete       }
{ source code remains property of the author and may not be distributed,  }
{ published, given or sold in any form as such. No parts of the source    }
{ code can be included in any other component or application without      }
{ written authorization of the author.                                    }
{*************************************************************************}

{$I TMSDEFS.INC}

unit DBAdvSmoothDatePickerDE;

interface

uses
  Classes, Controls, DBAdvSmoothDatePicker, dialogs, DB
  {$IFDEF DELPHI2006_LVL}
  ,WideStrings
  {$ENDIF}
  {$IFDEF DELPHI6_LVL}
  , DesignIntf, DesignEditors
  {$ELSE}
  , DsgnIntf
  {$ENDIF}
  ;


type

  TDBAdvSmoothDatePickerFieldNameProperty = class(TStringProperty)
  public
    function GetAttributes:TPropertyAttributes; override;
    procedure GetValues(Proc:TGetStrProc); override;
  end;

implementation

uses
  SysUtils;

//------------------------------------------------------------------------------
{ TDBAdvSmoothDatePickerFieldNameProperty }

function TDBAdvSmoothDatePickerFieldNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList];
end;

//------------------------------------------------------------------------------

procedure TDBAdvSmoothDatePickerFieldNameProperty.GetValues(Proc: TGetStrProc);
var
  FDBDatePicker: TDBAdvSmoothDatePicker;
  aDataSource: TDataSource;
  FDataSet: TDataSet;
  {$IFNDEF DELPHIXE3_LVL}
  {$IFDEF DELPHI2006_LVL}
  st: TWideStringList;
  {$ENDIF}
  {$IFNDEF DELPHI2006_LVL}
  st: TStringList;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DELPHIXE3_LVL}
  st: TStringList;
  {$ENDIF}
  i: Integer;
begin
  if (GetComponent(0) is TDBAdvSmoothDatePicker) then
    FDBDatePicker := (GetComponent(0) as TDBAdvSmoothDatePicker)
  else
    Exit;

  if not Assigned(FDBDatePicker) then
    Exit;

  aDataSource := FDBDatePicker.DataSource;

  if not Assigned(aDataSource) then
    Exit;

  FDataSet := aDataSource.DataSet;

  if not Assigned(FDataSet) then Exit;


  {$IFNDEF DELPHIXE3_LVL}
  {$IFDEF DELPHI2006_LVL}
  st := TWideStringList.Create;
  {$ENDIF}
  {$IFNDEF DELPHI2006_LVL}
  st := TStringList.Create;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DELPHIXE3_LVL}
  st := TStringList.Create;
  {$ENDIF}

  FDataSet.GetFieldNames(st);
  for i := 1 to st.Count do
    Proc(st.Strings[i - 1]);
  st.Free;
end;

//------------------------------------------------------------------------------

end.
