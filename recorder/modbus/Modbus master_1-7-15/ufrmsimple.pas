unit uFrmSimple;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls;

type

  { TFrmSimple }

  TFrmSimple = class(TFrame)
  private

  public
    procedure UpdateHmi; virtual; abstract;
  end;

implementation

{$R *.lfm}

{ TFrmSimple }


end.

